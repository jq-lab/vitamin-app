# VIVI Voice MVP Implementation Plan

## Goal

Build a demonstrable voice loop for the independent `VIVI Oura` simulator app:

- Health page voice message.
- AI assistant voice playback.
- Mock voice input.
- Voice preset selection.
- A clear MCP and backend adapter path for cloud TTS later.

This MVP does not add voice cloning, user voice upload, medical diagnosis, or frontend TTS provider keys.

## Current MVP Behavior

The current simulator still uses system TTS inside the app WebView as a temporary fallback, but this is not a voice-model evaluation path:

- `我的健康` has a health-state orb map with `需要关注` and `状态良好` signals.
- Tapping a health orb updates AI explanation text and the voice message copy.
- Tapping the voice bubble can read the current Chinese text through `speechSynthesis` only as a simulator fallback.
- If the WebView runtime does not support system TTS, playback falls back to a short Web Audio tone.
- The cloud IP switches into speaking/listening/thinking reactions during voice actions.
- The assistant screen has voice playback, mock microphone input, and a voice settings sheet.
- Voice preset speed and pitch map to `SpeechSynthesisUtterance.rate` and `.pitch` only in fallback mode; they do not create distinct model voices.
- Voice settings are stored in WebView `localStorage`.

## Voice Presets

The four first-version presets follow `Vitora_Voice_MVP_Codex_Package/04_voice_api_spec.json`:

| ID | Name | Default Speed | Default Pitch | Product Role |
| --- | --- | ---: | ---: | --- |
| `ghost_soft` | 软萌小云朵 | 0.95 | 1.08 | Daily body message |
| `sister_warm` | 温柔姐姐 | 0.92 | 1.00 | Recovery and comfort |
| `calm_keeper` | 冷静管家 | 0.90 | 0.95 | Decision support |
| `energy_friend` | 元气陪伴 | 1.05 | 1.10 | Good-state encouragement |

## Backend Contract

The App must never call provider TTS APIs directly. The production path is:

```text
App -> Backend /api/tts/generate -> TTS Provider -> audioUrl -> App playback
```

Minimum backend endpoints:

- `GET /api/voices`: returns available voices and plan access.
- `POST /api/user/voice-setting`: saves voice, persona, nickname, speed, and pitch.
- `POST /api/tts/generate`: returns `{ audioUrl, duration, cacheHit }`.

Recommended cache key:

```text
hash(text + voiceId + persona + speed + pitch + style)
```

## TTS Bakeoff Before Provider Selection

The current system TTS is only a simulator bridge and should not be treated as the final voice model. Before wiring a provider into the app, run the listening bakeoff:

```bash
pnpm tts:bakeoff
```

The tool lives in `tools/tts-bakeoff/` and writes review artifacts into `voice-bakeoff/`:

- `manifest.json`: provider, voice, text, status, output file, duration/cost placeholders.
- `scorecard.md`: listening score table and final decision criteria.
- `index.html`: direct listening and voice selection page.
- `audio/*.mp3`: generated real provider samples when provider keys and voice IDs are configured.

Provider keys must be provided through shell env vars or `.env.tts-bakeoff`. Missing providers are skipped instead of blocking the run, so the scorecard can still be prepared without secrets.

The listening page must not use browser/system TTS as a substitute for model comparison. A voice can be selected only after a real MP3 exists for that voice.

The bakeoff uses 12 fixed Chinese scripts covering daily status, sleep recovery, stress, cycle guidance, workout decisions, food cravings, and assistant replies. These scripts preserve the VIVI cloud assistant persona and are designed to expose robotic pauses, wrong Chinese segmentation, weak emotion, and poor number handling.

## Provider Recommendation

Default real provider for V1 should be a domestic Chinese TTS cloud provider, with Alibaba Cloud Model Studio / DashScope CosyVoice as the first integration target.

Reasoning:

- Better domestic network and account/payment path.
- Strong Chinese naturalness and text normalization.
- Easier to map speed, style, and Chinese assistant persona.
- Lower operational burden than self-hosting GPU TTS for MVP.

MiniMax Speech should be tested as the Chinese-quality-first candidate. DashScope / CosyVoice should be tested as the cost/stability-balanced domestic candidate. Azure Neural TTS should remain the enterprise-stability baseline. GPT-SoVITS and self-hosted CosyVoice stay as V2 cost/private-deployment options because they add model hosting, GPU, monitoring, and model-quality operations that are not needed for this MVP.

Selection rule:

- Naturalness must be at least 4/5.
- Mechanical feeling must be no more than 2/5.
- Cloud persona fit must be at least 4/5.
- Cycle, sleep, recovery, and Chinese number phrasing must not be obviously wrong.
- If MiniMax is clearly more natural, choose MiniMax for V1.
- If CosyVoice is close and has better cost/stability, choose CosyVoice for V1.

## TTS Adapter Interface

```ts
type TTSProvider = "mock" | "cosyvoice" | "minimax";

interface GenerateSpeechInput {
  text: string;
  providerVoiceId: string;
  speed?: number;
  pitch?: number;
  style?: "cute" | "warm" | "calm" | "energetic";
}

interface GenerateSpeechOutput {
  audioUrl: string;
  duration: number;
}

interface TTSAdapter {
  generateSpeech(input: GenerateSpeechInput): Promise<GenerateSpeechOutput>;
}
```

Provider adapters:

- `SystemTTSAdapter`: current simulator-only bridge through iOS/browser system TTS.
- `MockTTSAdapter`: local generated audio or bundled fixture audio fallback.
- `CosyVoiceAdapter`: first real provider adapter.
- `MiniMaxTTSAdapter`: backup premium provider adapter.
- `AzureTTSAdapter`: enterprise baseline used for bakeoff comparison.
- `OpenAITTSAdapter`: optional backup, not a first-tier Chinese persona candidate unless bakeoff quality is strong.

## MCP Tooling

MCP is only for development validation in Codex, not a production App dependency.

The planned `tts-voice MCP` should expose:

| Tool | Purpose |
| --- | --- |
| `list_voices` | Inspect configured voice profiles |
| `get_voice` | Inspect one voice profile |
| `validate_voice_access` | Check free/vip/pro access |
| `synthesize_preview` | Generate test preview audio through mock or provider adapter |
| `rewrite_persona_text` | Rewrite assistant text for a selected persona |

The MCP tool should read the same voice config used by backend tests, so voice names, tiering, and provider IDs do not drift between product and implementation.

## Acceptance Criteria

- The simulator works without any provider API key.
- Health page voice message can read Chinese text aloud and expand to text.
- Assistant voice bubble can read the latest assistant reply aloud.
- Microphone button can enter a mock listening state and fill recognized text.
- Voice settings can switch presets and adjust speed, pitch, and nickname.
- Future backend TTS can replace the mock layer without changing the health page UI contract.
