#!/usr/bin/env node
import { existsSync } from "node:fs";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const appRoot = path.resolve(__dirname, "../..");
const dataDir = path.resolve(process.env.VITORA_TTS_DATA_DIR || path.join(appRoot, ".vitora-tts"));
const audioDir = path.resolve(process.env.VITORA_TTS_AUDIO_DIR || path.join(dataDir, "audio"));
const bridgeUrl = (process.env.VITORA_TTS_BRIDGE_URL || "http://127.0.0.1:8787").replace(/\/+$/, "");
const elevenLabsEndpoint = (process.env.ELEVENLABS_TTS_ENDPOINT || "https://api.elevenlabs.io/v1/text-to-speech").replace(/\/+$/, "");
const outputFormat = process.env.ELEVENLABS_OUTPUT_FORMAT || "mp3_44100_128";
const defaultVoiceId =
  process.env.ELEVENLABS_VOICE_ID ||
  process.env.ELEVENLABS_DORI_MALE_VOICE_ID ||
  process.env.ELEVENLABS_DORI_VOICE_ID ||
  "";

const voicePresets = {
  dori_male: {
    modelId: "eleven_multilingual_v2",
    voiceId: process.env.ELEVENLABS_DORI_MALE_VOICE_ID || defaultVoiceId,
    settings: { stability: 0.64, similarity_boost: 0.84, style: 0.16, use_speaker_boost: true, speed: 0.92 },
  },
  dori_male_care: {
    modelId: "eleven_multilingual_v2",
    voiceId: process.env.ELEVENLABS_DORI_MALE_CARE_VOICE_ID || process.env.ELEVENLABS_DORI_MALE_VOICE_ID || defaultVoiceId,
    settings: { stability: 0.7, similarity_boost: 0.84, style: 0.1, use_speaker_boost: true, speed: 0.88 },
  },
  dori_male_action: {
    modelId: "eleven_multilingual_v2",
    voiceId: process.env.ELEVENLABS_DORI_MALE_ACTION_VOICE_ID || process.env.ELEVENLABS_DORI_MALE_VOICE_ID || defaultVoiceId,
    settings: { stability: 0.56, similarity_boost: 0.82, style: 0.24, use_speaker_boost: true, speed: 0.98 },
  },
  dori_male_intimate: {
    modelId: "eleven_multilingual_v2",
    voiceId: process.env.ELEVENLABS_DORI_MALE_INTIMATE_VOICE_ID || process.env.ELEVENLABS_DORI_MALE_VOICE_ID || defaultVoiceId,
    settings: { stability: 0.76, similarity_boost: 0.86, style: 0.14, use_speaker_boost: true, speed: 0.84 },
  },
};

function sanitize(value, fallback) {
  const clean = String(value || fallback || "")
    .replace(/[^a-zA-Z0-9_-]/g, "-")
    .replace(/-+/g, "-")
    .replace(/^-|-$/g, "");
  return clean || fallback;
}

function todayCompact() {
  return new Date().toISOString().slice(0, 10).replaceAll("-", "");
}

function audioUrlFor(audioId) {
  return `${bridgeUrl}/audio/${encodeURIComponent(audioId)}.mp3`;
}

function numberArg(value, fallback) {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : fallback;
}

function boolArg(value, fallback) {
  if (value === undefined || value === null || value === "") return fallback;
  return value === true || value === "1" || value === "true";
}

function resolveVoiceConfig(args = {}) {
  const presetName = typeof args.preset === "string" && voicePresets[args.preset] ? args.preset : "dori_male";
  const preset = voicePresets[presetName];
  return {
    presetName,
    voiceId: String(args.voiceId || preset.voiceId || defaultVoiceId || "").trim(),
    modelId: String(args.modelId || process.env.ELEVENLABS_MODEL || preset.modelId).trim(),
    languageCode: String(args.languageCode || process.env.ELEVENLABS_LANGUAGE_CODE || "zh").trim(),
    settings: {
      stability: numberArg(args.stability ?? process.env.ELEVENLABS_STABILITY, preset.settings.stability),
      similarity_boost: numberArg(args.similarityBoost ?? process.env.ELEVENLABS_SIMILARITY, preset.settings.similarity_boost),
      style: numberArg(args.style ?? process.env.ELEVENLABS_STYLE, preset.settings.style),
      use_speaker_boost: boolArg(args.useSpeakerBoost ?? process.env.ELEVENLABS_USE_SPEAKER_BOOST, preset.settings.use_speaker_boost),
      speed: numberArg(args.speed ?? process.env.ELEVENLABS_SPEED, preset.settings.speed),
    },
  };
}

async function synthesizeElevenLabs({ text, voiceId, modelId, languageCode, settings }) {
  if (process.env.VITORA_TTS_DRY_RUN === "1") {
    const samplePath = path.resolve(process.env.VITORA_TTS_SAMPLE_AUDIO || path.join(appRoot, "web/voice-bakeoff/audio/selection_edge_ghost_soft.mp3"));
    if (!existsSync(samplePath)) throw new Error(`dry run sample audio not found: ${samplePath}`);
    return readFile(samplePath);
  }
  if (!process.env.ELEVENLABS_API_KEY) {
    throw new Error("Missing ELEVENLABS_API_KEY. Set it on VPS/local shell, never in the app bundle.");
  }
  if (!voiceId) {
    throw new Error("Missing voiceId. Pass voiceId or set ELEVENLABS_VOICE_ID / ELEVENLABS_DORI_VOICE_ID.");
  }
  const endpoint = `${elevenLabsEndpoint}/${encodeURIComponent(voiceId)}?output_format=${encodeURIComponent(outputFormat)}`;
  const response = await fetch(endpoint, {
    method: "POST",
    headers: {
      "xi-api-key": process.env.ELEVENLABS_API_KEY,
      "Content-Type": "application/json",
      Accept: "audio/mpeg",
    },
    body: JSON.stringify({
      text,
      model_id: modelId,
      language_code: languageCode,
      voice_settings: settings,
    }),
  });
  if (!response.ok) {
    const body = await response.text().catch(() => "");
    throw new Error(`ElevenLabs ${response.status}: ${body.slice(0, 400)}`);
  }
  return Buffer.from(await response.arrayBuffer());
}

async function registerWithBridge(message) {
  const response = await fetch(`${bridgeUrl}/api/tts/messages`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(message),
  });
  if (!response.ok) {
    const body = await response.text().catch(() => "");
    throw new Error(`bridge ${response.status}: ${body.slice(0, 300)}`);
  }
  return response.json();
}

async function speakWithDoriVoice(args) {
  const text = String(args?.text || "").trim();
  if (!text) throw new Error("text is required");
  const voiceConfig = resolveVoiceConfig(args);
  const voiceId = voiceConfig.voiceId;
  const messageId = sanitize(args?.messageId, `tts-${Date.now()}`);
  const audioId = sanitize(args?.audioId, `${todayCompact()}-${messageId}`);
  const targetSurface = args?.targetSurface === "explore" || args?.targetSurface === "both" ? args.targetSurface : "today";
  await mkdir(audioDir, { recursive: true });
  const audio = await synthesizeElevenLabs({ text, ...voiceConfig });
  const audioPath = path.join(audioDir, `${audioId}.mp3`);
  await writeFile(audioPath, audio);
  const createdAt = new Date().toISOString();
  const message = {
    audioId,
    audioUrl: audioUrlFor(audioId),
    text,
    audioText: text,
    voiceId,
    voicePreset: voiceConfig.presetName,
    voiceSettings: voiceConfig.settings,
    messageId,
    persona: args?.persona ? String(args.persona) : "dori",
    reason: args?.reason ? String(args.reason) : "claude-code-selected-voice",
    targetSurface,
    createdAt,
  };
  let bridgeRegistered = false;
  try {
    await registerWithBridge(message);
    bridgeRegistered = true;
  } catch (error) {
    message.bridgeError = error instanceof Error ? error.message : String(error);
  }
  return { ...message, audioPath, bridgeRegistered };
}

const tool = {
  name: "speak_with_dori_voice",
  description: "Generate a Dori TTS audio clip with ElevenLabs, save it locally, register it with the Vitora TTS bridge, and return the playable audio URL.",
  inputSchema: {
    type: "object",
    properties: {
      text: { type: "string", description: "The exact words Dori should speak." },
      voiceId: { type: "string", description: "ElevenLabs voice_id. Falls back to ELEVENLABS_VOICE_ID." },
      preset: {
        type: "string",
        enum: ["dori_male", "dori_male_care", "dori_male_action", "dori_male_intimate"],
        description: "Male Dori voice preset. Defaults to dori_male.",
      },
      modelId: { type: "string", description: "Optional ElevenLabs model override." },
      languageCode: { type: "string", description: "Optional language code override, defaults to zh." },
      stability: { type: "number", description: "Optional per-call stability override." },
      similarityBoost: { type: "number", description: "Optional per-call similarity_boost override." },
      style: { type: "number", description: "Optional per-call style exaggeration override." },
      speed: { type: "number", description: "Optional per-call speed override." },
      useSpeakerBoost: { type: "boolean", description: "Optional per-call speaker boost override." },
      messageId: { type: "string", description: "Stable message id for dedupe in the app." },
      persona: { type: "string", description: "Voice/persona label, for metadata only." },
      reason: { type: "string", description: "Why Claude decided to speak this message." },
      targetSurface: { type: "string", enum: ["today", "explore", "both"], description: "Where the simulator should show the audio bar." },
    },
    required: ["text"],
    additionalProperties: false,
  },
};

function send(message) {
  const json = JSON.stringify(message);
  process.stdout.write(`Content-Length: ${Buffer.byteLength(json, "utf8")}\r\n\r\n${json}`);
}

async function handle(message) {
  if (!message || typeof message !== "object") return;
  if (!("id" in message)) return;
  try {
    if (message.method === "initialize") {
      send({
        jsonrpc: "2.0",
        id: message.id,
        result: {
          protocolVersion: message.params?.protocolVersion || "2024-11-05",
          capabilities: { tools: {} },
          serverInfo: { name: "vitora-tts-mcp", version: "1.0.0" },
        },
      });
      return;
    }
    if (message.method === "tools/list") {
      send({ jsonrpc: "2.0", id: message.id, result: { tools: [tool] } });
      return;
    }
    if (message.method === "tools/call") {
      if (message.params?.name !== tool.name) throw new Error(`Unknown tool: ${message.params?.name}`);
      const result = await speakWithDoriVoice(message.params?.arguments || {});
      send({
        jsonrpc: "2.0",
        id: message.id,
        result: {
          content: [{ type: "text", text: JSON.stringify(result, null, 2) }],
          structuredContent: result,
        },
      });
      return;
    }
    send({ jsonrpc: "2.0", id: message.id, error: { code: -32601, message: `Method not found: ${message.method}` } });
  } catch (error) {
    send({
      jsonrpc: "2.0",
      id: message.id,
      error: { code: -32000, message: error instanceof Error ? error.message : String(error) },
    });
  }
}

let buffer = Buffer.alloc(0);

function tryReadContentLengthFrame() {
  const marker = buffer.indexOf("\r\n\r\n");
  if (marker < 0) return null;
  const header = buffer.slice(0, marker).toString("utf8");
  const match = header.match(/Content-Length:\s*(\d+)/i);
  if (!match) return null;
  const length = Number(match[1]);
  const start = marker + 4;
  const end = start + length;
  if (buffer.length < end) return null;
  const raw = buffer.slice(start, end).toString("utf8");
  buffer = buffer.slice(end);
  return JSON.parse(raw);
}

function tryReadJsonLine() {
  const newline = buffer.indexOf("\n");
  if (newline < 0) return null;
  const raw = buffer.slice(0, newline).toString("utf8").trim();
  buffer = buffer.slice(newline + 1);
  if (!raw) return null;
  return JSON.parse(raw);
}

process.stdin.on("data", (chunk) => {
  buffer = Buffer.concat([buffer, chunk]);
  while (buffer.length) {
    let message = null;
    try {
      message = tryReadContentLengthFrame() || tryReadJsonLine();
    } catch (error) {
      console.error(`[vitora-tts-mcp] parse error: ${error instanceof Error ? error.message : String(error)}`);
      buffer = Buffer.alloc(0);
      return;
    }
    if (!message) return;
    void handle(message);
  }
});

console.error("[vitora-tts-mcp] ready");
