# VIVI 男声平替方案 v7

## 结论

当前 `Edge Neural TTS` 的男低音和青涩男声不适合作为 VIVI 正式声线。它的问题不是单纯音高或语速，而是底层声库缺少真人表演里的气声、细微动态、语义停顿和贴耳感。继续降 pitch / 降 speed 只会更闷、更像系统播报。

目标视频声线更接近：

- 低声压、近讲、冷白。
- 句子短，停顿多。
- 情绪克制，但有表演感。
- 平均音量不大，峰值不顶满。
- 静音不是死停顿，而像自然呼吸。

## 本地参考分析

已从用户给的两个视频中提取前 20 秒音频：

| 文件 | 平均音量 | 峰值 | 停顿特征 |
| --- | ---: | ---: | --- |
| `录屏2026-06-17 15.13.26.mov` | `-30.1 dB` | `-13.0 dB` | 开头长停顿，整体更轻、更靠近 |
| `录屏2026-06-17 15.03.56.mov` | `-27.2 dB` | `-11.7 dB` | 多个 `0.3-0.45s` 自然停顿 |

当前 Edge 男声样音：

| 声线 | 平均音量 | 峰值 | 主要问题 |
| --- | ---: | ---: | --- |
| `男声 A · NOIR 低冷旁白` | `-18.9 dB` | `-1.9 dB` | 太顶、太近、低频闷，不像真人贴耳 |
| `男声 B · 青涩陪伴` | `-17.3 dB` | `-1.9 dB` | 太满、播报感强，缺少自然呼吸和语义弹性 |

因此下一轮不再继续调 Edge 男声。

## 平替优先级

### Tier 1：ElevenLabs v3 / Voice Library / Voice Design

适合：复刻视频里的英文 NOIR 质感、低冷男声、电影旁白感。

原因：

- 官方文档明确：最终音频最受 `voice` 和 `model` 影响，参数只是第三层；继续调错 voice 没意义。
- ElevenLabs 支持 Voice Library、Voice Design、Voice Cloning 和 Voice Remixing，可用自然语言改变 delivery、cadence、tone、gender、accent。
- Eleven v3 是更偏表演和情绪的路线，适合视频声线这类“冷白、克制、低语”的声音。

限制：

- 如果没有合法授权的 `voice_id`，只能做相似气质，不能 1:1。
- 英文视频质感更容易还原；中文主声线需要额外测试中文发音和口音。

建议搜索词：

```text
male, noir, intimate, cinematic, soft spoken, low voice, restrained, close mic
```

建议参数：

```text
model: eleven_v3
stability: 0.36-0.44
style: 0.70-0.84
speed: 1.04-1.12
```

### Tier 2：MiniMax Speech-02-HD / Text-Prompted Voice

适合：中文男低音、中文青涩男中音、中文 VIVI 主声线。

原因：

- MiniMax 技术报告提到支持 reference timbre、zero-shot / one-shot、中文发音表现和文本描述生成音色。
- 对 VIVI 更关键的是中文自然度和中文断句，这比英文视频质感更重要。
- 可直接写中文音色描述，例如“年轻男中音、音色清亮、语速偏慢、带一点气声，但不要播音腔”。

建议作为中文主路线：

```text
男声 A：
中国男性声音，低沉、冷白、近讲，语速偏慢，短句之间有自然停顿。声音克制，不要播音腔，不要客服腔。

男声 B：
中国青年男性声音，男中音，清亮、自然、轻陪伴。语速中等偏慢，像认真帮用户看身体状态，不油腻，不卖萌。
```

### Tier 3：Hume Octave

适合：英文情绪表达、英文视频质感、Voice Design 试验。

原因：

- Hume Octave 支持用 prompt 设计声音，并强调语义和情绪理解、pitch / tempo / emphasis 的自适应。
- 文档也提到可以通过 prompt 设计“任何声音”，并支持克隆和流式生成。

限制：

- 当前官方文档列出的 Octave 2 支持语言不包含中文；因此不建议做 VIVI 中文主声线。
- 可以作为英文 NOIR 参考测试，不作为中文 App 生产主路线。

### Tier 4：F5-TTS / OpenVoice / Fish Speech 自部署

适合：有工程资源、愿意自部署、需要降低长期成本。

优点：

- F5-TTS 支持 reference audio + target text 的推理方式。
- OpenVoice / Fish Speech 也属于可探索的开源或半开源 voice clone / TTS 方向。

限制：

- 需要 GPU 或外部推理服务。
- 需要处理模型许可、商用许可和部署稳定性。
- 如果使用视频参考音色，仍然必须确认授权，不能做未授权声音克隆。

## 推荐决策

不要再调 Edge 男声。下一步做两条并行试听：

1. `ElevenLabs v3`：负责视频里的 NOIR / Vessel 男声气质。
2. `MiniMax Speech-02-HD`：负责中文男低音、中文青涩男中音和 VIVI 中文主声线。

Hume Octave 作为英文情绪表达备选；F5-TTS / OpenVoice / Fish Speech 作为后续自部署和成本优化路线。

## 下一步落地

1. 在试听台中保留 Edge 男声，但标记为“失败方向 / 不推荐”。
2. 新增 `ElevenLabs 男声 A/B` 和 `MiniMax 男声 A/B` 的真实模型卡。
3. 配置真实 API Key 和 voiceId 后，不再用 Edge 男声作为可选正式声线。
4. 每个候选生成 4 条场景样音：
   - 今日状态。
   - 睡眠恢复。
   - 压力提醒。
   - AI 回复。
5. 用户只在真实模型样音中选择正式声线。

## Provider 资料

- ElevenLabs Text to Speech / Voice Design / Voice Remixing: https://elevenlabs.io/docs/eleven-creative/playground/text-to-speech
- MiniMax-Speech Tech Report: https://minimax-ai.github.io/tts_tech_report/
- Hume Octave TTS: https://dev.hume.ai/docs/text-to-speech-tts/overview
- F5-TTS: https://github.com/SWivid/F5-TTS
- GPT-SoVITS: https://github.com/RVC-Boss/GPT-SoVITS
- OpenVoice: https://github.com/myshell-ai/OpenVoice
