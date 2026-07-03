export type VitoraRuntimeKey =
  | "vitora_body_profile_v1"
  | "vivi:user:bodyProfileV1"
  | "vivi:prediction:signalsV1"
  | "vivi:content:recommendationV1"
  | "vivi:care:eventsV1"
  | "vivi:achievement:monthlyStampsV1";

export type TodayCardId = "today" | "sleep" | "cycle" | "focus" | "metabolism" | "morning";
export type HealthDetailTab = "summary" | "sleep" | "cycle" | "focus" | "metabolism" | "morning";
export type HealthStampTone = "amateur" | "sleepers" | "steps" | "gym" | "hours";
export type CareActionTypeV1 = "direct_session" | "reminder" | "map_guidance";
export type AchievementStampTypeV1 =
  | "perfect_month"
  | "most_consistent"
  | "sleep_guardian"
  | "steady_recovery"
  | "movement_spark"
  | "focus_muse"
  | "cycle_keeper";

export type BodyProfileDimensionV1 = {
  sleep: "D" | "L";
  cycle: "S" | "T";
  stress: "B" | "N";
  focus: "I" | "J";
  energy: "V" | "C";
};

export type BodyProfileV1 = {
  schemaVersion: "BodyProfileV1";
  profileId: string;
  createdAt: string;
  updatedAt: string;
  source: "onboarding" | "restored" | "default";
  compatibilityKey: "vitora_body_profile_v1";
  rawCode: string;
  internalCode: string;
  legacyAnimalName?: string;
  legacyAnimalId?: string;
  personaName: string;
  personaType: string;
  mythicReference: string;
  oneLine: string;
  dimensions: BodyProfileDimensionV1;
  traits: string[];
  risks: string[];
  recommendationBiases: {
    intensity: "low" | "medium" | "high";
    defaultMinutes: number;
    contentTypes: string[];
    tone: string;
  };
};

export type HealthSnapshotV1 = {
  schemaVersion: "HealthSnapshotV1";
  snapshotId: string;
  profileId: string;
  date: string;
  source: "apple_health" | "mock" | "mixed";
  adapterStatus: "authorized" | "mock_simulator" | "permission_missing";
  sleep: {
    durationMinutes: number;
    deepMinutes: number;
    remMinutes: number;
    awakeMinutes: number;
    efficiency: number;
    bedtime: string;
    wakeTime: string;
  };
  recovery: {
    hrvRmssd: number;
    restingHeartRate: number;
    bodyTemperatureDelta: number;
  };
  activity: {
    steps: number;
    activeCalories: number;
    distanceKm: number;
    workoutCompleted: boolean;
  };
  cycle: {
    cycleDay: number;
    phase: "menstrual" | "follicular" | "ovulation" | "luteal";
    phaseLabel: string;
    periodPredictedInDays: number;
    symptoms: string[];
  };
  selfReport: {
    goal: string;
    stress: number;
    fatigue: number;
    conversationSignals: string[];
  };
};

export type PredictionStateV1 = {
  schemaVersion: "PredictionStateV1";
  predictionId: string;
  profileId: string;
  snapshotId: string;
  date: string;
  todayScore: number;
  confidence: "low" | "medium" | "high";
  phaseLabel: string;
  scores: {
    sleep: number;
    focus: number;
    stress: number;
    cycle: number;
    metabolism: number;
    morning: number;
    readiness: number;
  };
  scoreBreakdown: TodayScoreBreakdownV1;
  scoreDeltas: {
    sleep: number;
    focus: number;
    metabolism: number;
    morning: number;
  };
  primaryAction: {
    actionId: string;
    actionType: CareActionTypeV1;
    title: string;
    reason: string;
    session: string;
    push: string;
    scheduledTime: string;
    targetCard: TodayCardId;
    targetHealthTab: HealthDetailTab;
  };
  drivers: {
    good: string[];
    bad: string[];
  };
  evidence: string[];
};

export type TodayScoreBreakdownV1 = {
  schemaVersion: "TodayScoreBreakdownV1";
  baseScore: number;
  totalScore: number;
  chips: Array<{
    id: "sleep" | "cycle" | "focus" | "stress" | "metabolism" | "morning";
    label: string;
    value: string;
    contribution: number;
    score: number;
    status: "normal" | "warning";
  }>;
  explanation: string;
};

export type TodayStatusRailItemV1 = TodayScoreBreakdownV1["chips"][number] & {
  id: "sleep" | "cycle" | "focus" | "stress";
};

export type TodayCardRuntimeV1 = {
  id: TodayCardId;
  label: string;
  chipValue: string;
  title: string;
  subtitle: string;
  score: string;
  scoreUnit?: string;
  tone: "energy" | "sleep" | "cycle" | "focus" | "metabolism" | "morning";
  moreTab: HealthDetailTab;
  monitor: string;
  action: string;
  actionType: CareActionTypeV1;
  status: "normal" | "warning";
};

export type HealthSuggestionV1 = {
  icon: string;
  time: string;
  title: string;
  copy: string;
  action: string;
  tone?: "green" | "purple";
};

export type HealthDetailContentV1 = {
  title: string;
  body: string;
  scoreLabel: string;
  evidence: string[];
  suggestions: HealthSuggestionV1[];
};

export type ContentRecommendationV1 = {
  schemaVersion: "ContentRecommendationV1";
  contentId: string;
  profileId: string;
  snapshotId: string;
  predictionId: string;
  date: string;
  todayCards: TodayCardRuntimeV1[];
  healthTitle: string;
  healthSummary: string;
  healthMetrics: {
    readiness: string;
    sleepDebt: string;
    informationDebt: string;
    average: string;
  };
  healthDetails: Record<HealthDetailTab, HealthDetailContentV1>;
};

export type HealthInsightSummaryV1 = {
  schemaVersion: "HealthInsightSummaryV1";
  totalSignals: number;
  bestWindows: number;
  highEnergyDays: number;
  lowEnergyDays: number;
  periodExperience: string;
  periodTopics: string[];
  heatmapRange: "this_week" | "last_week";
  heatmapLegend: Array<{
    label: string;
    color: string;
  }>;
  heatmapWindows: Array<{
    id: "this_week" | "last_week";
    label: string;
    rows: Array<{
      id: "energy" | "mood" | "stress";
      label: string;
      values: Array<0 | 1 | 2 | 3>;
    }>;
  }>;
  heatmapRows: Array<{
    id: "energy" | "mood" | "stress";
    label: string;
    values: Array<0 | 1 | 2 | 3>;
  }>;
  radarScores: {
    sleep: number;
    cycle: number;
    stress: number;
    metabolism: number;
    focus: number;
  };
  explanation: string;
};

export type ProfileSurfaceStateV1 = {
  schemaVersion: "ProfileSurfaceStateV1";
  displayName: string;
  encounterDays: number;
  inboxEvents: Array<{
    id: string;
    title: string;
    body: string;
    time: string;
    unread: boolean;
  }>;
  watchStatus: {
    source: "mock" | "apple_health";
    title: string;
    body: string;
    lastSync: string;
  };
  membershipStatus: {
    tier: "free" | "plus";
    trialDays: number;
    benefits: string[];
  };
};

export type ProactiveCareEventV1 = {
  schemaVersion: "ProactiveCareEventV1";
  careEventId: string;
  profileId: string;
  snapshotId: string;
  predictionId: string;
  contentId: string;
  date: string;
  title: string;
  body: string;
  trigger: "sleep_drop" | "hrv_drop" | "cycle_window" | "workout_done" | "conversation_fatigue";
  targetSurface: "today" | "health";
  targetCard: TodayCardId;
  targetHealthTab: HealthDetailTab;
  scheduledFor: string;
  status: "preview" | "scheduled" | "sent" | "opened";
  evidence: string[];
  rateLimit: {
    maxDailyCount: number;
    minIntervalHours: number;
    quietHours: { start: string; end: string };
  };
  payload: {
    profileId: string;
    snapshotId: string;
    predictionId: string;
    careEventId: string;
    targetSurface: "today" | "health";
  };
};

export type AchievementStampV1 = {
  schemaVersion: "AchievementStampV1";
  stampId: string;
  profileId: string;
  snapshotId: string;
  predictionId: string;
  month: string;
  title: string;
  type: AchievementStampTypeV1;
  tone: HealthStampTone;
  source: "monthly_rule" | "today_action" | "conversation_stamp";
  sourceLabel: string;
  sourceId?: string;
  assetKey: string;
  mythicFigure: string;
  oilPaintingPrompt: string;
  awardRule: string;
  evidenceLabel: string;
  lockedReason?: string;
  reason: string;
  evidence: string[];
  awardedAt?: string;
};

export type VitoraRuntimeStateV1 = {
  runtimeVersion: "VitoraRuntimeStateV1";
  updatedAt: string;
  profile: BodyProfileV1;
  snapshot: HealthSnapshotV1;
  prediction: PredictionStateV1;
  content: ContentRecommendationV1;
  healthInsight: HealthInsightSummaryV1;
  profileSurface: ProfileSurfaceStateV1;
  careEvents: ProactiveCareEventV1[];
  activeCareEventId: string;
  achievementStamps: AchievementStampV1[];
  permissionState: Record<string, boolean | string | number | null>;
  storageKeys: Record<VitoraRuntimeKey, unknown>;
};
