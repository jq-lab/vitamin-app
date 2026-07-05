#!/usr/bin/env node
import http from "node:http";
import { createReadStream, existsSync } from "node:fs";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const appRoot = path.resolve(__dirname, "../..");
const host = process.env.VITORA_TTS_HOST || "127.0.0.1";
const port = Number(process.env.VITORA_TTS_PORT || 8787);
const dataDir = path.resolve(process.env.VITORA_TTS_DATA_DIR || path.join(appRoot, ".vitora-tts"));
const audioDir = path.resolve(process.env.VITORA_TTS_AUDIO_DIR || path.join(dataDir, "audio"));
const messagesPath = path.join(dataDir, "messages.json");
const publicBaseUrl = (process.env.VITORA_TTS_PUBLIC_BASE_URL || `http://${host}:${port}`).replace(/\/+$/, "");

async function ensureStore() {
  await mkdir(audioDir, { recursive: true });
  if (!existsSync(messagesPath)) {
    await writeFile(messagesPath, JSON.stringify({ messages: [] }, null, 2));
  }
}

async function readMessages() {
  await ensureStore();
  try {
    const parsed = JSON.parse(await readFile(messagesPath, "utf8"));
    return Array.isArray(parsed.messages) ? parsed.messages : [];
  } catch {
    return [];
  }
}

async function writeMessages(messages) {
  await mkdir(dataDir, { recursive: true });
  await writeFile(messagesPath, JSON.stringify({ messages }, null, 2));
}

function sendJson(res, status, payload) {
  const body = JSON.stringify(payload);
  res.writeHead(status, {
    "Content-Type": "application/json; charset=utf-8",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type, Authorization",
    "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
  });
  res.end(body);
}

function escapeHtml(value) {
  return String(value ?? "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

function sendHtml(res, status, body) {
  res.writeHead(status, {
    "Content-Type": "text/html; charset=utf-8",
    "Access-Control-Allow-Origin": "*",
  });
  res.end(body);
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    let body = "";
    req.setEncoding("utf8");
    req.on("data", (chunk) => {
      body += chunk;
      if (body.length > 1024 * 1024) {
        reject(new Error("request body too large"));
        req.destroy();
      }
    });
    req.on("end", () => resolve(body ? JSON.parse(body) : {}));
    req.on("error", reject);
  });
}

function sanitizeAudioPath(value) {
  const clean = decodeURIComponent(value).replace(/^\/+/, "");
  if (clean.includes("..")) return null;
  return clean;
}

function audioUrlFor(audioId) {
  return `${publicBaseUrl}/audio/${encodeURIComponent(audioId)}.mp3`;
}

async function handlePostMessage(req, res) {
  const payload = await readBody(req);
  const now = new Date().toISOString();
  const audioId = String(payload.audioId || payload.messageId || `tts-${Date.now()}`).replace(/[^a-zA-Z0-9_-]/g, "-");
  const message = {
    audioId,
    messageId: String(payload.messageId || audioId),
    text: String(payload.text || payload.audioText || ""),
    audioText: String(payload.audioText || payload.text || ""),
    audioUrl: String(payload.audioUrl || audioUrlFor(audioId)),
    voiceId: payload.voiceId ? String(payload.voiceId) : "",
    persona: payload.persona ? String(payload.persona) : "",
    reason: payload.reason ? String(payload.reason) : "",
    targetSurface: payload.targetSurface === "explore" || payload.targetSurface === "both" ? payload.targetSurface : "today",
    createdAt: payload.createdAt ? String(payload.createdAt) : now,
  };
  const messages = await readMessages();
  const deduped = messages.filter((item) => item.messageId !== message.messageId && item.audioId !== message.audioId);
  deduped.push(message);
  await writeMessages(deduped.slice(-200));
  sendJson(res, 200, { ok: true, message });
}

async function handleGetMessages(req, res, url) {
  const since = url.searchParams.get("since");
  const sinceTime = since ? Date.parse(since) : 0;
  const messages = await readMessages();
  const visible = messages.filter((message) => {
    const createdAt = Date.parse(message.createdAt || "");
    return Number.isFinite(createdAt) && createdAt > sinceTime;
  });
  sendJson(res, 200, { ok: true, messages: visible });
}

async function handleDashboard(_req, res) {
  const messages = await readMessages();
  const recent = messages.slice(-8).reverse();
  const rows = recent.length
    ? recent
        .map((message) => {
          const audioUrl = message.audioUrl || audioUrlFor(message.audioId);
          return `<li><a href="${escapeHtml(audioUrl)}">${escapeHtml(message.audioId)}</a><small>${escapeHtml(message.targetSurface)} · ${escapeHtml(message.createdAt)}</small><p>${escapeHtml(message.audioText || message.text)}</p></li>`;
        })
        .join("")
    : "<li><p>No TTS messages registered yet.</p></li>";
  sendHtml(
    res,
    200,
    `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Vitora TTS Bridge</title>
  <style>
    :root { color-scheme: dark; font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", sans-serif; }
    body { margin: 0; min-height: 100vh; background: radial-gradient(circle at 20% 0%, #3b4650, #111519 48%, #080a0c); color: #eef3f4; }
    main { max-width: 820px; margin: 0 auto; padding: 44px 22px; }
    .card { border: 1px solid rgba(255,255,255,0.16); border-radius: 28px; padding: 24px; background: rgba(255,255,255,0.08); box-shadow: 0 28px 80px rgba(0,0,0,0.35); backdrop-filter: blur(28px); }
    h1 { margin: 0 0 8px; font-size: 34px; letter-spacing: -0.04em; }
    p { color: rgba(238,243,244,0.72); line-height: 1.55; }
    code, a { color: #d7ff5f; }
    .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 12px; margin: 22px 0; }
    .pill { border-radius: 18px; background: rgba(255,255,255,0.1); padding: 14px 16px; }
    ul { list-style: none; padding: 0; display: grid; gap: 12px; }
    li { border-radius: 18px; background: rgba(255,255,255,0.09); padding: 14px 16px; }
    li small { display: block; margin-top: 6px; color: rgba(238,243,244,0.54); }
    li p { margin: 8px 0 0; }
  </style>
</head>
<body>
  <main>
    <section class="card">
      <h1>Vitora TTS Bridge</h1>
      <p>Bridge is running. The app polls this service for MCP-generated audio messages.</p>
      <div class="grid">
        <div class="pill"><strong>Status</strong><br /><code>ok</code></div>
        <div class="pill"><strong>Messages</strong><br /><code>${messages.length}</code></div>
        <div class="pill"><strong>Audio dir</strong><br /><code>${escapeHtml(audioDir)}</code></div>
      </div>
      <p>API: <a href="/health">/health</a> · <a href="/api/tts/messages">/api/tts/messages</a></p>
      <h2>Recent audio</h2>
      <ul>${rows}</ul>
    </section>
  </main>
</body>
</html>`
  );
}

function handleGetAudio(req, res, pathname) {
  const requested = sanitizeAudioPath(pathname.replace(/^\/audio\//, ""));
  if (!requested) {
    sendJson(res, 400, { ok: false, error: "invalid audio path" });
    return;
  }
  const fileName = requested.endsWith(".mp3") ? requested : `${requested}.mp3`;
  const filePath = path.join(audioDir, fileName);
  if (!filePath.startsWith(audioDir) || !existsSync(filePath)) {
    sendJson(res, 404, { ok: false, error: "audio not found" });
    return;
  }
  res.writeHead(200, {
    "Content-Type": "audio/mpeg",
    "Access-Control-Allow-Origin": "*",
    "Cache-Control": "public, max-age=31536000, immutable",
  });
  if (req.method === "HEAD") {
    res.end();
    return;
  }
  createReadStream(filePath).pipe(res);
}

await ensureStore();

const server = http.createServer(async (req, res) => {
  try {
    if (req.method === "OPTIONS") {
      sendJson(res, 204, {});
      return;
    }
    const url = new URL(req.url || "/", publicBaseUrl);
    if (req.method === "GET" && url.pathname === "/") {
      await handleDashboard(req, res);
      return;
    }
    if (req.method === "GET" && url.pathname === "/health") {
      sendJson(res, 200, { ok: true, audioDir, messagesPath });
      return;
    }
    if (req.method === "GET" && url.pathname === "/api/tts/messages") {
      await handleGetMessages(req, res, url);
      return;
    }
    if (req.method === "POST" && url.pathname === "/api/tts/messages") {
      await handlePostMessage(req, res);
      return;
    }
    if ((req.method === "GET" || req.method === "HEAD") && url.pathname.startsWith("/audio/")) {
      handleGetAudio(req, res, url.pathname);
      return;
    }
    sendJson(res, 404, { ok: false, error: "not found" });
  } catch (error) {
    sendJson(res, 500, { ok: false, error: error instanceof Error ? error.message : String(error) });
  }
});

server.on("error", (error) => {
  console.error(`[vitora-tts-bridge] listen failed: ${error instanceof Error ? error.stack || error.message : String(error)}`);
  process.exit(1);
});

server.listen(port, host, () => {
  console.log(`[vitora-tts-bridge] ${publicBaseUrl}`);
  console.log(`[vitora-tts-bridge] audioDir=${audioDir}`);
});
