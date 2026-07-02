# VIVI 公开声线来源库

更新时间：2026-06-17

目标：为 VIVI 云朵助手扩展可直接试听、可商用接入的公开声线来源，不再依赖 Edge 系统声线。所有候选都必须先确认授权，再生成真实 MP3，最后才能进入 App 语音选择。

## 总原则

- 不做未授权声音克隆，不上传视频里的人声做复刻。
- 视频声音只作为气质参考：NOIR、低冷、贴耳、电影旁白感。
- 页面里只有 `licenseStatus=usable` 且已有真实 MP3 的候选才能选择。
- 没有 API Key 或 voiceId 时，只展示平台、搜索词和接入步骤，不用系统 TTS 冒充。
- Edge 男声保留为失败对照，不作为正式声线来源。

## 平台优先级

| 优先级 | 平台 | 用途 | 中文能力 | 男声能力 | 接入判断 |
| --- | --- | --- | --- | --- | --- |
| P0 | ElevenLabs Voice Library | NOIR 男低音、电影旁白、英文视频质感 | 中 | 高 | 主推找视频平替 |
| P0 | MiniMax Speech | 中文男声、知心姐姐、小云朵人格 | 高 | 高 | 中文主线 |
| P1 | Fish Audio | 中文角色声线、公共库候选、Voice Design | 高 | 中高 | MiniMax 不贴时备选 |
| P1 | ElevenLabs Voice Design | 找不到现成声线时用 prompt 生成 | 中 | 高 | NOIR 平替路线 |
| P2 | Hume Octave | 英文表演感、情绪化旁白 | 低中 | 高 | 英文参考，不做中文主线 |
| P3 | Azure / Google / Amazon | 稳定兜底 | 中 | 中 | 生成失败时 fallback |

## 推荐搜索词

### NOIR 男低音

首选平台：ElevenLabs Voice Library / Voice Design，其次 Hume Octave。

搜索词：

```text
male narrator, noir, cinematic, deep, calm, intimate
english male, noir, vessel, calm, cinematic, documentary
low male noir narrator, intimate, cinematic, restrained, softly spoken
```

Voice Design prompt：

```text
A low, calm, cinematic Chinese male voice, intimate but restrained,
soft breath, no announcer tone, no exaggerated acting.
```

验收标准：

- 低沉但不闷。
- 贴近但不油腻。
- 句尾有自然收束，不像播报。
- 中文如果明显断句奇怪，降级为英文参考声线。

### 青涩男中音

首选平台：MiniMax Speech，其次 Fish Audio / ElevenLabs Library。

搜索词：

```text
青涩 男中音 清爽 陪伴 自然 不油腻
Chinese young male, friendly, natural, soft, assistant
young male, gentle, conversational, clear, assistant
```

验收标准：

- 年轻、清亮，但不要尖。
- 自然聊天感，不卖萌。
- 不能像广告男声或客服。
- 适合说“我看了一下”“今天别排太满”这种轻陪伴台词。

### 知心大姐姐

首选平台：MiniMax Speech，其次 Fish Audio / ElevenLabs Library。

搜索词：

```text
成熟 女声 温柔 知心姐姐 健康建议 可信
Chinese warm female, mature, caring, natural, health advisor
warm female, caring, mature, natural, soft, conversational
```

验收标准：

- 温柔、成熟、可信。
- 解释身体状态时像真实的人在慢慢讲。
- 不要客服腔、播报腔、过度甜美。
- 适合睡眠恢复、压力提醒、周期建议。

### 稳定兜底

平台：Azure Neural TTS、Google Cloud TTS / Chirp、Amazon Polly。

搜索词：

```text
Mandarin Chinese neural voice, calm assistant, female/male baseline
zh-CN Xiaoxiao / Yunxi neural voices, assistant style
```

验收标准：

- 稳定可用，发音清晰。
- 不追求云朵人格。
- 真实 provider 失败时才 fallback。

## 12 个候选池

试听台当前内置 12 个公开来源候选：

| 角色 | 数量 | 优先来源 |
| --- | ---: | --- |
| NOIR 男低音 | 4 | ElevenLabs Library、ElevenLabs Voice Design、Hume Octave |
| 青涩男中音 | 3 | MiniMax、Fish Audio、ElevenLabs Library |
| 知心姐姐 | 3 | MiniMax、Fish Audio、ElevenLabs Library |
| 稳定兜底 | 2 | Azure、Google/Amazon |

字段标准：

```json
{
  "provider": "minimax",
  "sourceType": "model_voice_catalog",
  "voiceId": "provider voice id",
  "searchQuery": "平台搜索词",
  "persona": "人设与听感描述",
  "licenseStatus": "needs_voice_id | usable_with_provider_terms | usable",
  "sampleAudio": "audio/sample.mp3",
  "score": 4.2
}
```

## 接入流程

1. 在试听台的“公开声线来源库”里选一个角色筛选项。
2. 打开平台文档或 Web 控制台，按 `searchQuery` 找声线。
3. 确认这条声线能用于你的账号和产品场景。
4. 把 voiceId 写入 `.env.tts-bakeoff` 对应变量。
5. 运行真实样音生成：

```bash
pnpm --dir /Users/youxiang/Desktop/VIVI/vitora-cycle-sandbox/vivi-oura-simulator tts:bakeoff -- --provider elevenlabs_v3,minimax --text today_ready,sleep_recovery_weak,stress_attention,ai_reply_short --force
```

6. 在 `http://127.0.0.1:8778/index.html` 试听。
7. 评分达到标准后，才允许进入正式 App 声线设置。

## 评分标准

| 维度 | 通过线 |
| --- | --- |
| 真人感 | >= 4/5 |
| 机械感 | <= 2/5 |
| 人设贴合 | >= 4/5 |
| 中文断句 | 无明显错误 |
| 健康词汇 | 周期、睡眠、恢复、压力不能读错 |
| 稳定性 | 同一文案多次生成不明显漂移 |

## 当前结论

- NOIR 男低音：继续优先找 ElevenLabs Library 或 Voice Design，Edge 不适合。
- 中文男声：优先 MiniMax，其次 Fish Audio。
- 知心姐姐：MiniMax / Fish Audio 都值得试。
- 兜底：Azure / Google / Amazon 只做失败 fallback，不做主声线。
