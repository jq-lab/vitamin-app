const numberEnv = (key, fallback) => {
  const value = Number(process.env[key]);
  return Number.isFinite(value) ? value : fallback;
};

export const providerProfiles = [
  {
    id: "elevenlabs_v3",
    label: "ElevenLabs v3",
    docs: "https://elevenlabs.io/docs/capabilities/text-to-speech",
    defaultModel: process.env.ELEVENLABS_MODEL || "eleven_v3",
    enabledWhen: ["ELEVENLABS_API_KEY"],
    recommendation:
      "主攻视频里的 NOIR / Vessel 电影感和强表演 TTS。若没有合法 voice_id，只能做相似气质，不能保证同款声线。",
    decisionRole: "cinematic_reference",
    voicePresets: [
      {
        presetId: "noir_reference",
        displayName: "NOIR Vessel 参考声线",
        voiceId: process.env.ELEVENLABS_NOIR_VOICE_ID || process.env.ELEVENLABS_VOICE_ID || "",
        speed: numberEnv("ELEVENLABS_NOIR_SPEED", 1.18),
        pitch: 1,
        style: "noir_cinematic",
        stability: numberEnv("ELEVENLABS_NOIR_STABILITY", 0.34),
        similarityBoost: numberEnv("ELEVENLABS_NOIR_SIMILARITY", 0.78),
        styleExaggeration: numberEnv("ELEVENLABS_NOIR_STYLE", 0.86),
        useSpeakerBoost: process.env.ELEVENLABS_USE_SPEAKER_BOOST !== "0",
        languageCode: process.env.ELEVENLABS_NOIR_LANGUAGE || "en",
        directorVariant: "noir_en",
        actingProfile: "冷白、克制、轻疏离，带电影旁白感；参考视频质感，但不做未授权声音克隆。",
      },
      {
        presetId: "noir_low_male",
        displayName: "男声 A · NOIR 低冷旁白",
        voiceId:
          process.env.ELEVENLABS_NOIR_LOW_MALE_VOICE_ID ||
          process.env.ELEVENLABS_NOIR_VOICE_ID ||
          process.env.ELEVENLABS_VOICE_ID ||
          "",
        speed: numberEnv("ELEVENLABS_NOIR_LOW_MALE_SPEED", 1.1),
        pitch: 1,
        style: "noir_low_male",
        stability: numberEnv("ELEVENLABS_NOIR_LOW_MALE_STABILITY", 0.38),
        similarityBoost: numberEnv("ELEVENLABS_NOIR_LOW_MALE_SIMILARITY", 0.8),
        styleExaggeration: numberEnv("ELEVENLABS_NOIR_LOW_MALE_STYLE", 0.82),
        useSpeakerBoost: process.env.ELEVENLABS_USE_SPEAKER_BOOST !== "0",
        languageCode: process.env.ELEVENLABS_NOIR_LOW_MALE_LANGUAGE || "zh",
        directorVariant: "noir_low_male",
        actingProfile: "低沉、冷白、克制，像贴近耳边的电影旁白；参考视频气质，不做未授权同款克隆。",
      },
      {
        presetId: "young_mid_male",
        displayName: "男声 B · 青涩陪伴",
        voiceId:
          process.env.ELEVENLABS_YOUNG_MALE_VOICE_ID ||
          process.env.ELEVENLABS_MALE_VOICE_ID ||
          process.env.ELEVENLABS_VOICE_ID ||
          "",
        speed: numberEnv("ELEVENLABS_YOUNG_MALE_SPEED", 1.06),
        pitch: 1,
        style: "young_mid_male",
        stability: numberEnv("ELEVENLABS_YOUNG_MALE_STABILITY", 0.42),
        similarityBoost: numberEnv("ELEVENLABS_YOUNG_MALE_SIMILARITY", 0.76),
        styleExaggeration: numberEnv("ELEVENLABS_YOUNG_MALE_STYLE", 0.72),
        useSpeakerBoost: process.env.ELEVENLABS_USE_SPEAKER_BOOST !== "0",
        languageCode: process.env.ELEVENLABS_YOUNG_MALE_LANGUAGE || "zh",
        directorVariant: "young_male_support",
        actingProfile: "青涩、清亮、男中音，陪伴感强但不油腻；像认真帮你看状态的年轻助理。",
      },
      {
        presetId: "confidante_sister",
        displayName: "女声 · 知心大姐姐",
        voiceId:
          process.env.ELEVENLABS_CONFIDANTE_SISTER_VOICE_ID ||
          process.env.ELEVENLABS_SISTER_VOICE_ID ||
          process.env.ELEVENLABS_VOICE_ID ||
          "",
        speed: numberEnv("ELEVENLABS_CONFIDANTE_SISTER_SPEED", 1.02),
        pitch: 1,
        style: "confidante_sister",
        stability: numberEnv("ELEVENLABS_CONFIDANTE_SISTER_STABILITY", 0.44),
        similarityBoost: numberEnv("ELEVENLABS_CONFIDANTE_SISTER_SIMILARITY", 0.78),
        styleExaggeration: numberEnv("ELEVENLABS_CONFIDANTE_SISTER_STYLE", 0.7),
        useSpeakerBoost: process.env.ELEVENLABS_USE_SPEAKER_BOOST !== "0",
        languageCode: process.env.ELEVENLABS_CONFIDANTE_SISTER_LANGUAGE || "zh",
        directorVariant: "confidante_sister",
        actingProfile: "成熟、温柔、可信，像知心姐姐在慢慢解释身体信号；不要客服腔。",
      },
      {
        presetId: "cloud_smart_soft",
        displayName: "小云朵 · 聪明软萌",
        voiceId:
          process.env.ELEVENLABS_CLOUD_SMART_VOICE_ID ||
          process.env.ELEVENLABS_CLOUD_SOFT_VOICE_ID ||
          process.env.ELEVENLABS_VOICE_ID ||
          "",
        speed: numberEnv("ELEVENLABS_CLOUD_SMART_SPEED", 1.12),
        pitch: 1,
        style: "cloud_smart_soft",
        stability: numberEnv("ELEVENLABS_CLOUD_SMART_STABILITY", 0.36),
        similarityBoost: numberEnv("ELEVENLABS_CLOUD_SMART_SIMILARITY", 0.76),
        styleExaggeration: numberEnv("ELEVENLABS_CLOUD_SMART_STYLE", 0.84),
        useSpeakerBoost: process.env.ELEVENLABS_USE_SPEAKER_BOOST !== "0",
        languageCode: process.env.ELEVENLABS_CLOUD_LANGUAGE || "zh",
        directorVariant: "cloud_performance",
        actingProfile: "聪明、轻软、贴近，好奇但不幼稚；少客服腔，短句自然停顿。",
      },
      {
        presetId: "cloud_recovery_soft",
        displayName: "小云朵 · 安抚恢复",
        voiceId:
          process.env.ELEVENLABS_CLOUD_RECOVERY_VOICE_ID ||
          process.env.ELEVENLABS_CLOUD_SOFT_VOICE_ID ||
          process.env.ELEVENLABS_VOICE_ID ||
          "",
        speed: numberEnv("ELEVENLABS_CLOUD_RECOVERY_SPEED", 1.08),
        pitch: 1,
        style: "cloud_recovery_soft",
        stability: numberEnv("ELEVENLABS_CLOUD_RECOVERY_STABILITY", 0.4),
        similarityBoost: numberEnv("ELEVENLABS_CLOUD_RECOVERY_SIMILARITY", 0.78),
        styleExaggeration: numberEnv("ELEVENLABS_CLOUD_RECOVERY_STYLE", 0.8),
        useSpeakerBoost: process.env.ELEVENLABS_USE_SPEAKER_BOOST !== "0",
        languageCode: process.env.ELEVENLABS_CLOUD_LANGUAGE || "zh",
        directorVariant: "cloud_soft_recovery",
        actingProfile: "更慢、更安抚，适合睡眠恢复、压力提醒和经前窗口。",
      },
    ],
  },
  {
    id: "edge_neural",
    label: "Microsoft Edge Neural TTS",
    docs: "https://github.com/rany2/edge-tts",
    defaultModel: "edge-neural-tts",
    enabledWhen: [],
    recommendation: "即时真实样音：不需要 API Key，适合先试听不同中文神经网络声线；生产主声线仍建议用 MiniMax 或 CosyVoice 复核。",
    decisionRole: "instant_preview",
    voicePresets: [
      {
        presetId: "ghost_soft",
        displayName: "软萌小云朵",
        voiceId: process.env.EDGE_GHOST_SOFT_VOICE_ID || "zh-CN-XiaoyiNeural",
        speed: numberEnv("EDGE_GHOST_SOFT_SPEED", 0.9),
        pitch: numberEnv("EDGE_GHOST_SOFT_PITCH", 1.12),
        style: "cute",
      },
      {
        presetId: "male_noir_preview",
        displayName: "男声 A · NOIR 低冷旁白",
        voiceId: process.env.EDGE_MALE_NOIR_VOICE_ID || "zh-CN-YunyangNeural",
        speed: numberEnv("EDGE_MALE_NOIR_SPEED", 0.86),
        pitch: numberEnv("EDGE_MALE_NOIR_PITCH", 0.84),
        style: "noir_low_male",
        directorVariant: "noir_low_male",
      },
      {
        presetId: "male_youth_preview",
        displayName: "男声 B · 年轻成人陪伴",
        voiceId: process.env.EDGE_MALE_YOUTH_VOICE_ID || "zh-CN-YunxiNeural",
        speed: numberEnv("EDGE_MALE_YOUTH_SPEED", 1.03),
        pitch: numberEnv("EDGE_MALE_YOUTH_PITCH", 0.9),
        style: "young_mid_male",
        directorVariant: "young_male_support",
      },
      {
        presetId: "confidante_sister_preview",
        displayName: "女声 · 知心大姐姐",
        voiceId: process.env.EDGE_CONFIDANTE_SISTER_VOICE_ID || "zh-CN-XiaoxiaoNeural",
        speed: numberEnv("EDGE_CONFIDANTE_SISTER_SPEED", 0.84),
        pitch: numberEnv("EDGE_CONFIDANTE_SISTER_PITCH", 0.88),
        style: "confidante_sister",
        directorVariant: "confidante_sister",
      },
      {
        presetId: "sister_warm",
        displayName: "温柔姐姐",
        voiceId: process.env.EDGE_SISTER_WARM_VOICE_ID || "zh-CN-XiaoxiaoNeural",
        speed: numberEnv("EDGE_SISTER_WARM_SPEED", 0.86),
        pitch: numberEnv("EDGE_SISTER_WARM_PITCH", 0.92),
        style: "warm",
      },
      {
        presetId: "sunshine_friend",
        displayName: "阳光朋友 · 年轻成人",
        voiceId: process.env.EDGE_SUNSHINE_FRIEND_VOICE_ID || "zh-CN-YunxiNeural",
        speed: numberEnv("EDGE_SUNSHINE_FRIEND_SPEED", 1.06),
        pitch: numberEnv("EDGE_SUNSHINE_FRIEND_PITCH", 0.88),
        style: "sunshine",
        directorVariant: "young_male_support",
      },
      {
        presetId: "calm_keeper",
        displayName: "冷静管家",
        voiceId: process.env.EDGE_CALM_KEEPER_VOICE_ID || "zh-CN-YunyangNeural",
        speed: numberEnv("EDGE_CALM_KEEPER_SPEED", 0.88),
        pitch: numberEnv("EDGE_CALM_KEEPER_PITCH", 0.86),
        style: "calm",
        directorVariant: "noir_low_male",
      },
    ],
  },
  {
    id: "minimax",
    label: "MiniMax Speech",
    docs: "https://minimax-ai.github.io/tts_tech_report/",
    defaultModel: process.env.MINIMAX_TTS_MODEL || "speech-02-hd",
    enabledWhen: ["MINIMAX_API_KEY", "MINIMAX_GROUP_ID"],
    recommendation: "主推荐：中文自然度、情绪和角色感优先时选它，适合 VIVI 云朵人格。",
    decisionRole: "best_voice",
    voicePresets: [
      {
        presetId: "cloud_soft_a",
        displayName: "云朵 A · 轻软陪伴",
        voiceId:
          process.env.MINIMAX_CLOUD_SOFT_A_VOICE_ID ||
          process.env.MINIMAX_GHOST_SOFT_VOICE_ID ||
          process.env.MINIMAX_VOICE_ID ||
          "",
        speed: numberEnv("MINIMAX_CLOUD_SOFT_A_SPEED", 0.9),
        pitch: numberEnv("MINIMAX_CLOUD_SOFT_A_PITCH", 1.04),
        style: "cloud_soft_a",
        directorVariant: "cloud_natural",
        actingProfile: "年轻、轻软、贴近，像从屏幕右下角探出来轻声提醒。",
      },
      {
        presetId: "cloud_soft_b",
        displayName: "云朵 B · 好奇灵动",
        voiceId:
          process.env.MINIMAX_CLOUD_SOFT_B_VOICE_ID ||
          process.env.MINIMAX_GHOST_SOFT_VOICE_ID ||
          process.env.MINIMAX_VOICE_ID ||
          "",
        speed: numberEnv("MINIMAX_CLOUD_SOFT_B_SPEED", 0.94),
        pitch: numberEnv("MINIMAX_CLOUD_SOFT_B_PITCH", 1.06),
        style: "cloud_soft_b",
        directorVariant: "cloud_curious",
        actingProfile: "更好奇、更轻快，但避免过甜、夹子音和夸张表演。",
      },
      {
        presetId: "cloud_soft_c",
        displayName: "云朵 C · 安抚恢复",
        voiceId:
          process.env.MINIMAX_CLOUD_SOFT_C_VOICE_ID ||
          process.env.MINIMAX_GHOST_SOFT_VOICE_ID ||
          process.env.MINIMAX_VOICE_ID ||
          "",
        speed: numberEnv("MINIMAX_CLOUD_SOFT_C_SPEED", 0.88),
        pitch: numberEnv("MINIMAX_CLOUD_SOFT_C_PITCH", 1.02),
        style: "cloud_soft_c",
        directorVariant: "cloud_recovery",
        actingProfile: "更慢、更安抚，适合睡眠恢复、压力提醒和经前窗口。",
      },
      {
        presetId: "sister_warm",
        displayName: "温柔姐姐",
        voiceId: process.env.MINIMAX_SISTER_WARM_VOICE_ID || process.env.MINIMAX_VOICE_ID || "",
        speed: numberEnv("MINIMAX_SISTER_WARM_SPEED", 0.92),
        pitch: numberEnv("MINIMAX_SISTER_WARM_PITCH", 1.0),
        style: "warm",
        directorVariant: "health_trust",
      },
      {
        presetId: "noir_low_male",
        displayName: "男声 A · NOIR 低冷旁白",
        voiceId: process.env.MINIMAX_NOIR_LOW_MALE_VOICE_ID || process.env.MINIMAX_MALE_VOICE_ID || "",
        speed: numberEnv("MINIMAX_NOIR_LOW_MALE_SPEED", 0.86),
        pitch: numberEnv("MINIMAX_NOIR_LOW_MALE_PITCH", 0.92),
        style: "noir_low_male",
        directorVariant: "noir_low_male",
        actingProfile: "中文低冷男声候选：低沉、克制、电影感，不做未授权视频声线克隆。",
      },
      {
        presetId: "young_mid_male",
        displayName: "男声 B · 青涩陪伴",
        voiceId: process.env.MINIMAX_YOUNG_MALE_VOICE_ID || process.env.MINIMAX_MALE_VOICE_ID || "",
        speed: numberEnv("MINIMAX_YOUNG_MALE_SPEED", 0.94),
        pitch: numberEnv("MINIMAX_YOUNG_MALE_PITCH", 0.98),
        style: "young_mid_male",
        directorVariant: "young_male_support",
        actingProfile: "中文年轻男中音候选：青涩、清亮、陪伴，不油腻。",
      },
      {
        presetId: "confidante_sister",
        displayName: "女声 · 知心大姐姐",
        voiceId: process.env.MINIMAX_CONFIDANTE_SISTER_VOICE_ID || process.env.MINIMAX_SISTER_WARM_VOICE_ID || "",
        speed: numberEnv("MINIMAX_CONFIDANTE_SISTER_SPEED", 0.9),
        pitch: numberEnv("MINIMAX_CONFIDANTE_SISTER_PITCH", 0.98),
        style: "confidante_sister",
        directorVariant: "confidante_sister",
        actingProfile: "中文知心姐姐候选：成熟、温柔、可信，解释身体信号时不客服。",
      },
    ],
  },
  {
    id: "dashscope_cosyvoice",
    label: "DashScope / CosyVoice",
    docs: "https://github.com/FunAudioLLM/CosyVoice",
    defaultModel: process.env.DASHSCOPE_TTS_MODEL || "cosyvoice-v2",
    enabledWhen: ["DASHSCOPE_API_KEY"],
    recommendation: "稳定兜底：国内链路、成本和稳定性更适合作为生产 fallback。",
    decisionRole: "stable_fallback",
    voicePresets: [
      {
        presetId: "ghost_soft",
        displayName: "软萌小云朵",
        voiceId: process.env.DASHSCOPE_GHOST_SOFT_VOICE_ID || process.env.DASHSCOPE_VOICE_ID || "",
        speed: numberEnv("DASHSCOPE_GHOST_SOFT_SPEED", 0.95),
        pitch: numberEnv("DASHSCOPE_GHOST_SOFT_PITCH", 1.08),
        style: "cute",
        directorVariant: "cloud_natural",
      },
      {
        presetId: "sister_warm",
        displayName: "温柔姐姐",
        voiceId: process.env.DASHSCOPE_SISTER_WARM_VOICE_ID || process.env.DASHSCOPE_VOICE_ID || "",
        speed: numberEnv("DASHSCOPE_SISTER_WARM_SPEED", 0.92),
        pitch: numberEnv("DASHSCOPE_SISTER_WARM_PITCH", 1.0),
        style: "warm",
        directorVariant: "health_trust",
      },
    ],
  },
  {
    id: "azure",
    label: "Azure Neural TTS",
    docs: "https://learn.microsoft.com/en-us/azure/ai-services/speech-service/text-to-speech",
    defaultModel: "azure-neural-tts",
    enabledWhen: ["AZURE_SPEECH_KEY", "AZURE_SPEECH_REGION"],
    recommendation: "企业 baseline：稳定，但人格感通常不如新一代中文大模型 TTS。",
    decisionRole: "baseline",
    voicePresets: [
      {
        presetId: "sister_warm",
        displayName: "温柔姐姐",
        voiceId: process.env.AZURE_SISTER_WARM_VOICE_ID || process.env.AZURE_VOICE_ID || "zh-CN-XiaoxiaoNeural",
        speed: numberEnv("AZURE_SISTER_WARM_SPEED", 0.92),
        pitch: numberEnv("AZURE_SISTER_WARM_PITCH", 1.0),
        style: "warm",
        azureStyle: process.env.AZURE_SISTER_WARM_STYLE || "assistant",
        azureRole: process.env.AZURE_SISTER_WARM_ROLE || "",
        directorVariant: "health_trust",
      },
      {
        presetId: "calm_keeper",
        displayName: "冷静管家",
        voiceId: process.env.AZURE_CALM_KEEPER_VOICE_ID || process.env.AZURE_VOICE_ID || "zh-CN-YunxiNeural",
        speed: numberEnv("AZURE_CALM_KEEPER_SPEED", 0.9),
        pitch: numberEnv("AZURE_CALM_KEEPER_PITCH", 0.95),
        style: "calm",
        azureStyle: process.env.AZURE_CALM_KEEPER_STYLE || "",
        azureRole: process.env.AZURE_CALM_KEEPER_ROLE || "",
        directorVariant: "clean",
      },
    ],
  },
  {
    id: "openai",
    label: "OpenAI TTS",
    docs: "https://platform.openai.com/docs/guides/text-to-speech",
    defaultModel: process.env.OPENAI_TTS_MODEL || "gpt-4o-mini-tts",
    enabledWhen: ["OPENAI_API_KEY"],
    optional: true,
    recommendation: "备选参考：可做横向参考，不作为第一梯队中文人格声线。",
    decisionRole: "optional_reference",
    voicePresets: [
      {
        presetId: "calm_keeper",
        displayName: "冷静管家",
        voiceId: process.env.OPENAI_CALM_KEEPER_VOICE_ID || process.env.OPENAI_VOICE_ID || "alloy",
        speed: numberEnv("OPENAI_CALM_KEEPER_SPEED", 0.92),
        pitch: 1,
        style: "calm",
        directorVariant: "health_trust",
        instructions: "声音克制、可信、像清晰的私人健康助理；不要客服腔，不要夸张表演。",
      },
    ],
  },
];
