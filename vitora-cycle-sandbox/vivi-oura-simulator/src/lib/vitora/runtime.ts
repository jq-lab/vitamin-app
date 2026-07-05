import type {
  AchievementStampV1,
  BodyProfileDimensionV1,
  BodyProfileV1,
  ContentRecommendationV1,
  HealthInsightSummaryV1,
  HealthDetailContentV1,
  HealthDetailTab,
  HealthSnapshotV1,
  HealthStampTone,
  HealthSuggestionV1,
  PredictionStateV1,
  ProfileSurfaceStateV1,
  ProactiveCareEventV1,
  TodayCardId,
  TodayCardRuntimeV1,
  VitoraRuntimeStateV1
} from "./types";

type RuntimePayload = Partial<VitoraRuntimeStateV1> & {
  profile?: unknown;
  signals?: unknown;
  prediction?: unknown;
  content?: unknown;
  permissionState?: Record<string, boolean | string | number | null>;
};

type PersonaRow = {
  code: string;
  personaName: string;
  personaType: string;
  mythicReference: string;
  oneLine: string;
  traits: string[];
  risks: string[];
  recommendationBiases: BodyProfileV1["recommendationBiases"];
};

const DEFAULT_DIMENSIONS: BodyProfileDimensionV1 = {
  sleep: "L",
  cycle: "T",
  stress: "N",
  focus: "J",
  energy: "C"
};

const PERSONA_ROWS: PersonaRow[] = [
  {
    code: "D-S-B-I-V",
    personaName: "武则天型",
    personaType: "高能掌舵型身体",
    mythicReference: "雅典娜",
    oneLine: "恢复快、行动强，但容易把休息信号排到最后。",
    traits: ["恢复快", "抗压强", "行动力高"],
    risks: ["容易透支", "忽略休息信号"],
    recommendationBiases: { intensity: "high", defaultMinutes: 25, contentTypes: ["focus", "active"], tone: "直接、清晰、少废话" }
  },
  {
    code: "L-T-N-J-C",
    personaName: "林黛玉型",
    personaType: "敏感低耗型身体",
    mythicReference: "月亮女神塞勒涅",
    oneLine: "身体能捕捉很细的变化，更需要温柔稳定的恢复窗口。",
    traits: ["身体灵敏", "能捕捉细微信号", "适合温柔节奏"],
    risks: ["易受周期和压力影响", "高刺激内容容易过载"],
    recommendationBiases: { intensity: "low", defaultMinutes: 8, contentTypes: ["breath", "sleep", "low_stim"], tone: "温和、保护恢复窗口" }
  },
  {
    code: "D-T-B-J-V",
    personaName: "上官婉儿型",
    personaType: "顺势爆发型身体",
    mythicReference: "缪斯女神卡利俄佩",
    oneLine: "状态来了能快速推进，但要先看窗口再安排强度。",
    traits: ["能量高", "适合顺势推进", "恢复弹性好"],
    risks: ["状态波动明显", "多任务切换会放大消耗"],
    recommendationBiases: { intensity: "medium", defaultMinutes: 20, contentTypes: ["soundscape", "focus", "cycle"], tone: "先看窗口，再安排强度" }
  },
  {
    code: "L-S-N-I-C",
    personaName: "李清照型",
    personaType: "慢热深专注型身体",
    mythicReference: "墨涅摩绪涅",
    oneLine: "进入状态后能深度专注，关键是减少打扰和夜间兴奋。",
    traits: ["深度专注强", "适合安静长线任务", "节奏稳定"],
    risks: ["启动慢", "夜间兴奋后容易影响睡眠"],
    recommendationBiases: { intensity: "low", defaultMinutes: 25, contentTypes: ["focus", "sleep", "quiet"], tone: "减少打扰，保护进入状态的时间" }
  },
  {
    code: "D-S-N-J-V",
    personaName: "花木兰型",
    personaType: "创意跳切型身体",
    mythicReference: "阿尔忒弥斯",
    oneLine: "爆发力和表达力强，压力升高时需要清边界。",
    traits: ["表达欲强", "创意反应快", "短时爆发好"],
    risks: ["容易分心", "压力一高就切换过密"],
    recommendationBiases: { intensity: "medium", defaultMinutes: 15, contentTypes: ["focus", "breath", "creative"], tone: "短任务、清边界、快反馈" }
  },
  {
    code: "L-T-B-I-C",
    personaName: "王昭君型",
    personaType: "安静深恢复型身体",
    mythicReference: "赫斯提亚",
    oneLine: "恢复力深而慢，适合低刺激、长线补能。",
    traits: ["安静", "恢复力好", "适合深沉慢节奏"],
    risks: ["周期敏感", "高强度社交后恢复变慢"],
    recommendationBiases: { intensity: "low", defaultMinutes: 18, contentTypes: ["sleep", "meditation", "cycle"], tone: "低刺激、深恢复、慢推进" }
  },
  {
    code: "D-T-N-I-V",
    personaName: "卓文君型",
    personaType: "高敏高爆发型身体",
    mythicReference: "尼刻",
    oneLine: "目标感强、标准高，需要给挑战保留恢复边界。",
    traits: ["标准高", "爆发力强", "目标感清晰"],
    risks: ["压力敏感", "容易把恢复窗口压掉"],
    recommendationBiases: { intensity: "medium", defaultMinutes: 25, contentTypes: ["focus", "breath", "recovery"], tone: "保留挑战，但先设恢复边界" }
  },
  {
    code: "L-S-B-J-C",
    personaName: "谢道韫型",
    personaType: "低耗稳定续航型身体",
    mythicReference: "珀耳塞福涅",
    oneLine: "稳定、低消耗，最适合用低门槛动作慢慢积累。",
    traits: ["低消耗", "稳定", "适合慢积累"],
    risks: ["启动偏慢", "容易拖到能量更低再行动"],
    recommendationBiases: { intensity: "low", defaultMinutes: 10, contentTypes: ["morning", "breath", "light_walk"], tone: "低门槛、先开始、少压迫" }
  }
];

const LEGACY_ANIMAL_TO_PERSONA: Record<string, string> = {
  astra_leopard: "D-S-B-I-V",
  bloom_deer: "L-T-N-J-C",
  crest_dolphin: "D-T-B-J-V",
  dusk_owl: "L-S-N-I-C",
  ember_fox: "D-S-N-J-V",
  frost_whale: "L-T-B-I-C",
  garnet_hawk: "D-T-N-I-V",
  hush_sloth: "L-S-B-J-C"
};

function todayIso() {
  const date = new Date();
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}-${String(date.getDate()).padStart(2, "0")}`;
}

function nowIso() {
  return new Date().toISOString();
}

function clamp(value: number, min: number, max: number) {
  return Math.max(min, Math.min(max, Number.isFinite(value) ? value : min));
}

function asRecord(value: unknown): Record<string, unknown> {
  return value && typeof value === "object" ? (value as Record<string, unknown>) : {};
}

function asString(value: unknown, fallback = "") {
  return typeof value === "string" && value ? value : fallback;
}

function asNumber(value: unknown, fallback: number) {
  return typeof value === "number" && Number.isFinite(value) ? value : fallback;
}

function hammingCodeDistance(a: string, b: string) {
  const aa = String(a || "").split("-");
  const bb = String(b || "").split("-");
  return aa.reduce((sum, value, index) => sum + (value === bb[index] ? 0 : 1), 0);
}

function rowForCode(code: string) {
  const normalized = PERSONA_ROWS.find((row) => row.code === code);
  if (normalized) return normalized;
  return PERSONA_ROWS.slice().sort((a, b) => hammingCodeDistance(code, a.code) - hammingCodeDistance(code, b.code))[0];
}

function dimensionsFromCode(code: string): BodyProfileDimensionV1 {
  const [sleep, cycle, stress, focus, energy] = String(code || "").split("-");
  return {
    sleep: sleep === "D" ? "D" : "L",
    cycle: cycle === "S" ? "S" : "T",
    stress: stress === "B" ? "B" : "N",
    focus: focus === "I" ? "I" : "J",
    energy: energy === "V" ? "V" : "C"
  };
}

function codeFromDimensions(dimensions: Partial<BodyProfileDimensionV1>) {
  return [
    dimensions.sleep === "D" ? "D" : "L",
    dimensions.cycle === "S" ? "S" : "T",
    dimensions.stress === "B" ? "B" : "N",
    dimensions.focus === "I" ? "I" : "J",
    dimensions.energy === "V" ? "V" : "C"
  ].join("-");
}

export function normalizeBodyProfile(input?: unknown): BodyProfileV1 {
  const record = asRecord(input);
  const dimensionsRecord = asRecord(record.dimensions);
  const rawCodeFromInput = asString(record.rawCode, "");
  const bodyCodeFromInput = asString(record.bodyCode, "");
  const legacyAnimalId = asString(record.archetypeId, "");
  const code =
    rawCodeFromInput ||
    bodyCodeFromInput ||
    LEGACY_ANIMAL_TO_PERSONA[legacyAnimalId] ||
    codeFromDimensions({
      sleep: dimensionsRecord.sleep as BodyProfileDimensionV1["sleep"],
      cycle: dimensionsRecord.cycle as BodyProfileDimensionV1["cycle"],
      stress: dimensionsRecord.stress as BodyProfileDimensionV1["stress"],
      focus: dimensionsRecord.focus as BodyProfileDimensionV1["focus"],
      energy: dimensionsRecord.energy as BodyProfileDimensionV1["energy"]
    }) ||
    codeFromDimensions(DEFAULT_DIMENSIONS);
  const row = rowForCode(code);
  const createdAt = asString(record.createdAt, nowIso());
  return {
    schemaVersion: "BodyProfileV1",
    profileId: `profile-${code.toLowerCase().replace(/-/g, "")}`,
    createdAt,
    updatedAt: nowIso(),
    source: Object.keys(record).length ? "onboarding" : "default",
    compatibilityKey: "vitora_body_profile_v1",
    rawCode: code,
    internalCode: row.code,
    legacyAnimalName: asString(record.zhName, undefined as unknown as string),
    legacyAnimalId: legacyAnimalId || undefined,
    personaName: row.personaName,
    personaType: row.personaType,
    mythicReference: row.mythicReference,
    oneLine: row.oneLine,
    dimensions: dimensionsFromCode(code),
    traits: row.traits,
    risks: row.risks,
    recommendationBiases: row.recommendationBiases
  };
}

function cyclePhase(cycleDay: number): HealthSnapshotV1["cycle"]["phase"] {
  if (cycleDay <= 5) return "menstrual";
  if (cycleDay <= 13) return "follicular";
  if (cycleDay <= 16) return "ovulation";
  return "luteal";
}

function cyclePhaseLabel(phase: HealthSnapshotV1["cycle"]["phase"]) {
  if (phase === "menstrual") return "经期";
  if (phase === "follicular") return "卵泡期";
  if (phase === "ovulation") return "排卵期";
  return "黄体期";
}

function healthFromSignals(signals?: unknown) {
  const signalRecord = asRecord(signals);
  const health = asRecord(signalRecord.health);
  const cycle = asRecord(signalRecord.cycle);
  const selfReport = asRecord(signalRecord.selfReport);
  const symptoms = asRecord(cycle.symptoms);
  return { signalRecord, health, cycle, selfReport, symptoms };
}

export function buildHealthSnapshot(profile: BodyProfileV1, signals?: unknown): HealthSnapshotV1 {
  const { signalRecord, health, cycle, selfReport, symptoms } = healthFromSignals(signals);
  const date = asString(signalRecord.date, todayIso());
  const sleepMinutes = asNumber(health.sleepMinutes, 412);
  const cycleDay = clamp(asNumber(cycle.cycleDay, 24), 1, 45);
  const phase = cyclePhase(cycleDay);
  const stress = asString(selfReport.mood, "") === "tense" ? 7 : 5;
  return {
    schemaVersion: "HealthSnapshotV1",
    snapshotId: `snapshot-${date}`,
    profileId: profile.profileId,
    date,
    source: "mock",
    adapterStatus: "mock_simulator",
    sleep: {
      durationMinutes: sleepMinutes,
      deepMinutes: asNumber(health.deepSleepMinutes, 68),
      remMinutes: Math.max(54, Math.round(sleepMinutes * 0.18)),
      awakeMinutes: asNumber(health.awakenings, 2) * 9,
      efficiency: clamp(sleepMinutes / 480 - asNumber(health.awakenings, 2) * 0.018, 0.62, 0.96),
      bedtime: "23:10",
      wakeTime: "07:42"
    },
    recovery: {
      hrvRmssd: asNumber(health.hrv, 37),
      restingHeartRate: asNumber(health.restingHeartRate, 69),
      bodyTemperatureDelta: asNumber(health.skinTempDelta, 0.18)
    },
    activity: {
      steps: asNumber(health.steps, 6150),
      activeCalories: 343,
      distanceKm: Math.round(asNumber(health.steps, 6150) * 0.00078 * 100) / 100,
      workoutCompleted: asString(selfReport.goal, "") === "training"
    },
    cycle: {
      cycleDay,
      phase,
      phaseLabel: cyclePhaseLabel(phase),
      periodPredictedInDays: Math.max(0, 28 - cycleDay),
      symptoms: [
        asNumber(symptoms.fatigue, 0) > 1 ? "疲惫" : "",
        asNumber(symptoms.mood, 0) > 1 ? "情绪敏感" : "",
        asNumber(symptoms.bloating, 0) > 1 ? "水肿" : ""
      ].filter(Boolean)
    },
    selfReport: {
      goal: asString(selfReport.goal, "sleep"),
      stress,
      fatigue: asNumber(selfReport.fatigue, 2),
      conversationSignals: ["用户提到疲惫时，主动关心但不打扰"]
    }
  };
}

function sleepScore(snapshot: HealthSnapshotV1) {
  const durationScore = clamp((snapshot.sleep.durationMinutes - 330) / 150 * 100, 45, 96);
  const efficiencyScore = clamp(snapshot.sleep.efficiency * 100, 55, 96);
  const wakePenalty = snapshot.sleep.awakeMinutes > 24 ? 9 : 0;
  return Math.round((durationScore * 0.56 + efficiencyScore * 0.44) - wakePenalty);
}

function stressScore(snapshot: HealthSnapshotV1) {
  const hrvComponent = clamp((snapshot.recovery.hrvRmssd - 24) / 28 * 100, 38, 96);
  const rhrPenalty = clamp((snapshot.recovery.restingHeartRate - 58) * 1.35, 0, 22);
  const selfPenalty = snapshot.selfReport.stress * 2.2;
  return Math.round(clamp(hrvComponent - rhrPenalty - selfPenalty + 18, 28, 95));
}

function cycleScore(snapshot: HealthSnapshotV1) {
  const phasePenalty = snapshot.cycle.phase === "luteal" ? 10 : snapshot.cycle.phase === "menstrual" ? 16 : 0;
  const symptomPenalty = snapshot.cycle.symptoms.length * 4;
  return Math.round(clamp(86 - phasePenalty - symptomPenalty, 42, 94));
}

function focusScore(snapshot: HealthSnapshotV1, stress: number) {
  const sleep = sleepScore(snapshot);
  return Math.round(clamp(sleep * 0.45 + stress * 0.42 + 18 - snapshot.selfReport.fatigue * 3, 24, 94));
}

function metabolismScore(snapshot: HealthSnapshotV1) {
  const stepScore = clamp(snapshot.activity.steps / 8500 * 100, 34, 96);
  const tempPenalty = snapshot.recovery.bodyTemperatureDelta > 0.14 ? 8 : 0;
  return Math.round(clamp(stepScore - tempPenalty + 8, 35, 96));
}

function scoreDelta(score: number, weight: number) {
  return Math.round((score - 70) * weight);
}

function buildScoreBreakdown(scores: PredictionStateV1["scores"], snapshot: HealthSnapshotV1): PredictionStateV1["scoreBreakdown"] {
  const sleepContribution = Math.round(clamp((scores.sleep - 56) * 0.36, 0, 24));
  const cycleContribution = Math.round(clamp((scores.cycle - 78) * 0.38, -16, 10));
  const focusContribution = Math.round(clamp((scores.focus - 70) * 0.46, -18, 12));
  const stressContribution = Math.round(clamp((scores.stress - 72) * 0.28, -10, 10));
  const metabolismContribution = Math.round(clamp((scores.metabolism - 70) * 0.22, -10, 8));
  const morningContribution = Math.round(clamp((scores.morning - 70) * 0.18, -8, 8));
  const baseScore = 75;
  const totalScore = Math.round(clamp(
    baseScore +
      sleepContribution +
      cycleContribution +
      focusContribution +
      stressContribution +
      metabolismContribution +
      morningContribution,
    35,
    96
  ));
  return {
    schemaVersion: "TodayScoreBreakdownV1",
    baseScore,
    totalScore,
    chips: [
      {
        id: "sleep",
        label: "睡眠",
        value: `+${sleepContribution}`,
        contribution: sleepContribution,
        score: scores.sleep,
        status: scores.sleep < 62 ? "warning" : "normal"
      },
      {
        id: "cycle",
        label: "周期",
        value: `D${snapshot.cycle.cycleDay}`,
        contribution: cycleContribution,
        score: scores.cycle,
        status: snapshot.cycle.phase === "menstrual" || snapshot.cycle.periodPredictedInDays <= 3 ? "warning" : "normal"
      },
      {
        id: "focus",
        label: "专注",
        value: focusContribution > 0 ? `+${focusContribution}` : `${focusContribution}`,
        contribution: focusContribution,
        score: scores.focus,
        status: scores.focus < 68 ? "warning" : "normal"
      },
      {
        id: "stress",
        label: "抗压",
        value: stressContribution > 0 ? `+${stressContribution}` : `${stressContribution}`,
        contribution: stressContribution,
        score: scores.stress,
        status: scores.stress < 64 ? "warning" : "normal"
      },
      {
        id: "metabolism",
        label: "代谢",
        value: metabolismContribution > 0 ? `+${metabolismContribution}` : `${metabolismContribution}`,
        contribution: metabolismContribution,
        score: scores.metabolism,
        status: scores.metabolism < 68 ? "warning" : "normal"
      },
      {
        id: "morning",
        label: "晨间",
        value: morningContribution > 0 ? `+${morningContribution}` : `${morningContribution}`,
        contribution: morningContribution,
        score: scores.morning,
        status: scores.morning < 66 ? "warning" : "normal"
      }
    ],
    explanation: `今日综合数据 ${totalScore}%，由基础分 ${baseScore}、睡眠 +${sleepContribution}、周期 ${cycleContribution}、专注 ${focusContribution}、抗压 ${stressContribution}、代谢 ${metabolismContribution} 和晨间 ${morningContribution} 共同计算。`
  };
}

function primaryActionFor(scores: PredictionStateV1["scores"], snapshot: HealthSnapshotV1, profile: BodyProfileV1): PredictionStateV1["primaryAction"] {
  if (snapshot.cycle.phase === "luteal" && snapshot.cycle.periodPredictedInDays <= 6) {
    return {
      actionId: "cycle-low-stimulus",
      actionType: "reminder",
      title: "经前低刺激窗口",
      reason: `${snapshot.cycle.phaseLabel}叠加体温变化，今天把强刺激任务往后放。`,
      session: "cycle-luteal-soft-10",
      push: `Dori 发现你离经期还有 ${snapshot.cycle.periodPredictedInDays} 天，今天先保留恢复窗口。`,
      scheduledTime: "12:05",
      targetCard: "today",
      targetHealthTab: "cycle"
    };
  }
  if (scores.sleep < 74) {
    return {
      actionId: "sleep-repair",
      actionType: "reminder",
      title: "开始第 1 级睡眠修复",
      reason: "昨晚睡眠连续性偏低，下午专注和恢复速度都会被影响。",
      session: "sleep-dream-brown-18",
      push: "昨晚睡得不太稳，Dori 帮你留了一个睡眠修复提醒。",
      scheduledTime: "21:30",
      targetCard: "sleep",
      targetHealthTab: "sleep"
    };
  }
  if (scores.focus < 68) {
    return {
      actionId: "single-task-focus",
      actionType: "direct_session",
      title: profile.recommendationBiases.intensity === "low" ? "开始 15 分钟单任务" : "开始 25 分钟单任务",
      reason: "HRV、疲劳和睡眠共同显示切换成本偏高。",
      session: "focus-afternoon-25",
      push: "Dori 发现你今天更适合单任务推进，先把切换降下来。",
      scheduledTime: "13:00",
      targetCard: "focus",
      targetHealthTab: "focus"
    };
  }
  if (scores.metabolism < 68) {
    return {
      actionId: "metabolism-snack",
      actionType: "reminder",
      title: "设置加餐提醒",
      reason: "步数和体温变化提示下午容易靠意志硬扛。",
      session: "metabolism-soft-snack",
      push: "Dori 发现代谢负担上来，下午补一点温和能量。",
      scheduledTime: "15:00",
      targetCard: "metabolism",
      targetHealthTab: "metabolism"
    };
  }
  return {
    actionId: "morning-stabilize",
    actionType: "direct_session",
    title: "开始 4 分钟呼吸",
    reason: "整体状态可推进，但先用低刺激动作保持稳定。",
    session: "emotion-breath-3",
    push: "Dori 看见今天状态可以推进，先用 4 分钟把节奏稳住。",
    scheduledTime: "10:30",
    targetCard: "today",
    targetHealthTab: "summary"
  };
}

export function predictDailyState(profile: BodyProfileV1, snapshot: HealthSnapshotV1): PredictionStateV1 {
  const sleep = sleepScore(snapshot);
  const stress = stressScore(snapshot);
  const cycle = cycleScore(snapshot);
  const focus = focusScore(snapshot, stress);
  const metabolism = metabolismScore(snapshot);
  const morning = Math.round(clamp(sleep * 0.35 + stress * 0.2 + cycle * 0.2 + 22, 42, 96));
  const provisionalReadiness = Math.round(clamp(sleep * 0.34 + stress * 0.24 + cycle * 0.18 + metabolism * 0.14 + morning * 0.1, 35, 96));
  const provisionalScores = { sleep, focus, stress, cycle, metabolism, morning, readiness: provisionalReadiness };
  const scoreBreakdown = buildScoreBreakdown(provisionalScores, snapshot);
  const readiness = scoreBreakdown.totalScore;
  const scores = { ...provisionalScores, readiness };
  const primaryAction = primaryActionFor(scores, snapshot, profile);
  const todayScore = scoreBreakdown.totalScore;
  const confidence = snapshot.adapterStatus === "mock_simulator" ? "medium" : "high";
  return {
    schemaVersion: "PredictionStateV1",
    predictionId: `prediction-${snapshot.date}-${profile.internalCode.toLowerCase().replace(/-/g, "")}`,
    profileId: profile.profileId,
    snapshotId: snapshot.snapshotId,
    date: snapshot.date,
    todayScore,
    confidence,
    phaseLabel: snapshot.cycle.phaseLabel,
    scores,
    scoreBreakdown,
    scoreDeltas: {
      sleep: scoreDelta(sleep, 0.42),
      focus: scoreDelta(focus, 0.6),
      metabolism: scoreDelta(metabolism, 0.45),
      morning: scoreDelta(morning, 0.32)
    },
    primaryAction,
    drivers: {
      good: [
        `${profile.personaName}适合${profile.recommendationBiases.tone}`,
        `步数 ${snapshot.activity.steps.toLocaleString()}，仍有温和活动空间`
      ],
      bad: [
        `睡眠 ${Math.round(snapshot.sleep.durationMinutes / 60 * 10) / 10}h，效率 ${Math.round(snapshot.sleep.efficiency * 100)}%`,
        `HRV ${snapshot.recovery.hrvRmssd}ms，静息心率 ${snapshot.recovery.restingHeartRate}bpm`,
        `${snapshot.cycle.phaseLabel} D${snapshot.cycle.cycleDay}，经期预计 ${snapshot.cycle.periodPredictedInDays} 天后`
      ]
    },
    evidence: [
      `profileId=${profile.profileId}`,
      `snapshotId=${snapshot.snapshotId}`,
      `睡眠 ${snapshot.sleep.durationMinutes} 分钟 / HRV ${snapshot.recovery.hrvRmssd}ms / RHR ${snapshot.recovery.restingHeartRate}bpm`,
      `${snapshot.cycle.phaseLabel} D${snapshot.cycle.cycleDay}，体温变化 ${snapshot.recovery.bodyTemperatureDelta > 0 ? "+" : ""}${snapshot.recovery.bodyTemperatureDelta}°C`
    ]
  };
}

function deltaText(value: number) {
  if (value > 0) return `+${value}`;
  return `${value}`;
}

function scoreTimeLabel(minutes: number) {
  const hours = Math.floor(minutes / 60);
  const mins = minutes % 60;
  return mins ? `${hours}.${Math.round(mins / 6)}` : `${hours}`;
}

function buildSuggestions(snapshot: HealthSnapshotV1, prediction: PredictionStateV1): Record<HealthDetailTab, HealthSuggestionV1[]> {
  const primary = prediction.primaryAction;
  const lowStimulus = snapshot.cycle.phase === "luteal" || prediction.scores.stress < 62;
  return {
    summary: [
      { icon: "☕", time: primary.scheduledTime, title: primary.title, copy: primary.reason, action: "提醒我", tone: "green" },
      { icon: "□", time: "13:00", title: "表达与记录", copy: "把身体线索和情绪放在同一个记录里，明天预测会继续校准。", action: "设置" },
      { icon: "◒", time: "18:30", title: lowStimulus ? "温和运动" : "轻量推进", copy: lowStimulus ? "选择散步或拉伸，减少高刺激训练。" : "用 8 分钟轻走维持循环。", action: "提醒我" }
    ],
    sleep: [
      { icon: "◜", time: "21:30", title: "提前放松", copy: `昨晚清醒约 ${snapshot.sleep.awakeMinutes} 分钟，今晚提前降低屏幕刺激。`, action: "提醒我", tone: "green" },
      { icon: "◷", time: "22:30", title: "保持规律", copy: "固定入睡时间，帮助睡眠连续性回到稳定区间。", action: "设置" },
      { icon: "☼", time: "07:30", title: "晨间唤醒", copy: "起床后接触自然光，帮助白天更清醒。", action: "提醒" }
    ],
    cycle: [
      { icon: "☕", time: "09:00", title: "放缓节奏，优先休息", copy: `${snapshot.cycle.phaseLabel} D${snapshot.cycle.cycleDay}，上午先安排轻量任务。`, action: "提醒我", tone: "green" },
      { icon: "♙", time: "18:00", title: "温和运动，舒缓身心", copy: "选择瑜伽、散步等低强度运动，促进循环与放松。", action: "设置", tone: "green" },
      { icon: "□", time: "21:00", title: "记录感受，倾听身体", copy: "记录情绪、睡眠和食欲变化，作为后续预测证据。", action: "提醒我" }
    ],
    focus: [
      { icon: "◎", time: primary.targetHealthTab === "focus" ? primary.scheduledTime : "10:30", title: "单任务开始", copy: "只打开当前任务相关窗口，先工作一个短时段。", action: "提醒我" },
      { icon: "□", time: "14:00", title: "通知降噪", copy: "下午关闭非必要通知，避免重复切换。", action: "设置" },
      { icon: "◌", time: "16:30", title: "呼吸复位", copy: "注意力下降时先做 3 分钟呼吸，再继续推进。", action: "提醒我" }
    ],
    metabolism: [
      { icon: "☕", time: "15:00", title: "加餐恢复", copy: "补充温和能量，降低下午恢复压力。", action: "提醒我", tone: "green" },
      { icon: "◒", time: "17:30", title: "轻走 8 分钟", copy: "不做强刺激，只把循环拉回来。", action: "设置" },
      { icon: "□", time: "20:30", title: "代谢回看", copy: "记录今晚食欲和疲劳感，作为明天预测线索。", action: "提醒我" }
    ]
  };
}

function healthDetail(title: string, body: string, scoreLabel: string, evidence: string[], suggestions: HealthSuggestionV1[]): HealthDetailContentV1 {
  return { title, body, scoreLabel, evidence, suggestions };
}

export function composeContent(profile: BodyProfileV1, snapshot: HealthSnapshotV1, prediction: PredictionStateV1): ContentRecommendationV1 {
  const suggestions = buildSuggestions(snapshot, prediction);
  const todayScore = `${prediction.todayScore}`;
  const sleepHours = scoreTimeLabel(snapshot.sleep.durationMinutes);
  const chip = (id: PredictionStateV1["scoreBreakdown"]["chips"][number]["id"]) =>
    prediction.scoreBreakdown.chips.find((item) => item.id === id);
  const todayCards: TodayCardRuntimeV1[] = [
    {
      id: "today",
      label: "今日",
      chipValue: `${prediction.todayScore}%`,
      title: "今日能量",
      subtitle: `今日${snapshot.cycle.phaseLabel}，${profile.personaName}适合${profile.recommendationBiases.tone}。`,
      score: todayScore,
      tone: "energy",
      moreTab: prediction.primaryAction.targetHealthTab,
      monitor: `${prediction.scoreBreakdown.explanation} ${prediction.primaryAction.push}`,
      action: prediction.primaryAction.title,
      actionType: prediction.primaryAction.actionType,
      status: prediction.todayScore < 66 ? "warning" : "normal"
    },
    {
      id: "sleep",
      label: "睡眠",
      chipValue: chip("sleep")?.value ?? "良好",
      title: "睡眠",
      subtitle: `昨晚 ${sleepHours} 小时，效率 ${Math.round(snapshot.sleep.efficiency * 100)}%，会影响下午专注和恢复速度。`,
      score: sleepHours,
      scoreUnit: "h",
      tone: "sleep",
      moreTab: "sleep",
      monitor: `睡眠得分 ${prediction.scores.sleep}；证据来自睡眠时长、清醒 ${snapshot.sleep.awakeMinutes} 分钟和 HRV。`,
      action: "设置睡眠提醒",
      actionType: "reminder",
      status: chip("sleep")?.status ?? "normal"
    },
    {
      id: "cycle",
      label: "周期",
      chipValue: chip("cycle")?.value ?? `D${snapshot.cycle.cycleDay}`,
      title: `周期 D${snapshot.cycle.cycleDay} 天`,
      subtitle: `当前处于${snapshot.cycle.phaseLabel}，更适合低刺激恢复和稳定节奏。`,
      score: String(snapshot.cycle.cycleDay),
      scoreUnit: "天",
      tone: "cycle",
      moreTab: "cycle",
      monitor: `周期得分 ${prediction.scores.cycle}；${snapshot.cycle.phaseLabel}会影响水肿、食欲、情绪和专注耐受。`,
      action: "开始第 1 级低刺激恢复",
      actionType: "direct_session",
      status: chip("cycle")?.status ?? "normal"
    },
    {
      id: "focus",
      label: "专注",
      chipValue: chip("focus")?.value ?? deltaText(prediction.scoreDeltas.focus),
      title: "专注",
      subtitle: "HRV、疲劳和睡眠共同决定今天的切换成本。",
      score: profile.recommendationBiases.intensity === "low" ? "15" : "25",
      scoreUnit: "分钟",
      tone: "focus",
      moreTab: "focus",
      monitor: `专注得分 ${prediction.scores.focus}；先做单任务，再恢复输入信息。`,
      action: profile.recommendationBiases.intensity === "low" ? "开始 15 分钟专注" : "开始 25 分钟专注",
      actionType: "direct_session",
      status: chip("focus")?.status ?? "normal"
    },
    {
      id: "metabolism",
      label: "代谢",
      chipValue: chip("metabolism")?.value ?? deltaText(prediction.scoreDeltas.metabolism),
      title: "代谢",
      subtitle: `今日步数 ${snapshot.activity.steps.toLocaleString()}，体温和周期会影响下午补能。`,
      score: snapshot.activity.steps.toLocaleString(),
      tone: "metabolism",
      moreTab: "metabolism",
      monitor: `代谢得分 ${prediction.scores.metabolism}；建议下午补一点温和能量，避免硬扛。`,
      action: "代谢开启",
      actionType: "direct_session",
      status: chip("metabolism")?.status ?? "normal"
    },
    {
      id: "morning",
      label: "晨间",
      chipValue: chip("morning")?.value ?? deltaText(prediction.scoreDeltas.morning),
      title: "晨间计划",
      subtitle: snapshot.cycle.symptoms.length ? `当前更容易${snapshot.cycle.symptoms.join("、")}。` : "当前适合用自然光和轻走启动。",
      score: snapshot.activity.distanceKm.toFixed(2),
      scoreUnit: "KM",
      tone: "morning",
      moreTab: "summary",
      monitor: `晨间得分 ${prediction.scores.morning}；自然光和轻走会帮助今天更早进入稳态。`,
      action: "打开晨间路线",
      actionType: "map_guidance",
      status: chip("morning")?.status ?? "normal"
    }
  ];
  return {
    schemaVersion: "ContentRecommendationV1",
    contentId: `content-${prediction.predictionId}`,
    profileId: profile.profileId,
    snapshotId: snapshot.snapshotId,
    predictionId: prediction.predictionId,
    date: prediction.date,
    todayCards,
    healthTitle: `${profile.personaName}正在回到稳态`,
    healthSummary: `本周主线是${snapshot.cycle.phaseLabel}适应与恢复窗口。今日预测 ${prediction.todayScore} 分，主动关心事件会同步到 Today 和健康详情。`,
    healthMetrics: {
      readiness: String(prediction.scores.readiness),
      sleepDebt: prediction.scores.sleep < 76 ? "+2" : "+0",
      informationDebt: prediction.scores.focus < 70 ? "+6" : "+2",
      average: `${Math.round((prediction.scores.sleep + prediction.scores.focus + prediction.scores.cycle) / 3)}%`
    },
    healthDetails: {
      summary: healthDetail(
        "身体翻译",
        `${profile.personaName}的今日主建议是：${prediction.primaryAction.title}。原因：${prediction.primaryAction.reason}`,
        `${prediction.todayScore}%`,
        prediction.evidence,
        suggestions.summary
      ),
      sleep: healthDetail(
        "睡眠连续性",
        `昨晚睡眠 ${snapshot.sleep.durationMinutes} 分钟，清醒约 ${snapshot.sleep.awakeMinutes} 分钟。睡眠变化会直接影响专注与恢复。`,
        `${prediction.scores.sleep}`,
        [`睡眠效率 ${Math.round(snapshot.sleep.efficiency * 100)}%`, `深睡 ${snapshot.sleep.deepMinutes} 分钟`, `HRV ${snapshot.recovery.hrvRmssd}ms`],
        suggestions.sleep
      ),
      cycle: healthDetail(
        "周期解读",
        `你目前处于${snapshot.cycle.phaseLabel} D${snapshot.cycle.cycleDay}，预计 ${snapshot.cycle.periodPredictedInDays} 天后进入经期。`,
        `D${snapshot.cycle.cycleDay}`,
        [`体温变化 ${snapshot.recovery.bodyTemperatureDelta > 0 ? "+" : ""}${snapshot.recovery.bodyTemperatureDelta}°C`, `症状：${snapshot.cycle.symptoms.join("、") || "暂无明显症状"}`],
        suggestions.cycle
      ),
      focus: healthDetail(
        "专注窗口",
        `今日专注分 ${prediction.scores.focus}，建议把任务压成单线程，减少通知和切换。`,
        `${prediction.scores.focus}`,
        [`HRV ${snapshot.recovery.hrvRmssd}ms`, `压力自评 ${snapshot.selfReport.stress}/10`, `睡眠效率 ${Math.round(snapshot.sleep.efficiency * 100)}%`],
        suggestions.focus
      ),
      metabolism: healthDetail(
        "代谢节奏",
        `今日步数 ${snapshot.activity.steps.toLocaleString()}，活跃消耗 ${snapshot.activity.activeCalories} kcal。下午用温和补能维持状态。`,
        snapshot.activity.steps.toLocaleString(),
        [`距离 ${snapshot.activity.distanceKm.toFixed(2)} km`, `活跃消耗 ${snapshot.activity.activeCalories} kcal`, `体温变化 ${snapshot.recovery.bodyTemperatureDelta > 0 ? "+" : ""}${snapshot.recovery.bodyTemperatureDelta}°C`],
        suggestions.metabolism
      )
    }
  };
}

function triggerFor(prediction: PredictionStateV1, snapshot: HealthSnapshotV1): ProactiveCareEventV1["trigger"] {
  if (prediction.primaryAction.targetHealthTab === "sleep") return "sleep_drop";
  if (prediction.primaryAction.targetHealthTab === "cycle") return "cycle_window";
  if (snapshot.activity.workoutCompleted) return "workout_done";
  if (prediction.scores.stress < 62) return "hrv_drop";
  return "conversation_fatigue";
}

export function createCareEvents(
  profile: BodyProfileV1,
  snapshot: HealthSnapshotV1,
  prediction: PredictionStateV1,
  content: ContentRecommendationV1
): ProactiveCareEventV1[] {
  const eventId = `care-${prediction.date}-${prediction.primaryAction.actionId}`;
  const event: ProactiveCareEventV1 = {
    schemaVersion: "ProactiveCareEventV1",
    careEventId: eventId,
    profileId: profile.profileId,
    snapshotId: snapshot.snapshotId,
    predictionId: prediction.predictionId,
    contentId: content.contentId,
    date: prediction.date,
    title: "Dori 主动关心",
    body: `${prediction.primaryAction.push}｜${profile.personaName}`,
    trigger: triggerFor(prediction, snapshot),
    targetSurface: "today",
    targetCard: prediction.primaryAction.targetCard,
    targetHealthTab: prediction.primaryAction.targetHealthTab,
    scheduledFor: `${prediction.date}T${prediction.primaryAction.scheduledTime}:00`,
    status: "preview",
    evidence: [
      ...prediction.evidence,
      `contentId=${content.contentId}`,
      `careEventId=${eventId}`
    ],
    rateLimit: {
      maxDailyCount: 2,
      minIntervalHours: 4,
      quietHours: { start: "22:30", end: "08:00" }
    },
    payload: {
      profileId: profile.profileId,
      snapshotId: snapshot.snapshotId,
      predictionId: prediction.predictionId,
      careEventId: eventId,
      targetSurface: "today"
    }
  };
  return [event];
}

function monthFromDate(date: string) {
  return date.slice(0, 7);
}

function stampTone(index: number): HealthStampTone {
  return (["amateur", "hours", "sleepers", "steps", "gym"] as HealthStampTone[])[index] ?? "amateur";
}

function clampDay(value: number) {
  return Math.max(1, Math.min(28, Math.round(value)));
}

function buildHeatValues(seed: number, length = 21): Array<0 | 1 | 2 | 3> {
  return Array.from({ length }).map((_, index) => {
    const wave = Math.sin((index + seed) * 0.9) + Math.cos((index + seed) * 0.37);
    if ((index + seed) % 11 === 0) return 0;
    if (wave > 0.95) return 3;
    if (wave > -0.1) return 2;
    return 1;
  });
}

function countEnergyDays(values: Array<0 | 1 | 2 | 3>, direction: "high" | "low"): number {
  let count = 0;
  Array.from({ length: 7 }).forEach((_, dayIndex) => {
    const dayValues = values.slice(dayIndex * 3, dayIndex * 3 + 3);
    const average = dayValues.reduce<number>((sum, value) => sum + value, 0) / Math.max(1, dayValues.length);
    if (direction === "high" && average >= 2.35) count += 1;
    if (direction === "low" && average <= 1.25) count += 1;
  });
  return count;
}

export function createHealthInsightSummary(
  profile: BodyProfileV1,
  snapshot: HealthSnapshotV1,
  prediction: PredictionStateV1
): HealthInsightSummaryV1 {
  const remainingMetabolism = clamp(100 - Math.round(snapshot.activity.activeCalories / 500 * 100), 12, 62);
  const thisWeekRows = [
    { id: "energy" as const, label: "精力", values: buildHeatValues(prediction.scores.metabolism + snapshot.cycle.cycleDay) },
    { id: "mood" as const, label: "情绪", values: buildHeatValues(prediction.scores.cycle + snapshot.selfReport.stress) },
    { id: "stress" as const, label: "压力", values: buildHeatValues(prediction.scores.stress + snapshot.sleep.awakeMinutes) }
  ];
  const lastWeekRows = [
    { id: "energy" as const, label: "精力", values: buildHeatValues(prediction.scores.metabolism + snapshot.cycle.cycleDay - 9) },
    { id: "mood" as const, label: "情绪", values: buildHeatValues(prediction.scores.cycle + snapshot.selfReport.stress - 7) },
    { id: "stress" as const, label: "压力", values: buildHeatValues(prediction.scores.stress + snapshot.sleep.awakeMinutes - 11) }
  ];
  const highEnergyDays = countEnergyDays(thisWeekRows[0].values, "high");
  const lowEnergyDays = countEnergyDays(thisWeekRows[0].values, "low");
  const stableWindows = thisWeekRows.flatMap((row) => row.values).filter((value) => value === 2 || value === 3).length;
  const totalSignals = highEnergyDays;
  const bestWindows = lowEnergyDays;
  const sleepDebtHours = Math.max(0, Math.round((450 - snapshot.sleep.durationMinutes) / 30) / 2);
  const periodTopics = [
    `${snapshot.cycle.phaseLabel} D${clampDay(snapshot.cycle.cycleDay)}`,
    `睡眠负债 +${sleepDebtHours}`,
    `基础代谢 ${remainingMetabolism}% 未消耗`,
    `高精力 ${highEnergyDays} 天`
  ];
  return {
    schemaVersion: "HealthInsightSummaryV1",
    totalSignals,
    bestWindows,
    highEnergyDays,
    lowEnergyDays,
    highEnergyCountLabel: "高精力天",
    lowEnergyCountLabel: "低精力天",
    periodExperience: `本期经历：${periodTopics.join("、")}`,
    periodTopics,
    heatmapMode: "week",
    heatmapRange: "this_week",
    heatmapLegend: [
      { label: "高精力", color: "#42e75e" },
      { label: "平稳", color: "#42b85a" },
      { label: "低精力", color: "#d9d9df" },
      { label: "信号不足", color: "rgba(236,236,240,0.52)" }
    ],
    heatmapWindows: [
      { id: "this_week", label: "本周", rows: thisWeekRows },
      { id: "last_week", label: "上周", rows: lastWeekRows }
    ],
    heatmapRows: thisWeekRows,
    radarScores: {
      sleep: prediction.scores.sleep,
      cycle: prediction.scores.cycle,
      stress: prediction.scores.stress,
      metabolism: prediction.scores.metabolism,
      focus: prediction.scores.focus
    },
    radarLabels: ["睡眠", "周期", "抗压", "代谢", "专注"],
    explanation: `${profile.personaName}本期有 ${highEnergyDays} 天高精力、${lowEnergyDays} 天低精力，${stableWindows} 个时段接近稳态。热力图绿色越深代表越接近高精力，灰色代表低精力或信号不足。`
  };
}

function daysSince(start: string) {
  const started = new Date(start).getTime();
  if (!Number.isFinite(started)) return 1;
  return Math.max(1, Math.floor((Date.now() - started) / 86400000) + 1);
}

export function createProfileSurfaceState(
  profile: BodyProfileV1,
  snapshot: HealthSnapshotV1,
  prediction: PredictionStateV1,
  careEvents: ProactiveCareEventV1[],
  restored?: unknown
): ProfileSurfaceStateV1 {
  const previous = asRecord(restored);
  const previousWatch = asRecord(previous.watchStatus);
  const previousMembership = asRecord(previous.membershipStatus);
  return {
    schemaVersion: "ProfileSurfaceStateV1",
    displayName: asString(previous.displayName, "Scarlett"),
    encounterDays: daysSince(profile.createdAt),
    inboxEvents: [
      ...careEvents.map((event) => ({
        id: event.careEventId,
        title: event.title,
        body: event.body,
        time: event.scheduledFor.slice(11, 16),
        unread: true
      })),
      {
        id: `period-${snapshot.date}`,
        title: `${snapshot.cycle.phaseLabel}提醒`,
        body: `D${snapshot.cycle.cycleDay}，今天建议把高刺激任务往后放。`,
        time: "09:30",
        unread: false
      }
    ],
    watchStatus: {
      source: snapshot.adapterStatus === "mock_simulator" ? "mock" : "apple_health",
      title: snapshot.adapterStatus === "mock_simulator" ? "模拟器使用 Mock Adapter" : "Apple Health 已连接",
      body: snapshot.adapterStatus === "mock_simulator"
        ? "当前读取本地 mock 睡眠、周期、HRV、步数和体温变化。"
        : "正在读取睡眠、步数、HRV、静息心率、体温变化和周期字段。",
      lastSync: asString(previousWatch.lastSync, `${snapshot.date} ${new Date().toTimeString().slice(0, 5)}`)
    },
    membershipStatus: {
      tier: asString(previousMembership.tier, "free") === "plus" ? "plus" : "free",
      trialDays: asNumber(previousMembership.trialDays, 7),
      benefits: [
        "高级预测历史",
        "完整邮戳收藏册",
        "周期与睡眠趋势报告",
        "更细的主动关心频控"
      ]
    }
  };
}

export function createAchievementStamps(profile: BodyProfileV1, snapshot: HealthSnapshotV1, prediction: PredictionStateV1): AchievementStampV1[] {
  const month = monthFromDate(snapshot.date);
  const code = profile.internalCode.toLowerCase().replace(/-/g, "");
  const makeStamp = (
    index: number,
    input: Omit<AchievementStampV1, "schemaVersion" | "stampId" | "profileId" | "snapshotId" | "predictionId" | "month" | "tone" | "source" | "sourceLabel" | "sourceId" | "awardedAt"> & {
      earned: boolean;
    }
  ): AchievementStampV1 => {
    const stamp: AchievementStampV1 = {
      schemaVersion: "AchievementStampV1",
      stampId: `stamp-${month}-${input.type}-${code}`,
      profileId: profile.profileId,
      snapshotId: snapshot.snapshotId,
      predictionId: prediction.predictionId,
      month,
      title: input.title,
      type: input.type,
      tone: stampTone(index),
      source: "monthly_rule",
      sourceLabel: "月度规则",
      sourceId: month,
      assetKey: input.assetKey,
      mythicFigure: input.mythicFigure,
      oilPaintingPrompt: input.oilPaintingPrompt,
      awardRule: input.awardRule,
      evidenceLabel: input.evidenceLabel,
      reason: input.reason,
      evidence: input.evidence,
      lockedReason: input.earned ? undefined : input.lockedReason ?? input.awardRule
    };
    if (input.earned) stamp.awardedAt = nowIso();
    return stamp;
  };
  return [
    makeStamp(0, {
      title: "能量回光",
      type: "steady_recovery",
      assetKey: "stamp-energy-dori",
      mythicFigure: "阿波罗",
      oilPaintingPrompt: "Public domain classical oil painting inspired postage stamp about light returning to the body, frosted paper, collectible health stamp.",
      awardRule: "完成今日能量记录、呼吸或低刺激恢复。",
      evidenceLabel: `综合 ${prediction.todayScore}%`,
      reason: "你把今天的能量状态记录下来，让身体从高刺激里慢慢回到可预测的节奏。",
      evidence: [`综合 ${prediction.todayScore}%`, `${snapshot.cycle.phaseLabel} D${snapshot.cycle.cycleDay}`, `建议 ${prediction.primaryAction.title}`],
      lockedReason: "完成一次今日能量记录或呼吸后解锁。",
      earned: prediction.todayScore >= 60
    }),
    makeStamp(1, {
      title: "睡眠守夜",
      type: "sleep_guardian",
      assetKey: "stamp-sleep-hypnos",
      mythicFigure: "希普诺斯",
      oilPaintingPrompt: "Ancient oil painting postage stamp of Hypnos in deep blue night robes, soft moonlight, sleepy golden border, collectible stamp.",
      awardRule: "完成睡眠修复、睡前提醒，或达成睡眠建议。",
      evidenceLabel: `睡眠 ${Math.round(snapshot.sleep.durationMinutes / 60 * 10) / 10}h`,
      reason: "你守住了一次睡眠恢复窗口，明天的专注和情绪会更容易回到稳态。",
      evidence: [`睡眠分 ${prediction.scores.sleep}`, `清醒 ${snapshot.sleep.awakeMinutes} 分钟`, `效率 ${Math.round(snapshot.sleep.efficiency * 100)}%`],
      lockedReason: "再减少一次夜间清醒即可解锁。",
      earned: prediction.scores.sleep >= 78 && snapshot.sleep.awakeMinutes <= 18
    }),
    makeStamp(2, {
      title: "专注火种",
      type: "focus_muse",
      assetKey: "stamp-focus-athena",
      mythicFigure: "雅典娜",
      oilPaintingPrompt: "Oil painting postage stamp of Athena as a quiet focus muse, violet blue light, antique paper, ornate border.",
      awardRule: "完成一次专注计时，或本周专注窗口明显提升。",
      evidenceLabel: `专注分 ${prediction.scores.focus}`,
      reason: "你点燃了一段单任务时间，注意力从切换噪音里重新聚拢。",
      evidence: [`专注分 ${prediction.scores.focus}`, `压力自评 ${snapshot.selfReport.stress}/10`, `睡眠效率 ${Math.round(snapshot.sleep.efficiency * 100)}%`],
      lockedReason: "完成一次专注计时后解锁。",
      earned: prediction.scores.focus >= 76
    }),
    makeStamp(3, {
      title: "行动心跳",
      type: "movement_spark",
      assetKey: "stamp-movement-artemis",
      mythicFigure: "阿尔忒弥斯",
      oilPaintingPrompt: "Ancient oil painting postage stamp of Artemis walking under sunrise, emerald and gold frame, active but gentle health achievement.",
      awardRule: "完成代谢、晨间、散步或轻运动。",
      evidenceLabel: `${snapshot.activity.steps.toLocaleString()} steps`,
      reason: "你让身体重新有了节律，轻微行动会把低能量慢慢推回流动状态。",
      evidence: [`步数 ${snapshot.activity.steps.toLocaleString()}`, `距离 ${snapshot.activity.distanceKm.toFixed(2)} km`, `活跃消耗 ${snapshot.activity.activeCalories} kcal`],
      lockedReason: "完成一次代谢或晨间行动后解锁。",
      earned: snapshot.activity.steps >= 6000
    }),
    makeStamp(4, {
      title: "周期护符",
      type: "cycle_keeper",
      assetKey: "stamp-cycle-selene",
      mythicFigure: "塞勒涅",
      oilPaintingPrompt: "Ancient moon goddess Selene oil painting postage stamp, pearl violet cycle wheel, frosted glass moonlight, collectible stamp.",
      awardRule: "完成周期记录，或在经期/黄体期完成低刺激恢复建议。",
      evidenceLabel: `${snapshot.cycle.phaseLabel} D${snapshot.cycle.cycleDay}`,
      reason: "你把周期变化变成可被照顾的线索，身体会因此得到更温和的安排。",
      evidence: [`${snapshot.cycle.phaseLabel} D${snapshot.cycle.cycleDay}`, `预计 ${snapshot.cycle.periodPredictedInDays} 天后经期`, `症状 ${snapshot.cycle.symptoms.join("、") || "暂无"}`],
      earned: snapshot.cycle.phase === "luteal" || snapshot.cycle.phase === "menstrual"
    })
  ];
}

export function buildRuntimeStateFromPayload(payload?: RuntimePayload | unknown): VitoraRuntimeStateV1 {
  const record = asRecord(payload);
  const profileInput = record.profile ?? record.profile ?? asRecord(record.storageKeys)["vivi:user:bodyProfileV1"];
  const profile = normalizeBodyProfile(profileInput);
  const signals = record.signals ?? asRecord(record.storageKeys)["vivi:prediction:signalsV1"];
  const snapshot = buildHealthSnapshot(profile, signals);
  const prediction = predictDailyState(profile, snapshot);
  const content = composeContent(profile, snapshot, prediction);
  const careEvents = createCareEvents(profile, snapshot, prediction, content);
  const achievementStamps = createAchievementStamps(profile, snapshot, prediction);
  const healthInsight = createHealthInsightSummary(profile, snapshot, prediction);
  const profileSurface = createProfileSurfaceState(profile, snapshot, prediction, careEvents, record.profileSurface);
  return {
    runtimeVersion: "VitoraRuntimeStateV1",
    updatedAt: nowIso(),
    profile,
    snapshot,
    prediction,
    content,
    healthInsight,
    profileSurface,
    careEvents,
    activeCareEventId: careEvents[0].careEventId,
    achievementStamps,
    permissionState: (record.permissionState as VitoraRuntimeStateV1["permissionState"]) ?? {},
    storageKeys: {
      "vitora_body_profile_v1": profile,
      "vivi:user:bodyProfileV1": profile,
      "vivi:prediction:signalsV1": snapshot,
      "vivi:content:recommendationV1": content,
      "vivi:care:eventsV1": careEvents,
      "vivi:achievement:monthlyStampsV1": achievementStamps
    }
  };
}
