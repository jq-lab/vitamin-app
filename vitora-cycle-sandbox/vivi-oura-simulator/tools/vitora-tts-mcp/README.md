# Vitora TTS MCP

This local MCP server lets Claude Code decide when Dori should speak. It calls ElevenLabs, saves the MP3 locally, registers the message with the Vitora TTS bridge, and returns the playable URL.

## Start the bridge

```bash
VITORA_TTS_HOST=0.0.0.0 \
VITORA_TTS_PORT=8787 \
VITORA_TTS_PUBLIC_BASE_URL=http://127.0.0.1:8787 \
pnpm tts:bridge
```

For a real VPS, set `VITORA_TTS_PUBLIC_BASE_URL` to the HTTPS public origin.

## Configure the MCP process

```bash
ELEVENLABS_API_KEY=... \
ELEVENLABS_DORI_MALE_VOICE_ID=... \
VITORA_TTS_BRIDGE_URL=http://127.0.0.1:8787 \
pnpm tts:mcp
```

The API key stays in this server process. Do not put it in the mobile app.

## Male Dori voice presets

Pick a male voice in ElevenLabs, copy its `voice_id`, and put it in `ELEVENLABS_DORI_MALE_VOICE_ID`.
The default MCP preset is `dori_male`: lower, slower, steadier, and less theatrical.

Available presets:

- `dori_male`: default daily voice, calm and close.
- `dori_male_care`: slower and softer for low-energy care, sleep, and stress moments.
- `dori_male_action`: slightly clearer and faster for reminders, focus, and breathing starts.
- `dori_male_intimate`: lowest and slowest for sensitive emotional moments or stamp reveals.

Optional per-preset voice ids:

```bash
ELEVENLABS_DORI_MALE_VOICE_ID=...
ELEVENLABS_DORI_MALE_CARE_VOICE_ID=...
ELEVENLABS_DORI_MALE_ACTION_VOICE_ID=...
ELEVENLABS_DORI_MALE_INTIMATE_VOICE_ID=...
```

## Tool

`speak_with_dori_voice`

Input:

```json
{
  "text": "今天先慢一点，下午留八分钟呼吸恢复。",
  "preset": "dori_male_care",
  "voiceId": "optional-elevenlabs-voice-id",
  "messageId": "prediction-2026-07-04-001",
  "persona": "dori",
  "reason": "Claude decided this health moment should be spoken",
  "targetSurface": "today"
}
```

Output includes `audioId`, `audioUrl`, `audioPath`, `text`, `voiceId`, `voicePreset`, `voiceSettings`, and `createdAt`.

Per-call tuning is supported when you want to fine-tune a favorite male voice:

```json
{
  "text": "今天别硬撑，先做一个低刺激恢复。",
  "preset": "dori_male_care",
  "stability": 0.72,
  "similarityBoost": 0.86,
  "style": 0.12,
  "speed": 0.88
}
```

## Local dry run

Without an ElevenLabs key, you can test the bridge path with the bundled sample:

```bash
VITORA_TTS_DRY_RUN=1 pnpm tts:mcp
```
