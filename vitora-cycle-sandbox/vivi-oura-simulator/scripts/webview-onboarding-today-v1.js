(() => {
  if (window.__vitoraOnboardingTodayLoopV1) return;
  window.__vitoraOnboardingTodayLoopV1 = true;

  const ONBOARDING_KEY = "vivi:prediction:onboardingV1";
  const ONBOARDING_VERSION = "body-profile-content-v2";
  const SIGNAL_KEY = "vivi:prediction:signalsV1";
  const PERMISSION_KEY = "vivi:prediction:permissionsV1";
  const FEEDBACK_KEY = "vivi:prediction:feedbackV1";
  const BODY_PROFILE_KEY = "vivi:user:bodyProfileV1";
  const CONTENT_KEY = "vivi:content:recommendationV1";

  let genTimer = null;
  let readTimer = null;
  let planTimer = null;
  let pickerDrag = null;
  let suppressPickerClick = false;

  const state = {
    page: "entry",
    step: "entry",
    stage: "confirm",
    genStep: 0,
    readStep: 0,
    planCardIndex: 0,
    toast: false,
    healthPermission: "not_requested",
    healthSkippedFrom: null,
    onboardingVersion: ONBOARDING_VERSION,
    name: "",
    phone: "",
    code: "",
    consent: false,
    loginProvider: null,
    goal: "sleep",
    bodyTiming: "before_period",
    sleepReminderHour: 21,
    sleepReminderMinute: 30,
    sleepPattern: "onset",
    sleepFrequency: "3_4",
    sleepDuration: "weeks",
    sleepImpact: "medium",
    sleepTriggers: ["active_mind", "pre_period"],
    pmsSignals: ["sleep"],
    pmsNote: "",
    painLevel: 3,
    periodDay: 15,
    periodLength: 8,
    birthYear: new Date().getFullYear() - 28,
    cycleDay: 24,
    cycleLen: 28,
    periodLen: 5,
    pain: 3,
    flow: "medium",
    pms: ["fatigue", "mood"],
    sleepIssue: "wake",
    screenBeforeBed: "high",
    stress: "high",
    bodySleep: "L",
    bodyCycle: "T",
    bodyStress: "N",
    bodyFocus: "J",
    bodyEnergy: "C",
    health: true,
    notification: true,
    phoneBehavior: true,
    location: true,
    background: true,
  };

  const readRows = [
    ["self", "自填档案", "周期、睡眠、压力和目标"],
    ["health", "mock 健康数据", "睡眠、步数、心率、HRV、体温 proxy"],
    ["phone", "mock 手机行为", "首次/末次使用、通知密度、App 切换"],
    ["env", "位置与日光", "天气、太阳方向、晨间户外 proxy"],
    ["feedback", "本地反馈", "完成、喜欢、太强、想轻一点"],
  ];

  const permissionCopy = {
    notification: ["通知权限", "午后恢复、睡前修复、周期确认"],
    health: ["健康数据", "睡眠、步数、心率、HRV、体温/呼吸，V1 用 mock 展示"],
    phoneBehavior: ["手机行为", "首次/末次使用、夜间使用、通知密度、App 切换，V1 用 mock 展示"],
    location: ["位置/日光", "晨间太阳方向和天气，V1 用 mock 展示"],
    background: ["后台刷新", "每日 nowcast / refresh / forecast，V1 本地模拟"],
  };

  const bodyArchetypes = [
    ["D-S-B-I-V", "astra_leopard", "太阳豹", "Astra Leopard", "高能快充型身体", ["恢复快", "抗压强", "行动力高"], ["容易透支自己", "忽略休息信号"], ["high", 25, ["focus", "active"], "直接、清晰、少废话"]],
    ["L-T-N-J-C", "bloom_deer", "月雾小鹿", "Bloom Deer", "敏感低耗型身体", ["身体灵敏", "能捕捉细微信号", "适合温柔节奏"], ["易受周期和压力影响", "高刺激内容容易过载"], ["low", 8, ["breath", "sleep", "low_stim"], "温和、保护恢复窗口"]],
    ["D-T-B-J-V", "crest_dolphin", "潮汐海豚", "Crest Dolphin", "顺势爆发型身体", ["能量高", "适合顺势推进", "恢复弹性好"], ["状态波动明显", "多任务切换会放大消耗"], ["medium", 20, ["soundscape", "focus", "cycle"], "先看窗口，再安排强度"]],
    ["L-S-N-I-C", "dusk_owl", "夜光猫头鹰", "Dusk Owl", "慢热深专注型身体", ["深度专注强", "适合安静长线任务", "节奏稳定"], ["启动慢", "夜间兴奋后容易影响睡眠"], ["low", 25, ["focus", "sleep", "quiet"], "减少打扰，保护进入状态的时间"]],
    ["D-S-N-J-V", "ember_fox", "烟花狐狸", "Ember Fox", "创意跳切型身体", ["表达欲强", "创意反应快", "短时爆发好"], ["容易分心", "压力一高就切换过密"], ["medium", 15, ["focus", "breath", "creative"], "短任务、清边界、快反馈"]],
    ["L-T-B-I-C", "frost_whale", "雪地鲸鱼", "Frost Whale", "安静深恢复型身体", ["安静", "恢复力好", "适合深沉慢节奏"], ["周期敏感", "高强度社交后恢复变慢"], ["low", 18, ["sleep", "meditation", "cycle"], "低刺激、深恢复、慢推进"]],
    ["D-T-N-I-V", "garnet_hawk", "玫瑰猎鹰", "Garnet Hawk", "高敏高爆发型身体", ["标准高", "爆发力强", "目标感清晰"], ["压力敏感", "容易把恢复窗口压掉"], ["medium", 25, ["focus", "breath", "recovery"], "保留挑战，但先设恢复边界"]],
    ["L-S-B-J-C", "hush_sloth", "云朵树懒", "Hush Sloth", "低耗稳定续航型身体", ["低消耗", "稳定", "适合慢积累"], ["启动偏慢", "容易拖到能量更低再行动"], ["low", 10, ["morning", "breath", "light_walk"], "低门槛、先开始、少压迫"]],
  ];

  function esc(value) {
    return String(value == null ? "" : value).replace(/[&<>"']/g, (c) => ({
      "&": "&amp;",
      "<": "&lt;",
      ">": "&gt;",
      '"': "&quot;",
      "'": "&#39;",
    })[c]);
  }

  function readJson(key, fallback) {
    try {
      const raw = localStorage.getItem(key);
      return raw ? JSON.parse(raw) : fallback;
    } catch (_) {
      return fallback;
    }
  }

  function writeJson(key, value) {
    try {
      localStorage.setItem(key, JSON.stringify(value));
    } catch (_) {}
  }

  function hasHealthSummaryDeepLink() {
    try {
      const params = new URLSearchParams(window.location.search || "");
      if (params.get("healthSummary") || params.get("openHealthSummary")) return true;
    } catch (_) {}
    const hash = String(window.location.hash || "").replace(/^#/, "");
    return hash.indexOf("health-summary") === 0;
  }

  function hasOnboardingDeepLink() {
    try {
      const params = new URLSearchParams(window.location.search || "");
      if (params.get("onboarding") === "1" || params.get("showOnboarding") === "1") return true;
    } catch (_) {}
    const hash = String(window.location.hash || "").replace(/^#/, "");
    return hash.indexOf("onboarding") === 0;
  }

  function host() {
    return document.querySelector(".phone") || document.getElementById("app") || document.body;
  }

  function todayIso() {
    const d = new Date();
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
  }

  function clamp(value, min, max) {
    return Math.max(min, Math.min(max, Number(value) || 0));
  }

  function sourceLabel(sources) {
    return (sources || [])
      .filter(Boolean)
      .filter((item, index, arr) => arr.indexOf(item) === index)
      .map((source) => source === "measured" ? "测量" : source === "inferred" ? "推断" : source === "self_report" ? "自填" : "mock")
      .join("/");
  }

  function permissions() {
    return {
      notification: !!state.notification,
      health: !!state.health,
      phoneBehavior: !!state.phoneBehavior,
      location: !!state.location,
      background: !!state.background,
    };
  }

  function permissionSummary(perms = readJson(PERMISSION_KEY, permissions())) {
    const enabled = Object.keys(permissionCopy).filter((key) => perms[key]);
    const missing = Object.keys(permissionCopy).filter((key) => !perms[key]);
    return { enabled, missing };
  }

  function bodyDimensions() {
    return {
      sleep: state.bodySleep === "D" ? "D" : "L",
      cycle: state.bodyCycle === "S" ? "S" : "T",
      stress: state.bodyStress === "B" ? "B" : "N",
      focus: state.bodyFocus === "I" ? "I" : "J",
      energy: state.bodyEnergy === "V" ? "V" : "C",
    };
  }

  function bodyCode(dimensions = bodyDimensions()) {
    return [dimensions.sleep, dimensions.cycle, dimensions.stress, dimensions.focus, dimensions.energy].join("-");
  }

  function bodyDistance(a, b) {
    const aa = String(a || "").split("-");
    const bb = String(b || "").split("-");
    return aa.reduce((sum, value, index) => sum + (value === bb[index] ? 0 : 1), 0);
  }

  function archetypeObject(row, rawCode, dimensions, exact) {
    return {
      bodyCode: row[0],
      rawCode,
      archetypeId: row[1],
      zhName: row[2],
      enName: row[3],
      oneLine: row[4],
      dimensions,
      traits: row[5],
      risks: row[6],
      recommendationBiases: {
        intensity: row[7][0],
        defaultMinutes: row[7][1],
        contentTypes: row[7][2],
        tone: row[7][3],
      },
      matchedExactly: exact,
    };
  }

  function buildBodyProfileFromOnboarding() {
    const dimensions = bodyDimensions();
    const rawCode = bodyCode(dimensions);
    const exact = bodyArchetypes.find((row) => row[0] === rawCode);
    const nearest = exact || bodyArchetypes.slice().sort((a, b) => bodyDistance(rawCode, a[0]) - bodyDistance(rawCode, b[0]))[0];
    return archetypeObject(nearest, rawCode, dimensions, !!exact);
  }

  function writeBodyProfile() {
    const profile = buildBodyProfileFromOnboarding();
    writeJson(BODY_PROFILE_KEY, profile);
    return profile;
  }

  function syncFlowAnswersForPrediction() {
    state.cycleDay = clamp(state.periodDay || state.cycleDay || 24, 1, 45);
    state.periodLen = clamp(state.periodLength || state.periodLen || 5, 2, 12);
    state.pain = clamp(state.painLevel || state.pain || 3, 0, 10);
    state.goal = state.goal === "body" ? "cycle" : state.goal === "training" ? "focus" : state.goal;
    const triggerSet = new Set(state.sleepTriggers || []);
    state.sleepIssue =
      state.sleepPattern === "wake" || state.sleepPattern === "non_restorative" ? "wake" :
      state.sleepPattern === "early" ? "early" :
      state.sleepPattern === "onset" || state.sleepPattern === "shift" ? "hard" :
      "stable";
    state.screenBeforeBed = triggerSet.has("screen") ? "high" : triggerSet.has("active_mind") ? "medium" : "low";
    state.stress = triggerSet.has("stress") || triggerSet.has("anxiety") ? "high" : "medium";
    const pms = new Set(state.pms || []);
    (state.pmsSignals || []).forEach((value) => {
      if (value === "fatigue") pms.add("fatigue");
      if (value === "swelling") pms.add("bloating");
      if (value === "sleep" || value === "appetite") pms.add("mood");
    });
    state.pms = Array.from(pms);
    if (state.healthPermission === "denied") state.health = false;
    if (state.healthPermission === "granted") state.health = true;
  }

  function sourcesText(stateObj) {
    if (!stateObj || !stateObj.states) return "自填 / mock / 推断";
    const list = []
      .concat(stateObj.states.sleep.source || [])
      .concat(stateObj.states.cycle.source || [])
      .concat(stateObj.states.focus.source || [])
      .concat(stateObj.states.stress.source || [])
      .concat(stateObj.states.morning.source || []);
    return list
      .map((source) => source === "measured" ? "测量" : source === "inferred" ? "推断" : source === "self_report" ? "自填" : "mock")
      .filter((label, index, arr) => arr.indexOf(label) === index)
      .join(" / ");
  }

  function composeDailyContent(stateObj, profile = readJson(BODY_PROFILE_KEY, null) || writeBodyProfile()) {
    const prediction = stateObj || currentPrediction();
    const p = prediction || { today_score: 80, confidence: "medium", states: {}, primary_action: { title: "开始今日恢复", reason: "今日状态需要一个主动作", session: "today-journey", push: "先做一个主动作。" } };
    const s = p.states || {};
    const bias = profile.recommendationBiases || { intensity: "medium", defaultMinutes: 15, contentTypes: ["breath"], tone: "稳定节奏" };
    const low = bias.intensity === "low";
    const primary = p.primary_action || { title: "开始今日恢复", reason: "今日状态需要一个主动作", session: "today-journey", push: "先做一个主动作。" };
    const pagePushes = [
      { page: "today", title: `今日 ${p.today_score} 分，${p.confidence} 置信度`, reason: `${profile.zhName}更适合${bias.tone}；今天先执行一个主动作：${primary.title}。`, source: `来源：${sourcesText(p)}；档案：${profile.rawCode}`, cta: primary.title, targetSession: primary.session },
      { page: "sleep", title: low ? "今晚先做低刺激睡眠修复" : "今晚保留睡眠修复窗口", reason: `睡眠 ${s.sleep ? s.sleep.score : 70} 分；${s.sleep ? (s.sleep.drivers_bad || []).join(" / ") : "睡眠连续性需要观察"}。`, source: "睡眠、夜醒、睡前手机和身体档案共同决定时长。", cta: low ? `开始 ${Math.min(bias.defaultMinutes, 18)} 分钟睡眠修复` : "开始睡眠修复", targetSession: "sleep-dream-brown-18" },
      { page: "cycle", title: `${s.cycle && s.cycle.phase_label ? s.cycle.phase_label : "周期"}低刺激窗口`, reason: `${profile.zhName}的周期建议只调整刺激强度，不压过压力/睡眠急迫信号。`, source: "来自经期自填、症状记录和历史周期窗口。", cta: "开始低刺激恢复", targetSession: "cycle-luteal-soft-10" },
      { page: "focus", title: low ? "先做 15 分钟单任务" : "先做 25 分钟单任务", reason: `专注 ${s.focus ? s.focus.score : 64} 分；${s.focus ? (s.focus.drivers_bad || []).join(" / ") : "切换成本偏高"}。`, source: "来自 App 切换、通知密度、短会话比例和反馈历史。", cta: low ? "开始 15 分钟专注" : "开始 25 分钟专注", targetSession: "focus-afternoon-25" },
      { page: "stress", title: "先把身体从紧绷切回来", reason: `抗压 ${s.stress ? s.stress.score : 50} 分；${s.stress ? (s.stress.drivers_bad || []).join(" / ") : "压力负荷偏高"}。`, source: "来自睡眠债、手机拾起密度、通知和碎片化 proxy。", cta: low ? "开始 3 分钟延长呼气" : "开始 4 分钟箱式呼吸", targetSession: "emotion-breath-3" },
      { page: "morning", title: "晨间启动用低门槛动作", reason: `晨间 ${s.morning ? s.morning.score : 72} 分；先用日光或轻走启动。`, source: "来自首次使用、日光/天气和晨间户外 proxy。", cta: "开始找太阳", targetSession: "morning-sun-map" },
      { page: "charge", title: "今晚声场按身体档案降刺激", reason: `${profile.enName} 推荐偏好：${(bias.contentTypes || []).join(" / ")}。`, source: "来自身体动物档案、今日状态和内容反馈。", cta: low ? "打开低刺激声场" : "打开今日声场", targetSession: "coast-night-sound" },
      { page: "health", title: "健康详情已关联今日档案", reason: `历史页会展示 ${profile.zhName}、当日预测分、推荐原因和完成反馈。`, source: "来自本地 bodyProfile、prediction history 和 feedback history。", cta: "查看健康详情历史", targetSession: "health-summary-history" },
    ];
    const content = {
      date: p.date || todayIso(),
      bodyProfile: profile,
      primaryAction: primary,
      pagePushes,
      evidence: [`身体档案：${profile.rawCode}｜${profile.zhName} ${profile.enName}`, `推荐偏好：${bias.tone}`],
      sources: sourcesText(p).split(" / ").filter(Boolean),
      confidence: p.confidence || "medium",
    };
    writeJson(CONTENT_KEY, content);
    return content;
  }

  function buildSignals() {
    syncFlowAnswersForPrediction();
    const stress = state.stress === "high" ? 1 : state.stress === "medium" ? 0.55 : 0.22;
    const sleepMinutes = state.sleepIssue === "wake" ? 412 : state.sleepIssue === "early" ? 398 : state.sleepIssue === "hard" ? 426 : 452;
    const latePhone = state.screenBeforeBed === "high" ? 72 : state.screenBeforeBed === "medium" ? 42 : 18;
    const symptomLoad = clamp(state.pain, 0, 10);
    const profile = writeBodyProfile();
    return {
      user_id: "local-onboarding",
      date: todayIso(),
      sources: ["self_report", "mock", "inferred"],
      profile,
      health: {
        sleepMinutes,
        deepSleepMinutes: state.sleepIssue === "wake" ? 68 : 84,
        lightSleepMinutes: Math.max(260, sleepMinutes - 92),
        awakenings: state.sleepIssue === "wake" ? 3 : 1,
        steps: Math.round(5200 + (1 - stress) * 2200),
        hrv: Math.round(34 + (1 - stress) * 18),
        restingHeartRate: Math.round(66 + stress * 7),
        skinTempDelta: state.cycleDay > 20 ? 0.18 : 0.04,
      },
      phone: {
        lastUnlock: state.screenBeforeBed === "high" ? "00:48" : "23:34",
        firstUnlock: "07:58",
        latePhoneMinutes: latePhone,
        appSwitchesPerHour: Math.round((5.2 + stress * 5.4) * 10) / 10,
        notificationCount: Math.round(18 + stress * 34),
        pickups: Math.round(54 + stress * 52),
        shortSessionRatio: Math.round((0.28 + stress * 0.27) * 100) / 100,
        socialShare: Math.round((0.18 + stress * 0.2) * 100) / 100,
      },
      cycle: {
        cycleDay: state.cycleDay,
        usualCycleLength: state.cycleLen,
        periodLength: state.periodLen,
        flow: state.flow,
        symptoms: {
          cramps: Math.round(symptomLoad / 2),
          fatigue: state.pms.includes("fatigue") ? 3 : 1,
          mood: state.pms.includes("mood") ? 3 : 1,
          bloating: state.pms.includes("bloating") ? 2 : 1,
          flow: state.flow === "heavy" ? 3 : state.flow === "medium" ? 2 : 1,
        },
      },
      selfReport: {
        goal: state.goal,
        mood: state.stress === "high" ? "tense" : "neutral",
        fatigue: state.pms.includes("fatigue") ? 3 : 1,
        caffeineAfter14: false,
        mealGapHours: state.stress === "high" ? 5.8 : 4.2,
        sleepIssue: state.sleepIssue,
      },
      environment: {
        sunAzimuth: 126,
        weather: "cloudy",
        morningOutdoorMinutes: state.location ? 4 : 0,
      },
      feedback: {
        history: readJson(FEEDBACK_KEY, []),
      },
      permissions: permissions(),
    };
  }

  function applyPrediction(signals) {
    const mcp = window.VitoraDailyPredictionMCP;
    if (mcp && mcp.ingest_user_signals) mcp.ingest_user_signals({ userId: "local-onboarding", signals });
    writeJson(SIGNAL_KEY, signals);
    writeJson(PERMISSION_KEY, permissions());
    const profile = signals.profile || writeBodyProfile();
    const prediction = mcp && mcp.predict_daily_state ? mcp.predict_daily_state({ userId: "local-onboarding", date: signals.date, signals }) : null;
    const content = mcp && mcp.compose_daily_content ? mcp.compose_daily_content({ state: prediction, signals, profile }) : composeDailyContent(prediction, profile);
    writeJson(CONTENT_KEY, content);
    try {
      if (prediction && typeof pdApplyPredictionToMetricsV1 === "function") pdApplyPredictionToMetricsV1(prediction);
    } catch (_) {}
    try {
      if (prediction) {
        window.predictionStateV1 = prediction;
        predictionStateV1 = prediction;
      }
    } catch (_) {}
    return prediction;
  }

  function currentPrediction() {
    try {
      if (window.VitoraDailyPredictionMCP && window.VitoraDailyPredictionMCP.state) return window.VitoraDailyPredictionMCP.state();
    } catch (_) {}
    try {
      if (typeof predict_daily_state === "function") return predict_daily_state({});
    } catch (_) {}
    return null;
  }

  function loadState() {
    const stored = readJson(ONBOARDING_KEY, null);
    const perms = readJson(PERMISSION_KEY, null);
    if (stored) {
      const currentVersion = stored.onboardingVersion === ONBOARDING_VERSION;
      Object.assign(state, stored, {
        onboardingVersion: ONBOARDING_VERSION,
        page: currentVersion && stored.page ? stored.page : "entry",
        step: currentVersion && stored.step ? stored.step : "entry",
        stage: currentVersion && stored.stage ? stored.stage : "confirm",
      });
      if (!currentVersion) Object.assign(state, { page: "entry", step: "entry", stage: "confirm", genStep: 0, readStep: 0, planCardIndex: 0, consent: false });
    }
    if (perms) Object.assign(state, perms);
  }

  function resetOnboardingStorage() {
    [ONBOARDING_KEY, SIGNAL_KEY, PERMISSION_KEY, BODY_PROFILE_KEY, CONTENT_KEY].forEach((key) => {
      try { localStorage.removeItem(key); } catch (_) {}
    });
    Object.assign(state, {
      page: "entry",
      step: "entry",
      stage: "confirm",
      onboardingVersion: ONBOARDING_VERSION,
      consent: false,
      genStep: 0,
      readStep: 0,
      planCardIndex: 0,
      toast: false,
      healthPermission: "not_requested",
      healthSkippedFrom: null,
    });
  }

  function ensureLayer() {
    const root = host();
    let layer = document.getElementById("vitoraOnboardingLayerV1");
    if (!layer) {
      layer = document.createElement("section");
      layer.id = "vitoraOnboardingLayerV1";
      layer.className = "vob-onboarding-layer-v1";
      layer.setAttribute("aria-hidden", "true");
      root.appendChild(layer);
    }
    return layer;
  }

  const pages = ["entry", "goal", "questions", "sleep_reminder", "health_intro", "health_permission", "cycle"];
  const legacyProgressPages = ["entry", "goal", "questions", "cycle"];
  const healthFlowPages = ["sleep_reminder", "health_intro", "health_permission"];
  const labels = {
    goal: { sleep: "改善睡眠", focus: "稳定专注", body: "身体线索", training: "ADHD修复" },
    bodyTiming: { before_period: "经前几天", during_period: "经期前两天", before_sleep: "睡前", daytime: "白天中段", after_training: "运动后" },
    sleepPattern: { onset: "入睡困难", wake: "夜醒多", early: "早醒", non_restorative: "睡够仍累", shift: "作息漂移" },
    sleepFrequency: { "0_1": "0-1晚", "2": "每周2晚", "3_4": "每周3-4晚", "5_plus": "5晚以上" },
    sleepDuration: { days: "2周内", weeks: "2-4周", months: "1-3个月", chronic: "3个月以上" },
    sleepImpact: { mild: "轻微", medium: "中等", clear: "明显" },
    sleepTriggers: { stress: "压力过大", active_mind: "睡前清醒", anxiety: "焦虑紧绷", screen: "屏幕太晚", caffeine: "咖啡因偏晚", pre_period: "经前不适" },
    pmsSignals: { swelling: "浮肿", sleep: "睡眠变化", appetite: "食欲变化", fatigue: "疲惫" },
  };
  const genSteps = ["经前情绪波动较大", "经期中等疼痛，影响日常生活", "睡眠质量一般，夜间偶有醒来", "白天偶尔感到疲惫"];
  const readingRows = [
    { title: "读取睡眠窗口", body: "根据入睡时间、夜醒频率和白天影响整理恢复边界。" },
    { title: "匹配周期模型", body: "把最近一次经期、痛感和经前反应合并成身体线索。" },
    { title: "校准呼吸节奏", body: "沿用刚才的吸气/呼气节奏，估算今晚降刺激入口。" },
    { title: "生成专属方案", body: "只在本机汇总你的建档答案，不上传，也不生成诊断。" },
  ];
  const planCards = [
    { title: "深睡准备", body: "睡前 28 分钟", theme: "rest" },
    { title: "经前安抚", body: "48 小时预警提示", theme: "sleep" },
    { title: "呼吸节奏", body: "睡前降刺激练习", theme: "energy" },
    { title: "经后营养", body: "结束后补充提示", theme: "tool" },
  ];
  const pickerValues = {
    sleepReminderHour: [18, 19, 20, 21, 22, 23, 0, 1, 2],
    sleepReminderMinute: Array.from({ length: 12 }, (_, index) => index * 5),
    periodDay: Array.from({ length: 31 }, (_, index) => index + 1),
    periodLength: Array.from({ length: 11 }, (_, index) => index + 2),
  };

  function flowApp() {
    return ensureLayer().querySelector("[data-vob-flow-app]");
  }

  function escapeAttr(value) {
    return String(value || "").replace(/&/g, "&amp;").replace(/"/g, "&quot;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
  }

  function selectedClass(key, value) {
    const current = state[key];
    if (Array.isArray(current)) return current.includes(value) ? " is-selected" : "";
    return current === value ? " is-selected" : "";
  }

  function label(key, value) {
    return (labels[key] && labels[key][value]) || value;
  }

  function progressMarkup(mode = "legacy") {
    const flow = mode === "health" ? pages : legacyProgressPages;
    const idx = flow.indexOf(state.page);
    return `<div class="progress${mode === "health" ? " is-health" : ""}">${flow.map((_, i) => `<span style="--fill:${i <= idx ? 100 : 0}%"></span>`).join("")}</div>`;
  }

  function iosStatus() {
    return `<div class="ios-status" aria-hidden="true"><div class="ios-time">18:13</div><div class="ios-icons"><span class="cell-bars"><i></i><i></i><i></i><i></i></span><span class="wifi-mark"></span><span class="battery-mark"></span></div></div>`;
  }

  function healthTopbar() {
    const showSkip = state.page !== "health_permission";
    return `${iosStatus()}<button class="health-back" data-action="back" aria-label="返回">‹</button>${progressMarkup("health")}${showSkip ? `<button class="skip" data-action="skip-health">跳过</button>` : ""}`;
  }

  function topbar() {
    if (healthFlowPages.includes(state.page)) return healthTopbar();
    const canBack = state.page !== "entry" || state.stage !== "confirm";
    return `<div class="topbar"><button class="back" data-action="back" ${canBack ? "" : "disabled"} aria-label="返回">‹</button><div class="brand">Vitora</div></div>${progressMarkup()}`;
  }

  function screen(inner, footer = "") {
    state.step = state.page;
    return `<section class="screen screen-${state.page} stage-${state.stage}">${topbar()}${inner}${footer}</section>`;
  }

  function entryScreen() {
    return screen(`<div class="entry-title"><h1 class="title">先听见身体<br />的回声</h1><p class="lead">建立一份只保存在本机的睡眠、经期和恢复档案，再给出今日计划。</p></div><div class="entry-actions"><button class="pill${selectedClass("loginProvider", "wechat")}" data-action="login" data-value="wechat">微信登录</button><button class="pill${selectedClass("loginProvider", "alipay")}" data-action="login" data-value="alipay">支付宝登录</button></div>`);
  }

  function goalButton(value, title, body) {
    return `<button class="choice${selectedClass("goal", value)}" data-action="set" data-key="goal" data-value="${value}"><strong>${title}</strong><span>${body}</span></button>`;
  }

  function goalScreen() {
    return screen(`<div class="goal-title"><h1 class="title">先选择你想<br />关注的事</h1></div><div class="glass-panel goal-panel"><p class="panel-label">开始定制你的私人身体助理！</p><div class="goal-grid">${goalButton("sleep", "改善睡眠", "入睡、夜醒、醒后恢复")}${goalButton("focus", "稳定专注", "情绪、压力、白天能量")}${goalButton("body", "身体线索", "经期、痛感、经前反应")}${goalButton("training", "恢复强度", "运动负荷和恢复节奏")}</div></div>`, `<div class="footer"><button class="primary" data-action="next">进入对应问题</button></div>`);
  }

  function chip(key, value, multi = false) {
    return `<button class="chip${selectedClass(key, value)}" data-action="${multi ? "toggle" : "set"}" data-key="${key}" data-value="${value}">${label(key, value)}</button>`;
  }

  function wide(key, value, title, body) {
    return `<button class="wide-choice${selectedClass(key, value)}" data-action="set" data-key="${key}" data-value="${value}"><strong>${title}</strong><span>${body}</span></button>`;
  }

  function questionsScreen() {
    return screen(`<div class="question-title"><h1 class="title">${state.goal === "sleep" ? "定制睡眠模型" : "定制身体模型"}</h1></div><div class="glass-panel question-panel"><div class="sleep-time"><span>你通常几点入睡？</span><strong>23:30 <em>⌄</em></strong></div><div class="scroll"><p class="field-heading">先看时间点、经期感受和当前目标</p><div class="chip-row">${chip("bodyTiming", "before_period")}${chip("bodyTiming", "during_period")}${chip("bodyTiming", "before_sleep")}${chip("bodyTiming", "daytime")}${chip("bodyTiming", "after_training")}</div><div class="group"><p class="field-heading">你的睡眠更像哪一种？</p><div class="wide-list">${wide("sleepPattern", "onset", "入睡困难", "躺下后脑子还很清醒")}${wide("sleepPattern", "wake", "夜醒多", "半夜醒来后很难再睡稳")}${wide("sleepPattern", "early", "早醒", "比计划更早醒，白天容易累")}${wide("sleepPattern", "non_restorative", "睡够仍累", "时长够，但恢复感不够")}${wide("sleepPattern", "shift", "作息漂移", "越睡越晚，起床时间跟着漂")}</div></div><div class="group"><p class="field-heading">最近出现频率</p><div class="chip-row">${chip("sleepFrequency", "0_1")}${chip("sleepFrequency", "2")}${chip("sleepFrequency", "3_4")}${chip("sleepFrequency", "5_plus")}</div></div><div class="group"><p class="field-heading">持续多久了？</p><div class="chip-row">${chip("sleepDuration", "days")}${chip("sleepDuration", "weeks")}${chip("sleepDuration", "months")}${chip("sleepDuration", "chronic")}</div></div><div class="group"><p class="field-heading">白天影响</p><div class="chip-row">${chip("sleepImpact", "mild")}${chip("sleepImpact", "medium")}${chip("sleepImpact", "clear")}</div></div><div class="group"><p class="field-heading">睡前触发因素</p><div class="chip-row">${chip("sleepTriggers", "stress", true)}${chip("sleepTriggers", "active_mind", true)}${chip("sleepTriggers", "anxiety", true)}${chip("sleepTriggers", "screen", true)}${chip("sleepTriggers", "pre_period", true)}</div></div></div></div>`, `<div class="footer"><button class="primary" data-action="next">继续</button></div>`);
  }

  function padTime(value) {
    return String(value).padStart(2, "0");
  }

  function wrapIndex(index, length) {
    return (index + length) % length;
  }

  function pickerLabel(key, value) {
    if (key === "sleepReminderHour" || key === "sleepReminderMinute") return padTime(value);
    if (key === "periodDay") return `${value}号`;
    if (key === "periodLength") return `${value}天`;
    return value;
  }

  function pickerAdjacent(key) {
    const values = pickerValues[key];
    const current = Number(state[key]);
    const index = Math.max(0, values.indexOf(current));
    return [values[wrapIndex(index - 1, values.length)], values[index], values[wrapIndex(index + 1, values.length)]];
  }

  function pickerColumn(key) {
    return `<div class="picker-column" data-picker-key="${key}">${pickerAdjacent(key).map((value, index) => `<button class="picker-item${index === 1 ? " is-current" : ""}" data-action="picker-set" data-key="${key}" data-value="${value}">${pickerLabel(key, value)}</button>`).join("")}</div>`;
  }

  function compactPicker(key, labelText) {
    return `<div class="compact-picker">${pickerColumn(key)}<span class="compact-picker-label">${labelText}</span></div>`;
  }

  function cycleEndDay() {
    return ((Number(state.periodDay) + Number(state.periodLength) - 2) % 31) + 1;
  }

  function sleepReminderScreen() {
    return screen(`<div class="sleep-reminder-copy"><h1>你希望每天能在<br />几点入睡?</h1><p>研究表明，规律的入睡时间可显著提升睡眠质量。</p></div><div class="wheel-panel"><p class="wheel-label">设置入睡提醒时间</p><div class="time-wheel" aria-label="入睡提醒时间 ${padTime(state.sleepReminderHour)}:${padTime(state.sleepReminderMinute)}">${pickerColumn("sleepReminderHour")}<span class="picker-colon">:</span>${pickerColumn("sleepReminderMinute")}</div></div><p class="sleep-reminder-note">不用担心，后续可随时修改</p>`, `<div class="footer"><button class="primary" data-action="next">继续</button></div>`);
  }

  function healthIntroScreen() {
    return screen(`<div class="health-intro-copy"><h1>连接 Apple 健康</h1><p>为了更及时、完整和准确地了解你的身心状态，潮汐需要你授权以访问 Apple 健康中的相关数据。</p></div><div class="health-visual" aria-hidden="true"><div class="sleep-data-card"><h2><span>昨日睡眠</span><span>◑ 86</span></h2><div class="sleep-bars"><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i></div><div class="sleep-line"></div><div class="sleep-line short"></div></div><div class="health-icon-float">♥</div></div><p class="health-intro-note">我们会确保你的数据隐私与安全。</p>`, `<div class="footer"><button class="primary" data-action="next">继续</button></div>`);
  }

  function permissionRow(icon, title) {
    return `<button class="permission-row" data-action="health-grant"><span class="permission-emoji">${icon}</span><span>${title}</span><span class="ios-toggle"></span></button>`;
  }

  function healthPermissionScreen() {
    return screen(`<div class="permission-sheet"><div class="permission-nav"><button class="permission-deny" data-action="health-deny">不允许</button><strong class="permission-title">访问健康数据</strong><button class="permission-allow" data-action="health-grant">允许</button></div><div class="permission-body"><div class="permission-icon">♥</div><h1>健康</h1><p class="permission-copy">“潮汐”想要访问并更新你的健康数据。</p><button class="permission-all" data-action="health-grant">全部打开</button><p class="permission-section-title">允许 “潮汐” 写入</p><div class="permission-list">${permissionRow("🔥", "活动能量")}${permissionRow("🛏", "睡眠")}${permissionRow("🔥", "体能训练")}</div></div></div>`);
  }

  function mini(key, value) {
    return `<button class="mini-chip${selectedClass(key, value)}" data-action="toggle" data-key="${key}" data-value="${value}">${label(key, value)}</button>`;
  }

  function cycleScreen() {
    if (state.stage === "generating") return generatingScreen();
    if (state.stage === "reading") return readingScreen();
    if (state.stage === "plan") return planScreen();
    if (state.stage === "personality") return personalityScreen();
    if (state.stage === "result") return resultScreen();
    return screen(`<div class="cycle-title"><h1 class="title">定制周期模型</h1></div><div class="glass-panel cycle-model-panel"><div class="cycle-scroll"><div class="cycle-group"><span class="cycle-group-title">经前反应</span><div class="chip-row">${mini("pmsSignals", "swelling")}${mini("pmsSignals", "sleep")}${mini("pmsSignals", "appetite")}${mini("pmsSignals", "fatigue")}</div><input class="pms-note-input" data-action="note" data-key="pmsNote" value="${escapeAttr(state.pmsNote)}" placeholder="（补充你的经前反应...）" /></div><div class="cycle-group"><span class="cycle-group-title">最近一次</span>${compactPicker("periodDay", "滚动选择经期日期")}<div class="cycle-reminder-stack"><p class="cycle-reminder is-strong">将为你设置为 ${state.periodDay} 号之前经前提醒跟踪。</p><p class="cycle-reminder">已为你打开经前 48 小时预警提示功能。</p></div></div><div class="cycle-group"><span class="cycle-group-title">痛经程度</span><span class="pain-stepper"><button data-action="step" data-key="painLevel" data-delta="-1" data-min="0" data-max="10">-</button><strong>${state.painLevel}</strong><button data-action="step" data-key="painLevel" data-delta="1" data-min="0" data-max="10">+</button></span></div><div class="cycle-group"><span class="cycle-group-title">持续几天</span>${compactPicker("periodLength", "滚动选择持续时间")}<div class="cycle-reminder-stack"><p class="cycle-reminder is-strong">预计本次经期在 ${cycleEndDay()} 号左右结束。</p><p class="cycle-reminder">已为你打开经后营养补充提示功能。</p></div></div><div class="cycle-group"><span class="cycle-group-title">已完成的身体线索</span><div class="cycle-summary"><span>经前反应：${state.pmsSignals.map((value) => label("pmsSignals", value)).join("、") || "暂未选择"}</span><span>补充描述：${state.pmsNote.trim() || "暂未补充"}</span><span>最近一次：${state.periodDay}号；痛经程度 ${state.painLevel}/10；持续 ${state.periodLength}天</span><span>提醒功能：经前 48 小时预警提示 + 经后营养补充提示已开启。</span></div></div></div></div>`, `<div class="footer"><button class="primary" data-action="generate">生成我的身体档案</button></div>`);
  }

  function generatingScreen() {
    return screen(`<div class="generating"><div class="breath"><span>吸气 / 呼气</span></div><h2 class="generate-title">生成专属模型中</h2><div class="gen-steps">${genSteps.map((item, index) => `<div class="gen-step ${index < state.genStep ? "is-done" : index === state.genStep ? "is-active" : ""}"><span class="dot"></span>${item}</div>`).join("")}</div></div>`);
  }

  function readingScreen() {
    return screen(`<div class="reading"><div class="reading-head"><h2 class="title">正在读取<br />身体数据</h2><p class="lead">Vitora 只读取这次建档里的本地答案，把睡眠、身体线索和呼吸节奏整理成第一版方案。</p></div><div class="glass-panel reading-panel">${readingRows.map((row, index) => `<div class="read-row ${index < state.readStep ? "is-done" : index === state.readStep ? "is-active" : ""}"><h3>${row.title}</h3><p>${row.body}</p></div>`).join("")}</div></div>`);
  }

  function planScreen() {
    return screen(`<div class="plan"><div class="plan-head"><h2 class="title">适合你的<br />先用卡片</h2><p class="lead">根据你的建档答案，先推一组今晚可执行的内容，让你提前进入使用场景。</p></div><ul class="plan-bullets"><li>深睡准备：更快进入睡前状态</li><li>经前安抚：提前 48 小时接住波动</li><li>经后营养：在结束后补足恢复节奏</li></ul><div class="plan-stack">${planCards.map((card, index) => { const slot = (index - state.planCardIndex + planCards.length) % planCards.length; return `<article class="plan-card slot-${slot} theme-${card.theme}"><div class="plan-visual"></div><div class="plan-copy"><strong>${card.title}</strong><span>${card.body}</span></div></article>`; }).join("")}</div><p class="plan-note">卡片会按顺序向前推送。这里是网页预览动效，不会发起真实登录或上传健康数据。</p></div>`, `<div class="footer"><button class="primary" data-action="result">领取定制结果卡片</button></div>`);
  }

  function personalityScreen() {
    return screen(`<div class="personality"><div class="personality-head"><h2 class="title">你是 O 型人格<br />（低精力人群）</h2><p class="lead">这些数据围成 O 型，是因为你的弱项集中在周期、睡眠和抗压恢复上。</p></div><div class="personality-type"><div class="o-ring"><strong>O型<br />人格</strong></div><div class="o-metric metric-cycle"><b>周期能量弱</b><span>经前反应 + 痛度 ${state.painLevel}/10</span></div><div class="o-metric metric-sleep"><b>睡眠恢复弱</b><span>${label("sleepPattern", state.sleepPattern)} · ${label("sleepFrequency", state.sleepFrequency)}</span></div><div class="o-metric metric-stress"><b>抗压能力弱</b><span>胸呼吸弱 · 睡前刺激高</span></div><div class="o-metric metric-pms"><b>经前波动明显</b><span>${state.pmsSignals.map((value) => label("pmsSignals", value)).join("、") || "待观察"}</span></div></div><div class="use-card-list"><span>适合先用：经前安抚卡 + 深睡准备卡</span><span>下一步会为你展示可提前使用的方案卡片</span></div></div>`, `<div class="footer"><button class="primary" data-action="plan">查看适合你的卡片</button></div>`);
  }

  function resultScreen() {
    return screen(`<div class="result"><div class="result-head"><h2 class="title">你的定制<br />结果卡片</h2><p class="lead">这张卡片会成为今日计划入口，帮助你提前代入今晚的使用节奏。</p></div><div class="final-share-card"><div class="final-card-hero"></div><h3>O型恢复卡</h3><p>适合先从睡前降刺激开始，再把经前线索和呼吸节奏放入今日计划。</p><div class="final-metrics"><div><strong>周期</strong><span>中度波动</span></div><div><strong>睡眠</strong><span>短休眠型</span></div><div><strong>抗压能力</strong><span>胸呼吸弱</span></div><div><strong>今晚建议</strong><span>${padTime(state.sleepReminderHour)}:${padTime(state.sleepReminderMinute)} 前降刺激</span></div></div></div></div>`, `<div class="footer"><button class="primary" data-action="complete">查看今日计划</button></div>`);
  }

  function currentScreenHtml() {
    if (state.page === "entry") return entryScreen();
    if (state.page === "goal") return goalScreen();
    if (state.page === "questions") return questionsScreen();
    if (state.page === "sleep_reminder") return sleepReminderScreen();
    if (state.page === "health_intro") return healthIntroScreen();
    if (state.page === "health_permission") return healthPermissionScreen();
    return cycleScreen();
  }

  function renderOnboarding() {
    const layer = ensureLayer();
    if (!layer.querySelector("[data-vob-flow-app]")) {
      layer.innerHTML = `<div class="video-layer" aria-hidden="true"><video src="./assets/onboarding/vitora-onboarding-full-background.mp4" autoplay muted loop playsinline></video></div><div class="veil" aria-hidden="true"></div><div class="vob-flow-app-v1" data-vob-flow-app></div>`;
    }
    const app = flowApp();
    if (app) {
      try {
        app.innerHTML = currentScreenHtml();
      } catch (error) {
        app.innerHTML = `<pre class="vob-runtime-error-v1">${esc(error && error.stack ? error.stack : error)}</pre>`;
      }
    }
    layer.classList.add("open");
    layer.setAttribute("aria-hidden", "false");
    host().classList.add("vob-onboarding-open");
  }

  function render() {
    renderOnboarding();
  }

  function clearTimers() {
    if (genTimer) window.clearInterval(genTimer);
    if (readTimer) window.clearInterval(readTimer);
    if (planTimer) window.clearInterval(planTimer);
    genTimer = null;
    readTimer = null;
    planTimer = null;
  }

  function openOnboarding(reset = false) {
    clearTimers();
    if (reset) {
      resetOnboardingStorage();
      writeJson(ONBOARDING_KEY, { ...state, onboardingVersion: ONBOARDING_VERSION, completed: false, reopenedAt: Date.now() });
    }
    renderOnboarding();
  }

  function closeOnboarding() {
    clearTimers();
    const layer = document.getElementById("vitoraOnboardingLayerV1");
    if (layer) {
      layer.classList.remove("open");
      layer.setAttribute("aria-hidden", "true");
    }
    host().classList.remove("vob-onboarding-open");
  }

  function nextPage() {
    const idx = pages.indexOf(state.page);
    if (idx < pages.length - 1) {
      state.page = pages[idx + 1];
      state.step = state.page;
      state.stage = "confirm";
      state.toast = false;
      clearTimers();
      render();
    }
  }

  function backPage() {
    clearTimers();
    state.toast = false;
    if (state.page === "cycle" && state.stage !== "confirm") {
      if (state.stage === "result") return startPlan();
      if (state.stage === "plan") return showPersonality();
      state.stage = "confirm";
      state.genStep = 0;
      state.readStep = 0;
      state.planCardIndex = 0;
      render();
      return;
    }
    if (state.page === "cycle" && state.healthPermission === "skipped" && state.healthSkippedFrom) {
      state.page = state.healthSkippedFrom;
      state.step = state.page;
      state.healthPermission = "not_requested";
      state.healthSkippedFrom = null;
      render();
      return;
    }
    const idx = pages.indexOf(state.page);
    if (idx > 0) {
      state.page = pages[idx - 1];
      state.step = state.page;
      state.stage = "confirm";
      render();
    }
  }

  function startGenerate() {
    clearTimers();
    state.stage = "generating";
    state.genStep = 0;
    render();
    genTimer = window.setInterval(() => {
      state.genStep += 1;
      if (state.genStep >= genSteps.length) {
        clearTimers();
        startReading();
        return;
      }
      render();
    }, 850);
  }

  function startReading() {
    clearTimers();
    state.stage = "reading";
    state.readStep = 0;
    render();
    readTimer = window.setInterval(() => {
      state.readStep += 1;
      if (state.readStep > readingRows.length) {
        clearTimers();
        showPersonality();
        return;
      }
      render();
    }, 620);
  }

  function startPlan() {
    clearTimers();
    state.stage = "plan";
    state.planCardIndex = 0;
    render();
    if (window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches) return;
    planTimer = window.setInterval(() => {
      state.planCardIndex = (state.planCardIndex + 1) % planCards.length;
      render();
    }, 1400);
  }

  function showPersonality() {
    clearTimers();
    state.stage = "personality";
    state.toast = false;
    render();
  }

  function showResult() {
    clearTimers();
    state.stage = "result";
    state.toast = false;
    render();
  }

  function enterCycleWithHealth(status) {
    clearTimers();
    state.healthPermission = status;
    if (status !== "skipped") state.healthSkippedFrom = null;
    state.page = "cycle";
    state.step = "cycle";
    state.stage = "confirm";
    state.toast = false;
    render();
  }

  function skipHealthFlow() {
    state.healthSkippedFrom = state.page;
    enterCycleWithHealth("skipped");
  }

  function setValue(key, value) {
    state[key] = value;
    state.toast = false;
    render();
  }

  function toggleValue(key, value) {
    const next = new Set(state[key] || []);
    if (next.has(value)) next.delete(value);
    else next.add(value);
    state[key] = Array.from(next);
    render();
  }

  function stepValue(key, delta, min, max) {
    state[key] = Math.max(min, Math.min(max, Number(state[key]) + Number(delta)));
    render();
  }

  function setPickerValue(key, value) {
    state[key] = Number(value);
    state.toast = false;
    render();
  }

  function stepPicker(key, delta) {
    const values = pickerValues[key];
    if (!values) return;
    const index = Math.max(0, values.indexOf(Number(state[key])));
    state[key] = values[wrapIndex(index + delta, values.length)];
    state.toast = false;
    render();
  }

  function goToday() {
    syncFlowAnswersForPrediction();
    const prediction = applyPrediction(buildSignals());
    writeJson(ONBOARDING_KEY, { ...state, onboardingVersion: ONBOARDING_VERSION, completed: true, completedAt: Date.now() });
    closeOnboarding();
    try {
      if (typeof switchTab === "function") switchTab("today");
    } catch (_) {}
    try {
      const store = typeof tbiStoreV1 === "function" ? tbiStoreV1() : (window.S = window.S || {});
      store.fixedTodayActiveV1 = "today";
      store.fixedTodayDetailV1 = false;
    } catch (_) {}
    try {
      if (prediction && typeof pdApplyPredictionToMetricsV1 === "function") pdApplyPredictionToMetricsV1(prediction);
    } catch (_) {}
    [0, 80, 240, 700].forEach((delay) => {
      setTimeout(() => {
        try {
          if (typeof ftRenderFixedTodayV1 === "function") ftRenderFixedTodayV1("today");
        } catch (_) {}
        ensureDataStripInToday();
      }, delay);
    });
  }

  function cardForSession(session) {
    if (session === "sleep-dream-brown-18") return "sleep";
    if (session === "focus-afternoon-25") return "focus";
    if (session === "emotion-breath-3") return "stress";
    if (session === "morning-sun-map") return "morning";
    if (session === "cycle-luteal-soft-10") return "cycle";
    return "today";
  }

  function pushRows(prediction = currentPrediction()) {
    const content = readJson(CONTENT_KEY, null);
    if (content && Array.isArray(content.pagePushes)) {
      const primarySession = content.primaryAction && (content.primaryAction.session || content.primaryAction.target);
      return content.pagePushes
        .filter((item) => ["today", "sleep", "cycle", "focus", "stress", "morning"].includes(item.page))
        .map((item) => [item.page, item.page.charAt(0).toUpperCase() + item.page.slice(1), `${item.title}。${item.reason}`, item.targetSession === primarySession || item.cta === (content.primaryAction && content.primaryAction.title)]);
    }
    const primary = prediction && prediction.primary_action ? cardForSession(prediction.primary_action.session || prediction.primary_action.target) : "today";
    return [
      ["today", "Today", `今日 ${prediction ? prediction.today_score : 80} 分，${prediction ? prediction.confidence : "medium"} 置信度。先做 ${((prediction && prediction.primary_action && prediction.primary_action.title) || "4 分钟呼吸")}。`, primary === "today"],
      ["sleep", "Sleep", "13:40 闭眼 12 分钟；昨晚夜醒偏多，今天不建议硬补咖啡。", primary === "sleep"],
      ["cycle", "Cycle", "黄体期低刺激窗口，下午减少高强度任务，补充温热饮食。", primary === "cycle"],
      ["focus", "Focus", "现在适合 25 分钟单任务；通知和切换偏高，先只推进一件事。", primary === "focus"],
      ["stress", "Stress", "压力负荷偏高，先做 4 分钟箱式呼吸。", primary === "stress"],
      ["morning", "Morning", "晨间启动偏慢，向太阳方向找窗边光或轻走 8 分钟。", primary === "morning"],
    ];
  }

  function dataStripHtml() {
    const prediction = currentPrediction();
    const perms = readJson(PERMISSION_KEY, permissions());
    const summary = permissionSummary(perms);
    const storedSignals = readJson(SIGNAL_KEY, buildSignals());
    const src = prediction && prediction.states
      ? sourceLabel([...(prediction.states.sleep.source || []), ...(prediction.states.cycle.source || []), ...(prediction.states.focus.source || []), ...(prediction.states.stress.source || []), ...(prediction.states.morning.source || [])])
      : sourceLabel(storedSignals.sources || ["self_report", "mock", "inferred"]);
    const missing = summary.missing.length ? summary.missing.map((key) => permissionCopy[key][0]).join("、") : "无缺失项";
    return `<div class="vob-data-strip-v1" data-vob-data-strip><div><strong>数据与后台</strong><span>来源 ${esc(src)} · 缺失项：${esc(missing)} · 推送${perms.notification ? "待模拟" : "未开启"}</span></div><button type="button" data-vob-open-data>查看</button></div>`;
  }

  function dataSheetHtml() {
    const prediction = currentPrediction();
    const perms = readJson(PERMISSION_KEY, permissions());
    const summary = permissionSummary(perms);
    const rows = Object.keys(permissionCopy).map((key) => {
      const copy = permissionCopy[key];
      return `<div class="vob-panel-row-v1"><div><b>${copy[0]}</b><span>${copy[1]}</span></div><em>${perms[key] ? "开启模拟" : "稍后"}</em></div>`;
    }).join("");
    const pushes = pushRows(prediction).map((row) => `<button class="vob-push-item-v1 ${row[3] ? "primary" : ""}" type="button" data-vob-open-card="${row[0]}"><b>${esc(row[1])}${row[3] ? " · 主推荐" : ""}</b><span>${esc(row[2])}</span></button>`).join("");
    const missing = summary.missing.length ? summary.missing.map((key) => permissionCopy[key][0]).join("、") : "暂无";
    return `<article class="vob-data-panel-v1"><header class="vob-data-panel-head-v1"><div><h2>数据与后台</h2><p>V1 不触发真实系统权限。这里把后续需要用户打开的能力、缺失项和通知预览先在 WebView 内跑通。</p></div><button type="button" data-vob-close-data aria-label="关闭">×</button></header><section class="vob-panel-block-v1"><h3>后台开关</h3>${rows}</section><section class="vob-panel-block-v1"><h3>读取状态</h3><div class="vob-panel-row-v1"><div><b>已读取</b><span>自填、mock 健康、mock 手机行为、位置日光、反馈历史。</span></div><em>${summary.enabled.length} 项</em></div><div class="vob-panel-row-v1"><div><b>缺失项</b><span>${esc(missing)}</span></div><em>${summary.missing.length ? "需补齐" : "完整"}</em></div></section><section class="vob-panel-block-v1"><h3>通知预览</h3><div class="vob-push-list-v1">${pushes}</div></section><section class="vob-panel-block-v1"><button class="vob-primary-v1" style="width:100%" type="button" data-vob-open-onboarding>重新建档</button></section></article>`;
  }

  function ensureDataSheet() {
    const root = host();
    let sheet = document.getElementById("vitoraDataSheetV1");
    if (!sheet) {
      sheet = document.createElement("section");
      sheet.id = "vitoraDataSheetV1";
      sheet.className = "vob-data-sheet-v1";
      sheet.setAttribute("aria-hidden", "true");
      root.appendChild(sheet);
    }
    return sheet;
  }

  function openDataSheet() {
    const sheet = ensureDataSheet();
    sheet.innerHTML = dataSheetHtml();
    sheet.classList.add("open");
    sheet.setAttribute("aria-hidden", "false");
  }

  function closeDataSheet() {
    const sheet = document.getElementById("vitoraDataSheetV1");
    if (sheet) {
      sheet.classList.remove("open");
      sheet.setAttribute("aria-hidden", "true");
    }
  }

  function activateCard(key) {
    closeDataSheet();
    const target = key || "today";
    try {
      if (typeof switchTab === "function") switchTab("today");
    } catch (_) {}
    try {
      const store = typeof tbiStoreV1 === "function" ? tbiStoreV1() : (window.S = window.S || {});
      store.fixedTodayActiveV1 = target;
      store.fixedTodayDetailV1 = false;
    } catch (_) {}
    [0, 60, 180, 420].forEach((delay) => setTimeout(() => {
      routeTodayViaNativeChip(target);
      try {
        if (typeof ftRenderFixedTodayV1 === "function") ftRenderFixedTodayV1(target);
      } catch (_) {}
      syncTodayRoute(target);
      ensureDataStripInToday();
    }, delay));
  }

  function ensureDataStripInToday() {
    let root = document.querySelector("[data-fixed-today-home-v1]") || document.querySelector(".fixed-today-home-v1");
    if (!root) root = document.querySelector('[data-screen="today"] .pad') || document.querySelector('[data-screen="today"]');
    if (!root) return false;
    const existing = root.querySelector("[data-vob-data-strip]");
    const html = dataStripHtml();
    if (existing) existing.outerHTML = html;
    else root.insertAdjacentHTML("afterbegin", html);
    return true;
  }

  function routeTodayViaNativeChip(key) {
    const target = key || "today";
    const chip = document.querySelector(`[data-fixed-today-chip="${target}"]`);
    if (!chip) return false;
    try {
      chip.click();
      return true;
    } catch (_) {
      return false;
    }
  }

  function syncTodayRoute(key) {
    const target = key || "today";
    const home = document.querySelector("[data-fixed-today-home-v1]") || document.querySelector(".fixed-today-home-v1");
    if (!home) return false;
    const slides = Array.from(home.querySelectorAll("[data-fixed-today-slide]"));
    const index = slides.findIndex((slide) => slide.getAttribute("data-fixed-today-slide") === target);
    if (index < 0) return false;
    const track = home.querySelector(".fixed-today-track-v1");
    if (track) track.style.transform = `translateX(-${index * 100}%)`;
    slides.forEach((slide) => {
      const on = slide.getAttribute("data-fixed-today-slide") === target;
      slide.classList.toggle("active", on);
      slide.setAttribute("aria-hidden", on ? "false" : "true");
    });
    home.querySelectorAll("[data-fixed-today-chip]").forEach((chip) => {
      const on = chip.getAttribute("data-fixed-today-chip") === target;
      chip.classList.toggle("active", on);
      chip.setAttribute("aria-pressed", on ? "true" : "false");
    });
    try {
      const store = typeof tbiStoreV1 === "function" ? tbiStoreV1() : (window.S = window.S || {});
      store.fixedTodayActiveV1 = target;
      store.fixedTodayDetailV1 = false;
    } catch (_) {}
    return true;
  }

  function patchTodayHome() {
    if (typeof ftRenderHomeV1 !== "function" || ftRenderHomeV1.__vobTodayLoopV1) return typeof ftRenderHomeV1 === "function";
    const base = ftRenderHomeV1;
    ftRenderHomeV1 = function patchedFtRenderHomeV1(active) {
      return base(active || "today").replace('minimal-home-v5"', 'minimal-home-v5 vob-today-v1"');
    };
    ftRenderHomeV1.__vobTodayLoopV1 = true;
    return true;
  }

  function patchFixedTodayRender() {
    if (typeof ftRenderFixedTodayV1 !== "function" || ftRenderFixedTodayV1.__vobTodayLoopV1) return typeof ftRenderFixedTodayV1 === "function";
    const base = ftRenderFixedTodayV1;
    ftRenderFixedTodayV1 = function patchedFtRenderFixedTodayV1(active) {
      const result = base.apply(this, arguments);
      ensureDataStripInToday();
      setTimeout(ensureDataStripInToday, 0);
      setTimeout(ensureDataStripInToday, 120);
      return result;
    };
    ftRenderFixedTodayV1.__vobTodayLoopV1 = true;
    return true;
  }

  function boot() {
    loadState();
    ensureDataSheet();
    const homePatched = patchTodayHome();
    patchFixedTodayRender();
    if (homePatched) {
      try {
        if (typeof ftRenderFixedTodayV1 === "function" && ((typeof S === "undefined") || !S.tab || S.tab === "today")) ftRenderFixedTodayV1((typeof S !== "undefined" && S.fixedTodayActiveV1) || "today");
      } catch (_) {}
    }
    setTimeout(ensureDataStripInToday, 0);
    setTimeout(ensureDataStripInToday, 240);
    const stored = readJson(ONBOARDING_KEY, null);
    const completed = !!(stored && stored.completed && stored.onboardingVersion === ONBOARDING_VERSION);
    if (hasOnboardingDeepLink()) {
      setTimeout(() => openOnboarding(true), 120);
      return;
    }
    if (!completed) {
      setTimeout(() => openOnboarding(stored && stored.completed), 180);
      return;
    }
    if (hasHealthSummaryDeepLink()) return;
  }

  let lastHandledKey = "";
  let lastHandledAt = 0;

  function eventTarget(event) {
    const target = event.target;
    if (!target) return null;
    if (target.closest) return target;
    return target.parentElement && target.parentElement.closest ? target.parentElement : null;
  }

  function stopVobEvent(event) {
    event.preventDefault();
    event.stopPropagation();
    if (event.stopImmediatePropagation) event.stopImmediatePropagation();
  }

  function wasRecentlyHandled(key) {
    const now = Date.now();
    if (lastHandledKey === key && now - lastHandledAt < 420) return true;
    lastHandledKey = key;
    lastHandledAt = now;
    return false;
  }

  function handleVobInputEvent(event) {
    const target = eventTarget(event);
    const input = target && target.closest("#vitoraOnboardingLayerV1 [data-vob-input], #vitoraOnboardingLayerV1 [data-action='note']");
    if (!input) return;
    state[input.getAttribute("data-vob-input") || input.getAttribute("data-key")] = input.value;
    writeJson(ONBOARDING_KEY, { ...state, completed: false });
  }

  function handleVobWheelEvent(event) {
    const target = eventTarget(event);
    const column = target && target.closest("#vitoraOnboardingLayerV1 .picker-column[data-picker-key]");
    if (!column) return;
    stopVobEvent(event);
    stepPicker(column.getAttribute("data-picker-key"), event.deltaY > 0 ? 1 : -1);
    writeJson(ONBOARDING_KEY, { ...state, completed: false });
  }

  function handleVobActionEvent(event) {
    const target = eventTarget(event);
    if (!target) return;

    const open = target.closest("[data-vob-open-onboarding]");
    if (open) {
      const dedupeKey = "open-onboarding";
      stopVobEvent(event);
      if (wasRecentlyHandled(dedupeKey)) return;
      openOnboarding(true);
      return;
    }
    const data = target.closest("[data-vob-open-data]");
    if (data) {
      const dedupeKey = "open-data";
      stopVobEvent(event);
      if (wasRecentlyHandled(dedupeKey)) return;
      openDataSheet();
      return;
    }
    const close = target.closest("[data-vob-close-data]");
    if (close || target.id === "vitoraDataSheetV1") {
      const dedupeKey = "close-data";
      stopVobEvent(event);
      if (wasRecentlyHandled(dedupeKey)) return;
      closeDataSheet();
      return;
    }
    const push = target.closest("[data-vob-open-card]");
    if (push) {
      const key = push.getAttribute("data-vob-open-card") || "today";
      const dedupeKey = `push:${key}`;
      stopVobEvent(event);
      if (wasRecentlyHandled(dedupeKey)) return;
      activateCard(key);
      return;
    }
    const actionNode = target.closest("#vitoraOnboardingLayerV1 [data-action]");
    if (!actionNode) return;

    const action = actionNode.getAttribute("data-action");
    if (action === "note") return;
    const key = actionNode.getAttribute("data-key");
    const value = actionNode.getAttribute("data-value");
    const dedupeKey = `action:${action}:${key || ""}:${value || ""}:${actionNode.getAttribute("data-delta") || ""}`;
    stopVobEvent(event);
    if (wasRecentlyHandled(dedupeKey)) return;

    if (action === "login") {
      state.loginProvider = value;
      state.page = "goal";
      state.step = "goal";
      state.stage = "confirm";
    } else if (action === "set") {
      state[key] = value;
      state.toast = false;
    } else if (action === "toggle") {
      const next = new Set(state[key] || []);
      if (next.has(value)) next.delete(value);
      else next.add(value);
      state[key] = Array.from(next);
    } else if (action === "step") {
      state[key] = clamp(
        (Number(state[key]) || 0) + Number(actionNode.getAttribute("data-delta") || 0),
        Number(actionNode.getAttribute("data-min") || 0),
        Number(actionNode.getAttribute("data-max") || 999),
      );
    } else if (action === "picker-set") {
      if (suppressPickerClick) {
        suppressPickerClick = false;
        return;
      }
      state[key] = Number(value);
      state.toast = false;
    } else if (action === "next") {
      nextPage();
      writeJson(ONBOARDING_KEY, { ...state, completed: false });
      return;
    } else if (action === "back") {
      backPage();
      writeJson(ONBOARDING_KEY, { ...state, completed: false });
      return;
    } else if (action === "skip-health") {
      skipHealthFlow();
      writeJson(ONBOARDING_KEY, { ...state, completed: false });
      return;
    } else if (action === "health-grant") {
      enterCycleWithHealth("granted");
      writeJson(ONBOARDING_KEY, { ...state, completed: false });
      return;
    } else if (action === "health-deny") {
      enterCycleWithHealth("denied");
      writeJson(ONBOARDING_KEY, { ...state, completed: false });
      return;
    } else if (action === "generate") {
      writeJson(ONBOARDING_KEY, { ...state, completed: false });
      startGenerate();
      return;
    } else if (action === "personality") {
      showPersonality();
      writeJson(ONBOARDING_KEY, { ...state, completed: false });
      return;
    } else if (action === "plan") {
      writeJson(ONBOARDING_KEY, { ...state, completed: false });
      startPlan();
      return;
    } else if (action === "result") {
      showResult();
      writeJson(ONBOARDING_KEY, { ...state, completed: false });
      return;
    } else if (action === "complete") {
      goToday();
      return;
    }
    writeJson(ONBOARDING_KEY, { ...state, completed: false });
    render();
  }

  ["input", "change"].forEach((type) => {
    window.addEventListener(type, handleVobInputEvent, true);
    document.addEventListener(type, handleVobInputEvent, true);
  });

  ["pointerup", "touchend", "click"].forEach((type) => {
    window.addEventListener(type, handleVobActionEvent, { capture: true, passive: false });
    document.addEventListener(type, handleVobActionEvent, { capture: true, passive: false });
  });

  window.addEventListener("wheel", handleVobWheelEvent, { capture: true, passive: false });
  document.addEventListener("wheel", handleVobWheelEvent, { capture: true, passive: false });

  window.openVitoraOnboardingV1 = () => openOnboarding(true);
  window.openVitoraDataAndBackgroundV1 = openDataSheet;

  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", boot, { once: true });
  else boot();

  const patchTimer = setInterval(() => {
    const homeReady = patchTodayHome();
    const fixedReady = patchFixedTodayRender();
    ensureDataStripInToday();
    if (homeReady && fixedReady) clearInterval(patchTimer);
  }, 400);
})();
