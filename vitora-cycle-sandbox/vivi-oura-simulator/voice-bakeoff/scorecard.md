# VIVI TTS Bakeoff Scorecard

Generated: 2026-06-17T10:02:43.410Z

## Run Summary

| Provider | Generated | Skipped | Failed | Docs |
| --- | ---: | ---: | ---: | --- |
| ElevenLabs v3 | 0 | 24 | 0 | https://elevenlabs.io/docs/capabilities/text-to-speech |
| Microsoft Edge Neural TTS | 28 | 0 | 0 | https://github.com/rany2/edge-tts |
| MiniMax Speech | 0 | 28 | 0 | https://minimax-ai.github.io/tts_tech_report/ |
| DashScope / CosyVoice | 0 | 8 | 0 | https://github.com/FunAudioLLM/CosyVoice |
| Azure Neural TTS | 0 | 8 | 0 | https://learn.microsoft.com/en-us/azure/ai-services/speech-service/text-to-speech |
| OpenAI TTS | 0 | 4 | 0 | https://platform.openai.com/docs/guides/text-to-speech |

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
| today_ready | 今日状态 | 我在这儿。今天状态不错，昨晚的恢复托住了你。重要事情，可以先放在上午推进。 |  |  |  |  |  |
| sleep_recovery_weak | 睡眠恢复 | 今天先别急。醒来觉得累，不是你懒，是身体还没完全修好。我们把节奏放轻一点。 |  |  |  |  |  |
| stress_attention | 压力提醒 | 压力这里，需要稍微看一下。今天别把事情排太满，下午留八分钟呼吸恢复，会舒服很多。 |  |  |  |  |  |
| ai_reply_short | AI 回复短句 | 可以动，但换轻一点。今天快走二十分钟，比硬练更适合。 |  |  |  |  |  |

## Public Voice Source Candidates

| Candidate | Source | Role | License Status | Env Var | Search Query | Score | Notes |
| --- | --- | --- | --- | --- | --- | ---: | --- |
| NOIR 男低音 01 · 冷白旁白 | ElevenLabs Voice Library | noir_low_male | needs_voice_id | ELEVENLABS_NOIR_LOW_MALE_VOICE_ID | male narrator, noir, cinematic, deep, calm, intimate |  | |
| NOIR 男低音 02 · 英文参考 | ElevenLabs Voice Library | noir_low_male | needs_voice_id | ELEVENLABS_NOIR_VOICE_ID | english male, noir, vessel, calm, cinematic, documentary |  | |
| NOIR 男低音 03 · Prompt 生成 | ElevenLabs Voice Design | noir_low_male | needs_generated_voice_review | ELEVENLABS_NOIR_LOW_MALE_VOICE_ID | A low, calm, cinematic Chinese male voice, intimate but restrained, soft breath, no announcer tone. |  | |
| NOIR 男低音 04 · 英文表演感 | Hume Octave | noir_low_male | needs_api_key_and_review | HUME_NOIR_LOW_MALE_VOICE_ID | low male noir narrator, intimate, cinematic, restrained, softly spoken |  | |
| 青涩男中音 01 · 清爽陪伴 | MiniMax Speech | young_mid_male | needs_voice_id | MINIMAX_YOUNG_MALE_VOICE_ID | 青涩 男中音 清爽 陪伴 自然 不油腻 |  | |
| 青涩男中音 02 · 公共库候选 | Fish Audio | young_mid_male | needs_voice_id_and_license_review | FISH_YOUNG_MALE_VOICE_ID | Chinese young male, friendly, natural, soft, assistant |  | |
| 青涩男中音 03 · Library 候选 | ElevenLabs Voice Library | young_mid_male | needs_voice_id | ELEVENLABS_YOUNG_MALE_VOICE_ID | young male, gentle, conversational, clear, assistant |  | |
| 知心姐姐 01 · 中文主推 | MiniMax Speech | confidante_sister | needs_voice_id | MINIMAX_CONFIDANTE_SISTER_VOICE_ID | 成熟 女声 温柔 知心姐姐 健康建议 可信 |  | |
| 知心姐姐 02 · 公共库候选 | Fish Audio | confidante_sister | needs_voice_id_and_license_review | FISH_CONFIDANTE_SISTER_VOICE_ID | Chinese warm female, mature, caring, natural, health advisor |  | |
| 知心姐姐 03 · 高质感候选 | ElevenLabs Voice Library | confidante_sister | needs_voice_id | ELEVENLABS_CONFIDANTE_SISTER_VOICE_ID | warm female, caring, mature, natural, soft, conversational |  | |
| 稳定兜底 01 · Azure 中文 | Azure Neural TTS | stable_fallback | usable_with_provider_terms | AZURE_SISTER_WARM_VOICE_ID | zh-CN Xiaoxiao / Yunxi neural voices, assistant style |  | |
| 稳定兜底 02 · Google/Amazon | Google Chirp / Amazon Polly | stable_fallback | usable_with_provider_terms | GOOGLE_TTS_VOICE_ID / AMAZON_POLLY_VOICE_ID | Mandarin Chinese neural voice, calm assistant, female/male baseline |  | |

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
