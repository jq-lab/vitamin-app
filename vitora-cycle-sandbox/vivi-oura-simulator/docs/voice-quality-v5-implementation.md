# VIVI Voice Quality v5

## Goal

VIVI voice quality should be selected from real audio, not from browser system TTS.

The production workflow is:

```text
Scene / persona / frame reference
-> Codex voice director rewrite
-> real TTS provider
-> light post processing
-> listening bakeoff
-> selected voice settings
-> app playback
```

## Reality Check

- If we have the legal `voice_id` behind the reference video, ElevenLabs v3 is the best route for matching the NOIR / Vessel cinematic feeling.
- Without that `voice_id`, we can only create a similar tone direction. We should not promise 1:1 identity or unauthorized cloning.
- VIVI's Chinese product voice should still be evaluated separately. The cloud assistant needs to sound smart, soft, close, and curious, not only cinematic.
- Edge Neural TTS remains a no-key demo fallback. It is not the final voice quality target.

## Provider Tiers

| Tier | Provider | Role | Use When |
| --- | --- | --- | --- |
| 1 | ElevenLabs v3 | Cinematic / expressive reference | We have a legal voice ID and need the closest video-like quality |
| 2 | MiniMax Speech | Chinese cloud persona | We need natural Mandarin and character fit |
| 3 | DashScope / CosyVoice | Stable Chinese fallback | We need domestic chain, cost control, and reliability |
| 4 | Azure / OpenAI | Stable / instruction baseline | We need enterprise fallback or instruction comparison |
| 5 | Edge + post process | No-key demo only | We need to demo the workflow without provider keys |

## Voice Director Rules

### Cloud Assistant

Target:

- smart, soft, curious, close
- young but not childish
- airy but not weak
- short lines with natural pauses
- avoids customer-service tone

Avoid:

- "主人" as a default in production copy
- baby voice
- over-sweet acting
- flat broadcasting
- long paragraph narration

Example clean text:

```text
今天状态不错，昨晚的恢复托住了你。重要事情，可以先放在上午推进。
```

Example cloud performance text:

```text
[softly] 嗯，我在这儿。[pause] 今天状态不错，昨晚的恢复托住了你。[teasing] 重要的事，我们先放在上午，慢慢往前推。
```

### NOIR Reference

Target:

- cold white tone
- intimate but restrained
- cinematic narration
- soft pauses
- no overacting

Example:

```text
[softly] But I know you. [pause] You move faster when the room gets quiet. [long pause] So today, take the first step before the noise comes back.
```

## Current Implementation

Core files:

- `/Users/youxiang/Desktop/VIVI/vitora-cycle-sandbox/vivi-oura-simulator/tools/tts-bakeoff/providers.mjs`
- `/Users/youxiang/Desktop/VIVI/vitora-cycle-sandbox/vivi-oura-simulator/tools/tts-bakeoff/voice-director.mjs`
- `/Users/youxiang/Desktop/VIVI/vitora-cycle-sandbox/vivi-oura-simulator/tools/tts-bakeoff/run-bakeoff.mjs`
- `/Users/youxiang/Desktop/VIVI/vitora-cycle-sandbox/vivi-oura-simulator/.env.tts-bakeoff.example`

The manifest records:

- original source text
- directed script
- provider
- model
- voice ID
- director variant
- performance tags
- provider parameters
- post-processing result

## Commands

Generate the full listening page:

```bash
pnpm --dir /Users/youxiang/Desktop/VIVI/vitora-cycle-sandbox/vivi-oura-simulator tts:bakeoff -- --force
```

Generate only ElevenLabs v3:

```bash
pnpm --dir /Users/youxiang/Desktop/VIVI/vitora-cycle-sandbox/vivi-oura-simulator tts:bakeoff -- --provider elevenlabs_v3 --force
```

Generate raw provider output without post processing:

```bash
pnpm --dir /Users/youxiang/Desktop/VIVI/vitora-cycle-sandbox/vivi-oura-simulator tts:bakeoff -- --provider elevenlabs_v3,minimax --force --no-post-process
```

## Acceptance Criteria

For each selected voice:

- MP3 exists and is larger than 10 KB.
- Duration is longer than 1 second.
- Performance tags are not spoken aloud unless the provider intentionally supports them.
- Cloud assistant scores 4/5+ for smart, soft, curious, and close.
- Mechanical feeling scores below 2/5.
- Health advice sounds trustworthy and not like customer service.

## Fallbacks

1. If ElevenLabs v3 with authorized voice ID works:
   Use it for cinematic showcase and compare Chinese cloud delivery.

2. If ElevenLabs voice ID is unavailable:
   Use Voice Library / Voice Design only for similar style exploration, and mark it clearly.

3. If ElevenLabs quality is high but cost or latency is risky:
   Use it for marketing/showcase audio and MiniMax or CosyVoice for product playback.

4. If MiniMax Chinese cloud is still not right:
   Run OpenAI instruction TTS and DashScope / CosyVoice as additional comparison.

5. If no real provider key is available:
   Keep Edge samples only as workflow validation. Do not use them to judge final VIVI voice quality.
