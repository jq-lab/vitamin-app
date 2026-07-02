#!/usr/bin/env node
import { mkdir, mkdtemp, readFile, rename, rm, stat, writeFile } from "node:fs/promises";
import { existsSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { tmpdir } from "node:os";
import { execFile } from "node:child_process";
import { promisify } from "node:util";
import { bakeoffTexts } from "./texts.mjs";
import { providerProfiles } from "./providers.mjs";
import { directScript, stripPerformanceTags } from "./voice-director.mjs";
import { publicVoiceCandidates, publicVoiceSources } from "./voice-source-catalog.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const appRoot = path.resolve(__dirname, "../..");
const defaultOutputDir = path.join(appRoot, "voice-bakeoff");
const audioDirName = "audio";
const voiceSourceDocPath = path.join(appRoot, "docs", "voice-source-catalog.md");
const execFileAsync = promisify(execFile);
const defaultBakeoffTextIds = ["today_ready", "sleep_recovery_weak", "stress_attention", "ai_reply_short"];

function parseArgs(argv) {
  const out = {
    outputDir: defaultOutputDir,
    providers: null,
    textIds: null,
    limit: null,
    dryRun: false,
    force: false,
    postProcess: true,
  };
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === "--out") out.outputDir = path.resolve(argv[++i]);
    else if (arg === "--provider") out.providers = argv[++i].split(",").map((x) => x.trim()).filter(Boolean);
    else if (arg === "--text") out.textIds = argv[++i].split(",").map((x) => x.trim()).filter(Boolean);
    else if (arg === "--limit") out.limit = Number(argv[++i]);
    else if (arg === "--dry-run") out.dryRun = true;
    else if (arg === "--force") out.force = true;
    else if (arg === "--no-post-process") out.postProcess = false;
    else if (arg === "--help" || arg === "-h") {
      printHelp();
      process.exit(0);
    }
  }
  return out;
}

function printHelp() {
  console.log(`Usage: pnpm tts:bakeoff [options]

Options:
  --provider elevenlabs_v3,minimax,dashscope_cosyvoice,azure,openai
  --text today_ready,stress_attention
  --limit 3
  --out ./voice-bakeoff
  --dry-run
  --force
  --no-post-process

Default text set: ${defaultBakeoffTextIds.join(", ")}
`);
}

function missingEnv(keys) {
  return keys.filter((key) => !process.env[key]);
}

function sanitize(input) {
  return input.replace(/[^a-z0-9_-]+/gi, "_").replace(/^_+|_+$/g, "").toLowerCase();
}

function isHexAudio(value) {
  return typeof value === "string" && value.length > 32 && value.length % 2 === 0 && /^[0-9a-f]+$/i.test(value);
}

function isBase64Audio(value) {
  return typeof value === "string" && value.length > 32 && /^[A-Za-z0-9+/=]+$/.test(value);
}

async function downloadAudio(url) {
  const response = await fetch(url);
  if (!response.ok) throw new Error(`audio url ${response.status} ${response.statusText}`);
  return Buffer.from(await response.arrayBuffer());
}

async function audioFromJson(json) {
  const candidates = [
    json?.data?.audio,
    json?.data?.audio_base64,
    json?.audio,
    json?.audio_base64,
    json?.output?.audio,
    json?.output?.audio_base64,
  ].filter(Boolean);
  for (const value of candidates) {
    if (isHexAudio(value)) return Buffer.from(value, "hex");
    if (isBase64Audio(value)) return Buffer.from(value, "base64");
  }

  const url =
    json?.data?.audio_url ||
    json?.data?.url ||
    json?.output?.audio_url ||
    json?.output?.url ||
    json?.audio_url ||
    json?.url;
  if (url) return downloadAudio(url);

  throw new Error(`No audio payload found in JSON response: ${JSON.stringify(json).slice(0, 500)}`);
}

function makeMiniMaxPayload({ profile, voice, text }) {
  return {
    model: profile.defaultModel,
    text,
    stream: false,
    voice_setting: {
      voice_id: voice.voiceId,
      speed: voice.speed,
      vol: 1,
      pitch: Math.round((voice.pitch - 1) * 10),
    },
    audio_setting: {
      sample_rate: 32000,
      bitrate: 128000,
      format: "mp3",
      channel: 1,
    },
  };
}

function makeElevenLabsPayload({ profile, voice, text }) {
  return {
    text,
    model_id: profile.defaultModel,
    language_code: voice.languageCode || process.env.ELEVENLABS_LANGUAGE_CODE || "zh",
    voice_settings: {
      stability: voice.stability ?? 0.36,
      similarity_boost: voice.similarityBoost ?? 0.76,
      style: voice.styleExaggeration ?? 0.84,
      use_speaker_boost: voice.useSpeakerBoost !== false,
      speed: voice.speed ?? 1,
    },
  };
}

async function synthesizeElevenLabs(input) {
  const base = process.env.ELEVENLABS_TTS_ENDPOINT || "https://api.elevenlabs.io/v1/text-to-speech";
  const outputFormat = process.env.ELEVENLABS_OUTPUT_FORMAT || "mp3_44100_128";
  const endpoint = `${base}/${encodeURIComponent(input.voice.voiceId)}?output_format=${encodeURIComponent(outputFormat)}`;
  const response = await fetch(endpoint, {
    method: "POST",
    headers: {
      "xi-api-key": process.env.ELEVENLABS_API_KEY,
      "Content-Type": "application/json",
      Accept: "audio/mpeg",
    },
    body: JSON.stringify(makeElevenLabsPayload(input)),
  });
  return responseToAudio(response);
}

async function synthesizeMiniMax(input) {
  const endpoint =
    process.env.MINIMAX_TTS_ENDPOINT ||
    `https://api.minimax.chat/v1/t2a_v2?GroupId=${encodeURIComponent(process.env.MINIMAX_GROUP_ID)}`;
  const response = await fetch(endpoint, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${process.env.MINIMAX_API_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(makeMiniMaxPayload(input)),
  });
  return responseToAudio(response);
}

function makeDashScopePayload({ profile, voice, text }) {
  return {
    model: profile.defaultModel,
    input: {
      text,
      voice: voice.voiceId,
    },
    parameters: {
      format: "mp3",
      sample_rate: 32000,
      speed: voice.speed,
      pitch: voice.pitch,
      style: voice.style,
    },
  };
}

async function synthesizeDashScope(input) {
  const endpoint =
    process.env.DASHSCOPE_TTS_ENDPOINT ||
    "https://dashscope.aliyuncs.com/api/v1/services/aigc/multimodal-generation/generation";
  const response = await fetch(endpoint, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${process.env.DASHSCOPE_API_KEY}`,
      "Content-Type": "application/json",
      "X-DashScope-Async": "disable",
    },
    body: JSON.stringify(makeDashScopePayload(input)),
  });
  return responseToAudio(response);
}

function escapeXml(value) {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&apos;");
}

function azureRate(speed) {
  const pct = Math.round((speed - 1) * 100);
  return `${pct >= 0 ? "+" : ""}${pct}%`;
}

function azurePitch(pitch) {
  const pct = Math.round((pitch - 1) * 100);
  return `${pct >= 0 ? "+" : ""}${pct}%`;
}

async function synthesizeAzure({ voice, text }) {
  const endpoint =
    process.env.AZURE_TTS_ENDPOINT ||
    `https://${process.env.AZURE_SPEECH_REGION}.tts.speech.microsoft.com/cognitiveservices/v1`;
  const prosody = `<prosody rate="${azureRate(voice.speed)}" pitch="${azurePitch(voice.pitch)}">${escapeXml(
    stripPerformanceTags(text),
  )}</prosody>`;
  const expressive =
    voice.azureStyle && process.env.AZURE_DISABLE_EXPRESS_AS !== "1"
      ? `<mstts:express-as style="${escapeXml(voice.azureStyle)}"${
          voice.azureRole ? ` role="${escapeXml(voice.azureRole)}"` : ""
        }>${prosody}</mstts:express-as>`
      : prosody;
  const ssml = `<speak version="1.0" xml:lang="zh-CN" xmlns:mstts="https://www.w3.org/2001/mstts"><voice xml:lang="zh-CN" name="${escapeXml(
    voice.voiceId,
  )}">${expressive}</voice></speak>`;
  const response = await fetch(endpoint, {
    method: "POST",
    headers: {
      "Ocp-Apim-Subscription-Key": process.env.AZURE_SPEECH_KEY,
      "Content-Type": "application/ssml+xml",
      "X-Microsoft-OutputFormat": "audio-24khz-96kbitrate-mono-mp3",
      "User-Agent": "vivi-tts-bakeoff",
    },
    body: ssml,
  });
  return responseToAudio(response);
}

async function synthesizeOpenAI({ profile, voice, text, director }) {
  const endpoint = process.env.OPENAI_TTS_ENDPOINT || "https://api.openai.com/v1/audio/speech";
  const response = await fetch(endpoint, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${process.env.OPENAI_API_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: profile.defaultModel,
      voice: voice.voiceId,
      input: stripPerformanceTags(text),
      instructions: director?.instructions || voice.instructions,
      response_format: "mp3",
      speed: voice.speed,
    }),
  });
  return responseToAudio(response);
}

function edgeTtsBin() {
  const configured = process.env.EDGE_TTS_BIN;
  if (configured) return configured;
  const tempVenvBin = "/private/tmp/vivi-edge-tts-venv/bin/edge-tts";
  if (existsSync(tempVenvBin)) return tempVenvBin;
  return "edge-tts";
}

function edgeRate(speed) {
  const pct = Math.round((speed - 1) * 100);
  return `${pct >= 0 ? "+" : ""}${pct}%`;
}

function edgePitch(pitch) {
  const hz = Math.round((pitch - 1) * 80);
  return `${hz >= 0 ? "+" : ""}${hz}Hz`;
}

async function synthesizeEdge({ voice, text }) {
  const tempDir = await mkdtemp(path.join(tmpdir(), "vivi-edge-tts-"));
  const mediaPath = path.join(tempDir, "sample.mp3");
  try {
    await execFileAsync(
      edgeTtsBin(),
      [
        "--voice",
        voice.voiceId,
        "--text",
        text,
        `--rate=${edgeRate(voice.speed)}`,
        `--pitch=${edgePitch(voice.pitch)}`,
        "--write-media",
        mediaPath,
      ],
      { maxBuffer: 1024 * 1024 * 4 },
    );
    return readFile(mediaPath);
  } finally {
    await rm(tempDir, { force: true, recursive: true });
  }
}

async function responseToAudio(response) {
  const contentType = response.headers.get("content-type") || "";
  if (!response.ok) {
    const body = await response.text();
    throw new Error(`${response.status} ${response.statusText}: ${body.slice(0, 800)}`);
  }
  if (/audio|octet-stream/i.test(contentType)) {
    return Buffer.from(await response.arrayBuffer());
  }
  const json = await response.json();
  return audioFromJson(json);
}

async function synthesize(input) {
  if (input.profile.id === "elevenlabs_v3") return synthesizeElevenLabs(input);
  if (input.profile.id === "edge_neural") return synthesizeEdge(input);
  if (input.profile.id === "minimax") return synthesizeMiniMax(input);
  if (input.profile.id === "dashscope_cosyvoice") return synthesizeDashScope(input);
  if (input.profile.id === "azure") return synthesizeAzure(input);
  if (input.profile.id === "openai") return synthesizeOpenAI(input);
  throw new Error(`Unknown provider: ${input.profile.id}`);
}

async function postProcessAudio(filePath, enabled) {
  if (!enabled || process.env.TTS_SKIP_POST_PROCESS === "1") {
    return { applied: false, reason: "disabled" };
  }
  const tempPath = `${filePath}.post.mp3`;
  try {
    await execFileAsync(
      process.env.FFMPEG_BIN || "ffmpeg",
      [
        "-hide_banner",
        "-loglevel",
        "error",
        "-y",
        "-i",
        filePath,
        "-af",
        "highpass=f=65,equalizer=f=7600:t=q:w=1.1:g=1.4,acompressor=threshold=-18dB:ratio=2.1:attack=8:release=130,loudnorm=I=-16:TP=-1.5:LRA=10",
        "-codec:a",
        "libmp3lame",
        "-b:a",
        "160k",
        tempPath,
      ],
      { maxBuffer: 1024 * 1024 * 4 },
    );
    await rename(tempPath, filePath);
    const info = await stat(filePath);
    return {
      applied: true,
      bytes: info.size,
      chain: "highpass 65Hz + air EQ + light compression + loudnorm -16 LUFS",
    };
  } catch (error) {
    await rm(tempPath, { force: true });
    return {
      applied: false,
      reason: error instanceof Error ? error.message : String(error),
    };
  }
}

function estimateCost({ text }) {
  return {
    chars: [...text].length,
    note: "Provider pricing varies; fill after selecting production provider.",
  };
}

const voiceSelectionOptions = [
  {
    id: "elevenlabs_noir_reference",
    provider: "elevenlabs_v3",
    providerLabel: "ElevenLabs v3",
    voicePreset: "noir_reference",
    title: "NOIR Vessel 参考声线",
    badge: "视频质感",
    role: "冷白、疏离、电影旁白感；需要合法授权 voice_id 才可能接近视频同款。",
    localVoice: "ELEVENLABS_NOIR_VOICE_ID",
    localRate: 1.18,
    sampleText:
      "[softly] But I know you. [pause] You move faster when the room gets quiet. [long pause] So today, take the first step before the noise comes back.",
  },
  {
    id: "elevenlabs_cloud_smart",
    provider: "elevenlabs_v3",
    providerLabel: "ElevenLabs v3",
    voicePreset: "cloud_smart_soft",
    title: "小云朵 · 聪明软萌",
    badge: "主推荐",
    role: "聪明、轻软、好奇，像云朵探头提醒；不幼态，不客服。",
    localVoice: "ELEVENLABS_CLOUD_SMART_VOICE_ID",
    localRate: 1.12,
    sampleText:
      "[softly] 嗯，我在这儿。[pause] 今天状态不错，昨晚的恢复托住了你。[teasing] 重要的事，我们先放在上午，慢慢往前推。",
  },
  {
    id: "elevenlabs_noir_low_male",
    provider: "elevenlabs_v3",
    providerLabel: "ElevenLabs v3",
    voicePreset: "noir_low_male",
    title: "正式候选 · NOIR 男低音",
    badge: "视频平替",
    role: "优先用于接近视频里的冷白、低沉、贴耳、电影旁白气质；需要合法 voiceId。",
    localVoice: "ELEVENLABS_NOIR_LOW_MALE_VOICE_ID",
    localRate: 1.1,
    sampleText:
      "[softly] 嗯。今天的底子还不错。[pause] 恢复托住了你。重要的事，放在上午。[long pause] 别急着证明什么。",
  },
  {
    id: "minimax_noir_low_male",
    provider: "minimax",
    providerLabel: "MiniMax Speech-02 HD",
    voicePreset: "noir_low_male",
    title: "中文候选 · NOIR 男低音",
    badge: "中文优先",
    role: "中文低沉男声平替：克制、近讲、少播报感，适合 VIVI 中文场景。",
    localVoice: "MINIMAX_NOIR_LOW_MALE_VOICE_ID",
    localRate: 0.86,
    sampleText: "嗯。今天的底子还不错。恢复托住了你。重要的事，放在上午。别急着证明什么。",
  },
  {
    id: "minimax_young_mid_male",
    provider: "minimax",
    providerLabel: "MiniMax Speech-02 HD",
    voicePreset: "young_mid_male",
    title: "中文候选 · 青涩男中音",
    badge: "男中音",
    role: "中文年轻男中音：清亮、自然、轻陪伴，不油腻，不卖萌。",
    localVoice: "MINIMAX_YOUNG_MALE_VOICE_ID",
    localRate: 0.94,
    sampleText: "嗯，我看了一下。今天状态还不错。上午可以先推重要的事，别一下子排太满就好。",
  },
  {
    id: "minimax_confidante_sister",
    provider: "minimax",
    providerLabel: "MiniMax Speech-02 HD",
    voicePreset: "confidante_sister",
    title: "中文候选 · 知心大姐姐",
    badge: "女声主推",
    role: "中文成熟女声：温柔、可信、解释身体信号时不客服。",
    localVoice: "MINIMAX_CONFIDANTE_SISTER_VOICE_ID",
    localRate: 0.9,
    sampleText: "今天状态是稳的。你可以把重要的事放在上午慢慢推进，晚上记得给自己留一点恢复时间。",
  },
  {
    id: "minimax_cloud_recovery",
    provider: "minimax",
    providerLabel: "MiniMax Speech-02 HD",
    voicePreset: "cloud_soft_c",
    title: "小云朵 · 安抚恢复",
    badge: "中文备选",
    role: "更慢、更温柔，适合睡眠恢复、压力提醒和经前窗口。",
    localVoice: "MINIMAX_CLOUD_SOFT_C_VOICE_ID",
    localRate: 0.88,
    sampleText: "先慢一点。身体还没完全修好，不是你做得不好。今天我们把强度放轻，状态会更稳。",
  },
  {
    id: "azure_stable_fallback",
    provider: "azure",
    providerLabel: "Azure Neural TTS",
    voicePreset: "sister_warm",
    title: "稳定兜底",
    badge: "生产兜底",
    role: "稳定、可信、低故障率；不是最有角色感，但适合兜底播放。",
    localVoice: "AZURE_SISTER_WARM_VOICE_ID",
    localRate: 0.92,
    sampleText: "今天状态不错，恢复条件比较稳。重要任务可以放在上午，但晚上仍然要留出恢复时间。",
  },
  {
    id: "local_edge_cloud_preview",
    provider: "edge_neural",
    providerLabel: "Edge Neural TTS · 本地可听调配",
    voicePreset: "ghost_soft",
    title: "本地可听 · 小云朵调配版",
    badge: "现在可听",
    role: "当前可直接试听的兜底样音，经过语气导演和轻后期；用于看效果，不作为最终主模型承诺。",
    localVoice: "zh-CN-XiaoyiNeural",
    localRate: 0.9,
    localFile: `${audioDirName}/edge_neural_ghost_soft_today_ready.mp3`,
    sampleText: "嗯，我在这儿。今天状态不错，昨晚的恢复托住了你。重要的事，我们先放在上午，慢慢往前推。",
  },
  {
    id: "local_edge_male_noir_preview",
    provider: "edge_neural",
    providerLabel: "Edge Neural TTS · 本地可听调配",
    voicePreset: "male_noir_preview",
    title: "男声 A · NOIR 低冷旁白",
    badge: "失败对照",
    role: "已判定不适合正式使用：降调后会闷、顶、系统播报感强。保留给对比，不再推荐选择。",
    localVoice: "zh-CN-YunyangNeural",
    localRate: 0.8,
    localFile: `${audioDirName}/edge_neural_male_noir_preview_today_ready.mp3`,
    sampleText: "嗯。今天的底子还不错。恢复托住了你。重要的事，放在上午。别急着证明什么。",
    selectable: false,
  },
  {
    id: "local_edge_male_youth_preview",
    provider: "edge_neural",
    providerLabel: "Edge Neural TTS · 本地可听调配",
    voicePreset: "male_youth_preview",
    title: "男声 B · 青涩陪伴",
    badge: "失败对照",
    role: "已判定不适合正式使用：虽然是年轻男声，但真人感和语义弹性不足。保留给对比，不再推荐选择。",
    localVoice: "zh-CN-YunxiaNeural",
    localRate: 0.96,
    localFile: `${audioDirName}/edge_neural_male_youth_preview_today_ready.mp3`,
    sampleText: "嗯，我看了一下。今天状态还不错。上午可以先推重要的事，别一下子排太满就好。",
    selectable: false,
  },
  {
    id: "local_edge_confidante_sister_preview",
    provider: "edge_neural",
    providerLabel: "Edge Neural TTS · 本地可听调配",
    voicePreset: "confidante_sister_preview",
    title: "女声 · 知心大姐姐",
    badge: "知心感",
    role: "成熟、温柔、可信，像知心姐姐慢慢解释身体状态；不做客服播报。",
    localVoice: "zh-CN-XiaoxiaoNeural",
    localRate: 0.84,
    localFile: `${audioDirName}/edge_neural_confidante_sister_preview_today_ready.mp3`,
    sampleText: "今天状态是稳的。你可以把重要的事放在上午慢慢推进，晚上记得给自己留一点恢复时间。",
  },
];

async function generateLocalSelectionSamples(outputDir, { providers, force, dryRun, postProcess }) {
  const samples = [];
  for (const option of voiceSelectionOptions) {
    const profile = providers.find((candidate) => candidate.id === option.provider);
    const voice = profile?.voicePresets.find((candidate) => candidate.presetId === option.voicePreset);
    const base = {
      ...option,
      sampleFile: null,
      sampleModel: profile?.defaultModel || "",
      sampleStatus: "pending_real_audio",
      sampleSource: "provider_required",
      reason: "等待真实模型 MP3。请配置 provider key 和 voiceId 后运行 pnpm tts:bakeoff。",
    };

    if (!profile) {
      samples.push({
        ...base,
        reason: `本次未运行 ${option.providerLabel}。如需生成，请使用 --provider ${option.provider}。`,
      });
      continue;
    }
    if (dryRun) {
      samples.push({ ...base, sampleStatus: "skipped", reason: "dry-run" });
      continue;
    }

    if (option.localFile) {
      const localPath = path.join(outputDir, option.localFile);
      if (existsSync(localPath)) {
        samples.push({
          ...base,
          sampleFile: option.localFile,
          sampleStatus: "generated",
          sampleSource: "local_audible_preview",
          reason: "cached local preview",
        });
        continue;
      }
    }

    const missing = missingEnv(profile.enabledWhen);
    if (missing.length > 0) {
      samples.push({ ...base, sampleStatus: "skipped", reason: `missing env: ${missing.join(", ")}` });
      continue;
    }
    if (!voice?.voiceId) {
      samples.push({ ...base, sampleStatus: "skipped", reason: `${profile.id} voice id is not configured` });
      continue;
    }

    const relativeFile = `${audioDirName}/selection_${sanitize(option.id)}.mp3`;
    const filePath = path.join(outputDir, relativeFile);
    if (existsSync(filePath) && !force) {
      samples.push({
        ...base,
        sampleFile: relativeFile,
        sampleStatus: "generated",
        sampleSource: "provider_audio",
        reason: "cached",
      });
      continue;
    }

    try {
      const directed = directScript({
        profile,
        voice,
        text: { id: option.id, category: "Voice selector", text: option.sampleText },
        forcedVariant: voice.directorVariant,
      });
      const audio = await synthesize({ profile, voice, text: directed.text, director: directed });
      await writeFile(filePath, audio);
      const processing = await postProcessAudio(filePath, postProcess);
      samples.push({
        ...base,
        sampleFile: relativeFile,
        sampleStatus: "generated",
        sampleSource: "provider_audio",
        directedText: directed.text,
        rawScript: directed.rawScript,
        directorVariant: directed.variant,
        directorTags: directed.tags,
        postProcess: processing,
        bytes: audio.length,
        reason: null,
      });
    } catch (error) {
      samples.push({
        ...base,
        sampleStatus: "failed",
        reason: error instanceof Error ? error.message : String(error),
      });
    }
  }
  return samples;
}

async function maybeLoadEnvFile() {
  const envPath = path.join(appRoot, ".env.tts-bakeoff");
  if (!existsSync(envPath)) return;
  const raw = await readFile(envPath, "utf8");
  for (const line of raw.split(/\r?\n/)) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#") || !trimmed.includes("=")) continue;
    const index = trimmed.indexOf("=");
    const key = trimmed.slice(0, index).trim();
    const value = trimmed.slice(index + 1).trim().replace(/^['"]|['"]$/g, "");
    if (key && process.env[key] === undefined) process.env[key] = value;
  }
}

function buildScorecard({ providers, texts, entries, generatedAt, voiceCandidates }) {
  const providerRows = providers
    .map((provider) => {
      const providerEntries = entries.filter((entry) => entry.provider === provider.id);
      const generated = providerEntries.filter((entry) => entry.status === "generated").length;
      const skipped = providerEntries.filter((entry) => entry.status === "skipped").length;
      const failed = providerEntries.filter((entry) => entry.status === "failed").length;
      return `| ${provider.label} | ${generated} | ${skipped} | ${failed} | ${provider.docs} |`;
    })
    .join("\n");

  const sampleRows = texts
    .map((text) => `| ${text.id} | ${text.category} | ${text.text} |  |  |  |  |  |`)
    .join("\n");

  const sourceRows = voiceCandidates
    .map(
      (candidate) =>
        `| ${candidate.title} | ${candidate.providerLabel} | ${candidate.targetRole} | ${candidate.licenseStatus} | ${candidate.voiceIdEnv} | ${candidate.searchQuery} |  | |`,
    )
    .join("\n");

  return `# VIVI TTS Bakeoff Scorecard

Generated: ${generatedAt}

## Run Summary

| Provider | Generated | Skipped | Failed | Docs |
| --- | ---: | ---: | ---: | --- |
${providerRows}

## Listening Score

Score each provider voice from 1-5 after listening to the generated MP3 files.

| Provider | Voice | Naturalness | Chinese Comfort | Persona Fit | Emotion Control | Mechanical Feeling | Latency | Notes |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| ElevenLabs v3 | NOIR Vessel 参考声线 |  |  |  |  |  |  |  |
| ElevenLabs v3 | 男声 A · NOIR 低冷旁白 |  |  |  |  |  |  |  |
| ElevenLabs v3 | 男声 B · 青涩陪伴 |  |  |  |  |  |  |  |
| ElevenLabs v3 | 女声 · 知心大姐姐 |  |  |  |  |  |  |  |
| ElevenLabs v3 | 小云朵 · 聪明软萌 |  |  |  |  |  |  |  |
| ElevenLabs v3 | 小云朵 · 安抚恢复 |  |  |  |  |  |  |  |
| MiniMax Speech | 软萌小云朵 |  |  |  |  |  |  |  |
| MiniMax Speech | 男声 A · NOIR 低冷旁白 |  |  |  |  |  |  |  |
| MiniMax Speech | 男声 B · 青涩陪伴 |  |  |  |  |  |  |  |
| MiniMax Speech | 女声 · 知心大姐姐 |  |  |  |  |  |  |  |
| MiniMax Speech | 温柔姐姐 |  |  |  |  |  |  |  |
| DashScope / CosyVoice | 软萌小云朵 |  |  |  |  |  |  |  |
| DashScope / CosyVoice | 温柔姐姐 |  |  |  |  |  |  |  |
| Azure Neural TTS | 温柔姐姐 |  |  |  |  |  |  |  |
| Azure Neural TTS | 冷静管家 |  |  |  |  |  |  |  |

## Script Coverage

| Text ID | Category | Text | MiniMax | CosyVoice | Azure | OpenAI | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
${sampleRows}

## Public Voice Source Candidates

| Candidate | Source | Role | License Status | Env Var | Search Query | Score | Notes |
| --- | --- | --- | --- | --- | --- | ---: | --- |
${sourceRows}

## Decision Rule

- If the authorized ElevenLabs voice ID is available and scores 4/5+ for the target scene, use it for cinematic/showcase voice.
- If ElevenLabs lacks an authorized voice ID, mark it as "similar style only" and do not promise 1:1.
- Naturalness must be at least 4/5.
- Mechanical feeling must be no more than 2/5.
- Cloud persona fit must be at least 4/5.
- Chinese segmentation, numbers, cycle/sleep/recovery terms must not be obviously wrong.
- If MiniMax is clearly more natural, choose MiniMax for V1.
- If CosyVoice is close and has better cost/stability, choose CosyVoice for V1.
- Edge is only a no-key demo fallback and should not be selected as final production voice.
`;
}

function escapeHtml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

function sourceStatusLabel(status) {
  if (status === "usable") return "可直接选择";
  if (status === "usable_with_provider_terms") return "按平台条款可用";
  if (status === "needs_voice_id") return "待补 voiceId";
  if (status === "needs_generated_voice_review") return "待生成并复核";
  if (status === "needs_voice_id_and_license_review") return "待授权复核";
  if (status === "needs_api_key_and_review") return "待 Key 与复核";
  return status || "待确认";
}

function buildSourceCatalogSection({ candidates }) {
  const sourceTabs = [
    ["all", "全部来源"],
    ["noir_low_male", "NOIR 男低音"],
    ["young_mid_male", "青涩男中音"],
    ["confidante_sister", "知心姐姐"],
    ["stable_fallback", "稳定兜底"],
  ]
    .map(([id, label]) => `<button class="source-tab${id === "all" ? " active" : ""}" data-source-target="${escapeHtml(id)}">${escapeHtml(label)}</button>`)
    .join("");

  const sourceCards = candidates
    .map((candidate) => {
      const hasAudio = Boolean(candidate.sampleAudio);
      const usable = candidate.licenseStatus === "usable" || candidate.licenseStatus === "usable_with_provider_terms";
      const chooseDisabled = hasAudio && usable ? "" : " disabled";
      const secondaryDocs = candidate.secondaryDocs
        ? `<a href="${escapeHtml(candidate.secondaryDocs)}" target="_blank" rel="noreferrer">备用文档</a>`
        : "";
      const sample = hasAudio
        ? `<audio controls preload="metadata" src="./${escapeHtml(candidate.sampleAudio)}"></audio>`
        : `<div class="source-missing">待生成真实样音。先在平台里按搜索词找声线，确认授权后把 voiceId 填到 <code>${escapeHtml(candidate.voiceIdEnv)}</code>。</div>`;
      return `<article class="source-card" data-source-role="${escapeHtml(candidate.targetRole)}" data-source-provider="${escapeHtml(candidate.provider)}">
        <div class="source-head">
          <span>${escapeHtml(candidate.providerLabel)}</span>
          <strong>${escapeHtml(sourceStatusLabel(candidate.licenseStatus))}</strong>
        </div>
        <h3>${escapeHtml(candidate.title)}</h3>
        <p class="source-persona">${escapeHtml(candidate.persona)}</p>
        <div class="source-meta">
          <span>${escapeHtml(candidate.sourceType)}</span>
          <span>${escapeHtml(candidate.targetRole)}</span>
          <span>${escapeHtml(candidate.recommendation)}</span>
        </div>
        <div class="source-query"><b>搜索词</b><span>${escapeHtml(candidate.searchQuery)}</span></div>
        ${sample}
        <div class="source-actions">
          <a href="${escapeHtml(candidate.docs)}" target="_blank" rel="noreferrer">平台文档</a>
          ${secondaryDocs}
          <button data-choose-source="${escapeHtml(candidate.id)}" data-choose-name="${escapeHtml(candidate.title)}" data-choose-provider="${escapeHtml(candidate.provider)}" data-choose-audio="${escapeHtml(candidate.sampleAudio || "")}"${chooseDisabled}>${hasAudio && usable ? "选择这个公开声线" : "待授权/样音"}</button>
        </div>
      </article>`;
    })
    .join("");

  return `<section class="source-catalog">
      <div class="source-intro">
        <div>
          <div class="eyebrow">PUBLIC VOICE SOURCES</div>
          <h2>公开声线来源库</h2>
          <p>这里不是系统 TTS，也不是声音克隆。每张卡都是一个可继续搜索、补 voiceId、生成真实 MP3 的公开来源候选；只有授权状态可用且已有真实样音时才允许选择。</p>
        </div>
        <a class="source-doc" href="./docs/voice-source-catalog.md" target="_blank" rel="noreferrer">查看声线来源文档</a>
      </div>
      <div class="source-tabs">${sourceTabs}</div>
      <div class="source-grid">${sourceCards}</div>
    </section>`;
}

function buildHtmlReport({ providers, texts, entries, generatedAt, selectionSamples, voiceSources, voiceCandidates }) {
  const summary = entries.reduce(
    (acc, entry) => {
      acc[entry.status] = (acc[entry.status] || 0) + 1;
      return acc;
    },
    {},
  );
  const providerFilters = providers
    .map((provider) => `<button class="filter" data-filter-provider="${escapeHtml(provider.id)}">${escapeHtml(provider.label)}</button>`)
    .join("");
  const textFilters = texts
    .map((text) => `<button class="filter" data-filter-text="${escapeHtml(text.id)}">${escapeHtml(text.category)}</button>`)
    .join("");
  const cards = entries
    .map((entry) => {
      const canPlay = entry.status === "generated";
      const statusLabel = entry.status === "generated" ? "已生成" : entry.status === "failed" ? "失败" : "未生成";
      const audio = canPlay
        ? `<audio controls preload="metadata" src="./${escapeHtml(entry.file)}"></audio>`
        : `<div class="missing">${escapeHtml(entry.reason || "等待生成音频")}</div>`;
      return `<article class="card ${escapeHtml(entry.status)}" data-provider="${escapeHtml(entry.provider)}" data-text="${escapeHtml(entry.textId)}">
        <div class="card-head">
          <div>
            <div class="provider">${escapeHtml(entry.providerLabel)}</div>
            <div class="voice">${escapeHtml(entry.voiceName)} · ${escapeHtml(entry.model)}</div>
          </div>
          <span class="status">${statusLabel}</span>
        </div>
        <div class="meta">
          <span>${escapeHtml(entry.category)}</span>
          <span>${escapeHtml(entry.textId)}</span>
          <span>${escapeHtml(entry.style)}</span>
          <span>导演 ${escapeHtml(entry.directorVariant || "clean")}</span>
          <span>speed ${escapeHtml(entry.speed)}</span>
          <span>pitch ${escapeHtml(entry.pitch)}</span>
        </div>
        ${
          entry.directorTags?.length
            ? `<div class="meta">${entry.directorTags.map((tag) => `<span>[${escapeHtml(tag)}]</span>`).join("")}</div>`
            : ""
        }
        <p class="text">${escapeHtml(entry.text)}</p>
        ${audio}
        <div class="actions">
          <a href="${escapeHtml(entry.docs)}" target="_blank" rel="noreferrer">Provider 文档</a>
        </div>
      </article>`;
    })
    .join("");

  const providerRecommendationCards = providers
    .map((provider) => {
      const tone =
        provider.decisionRole === "cinematic_reference"
          ? "rec-cinema"
          : provider.decisionRole === "best_voice"
          ? "rec-best"
          : provider.decisionRole === "stable_fallback"
            ? "rec-stable"
            : "rec-base";
      const label =
        provider.decisionRole === "cinematic_reference"
          ? "视频质感"
          : provider.decisionRole === "best_voice"
          ? "最好听"
          : provider.decisionRole === "stable_fallback"
            ? "最稳兜底"
            : provider.decisionRole === "baseline"
              ? "稳定 baseline"
              : "备选";
      return `<div class="rec-card ${tone}">
        <div class="rec-label">${label}</div>
        <div class="rec-title">${escapeHtml(provider.label)}</div>
        <p>${escapeHtml(provider.recommendation || "")}</p>
      </div>`;
    })
    .join("");

  const selectionCards = selectionSamples
    .map((sample) => {
      const providerEntry = entries.find(
        (entry) =>
          entry.provider === sample.provider &&
          entry.voicePreset === sample.voicePreset &&
          entry.textId === "today_ready" &&
          entry.status === "generated",
      );
      const file = sample.sampleFile || providerEntry?.file;
      const model = sample.sampleModel || providerEntry?.model || "";
      const source = sample.sampleFile || providerEntry ? "真实模型样音" : "待生成真实模型音频";
      const audio = file
        ? `<audio controls preload="metadata" src="./${escapeHtml(file)}"></audio>`
        : `<div class="missing">${escapeHtml(sample.reason || "等待生成真实模型音频")}</div>`;
      const disabled = file && sample.selectable !== false ? "" : " disabled";
      const chooseLabel = !file ? "先生成真实样音" : sample.selectable === false ? "仅作对照，不推荐选择" : "选择这个声音";
      return `<article class="select-card" data-select-card="${escapeHtml(sample.id)}">
        <div class="select-top">
          <span class="select-badge">${escapeHtml(sample.badge)}</span>
          <span class="select-source">${escapeHtml(source)}</span>
        </div>
        <h3>${escapeHtml(sample.title)}</h3>
        <p class="select-role">${escapeHtml(sample.role)}</p>
        <div class="select-provider">${escapeHtml(sample.providerLabel)}</div>
        <p class="select-script">${escapeHtml(sample.sampleText)}</p>
        ${
          sample.directorTags?.length
            ? `<div class="select-tags">${sample.directorTags.map((tag) => `<span>[${escapeHtml(tag)}]</span>`).join("")}</div>`
            : ""
        }
        ${audio}
        <button class="choose-btn" data-choose-voice="${escapeHtml(sample.id)}" data-choose-name="${escapeHtml(sample.title)}" data-choose-provider="${escapeHtml(sample.provider)}" data-choose-model="${escapeHtml(model)}" data-choose-audio="${escapeHtml(file || "")}" data-choose-preset="${escapeHtml(sample.voicePreset)}"${disabled}>${chooseLabel}</button>
      </article>`;
    })
    .join("");

  return `<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>VIVI TTS 试听评测</title>
  <style>
    :root{color-scheme:dark;--bg:#0d1113;--panel:rgba(255,255,255,.075);--line:rgba(255,255,255,.12);--text:#f4f1e9;--muted:rgba(244,241,233,.62);--good:#89e6cc;--bad:#ffb199;--warn:#ffd26d}
    *{box-sizing:border-box}body{margin:0;background:radial-gradient(circle at 22% 8%,rgba(129,199,196,.22),transparent 34%),radial-gradient(circle at 80% 12%,rgba(226,158,188,.16),transparent 32%),linear-gradient(180deg,#162126,#090c0e);color:var(--text);font-family:PingFang SC,Noto Sans SC,system-ui,sans-serif;line-height:1.5}
    .shell{max-width:1180px;margin:0 auto;padding:40px 24px 72px}.hero{display:grid;grid-template-columns:1.25fr .75fr;gap:24px;align-items:end;margin-bottom:24px}.eyebrow{color:var(--good);font-size:13px;font-weight:800;letter-spacing:.08em}.title{font-family:Songti SC,Noto Serif SC,serif;font-size:44px;line-height:1.12;margin:10px 0 12px}.desc{max-width:760px;color:var(--muted);font-size:16px}.stats{display:grid;grid-template-columns:repeat(3,1fr);gap:10px}.stat{border:1px solid var(--line);background:var(--panel);border-radius:20px;padding:16px;backdrop-filter:blur(18px)}.stat strong{display:block;font-size:28px}.stat span{font-size:12px;color:var(--muted)}
    .recommend{display:grid;grid-template-columns:1fr 1.4fr;gap:14px;margin:0 0 22px}.decision{border:1px solid rgba(137,230,204,.22);background:linear-gradient(145deg,rgba(137,230,204,.14),rgba(255,255,255,.05));border-radius:24px;padding:20px;box-shadow:0 24px 56px rgba(0,0,0,.22)}.decision h2{font-family:Songti SC,Noto Serif SC,serif;font-size:26px;margin:0 0 10px}.decision p{color:rgba(244,241,233,.74);margin:0;font-size:14px}.rec-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:10px}.rec-card{border:1px solid var(--line);background:rgba(255,255,255,.065);border-radius:20px;padding:15px}.rec-card p{margin:8px 0 0;color:var(--muted);font-size:13px}.rec-label{display:inline-flex;border-radius:999px;padding:4px 8px;margin-bottom:9px;background:rgba(255,255,255,.10);font-size:11px;font-weight:900}.rec-cinema{border-color:rgba(194,210,255,.34)}.rec-cinema .rec-label{background:rgba(194,210,255,.18);color:#cdd8ff}.rec-best{border-color:rgba(137,230,204,.34)}.rec-best .rec-label{background:rgba(137,230,204,.18);color:var(--good)}.rec-stable{border-color:rgba(255,210,109,.30)}.rec-stable .rec-label{background:rgba(255,210,109,.16);color:var(--warn)}.rec-title{font-size:16px;font-weight:950}.notice{margin:0 0 20px;border:1px solid rgba(255,210,109,.22);background:rgba(255,210,109,.075);border-radius:20px;padding:14px 16px;color:rgba(255,232,169,.88);font-size:14px}
    .chooser{margin:0 0 24px;border:1px solid rgba(137,230,204,.20);background:linear-gradient(145deg,rgba(255,255,255,.10),rgba(255,255,255,.035));border-radius:28px;padding:20px;box-shadow:0 26px 70px rgba(0,0,0,.28);backdrop-filter:blur(24px)}.chooser-head{display:flex;align-items:end;justify-content:space-between;gap:16px;margin-bottom:14px}.chooser h2{font-family:Songti SC,Noto Serif SC,serif;font-size:30px;margin:0}.chosen{border:1px solid rgba(137,230,204,.26);background:rgba(137,230,204,.10);border-radius:999px;padding:9px 13px;color:var(--good);font-size:13px;font-weight:900}.select-grid{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:12px}.select-card{position:relative;border:1px solid rgba(255,255,255,.11);background:rgba(255,255,255,.055);border-radius:22px;padding:15px;min-height:382px}.select-card.selected{border-color:rgba(137,230,204,.78);box-shadow:0 0 0 1px rgba(137,230,204,.35),0 20px 44px rgba(0,0,0,.22)}.select-top{display:flex;justify-content:space-between;gap:8px;align-items:center}.select-badge,.select-source{border-radius:999px;padding:4px 8px;font-size:11px;font-weight:900;background:rgba(255,255,255,.10)}.select-badge{color:var(--good);background:rgba(137,230,204,.14)}.select-source{color:rgba(244,241,233,.62)}.select-card h3{font-size:20px;margin:14px 0 4px}.select-role,.select-provider,.select-script{font-size:13px;color:var(--muted);margin:0}.select-provider{margin-top:9px;color:rgba(244,241,233,.86);font-weight:850}.select-script{min-height:82px;margin:12px 0 10px;color:rgba(244,241,233,.72)}.select-tags{display:flex;flex-wrap:wrap;gap:5px;min-height:22px;margin-bottom:10px}.select-tags span{border-radius:999px;background:rgba(194,210,255,.11);color:#cdd8ff;padding:3px 7px;font-size:10px;font-weight:850}.choose-btn{width:100%;height:40px;margin-top:12px;border:0;border-radius:999px;background:rgba(255,255,255,.12);color:var(--text);font-weight:900}.select-card.selected .choose-btn{background:rgba(137,230,204,.92);color:#0d1515}.choose-btn:disabled{cursor:not-allowed;opacity:.48;background:rgba(255,255,255,.07);color:rgba(244,241,233,.52)}
    .toolbar{position:sticky;top:0;z-index:3;margin:0 -8px 20px;padding:12px 8px;background:linear-gradient(180deg,rgba(13,17,19,.94),rgba(13,17,19,.72));backdrop-filter:blur(20px);border-bottom:1px solid rgba(255,255,255,.06)}.filters{display:flex;gap:8px;overflow:auto;padding-bottom:4px}.filter{border:1px solid var(--line);background:rgba(255,255,255,.06);color:var(--text);height:34px;padding:0 13px;border-radius:999px;white-space:nowrap;font-weight:750}.filter.active{background:rgba(255,255,255,.88);color:#101416}
    .grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:14px}.card{border:1px solid var(--line);background:linear-gradient(145deg,rgba(255,255,255,.10),rgba(255,255,255,.035));border-radius:24px;padding:18px;box-shadow:0 22px 50px rgba(0,0,0,.22);backdrop-filter:blur(22px)}.card.generated{border-color:rgba(137,230,204,.34)}.card.failed{border-color:rgba(255,177,153,.34)}.card-head{display:flex;justify-content:space-between;gap:16px}.provider{font-size:17px;font-weight:900}.voice{font-size:13px;color:var(--muted);margin-top:3px}.status{align-self:start;border-radius:999px;padding:5px 10px;background:rgba(255,255,255,.09);font-size:12px;font-weight:850}.generated .status{background:rgba(137,230,204,.18);color:var(--good)}.failed .status{background:rgba(255,177,153,.16);color:var(--bad)}
    .meta{display:flex;gap:6px;flex-wrap:wrap;margin:14px 0}.meta span{border:1px solid rgba(255,255,255,.08);background:rgba(255,255,255,.045);border-radius:999px;padding:4px 8px;color:var(--muted);font-size:11px}.text{font-size:15px;color:rgba(244,241,233,.86);min-height:68px}.missing{border:1px dashed rgba(255,255,255,.16);border-radius:16px;padding:14px;color:rgba(255,210,109,.86);background:rgba(255,210,109,.055);font-size:13px}audio{width:100%;height:42px}.actions{display:flex;justify-content:flex-end;align-items:center;margin-top:12px}.actions a{border:0;border-radius:999px;background:rgba(255,255,255,.10);padding:9px 12px;text-decoration:none;font-size:12px;font-weight:850;color:var(--good)}
    .source-catalog{margin:0 0 24px;border:1px solid rgba(194,210,255,.18);background:linear-gradient(145deg,rgba(194,210,255,.08),rgba(255,255,255,.035));border-radius:28px;padding:20px;box-shadow:0 24px 58px rgba(0,0,0,.22);backdrop-filter:blur(22px)}.source-intro{display:flex;align-items:end;justify-content:space-between;gap:18px;margin-bottom:14px}.source-intro h2{font-family:Songti SC,Noto Serif SC,serif;font-size:30px;line-height:1.16;margin:6px 0 6px}.source-intro p{max-width:760px;margin:0;color:var(--muted);font-size:14px}.source-doc{flex:0 0 auto;border-radius:999px;padding:10px 13px;background:rgba(255,255,255,.10);color:var(--good);font-size:12px;font-weight:900;text-decoration:none}.source-tabs{display:flex;gap:8px;overflow:auto;margin:0 -2px 14px;padding:0 2px 2px}.source-tab{height:32px;border:1px solid var(--line);background:rgba(255,255,255,.055);color:var(--text);border-radius:999px;padding:0 12px;white-space:nowrap;font-weight:850}.source-tab.active{background:rgba(194,210,255,.18);color:#d7e1ff}.source-grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:12px}.source-card{border:1px solid rgba(255,255,255,.10);background:rgba(255,255,255,.052);border-radius:22px;padding:15px;min-height:330px}.source-card.hidden{display:none}.source-head{display:flex;align-items:center;justify-content:space-between;gap:8px}.source-head span,.source-head strong{border-radius:999px;padding:4px 8px;background:rgba(255,255,255,.09);font-size:10px;font-weight:900;color:rgba(244,241,233,.64)}.source-head strong{color:var(--warn);background:rgba(255,210,109,.12)}.source-card h3{font-size:18px;line-height:1.25;margin:14px 0 8px}.source-persona{min-height:66px;margin:0;color:rgba(244,241,233,.72);font-size:13px}.source-meta{display:flex;flex-wrap:wrap;gap:5px;margin:12px 0}.source-meta span{border-radius:999px;background:rgba(137,230,204,.09);color:rgba(137,230,204,.86);padding:3px 7px;font-size:10px;font-weight:850}.source-query{border:1px solid rgba(255,255,255,.08);background:rgba(255,255,255,.04);border-radius:15px;padding:10px 11px;margin:10px 0;color:rgba(244,241,233,.68);font-size:12px}.source-query b{display:block;color:rgba(244,241,233,.9);font-size:11px;margin-bottom:4px}.source-query span{word-break:break-word}.source-missing{border:1px dashed rgba(255,255,255,.14);background:rgba(255,210,109,.055);border-radius:15px;padding:11px;color:rgba(255,210,109,.86);font-size:12px}.source-missing code{font-family:ui-monospace,SFMono-Regular,Menlo,monospace;color:#ffe8a9}.source-actions{display:flex;flex-wrap:wrap;gap:8px;margin-top:12px}.source-actions a,.source-actions button{border:0;border-radius:999px;background:rgba(255,255,255,.09);color:var(--good);padding:8px 10px;text-decoration:none;font-size:11px;font-weight:900}.source-actions button{color:var(--text)}.source-actions button:disabled{opacity:.48;cursor:not-allowed;color:rgba(244,241,233,.54)}
    .empty{display:none;margin-top:24px;border:1px solid var(--line);border-radius:22px;padding:24px;background:var(--panel);color:var(--muted)}@media(max-width:980px){.select-grid{grid-template-columns:repeat(2,minmax(0,1fr))}.source-grid{grid-template-columns:repeat(2,minmax(0,1fr))}}@media(max-width:760px){.hero,.recommend{grid-template-columns:1fr}.rec-grid,.grid,.select-grid,.source-grid{grid-template-columns:1fr}.chooser-head,.source-intro{display:block}.chosen{display:inline-flex;margin-top:12px}.source-doc{display:inline-flex;margin-top:12px}.title{font-size:34px}.shell{padding:28px 14px 48px}}
  </style>
</head>
<body>
  <main class="shell">
    <section class="hero">
      <div>
        <div class="eyebrow">VIVI VOICE BAKEOFF</div>
        <h1 class="title">声优式真实样音评测</h1>
        <p class="desc">这页不再用系统 TTS 冒充声线。先用 Codex 语气导演改写台词，再调用真实 TTS 生成 MP3，并做轻后期处理；顶部优先比较视频 NOIR 参考、小云朵主声线、中文恢复声线和稳定兜底。</p>
      </div>
      <div class="stats">
        <div class="stat"><strong>${summary.generated || 0}</strong><span>已生成</span></div>
        <div class="stat"><strong>${summary.skipped || 0}</strong><span>未生成</span></div>
        <div class="stat"><strong>${summary.failed || 0}</strong><span>失败</span></div>
      </div>
    </section>
    <section class="recommend">
      <div class="decision">
        <h2>我的建议：双轨选声线</h2>
        <p>视频同款质感优先跑 ElevenLabs v3，但必须有合法 voice_id；VIVI 中文主声线同时跑 MiniMax/CosyVoice。Edge 只保留为无 Key 流程兜底，不作为最终声线。</p>
      </div>
      <div class="rec-grid">${providerRecommendationCards}</div>
    </section>
    <div class="notice">声优调音方向：图像/剧照先判断人设和情绪，再改成短句、停顿和语气词。小云朵要聪明、轻软、贴近，不幼稚；NOIR 要冷白、克制、电影感。没有真实 Key 或 voice_id 时，卡片会禁用，不用 Edge 冒充。</div>
    ${buildSourceCatalogSection({ sources: voiceSources, candidates: voiceCandidates })}
    <section class="chooser">
      <div class="chooser-head">
        <div>
          <div class="eyebrow">VOICE SELECTOR</div>
        <h2>先听，再选一个声音</h2>
        </div>
        <div class="chosen" id="chosenVoice">当前未选择</div>
      </div>
      <div class="select-grid">${selectionCards}</div>
    </section>
    <section class="toolbar">
      <div class="filters">
        <button class="filter active" data-filter-provider="all">全部模型</button>
        ${providerFilters}
      </div>
      <div class="filters">
        <button class="filter active" data-filter-text="all">全部文案</button>
        ${textFilters}
      </div>
    </section>
    <section class="grid" id="grid">${cards}</section>
    <section class="empty" id="empty">当前筛选没有结果。</section>
  </main>
  <script>
    var activeProvider='all',activeText='all';
    var selectedVoice=localStorage.getItem('viviSelectedVoice')||'';
    function applySelection(){
      document.querySelectorAll('[data-select-card]').forEach(function(card){
        card.classList.toggle('selected',card.dataset.selectCard===selectedVoice);
      });
      var chosen=document.getElementById('chosenVoice');
      var card=document.querySelector('[data-select-card="'+selectedVoice+'"]');
      chosen.textContent=card?'已选择：'+card.querySelector('h3').textContent:'当前未选择';
    }
    function applyFilters(){
      var visible=0;
      document.querySelectorAll('.card').forEach(function(card){
        var ok=(activeProvider==='all'||card.dataset.provider===activeProvider)&&(activeText==='all'||card.dataset.text===activeText);
        card.style.display=ok?'block':'none';
        if(ok)visible++;
      });
      document.getElementById('empty').style.display=visible?'none':'block';
    }
    document.addEventListener('click',function(e){
      var provider=e.target.closest('[data-filter-provider]');
      if(provider){activeProvider=provider.dataset.filterProvider;document.querySelectorAll('[data-filter-provider]').forEach(function(n){n.classList.toggle('active',n===provider)});applyFilters();return}
      var text=e.target.closest('[data-filter-text]');
      if(text){activeText=text.dataset.filterText;document.querySelectorAll('[data-filter-text]').forEach(function(n){n.classList.toggle('active',n===text)});applyFilters();return}
      var choose=e.target.closest('[data-choose-voice]');
      if(choose && !choose.disabled){selectedVoice=choose.dataset.chooseVoice;localStorage.setItem('viviSelectedVoice',selectedVoice);localStorage.setItem('viviSelectedVoicePayload',JSON.stringify({id:selectedVoice,name:choose.dataset.chooseName,provider:choose.dataset.chooseProvider,model:choose.dataset.chooseModel,audioFile:choose.dataset.chooseAudio,preset:choose.dataset.choosePreset}));localStorage.setItem('viviVoiceSettings',JSON.stringify({voiceId:choose.dataset.chooseVoice,provider:choose.dataset.chooseProvider,model:choose.dataset.chooseModel,audioFile:choose.dataset.chooseAudio,preset:choose.dataset.choosePreset}));applySelection();return}
      var sourceTab=e.target.closest('[data-source-target]');
      if(sourceTab){var target=sourceTab.dataset.sourceTarget;document.querySelectorAll('[data-source-target]').forEach(function(n){n.classList.toggle('active',n===sourceTab)});document.querySelectorAll('[data-source-role]').forEach(function(card){card.classList.toggle('hidden',target!=='all'&&card.dataset.sourceRole!==target)});return}
      var sourceChoose=e.target.closest('[data-choose-source]');
      if(sourceChoose && !sourceChoose.disabled){selectedVoice=sourceChoose.dataset.chooseSource;localStorage.setItem('viviSelectedVoice',selectedVoice);localStorage.setItem('viviSelectedVoicePayload',JSON.stringify({id:selectedVoice,name:sourceChoose.dataset.chooseName,provider:sourceChoose.dataset.chooseProvider,audioFile:sourceChoose.dataset.chooseAudio,sourceType:'public_voice_source'}));localStorage.setItem('viviVoiceSettings',JSON.stringify({voiceId:sourceChoose.dataset.chooseSource,provider:sourceChoose.dataset.chooseProvider,audioFile:sourceChoose.dataset.chooseAudio,sourceType:'public_voice_source'}));applySelection();return}
    });
    applySelection();
  </script>
</body>
</html>`;
}

async function main() {
  await maybeLoadEnvFile();
  const args = parseArgs(process.argv.slice(2));
  await mkdir(args.outputDir, { recursive: true });
  await mkdir(path.join(args.outputDir, audioDirName), { recursive: true });
  await mkdir(path.join(args.outputDir, "docs"), { recursive: true });

  const selectedProviders = providerProfiles.filter((profile) =>
    args.providers ? args.providers.includes(profile.id) : profile.id !== "edge_neural",
  );
  let selectedTexts = bakeoffTexts.filter((text) =>
    args.textIds ? args.textIds.includes(text.id) : defaultBakeoffTextIds.includes(text.id),
  );
  if (Number.isFinite(args.limit) && args.limit > 0) selectedTexts = selectedTexts.slice(0, args.limit);

  const generatedAt = new Date().toISOString();
  const entries = [];

  for (const profile of selectedProviders) {
    const missing = missingEnv(profile.enabledWhen);
    for (const voice of profile.voicePresets) {
      const missingVoice = !voice.voiceId;
      for (const text of selectedTexts) {
        const fileName = `${sanitize(profile.id)}_${sanitize(voice.presetId)}_${sanitize(text.id)}.mp3`;
        const relativeFile = `${audioDirName}/${fileName}`;
        const filePath = path.join(args.outputDir, relativeFile);
        const directed = directScript({ profile, voice, text });
        const baseEntry = {
          provider: profile.id,
          providerLabel: profile.label,
          model: profile.defaultModel,
          voicePreset: voice.presetId,
          voiceName: voice.displayName,
          voiceId: voice.voiceId || null,
          style: voice.style,
          speed: voice.speed,
          pitch: voice.pitch,
          textId: text.id,
          category: text.category,
          sourceText: text.text,
          text: directed.text,
          rawScript: directed.rawScript,
          directorVariant: directed.variant,
          directorTags: directed.tags,
          directorInstructions: directed.instructions,
          tagsEnabled: directed.tagsEnabled,
          file: relativeFile,
          docs: profile.docs,
          costEstimate: estimateCost({ text: directed.text }),
          generatedAt,
        };

        if (args.dryRun) {
          entries.push({ ...baseEntry, status: "skipped", reason: "dry-run" });
          continue;
        }
        if (missing.length > 0) {
          entries.push({ ...baseEntry, status: "skipped", reason: `missing env: ${missing.join(", ")}` });
          continue;
        }
        if (missingVoice) {
          entries.push({ ...baseEntry, status: "skipped", reason: `${profile.id} voice id is not configured` });
          continue;
        }
        if (existsSync(filePath) && !args.force) {
          entries.push({ ...baseEntry, status: "generated", reason: "cached", bytes: null });
          continue;
        }

        const startedAt = Date.now();
        try {
          const audio = await synthesize({ profile, voice, text: directed.text, director: directed });
          await writeFile(filePath, audio);
          const processing = await postProcessAudio(filePath, args.postProcess);
          entries.push({
            ...baseEntry,
            status: "generated",
            bytes: processing.applied ? processing.bytes : audio.length,
            rawBytes: audio.length,
            postProcess: processing,
            latencyMs: Date.now() - startedAt,
          });
        } catch (error) {
          entries.push({
            ...baseEntry,
            status: "failed",
            reason: error instanceof Error ? error.message : String(error),
            latencyMs: Date.now() - startedAt,
          });
        }
      }
    }
  }

  const manifest = {
    version: 1,
    generatedAt,
    outputDir: args.outputDir,
    texts: selectedTexts,
    providers: selectedProviders.map((provider) => ({
      id: provider.id,
      label: provider.label,
      model: provider.defaultModel,
      docs: provider.docs,
      enabledWhen: provider.enabledWhen,
      optional: Boolean(provider.optional),
        voicePresets: provider.voicePresets.map((voice) => ({
          presetId: voice.presetId,
          displayName: voice.displayName,
          voiceId: voice.voiceId || null,
          speed: voice.speed,
          pitch: voice.pitch,
          style: voice.style,
          directorVariant: voice.directorVariant || null,
          actingProfile: voice.actingProfile || null,
          stability: voice.stability ?? null,
          similarityBoost: voice.similarityBoost ?? null,
          styleExaggeration: voice.styleExaggeration ?? null,
          azureStyle: voice.azureStyle || null,
          azureRole: voice.azureRole || null,
        })),
    })),
    entries,
    voiceSources: publicVoiceSources,
    voiceCandidates: publicVoiceCandidates,
  };

  await writeFile(path.join(args.outputDir, "manifest.json"), `${JSON.stringify(manifest, null, 2)}\n`);
  const selectionSamples = await generateLocalSelectionSamples(args.outputDir, {
    providers: providerProfiles,
    force: args.force,
    dryRun: args.dryRun,
    postProcess: args.postProcess,
  });
  manifest.selectionSamples = selectionSamples;
  await writeFile(path.join(args.outputDir, "manifest.json"), `${JSON.stringify(manifest, null, 2)}\n`);
  await writeFile(
    path.join(args.outputDir, "scorecard.md"),
    buildScorecard({
      providers: selectedProviders,
      texts: selectedTexts,
      entries,
      generatedAt,
      voiceCandidates: publicVoiceCandidates,
    }),
  );
  await writeFile(
    path.join(args.outputDir, "index.html"),
    buildHtmlReport({
      providers: selectedProviders,
      texts: selectedTexts,
      entries,
      generatedAt,
      selectionSamples,
      voiceSources: publicVoiceSources,
      voiceCandidates: publicVoiceCandidates,
    }),
  );
  if (existsSync(voiceSourceDocPath)) {
    await writeFile(
      path.join(args.outputDir, "docs", "voice-source-catalog.md"),
      await readFile(voiceSourceDocPath, "utf8"),
    );
  }

  const summary = entries.reduce(
    (acc, entry) => {
      acc[entry.status] = (acc[entry.status] || 0) + 1;
      return acc;
    },
    {},
  );
  console.log(`TTS bakeoff complete: ${JSON.stringify(summary)} -> ${args.outputDir}`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
