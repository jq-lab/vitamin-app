# VIVI TTS Bakeoff

This tool generates a real TTS listening pack for VIVI's cloud assistant voice.

It does not fake voice quality with browser/system TTS. It creates comparable audio samples, a `manifest.json`, and a `scorecard.md` so the team can select the production provider before wiring it into the simulator.

The v5 flow is:

```text
scene/persona -> Codex voice director script -> real TTS provider -> light post process -> listening page -> app selection
```

## Run

```bash
pnpm tts:bakeoff
```

Without provider keys, the run still creates `voice-bakeoff/index.html`, `manifest.json`, and `scorecard.md` with skipped entries. It does not create fake browser/system-TTS previews.

Useful options:

```bash
pnpm tts:bakeoff -- --provider minimax --limit 2
pnpm tts:bakeoff -- --provider elevenlabs_v3 --text today_ready,stress_attention,ai_reply_short --force
pnpm tts:bakeoff -- --provider minimax,edge_neural --text today_ready,sleep_recovery_weak,stress_attention,ai_reply_short --force
pnpm tts:bakeoff -- --provider azure --text today_ready,stress_attention --force
pnpm tts:bakeoff -- --provider elevenlabs_v3,minimax,azure --force --no-post-process
pnpm tts:bakeoff -- --dry-run
```

Default runs exclude `edge_neural` so the page does not treat no-key demo audio as a production candidate. Use `--provider edge_neural` explicitly when you only want to validate the workflow without API keys.

## Public Voice Source Catalog

The listening page also renders a public voice source catalog from `tools/tts-bakeoff/voice-source-catalog.mjs`.

It is a source-discovery layer, not fake audio:

- Candidate cards show provider, source type, search query, persona, license status, and target env var.
- A candidate is selectable only when it has a real `sampleAudio` file and a usable license status.
- Without API keys or voice IDs, the page shows the candidate and next step, but does not fall back to system TTS.

Reference SOP: `docs/voice-source-catalog.md`.

## Environment

Create `vivi-oura-simulator/.env.tts-bakeoff` or export variables in the shell.

ElevenLabs v3:

```bash
ELEVENLABS_API_KEY=
ELEVENLABS_MODEL=eleven_v3
ELEVENLABS_OUTPUT_FORMAT=mp3_44100_128

# If you have the legal voice ID from the reference video, put it here.
# Without it, this route can only target a similar vibe, not 1:1 identity.
ELEVENLABS_NOIR_VOICE_ID=
ELEVENLABS_NOIR_STABILITY=0.34
ELEVENLABS_NOIR_STYLE=0.86
ELEVENLABS_NOIR_SPEED=1.18

# VIVI cloud candidate voices.
ELEVENLABS_CLOUD_SMART_VOICE_ID=
ELEVENLABS_CLOUD_RECOVERY_VOICE_ID=
ELEVENLABS_CLOUD_SMART_STABILITY=0.36
ELEVENLABS_CLOUD_SMART_STYLE=0.84
ELEVENLABS_CLOUD_SMART_SPEED=1.12
ELEVENLABS_CLOUD_RECOVERY_STABILITY=0.40
ELEVENLABS_CLOUD_RECOVERY_STYLE=0.80
ELEVENLABS_CLOUD_RECOVERY_SPEED=1.08

# Additional v6 role voices.
ELEVENLABS_NOIR_LOW_MALE_VOICE_ID=
ELEVENLABS_YOUNG_MALE_VOICE_ID=
ELEVENLABS_CONFIDANTE_SISTER_VOICE_ID=
ELEVENLABS_NOIR_LOW_MALE_STABILITY=0.38
ELEVENLABS_NOIR_LOW_MALE_STYLE=0.82
ELEVENLABS_NOIR_LOW_MALE_SPEED=1.10
ELEVENLABS_YOUNG_MALE_STABILITY=0.42
ELEVENLABS_YOUNG_MALE_STYLE=0.72
ELEVENLABS_YOUNG_MALE_SPEED=1.06
ELEVENLABS_CONFIDANTE_SISTER_STABILITY=0.44
ELEVENLABS_CONFIDANTE_SISTER_STYLE=0.70
ELEVENLABS_CONFIDANTE_SISTER_SPEED=1.02
```

MiniMax:

```bash
MINIMAX_API_KEY=
MINIMAX_GROUP_ID=
MINIMAX_VOICE_ID=
MINIMAX_TTS_MODEL=speech-02-hd
```

DashScope / CosyVoice:

```bash
DASHSCOPE_API_KEY=
DASHSCOPE_VOICE_ID=
DASHSCOPE_TTS_MODEL=cosyvoice-v2
# Optional when the account uses a different endpoint:
DASHSCOPE_TTS_ENDPOINT=
```

Azure:

```bash
AZURE_SPEECH_KEY=
AZURE_SPEECH_REGION=eastasia
AZURE_VOICE_ID=zh-CN-XiaoxiaoNeural
```

OpenAI optional backup:

```bash
OPENAI_API_KEY=
OPENAI_VOICE_ID=alloy
OPENAI_TTS_MODEL=gpt-4o-mini-tts
```

For the VIVI cloud persona round, configure one to three MiniMax cloud candidates:

```bash
MINIMAX_CLOUD_SOFT_A_VOICE_ID=
MINIMAX_CLOUD_SOFT_B_VOICE_ID=
MINIMAX_CLOUD_SOFT_C_VOICE_ID=
MINIMAX_CLOUD_SOFT_A_SPEED=0.90
MINIMAX_CLOUD_SOFT_B_SPEED=0.94
MINIMAX_CLOUD_SOFT_C_SPEED=0.88
MINIMAX_CLOUD_SOFT_A_PITCH=1.04
MINIMAX_CLOUD_SOFT_B_PITCH=1.06
MINIMAX_CLOUD_SOFT_C_PITCH=1.02
MINIMAX_GHOST_SOFT_VOICE_ID=
MINIMAX_SISTER_WARM_VOICE_ID=
MINIMAX_NOIR_LOW_MALE_VOICE_ID=
MINIMAX_YOUNG_MALE_VOICE_ID=
MINIMAX_CONFIDANTE_SISTER_VOICE_ID=
```

Cloud persona target:

- Young, light, soft, close, and slightly airy.
- Natural pauses between short Chinese phrases.
- Curious and caring, like the cloud peeking from the bottom-right corner.
- Avoid overly sweet acting, baby voice, customer-service tone, and mechanical narration.

Provider-specific voice IDs can override the shared voice:

```bash
DASHSCOPE_GHOST_SOFT_VOICE_ID=
DASHSCOPE_SISTER_WARM_VOICE_ID=
AZURE_SISTER_WARM_VOICE_ID=
AZURE_CALM_KEEPER_VOICE_ID=

# Local no-key previews for v6 role voices.
EDGE_MALE_NOIR_VOICE_ID=zh-CN-YunyangNeural
EDGE_MALE_YOUTH_VOICE_ID=zh-CN-YunxiaNeural
EDGE_CONFIDANTE_SISTER_VOICE_ID=zh-CN-XiaoxiaoNeural
```

Generated audio files are written to `voice-bakeoff/audio/*.mp3`. The listening page only enables a voice card when a real provider MP3 exists.

By default, generated MP3s go through light post processing with ffmpeg:

```text
highpass 65Hz + light air EQ + light compression + loudness normalization
```

Use `--no-post-process` when you want to audit the raw provider output.

## Selection Rule

- Naturalness >= 4/5.
- Mechanical feeling <= 2/5.
- Cloud persona fit >= 4/5.
- Chinese terms for cycle, sleep, recovery, and numbers must be read correctly.
- Pick MiniMax if it is clearly more natural.
- Pick CosyVoice if quality is close and cost/stability is better.
- Use ElevenLabs v3 when it has the authorized `voice_id` and scores higher for cinematic/showcase scenes.
- If ElevenLabs lacks the authorized reference voice, label it "similar style only"; do not claim video-level 1:1.
- Edge is a no-key demo fallback only.
