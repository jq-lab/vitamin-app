import { Asset } from "expo-asset";
import { createAudioPlayer } from "expo-audio";
import type { AudioPlayer } from "expo-audio";
import { BlurView } from "expo-blur";
import * as FileSystem from "expo-file-system/legacy";
import * as ImagePicker from "expo-image-picker";
import { LinearGradient } from "expo-linear-gradient";
import { StatusBar } from "expo-status-bar";
import {
  AppState,
  AppStateStatus,
  ActivityIndicator,
  Alert,
  Animated,
  Easing,
  Image,
  ImageBackground,
  Linking,
  PanResponder,
  Pressable,
  ScrollView,
  Share,
  StyleSheet,
  Text,
  TextInput,
  View
} from "react-native";
import { useEffect, useRef, useState } from "react";
import type { ReactNode } from "react";
import { WebView } from "react-native-webview";
import { SIMULATOR_WEB_PATCH } from "./src/simulatorWebPatch";
import { buildRuntimeStateFromPayload } from "./src/lib/vitora/runtime";
import type { AchievementStampV1, VitoraRuntimeStateV1 } from "./src/lib/vitora/types";

declare const process:
  | {
      env?: Record<string, string | undefined>;
    }
  | undefined;

const CACHE_ROOT = `${FileSystem.cacheDirectory ?? ""}vivi-oura-web/`;
const RUNTIME_STATE_FILE = `${FileSystem.documentDirectory || FileSystem.cacheDirectory || ""}vitora-runtime-v1.json`;
const APP_DEMO_QUERY = "openTab=today";
const REMOTE_WEB_BASE_URI = "http://127.0.0.1:8822/vivi-oura-simulator/web/index.html";
const TTS_BRIDGE_URL = process?.env?.EXPO_PUBLIC_TTS_BRIDGE_URL || "http://127.0.0.1:8787";
const TTS_BRIDGE_POLL_MS = 4500;
const FALLBACK_TRANSPARENT_PNG =
  "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/p9sAAAAASUVORK5CYII=";

type WebAsset = {
  module: number;
  target: string;
};

type NativeTab = "today" | "explore" | "health";
type ExploreRoute = "home" | "detail" | "chat" | "feedback";
type HealthRoute = "home" | "detail";
type HealthDetailTab = "summary" | "sleep" | "cycle" | "focus" | "metabolism";
type TodayCardId = "today" | "sleep" | "cycle" | "focus" | "metabolism" | "morning";
type TodayRoute = "home" | "breathing" | "focusTimer" | "metabolismTimer" | "morningMap";
type HealthDetailSource = TodayCardId | "cycle" | "health";
type ProfilePanel = "inbox" | "info" | "editName" | "stamps" | "archive" | "watch" | "vip" | null;
type HealthMetricKey = "averageEnergy" | "sleep" | "focus" | "stress" | "metabolism";
type ReminderSheetState = {
  source: string;
  time: string;
} | null;
type TodayCard = {
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
  actionType: "direct_session" | "reminder" | "map_guidance";
  status: "normal" | "warning";
};
type TodayNavCircle = Pick<TodayCard, "id" | "label" | "chipValue" | "tone" | "status">;
type TodayToneTheme = {
  base: string;
  washTop: string;
  bottomGlow: string;
  bottomGlowStrong: string;
  accent: string;
  text: string;
  mutedText: string;
  button: string;
  buttonText: string;
};
type ExploreTheme = {
  id: string;
  tag: string;
  title: string;
  prompt: string;
  image: number;
  lead: string;
  detailTitle: string;
};
type NativeMessage = {
  id?: string;
  role: "ai" | "user";
  kind?: "text" | "audio";
  text: string;
  audioUrl?: string;
  audioText?: string;
  voiceId?: string;
  audioStatus?: "loading" | "ready" | "failed";
  createdAt?: string;
  animatedOnce?: boolean;
};
type TtsBridgeMessage = {
  audioId?: string;
  audioUrl?: string;
  text?: string;
  audioText?: string;
  voiceId?: string;
  messageId?: string;
  persona?: string;
  reason?: string;
  createdAt?: string;
  targetSurface?: "today" | "explore" | "both";
};
type NativeChatMode = "explore" | "energy";
type ChatInputMode = "keyboard" | "voice" | "quickActions";
type NativeReplyContext = {
  mode: NativeChatMode;
  personaName: string;
  todayScore: number;
  cycleLabel: string;
  sleepChip?: string;
  focusChip?: string;
  stressChip?: string;
  primaryAction: string;
  primaryReason: string;
  primaryPush: string;
  evidence: string[];
};
type EnergyRecordState = "idle" | "recording" | "saving" | "saved";
type BreathingBackgroundId = "mist" | "forest" | "moon";
type EnergyLiveCardV1 = {
  id: string;
  imageUri: string | null;
  score: number;
  advice: string;
  createdAt: string;
  source: "photo" | "sample";
};
type HealthStampTone = "amateur" | "sleepers" | "steps" | "gym" | "hours";
type StampRevealSheetState = {
  stamp: AchievementStampV1;
  mode: "award" | "detail";
  expanded: boolean;
} | null;
type VitoraOnboardingBridgePayload = {
  scope?: string;
  open?: boolean;
  completed?: boolean;
  profile?: unknown;
  signals?: unknown;
  prediction?: unknown;
  content?: unknown;
  permissionState?: Record<string, boolean | string | number | null>;
};

const HEALTH_DETAIL_TABS: { id: HealthDetailTab; label: string }[] = [
  { id: "summary", label: "综合" },
  { id: "sleep", label: "睡眠" },
  { id: "cycle", label: "周期" },
  { id: "focus", label: "专注" },
  { id: "metabolism", label: "代谢" }
];

const TODAY_NAV_ORDER: TodayCardId[] = ["today", "sleep", "cycle", "focus", "metabolism", "morning"];

const UI = {
  colors: {
    pageBg: "#f8f6f5",
    textPrimary: "#111827",
    textSecondary: "#5f6670",
    textMuted: "#8d949c",
    surface: "#ffffff",
    surfaceSoft: "#f1f0ef",
    surfaceElevated: "rgba(255,255,255,0.92)",
    accent: "#8f7bff",
    accentSoft: "#e9e4ff",
    success: "#2ccf7b",
    danger: "#ff4a53",
    inkOnDark: "#ffffff"
  },
  type: {
    display: { fontSize: 38, lineHeight: 44, fontWeight: "900" as const },
    title: { fontSize: 24, lineHeight: 30, fontWeight: "900" as const },
    sectionTitle: { fontSize: 20, lineHeight: 25, fontWeight: "900" as const },
    bodyStrong: { fontSize: 16, lineHeight: 23, fontWeight: "900" as const },
    body: { fontSize: 15, lineHeight: 22, fontWeight: "700" as const },
    caption: { fontSize: 12, lineHeight: 17, fontWeight: "800" as const },
    chip: { fontSize: 12, lineHeight: 16, fontWeight: "900" as const }
  },
  radius: {
    circle: 999,
    card: 26,
    panel: 22,
    pill: 999
  },
  spacing: {
    pageX: 18,
    cardX: 18
  },
  sizes: {
    todayNavCircle: 68,
    bottomTabHeight: 54,
    bottomTabButtonWidth: 58,
    bottomTabButtonHeight: 44,
    bottomPlus: 54
  }
};

const ENERGY_QUICK_QUESTIONS = ["为什么今天能量低？", "我现在适合做什么？", "帮我设一个提醒"];
const BREATHING_AUDIO_SOURCE = require("./web/voice-bakeoff/audio/selection_edge_ghost_soft.mp3");
const ENERGY_LIVE_CARD_FALLBACK_IMAGE = require("./web/assets/pillowtalk/gallery/moon_full_bleed.png");
const BREATHING_BACKGROUNDS: { id: BreathingBackgroundId; label: string; colors: [string, string, string] }[] = [
  { id: "mist", label: "雾气", colors: ["#edf6f1", "#c9d8cf", "#182221"] },
  { id: "forest", label: "林间", colors: ["#eff8f0", "#9fb99f", "#1c2821"] },
  { id: "moon", label: "月光", colors: ["#f3f0ff", "#9fa4c5", "#141724"] }
];

const STAMP_ASSET_IMAGES: Record<string, number> = {
  "stamp-perfect-goddess": require("./assets/stamps/stamp-perfect-goddess.png"),
  "stamp-consistency-flame": require("./assets/stamps/stamp-consistency-flame.png"),
  "stamp-sleep-hypnos": require("./assets/stamps/stamp-sleep-hypnos.png"),
  "stamp-recovery-hygieia": require("./assets/stamps/stamp-recovery-hygieia.png"),
  "stamp-movement-artemis": require("./assets/stamps/stamp-movement-artemis.png"),
  "stamp-focus-athena": require("./assets/stamps/stamp-focus-athena.png"),
  "stamp-cycle-selene": require("./assets/stamps/stamp-cycle-selene.png"),
  "stamp-energy-dori": require("./assets/stamps/stamp-energy-dori.png"),
  "stamp-conversation-dream": require("./assets/stamps/stamp-conversation-dream.png")
};

const createNativeMessage = (role: NativeMessage["role"], text: string): NativeMessage => ({
  id: `msg-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`,
  role,
  kind: "text",
  text,
  createdAt: new Date().toISOString()
});

const createNativeAudioMessage = (payload: TtsBridgeMessage): NativeMessage => ({
  id: payload.messageId || payload.audioId || `audio-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`,
  role: "ai",
  kind: "audio",
  text: payload.audioText || payload.text || "Dori 语音",
  audioText: payload.audioText || payload.text || "",
  audioUrl: payload.audioUrl,
  voiceId: payload.voiceId,
  audioStatus: payload.audioUrl ? "ready" : "failed",
  createdAt: payload.createdAt || new Date().toISOString()
});

function TypewriterText({
  text,
  enabled,
  style,
  onDone
}: {
  text: string;
  enabled: boolean;
  style?: any;
  onDone?: () => void;
}) {
  const [visibleText, setVisibleText] = useState(enabled ? "" : text);

  useEffect(() => {
    if (!enabled) {
      setVisibleText(text);
      return;
    }
    setVisibleText("");
    let index = 0;
    const timer = setInterval(() => {
      index += 1;
      setVisibleText(text.slice(0, index));
      if (index >= text.length) {
        clearInterval(timer);
        onDone?.();
      }
    }, 18);
    return () => clearInterval(timer);
  }, [enabled, text]);

  return <Text style={style}>{visibleText || " "}</Text>;
}

const TODAY_TONE_THEMES: Record<TodayCard["tone"], TodayToneTheme> = {
  energy: {
    base: "#f7c160",
    washTop: "rgba(255,205,196,0.68)",
    bottomGlow: "rgba(232,224,198,0.90)",
    bottomGlowStrong: "rgba(255,246,202,0.58)",
    accent: "#a994ff",
    text: "#ffffff",
    mutedText: "rgba(255,255,255,0.88)",
    button: "rgba(255,255,255,0.94)",
    buttonText: "#171d25"
  },
  sleep: {
    base: "#beddf4",
    washTop: "rgba(192,231,255,0.92)",
    bottomGlow: "rgba(232,227,213,0.92)",
    bottomGlowStrong: "rgba(214,196,241,0.42)",
    accent: "#eb5bc4",
    text: "#ffffff",
    mutedText: "rgba(255,255,255,0.86)",
    button: "rgba(255,255,255,0.94)",
    buttonText: "#1b2430"
  },
  cycle: {
    base: "#b7eee8",
    washTop: "rgba(170,232,225,0.92)",
    bottomGlow: "rgba(231,235,221,0.92)",
    bottomGlowStrong: "rgba(169,139,255,0.34)",
    accent: "#f02e91",
    text: "#ffffff",
    mutedText: "rgba(255,255,255,0.88)",
    button: "rgba(255,255,255,0.94)",
    buttonText: "#17212c"
  },
  focus: {
    base: "#dce4f7",
    washTop: "rgba(244,206,229,0.74)",
    bottomGlow: "rgba(235,236,232,0.94)",
    bottomGlowStrong: "rgba(204,216,255,0.46)",
    accent: "#f0df45",
    text: "#ffffff",
    mutedText: "rgba(255,255,255,0.88)",
    button: "rgba(255,255,255,0.94)",
    buttonText: "#18202b"
  },
  metabolism: {
    base: "#e7b449",
    washTop: "rgba(118,120,116,0.70)",
    bottomGlow: "rgba(255,219,152,0.94)",
    bottomGlowStrong: "rgba(255,188,47,0.38)",
    accent: "#ffd65b",
    text: "#ffffff",
    mutedText: "rgba(255,255,255,0.88)",
    button: "rgba(255,255,255,0.94)",
    buttonText: "#1a2028"
  },
  morning: {
    base: "#eee3df",
    washTop: "rgba(214,214,212,0.88)",
    bottomGlow: "rgba(238,215,211,0.92)",
    bottomGlowStrong: "rgba(255,239,157,0.42)",
    accent: "#ecd84c",
    text: "#ffffff",
    mutedText: "rgba(255,255,255,0.82)",
    button: "rgba(255,255,255,0.94)",
    buttonText: "#171d25"
  }
};

const DOT_MATRIX: Record<string, string[]> = {
  "0": ["111", "101", "101", "101", "111"],
  "1": ["010", "110", "010", "010", "111"],
  "2": ["111", "001", "111", "100", "111"],
  "3": ["111", "001", "111", "001", "111"],
  "4": ["101", "101", "111", "001", "001"],
  "5": ["111", "100", "111", "001", "111"],
  "6": ["111", "100", "111", "101", "111"],
  "7": ["111", "001", "010", "010", "010"],
  "8": ["111", "101", "111", "101", "111"],
  "9": ["111", "101", "111", "001", "111"],
  ":": ["0", "1", "0", "1", "0"],
  ".": ["0", "0", "0", "0", "1"],
  "-": ["0", "0", "1", "0", "0"],
  "+": ["0", "1", "1", "1", "0"]
};

const TODAY_REFERENCE_IMAGES: Record<TodayCardId, number> = {
  today: require("./assets/today-reference/energy.png"),
  sleep: require("./assets/today-reference/sleep.png"),
  cycle: require("./assets/today-reference/cycle.png"),
  focus: require("./assets/today-reference/focus.png"),
  metabolism: require("./assets/today-reference/metabolism.png"),
  morning: require("./assets/today-reference/morning.png")
};

const TODAY_CARD_ART_IMAGES: Record<TodayCardId, number> = {
  today: require("./assets/today-card-art/today.png"),
  sleep: require("./assets/today-card-art/sleep.png"),
  cycle: require("./assets/today-card-art/cycle.png"),
  focus: require("./assets/today-card-art/focus.png"),
  metabolism: require("./assets/today-card-art/metabolism.png"),
  morning: require("./assets/today-card-art/morning.png")
};

const TODAY_CARD_ART_RATIOS: Record<TodayCardId, number> = {
  today: 1664 / 1918,
  sleep: 1652 / 1866,
  cycle: 1800 / 1758,
  focus: 1668 / 1902,
  metabolism: 1636 / 1910,
  morning: 1700 / 1898
};

function DotMatrixText({
  value,
  dot = 7,
  gap = 5,
  color = "#fff",
  style
}: {
  value: string | number;
  dot?: number;
  gap?: number;
  color?: string;
  style?: object;
}) {
  return (
    <View style={[{ flexDirection: "row", alignItems: "center", justifyContent: "center", gap: dot }, style]}>
      {String(value).split("").map((char, charIndex) => {
        const matrix = DOT_MATRIX[char] ?? DOT_MATRIX["0"];
        return (
          <View key={`${char}-${charIndex}`} style={{ gap }}>
            {matrix.map((row, rowIndex) => (
              <View key={`${char}-${charIndex}-${rowIndex}`} style={{ flexDirection: "row", gap }}>
                {row.split("").map((cell, cellIndex) => (
                  <View
                    key={`${char}-${charIndex}-${rowIndex}-${cellIndex}`}
                    style={{
                      width: dot,
                      height: dot,
                      borderRadius: dot / 2,
                      backgroundColor: cell === "1" ? color : "transparent"
                    }}
                  />
                ))}
              </View>
            ))}
          </View>
        );
      })}
    </View>
  );
}

const REMINDER_QUICK_TIMES = ["09:30", "13:00", "18:30", "21:30"];
const TODAY_CARDS: TodayCard[] = [
  {
    id: "today",
    label: "今日",
    chipValue: "80%",
    title: "今日能量",
    subtitle: "今日黄体期适合温和行动和保护恢复窗口。",
    score: "70",
    tone: "energy",
    moreTab: "summary",
    monitor: "综合今日得分 80%，睡眠拉高恢复窗口，下午适合低刺激推进。",
    action: "开始 4 分钟呼吸",
    actionType: "direct_session",
    status: "normal"
  },
  {
    id: "sleep",
    label: "睡眠",
    chipValue: "+30",
    title: "睡眠",
    subtitle: "昨晚睡眠连续性会影响下午专注和恢复速度。",
    score: "7",
    scoreUnit: "h",
    tone: "sleep",
    moreTab: "sleep",
    monitor: "睡眠为今日加分项 +30；建议补足 20 分钟睡眠修复。",
    action: "开始第 1 级睡眠修复",
    actionType: "reminder",
    status: "normal"
  },
  {
    id: "cycle",
    label: "周期",
    chipValue: "D18",
    title: "周期 D18 天",
    subtitle: "当前可能更容易疲惫、轻水肿、食欲波动、情绪敏感。",
    score: "18",
    scoreUnit: "天",
    tone: "cycle",
    moreTab: "cycle",
    monitor: "周期进入低刺激窗口；建议用温和恢复替代高强度推进。",
    action: "开始第 1 级低刺激恢复",
    actionType: "direct_session",
    status: "warning"
  },
  {
    id: "focus",
    label: "专注",
    chipValue: "-30",
    title: "专注",
    subtitle: "检测到你的专注程度较低，下午切换工作的成本较高。",
    score: "25",
    scoreUnit: "分钟",
    tone: "focus",
    moreTab: "focus",
    monitor: "专注为今日减分项 -30；先做单任务专注，再恢复输入信息。",
    action: "开始第 1 级专注",
    actionType: "direct_session",
    status: "warning"
  },
  {
    id: "metabolism",
    label: "代谢",
    chipValue: "-15",
    title: "代谢",
    subtitle: "昨晚睡眠连续性会影响下午专注和恢复速度。",
    score: "4,151",
    tone: "metabolism",
    moreTab: "metabolism",
    monitor: "代谢负担 -15；建议下午 3:00 加餐恢复，避免硬扛。",
    action: "代谢开启",
    actionType: "direct_session",
    status: "warning"
  },
  {
    id: "morning",
    label: "晨间",
    chipValue: "+10",
    title: "晨间计划",
    subtitle: "当前可能更容易疲惫、轻水肿、食欲波动、情绪敏感。",
    score: "29.60",
    scoreUnit: "KM",
    tone: "morning",
    moreTab: "summary",
    monitor: "晨间启动 +10；自然光和轻走会帮助今天更早进入稳态。",
    action: "打开晨间路线",
    actionType: "map_guidance",
    status: "normal"
  }
];

function SoftGradientBackground({ children }: { children: ReactNode }) {
  return (
    <LinearGradient colors={["#ffffff", "#f1effb", "#e6e6e2"]} locations={[0, 0.48, 1]} style={styles.softGradientBase}>
      <View style={styles.softGradientContent}>{children}</View>
    </LinearGradient>
  );
}

const EXPLORE_THEMES: ExploreTheme[] = [
  {
    id: "inspiration",
    tag: "灵感",
    title: "哪一句话今天抓住了你？",
    prompt: "保存一句今天让你有感觉的话",
    image: require("./web/assets/pillowtalk/gallery/sky_color_full_bleed.png"),
    lead: "把今天抓住你的句子放在这里",
    detailTitle: "灵感句子"
  },
  {
    id: "thought",
    tag: "意识",
    title: "这一刻你反复想到什么？",
    prompt: "把脑海里反复出现的念头放在这里",
    image: require("./web/assets/pillowtalk/gallery/comet_full_bleed.png"),
    lead: "观察那个反复回来的念头",
    detailTitle: "意识线索"
  },
  {
    id: "relationship",
    tag: "关系",
    title: "探索你的关系模式",
    prompt: "今天世界无事发生，可以好好歇着，等一切安静下来",
    image: require("./web/assets/pillowtalk/gallery/moon_full_bleed.png"),
    lead: "想想你是如何与他人建立联系的",
    detailTitle: "探索你的关系模式"
  },
  {
    id: "dream",
    tag: "梦想",
    title: "你对其中一个梦有什么印象？",
    prompt: "写下一个梦里留下来的画面",
    image: require("./web/assets/pillowtalk/gallery/saturn_full_bleed.png"),
    lead: "把醒来后仍然清晰的画面留下来",
    detailTitle: "梦境回想"
  }
];

function initialNativeMessages(theme: ExploreTheme): NativeMessage[] {
  return [
    createNativeMessage("ai", "今天开心不，我陪你聊会儿天，会在合适的时机为你显影情绪 Live 卡片"),
    createNativeMessage("ai", theme.id === "relationship" ? "还好呀！你呢，今天和谁的关系最占心思？" : "还好呀！你呢，今天怎么样？")
  ];
}

function nativeReply(text: string, context?: NativeReplyContext) {
  if (context?.mode === "energy") {
    const normalized = text.replace(/\s+/g, "");
    const evidenceLine = context.evidence.filter((item) => !/[a-zA-Z]+Id=/.test(item)).slice(0, 2).join("；");
    const evidenceCopy = evidenceLine ? `${evidenceLine}。` : "";
    if (/为什么|原因|能量低|低|扣分|多少/.test(normalized)) {
      return `今天综合数据是 ${context.todayScore}%，主因是${context.cycleLabel}，睡眠 ${context.sleepChip ?? "稳定"}、专注 ${context.focusChip ?? "波动"}、抗压 ${context.stressChip ?? "需观察"}叠加。${evidenceCopy}所以我会优先建议你做「${context.primaryAction}」，而不是硬推高强度任务。`;
    }
    if (/现在|适合|做什么|建议|行动/.test(normalized)) {
      return `现在最适合做一个低门槛动作：${context.primaryAction}。原因是${context.primaryReason}。如果你只有 5 分钟，就先把呼吸、喝水或轻走完成；如果你有 25 分钟，再进入单任务专注。`;
    }
    if (/提醒|推送|设置|几点/.test(normalized)) {
      return `可以，我会按今天的状态给你安排提醒：${context.primaryPush}。这类提醒会和 Today 卡、健康详情、油戳记录使用同一组 predictionId，不会变成孤立通知。`;
    }
    if (/睡|困|累|恢复/.test(normalized)) {
      return `你今天不需要证明自己很能扛。${context.personaName}当前更适合先恢复连续性：降低切换、减少刺激、把最重要的事压成一个小动作。完成后我会把它记录到今日油戳里。`;
    }
    return `我读到的是：${text}。结合今天 ${context.todayScore}% 的综合状态，我建议先从「${context.primaryAction}」开始。你也可以继续问我为什么、现在做什么，或者让我帮你设提醒。`;
  }
  if (/梦|海|漂|水|画面/.test(text)) return "这个画面里有一种漂在中间的感觉。你像是在找岸，也像是在确认自己要去哪里。";
  if (/关系|朋友|家人|误会|吵|想/.test(text)) return "这里有一种想被理解、又不想继续解释的拉扯。你最希望对方看见你的哪一部分？";
  if (/累|焦虑|烦|压力|难过|开心/.test(text)) return "先不用急着把它变好。我们可以先给它一个名字，再看看身体在哪里最先感受到它。";
  return "我在。继续补一个细节就好：一个颜色、一个人物、一个动作，或者最先冒出来的一句话。";
}

function shiftClockTime(time: string, deltaMinutes: number) {
  const [hourValue, minuteValue] = time.split(":").map((part) => Number.parseInt(part, 10));
  const hour = Number.isFinite(hourValue) ? hourValue : 9;
  const minute = Number.isFinite(minuteValue) ? minuteValue : 30;
  const total = (hour * 60 + minute + deltaMinutes + 24 * 60) % (24 * 60);
  const nextHour = Math.floor(total / 60);
  const nextMinute = total % 60;
  return `${String(nextHour).padStart(2, "0")}:${String(nextMinute).padStart(2, "0")}`;
}

const WEB_ASSETS: WebAsset[] = [
  { module: require("./web/index.html"), target: "index.html" },
  { module: require("./web/assets/onboarding/vitora-onboarding-full-background.mp4"), target: "assets/onboarding/vitora-onboarding-full-background.mp4" },
  { module: require("./web/assets/backgrounds/cycle-warm.jpg"), target: "assets/backgrounds/cycle-warm.jpg" },
  { module: require("./web/assets/backgrounds/readiness-high.jpg"), target: "assets/backgrounds/readiness-high.jpg" },
  { module: require("./web/assets/backgrounds/readiness-low.jpg"), target: "assets/backgrounds/readiness-low.jpg" },
  { module: require("./web/assets/backgrounds/readiness-mid.jpg"), target: "assets/backgrounds/readiness-mid.jpg" },
  { module: require("./web/assets/backgrounds/sleep-night.jpg"), target: "assets/backgrounds/sleep-night.jpg" },
  { module: require("./web/assets/ecosystems/china-high.jpg"), target: "assets/ecosystems/china-high.jpg" },
  { module: require("./web/assets/ecosystems/china-low.jpg"), target: "assets/ecosystems/china-low.jpg" },
  { module: require("./web/assets/ecosystems/china-mid.jpg"), target: "assets/ecosystems/china-mid.jpg" },
  { module: require("./web/assets/ecosystems/iceland-high.jpg"), target: "assets/ecosystems/iceland-high.jpg" },
  { module: require("./web/assets/ecosystems/iceland-low.jpg"), target: "assets/ecosystems/iceland-low.jpg" },
  { module: require("./web/assets/ecosystems/iceland-mid.jpg"), target: "assets/ecosystems/iceland-mid.jpg" },
  { module: require("./web/assets/ecosystems/indonesia-high.jpg"), target: "assets/ecosystems/indonesia-high.jpg" },
  { module: require("./web/assets/ecosystems/indonesia-low.jpg"), target: "assets/ecosystems/indonesia-low.jpg" },
  { module: require("./web/assets/ecosystems/indonesia-mid.jpg"), target: "assets/ecosystems/indonesia-mid.jpg" },
  { module: require("./web/assets/ecosystems/japan-high.jpg"), target: "assets/ecosystems/japan-high.jpg" },
  { module: require("./web/assets/ecosystems/japan-low.jpg"), target: "assets/ecosystems/japan-low.jpg" },
  { module: require("./web/assets/ecosystems/japan-mid.jpg"), target: "assets/ecosystems/japan-mid.jpg" },
  { module: require("./web/assets/ecosystems/norway-high.jpg"), target: "assets/ecosystems/norway-high.jpg" },
  { module: require("./web/assets/ecosystems/norway-low.jpg"), target: "assets/ecosystems/norway-low.jpg" },
  { module: require("./web/assets/ecosystems/norway-mid.jpg"), target: "assets/ecosystems/norway-mid.jpg" },
  { module: require("./web/assets/ecosystems/usa-high.jpg"), target: "assets/ecosystems/usa-high.jpg" },
  { module: require("./web/assets/ecosystems/usa-low.jpg"), target: "assets/ecosystems/usa-low.jpg" },
  { module: require("./web/assets/ecosystems/usa-mid.jpg"), target: "assets/ecosystems/usa-mid.jpg" },
  { module: require("./web/assets/life-galaxy/life_galaxy_core_crop.jpg"), target: "assets/life-galaxy/life_galaxy_core_crop.jpg" },
  { module: require("./web/assets/planet-cloud/cutout/ref-1.png"), target: "assets/planet-cloud/cutout/ref-1.png" },
  { module: require("./web/assets/planet-cloud/cutout/ref-2.png"), target: "assets/planet-cloud/cutout/ref-2.png" },
  { module: require("./web/assets/planet-cloud/cutout/ref-3.png"), target: "assets/planet-cloud/cutout/ref-3.png" },
  { module: require("./web/assets/planet-cloud/cutout/ref-4.png"), target: "assets/planet-cloud/cutout/ref-4.png" },
  { module: require("./web/assets/planet-cloud/cutout/ref-5.png"), target: "assets/planet-cloud/cutout/ref-5.png" },
  { module: require("./web/assets/planet-cloud/reference/ref-1.png"), target: "assets/planet-cloud/reference/ref-1.png" },
  { module: require("./web/assets/planet-cloud/reference/ref-2.png"), target: "assets/planet-cloud/reference/ref-2.png" },
  { module: require("./web/assets/planet-cloud/reference/ref-3.png"), target: "assets/planet-cloud/reference/ref-3.png" },
  { module: require("./web/assets/planet-cloud/reference/ref-4.png"), target: "assets/planet-cloud/reference/ref-4.png" },
  { module: require("./web/assets/planet-cloud/reference/ref-5.png"), target: "assets/planet-cloud/reference/ref-5.png" },
  { module: require("./web/assets/weekly-theme-planets/cycle-bloom.png"), target: "assets/weekly-theme-planets/cycle-bloom.png" },
  { module: require("./web/assets/weekly-theme-planets/healing.png"), target: "assets/weekly-theme-planets/healing.png" },
  { module: require("./web/assets/weekly-theme-planets/protection.png"), target: "assets/weekly-theme-planets/protection.png" },
  { module: require("./web/assets/weekly-theme-planets/sleep-rest.png"), target: "assets/weekly-theme-planets/sleep-rest.png" },
  { module: require("./web/assets/weekly-theme-planets/vitality.png"), target: "assets/weekly-theme-planets/vitality.png" },
  { module: require("./web/assets/weekly-planets/cycle-bloom/activity.webp"), target: "assets/weekly-planets/cycle-bloom/activity.webp" },
  { module: require("./web/assets/weekly-planets/cycle-bloom/cycle.webp"), target: "assets/weekly-planets/cycle-bloom/cycle.webp" },
  { module: require("./web/assets/weekly-planets/cycle-bloom/main.webp"), target: "assets/weekly-planets/cycle-bloom/main.webp" },
  { module: require("./web/assets/weekly-planets/cycle-bloom/recovery.webp"), target: "assets/weekly-planets/cycle-bloom/recovery.webp" },
  { module: require("./web/assets/weekly-planets/cycle-bloom/sleep.webp"), target: "assets/weekly-planets/cycle-bloom/sleep.webp" },
  { module: require("./web/assets/weekly-planets/cycle-bloom/stress.webp"), target: "assets/weekly-planets/cycle-bloom/stress.webp" },
  { module: require("./web/assets/weekly-planets/healing/activity.webp"), target: "assets/weekly-planets/healing/activity.webp" },
  { module: require("./web/assets/weekly-planets/healing/cycle.webp"), target: "assets/weekly-planets/healing/cycle.webp" },
  { module: require("./web/assets/weekly-planets/healing/main.webp"), target: "assets/weekly-planets/healing/main.webp" },
  { module: require("./web/assets/weekly-planets/healing/recovery.webp"), target: "assets/weekly-planets/healing/recovery.webp" },
  { module: require("./web/assets/weekly-planets/healing/sleep.webp"), target: "assets/weekly-planets/healing/sleep.webp" },
  { module: require("./web/assets/weekly-planets/healing/stress.webp"), target: "assets/weekly-planets/healing/stress.webp" },
  { module: require("./web/assets/weekly-planets/protection/activity.webp"), target: "assets/weekly-planets/protection/activity.webp" },
  { module: require("./web/assets/weekly-planets/protection/cycle.webp"), target: "assets/weekly-planets/protection/cycle.webp" },
  { module: require("./web/assets/weekly-planets/protection/main.webp"), target: "assets/weekly-planets/protection/main.webp" },
  { module: require("./web/assets/weekly-planets/protection/recovery.webp"), target: "assets/weekly-planets/protection/recovery.webp" },
  { module: require("./web/assets/weekly-planets/protection/sleep.webp"), target: "assets/weekly-planets/protection/sleep.webp" },
  { module: require("./web/assets/weekly-planets/protection/stress.webp"), target: "assets/weekly-planets/protection/stress.webp" },
  { module: require("./web/assets/weekly-planets/stable/activity.webp"), target: "assets/weekly-planets/stable/activity.webp" },
  { module: require("./web/assets/weekly-planets/stable/cycle.webp"), target: "assets/weekly-planets/stable/cycle.webp" },
  { module: require("./web/assets/weekly-planets/stable/main.webp"), target: "assets/weekly-planets/stable/main.webp" },
  { module: require("./web/assets/weekly-planets/stable/recovery.webp"), target: "assets/weekly-planets/stable/recovery.webp" },
  { module: require("./web/assets/weekly-planets/stable/sleep.webp"), target: "assets/weekly-planets/stable/sleep.webp" },
  { module: require("./web/assets/weekly-planets/stable/stress.webp"), target: "assets/weekly-planets/stable/stress.webp" },
  { module: require("./web/assets/weekly-planets/vitality/activity.webp"), target: "assets/weekly-planets/vitality/activity.webp" },
  { module: require("./web/assets/weekly-planets/vitality/cycle.webp"), target: "assets/weekly-planets/vitality/cycle.webp" },
  { module: require("./web/assets/weekly-planets/vitality/main.webp"), target: "assets/weekly-planets/vitality/main.webp" },
  { module: require("./web/assets/weekly-planets/vitality/recovery.webp"), target: "assets/weekly-planets/vitality/recovery.webp" },
  { module: require("./web/assets/weekly-planets/vitality/sleep.webp"), target: "assets/weekly-planets/vitality/sleep.webp" },
  { module: require("./web/assets/weekly-planets/vitality/stress.webp"), target: "assets/weekly-planets/vitality/stress.webp" },
  { module: require("./web/assets/pillowtalk/invite-home.png"), target: "assets/pillowtalk/invite-home.png" },
  { module: require("./web/assets/pillowtalk/relationship-card.png"), target: "assets/pillowtalk/relationship-card.png" },
  { module: require("./web/assets/pillowtalk/dream-prompt.png"), target: "assets/pillowtalk/dream-prompt.png" },
  { module: require("./web/assets/pillowtalk/inspiration-quote.png"), target: "assets/pillowtalk/inspiration-quote.png" },
  { module: require("./web/assets/pillowtalk/text-chat.png"), target: "assets/pillowtalk/text-chat.png" },
  { module: require("./web/assets/pillowtalk/talk-preparing.png"), target: "assets/pillowtalk/talk-preparing.png" },
  { module: require("./web/assets/pillowtalk/analysis-loading.png"), target: "assets/pillowtalk/analysis-loading.png" },
  { module: require("./web/assets/pillowtalk/analysis-result.png"), target: "assets/pillowtalk/analysis-result.png" },
  { module: require("./web/assets/pillowtalk/feeling-tags.png"), target: "assets/pillowtalk/feeling-tags.png" },
  { module: require("./web/assets/pillowtalk/unlock-next-mode.png"), target: "assets/pillowtalk/unlock-next-mode.png" },
  { module: require("./web/assets/pillowtalk/streak-summary.png"), target: "assets/pillowtalk/streak-summary.png" },
  { module: require("./web/assets/pillowtalk/lowcode/01_home_invite_green.png"), target: "assets/pillowtalk/lowcode/01_home_invite_green.png" },
  { module: require("./web/assets/pillowtalk/lowcode/02_theme_relationship_moon.png"), target: "assets/pillowtalk/lowcode/02_theme_relationship_moon.png" },
  { module: require("./web/assets/pillowtalk/lowcode/03_theme_dream_saturn.png"), target: "assets/pillowtalk/lowcode/03_theme_dream_saturn.png" },
  { module: require("./web/assets/pillowtalk/lowcode/04_theme_inspiration_green_quote.png"), target: "assets/pillowtalk/lowcode/04_theme_inspiration_green_quote.png" },
  { module: require("./web/assets/pillowtalk/lowcode/05_analysis_result_moon.png"), target: "assets/pillowtalk/lowcode/05_analysis_result_moon.png" },
  { module: require("./web/assets/pillowtalk/lowcode/06_feeling_tags_duck.png"), target: "assets/pillowtalk/lowcode/06_feeling_tags_duck.png" },
  { module: require("./web/assets/pillowtalk/lowcode/07_unlock_next_mode_moon.png"), target: "assets/pillowtalk/lowcode/07_unlock_next_mode_moon.png" },
  { module: require("./web/assets/pillowtalk/lowcode/08_streak_summary_green.png"), target: "assets/pillowtalk/lowcode/08_streak_summary_green.png" },
  { module: require("./web/assets/pillowtalk/lowcode/09_chat_live_card_duck.png"), target: "assets/pillowtalk/lowcode/09_chat_live_card_duck.png" },
  { module: require("./web/assets/pillowtalk/gallery/moon_raw.png"), target: "assets/pillowtalk/gallery/moon_raw.png" },
  { module: require("./web/assets/pillowtalk/gallery/moon_card_portrait.png"), target: "assets/pillowtalk/gallery/moon_card_portrait.png" },
  { module: require("./web/assets/pillowtalk/gallery/moon_card_square.png"), target: "assets/pillowtalk/gallery/moon_card_square.png" },
  { module: require("./web/assets/pillowtalk/gallery/moon_full_bleed.png"), target: "assets/pillowtalk/gallery/moon_full_bleed.png" },
  { module: require("./web/assets/pillowtalk/gallery/saturn_raw.png"), target: "assets/pillowtalk/gallery/saturn_raw.png" },
  { module: require("./web/assets/pillowtalk/gallery/saturn_card_portrait.png"), target: "assets/pillowtalk/gallery/saturn_card_portrait.png" },
  { module: require("./web/assets/pillowtalk/gallery/saturn_card_square.png"), target: "assets/pillowtalk/gallery/saturn_card_square.png" },
  { module: require("./web/assets/pillowtalk/gallery/saturn_full_bleed.png"), target: "assets/pillowtalk/gallery/saturn_full_bleed.png" },
  { module: require("./web/assets/pillowtalk/gallery/live_duck_raw.png"), target: "assets/pillowtalk/gallery/live_duck_raw.png" },
  { module: require("./web/assets/pillowtalk/gallery/live_duck_card_portrait.png"), target: "assets/pillowtalk/gallery/live_duck_card_portrait.png" },
  { module: require("./web/assets/pillowtalk/gallery/live_duck_card_square.png"), target: "assets/pillowtalk/gallery/live_duck_card_square.png" },
  { module: require("./web/assets/pillowtalk/gallery/live_duck_full_bleed.png"), target: "assets/pillowtalk/gallery/live_duck_full_bleed.png" },
  { module: require("./web/assets/pillowtalk/gallery/sky_color_raw.png"), target: "assets/pillowtalk/gallery/sky_color_raw.png" },
  { module: require("./web/assets/pillowtalk/gallery/sky_color_card_portrait.png"), target: "assets/pillowtalk/gallery/sky_color_card_portrait.png" },
  { module: require("./web/assets/pillowtalk/gallery/sky_color_card_square.png"), target: "assets/pillowtalk/gallery/sky_color_card_square.png" },
  { module: require("./web/assets/pillowtalk/gallery/sky_color_full_bleed.png"), target: "assets/pillowtalk/gallery/sky_color_full_bleed.png" },
  { module: require("./web/assets/pillowtalk/gallery/green_spark_raw.png"), target: "assets/pillowtalk/gallery/green_spark_raw.png" },
  { module: require("./web/assets/pillowtalk/gallery/green_spark_card_portrait.png"), target: "assets/pillowtalk/gallery/green_spark_card_portrait.png" },
  { module: require("./web/assets/pillowtalk/gallery/green_spark_card_square.png"), target: "assets/pillowtalk/gallery/green_spark_card_square.png" },
  { module: require("./web/assets/pillowtalk/gallery/green_spark_full_bleed.png"), target: "assets/pillowtalk/gallery/green_spark_full_bleed.png" },
  { module: require("./web/assets/pillowtalk/gallery/comet_raw.png"), target: "assets/pillowtalk/gallery/comet_raw.png" },
  { module: require("./web/assets/pillowtalk/gallery/comet_card_portrait.png"), target: "assets/pillowtalk/gallery/comet_card_portrait.png" },
  { module: require("./web/assets/pillowtalk/gallery/comet_card_square.png"), target: "assets/pillowtalk/gallery/comet_card_square.png" },
  { module: require("./web/assets/pillowtalk/gallery/comet_full_bleed.png"), target: "assets/pillowtalk/gallery/comet_full_bleed.png" },
  { module: require("./web/ip-cloud/apng/01_peek_idle.apng"), target: "ip-cloud/apng/01_peek_idle.apng" },
  { module: require("./web/ip-cloud/apng/02_tap_wakeup.apng"), target: "ip-cloud/apng/02_tap_wakeup.apng" },
  { module: require("./web/ip-cloud/apng/03_listening_voice.apng"), target: "ip-cloud/apng/03_listening_voice.apng" },
  { module: require("./web/ip-cloud/apng/04_speaking_reply.apng"), target: "ip-cloud/apng/04_speaking_reply.apng" },
  { module: require("./web/ip-cloud/apng/05_thinking.apng"), target: "ip-cloud/apng/05_thinking.apng" },
  { module: require("./web/ip-cloud/apng/06_happy_good_state.apng"), target: "ip-cloud/apng/06_happy_good_state.apng" },
  { module: require("./web/ip-cloud/apng/07_sleepy_recovery.apng"), target: "ip-cloud/apng/07_sleepy_recovery.apng" },
  { module: require("./web/ip-cloud/apng/08_stress_dizzy.apng"), target: "ip-cloud/apng/08_stress_dizzy.apng" },
  { module: require("./web/ip-cloud/apng/09_eating_craving.apng"), target: "ip-cloud/apng/09_eating_craving.apng" },
  { module: require("./web/ip-cloud/apng/10_reading_learning.apng"), target: "ip-cloud/apng/10_reading_learning.apng" },
  { module: require("./web/voice-bakeoff/audio/edge_neural_ghost_soft_ai_reply_short.mp3"), target: "voice-bakeoff/audio/edge_neural_ghost_soft_ai_reply_short.mp3" },
  { module: require("./web/voice-bakeoff/audio/edge_neural_ghost_soft_sleep_recovery_weak.mp3"), target: "voice-bakeoff/audio/edge_neural_ghost_soft_sleep_recovery_weak.mp3" },
  { module: require("./web/voice-bakeoff/audio/edge_neural_ghost_soft_stress_attention.mp3"), target: "voice-bakeoff/audio/edge_neural_ghost_soft_stress_attention.mp3" },
  { module: require("./web/voice-bakeoff/audio/edge_neural_ghost_soft_today_ready.mp3"), target: "voice-bakeoff/audio/edge_neural_ghost_soft_today_ready.mp3" },
  { module: require("./web/voice-bakeoff/audio/selection_edge_ghost_soft.mp3"), target: "voice-bakeoff/audio/selection_edge_ghost_soft.mp3" }
];

function dirname(uri: string) {
  return uri.slice(0, uri.lastIndexOf("/"));
}

async function copyBundledAsset({ module, target }: WebAsset) {
  const asset = Asset.fromModule(module);
  const downloaded = await asset.downloadAsync();

  const to = `${CACHE_ROOT}${target}`;
  await FileSystem.makeDirectoryAsync(dirname(to), { intermediates: true });

  const candidates = [downloaded.localUri, asset.localUri, asset.uri].filter(
    (uri): uri is string => Boolean(uri)
  );
  for (const from of candidates) {
    try {
      const info = await FileSystem.getInfoAsync(from);
      if (info.exists) {
        await FileSystem.copyAsync({ from, to });
        return;
      }
    } catch {
      // Non-file asset URIs are not copyable here; keep looking for a local file.
    }
  }

  if (target.startsWith("assets/weekly-theme-planets/")) {
    await FileSystem.writeAsStringAsync(to, FALLBACK_TRANSPARENT_PNG, {
      encoding: FileSystem.EncodingType.Base64
    });
    return;
  }

  throw new Error(`Missing local URI for ${target}`);
}

async function prepareWebBundle() {
  if (!FileSystem.cacheDirectory) {
    throw new Error("FileSystem cache directory is unavailable.");
  }

  await FileSystem.deleteAsync(CACHE_ROOT, { idempotent: true });
  await FileSystem.makeDirectoryAsync(CACHE_ROOT, { intermediates: true });
  await Promise.all(WEB_ASSETS.map(copyBundledAsset));
  return `${CACHE_ROOT}index.html`;
}

function withQuery(uri: string, query: string) {
  return `${uri}${uri.includes("?") ? "&" : "?"}${query}`;
}

function withCacheBuster(uri: string, key: string) {
  return withQuery(uri, `${key}=${Date.now()}`);
}

function withAppDemoQuery(uri: string) {
  return APP_DEMO_QUERY ? withQuery(uri, APP_DEMO_QUERY) : uri;
}

const APP_QUERY_KEYS = ["openTab", "tab", "demo", "onboarding", "showOnboarding", "healthSummary"];
const SIMULATOR_WEB_PATCH_WITH_PROBE = `
(function () {
  var report = function (message) {
    try {
      window.ReactNativeWebView && window.ReactNativeWebView.postMessage(JSON.stringify({
        scope: "vitora-native-patch",
        message: message,
        href: String(location.href || ""),
        readyState: String(document.readyState || "")
      }));
    } catch (_) {}
  };
  report("bootstrap");
  try {
${SIMULATOR_WEB_PATCH}
    report("patch-ok");
  } catch (error) {
    report("patch-error:" + String(error && error.message ? error.message : error));
  }
})();
true;
`;

function queryFromAppUrl(url: string | null) {
  if (!url) return "";
  const marker = url.indexOf("?");
  if (marker < 0) return "";
  const rawQuery = url.slice(marker + 1).split("#")[0];
  const incoming = new URLSearchParams(rawQuery);
  const forwarded = new URLSearchParams();
  for (const key of APP_QUERY_KEYS) {
    const value = incoming.get(key);
    if (value) forwarded.set(key, value);
  }
  return forwarded.toString();
}

function withRuntimeQuery(uri: string, query: string) {
  if (query) return withQuery(uri, query);
  return withAppDemoQuery(uri);
}

function remoteUriForQuery(query: string) {
  return withRuntimeQuery(REMOTE_WEB_BASE_URI, query);
}

function buildRuntimeStorageInjection(state: VitoraRuntimeStateV1) {
  const runtimeJson = JSON.stringify(state);
  const storageLines = Object.entries(state.storageKeys)
    .map(([key, value]) => `localStorage.setItem(${JSON.stringify(key)}, ${JSON.stringify(JSON.stringify(value))});`)
    .join("\n");
  return `
(function () {
  try {
    var runtime = ${runtimeJson};
    window.VITORA_RUNTIME_STATE_V1 = runtime;
    localStorage.setItem("vivi:runtime:stateV1", JSON.stringify(runtime));
    ${storageLines}
  } catch (_) {}
})();
true;
`;
}

const DEFAULT_RUNTIME_STATE = buildRuntimeStateFromPayload();

export default function App() {
  const webViewRef = useRef<any>(null);
  const todayNavScrollRef = useRef<ScrollView>(null);
  const todayInputRef = useRef<TextInput>(null);
  const nativeInputRef = useRef<TextInput>(null);
  const [localWebUri, setLocalWebUri] = useState<string | null>(null);
  const [webSourceUri, setWebSourceUri] = useState<string>("");
  const [runtimeQuery, setRuntimeQuery] = useState<string>("");
  const [error, setError] = useState<string | null>(null);
  const [nativeTab, setNativeTab] = useState<NativeTab>("today");
  const [exploreRoute, setExploreRoute] = useState<ExploreRoute>("home");
  const [healthRoute, setHealthRoute] = useState<HealthRoute>("home");
  const [healthDetailTab, setHealthDetailTab] = useState<HealthDetailTab>("summary");
  const [healthDetailSource, setHealthDetailSource] = useState<HealthDetailSource>("health");
  const [healthDateOffset, setHealthDateOffset] = useState(0);
  const [todayActiveId, setTodayActiveId] = useState<TodayCardId>("today");
  const [todayRoute, setTodayRoute] = useState<TodayRoute>("home");
  const [focusMinutes, setFocusMinutes] = useState(25);
  const [sleepTargetMinutes, setSleepTargetMinutes] = useState(Math.round(DEFAULT_RUNTIME_STATE.snapshot.sleep.durationMinutes / 15) * 15);
  const [sleepWindowShift, setSleepWindowShift] = useState(0);
  const [healthHeatmapRange, setHealthHeatmapRange] = useState<"this_week" | "last_week">("this_week");
  const [sleepTrendRange, setSleepTrendRange] = useState<"7" | "30" | "90">("7");
  const [reminderSheet, setReminderSheet] = useState<ReminderSheetState>(null);
  const [activeThemeId, setActiveThemeId] = useState(EXPLORE_THEMES[0].id);
  const [nativeMessages, setNativeMessages] = useState<NativeMessage[]>(() => initialNativeMessages(EXPLORE_THEMES[0]));
  const [energyMessages, setEnergyMessages] = useState<NativeMessage[]>([]);
  const [typedMessageIds, setTypedMessageIds] = useState<Record<string, boolean>>({});
  const [nativeChatMode, setNativeChatMode] = useState<NativeChatMode>("explore");
  const [chatInputMode, setChatInputMode] = useState<ChatInputMode>("keyboard");
  const [chatMenuOpen, setChatMenuOpen] = useState(false);
  const [voiceListening, setVoiceListening] = useState(false);
  const [energyRecordState, setEnergyRecordState] = useState<EnergyRecordState>("idle");
  const [energyLiveCards, setEnergyLiveCards] = useState<EnergyLiveCardV1[]>([]);
  const [energyVoiceCueActive, setEnergyVoiceCueActive] = useState(false);
  const [breathingSoundOn, setBreathingSoundOn] = useState(false);
  const [breathingBackground, setBreathingBackground] = useState<BreathingBackgroundId>("mist");
  const [breathingExpanded, setBreathingExpanded] = useState(false);
  const [playingAudioMessageId, setPlayingAudioMessageId] = useState<string | null>(null);
  const [expandedAudioMessageIds, setExpandedAudioMessageIds] = useState<Record<string, boolean>>({});
  const [draft, setDraft] = useState("");
  const [profileOpen, setProfileOpen] = useState(false);
  const [profilePanel, setProfilePanel] = useState<ProfilePanel>(null);
  const [profileNameDraft, setProfileNameDraft] = useState(DEFAULT_RUNTIME_STATE.profileSurface.displayName);
  const [toast, setToast] = useState("");
  const [onboardingOpen, setOnboardingOpen] = useState(false);
  const [onboardingCompleted, setOnboardingCompleted] = useState(false);
  const [nativeLayerReady, setNativeLayerReady] = useState(false);
  const [vitoraState, setVitoraState] = useState<VitoraRuntimeStateV1>(DEFAULT_RUNTIME_STATE);
  const [stampSheet, setStampSheet] = useState<StampRevealSheetState>(null);
  const [activeCareEventId, setActiveCareEventId] = useState(DEFAULT_RUNTIME_STATE.activeCareEventId);
  const [seenTodayCards, setSeenTodayCards] = useState<Record<string, boolean>>({});
  const [referenceOverlayVisible, setReferenceOverlayVisible] = useState(false);
  const [referenceOverlayOpacity, setReferenceOverlayOpacity] = useState(0.28);
  const [activeFogThemeId, setActiveFogThemeId] = useState<string | null>(null);
  const [sessionStartedAt, setSessionStartedAt] = useState<number | null>(null);
  const [activeSessionTitle, setActiveSessionTitle] = useState("");
  const [completedTodayActions, setCompletedTodayActions] = useState<string[]>([]);
  const [nowTick, setNowTick] = useState(() => Date.now());
  const cardIntroAnim = useRef(new Animated.Value(0)).current;
  const heartPulseAnim = useRef(new Animated.Value(1)).current;
  const pinGlowAnim = useRef(new Animated.Value(0)).current;
  const energyFlowAnim = useRef(new Animated.Value(0)).current;
  const breathingPlayerRef = useRef<AudioPlayer | null>(null);
  const audioPlayersRef = useRef<Record<string, AudioPlayer>>({});
  const seenTtsAudioIdsRef = useRef<Record<string, boolean>>({});
  const ttsBridgeCursorRef = useRef(new Date(Date.now() - 15000).toISOString());

  const activeCareEvent =
    vitoraState.careEvents.find((event) => event.careEventId === activeCareEventId) ??
    vitoraState.careEvents[0] ??
    DEFAULT_RUNTIME_STATE.careEvents[0]!;
  const activeToneTheme = TODAY_TONE_THEMES[(vitoraState.content.todayCards.find((card) => card.id === todayActiveId) ?? vitoraState.content.todayCards[0]).tone];
  const activeSessionElapsed = sessionStartedAt ? Math.max(0, Math.floor((nowTick - sessionStartedAt) / 1000)) : 0;
  const shiftDate = (isoDate: string, offset: number) => {
    const base = new Date(`${isoDate}T12:00:00`);
    if (!Number.isFinite(base.getTime())) return isoDate;
    base.setDate(base.getDate() + offset);
    return `${base.getFullYear()}-${String(base.getMonth() + 1).padStart(2, "0")}-${String(base.getDate()).padStart(2, "0")}`;
  };
  const healthDetailDate = shiftDate(vitoraState.snapshot.date, healthDateOffset);
  const cycleDayForOffset = ((vitoraState.snapshot.cycle.cycleDay + healthDateOffset - 1 + 280) % 28) + 1;
  const healthDetailState = healthDateOffset === 0
    ? vitoraState
    : buildRuntimeStateFromPayload({
      profile: vitoraState.profile,
      permissionState: vitoraState.permissionState,
      signals: {
        date: healthDetailDate,
        health: {
          sleepMinutes: Math.max(360, Math.min(500, vitoraState.snapshot.sleep.durationMinutes + ((healthDateOffset % 3) - 1) * 18)),
          deepSleepMinutes: Math.max(52, vitoraState.snapshot.sleep.deepMinutes + (healthDateOffset % 2) * 8),
          awakenings: Math.max(1, Math.round(vitoraState.snapshot.sleep.awakeMinutes / 9) + (healthDateOffset % 2)),
          hrv: Math.max(24, vitoraState.snapshot.recovery.hrvRmssd + (healthDateOffset % 4) * 3 - 4),
          restingHeartRate: Math.max(56, vitoraState.snapshot.recovery.restingHeartRate - (healthDateOffset % 3)),
          skinTempDelta: Math.round((vitoraState.snapshot.recovery.bodyTemperatureDelta + (healthDateOffset % 4) * 0.02) * 100) / 100,
          steps: Math.max(3200, vitoraState.snapshot.activity.steps + healthDateOffset * 220)
        },
        cycle: {
          cycleDay: cycleDayForOffset,
          symptoms: { fatigue: cycleDayForOffset > 18 ? 2 : 1, mood: cycleDayForOffset > 20 ? 2 : 1, bloating: cycleDayForOffset > 16 ? 2 : 0 }
        },
        selfReport: {
          goal: vitoraState.snapshot.selfReport.goal,
          mood: cycleDayForOffset > 18 ? "tense" : "steady",
          fatigue: cycleDayForOffset > 18 ? 2 : 1
        }
      }
    });
  const activeHealthState = healthRoute === "detail" ? healthDetailState : vitoraState;
  const sleepDisplayHours = Math.max(5, Math.min(9, Math.round(sleepTargetMinutes / 60)));
  const sleepBedTime = shiftClockTime(vitoraState.snapshot.sleep.bedtime, sleepWindowShift * 15);
  const sleepWakeTime = shiftClockTime(vitoraState.snapshot.sleep.wakeTime, sleepWindowShift * -10);
  const activeHeatmapWindow = (state: VitoraRuntimeStateV1) =>
    state.healthInsight.heatmapWindows.find((window) => window.id === healthHeatmapRange) ?? state.healthInsight.heatmapWindows[0];
  const sleepDebtDisplay = (state: VitoraRuntimeStateV1) => {
    const raw = state.content.healthMetrics.sleepDebt.trim();
    return raw.includes("小时") ? raw : `${raw} 小时`;
  };
  const personaSummaryLabel = (state: VitoraRuntimeStateV1) => `${state.profile.personaName}低敏感`;
  const healthExperienceRows = (state: VitoraRuntimeStateV1) => [
    `${state.snapshot.cycle.phaseLabel} D${state.snapshot.cycle.cycleDay}`,
    `睡眠负债 ${sleepDebtDisplay(state)}`,
    `基础代谢 ${Math.max(0, 100 - state.prediction.scores.metabolism)}% 未消耗`
  ].slice(0, 3);
  const monthlyEnergyValues = (state: VitoraRuntimeStateV1): Array<0 | 1 | 2 | 3> => {
    const seed = state.prediction.scores.readiness + state.prediction.scores.focus + state.snapshot.cycle.cycleDay;
    return Array.from({ length: 30 }).map((_, index) => {
      const wave = Math.sin((seed + index * 3) * 0.37) + Math.cos((seed - index) * 0.21);
      if ((index + seed) % 13 === 0) return 0;
      if (wave > 0.82) return 3;
      if (wave < -0.78) return 1;
      return 2;
    });
  };
  const monthlyEnergyCounts = (state: VitoraRuntimeStateV1) => {
    const values = monthlyEnergyValues(state);
    return {
      high: values.filter((value) => value === 3).length,
      low: values.filter((value) => value === 1).length,
      steady: values.filter((value) => value === 2).length,
      missing: values.filter((value) => value === 0).length
    };
  };
  const stampCodeFor = (stamp: AchievementStampV1) => {
    const month = stamp.month.replace("-", "");
    const code =
      stamp.type === "sleep_guardian" ? "SLEEP" :
        stamp.type === "focus_muse" ? "FOCUS" :
          stamp.type === "movement_spark" ? "MOVE" :
            stamp.type === "cycle_keeper" ? "CYCLE" : "ENERGY";
    return `VTR-${month}-${code}-001`;
  };

  const mergeMessagesById = (current: NativeMessage[], incoming: NativeMessage[]) => {
    const existing = new Set(current.map((message) => message.id).filter(Boolean));
    const next = incoming.filter((message) => !message.id || !existing.has(message.id));
    return next.length ? [...current, ...next] : current;
  };

  const toggleAudioTranscript = (messageId: string) => {
    setExpandedAudioMessageIds((current) => ({ ...current, [messageId]: !current[messageId] }));
  };

  const toggleAudioMessagePlayback = (message: NativeMessage) => {
    if (!message.audioUrl || !message.id) {
      setToast("这条语音还没有可播放的音频");
      return;
    }
    try {
      if (playingAudioMessageId === message.id) {
        audioPlayersRef.current[message.id]?.pause();
        setPlayingAudioMessageId(null);
        return;
      }
      if (playingAudioMessageId) {
        audioPlayersRef.current[playingAudioMessageId]?.pause();
      }
      if (!audioPlayersRef.current[message.id]) {
        const player = createAudioPlayer(message.audioUrl, { updateInterval: 500, downloadFirst: true });
        player.volume = 1;
        audioPlayersRef.current[message.id] = player;
      }
      audioPlayersRef.current[message.id]?.play();
      setPlayingAudioMessageId(message.id);
    } catch {
      setToast("语音播放失败，请确认 TTS bridge 可以访问");
      setPlayingAudioMessageId(null);
    }
  };

  const appendTtsBridgeMessages = (messages: TtsBridgeMessage[]) => {
    const fresh = messages.filter((message) => {
      const key = message.messageId || message.audioId || message.audioUrl;
      if (!key || seenTtsAudioIdsRef.current[key]) return false;
      seenTtsAudioIdsRef.current[key] = true;
      return true;
    });
    if (!fresh.length) return;
    const todayMessages = fresh
      .filter((message) => message.targetSurface !== "explore")
      .map(createNativeAudioMessage);
    const exploreMessages = fresh
      .filter((message) => message.targetSurface === "explore" || message.targetSurface === "both")
      .map(createNativeAudioMessage);

    if (todayMessages.length) {
      setEnergyMessages((current) => mergeMessagesById(current, todayMessages));
    }
    if (exploreMessages.length) {
      setNativeMessages((current) => mergeMessagesById(current, exploreMessages));
    }

    const latestCreatedAt = fresh
      .map((message) => message.createdAt)
      .filter((value): value is string => Boolean(value))
      .sort()
      .at(-1);
    if (latestCreatedAt) {
      ttsBridgeCursorRef.current = latestCreatedAt;
    }
  };

  useEffect(() => {
    const timer = setInterval(() => setNowTick(Date.now()), 1000);
    return () => clearInterval(timer);
  }, []);

  useEffect(() => {
    const key = todayActiveId;
    if (seenTodayCards[key]) {
      cardIntroAnim.setValue(1);
      return;
    }
    cardIntroAnim.setValue(0);
    Animated.timing(cardIntroAnim, {
      toValue: 1,
      duration: 720,
      easing: Easing.out(Easing.cubic),
      useNativeDriver: true
    }).start(() => {
      setSeenTodayCards((seen) => ({ ...seen, [key]: true }));
    });
  }, [cardIntroAnim, seenTodayCards, todayActiveId]);

  useEffect(() => {
    const pulse = Animated.loop(
      Animated.sequence([
        Animated.timing(heartPulseAnim, { toValue: 1.08, duration: 620, easing: Easing.inOut(Easing.quad), useNativeDriver: true }),
        Animated.timing(heartPulseAnim, { toValue: 1, duration: 720, easing: Easing.inOut(Easing.quad), useNativeDriver: true })
      ])
    );
    pulse.start();
    return () => pulse.stop();
  }, [heartPulseAnim]);

  useEffect(() => {
    const glow = Animated.loop(
      Animated.sequence([
        Animated.timing(pinGlowAnim, { toValue: 1, duration: 920, easing: Easing.inOut(Easing.quad), useNativeDriver: true }),
        Animated.timing(pinGlowAnim, { toValue: 0, duration: 1100, easing: Easing.inOut(Easing.quad), useNativeDriver: true })
      ])
    );
    glow.start();
    return () => glow.stop();
  }, [pinGlowAnim]);

  useEffect(() => {
    const flow = Animated.loop(
      Animated.sequence([
        Animated.timing(energyFlowAnim, { toValue: 1, duration: 1600, easing: Easing.inOut(Easing.quad), useNativeDriver: true }),
        Animated.timing(energyFlowAnim, { toValue: 0, duration: 1800, easing: Easing.inOut(Easing.quad), useNativeDriver: true })
      ])
    );
    flow.start();
    return () => flow.stop();
  }, [energyFlowAnim]);

  useEffect(() => {
    return () => {
      try {
        breathingPlayerRef.current?.pause();
      } catch {
        // The player can already be released while the native runtime is tearing down.
      }
      Object.values(audioPlayersRef.current).forEach((player) => {
        try {
          player.pause();
        } catch {
          // Remote audio players may already be released during native teardown.
        }
      });
      audioPlayersRef.current = {};
      breathingPlayerRef.current = null;
    };
  }, []);

  useEffect(() => {
    let cancelled = false;
    const pollBridge = async () => {
      try {
        const url = `${TTS_BRIDGE_URL.replace(/\/+$/, "")}/api/tts/messages?since=${encodeURIComponent(ttsBridgeCursorRef.current)}`;
        const response = await fetch(url);
        if (!response.ok) return;
        const payload = (await response.json()) as { messages?: TtsBridgeMessage[] };
        if (cancelled || !Array.isArray(payload.messages)) return;
        appendTtsBridgeMessages(payload.messages);
      } catch {
        // The bridge is optional in the simulator; stay silent when it is not running.
      }
    };

    void pollBridge();
    const timer = setInterval(() => void pollBridge(), TTS_BRIDGE_POLL_MS);
    return () => {
      cancelled = true;
      clearInterval(timer);
    };
  }, []);

  const syncRuntimeToWebView = (state: VitoraRuntimeStateV1 = vitoraState) => {
    webViewRef.current?.injectJavaScript(buildRuntimeStorageInjection(state));
  };

  const applyVitoraRuntimeState = (next: VitoraRuntimeStateV1) => {
    setVitoraState(next);
    setActiveCareEventId(next.activeCareEventId);
    FileSystem.writeAsStringAsync(RUNTIME_STATE_FILE, JSON.stringify(next)).catch((error: unknown) => {
      console.log(`[VitoraRuntime] persist failed: ${String(error)}`);
    });
    syncRuntimeToWebView(next);
  };

  const refreshWebSource = () => {
    const source = localWebUri ? withRuntimeQuery(localWebUri, runtimeQuery) : remoteUriForQuery(runtimeQuery);
    setWebSourceUri(withCacheBuster(source, "_ts"));
  };

  useEffect(() => {
    let cancelled = false;

    prepareWebBundle()
      .then((uri) => {
        if (!cancelled) {
          setLocalWebUri(uri);
        }
      })
      .catch((err: unknown) => {
        if (!cancelled) {
          setError(err instanceof Error ? err.message : String(err));
        }
      });

    return () => {
      cancelled = true;
    };
  }, []);

  useEffect(() => {
    let cancelled = false;
    FileSystem.readAsStringAsync(RUNTIME_STATE_FILE)
      .then((raw) => {
        if (cancelled) return;
        const parsed = JSON.parse(raw) as VitoraRuntimeStateV1;
        const next = buildRuntimeStateFromPayload(parsed);
        setVitoraState(next);
        setActiveCareEventId(next.activeCareEventId);
      })
      .catch(() => {});
    return () => {
      cancelled = true;
    };
  }, []);

  useEffect(() => {
    let mounted = true;
    const applyNativeRoute = (url: string | null) => {
      if (!url) return;
      const marker = url.indexOf("?");
      if (marker < 0) return;
      const incoming = new URLSearchParams(url.slice(marker + 1).split("#")[0]);
      const nextTab = incoming.get("nativeTab") as NativeTab | null;
      const nextRoute = incoming.get("nativeRoute") as ExploreRoute | null;
      const nextHealthRoute = incoming.get("healthRoute") as HealthRoute | null;
      const nextHealthTab = incoming.get("healthTab") as HealthDetailTab | null;
      const nextToday = incoming.get("today") as TodayCardId | null;
      const nextTodayRoute = incoming.get("todayRoute") as TodayRoute | null;
      const nextThemeId = incoming.get("theme");
      const energyQuestion = incoming.get("energyQuestion");
      const nextTheme = EXPLORE_THEMES.find((theme) => theme.id === nextThemeId) ?? activeTheme;
      if (nextThemeId) setActiveThemeId(nextTheme.id);
      if (nextTab === "today") {
        setNativeTab("today");
        setTodayRoute("home");
        if (!nextToday) setTodayActiveId("today");
      } else if (nextTab === "explore" || nextTab === "health") {
        setNativeTab(nextTab);
      }
      if (nextToday === "today" || nextToday === "sleep" || nextToday === "cycle" || nextToday === "focus" || nextToday === "metabolism" || nextToday === "morning") {
        setNativeTab("today");
        setTodayActiveId(nextToday);
      }
      if (nextTodayRoute === "home" || nextTodayRoute === "breathing") {
        setNativeTab("today");
        setTodayRoute(nextTodayRoute);
      }
      if (nextTodayRoute === "focusTimer" || nextTodayRoute === "metabolismTimer" || nextTodayRoute === "morningMap") {
        setNativeTab("today");
        setTodayRoute(nextTodayRoute);
      }
      if (nextRoute === "home" || nextRoute === "detail" || nextRoute === "chat" || nextRoute === "feedback") {
        setNativeTab("explore");
        setExploreRoute(nextRoute);
        if (nextRoute === "chat") setNativeMessages(initialNativeMessages(nextTheme));
      }
      if (incoming.get("energyChat") === "1") {
        openEnergyChat(energyQuestion ?? undefined);
      }
      if (nextHealthRoute === "home" || nextHealthRoute === "detail") {
        setNativeTab("health");
        setHealthRoute(nextHealthRoute);
      }
      if (nextHealthTab === "summary" || nextHealthTab === "sleep" || nextHealthTab === "cycle" || nextHealthTab === "focus" || nextHealthTab === "metabolism") {
        setNativeTab("health");
        setHealthRoute("detail");
        setHealthDetailTab(nextHealthTab);
      }
      if (incoming.get("profile") === "1") setProfileOpen(true);
      if (incoming.get("profile") === "0") setProfileOpen(false);
    };
    const applyUrl = (url: string | null) => {
      applyNativeRoute(url);
      const query = queryFromAppUrl(url);
      if (!query) return;
      setRuntimeQuery(query);
      const source = localWebUri ? withRuntimeQuery(localWebUri, query) : remoteUriForQuery(query);
      setWebSourceUri(withCacheBuster(source, "_link"));
    };

    Linking.getInitialURL().then((url) => {
      if (mounted) applyUrl(url);
    });

    const subscription = Linking.addEventListener("url", ({ url }) => {
      applyUrl(url);
    });

    return () => {
      mounted = false;
      subscription.remove();
    };
  }, [localWebUri]);

  useEffect(() => {
    if (localWebUri) {
      setWebSourceUri(withCacheBuster(withRuntimeQuery(localWebUri, runtimeQuery), "_cache"));
    }
  }, [localWebUri, runtimeQuery]);

  useEffect(() => {
    if (error && localWebUri && webSourceUri.startsWith(REMOTE_WEB_BASE_URI)) {
      setWebSourceUri(withCacheBuster(withRuntimeQuery(localWebUri, runtimeQuery), "_fallback"));
      setError(null);
    }
  }, [error, localWebUri, runtimeQuery, webSourceUri]);

  useEffect(() => {
    const subscription = AppState.addEventListener("change", (nextState: AppStateStatus) => {
      if (nextState === "active") {
        refreshWebSource();
      }
    });
    return () => subscription.remove();
  }, [localWebUri, runtimeQuery]);

  useEffect(() => {
    if (!toast) return;
    const timer = setTimeout(() => setToast(""), 1800);
    return () => clearTimeout(timer);
  }, [toast]);

  useEffect(() => {
    if (!stampSheet || stampSheet.expanded || stampSheet.mode !== "award") return;
    const timer = setTimeout(() => {
      setStampSheet((sheet) => sheet ? { ...sheet, expanded: true } : sheet);
    }, 950);
    return () => clearTimeout(timer);
  }, [stampSheet]);

  useEffect(() => {
    if (!webSourceUri) {
      setNativeLayerReady(false);
      return;
    }
    setNativeLayerReady(false);
    const timer = setTimeout(() => setNativeLayerReady(true), 900);
    return () => clearTimeout(timer);
  }, [webSourceUri]);

  const handleWebViewError = () => {
    if (webSourceUri.startsWith(REMOTE_WEB_BASE_URI) && localWebUri) {
      setWebSourceUri(withCacheBuster(withRuntimeQuery(localWebUri, runtimeQuery), "_cache"));
      return;
    }
    setError("Failed to load the Vitora web view.");
  };

  const injectSimulatorPatch = () => {
    webViewRef.current?.injectJavaScript(SIMULATOR_WEB_PATCH_WITH_PROBE);
    setTimeout(() => syncRuntimeToWebView(), 60);
  };

  const handleWebViewMessage = (event: { nativeEvent: { data: string } }) => {
    const raw = event.nativeEvent.data;
    try {
      const payload = JSON.parse(raw) as VitoraOnboardingBridgePayload;
      if (payload.scope === "vitora-onboarding") {
        setOnboardingOpen(Boolean(payload.open));
        setOnboardingCompleted(Boolean(payload.completed));
        setNativeLayerReady(true);
        if (!payload.open && payload.completed) {
          const next = buildRuntimeStateFromPayload(payload);
          applyVitoraRuntimeState(next);
          setNativeTab("today");
          setTodayRoute("home");
          setTodayActiveId(next.careEvents[0]?.targetCard ?? "today");
        }
        return;
      }
    } catch {
      // Non-JSON messages are ignored unless they are patch diagnostics below.
    }
    if (raw.includes("vitora-native-patch")) {
      if (raw.includes("patch-ok")) {
        setNativeLayerReady(true);
      }
      console.log(`[VitoraWebView] ${raw}`);
    }
  };

  const activeTheme = EXPLORE_THEMES.find((theme) => theme.id === activeThemeId) ?? EXPLORE_THEMES[0];
  const runtimeTodayCards = vitoraState.content.todayCards;
  const activeToday = runtimeTodayCards.find((card) => card.id === todayActiveId) ?? runtimeTodayCards[0];
  const todayNavItems: TodayNavCircle[] = TODAY_NAV_ORDER
    .map((id) => runtimeTodayCards.find((card) => card.id === id))
    .filter((card): card is TodayCard => Boolean(card));
  const focusPanResponder = PanResponder.create({
    onStartShouldSetPanResponder: () => false,
    onMoveShouldSetPanResponder: (_, gesture) => Math.abs(gesture.dx) > 8,
    onPanResponderMove: (_, gesture) => {
      const raw = focusMinutes + gesture.dx / 8;
      const stepped = Math.round(raw / 5) * 5;
      setFocusMinutes(Math.max(10, Math.min(50, stepped)));
    }
  });
  const sleepPanResponder = PanResponder.create({
    onStartShouldSetPanResponder: () => false,
    onMoveShouldSetPanResponder: (_, gesture) => Math.abs(gesture.dx) > 10,
    onPanResponderRelease: (_, gesture) => {
      if (gesture.dx > 18) {
        setSleepWindowShift((value) => Math.max(-4, value - 1));
      } else if (gesture.dx < -18) {
        setSleepWindowShift((value) => Math.min(4, value + 1));
      }
    }
  });
  const formatElapsed = (seconds: number) => {
    const minutes = Math.floor(seconds / 60);
    const remaining = seconds % 60;
    return `${String(minutes).padStart(2, "0")}:${String(remaining).padStart(2, "0")}`;
  };

  const sunPosition = () => {
    const current = new Date(nowTick);
    const start = 6 * 60 + 14;
    const end = 17 * 60 + 21;
    const currentMinutes = current.getHours() * 60 + current.getMinutes();
    const progress = Math.max(0, Math.min(1, (currentMinutes - start) / (end - start)));
    return {
      progress,
      x: 58 + progress * 232,
      y: 150 - Math.sin(progress * Math.PI) * 72
    };
  };

  const adjustFocusMinutes = (delta: number) => {
    setFocusMinutes((minutes) => Math.max(10, Math.min(50, minutes + delta)));
  };

  const adjustSleepTarget = (delta: number) => {
    setSleepTargetMinutes((minutes) => Math.max(330, Math.min(540, minutes + delta)));
  };

  const monthLabelForStamp = (month: string) => {
    const [year, rawMonth] = month.split("-");
    return `${year} · ${Number(rawMonth || "1")}月`;
  };

  const storeAchievementStamp = (stamp: AchievementStampV1, mode: "award" | "detail" = "award") => {
    const nextStamps = [stamp, ...vitoraState.achievementStamps.filter((item) => item.stampId !== stamp.stampId)];
    applyVitoraRuntimeState({
      ...vitoraState,
      updatedAt: new Date().toISOString(),
      achievementStamps: nextStamps,
      storageKeys: {
        ...vitoraState.storageKeys,
        "vivi:achievement:monthlyStampsV1": nextStamps
      }
    });
    setStampSheet({ stamp, mode, expanded: mode === "detail" });
  };

  const openStampSheet = (stamp: AchievementStampV1, mode: "award" | "detail" = "detail") => {
    setStampSheet({ stamp, mode, expanded: mode === "detail" });
  };

  const collectTodayStamp = (actionId: string, title: string) => {
    if (completedTodayActions.includes(actionId)) return;
    setCompletedTodayActions((actions) => [...actions, actionId]);
    const isFocus = title.includes("专注");
    const isMetabolism = title.includes("代谢");
    const isMorning = title.includes("晨间");
    const isCycle = title.includes("周期") || title.includes("经前") || title.includes("低刺激");
    const isBreath = title.includes("呼吸");
    const stampTitle = isFocus ? "专注火种" : isMetabolism || isMorning ? "行动心跳" : isCycle ? "周期护符" : "能量回光";
    const stampType: AchievementStampV1["type"] = isFocus
      ? "focus_muse"
      : isMetabolism || isMorning
        ? "movement_spark"
        : isCycle
          ? "cycle_keeper"
          : "steady_recovery";
    const stampAsset = isFocus
      ? "stamp-focus-athena"
      : isMetabolism || isMorning
        ? "stamp-movement-artemis"
        : isCycle
          ? "stamp-cycle-selene"
          : "stamp-energy-dori";
    const mythicFigure = isFocus ? "雅典娜" : isMetabolism || isMorning ? "阿尔忒弥斯" : isCycle ? "塞勒涅" : "阿波罗";
    const stamp: AchievementStampV1 = {
      schemaVersion: "AchievementStampV1",
      stampId: `stamp-${vitoraState.snapshot.date}-${actionId}`,
      profileId: vitoraState.profile.profileId,
      snapshotId: vitoraState.snapshot.snapshotId,
      predictionId: vitoraState.prediction.predictionId,
      month: vitoraState.snapshot.date.slice(0, 7),
      title: stampTitle,
      type: stampType,
      tone: isFocus ? "sleepers" : isMetabolism ? "hours" : isMorning ? "steps" : "amateur",
      source: "today_action",
      sourceLabel: `今日动作 · ${title}`,
      sourceId: actionId,
      assetKey: stampAsset,
      mythicFigure,
      oilPaintingPrompt: `Oil painting postage stamp for ${title}, soft light, collectible Vitora health achievement stamp.`,
      awardRule: "完成一次可执行的呼吸、专注、代谢或晨间动作。",
      evidenceLabel: "今日完成反馈",
      reason: isBreath
        ? `你完成了「${title}」，身体从紧绷里回到可以呼吸的节奏。`
        : `你完成了「${title}」，这次行动会成为今天身体故事的一枚油戳。`,
      displayReason: isBreath
        ? `你在今天完成了低刺激恢复。愿这枚「${stampTitle}」提醒你：慢下来，也是在向前。`
        : `你在今天完成了「${title}」。愿这枚「${stampTitle}」把这次行动保存成可被看见的能量。`,
      shareCaption: `我在 Vitora 收集到「${stampTitle}」，来自今天完成的「${title}」。`,
      evidence: [
        `actionId=${actionId}`,
        `predictionId=${vitoraState.prediction.predictionId}`,
        `snapshotId=${vitoraState.snapshot.snapshotId}`
      ],
      awardedAt: new Date().toISOString()
    };
    storeAchievementStamp(stamp, "award");
  };

  const openTodayCard = (id: TodayCardId) => {
    setNativeTab("today");
    setTodayRoute("home");
    setTodayActiveId(id);
    const targetIndex = TODAY_NAV_ORDER.indexOf(id);
    if (targetIndex >= 0) {
      setTimeout(() => {
        todayNavScrollRef.current?.scrollTo({
          x: Math.max(0, targetIndex * 92 - 112),
          animated: true
        });
      }, 20);
    }
  };

  const openTodayMore = (id: TodayCardId) => {
    const card = runtimeTodayCards.find((item) => item.id === id) ?? runtimeTodayCards[0];
    setHealthDetailSource(id);
    openHealthDetail(card.moreTab, id);
  };

  const openBreathingPractice = (source: TodayCardId = todayActiveId) => {
    setNativeTab("today");
    setTodayActiveId(source);
    setActiveSessionTitle("呼吸恢复");
    setSessionStartedAt(Date.now());
    setTodayRoute("breathing");
  };

  const completeBreathingPractice = () => {
    breathingPlayerRef.current?.pause();
    setBreathingSoundOn(false);
    setBreathingExpanded(false);
    setTodayRoute("home");
    setSessionStartedAt(null);
    collectTodayStamp("breathing-recovery", "呼吸恢复");
  };

  const openTimedSession = (route: Extract<TodayRoute, "focusTimer" | "metabolismTimer">, title: string, source: TodayCardId) => {
    setNativeTab("today");
    setTodayActiveId(source);
    setActiveSessionTitle(title);
    setSessionStartedAt(Date.now());
    setTodayRoute(route);
  };

  const completeTimedSession = () => {
    const actionId = todayRoute === "metabolismTimer" ? "metabolism-timer" : "focus-timer";
    collectTodayStamp(actionId, activeSessionTitle || (todayRoute === "metabolismTimer" ? "代谢开启" : "专注计时"));
    setSessionStartedAt(null);
    setTodayRoute("home");
  };

  const openMorningMap = () => {
    setNativeTab("today");
    setTodayActiveId("morning");
    setActiveSessionTitle("晨间路线");
    setTodayRoute("morningMap");
  };

  const openThemeDetail = (theme: ExploreTheme) => {
    openNativeChat(theme);
  };

  const buildEnergyReplyContext = (): NativeReplyContext => {
    const chip = (id: "sleep" | "cycle" | "focus" | "stress") =>
      vitoraState.prediction.scoreBreakdown.chips.find((item) => item.id === id);
    return {
      mode: "energy",
      personaName: vitoraState.profile.personaName,
      todayScore: vitoraState.prediction.todayScore,
      cycleLabel: vitoraState.snapshot.cycle.phaseLabel,
      sleepChip: chip("sleep")?.value,
      focusChip: chip("focus")?.value,
      stressChip: chip("stress")?.value,
      primaryAction: vitoraState.prediction.primaryAction.title,
      primaryReason: vitoraState.prediction.primaryAction.reason,
      primaryPush: vitoraState.prediction.primaryAction.push,
      evidence: vitoraState.prediction.evidence.filter((item) => !/[a-zA-Z]+Id=/.test(item))
    };
  };

  const messageKey = (message: NativeMessage, index: number) => message.id ?? `${message.role}-${index}-${message.text}`;
  const isRenderableMessage = (message: NativeMessage) =>
    message.kind === "audio" || Boolean(message.text?.trim()) || Boolean(message.audioText?.trim());

  const renderMessageContent = (message: NativeMessage, _index: number, style: any, _isNewest?: boolean) => {
    if (message.kind === "audio") {
      const messageId = message.id ?? messageKey(message, _index);
      const expanded = Boolean(expandedAudioMessageIds[messageId]);
      const isPlaying = playingAudioMessageId === messageId;
      return (
        <View style={styles.audioMessageContent}>
          <View style={styles.audioMessageTopline}>
            <Pressable
              testID={`tts-audio-play-${messageId}`}
              style={[styles.audioPlayButton, isPlaying && styles.audioPlayButtonActive]}
              onPress={() => toggleAudioMessagePlayback(message)}
            >
              <Text style={styles.audioPlayButtonText}>{isPlaying ? "Ⅱ" : "▶"}</Text>
            </Pressable>
            <View style={styles.audioWaveform} pointerEvents="none">
              {Array.from({ length: 12 }).map((_, index) => (
                <View
                  key={`wave-${index}`}
                  style={[
                    styles.audioWaveBar,
                    { height: 8 + ((index * 7) % 18), opacity: isPlaying ? 0.92 : 0.5 }
                  ]}
                />
              ))}
            </View>
            <Text style={styles.audioVoiceLabel}>{message.voiceId ? "Dori Voice" : "Dori 语音"}</Text>
          </View>
          <Pressable testID={`tts-audio-transcript-${messageId}`} onPress={() => toggleAudioTranscript(messageId)}>
            <Text style={styles.audioTranscriptToggle}>{expanded ? "收起原文" : "展开原文"}</Text>
          </Pressable>
          {expanded ? <Text style={styles.audioTranscriptText}>{message.audioText || message.text}</Text> : null}
        </View>
      );
    }
    return <Text style={style}>{message.text || " "}</Text>;
  };

  const buildEnergyInitialMessages = (): NativeMessage[] => {
    const context = buildEnergyReplyContext();
    return [
      createNativeMessage(
        "ai",
        `我已经读取今天的状态：综合 ${context.todayScore}%，${context.cycleLabel}。睡眠 ${context.sleepChip ?? "稳定"}，专注 ${context.focusChip ?? "波动"}，抗压 ${context.stressChip ?? "需观察"}。你可以直接告诉我你现在的感受，我会把建议压成一个可执行动作。`
      )
    ];
  };

  const ensureEnergyConversation = () => {
    const seed = energyMessages.length ? energyMessages : buildEnergyInitialMessages();
    setNativeChatMode("energy");
    setChatInputMode("keyboard");
    setChatMenuOpen(false);
    setVoiceListening(false);
    setNativeMessages(seed);
    setEnergyMessages(seed);
    return seed;
  };

  const persistChatMessages = (messages: NativeMessage[], mode: NativeChatMode = nativeChatMode) => {
    setNativeMessages(messages);
    if (mode === "energy") {
      setEnergyMessages(messages);
    }
  };

  const openEnergyChat = (question?: string) => {
    const seed = energyMessages.length ? energyMessages : buildEnergyInitialMessages();
    const nextMessages = question
      ? [...seed, createNativeMessage("user", question), createNativeMessage("ai", nativeReply(question, buildEnergyReplyContext()))]
      : seed;
    setNativeChatMode("energy");
    setChatInputMode("keyboard");
    setChatMenuOpen(false);
    setVoiceListening(false);
    setNativeMessages(nextMessages);
    setEnergyMessages(nextMessages);
    setDraft("");
    setTimeout(() => todayInputRef.current?.focus(), 80);
  };

  const appendEnergyMessages = (messages: NativeMessage[]) => {
    setNativeChatMode("energy");
    setNativeMessages(messages);
    setEnergyMessages(messages);
  };

  const sendTodayEnergyMessage = () => {
    const text = draft.trim();
    if (!text) return;
    const seed = energyMessages.length ? energyMessages : buildEnergyInitialMessages();
    const nextMessages = [
      ...seed,
      createNativeMessage("user", text),
      createNativeMessage("ai", nativeReply(text, buildEnergyReplyContext()))
    ];
    appendEnergyMessages(nextMessages);
    setDraft("");
  };

  const createEnergyLiveCard = (imageUri: string | null, source: EnergyLiveCardV1["source"] = "photo") => {
    const context = buildEnergyReplyContext();
    const card: EnergyLiveCardV1 = {
      id: `live-card-${Date.now()}`,
      imageUri,
      score: context.todayScore,
      advice: context.primaryAction,
      createdAt: new Date().toISOString(),
      source
    };
    setEnergyLiveCards((current) => [card, ...current].slice(0, 3));
    const seed = energyMessages.length ? energyMessages : buildEnergyInitialMessages();
    const nextMessages = [
      ...seed,
      createNativeMessage("user", source === "photo" ? "发送了一张今日状态照片" : "记录了一张今日快卡"),
      createNativeMessage(
        "ai",
        `我把这张快卡记到今天了。当前综合 ${context.todayScore}%，${context.cycleLabel}，更适合先做「${context.primaryAction}」，用低刺激动作把身体拉回稳态。`
      )
    ];
    appendEnergyMessages(nextMessages);
    setDraft("");
    setToast("已生成今日能量快卡");
  };

  const pickEnergyPhoto = async (source: "camera" | "library") => {
    try {
      const permission =
        source === "camera"
          ? await ImagePicker.requestCameraPermissionsAsync()
          : await ImagePicker.requestMediaLibraryPermissionsAsync();
      if (!permission.granted) {
        setToast(source === "camera" ? "需要相机权限才能拍摄快卡" : "需要相册权限才能选择照片");
        createEnergyLiveCard(null, "sample");
        return;
      }
      const result =
        source === "camera"
          ? await ImagePicker.launchCameraAsync({ mediaTypes: ["images"], allowsEditing: true, quality: 0.72 })
          : await ImagePicker.launchImageLibraryAsync({ mediaTypes: ["images"], allowsEditing: true, quality: 0.72 });
      if (result.canceled) return;
      createEnergyLiveCard(result.assets[0]?.uri ?? null, "photo");
    } catch {
      createEnergyLiveCard(null, "sample");
    }
  };

  const openEnergyPhotoMenu = () => {
    ensureEnergyConversation();
    Alert.alert("添加今日快卡", "拍照或选择照片，Dori 会把它和今天的能量状态放在一起分析。", [
      { text: "拍照", onPress: () => void pickEnergyPhoto("camera") },
      { text: "相册", onPress: () => void pickEnergyPhoto("library") },
      { text: "先生成示例", onPress: () => createEnergyLiveCard(null, "sample") },
      { text: "取消", style: "cancel" }
    ]);
  };

  const startEnergyRecord = () => {
    setEnergyRecordState("recording");
  };

  const saveEnergyRecord = () => {
    setEnergyRecordState("saving");
    setTimeout(() => {
      setEnergyRecordState("saved");
      collectTodayStamp("energy-record", "今日能量记录");
    }, 850);
  };

  const playEnergyVoiceCue = () => {
    setEnergyVoiceCueActive(true);
    setToast("Dori 正在朗读今日能量摘要");
    setTimeout(() => setEnergyVoiceCueActive(false), 1800);
  };

  const toggleBreathingSound = () => {
    try {
      if (!breathingPlayerRef.current) {
        const player = createAudioPlayer(BREATHING_AUDIO_SOURCE, { updateInterval: 500 });
        player.loop = true;
        player.volume = 0.72;
        breathingPlayerRef.current = player;
      }
      if (breathingSoundOn) {
        breathingPlayerRef.current.pause();
        setBreathingSoundOn(false);
      } else {
        breathingPlayerRef.current.play();
        setBreathingSoundOn(true);
      }
    } catch {
      setBreathingSoundOn((value) => !value);
      setToast("已切换白噪音状态");
    }
  };

  const openNativeChat = (theme = activeTheme) => {
    setActiveThemeId(theme.id);
    setNativeChatMode("explore");
    setChatInputMode("keyboard");
    setChatMenuOpen(false);
    setVoiceListening(false);
    setNativeMessages(initialNativeMessages(theme));
    setDraft("");
    setNativeTab("explore");
    setExploreRoute("chat");
  };

  const sendNativeMessage = () => {
    const text = draft.trim();
    if (!text) return;
    const nextMessages = [
      ...nativeMessages,
      createNativeMessage("user", text),
      createNativeMessage("ai", nativeReply(text, nativeChatMode === "energy" ? buildEnergyReplyContext() : undefined))
    ];
    persistChatMessages(nextMessages);
    setDraft("");
  };

  const sendQuickEnergyQuestion = (question: string) => {
    if (nativeChatMode !== "energy") {
      openEnergyChat(question);
      return;
    }
    const nextMessages = [
      ...nativeMessages,
      createNativeMessage("user", question),
      createNativeMessage("ai", nativeReply(question, buildEnergyReplyContext()))
    ];
    persistChatMessages(nextMessages, "energy");
    setChatInputMode("keyboard");
    setChatMenuOpen(false);
    setDraft("");
  };

  const sendPhotoPlaceholder = () => {
    if (nativeChatMode === "energy") {
      openEnergyPhotoMenu();
      return;
    }
    const photoText = "发送了一张今日状态照片";
    const nextMessages = [
      ...nativeMessages,
      createNativeMessage("user", photoText),
      createNativeMessage(
        "ai",
        "我先把这张照片作为这次探索线索记录下来。你可以继续补一句当时的感受，我会帮你整理成更清晰的状态描述。"
      )
    ];
    persistChatMessages(nextMessages);
    setChatInputMode("keyboard");
    setChatMenuOpen(false);
  };

  const simulateVoiceInput = () => {
    setVoiceListening(true);
    const transcript = "我现在有点累，帮我看下今天适合做什么";
    setTimeout(() => {
      setVoiceListening(false);
      const nextMessages = [
        ...nativeMessages,
        createNativeMessage("user", transcript),
        createNativeMessage("ai", nativeReply(transcript, nativeChatMode === "energy" ? buildEnergyReplyContext() : undefined))
      ];
      persistChatMessages(nextMessages);
      setChatInputMode("keyboard");
    }, 620);
  };

  const completeNativeChat = () => {
    const text = draft.trim();
    const isEnergyChat = nativeChatMode === "energy";
    const finalMessages = text
      ? [
          ...nativeMessages,
          createNativeMessage("user", text),
          createNativeMessage("ai", nativeReply(text, nativeChatMode === "energy" ? buildEnergyReplyContext() : undefined))
        ]
      : nativeMessages;
    if (text) {
      persistChatMessages(finalMessages);
      setDraft("");
    }
    const userText = finalMessages.filter((message) => message.role === "user").map((message) => message.text).join(" ").trim();
    const stamp: AchievementStampV1 = {
      schemaVersion: "AchievementStampV1",
      stampId: `stamp-${vitoraState.snapshot.date}-conversation-${activeTheme.id}-${Date.now()}`,
      profileId: vitoraState.profile.profileId,
      snapshotId: vitoraState.snapshot.snapshotId,
      predictionId: vitoraState.prediction.predictionId,
      month: vitoraState.snapshot.date.slice(0, 7),
      title: "能量回光",
      type: "steady_recovery",
      tone: "sleepers",
      source: "conversation_stamp",
      sourceLabel: isEnergyChat ? "Dori 能量聊天" : `探索对话 · ${activeTheme.tag}`,
      sourceId: isEnergyChat ? "energy-chat" : activeTheme.id,
      assetKey: "stamp-energy-dori",
      mythicFigure: "阿波罗",
      oilPaintingPrompt: isEnergyChat
        ? "Oil painting postage stamp for a Vitora energy analysis conversation, antique paper, warm health aura, collectible stamp."
        : `Oil painting postage stamp for a reflective Vitora conversation about ${activeTheme.tag}, antique paper, soft moonlight, collectible health stamp.`,
      awardRule: isEnergyChat ? "完成一次今日能量分析对话，并保存行动建议。" : "完成一次探索对话，并保存对话主题与连续记录。",
      evidenceLabel: "对话完成",
      reason: isEnergyChat
        ? `你完成了今日能量分析，Dori 已结合 ${vitoraState.prediction.todayScore}% 综合数据、${vitoraState.snapshot.cycle.phaseLabel}和今日建议生成行动线索。`
        : userText
        ? `你完成了「${activeTheme.tag}」探索，对话里提到「${userText.slice(0, 28)}${userText.length > 28 ? "…" : ""}」，这会成为身体状态解释的一条线索。`
        : `你完成了「${activeTheme.tag}」探索，这次记录会进入你的健康油戳收集。`,
      displayReason: isEnergyChat
        ? `这枚「能量回光」来自一次今日能量对话。愿它提醒你：身体正在给出信号，而你已经开始回应。`
        : `这枚「能量回光」来自一次 Dori 对话记录。愿它把你说出的感受，变成下一次更温柔的预测线索。`,
      shareCaption: `我在 Vitora 收集到「能量回光」，来自一次 Dori 对话记录。`,
      evidence: [
        `主题=${isEnergyChat ? "今日能量" : activeTheme.tag}`,
        `消息数=${finalMessages.length}`,
        `predictionId=${vitoraState.prediction.predictionId}`
      ],
      awardedAt: new Date().toISOString()
    };
    storeAchievementStamp(stamp, "award");
    if (isEnergyChat) {
      setToast("今日能量聊天已保存");
      return;
    }
    setExploreRoute("home");
  };

  const shareNativeFeedback = async () => {
    try {
      await Share.share({ title: "Vitora 连续记录", message: "我完成了一次 Vitora 连续记录，已经收集到我的健康。" });
    } catch {
      Alert.alert("分享", "已生成分享内容");
    }
  };

  const finishNativeFeedback = () => {
    setToast("已收集到我的健康");
    setExploreRoute("home");
    setNativeTab("health");
    setHealthRoute("home");
  };

  const openHealthDetail = (tab: HealthDetailTab = "summary", source: HealthDetailSource = "health") => {
    setHealthDetailSource(source);
    setHealthDateOffset(0);
    setNativeTab("health");
    setHealthRoute("detail");
    setHealthDetailTab(tab);
  };

  const closeHealthDetail = () => {
    setHealthRoute("home");
    setHealthDateOffset(0);
  };

  const openReminderSheet = (source: string, defaultTime: string) => {
    setReminderSheet({ source, time: defaultTime });
  };

  const updateReminderTime = (time: string) => {
    setReminderSheet((sheet) => (sheet ? { ...sheet, time } : sheet));
  };

  const confirmReminder = () => {
    if (reminderSheet) {
      setToast(`已设置 ${reminderSheet.time} 提醒 · ${activeCareEvent.careEventId}`);
    }
    setReminderSheet(null);
  };

  const renderDots = () => (
    <View style={styles.nativeDots}>
      {[0, 1, 2, 3, 4, 5, 6].map((item) => (
        <View key={item} style={[styles.nativeDot, item === 5 && styles.nativeDotActive]} />
      ))}
    </View>
  );

  const renderExploreHome = () => (
    <SoftGradientBackground>
      <View style={styles.nativeExploreTop}>{renderDots()}</View>
      <ScrollView style={styles.nativeCardScroller} contentContainerStyle={styles.nativeCardScrollerContent} showsVerticalScrollIndicator={false}>
        {EXPLORE_THEMES.map((theme) => (
          <Pressable
            key={theme.id}
            style={styles.nativeExploreCard}
            onPressIn={() => setActiveFogThemeId(theme.id)}
            onPressOut={() => setActiveFogThemeId(null)}
            onPress={() => openThemeDetail(theme)}
          >
            <ImageBackground source={theme.image} resizeMode="cover" style={styles.nativeCardImage} imageStyle={styles.nativeCardImageRadius}>
              <View style={styles.nativeCardShade} />
              <BlurView pointerEvents="none" intensity={26} tint="dark" style={styles.nativeFogLayer}>
                <LinearGradient colors={["rgba(235,241,239,0.12)", "rgba(255,255,255,0.26)", "rgba(33,38,40,0.18)"]} style={styles.glassFill} />
              </BlurView>
              {activeFogThemeId === theme.id && <View pointerEvents="none" style={styles.nativeFogReveal} />}
              <View style={styles.nativeCardCopy}>
                <Text style={styles.nativeCardTitle}>{theme.title}</Text>
                <Text style={styles.nativeCardPrompt}>{theme.prompt}</Text>
              </View>
              <Pressable style={styles.nativeCardInput} onPress={() => openThemeDetail(theme)}>
                <Text style={styles.nativeCardInputText}>写点什么...</Text>
              </Pressable>
            </ImageBackground>
          </Pressable>
        ))}
      </ScrollView>
    </SoftGradientBackground>
  );

  const renderExploreDetail = () => (
    <ScrollView style={styles.nativePageDark} contentContainerStyle={styles.nativeDetailContent} showsVerticalScrollIndicator={false}>
      <View style={styles.nativeExploreTop}>{renderDots()}</View>
      <ImageBackground source={activeTheme.image} resizeMode="cover" style={styles.nativeDetailCard} imageStyle={styles.nativeCardImageRadius}>
        <View style={styles.nativeCardShade} />
        <BlurView pointerEvents="none" intensity={26} tint="dark" style={styles.nativeFogLayer}>
          <LinearGradient colors={["rgba(235,241,239,0.12)", "rgba(255,255,255,0.26)", "rgba(33,38,40,0.18)"]} style={styles.glassFill} />
        </BlurView>
        <View style={styles.nativeDetailCopy}>
          <Text style={styles.nativeDetailTitle}>{activeTheme.detailTitle}</Text>
          <Text style={styles.nativeDetailPrompt}>{activeTheme.prompt}</Text>
        </View>
        <Pressable style={styles.nativeDetailInput} onPress={() => openNativeChat(activeTheme)}>
          <Text style={styles.nativeCardInputText}>写点什么...</Text>
        </Pressable>
      </ImageBackground>
      <View style={styles.nativeRecentCard}>
        <Text style={styles.nativePillInline}>{activeTheme.tag}</Text>
        <Text style={styles.nativeRecentTitle}>最近记录 · {activeTheme.tag}</Text>
        <Text style={styles.nativeRecentCopy}>这段记录里有一个很明确的核心：你正在寻找一种更稳定、更真实的表达方式。</Text>
      </View>
    </ScrollView>
  );

  const renderNativeChat = () => (
    <LinearGradient colors={["#ffffff", "#f2efff", "#eef8f5"]} locations={[0, 0.42, 1]} style={styles.nativeChat}>
      <View style={styles.nativeChatTop}>
        <Pressable
          testID="native-chat-back"
          style={styles.nativeRoundButton}
          onPress={() => {
            if (nativeChatMode === "energy") {
              setNativeTab("today");
              setTodayRoute("home");
            } else {
              setExploreRoute("home");
            }
          }}
        >
          <Text style={styles.nativeBackText}>‹</Text>
        </Pressable>
        <Text style={styles.nativeAnalyze}>{nativeChatMode === "energy" ? "Dori 能量分析" : "分析"}</Text>
      </View>
      <ScrollView testID="native-chat-messages" style={styles.nativeMessages} contentContainerStyle={styles.nativeMessagesContent}>
        {(() => {
          const visibleMessages = nativeMessages.filter(isRenderableMessage);
          return visibleMessages.map((message, index) => (
            <View key={messageKey(message, index)} style={[styles.voiceMessageRow, message.role === "user" && styles.voiceMessageRowUser]}>
              {message.role !== "user" ? <View style={styles.voiceMessageTail} /> : null}
              <View style={[styles.voiceMessageBar, message.role === "user" && styles.voiceMessageBarUser]}>
                {renderMessageContent(message, index, styles.voiceMessageText, index === visibleMessages.length - 1)}
              </View>
              {message.role === "user" ? <View style={[styles.voiceMessageTail, styles.voiceMessageTailUser]} /> : null}
            </View>
          ));
        })()}
      </ScrollView>
      {chatMenuOpen && (
        <View style={styles.nativeInputMenu}>
          {[
            { id: "keyboard" as const, label: "键盘输入", mark: "⌨" },
            { id: "voice" as const, label: "语音输入", mark: "◉" },
            { id: "quickActions" as const, label: "快捷问题", mark: "?" }
          ].map((item) => (
            <Pressable
              key={item.id}
              testID={`chat-mode-${item.id}`}
              style={[styles.nativeInputMenuItem, chatInputMode === item.id && styles.nativeInputMenuItemActive]}
              onPress={() => {
                setChatInputMode(item.id);
                setChatMenuOpen(false);
              }}
            >
              <Text style={styles.nativeInputMenuMark}>{item.mark}</Text>
              <Text style={styles.nativeInputMenuText}>{item.label}</Text>
            </Pressable>
          ))}
        </View>
      )}
      {chatInputMode === "quickActions" && (
        <View style={styles.nativeQuickRail}>
          {ENERGY_QUICK_QUESTIONS.map((question) => (
            <Pressable
              key={question}
              testID={`chat-quick-${question}`}
              style={styles.nativeQuickChip}
              onPress={() => sendQuickEnergyQuestion(question)}
            >
              <Text style={styles.nativeQuickChipText}>{question}</Text>
            </Pressable>
          ))}
        </View>
      )}
      {chatInputMode === "voice" && (
        <View style={styles.nativeVoicePanel}>
          <Text style={styles.nativeVoiceTitle}>{voiceListening ? "正在听你说..." : "语音输入"}</Text>
          <Text style={styles.nativeVoiceCopy}>第一版先模拟转写，后续接真实麦克风权限和语音识别。</Text>
          <Pressable
            testID="chat-voice-record"
            style={[styles.nativeVoiceButton, voiceListening && styles.nativeVoiceButtonActive]}
            onPress={simulateVoiceInput}
            disabled={voiceListening}
          >
            <Text style={styles.nativeVoiceButtonText}>{voiceListening ? "转写中" : "模拟说一句"}</Text>
          </Pressable>
        </View>
      )}
      <View style={styles.nativeComposer}>
        <Pressable
          testID="native-chat-input-focus"
          style={styles.nativeInputWrap}
          onPress={() => nativeInputRef.current?.focus()}
        >
          <BlurView pointerEvents="none" intensity={42} tint="dark" style={styles.glassFill} />
          <LinearGradient pointerEvents="none" colors={["rgba(255,255,255,0.18)", "rgba(255,255,255,0.05)"]} style={styles.glassFill} />
          <TextInput
            ref={nativeInputRef}
            testID="native-chat-input"
            value={draft}
            onChangeText={setDraft}
            placeholder={nativeChatMode === "energy" ? "问 Dori：为什么、做什么、提醒我..." : "写点什么..."}
            placeholderTextColor="rgba(255,255,255,0.62)"
            returnKeyType="send"
            onSubmitEditing={draft.trim() ? sendNativeMessage : undefined}
            style={styles.nativeInput}
          />
          <Pressable
            testID="chat-plus-menu"
            style={styles.nativeComposerInlineButton}
            onPress={sendPhotoPlaceholder}
          >
            <Text style={styles.nativeComposerInlinePlus}>＋</Text>
          </Pressable>
          <Pressable
            testID="native-chat-send"
            style={[styles.nativeComposerInlineSend, !draft.trim() && styles.nativeComposerInlineSendIdle]}
            onPress={draft.trim() ? sendNativeMessage : completeNativeChat}
          >
            <Text style={styles.nativeComposerInlineSendText}>{draft.trim() ? "↑" : "✓"}</Text>
          </Pressable>
        </Pressable>
      </View>
    </LinearGradient>
  );

  const renderEnergyChatDrawer = () => null;

  const renderDreamPlate = () => {
    const marks = [
      { color: "#b7d4ad", left: 68, top: 42, size: 15 },
      { color: "#f5c8c2", left: 88, top: 56, size: 20 },
      { color: "#9cc6eb", left: 114, top: 80, size: 26 },
      { color: "#f4cf82", left: 78, top: 104, size: 28 },
      { color: "#c9b7dd", left: 134, top: 64, size: 14 },
      { color: "#df9bc1", left: 98, top: 100, size: 16 },
      { color: "#dfe2df", left: 58, top: 72, size: 10 },
      { color: "#94c2e4", left: 54, top: 96, size: 16 },
      { color: "#f3a18f", left: 126, top: 50, size: 12 },
      { color: "#dce0dd", left: 102, top: 34, size: 8 }
    ];
    return (
      <View style={styles.nativeDreamPlate}>
        {marks.map((mark, index) => (
          <View
            key={`${mark.color}-${index}`}
            style={[
              styles.nativeDreamParticle,
              {
                backgroundColor: mark.color,
                left: mark.left,
                top: mark.top,
                width: mark.size,
                height: mark.size * 0.58,
                transform: [{ rotate: `${index * 29 - 58}deg` }]
              }
            ]}
          />
        ))}
      </View>
    );
  };

  const renderFeedbackPerfs = () => (
    <>
      <View style={[styles.nativeFeedbackPerfRow, styles.nativeFeedbackPerfTop]}>
        {Array.from({ length: 12 }).map((_, index) => <View key={`feedback-top-${index}`} style={styles.nativeFeedbackPerfDot} />)}
      </View>
      <View style={[styles.nativeFeedbackPerfRow, styles.nativeFeedbackPerfBottom]}>
        {Array.from({ length: 12 }).map((_, index) => <View key={`feedback-bottom-${index}`} style={styles.nativeFeedbackPerfDot} />)}
      </View>
      <View style={[styles.nativeFeedbackPerfCol, styles.nativeFeedbackPerfLeft]}>
        {Array.from({ length: 13 }).map((_, index) => <View key={`feedback-left-${index}`} style={styles.nativeFeedbackPerfDot} />)}
      </View>
      <View style={[styles.nativeFeedbackPerfCol, styles.nativeFeedbackPerfRight]}>
        {Array.from({ length: 13 }).map((_, index) => <View key={`feedback-right-${index}`} style={styles.nativeFeedbackPerfDot} />)}
      </View>
    </>
  );

  const renderFeedback = () => (
    <View style={styles.nativeFeedbackDark}>
      <View style={styles.nativeFeedbackMist} />
      <View style={styles.nativeFeedbackTop}>
        <Pressable style={styles.nativeCloseCircle} onPress={() => setExploreRoute("home")}>
          <Text style={styles.nativeCloseText}>×</Text>
        </Pressable>
        {renderDots()}
      </View>
      <View style={styles.nativeStampLarge}>
        {renderFeedbackPerfs()}
        <Text style={styles.nativeStampSmall}>DREAM RECALL</Text>
        <View style={styles.nativeFeedbackStampArt}>{renderDreamPlate()}</View>
        <Text style={styles.nativeStampTitle}>RECORD 1 MORE DREAM,{`\n`}UNLOCK THE NEXT MODE</Text>
        <View style={styles.nativeStampSteps}>
          <View style={styles.nativeStampStepDot} />
          <View style={styles.nativeStampStepLine} />
          <View style={styles.nativeStampStepDot} />
        </View>
        <Text style={styles.nativeStampStep}>STEP 1     STEP 2</Text>
      </View>
      <View style={styles.nativeStreakRow}>
        <Text style={styles.nativeStreakMain}>海上漂浮{`\n`}城市意象</Text>
        <Text style={styles.nativeStreakSub}>当前连胜{`\n`}最佳连续记录</Text>
      </View>
      <Pressable style={styles.nativeFeedbackButton} onPress={shareNativeFeedback}>
        <Text style={styles.nativeFeedbackButtonText}>⇧ 分享连续记录</Text>
      </Pressable>
      <Pressable style={styles.nativeFeedbackButton} onPress={finishNativeFeedback}>
        <Text style={styles.nativeFeedbackButtonText}>完成</Text>
      </Pressable>
    </View>
  );

  const stampArtToneStyle = (tone: HealthStampTone) => {
    if (tone === "amateur") return styles.nativeStampArt_amateur;
    if (tone === "sleepers") return styles.nativeStampArt_sleepers;
    if (tone === "steps") return styles.nativeStampArt_steps;
    if (tone === "gym") return styles.nativeStampArt_gym;
    return styles.nativeStampArt_hours;
  };

  const renderStampArt = (tone: HealthStampTone) => (
    <View style={[styles.nativeStampArt, stampArtToneStyle(tone)]}>
      {tone === "amateur" ? (
        <View style={styles.nativeStampFace}>
          <View style={styles.nativeStampBand} />
          <View style={styles.nativeStampEyeRow}>
            <View style={styles.nativeStampEye} />
            <View style={styles.nativeStampEye} />
          </View>
        </View>
      ) : null}
      {tone === "sleepers" ? (
        <>
          <View style={styles.nativeStampWaveA} />
          <View style={styles.nativeStampWaveB} />
          <Text style={styles.nativeStampZ}>Z</Text>
          <Text style={[styles.nativeStampZ, styles.nativeStampZTwo]}>Z</Text>
        </>
      ) : null}
      {tone === "steps" ? (
        <>
          <View style={styles.nativeStepsCard} />
          <View style={styles.nativeStepsPath} />
          <View style={styles.nativeStepsBud} />
        </>
      ) : null}
      {tone === "gym" ? (
        <View style={styles.nativeGymFace}>
          <Text style={styles.nativeGymFaceText}>⌁</Text>
        </View>
      ) : null}
      {tone === "hours" ? (
        <>
          <View style={styles.nativeHoursHill} />
          <Text style={styles.nativeHoursMoon}>☾</Text>
          <Text style={styles.nativeHoursZ}>zZ</Text>
        </>
      ) : null}
    </View>
  );

  const renderStampPerfs = () => (
    <>
      <View style={[styles.nativeStampPerfRow, styles.nativeStampPerfTop]}>
        {Array.from({ length: 8 }).map((_, index) => <View key={`top-${index}`} style={styles.nativeStampPerfDot} />)}
      </View>
      <View style={[styles.nativeStampPerfRow, styles.nativeStampPerfBottom]}>
        {Array.from({ length: 8 }).map((_, index) => <View key={`bottom-${index}`} style={styles.nativeStampPerfDot} />)}
      </View>
      <View style={[styles.nativeStampPerfCol, styles.nativeStampPerfLeft]}>
        {Array.from({ length: 10 }).map((_, index) => <View key={`left-${index}`} style={styles.nativeStampPerfDot} />)}
      </View>
      <View style={[styles.nativeStampPerfCol, styles.nativeStampPerfRight]}>
        {Array.from({ length: 10 }).map((_, index) => <View key={`right-${index}`} style={styles.nativeStampPerfDot} />)}
      </View>
    </>
  );

  const stampGlyphFor = (stamp: VitoraRuntimeStateV1["achievementStamps"][number]) => {
    if (stamp.type === "perfect_month") return "♀";
    if (stamp.type === "most_consistent") return "♨";
    if (stamp.type === "sleep_guardian") return "☾";
    if (stamp.type === "steady_recovery") return "☤";
    if (stamp.type === "focus_muse") return "♟";
    if (stamp.type === "cycle_keeper") return "◐";
    return "✦";
  };

  const stampAssetFor = (stamp: AchievementStampV1) =>
    STAMP_ASSET_IMAGES[stamp.assetKey] ??
    (stamp.type === "perfect_month" ? STAMP_ASSET_IMAGES["stamp-perfect-goddess"] :
      stamp.type === "most_consistent" ? STAMP_ASSET_IMAGES["stamp-consistency-flame"] :
        stamp.type === "sleep_guardian" ? STAMP_ASSET_IMAGES["stamp-sleep-hypnos"] :
          stamp.type === "focus_muse" ? STAMP_ASSET_IMAGES["stamp-focus-athena"] :
            stamp.type === "cycle_keeper" ? STAMP_ASSET_IMAGES["stamp-cycle-selene"] :
              stamp.type === "movement_spark" ? STAMP_ASSET_IMAGES["stamp-movement-artemis"] :
                STAMP_ASSET_IMAGES["stamp-recovery-hygieia"]);

  const displayReasonForStamp = (stamp: AchievementStampV1) => {
    if (stamp.lockedReason) return `这枚「${stamp.title}」还未解锁：${stamp.lockedReason}`;
    if (stamp.displayReason) return stamp.displayReason;
    if (stamp.source === "today_action") {
      const actionName = stamp.sourceLabel.replace("今日动作 · ", "");
      return `你完成了「${actionName}」。这枚「${stamp.title}」记录了身体重新聚光的一刻，愿你把小动作也当作前进的证据。`;
    }
    if (stamp.source === "conversation_stamp") {
      return `这枚「${stamp.title}」来自一次 Dori 对话记录。你把感受说出口，身体故事就多了一条可以被照顾的线索。`;
    }
    return `${stamp.reason} 愿这枚「${stamp.title}」提醒你：今天留下的信号，会在之后成为更准确的照顾。`;
  };

  const shareStamp = async (stamp: AchievementStampV1) => {
    try {
      await Share.share({
        title: `${stamp.title} · Vitora 油戳`,
        message: stamp.shareCaption ?? `${monthLabelForStamp(stamp.month)}，我在 Vitora 收集到「${stamp.title}」。${displayReasonForStamp(stamp)}`
      });
    } catch {
      setToast("分享没有完成");
    }
  };

  const renderHealthStamp = (stamp: VitoraRuntimeStateV1["achievementStamps"][number], style: object) => (
    <Pressable
      style={[styles.nativeHealthStamp, stamp.lockedReason && styles.nativeHealthStampLocked, style]}
      onPress={() => openStampSheet(stamp, "detail")}
    >
      {renderStampPerfs()}
      <Image source={stampAssetFor(stamp)} style={styles.nativeHealthStampImage} resizeMode="contain" />
      <Text style={styles.nativeHealthStampTitle}>{stamp.title}</Text>
      {stamp.lockedReason && <Text style={styles.nativeStampLockedText}>LOCK</Text>}
    </Pressable>
  );

  const openStampSource = (stamp: AchievementStampV1) => {
    setStampSheet(null);
    if (stamp.source === "conversation_stamp") {
      setNativeTab("explore");
      setExploreRoute("home");
      return;
    }
    if (stamp.source === "today_action") {
      const sourceId = stamp.sourceId ?? "";
      if (sourceId.includes("focus")) openTodayCard("focus");
      else if (sourceId.includes("metabolism")) openTodayCard("metabolism");
      else if (sourceId.includes("morning")) openTodayCard("morning");
      else openTodayCard("today");
      return;
    }
    setNativeTab("health");
    setHealthRoute("home");
  };

  const renderStampFrame = (stamp: AchievementStampV1, scale: "large" | "small" = "large") => (
    <View style={[styles.stampFrame, scale === "small" && styles.stampFrameSmall]}>
      <Image source={stampAssetFor(stamp)} style={styles.stampFrameImage} resizeMode="contain" />
      <Text style={styles.stampCodeText}>{stampCodeFor(stamp)}</Text>
      <View style={styles.stampMonthPill}>
        <Text style={styles.stampMonthText}>{monthLabelForStamp(stamp.month)}</Text>
      </View>
    </View>
  );

  const renderStampRevealSheet = () => {
    if (!stampSheet) return null;
    const { stamp, mode } = stampSheet;
    const reason = displayReasonForStamp(stamp);
    return (
      <View style={styles.stampSheetLayer}>
        <Pressable style={styles.stampSheetScrim} onPress={() => setStampSheet(null)} />
        <BlurView intensity={54} tint="dark" style={styles.stampSheet}>
          <LinearGradient
            pointerEvents="none"
            colors={["rgba(25,29,31,0.82)", "rgba(54,62,58,0.62)", "rgba(18,21,24,0.86)"]}
            locations={[0, 0.48, 1]}
            style={styles.glassFill}
          />
          <View style={styles.stampSheetLiquidA} />
          <View style={styles.stampSheetLiquidB} />
          <View style={styles.stampSheetHandle} />
          <View style={styles.stampSheetTop}>
            <Pressable style={styles.stampSheetClose} onPress={() => setStampSheet(null)}>
              <Text style={styles.stampSheetCloseText}>×</Text>
            </Pressable>
            <Text style={styles.stampSheetCode}>{stampCodeFor(stamp)}</Text>
          </View>
          <View style={styles.stampSheetHero}>
            {renderStampFrame(stamp)}
          </View>
          <View style={styles.stampSheetDetails}>
            <Text style={styles.stampSheetKicker}>{mode === "award" ? "已获得油戳" : stamp.lockedReason ? "未解锁油戳" : "我的油戳"}</Text>
            <Text style={styles.stampSheetTitle}>{stamp.title}</Text>
            <Text style={styles.stampSheetReason}>{reason}</Text>
            <View style={styles.stampSheetActions}>
              <Pressable style={styles.stampSheetSecondary} onPress={() => setStampSheet(null)}>
                <Text style={styles.stampSheetSecondaryText}>完成</Text>
              </Pressable>
              <Pressable style={styles.stampSheetPrimary} onPress={() => shareStamp(stamp)}>
                <Text style={styles.stampSheetPrimaryText}>分享</Text>
              </Pressable>
            </View>
          </View>
        </BlurView>
      </View>
    );
  };

  const heatColor = (value: 0 | 1 | 2 | 3) => {
    if (value === 3) return "#31db55";
    if (value === 2) return "#45bd5e";
    if (value === 1) return "#d9d9df";
    return "rgba(236,236,240,0.52)";
  };

  const renderLineBetweenPoints = (
    from: { x: number; y: number },
    to: { x: number; y: number },
    key: string,
    lineStyle: object,
    thickness = 2
  ) => {
    const dx = to.x - from.x;
    const dy = to.y - from.y;
    const length = Math.sqrt(dx * dx + dy * dy);
    const angle = Math.atan2(dy, dx) * 180 / Math.PI;
    return (
      <View
        key={key}
        style={[
          styles.chartLineBase,
          lineStyle,
          {
            width: length,
            height: thickness,
            left: (from.x + to.x) / 2 - length / 2,
            top: (from.y + to.y) / 2 - thickness / 2,
            transform: [{ rotate: `${angle}deg` }]
          }
        ]}
      />
    );
  };

  const renderHealthHeatmapRangeControl = () => (
    <View style={styles.heatmapRangeControl}>
      <Pressable style={styles.heatmapRangeArrow} onPress={() => setHealthHeatmapRange("last_week")}>
        <Text style={styles.heatmapRangeArrowText}>‹</Text>
      </Pressable>
      <Text style={styles.heatmapRangeLabel}>{healthHeatmapRange === "this_week" ? "本周" : "上周"}</Text>
      <Pressable style={styles.heatmapRangeArrow} onPress={() => setHealthHeatmapRange("this_week")}>
        <Text style={styles.heatmapRangeArrowText}>›</Text>
      </Pressable>
    </View>
  );

  const renderHeatmapLegend = (state: VitoraRuntimeStateV1, compact = false) => (
    <View style={compact ? styles.nativeHeatLegend : styles.summaryHeatLegend}>
      {state.healthInsight.heatmapLegend.map((item) => (
        <View key={item.label} style={styles.heatLegendItem}>
          <View style={[styles.heatLegendDot, { backgroundColor: item.color }]} />
          <Text style={compact ? styles.nativeHeatLegendText : styles.summaryHeatLegendText}>{item.label}</Text>
        </View>
      ))}
    </View>
  );

  const renderHealthHeatmap = (state: VitoraRuntimeStateV1, compact = false) => {
    const window = activeHeatmapWindow(state);
    const rows = window?.rows ?? state.healthInsight.heatmapRows;
    return (
      <View style={compact ? styles.nativeHeatmap : styles.summaryHeatGridRows}>
        {rows.map((row) => (
          <View key={row.id} style={compact ? styles.nativeHeatmapRow : styles.summaryHeatGridRow}>
            {!compact && <Text style={styles.summaryHeatGridLabel}>{row.label}</Text>}
            <View style={compact ? styles.nativeHeatmapCells : styles.summaryHeatGridCells}>
              {(compact
                ? Array.from({ length: 7 }).map((_, dayIndex) => {
                  const dayValues = row.values.slice(dayIndex * 3, dayIndex * 3 + 3);
                  return Math.round(dayValues.reduce<number>((sum, value) => sum + value, 0) / Math.max(1, dayValues.length)) as 0 | 1 | 2 | 3;
                })
                : row.values
              ).map((value, index) => (
                <View
                  key={`${row.id}-${index}`}
                  style={[
                    compact ? styles.nativeHeatCell : styles.summaryHeatCell,
                    { backgroundColor: heatColor(value) },
                    value === 3 && (compact ? styles.nativeHeatCellHot : styles.summaryHeatCellHot)
                  ]}
                />
              ))}
            </View>
          </View>
        ))}
        {renderHeatmapLegend(state, compact)}
      </View>
    );
  };

  const renderHealthRadarGraph = (state: VitoraRuntimeStateV1, compact = false) => {
    const size = compact ? 128 : 246;
    const center = size / 2;
    const radius = compact ? 47 : 88;
    const metrics = [
      { label: "睡眠", score: state.healthInsight.radarScores.sleep, angle: -90 },
      { label: "周期", score: state.healthInsight.radarScores.cycle, angle: -18 },
      { label: "抗压", score: state.healthInsight.radarScores.stress, angle: 54 },
      { label: "代谢", score: state.healthInsight.radarScores.metabolism, angle: 126 },
      { label: "专注", score: state.healthInsight.radarScores.focus, angle: 198 }
    ];
    const pointFor = (angle: number, pointRadius: number) => ({
      x: center + Math.cos(angle * Math.PI / 180) * pointRadius,
      y: center + Math.sin(angle * Math.PI / 180) * pointRadius
    });
    const gridPolygons = [1, 0.72, 0.46].map((scale) => metrics.map((metric) => pointFor(metric.angle, radius * scale)));
    const valuePoints = metrics.map((metric) => pointFor(metric.angle, radius * Math.max(0.32, Math.min(0.96, metric.score / 100))));
    return (
      <View style={[styles.healthRadarGraph, compact && styles.healthRadarGraphCompact, { width: size, height: size }]}>
        <View style={[styles.healthRadarFillWash, compact && styles.healthRadarFillWashCompact]} />
        {gridPolygons.flatMap((points, ringIndex) =>
          points.map((point, index) =>
            renderLineBetweenPoints(
              point,
              points[(index + 1) % points.length],
              `grid-${ringIndex}-${index}`,
              styles.healthRadarGridLine,
              compact ? 1 : 2
            )
          )
        )}
        {metrics.map((metric, index) =>
          renderLineBetweenPoints(
            { x: center, y: center },
            pointFor(metric.angle, radius),
            `axis-${metric.label}`,
            styles.healthRadarAxisLine,
            1
          )
        )}
        {valuePoints.map((point, index) =>
          renderLineBetweenPoints(
            point,
            valuePoints[(index + 1) % valuePoints.length],
            `value-${index}`,
            styles.healthRadarValueLine,
            compact ? 2 : 3
          )
        )}
        {metrics.map((metric, index) => {
          const dotLeft = valuePoints[index].x - (compact ? 4 : 6);
          const dotTop = valuePoints[index].y - (compact ? 4 : 6);
          const labelPoint = pointFor(metric.angle, radius + (compact ? 18 : 34));
          const labelLeft = labelPoint.x - 22;
          const labelTop = labelPoint.y - 10;
          return (
            <View key={metric.label} pointerEvents="none" style={[styles.healthRadarMetricLayer, { width: size, height: size }]}>
              <View style={[styles.healthRadarDot, compact && styles.healthRadarDotCompact, { left: dotLeft, top: dotTop }]} />
              {!compact && <Text style={[styles.healthRadarLabel, { left: labelLeft, top: labelTop }]}>{metric.label}</Text>}
            </View>
          );
        })}
        <Text style={[styles.healthRadarCenterScore, compact && styles.healthRadarCenterScoreCompact]}>{state.prediction.scores.readiness}</Text>
      </View>
    );
  };

  const renderHealthActivityRings = (state: VitoraRuntimeStateV1) => {
    const rings = [
      { label: "综合", value: state.prediction.scores.readiness, color: "#7c5cff" },
      { label: "睡眠", value: state.healthInsight.radarScores.sleep, color: "#5aa5ff" },
      { label: "周期", value: state.healthInsight.radarScores.cycle, color: "#ef6b9c" },
      { label: "代谢", value: state.healthInsight.radarScores.metabolism, color: "#f3b13f" },
      { label: "专注", value: state.healthInsight.radarScores.focus, color: "#28cf76" }
    ];
    return (
      <View style={styles.activityRingPanel}>
        <View style={styles.activityRingStack}>
          {rings.map((ring, index) => {
            const size = 232 - index * 30;
            return (
              <View
                key={ring.label}
                style={[
                  styles.activityRing,
                  {
                    width: size,
                    height: size,
                    borderRadius: size / 2,
                    borderColor: ring.color,
                    opacity: 0.94 - index * 0.08,
                    transform: [{ rotate: `${-26 + index * 8}deg` }]
                  }
                ]}
              >
                <View style={styles.activityRingGap} />
              </View>
            );
          })}
          <View style={styles.activityRingCenter}>
            <Text style={styles.activityRingScore}>{state.prediction.scores.readiness}</Text>
            <Text style={styles.activityRingCenterLabel}>综合</Text>
          </View>
        </View>
        <View style={styles.activityRingLegend}>
          {rings.map((ring) => (
            <View key={ring.label} style={styles.activityRingLegendItem}>
              <View style={[styles.activityRingLegendDot, { backgroundColor: ring.color }]} />
              <View>
                <Text style={styles.activityRingLegendLabel}>{ring.label}</Text>
                <Text style={styles.activityRingLegendValue}>{ring.value}%</Text>
              </View>
            </View>
          ))}
        </View>
      </View>
    );
  };

  const healthDetailDateLabel = (state: VitoraRuntimeStateV1) => {
    const parts = state.snapshot.date.split("-");
    return `${Number(parts[1] ?? 1)}月${Number(parts[2] ?? 1)}日`;
  };

  const openMetricExplain = (metric: HealthMetricKey) => {
    const map: Record<HealthMetricKey, { title: string; body: string }> = {
      averageEnergy: {
        title: "平均能量",
        body: `${vitoraState.prediction.scores.readiness}% 来自睡眠、周期、抗压、专注和代谢五个维度。`
      },
      sleep: {
        title: "睡眠",
        body: `睡眠分 ${vitoraState.prediction.scores.sleep}，主要参考睡眠时长、清醒时长和连续性。`
      },
      focus: {
        title: "专注",
        body: `专注分 ${vitoraState.prediction.scores.focus}，用于判断今天切换任务的成本和单任务窗口。`
      },
      stress: {
        title: "抗压",
        body: `抗压分 ${vitoraState.prediction.scores.stress}，结合 HRV、静息心率和主观压力。`
      },
      metabolism: {
        title: "代谢",
        body: `代谢分 ${vitoraState.prediction.scores.metabolism}，结合步数、活动消耗和低刺激恢复窗口。`
      }
    };
    Alert.alert(map[metric].title, map[metric].body);
  };

  const renderHealthMetricCard = (metric: HealthMetricKey, label: string, value: string, copy: string) => (
    <Pressable style={styles.nativeMetricCard} onPress={() => openMetricExplain(metric)}>
      <Text style={styles.nativeMetricLabel}>{label}</Text>
      <Text style={styles.nativeMetricValue}>{value}</Text>
      <Text style={styles.nativeMetricCopy} numberOfLines={2}>{copy}</Text>
    </Pressable>
  );

  const renderHealthDetailChips = () => {
    const chips = runtimeTodayCards.map((card) => ({
      label: card.label,
      value: card.chipValue,
      active: card.moreTab === healthDetailTab || (card.id === "today" && healthDetailTab === "summary")
    }));
    return (
      <View style={styles.healthDetailChips}>
        {chips.map((chip) => (
          <View key={chip.label} style={[styles.healthDetailChip, chip.active && styles.healthDetailChipActive]}>
            <Text style={styles.healthDetailChipLabel}>{chip.label}</Text>
            <Text style={styles.healthDetailChipValue}>{chip.value}</Text>
          </View>
        ))}
      </View>
    );
  };

  const renderHealthDetailTabs = () => (
    <View style={styles.healthDetailTabs}>
      {HEALTH_DETAIL_TABS.map((tab) => (
        <Pressable
          key={tab.id}
          style={[styles.healthDetailTabButton, healthDetailTab === tab.id && styles.healthDetailTabActive]}
          onPress={() => setHealthDetailTab(tab.id)}
        >
          <Text style={[styles.healthDetailTabText, healthDetailTab === tab.id && styles.healthDetailTabTextActive]}>{tab.label}</Text>
        </Pressable>
      ))}
    </View>
  );

  const renderDetailHeader = () => (
    <View style={styles.healthDetailHeader}>
      <Pressable style={styles.healthBackButton} onPress={closeHealthDetail}>
        <Text style={styles.healthBackText}>‹</Text>
      </Pressable>
      <View style={styles.healthDateSwitcher}>
        <Pressable style={styles.healthDateArrow} onPress={() => setHealthDateOffset((value) => value - 1)}>
          <Text style={styles.healthDateArrowText}>‹</Text>
        </Pressable>
        <Text style={styles.healthDetailDate}>{healthDetailDateLabel(activeHealthState)}</Text>
        <Pressable style={styles.healthDateArrow} onPress={() => setHealthDateOffset((value) => value + 1)}>
          <Text style={styles.healthDateArrowText}>›</Text>
        </Pressable>
      </View>
      <View style={styles.healthHeaderSpacer} />
    </View>
  );

  const renderSuggestionRows = (
    rows: { icon: string; time: string; title: string; copy: string; action: string; tone?: "green" | "purple" }[]
  ) => (
    <View style={styles.healthAdviceCard}>
      <View style={styles.healthAdviceTitleRow}>
        <Text style={styles.healthAdviceSpark}>✦</Text>
        <Text style={styles.healthAdviceTitle}>AI 建议</Text>
      </View>
      {rows.map((row) => (
        <View key={`${row.time}-${row.title}`} style={styles.healthAdviceRow}>
          <View style={[styles.healthAdviceIcon, row.tone === "green" && styles.healthAdviceIconGreen]}>
            <Text style={styles.healthAdviceIconText}>{row.icon}</Text>
          </View>
          <View style={styles.healthAdviceCopy}>
            <Text style={[styles.healthAdviceTime, row.tone === "green" && styles.healthAdviceTimeGreen]}>{row.time}</Text>
            <Text style={styles.healthAdviceName}>{row.title}</Text>
            <Text style={styles.healthAdviceText}>{row.copy}</Text>
          </View>
          <Pressable style={[styles.healthAdviceButton, row.tone === "green" && styles.healthAdviceButtonGreen]} onPress={() => openReminderSheet(row.title, row.time)}>
            <Text style={[styles.healthAdviceButtonText, row.tone === "green" && styles.healthAdviceButtonTextGreen]}>{row.action}</Text>
          </Pressable>
        </View>
      ))}
    </View>
  );

  const renderHealthSummaryDetail = () => (
    <>
      <View style={styles.summaryRadarWrap}>{renderHealthRadarGraph(activeHealthState)}</View>
      <View style={styles.summaryTranslateBlock}>
        <View style={styles.summaryPercentRow}>
          <Text style={styles.summaryPercent}>{activeHealthState.content.healthDetails.summary.scoreLabel}</Text>
          <Text style={styles.summaryPercentCopy}>高于 72% 的用户</Text>
        </View>
        <Text style={styles.summaryBodyCopy}>{activeHealthState.content.healthDetails.summary.body}</Text>
      </View>
      {renderSuggestionRows(activeHealthState.content.healthDetails.summary.suggestions)}
      <Text style={styles.healthDisclaimer}>AI 建议基于历史数据与实时状态生成，仅供参考</Text>
    </>
  );

  const renderSleepStageBar = () => (
    <View style={styles.sleepStageWrap}>
      {[
        ["#ffa83d", 10],
        ["#6c63d5", 36],
        ["#a67cf0", 34],
        ["#6c63d5", 31],
        ["#c84bd3", 45],
        ["#6c63d5", 54],
        ["#d34bd2", 52],
        ["#6c63d5", 29],
        ["#ffa83d", 9]
      ].map(([color, width], index) => (
        <View key={`sleep-${index}`} style={[styles.sleepStageSegment, { backgroundColor: String(color), width: Number(width) }]} />
      ))}
    </View>
  );

  const renderSleepLegendItem = (color: string, label: string, value: string) => (
    <View style={styles.sleepLegendItem}>
      <View style={[styles.sleepLegendDot, { backgroundColor: color }]} />
      <View>
        <Text style={styles.sleepLegendLabel}>{label}</Text>
        <Text style={styles.sleepLegendValue}>{value}</Text>
      </View>
    </View>
  );

  const renderSleepDebtTrend = () => {
    const points = [
      { x: 22, y: 74 },
      { x: 74, y: 48 },
      { x: 128, y: 66 },
      { x: 184, y: 84 },
      { x: 240, y: 88 },
      { x: 296, y: 82 }
    ];
    return (
      <View style={styles.sleepTrendChart}>
        {[28, 74, 120].map((top, index) => (
          <View key={`guide-${index}`} style={[styles.sleepTrendGuide, { top }]} />
        ))}
        <View style={styles.sleepTrendArea} />
        {points.slice(0, -1).map((point, index) =>
          renderLineBetweenPoints(point, points[index + 1], `sleep-trend-${index}`, styles.sleepTrendLine, 3)
        )}
        {points.map((point, index) => (
          <View key={`sleep-point-${index}`} style={[styles.sleepTrendPoint, { left: point.x - 4, top: point.y - 4 }]} />
        ))}
        <Text style={[styles.sleepTrendAxisLabel, { left: 0, top: 18 }]}>+6</Text>
        <Text style={[styles.sleepTrendAxisLabel, { left: 0, top: 64 }]}>+3</Text>
        <Text style={[styles.sleepTrendAxisLabel, { left: 8, top: 110 }]}>0</Text>
        <Text style={styles.sleepTrendBadge}>+2</Text>
      </View>
    );
  };

  const renderHealthSleepDetail = () => (
    <>
      <View style={styles.sleepOverviewCard}>
        <View style={styles.sleepTimes}>
          <Text>{activeHealthState.snapshot.sleep.bedtime}  入睡</Text>
          <Text>{activeHealthState.snapshot.sleep.wakeTime}☼ 起床</Text>
        </View>
        {renderSleepStageBar()}
        <View style={styles.sleepLegend}>
          {renderSleepLegendItem("#ffa83d", "清醒", `${activeHealthState.snapshot.sleep.awakeMinutes} 分钟`)}
          {renderSleepLegendItem("#a67cf0", "浅睡", `${Math.max(1, Math.round((activeHealthState.snapshot.sleep.durationMinutes - activeHealthState.snapshot.sleep.deepMinutes - activeHealthState.snapshot.sleep.remMinutes) / 60 * 10) / 10)} 小时`)}
          {renderSleepLegendItem("#6c63d5", "深睡", `${activeHealthState.snapshot.sleep.deepMinutes} 分钟`)}
          {renderSleepLegendItem("#c84bd3", "REM", `${activeHealthState.snapshot.sleep.remMinutes} 分钟`)}
        </View>
      </View>
      <View style={styles.sleepDebtBlock}>
        <View style={styles.sleepDebtRow}>
          <Text style={styles.sleepDebtValue}>✦{activeHealthState.content.healthMetrics.sleepDebt}</Text>
          <Text style={styles.sleepDebtUnit}>小时</Text>
        </View>
        <Text style={styles.sleepDebtLabel}>轻度睡眠负荷</Text>
        <Text style={styles.sleepDebtCopy}>{activeHealthState.content.healthDetails.sleep.body}</Text>
      </View>
      <View style={styles.sleepTrendCard}>
        <View style={styles.sleepTrendHeader}>
          <Text style={styles.sleepTrendTitle}>睡眠负债趋势</Text>
          <View style={styles.sleepTrendTabs}>
            {(["7", "30", "90"] as const).map((range) => (
              <Pressable key={range} onPress={() => setSleepTrendRange(range)}>
                <Text style={sleepTrendRange === range ? styles.sleepTrendTabActive : styles.sleepTrendTabText}>{range}天</Text>
              </Pressable>
            ))}
          </View>
        </View>
        {renderSleepDebtTrend()}
      </View>
      {renderSuggestionRows(activeHealthState.content.healthDetails.sleep.suggestions)}
    </>
  );

  const renderHealthCycleDetail = () => (
    <>
      <View style={styles.cycleWheelHeader}>
        <Text style={styles.cycleWheelPhase}>{activeHealthState.snapshot.cycle.phaseLabel}</Text>
        <Text style={styles.cycleWheelNext}>D{activeHealthState.snapshot.cycle.cycleDay} · 已到达日期高亮显示</Text>
      </View>
      <View style={styles.cycleRingCard}>
        <View style={styles.cycleWheel}>
          {Array.from({ length: 28 }).map((_, index) => {
            const day = index + 1;
            const currentDay = Math.max(1, Math.min(28, activeHealthState.snapshot.cycle.cycleDay));
            const angle = 90 + (day - currentDay) * (360 / 28);
            const radian = angle * Math.PI / 180;
            const radius = 130;
            const isCurrent = day === currentDay;
            const arrived = day <= currentDay;
            const phaseStyle = day <= 5
              ? styles.cycleWheelDayMenstrual
              : day <= 13
                ? styles.cycleWheelDayFollicular
                : day <= 15
                  ? styles.cycleWheelDayOvulation
                  : styles.cycleWheelDayLuteal;
            return (
              <View
                key={day}
                style={[
                  styles.cycleWheelDay,
                  {
                    left: 146 + Math.cos(radian) * radius - (isCurrent ? 22 : 14),
                    top: 146 + Math.sin(radian) * radius - (isCurrent ? 22 : 14)
                  },
                  arrived ? phaseStyle : styles.cycleWheelDayFuture,
                  isCurrent && styles.cycleWheelDayCurrent
                ]}
              >
                {isCurrent && <View style={styles.cycleWheelCurrentGlow} />}
                <Text style={[styles.cycleWheelDayText, isCurrent && styles.cycleWheelDayTextCurrent]}>{day}</Text>
                {isCurrent && <View style={styles.cycleWheelCurrentArrow} />}
              </View>
            );
          })}
          <View style={styles.cycleWheelInner}>
            <Text style={styles.cycleWheelInnerIcon}>✿</Text>
          </View>
        </View>
      </View>
      <View style={styles.cycleInfoBlock}>
        <View style={styles.cycleDayRow}>
          <Text style={styles.cycleDay}>D{activeHealthState.snapshot.cycle.cycleDay}</Text>
          <Text style={styles.cycleDayCopy}>天  {activeHealthState.snapshot.cycle.phaseLabel}</Text>
        </View>
        <View style={styles.cycleDecodeRow}>
          <Text style={styles.cycleDecodeIcon}>✿</Text>
          <View style={styles.cycleDecodeCopy}>
            <Text style={styles.cycleDecodeTitle}>{activeHealthState.content.healthDetails.cycle.title}</Text>
            <Text style={styles.cycleDecodeText}>{activeHealthState.content.healthDetails.cycle.body}</Text>
          </View>
        </View>
      </View>
      {renderSuggestionRows(activeHealthState.content.healthDetails.cycle.suggestions)}
      <Text style={styles.healthDisclaimer}>数据仅供参考，不作为医疗建议</Text>
    </>
  );

  const renderModuleWaveGraph = (tone: "focus" | "morning") => {
    const points = tone === "focus"
      ? [
        { x: 18, y: 82 },
        { x: 64, y: 62 },
        { x: 110, y: 70 },
        { x: 156, y: 38 },
        { x: 202, y: 54 },
        { x: 248, y: 34 },
        { x: 294, y: 60 }
      ]
      : [
        { x: 18, y: 88 },
        { x: 66, y: 72 },
        { x: 114, y: 44 },
        { x: 162, y: 58 },
        { x: 210, y: 36 },
        { x: 258, y: 48 },
        { x: 306, y: 28 }
      ];
    return (
      <View style={[styles.healthModuleWaveCard, styles.healthModuleWaveCardClean]}>
        <View style={styles.healthModuleWaveAxisY} />
        <View style={styles.healthModuleWaveAxisX} />
        {[36, 66, 96].map((top, index) => <View key={index} style={[styles.healthModuleWaveGuide, { top }]} />)}
        {points.slice(0, -1).map((point, index) =>
          renderLineBetweenPoints(point, points[index + 1], `${tone}-wave-${index}`, tone === "focus" ? styles.focusModuleWaveLine : styles.morningModuleWaveLine, 3)
        )}
        {points.map((point, index) => (
          <View
            key={`${tone}-wave-point-${index}`}
            style={[
              styles.healthModuleWavePoint,
              tone === "morning" && styles.healthModuleWavePointMorning,
              { left: point.x - 5, top: point.y - 5 }
            ]}
          />
        ))}
      </View>
    );
  };

  const renderHealthFocusDetail = () => (
    <>
      {renderModuleWaveGraph("focus")}
      <View style={styles.healthModuleStateCard}>
        <Text style={styles.healthModuleStateKicker}>今日专注状态</Text>
        <View style={styles.healthModuleStateRow}>
          <Text style={styles.healthModuleStateScore}>{activeHealthState.prediction.scores.focus}</Text>
          <Text style={styles.healthModuleStateTitle}>{activeHealthState.prediction.scores.focus < 68 ? "切换成本偏高" : "单任务窗口稳定"}</Text>
        </View>
        <Text style={styles.healthModuleStateCopy}>{activeHealthState.content.healthDetails.focus.body}</Text>
        <Text style={styles.healthModuleStateHint}>建议 {focusMinutes} 分钟单任务专注，先降低切换成本。</Text>
      </View>
      {renderSuggestionRows(activeHealthState.content.healthDetails.focus.suggestions)}
    </>
  );

  const renderHealthMetabolismDetail = () => (
    <>
      <View style={styles.metabolismHeartCard}>
        <LinearGradient colors={["#2f1218", "#c83b44", "#ffb45e"]} locations={[0, 0.55, 1]} style={styles.glassFill} />
        <View style={styles.healthModuleHeaderRow}>
          <Text style={styles.healthModuleTitle}>代谢</Text>
          <Text style={styles.healthModuleBadge}>{activeHealthState.prediction.scores.metabolism < 68 ? "偏低" : "稳定"}</Text>
        </View>
        <Animated.Text style={[styles.metabolismHeart, { transform: [{ scale: heartPulseAnim }] }]}>♥</Animated.Text>
        <Text style={styles.metabolismHeartScore}>{activeHealthState.prediction.scores.metabolism}</Text>
        <Text style={styles.metabolismHeartCopy}>{activeHealthState.content.healthDetails.metabolism.body}</Text>
        <View style={styles.metabolismHeartStats}>
          <Text style={styles.metabolismHeartStat}>{activeHealthState.snapshot.activity.steps.toLocaleString()} 步</Text>
          <Text style={styles.metabolismHeartStat}>{activeHealthState.snapshot.activity.activeCalories} kcal</Text>
          <Text style={styles.metabolismHeartStat}>{activeHealthState.snapshot.activity.distanceKm.toFixed(2)} km</Text>
        </View>
      </View>
      {renderSuggestionRows(activeHealthState.content.healthDetails.metabolism.suggestions)}
    </>
  );

  const renderHealthMorningDetail = () => (
    <>
      {renderModuleWaveGraph("morning")}
      <View style={styles.healthModuleStateCard}>
        <Text style={styles.healthModuleStateKicker}>晨间计划</Text>
        <View style={styles.healthModuleStateRow}>
          <Text style={styles.healthModuleStateScore}>{activeHealthState.prediction.scores.morning}</Text>
          <Text style={styles.healthModuleStateTitle}>{activeHealthState.prediction.scores.morning < 70 ? "低刺激启动" : "稳定启动"}</Text>
        </View>
        <Text style={styles.healthModuleStateCopy}>{activeHealthState.content.healthDetails.summary.body}</Text>
        <View style={styles.healthModuleMiniStats}>
          <Text style={styles.healthModuleMiniStat}>{activeHealthState.snapshot.activity.distanceKm.toFixed(2)} KM</Text>
          <Text style={styles.healthModuleMiniStat}>{activeHealthState.snapshot.recovery.restingHeartRate} bpm</Text>
          <Text style={styles.healthModuleMiniStat}>{activeHealthState.snapshot.cycle.phaseLabel}</Text>
        </View>
      </View>
      {renderSuggestionRows(activeHealthState.content.healthDetails.summary.suggestions)}
    </>
  );

  const renderHealthDetail = () => (
    <LinearGradient colors={["#ded9ff", "#f5f2ff", "#ffffff"]} locations={[0, 0.35, 1]} style={styles.healthDetailPage}>
      <ScrollView contentContainerStyle={styles.healthDetailContent} showsVerticalScrollIndicator={false}>
        {renderDetailHeader()}
        {healthDetailTab === "sleep"
          ? renderHealthSleepDetail()
          : healthDetailTab === "cycle"
            ? renderHealthCycleDetail()
            : healthDetailTab === "focus"
              ? renderHealthFocusDetail()
              : healthDetailTab === "metabolism"
                ? renderHealthMetabolismDetail()
                : renderHealthSummaryDetail()}
      </ScrollView>
      {renderHealthDetailTabs()}
    </LinearGradient>
  );

  const renderReminderSheet = () => {
    if (!reminderSheet) return null;
    return (
      <View style={styles.reminderLayer}>
        <Pressable style={styles.reminderBackdrop} onPress={() => setReminderSheet(null)} />
        <BlurView intensity={58} tint="dark" style={styles.reminderPanel}>
          <LinearGradient pointerEvents="none" colors={["rgba(22,25,31,0.88)", "rgba(37,39,48,0.74)"]} style={styles.glassFill} />
          <View style={styles.reminderHandle} />
          <Text style={styles.reminderTitle}>设置提醒</Text>
          <Text style={styles.reminderSource}>{reminderSheet.source}</Text>
          <View style={styles.reminderTimeRow}>
            <Pressable style={styles.reminderAdjust} onPress={() => updateReminderTime(shiftClockTime(reminderSheet.time, -15))}>
              <Text style={styles.reminderAdjustText}>−15</Text>
            </Pressable>
            <Text style={styles.reminderTime}>{reminderSheet.time}</Text>
            <Pressable style={styles.reminderAdjust} onPress={() => updateReminderTime(shiftClockTime(reminderSheet.time, 15))}>
              <Text style={styles.reminderAdjustText}>+15</Text>
            </Pressable>
          </View>
          <View style={styles.reminderQuickRow}>
            {REMINDER_QUICK_TIMES.map((time) => (
              <Pressable key={time} style={[styles.reminderQuick, reminderSheet.time === time && styles.reminderQuickActive]} onPress={() => updateReminderTime(time)}>
                <Text style={[styles.reminderQuickText, reminderSheet.time === time && styles.reminderQuickTextActive]}>{time}</Text>
              </Pressable>
            ))}
          </View>
          <View style={styles.reminderActions}>
            <Pressable style={styles.reminderCancel} onPress={() => setReminderSheet(null)}>
              <Text style={styles.reminderCancelText}>关闭</Text>
            </Pressable>
            <Pressable style={styles.reminderConfirm} onPress={confirmReminder}>
              <Text style={styles.reminderConfirmText}>确定</Text>
            </Pressable>
          </View>
        </BlurView>
      </View>
    );
  };

  const renderHealthExperienceRows = (state: VitoraRuntimeStateV1) => (
    <Text style={styles.nativeExperienceInline} numberOfLines={2}>
      本期正在经历：{healthExperienceRows(state).join("、")}
    </Text>
  );

  const renderMonthlyEnergyGrid = (state: VitoraRuntimeStateV1) => (
    <View style={styles.monthlyEnergyGrid}>
      {monthlyEnergyValues(state).map((value, index) => (
        <View key={`month-energy-${index}`} style={[styles.monthlyEnergyCell, { backgroundColor: heatColor(value) }, value === 3 && styles.monthlyEnergyCellHot]} />
      ))}
    </View>
  );

  const renderHealth = () => (
    <LinearGradient colors={["#d9d4ff", "#f0edff", "#ffffff"]} locations={[0, 0.34, 1]} style={styles.nativeHealth}>
      <ScrollView style={styles.nativeHealthScroll} contentContainerStyle={styles.nativeHealthContent} showsVerticalScrollIndicator={false}>
        <View style={styles.nativeHello}>
          <Pressable style={styles.nativeProfileButton} onPress={() => setProfileOpen(true)}>
            <Text style={styles.nativeProfileIcon}>♙</Text>
          </Pressable>
          <Text style={styles.nativeHi}>Hi {vitoraState.profileSurface.displayName}</Text>
        </View>
        <Text style={styles.nativeHealthTitle}>{personaSummaryLabel(vitoraState)}</Text>
        {renderHealthExperienceRows(vitoraState)}
        <View style={styles.nativeStampStage}>
          {vitoraState.achievementStamps.slice(0, 5).map((stamp, index) => renderHealthStamp(
            stamp,
            [styles.nativeStampA, styles.nativeStampB, styles.nativeStampC, styles.nativeStampD, styles.nativeStampE][index] ?? styles.nativeStampA
          ))}
        </View>
        <View style={styles.nativeMonthCard}>
          <View style={styles.nativeMonthHeader}>
            <View>
              <Text style={styles.nativeWeekKicker}>30 天能量状态</Text>
              <Text style={styles.nativeWeekTitle}>高低精力分布</Text>
            </View>
            <View style={styles.nativeMonthScorePill}>
              <Text style={styles.nativeMonthScore}>{vitoraState.prediction.scores.readiness}%</Text>
            </View>
          </View>
          <View style={styles.nativeMonthStats}>
            <Text style={styles.nativeMonthStatHigh}>高精力 {monthlyEnergyCounts(vitoraState).high} 天</Text>
            <Text style={styles.nativeMonthStatLow}>低精力 {monthlyEnergyCounts(vitoraState).low} 天</Text>
            <Text style={styles.nativeMonthStatSteady}>平稳 {monthlyEnergyCounts(vitoraState).steady} 天</Text>
          </View>
          <View style={styles.nativeMonthBody}>
            <View style={styles.nativeWeekLeft}>
              {renderMonthlyEnergyGrid(vitoraState)}
              <View style={styles.nativeMonthLegend}>
                <Text style={styles.nativeMonthLegendText}>绿色 高精力</Text>
                <Text style={styles.nativeMonthLegendText}>灰色 信号不足</Text>
              </View>
            </View>
            <View style={styles.nativeRadarWrap}>
              {renderHealthRadarGraph(vitoraState, true)}
              <Text style={styles.nativeRadarCaption}>睡眠 / 周期 / 抗压 / 代谢 / 专注</Text>
            </View>
          </View>
          <Text style={styles.nativeWeekCopy} numberOfLines={2}>{vitoraState.content.healthSummary}</Text>
          <Pressable style={styles.nativeMoreButton} onPress={() => openHealthDetail("summary")}>
            <Text style={styles.nativeMore}>更多</Text>
          </Pressable>
        </View>
        <View style={styles.nativeAiRow}>
          <Text style={styles.nativeAiTitle}>AI 身体翻译</Text>
          <Pressable style={styles.nativeDetailPill} onPress={() => openHealthDetail("summary")}>
            <Text style={styles.nativeDetailPillText}>详情</Text>
          </Pressable>
        </View>
        <Pressable style={styles.nativeAverageEnergyCard} onPress={() => openMetricExplain("averageEnergy")}>
          <Text style={styles.nativeAverageEnergyLabel}>平均能量</Text>
          <Text style={styles.nativeAverageEnergyValue}>{vitoraState.prediction.scores.readiness}</Text>
          <Text style={styles.nativeAverageEnergyCopy}>由睡眠、周期、抗压、专注和代谢共同计算</Text>
        </Pressable>
        <View style={styles.nativeMetricGrid}>
          {renderHealthMetricCard("sleep", "睡眠", String(vitoraState.prediction.scores.sleep), sleepDebtDisplay(vitoraState))}
          {renderHealthMetricCard("focus", "专注", String(vitoraState.prediction.scores.focus), "切换成本")}
        </View>
        <View style={styles.nativeMetricGrid}>
          {renderHealthMetricCard("stress", "抗压", String(vitoraState.prediction.scores.stress), "恢复稳定")}
          {renderHealthMetricCard("metabolism", "代谢", String(vitoraState.prediction.scores.metabolism), "消耗窗口")}
        </View>
      </ScrollView>
    </LinearGradient>
  );

  const todayPillText = (card: TodayCard) => {
    if (card.id === "today") return "省电模式";
    if (card.id === "sleep") return predictionSleepDebtLabel();
    if (card.id === "cycle") return vitoraState.snapshot.cycle.phaseLabel;
    if (card.id === "focus") return card.status === "warning" ? "需保护" : "稳定";
    if (card.id === "metabolism") return card.status === "warning" ? "差" : "正常";
    return "省电模式";
  };

  const predictionSleepDebtLabel = () => {
    const sleepChip = vitoraState.prediction.scoreBreakdown.chips.find((chip) => chip.id === "sleep");
    return sleepChip?.status === "warning" ? "睡眠债1" : "睡眠债0";
  };

  const renderTodayCardHeader = (card: TodayCard) => (
    <View style={styles.todayCardHeader}>
      <View style={styles.todayCardHeaderCopy}>
        {card.id === "cycle" ? (
          <View style={styles.todayCycleTitleRow}>
            <Text style={styles.todayCardTitle}>周期</Text>
            <Text style={styles.todayCycleTitleDay}>D{vitoraState.snapshot.cycle.cycleDay}</Text>
            <Text style={styles.todayCycleTitleUnit}>天</Text>
          </View>
        ) : (
          <Text style={styles.todayCardTitle}>{card.title}</Text>
        )}
        <Text style={styles.todayCardSubtitle}>{card.subtitle}</Text>
      </View>
      <Pressable style={styles.todayMorePill} onPress={() => openTodayMore(card.id)}>
        <Text style={styles.todayMoreText}>{todayPillText(card)}</Text>
      </Pressable>
    </View>
  );

  const renderTodayNavFade = (side: "left" | "right") => (
    <View pointerEvents="none" style={[styles.todayNavFade, side === "left" ? styles.todayNavFadeLeft : styles.todayNavFadeRight]}>
      {[0.98, 0.72, 0.42, 0.16].map((opacity, index) => (
        <View
          key={`${side}-${index}`}
          style={[
            styles.todayNavFadeSegment,
            side === "left" ? { left: index * 9, opacity } : { right: index * 9, opacity }
          ]}
        />
      ))}
    </View>
  );

  const renderTodayNav = () => (
    <View style={styles.todayNavRail}>
      <ScrollView
        ref={todayNavScrollRef}
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={styles.todayNavContent}
      >
        {todayNavItems.map((item) => {
          const isActive = todayActiveId === item.id;
          const tone = TODAY_TONE_THEMES[item.tone];
          return (
            <Pressable
              testID={`today-nav-${item.id}`}
              key={item.id}
              style={[
                styles.todayNavCircle,
                isActive && styles.todayNavCircleActive,
                isActive && { backgroundColor: `${tone.accent}1F`, shadowColor: tone.accent }
              ]}
              onPress={() => openTodayCard(item.id)}
            >
              {item.status === "warning" && <View style={styles.todayNavAlertDot} />}
              <Text style={[styles.todayNavLabel, isActive && styles.todayNavLabelActive]}>{item.label}</Text>
              <Text style={[styles.todayNavValue, isActive && styles.todayNavValueActive]} numberOfLines={1}>
                {item.chipValue}
              </Text>
            </Pressable>
          );
        })}
      </ScrollView>
      {renderTodayNavFade("left")}
      {renderTodayNavFade("right")}
    </View>
  );

  const renderTodayEnergyVisual = () => {
    const sun = sunPosition();
    return (
    <View style={styles.todaySunVisual}>
      <DotMatrixText value={vitoraState.prediction.todayScore} dot={7} gap={5} style={styles.todayDotMatrixScore} />
      <Text style={styles.todayDotSub}>On Track</Text>
      <View style={styles.todaySunArc} />
      <Animated.View
        style={[
          styles.todaySunDot,
          {
            left: sun.x,
            top: sun.y,
            backgroundColor: activeToneTheme.accent,
            opacity: energyFlowAnim.interpolate({ inputRange: [0, 1], outputRange: [0.82, 1] }),
            transform: [
              { translateY: energyFlowAnim.interpolate({ inputRange: [0, 1], outputRange: [0, -5] }) },
              { scale: energyFlowAnim.interpolate({ inputRange: [0, 1], outputRange: [0.92, 1.12] }) }
            ]
          }
        ]}
      />
      <View style={[styles.todaySunDot, { left: 172, top: 98 }]} />
      <View style={[styles.todaySunDot, { left: 268, top: 98 }]} />
      <View style={styles.todaySunHorizon} />
      <Text style={[styles.todaySunTime, { left: 14 }]}>6:14{`\n`}Sunrise</Text>
      <Text style={[styles.todaySunTime, { left: 134 }]}>Good Sun</Text>
      <Text style={[styles.todaySunTime, { right: 10 }]}>17:21{`\n`}Sunset</Text>
    </View>
    );
  };

  const renderTodaySleepVisual = () => (
    <View style={styles.todaySleepVisual} {...sleepPanResponder.panHandlers}>
      <View style={styles.todaySleepPanel}>
        <View>
          <View style={styles.todaySleepTotalRow}>
            <DotMatrixText value={sleepDisplayHours} dot={8} gap={5} />
            <Text style={styles.todaySleepHourUnit}>h</Text>
          </View>
          <Text style={styles.todaySleepSmallLabel}>修复目标 · {Math.round(sleepTargetMinutes / 6) / 10}h</Text>
        </View>
        <View style={styles.todaySleepQuality}>
          <Text style={styles.todaySleepQualityLabel}>睡眠质量</Text>
          <Text style={styles.todaySleepQualityValue}>{vitoraState.prediction.scores.sleep >= 76 ? "优秀" : "恢复中"}</Text>
        </View>
      </View>
      <View style={styles.todaySleepChart}>
        {[
          ["#ea66c7", 62 + sleepWindowShift],
          ["#5c96df", 38 - sleepWindowShift * 2],
          ["#bc3dd1", 56 + sleepWindowShift],
          ["#5c96df", 52 - sleepWindowShift],
          ["#bc3dd1", 64],
          ["#5c96df", 44 + sleepWindowShift],
          ["#bc3dd1", 60 - sleepWindowShift],
          ["#5c96df", 42 + sleepWindowShift],
          ["#ea66c7", 66 - sleepWindowShift]
        ].map(([color, height], index) => (
          <View key={index} style={[styles.todaySleepBar, { backgroundColor: String(color), height: Number(height) }]} />
        ))}
      </View>
      <View style={styles.todaySleepAdjustRow}>
        <Pressable style={styles.todaySleepAdjust} onPress={() => adjustSleepTarget(15)}>
          <Text style={styles.todaySleepAdjustText}>+</Text>
        </Pressable>
        <Text style={styles.todaySleepWindowText}>左右滑动切换睡眠窗口</Text>
        <Pressable style={styles.todaySleepAdjust} onPress={() => adjustSleepTarget(-15)}>
          <Text style={styles.todaySleepAdjustText}>−</Text>
        </Pressable>
      </View>
      <View style={styles.todaySleepTimeRow}>
        <Text style={styles.todaySleepTimeText}>{sleepBedTime} 入睡</Text>
        <Text style={styles.todaySleepTimeDots}>···</Text>
        <Text style={styles.todaySleepTimeText}>{sleepWakeTime} 起床</Text>
      </View>
      <Text style={styles.todaySleepHint}>{vitoraState.content.healthDetails.sleep.suggestions[0]?.copy}</Text>
    </View>
  );

  const renderTodayCycleVisual = () => {
    const day = vitoraState.snapshot.cycle.cycleDay;
    const currentIndex = Math.max(1, Math.min(day, 28));
    return (
      <View style={styles.todayCycleVisual}>
        <Text style={styles.todayCyclePhaseTop}>{vitoraState.snapshot.cycle.phaseLabel}</Text>
        <View style={styles.todayCycleDial}>
          {Array.from({ length: 28 }).map((_, index) => {
            const dateNumber = index + 1;
            const angle = -90 + index * (360 / 28);
            const radian = angle * Math.PI / 180;
            const radius = 106;
            const left = 122 + Math.cos(radian) * radius - 11;
            const top = 122 + Math.sin(radian) * radius - 11;
            const isActive = dateNumber === currentIndex;
            const isPeriod = dateNumber <= 7;
            const isOvulation = dateNumber === 14;
            return (
              <View
                key={dateNumber}
                style={[
                  styles.todayCycleDay,
                  { left, top },
                  isPeriod && styles.todayCycleDay_period,
                  isOvulation && styles.todayCycleDay_ovulation,
                  isActive && styles.todayCycleDay_active
                ]}
              >
                <Text style={[styles.todayCycleDayText, isActive && styles.todayCycleDayText_active]}>{dateNumber}</Text>
              </View>
            );
          })}
          <View style={styles.todayCycleInner} />
          <View style={[styles.todayCycleOrb, styles.todayCycleOrb_large]} />
          <View style={[styles.todayCycleOrb, styles.todayCycleOrb_a]} />
          <View style={[styles.todayCycleOrb, styles.todayCycleOrb_b]} />
          <View style={[styles.todayCycleOrb, styles.todayCycleOrb_c]} />
          <View style={styles.todayCycleCurrentBadge}>
            <Text style={styles.todayCycleCurrentText}>{currentIndex}</Text>
          </View>
        </View>
        <Text style={[styles.todayCyclePhaseLabel, styles.todayCyclePhaseLeft]}>黄体期</Text>
        <Text style={[styles.todayCyclePhaseLabel, styles.todayCyclePhaseRight]}>卵泡期</Text>
        <Text style={[styles.todayCyclePhaseLabel, styles.todayCyclePhaseBottom]}>排卵期</Text>
      </View>
    );
  };

  const renderTodayFocusVisual = () => (
    <View style={styles.todayFocusVisual} {...focusPanResponder.panHandlers}>
      <View style={styles.todayFocusShapeWrap}>
        <View style={styles.todayFocusShapeLobeLeft} />
        <View style={styles.todayFocusShapeLobeRight} />
        <View style={styles.todayFocusShapePoint} />
      </View>
      <View style={styles.todayFocusDotRow}>
        <DotMatrixText value={focusMinutes} dot={8} gap={5} />
        <Text style={styles.todayFocusUnit}>分钟</Text>
      </View>
      <View style={styles.todayFocusTicks}>
        {Array.from({ length: 19 }).map((_, index) => {
          const active = Math.round((focusMinutes - 10) / 40 * 18) === index;
          return <View key={index} style={[styles.todayFocusTick, active && styles.todayFocusTickActive]} />;
        })}
      </View>
      <View style={styles.todayFocusRange}>
        <Pressable style={styles.todayFocusAdjust} onPress={() => adjustFocusMinutes(5)}>
          <Text style={styles.todayFocusAdjustText}>+</Text>
        </Pressable>
        <Pressable style={styles.todayFocusAdjust} onPress={() => adjustFocusMinutes(-5)}>
          <Text style={styles.todayFocusAdjustText}>−</Text>
        </Pressable>
      </View>
      <Text style={styles.todayFocusHint}>建议 {focusMinutes} 分钟单任务专注，先降低切换成本。</Text>
    </View>
  );

  const renderTodayMetabolismVisual = () => (
    <View style={styles.todayMetabolismVisual}>
      <Text style={styles.todayMetabolismValue}>{vitoraState.snapshot.activity.steps.toLocaleString()}</Text>
      <Animated.View style={[styles.todayHeartBadge, { transform: [{ scale: heartPulseAnim }] }]}>
        <Text style={styles.todayHeartText}>{vitoraState.snapshot.recovery.restingHeartRate}</Text>
      </Animated.View>
      <View style={styles.todayMetabolismBar}>
        <View style={styles.todayMetabolismFill}>
          {Array.from({ length: 7 }).map((_, index) => <View key={index} style={styles.todayMetabolismStripe} />)}
        </View>
      </View>
      <View style={styles.todayMetabolismStats}>
        <Text>◍ {vitoraState.snapshot.activity.distanceKm.toFixed(2)} km</Text>
        <Text>◷ {vitoraState.snapshot.sleep.durationMinutes} min</Text>
        <Text>⚡{vitoraState.snapshot.activity.activeCalories} kcal</Text>
      </View>
    </View>
  );

  const renderTodayMorningVisual = () => (
    <View style={styles.todayMorningVisual}>
      <View style={styles.todayMorningMap}>
        <View style={styles.todayMorningMapShape} />
        <Animated.View
          style={[
            styles.todayMorningGlow,
            {
              opacity: pinGlowAnim.interpolate({ inputRange: [0, 1], outputRange: [0.22, 0.72] }),
              transform: [{ scale: pinGlowAnim.interpolate({ inputRange: [0, 1], outputRange: [0.84, 1.18] }) }]
            }
          ]}
        />
        <View style={[styles.todayMorningRoad, { transform: [{ rotate: "-24deg" }] }]} />
        <View style={[styles.todayMorningRoad, { left: 98, transform: [{ rotate: "8deg" }] }]} />
        <View style={styles.todayMorningSunBeam} />
        <View style={styles.todayMorningPin} />
        <Text style={styles.todayMorningPlace}>静安寺</Text>
      </View>
      <View style={styles.todayMorningStats}>
        <Text style={styles.todayMorningKm}>{vitoraState.snapshot.activity.distanceKm.toFixed(2)}</Text>
        <Text style={styles.todayMorningMeta}>KM{`\n`}{vitoraState.snapshot.recovery.restingHeartRate} bpm{`\n`}{vitoraState.snapshot.cycle.phaseLabel}</Text>
      </View>
    </View>
  );

  const renderTodayCardVisual = (card: TodayCard) => {
    if (card.id === "sleep") return renderTodaySleepVisual();
    if (card.id === "cycle") return renderTodayCycleVisual();
    if (card.id === "focus") return renderTodayFocusVisual();
    if (card.id === "metabolism") return renderTodayMetabolismVisual();
    if (card.id === "morning") return renderTodayMorningVisual();
    return renderTodayEnergyVisual();
  };

  const todayCardToneStyle = (tone: TodayCard["tone"]) => {
    if (tone === "sleep") return styles.todayCard_sleep;
    if (tone === "cycle") return styles.todayCard_cycle;
    if (tone === "focus") return styles.todayCard_focus;
    if (tone === "metabolism") return styles.todayCard_metabolism;
    if (tone === "morning") return styles.todayCard_morning;
    return styles.todayCard_energy;
  };

  const handleTodayAction = (card: TodayCard) => {
    if (card.actionType === "reminder") {
      const time = card.id === "sleep" ? "21:30" : card.id === "metabolism" ? "15:00" : vitoraState.prediction.primaryAction.scheduledTime;
      openReminderSheet(card.action, time);
      return;
    }
    if (card.actionType === "map_guidance") {
      openMorningMap();
      return;
    }
    if (card.id === "focus") {
      openTimedSession("focusTimer", card.action, "focus");
      return;
    }
    if (card.id === "metabolism") {
      openTimedSession("metabolismTimer", card.action, "metabolism");
      return;
    }
    openBreathingPractice(card.id);
  };

  const cycleReferenceOpacity = () => {
    setReferenceOverlayOpacity((value) => (value >= 0.42 ? 0.18 : value + 0.12));
  };

  const renderTodayReferenceOverlay = () => {
    if (!__DEV__ || !referenceOverlayVisible) return null;
    return (
      <View pointerEvents="none" style={[styles.todayReferenceOverlay, { opacity: referenceOverlayOpacity }]}>
        <ImageBackground
          source={TODAY_REFERENCE_IMAGES[activeToday.id]}
          resizeMode="stretch"
          style={styles.todayReferenceOverlayImage}
          imageStyle={styles.todayReferenceImage}
        />
      </View>
    );
  };

  const renderTodayReferenceControls = () => {
    if (!__DEV__) return null;
    return (
      <View style={styles.todayReferenceControls}>
        <Pressable style={[styles.todayReferenceButton, referenceOverlayVisible && styles.todayReferenceButtonActive]} onPress={() => setReferenceOverlayVisible((value) => !value)}>
          <Text style={styles.todayReferenceButtonText}>Ref</Text>
        </Pressable>
        <Pressable style={styles.todayReferenceButton} onPress={cycleReferenceOpacity}>
          <Text style={styles.todayReferenceButtonText}>{Math.round(referenceOverlayOpacity * 100)}%</Text>
        </Pressable>
      </View>
    );
  };

  const renderEnergyRecordPanel = () => {
    if (energyRecordState === "idle") return null;
    const isSaving = energyRecordState === "saving";
    const isSaved = energyRecordState === "saved";
    return (
      <Animated.View
        style={[
          styles.energyRecordPanel,
          {
            opacity: energyFlowAnim.interpolate({ inputRange: [0, 1], outputRange: [0.86, 1] }),
            transform: [{ scale: energyFlowAnim.interpolate({ inputRange: [0, 1], outputRange: [0.985, 1.01] }) }]
          }
        ]}
      >
        <Text style={styles.energyRecordKicker}>{isSaved ? "已保存" : isSaving ? "正在保存" : "今日记录"}</Text>
        <Text style={styles.energyRecordTitle}>
          {isSaved ? "这条记录已进入你的今日能量" : isSaving ? "Dori 正在把状态保存下来" : "记录一下现在的身体感受"}
        </Text>
        <Text style={styles.energyRecordCopy}>
          {isSaved
            ? `综合 ${vitoraState.prediction.todayScore}%，${vitoraState.snapshot.cycle.phaseLabel}，已生成今日能量油戳。`
            : `当前建议：${vitoraState.prediction.primaryAction.title}。完成记录后会保存到健康时间线。`}
        </Text>
        {!isSaved && !isSaving ? (
          <View style={styles.energyRecordActions}>
            {["还可以", "有点累", "想恢复"].map((label) => (
              <Pressable key={label} style={styles.energyRecordOption} onPress={saveEnergyRecord}>
                <Text style={styles.energyRecordOptionText}>{label}</Text>
              </Pressable>
            ))}
          </View>
        ) : null}
      </Animated.View>
    );
  };

  const renderEnergyChatPreview = () => {
    const sleepChip = vitoraState.prediction.scoreBreakdown.chips.find((chip) => chip.id === "sleep");
    const cycleChip = vitoraState.prediction.scoreBreakdown.chips.find((chip) => chip.id === "cycle");
    const focusChip = vitoraState.prediction.scoreBreakdown.chips.find((chip) => chip.id === "focus");
    const stressChip = vitoraState.prediction.scoreBreakdown.chips.find((chip) => chip.id === "stress");
    const isTodayCard = activeToday.id === "today";
    const previewTitle = isTodayCard
      ? `你今日的综合数据是 ${vitoraState.prediction.todayScore}%`
      : `${activeToday.title} · ${activeToday.status === "warning" ? "需要关注" : "状态稳定"}`;
    const previewCopy = isTodayCard
      ? `基础分 ${vitoraState.prediction.scoreBreakdown.baseScore}，睡眠 ${sleepChip?.value ?? "-"}，周期 ${cycleChip?.contribution ?? 0}，专注 ${focusChip?.value ?? "-"}，抗压 ${stressChip?.value ?? "-"}。`
      : activeToday.monitor;
    return (
      <Animated.View
        testID="energy-chat-preview"
        style={[
          styles.energyChatPreview,
          {
            opacity: cardIntroAnim,
            transform: [{ translateY: cardIntroAnim.interpolate({ inputRange: [0, 1], outputRange: [8, 0] }) }]
          }
        ]}
      >
        <Pressable
          testID="energy-chat-preview-open"
          style={styles.energyChatPreviewMain}
          onPress={() => openEnergyChat()}
        >
          <View style={styles.energyChatPreviewTop}>
          <Text style={styles.energyChatPreviewKicker}>Dori 能量分析</Text>
          <Text style={styles.energyChatPreviewBadge}>可对话</Text>
        </View>
        <Text style={styles.energyChatPreviewTitle}>{previewTitle}</Text>
        <Text style={styles.energyChatPreviewCopy} numberOfLines={2}>{previewCopy}</Text>
          <Text style={styles.energyChatPreviewHint}>在下方输入框直接和 Dori 对话，或用 + 生成今日快卡</Text>
        </Pressable>
        {renderEnergyRecordPanel()}
      </Animated.View>
    );
  };

  const renderEnergyLiveCards = () => {
    if (!energyLiveCards.length) return null;
    return (
      <View style={styles.energyLiveList}>
        {energyLiveCards.map((card) => (
          <View key={card.id} style={styles.energyLiveCard}>
            <ImageBackground
              source={card.imageUri ? { uri: card.imageUri } : ENERGY_LIVE_CARD_FALLBACK_IMAGE}
              resizeMode="cover"
              style={styles.energyLiveImage}
              imageStyle={styles.energyLiveImageRadius}
            >
              <LinearGradient colors={["rgba(9,12,15,0.10)", "rgba(9,12,15,0.68)"]} style={styles.glassFill} />
              <View style={styles.energyLiveMeta}>
                <Text style={styles.energyLiveKicker}>今日快卡 · {card.source === "photo" ? "照片记录" : "示例记录"}</Text>
                <Text style={styles.energyLiveTitle}>{card.score}% 能量状态</Text>
                <Text style={styles.energyLiveCopy}>{card.advice}</Text>
              </View>
              <View style={styles.energyLiveActions}>
                <Pressable style={styles.energyLiveSound} onPress={playEnergyVoiceCue}>
                  <Text style={styles.energyLiveSoundText}>{energyVoiceCueActive ? "播放中" : "声音"}</Text>
                </Pressable>
                <Pressable style={styles.energyLiveBreath} onPress={() => openBreathingPractice("today")}>
                  <Text style={styles.energyLiveBreathText}>去呼吸</Text>
                </Pressable>
              </View>
            </ImageBackground>
          </View>
        ))}
      </View>
    );
  };

  const renderTodayInlineChat = () => {
    const messages = energyMessages.filter(isRenderableMessage);
    if (!messages.length) {
      return (
        <View style={styles.todayInlineEmpty}>
          <Text style={styles.todayInlineEmptyTitle}>Dori 在这里等你</Text>
          <Text style={styles.todayInlineEmptyCopy}>输入你的感受，或点击 + 发一张照片生成今日快卡。</Text>
        </View>
      );
    }
    return (
      <View testID="today-inline-chat" style={styles.todayInlineChat}>
        {messages.map((message, index) => (
          <View key={messageKey(message, index)} style={[styles.voiceMessageRow, message.role === "user" && styles.voiceMessageRowUser]}>
            {message.role !== "user" ? <View style={styles.voiceMessageTail} /> : null}
            <View style={[styles.voiceMessageBar, message.role === "user" && styles.voiceMessageBarUser]}>
              {renderMessageContent(message, index, styles.voiceMessageText)}
            </View>
            {message.role === "user" ? <View style={[styles.voiceMessageTail, styles.voiceMessageTailUser]} /> : null}
          </View>
        ))}
      </View>
    );
  };

  const renderTodayComposer = () => (
    <View testID="today-inline-composer" pointerEvents="box-none" style={styles.todayComposerDock}>
      <Pressable
        testID="today-composer-focus"
        style={styles.todayComposerInputWrap}
        onPress={() => {
          ensureEnergyConversation();
          setTimeout(() => todayInputRef.current?.focus(), 40);
        }}
      >
        <BlurView pointerEvents="none" intensity={42} tint="dark" style={styles.glassFill} />
        <LinearGradient pointerEvents="none" colors={["rgba(255,255,255,0.20)", "rgba(255,255,255,0.06)"]} style={styles.glassFill} />
        <TextInput
          ref={todayInputRef}
          testID="today-inline-input"
          value={draft}
          onChangeText={setDraft}
          placeholder="写点什么..."
          placeholderTextColor="rgba(255,255,255,0.62)"
          returnKeyType="send"
          onFocus={ensureEnergyConversation}
          onSubmitEditing={sendTodayEnergyMessage}
          onPressIn={() => {
            ensureEnergyConversation();
            setTimeout(() => todayInputRef.current?.focus(), 40);
          }}
          style={styles.todayComposerInput}
        />
        <Pressable testID="today-photo-plus" style={styles.todayComposerInlineButton} onPress={openEnergyPhotoMenu}>
          <Text style={styles.todayComposerInlinePlus}>＋</Text>
        </Pressable>
        <Pressable
          testID="today-inline-send"
          style={[styles.todayComposerInlineSend, !draft.trim() && styles.todayComposerInlineSendIdle]}
          onPress={sendTodayEnergyMessage}
          disabled={!draft.trim()}
        >
          <Text style={styles.todayComposerInlineSendText}>↑</Text>
        </Pressable>
      </Pressable>
    </View>
  );

  const renderTodayArtworkTextOverlay = () => {
    if (activeToday.id !== "today") return null;
    return (
      <View pointerEvents="none" style={styles.todayArtworkSubtitlePatch}>
        <Text style={styles.todayArtworkSubtitleText} numberOfLines={2}>
          {`${vitoraState.snapshot.cycle.phaseLabel}，${vitoraState.profile.personaName}适合温和行动，保护恢复窗口。`}
        </Text>
      </View>
    );
  };

  const renderTodayArtworkUtilityOverlay = (card: TodayCard) => {
    if (card.id === "sleep") {
      return <View pointerEvents="none" style={styles.todaySleepTimeRemovalPatch} />;
    }
    if (card.id === "today") {
      return (
        <Animated.View
          pointerEvents="none"
          style={[
            styles.todayArtworkPulseDot,
            {
              opacity: energyFlowAnim.interpolate({ inputRange: [0, 1], outputRange: [0.56, 1] }),
              transform: [
                { translateY: energyFlowAnim.interpolate({ inputRange: [0, 1], outputRange: [3, -4] }) },
                { scale: energyFlowAnim.interpolate({ inputRange: [0, 1], outputRange: [0.92, 1.12] }) }
              ]
            }
          ]}
        />
      );
    }
    return null;
  };

  const renderDynamicTodayCard = (card: TodayCard) => {
    const tone = TODAY_TONE_THEMES[card.tone];
    return (
      <Animated.View
        style={[
          styles.todayMainCard,
          card.id === "sleep" && styles.todayMainCardSleep,
          todayCardToneStyle(card.tone),
          {
            backgroundColor: tone.base,
            opacity: cardIntroAnim,
            transform: [{ translateY: cardIntroAnim.interpolate({ inputRange: [0, 1], outputRange: [12, 0] }) }]
          }
        ]}
      >
        <View style={[styles.todayToneTopWash, { backgroundColor: tone.washTop }]} />
        <View style={[styles.todayToneBottomGlow, { backgroundColor: tone.bottomGlow }]} />
        <View style={[styles.todayToneBottomGlowStrong, { backgroundColor: tone.bottomGlowStrong }]} />
        <Pressable testID={`today-main-card-${card.id}`} style={styles.todayLayeredPressable} onPress={() => openTodayMore(card.id)}>
          {renderTodayCardHeader(card)}
          {renderTodayCardVisual(card)}
          <Pressable style={styles.todayCardAction} onPress={() => handleTodayAction(card)}>
            <Text style={styles.todayCardActionText}>{card.id === "focus" ? `开始 ${focusMinutes} 分钟专注` : card.action}</Text>
          </Pressable>
        </Pressable>
      </Animated.View>
    );
  };

  const renderStaticTodayArtworkCard = (card: TodayCard) => (
    <Animated.View
      style={[
        styles.todayArtworkCard,
        {
          opacity: cardIntroAnim,
          transform: [{ translateY: cardIntroAnim.interpolate({ inputRange: [0, 1], outputRange: [12, 0] }) }]
        }
      ]}
    >
      <Pressable testID={`today-main-card-${card.id}`} style={styles.todayArtworkPressable} onPress={() => openTodayMore(card.id)}>
        <ImageBackground
          source={TODAY_CARD_ART_IMAGES[card.id]}
          resizeMode="stretch"
          style={[styles.todayArtworkImage, { aspectRatio: TODAY_CARD_ART_RATIOS[card.id] }]}
          imageStyle={styles.todayArtworkImageRadius}
        >
          {renderTodayArtworkTextOverlay()}
          {renderTodayArtworkUtilityOverlay(card)}
        </ImageBackground>
        <Pressable
          testID={`today-card-more-${card.id}`}
          style={styles.todayArtworkMoreButton}
          onPress={(event) => {
            event.stopPropagation?.();
            openTodayMore(card.id);
          }}
        >
          <Text style={styles.todayArtworkMoreText}>•••</Text>
        </Pressable>
        {card.id === "focus" && (
          <>
            <Pressable
              testID="today-focus-plus"
              style={[styles.todayArtworkFocusAdjustHit, styles.todayArtworkFocusAdjustLeft]}
              onPress={(event) => {
                event.stopPropagation?.();
                adjustFocusMinutes(5);
              }}
            />
            <Pressable
              testID="today-focus-minus"
              style={[styles.todayArtworkFocusAdjustHit, styles.todayArtworkFocusAdjustRight]}
              onPress={(event) => {
                event.stopPropagation?.();
                adjustFocusMinutes(-5);
              }}
            />
          </>
        )}
      </Pressable>
      <Pressable
        accessibilityLabel={`${card.label}行动按钮`}
        testID={`today-card-action-hit-${card.id}`}
        style={styles.todayArtworkActionHit}
        onPress={() => handleTodayAction(card)}
      />
    </Animated.View>
  );

  const renderToday = () => (
    <LinearGradient colors={["#e7e7e5", "#f7f5f2", "#ffffff"]} locations={[0, 0.42, 1]} style={styles.nativeToday}>
      <ScrollView style={styles.nativeTodayScroll} contentContainerStyle={styles.nativeTodayContent} showsVerticalScrollIndicator={false}>
        {renderTodayReferenceOverlay()}
        {renderTodayNav()}
        {renderStaticTodayArtworkCard(activeToday)}
        {renderEnergyChatPreview()}
        {renderEnergyLiveCards()}
        {renderTodayInlineChat()}
        {renderTodayReferenceControls()}
      </ScrollView>
    </LinearGradient>
  );

  const renderBreathingPractice = () => {
    const theme = BREATHING_BACKGROUNDS.find((item) => item.id === breathingBackground) ?? BREATHING_BACKGROUNDS[0];
    return (
      <LinearGradient colors={theme.colors} style={[styles.breathPractice, breathingExpanded && styles.breathPracticeExpanded]}>
        <View style={styles.breathMistOrb} />
        <View style={styles.breathHeader}>
          <Pressable
            style={styles.breathBack}
            onPress={() => {
              breathingPlayerRef.current?.pause();
              setBreathingSoundOn(false);
              setTodayRoute("home");
            }}
          >
            <Text style={styles.breathBackText}>‹</Text>
          </Pressable>
          <View style={styles.breathEnergyPill}>
            <Text style={styles.breathEnergyPillText}>今日能量 {vitoraState.prediction.todayScore}%</Text>
          </View>
          <Pressable style={styles.breathBack} onPress={() => setBreathingExpanded((value) => !value)}>
            <Text style={styles.breathExpandText}>{breathingExpanded ? "−" : "＋"}</Text>
          </Pressable>
        </View>
        <View style={styles.breathOrb}>
          <View style={styles.breathOrbInner} />
        </View>
        <Text style={styles.breathPhase}>白噪音呼吸</Text>
        <DotMatrixText value={formatElapsed(activeSessionElapsed)} dot={6} gap={4} style={styles.sessionDotClock} color="#eef7ef" />
        <Text style={styles.breathCopy}>跟随声音和圆形节奏，把注意力从高刺激任务拉回身体。背景可切换，能量状态会保留在顶部。</Text>
        <View style={styles.breathBackgroundRail}>
          {BREATHING_BACKGROUNDS.map((item) => (
            <Pressable
              key={item.id}
              style={[styles.breathBackgroundChip, breathingBackground === item.id && styles.breathBackgroundChipActive]}
              onPress={() => setBreathingBackground(item.id)}
            >
              <Text style={styles.breathBackgroundChipText}>{item.label}</Text>
            </Pressable>
          ))}
        </View>
        <View style={styles.breathActionRow}>
          <Pressable style={styles.breathSoundButton} onPress={toggleBreathingSound}>
            <Text style={styles.breathSoundButtonText}>{breathingSoundOn ? "暂停声音" : "播放声音"}</Text>
          </Pressable>
          <Pressable style={styles.breathCompleteInline} onPress={completeBreathingPractice}>
            <Text style={styles.breathCompleteInlineText}>完成</Text>
          </Pressable>
        </View>
      </LinearGradient>
    );
  };

  const renderTimedSession = (kind: "focus" | "metabolism") => {
    const theme = kind === "focus" ? TODAY_TONE_THEMES.focus : TODAY_TONE_THEMES.metabolism;
    return (
      <View style={[styles.sessionPage, { backgroundColor: theme.base }]}>
        <View style={[styles.todayToneTopWash, { backgroundColor: theme.washTop }]} />
        <View style={[styles.todayToneBottomGlow, { backgroundColor: theme.bottomGlow }]} />
        <View style={styles.breathHeader}>
          <Pressable style={styles.breathBack} onPress={() => setTodayRoute("home")}>
            <Text style={styles.breathBackText}>‹</Text>
          </Pressable>
          <Text style={styles.breathTitle}>{kind === "focus" ? "专注计时" : "代谢计时"}</Text>
          <View style={styles.breathBack} />
        </View>
        <View style={styles.sessionCenter}>
          {kind === "metabolism" ? (
            <Animated.View style={[styles.sessionHeart, { transform: [{ scale: heartPulseAnim }] }]}>
              <Text style={styles.sessionHeartText}>{vitoraState.snapshot.recovery.restingHeartRate}</Text>
            </Animated.View>
          ) : (
            <View style={styles.sessionFocusOrb}>
              <Text style={styles.sessionFocusText}>{focusMinutes}</Text>
            </View>
          )}
          <DotMatrixText value={formatElapsed(activeSessionElapsed)} dot={8} gap={5} style={styles.sessionLargeClock} />
          <Text style={styles.sessionCopy}>
            {kind === "focus" ? `保持单任务 ${focusMinutes} 分钟，先降低切换成本。` : "让身体进入温和活动状态，完成后会生成一枚代谢油戳。"}
          </Text>
        </View>
        <Pressable style={styles.sessionCompleteButton} onPress={completeTimedSession}>
        <Text style={styles.sessionCompleteText}>完成并生成油戳</Text>
        </Pressable>
      </View>
    );
  };

  const renderMorningMapGuide = () => (
    <View style={[styles.sessionPage, styles.morningGuidePage]}>
      <View style={[styles.todayToneTopWash, { backgroundColor: TODAY_TONE_THEMES.morning.washTop }]} />
      <View style={[styles.todayToneBottomGlow, { backgroundColor: TODAY_TONE_THEMES.morning.bottomGlow }]} />
      <View style={styles.breathHeader}>
        <Pressable style={styles.breathBack} onPress={() => setTodayRoute("home")}>
          <Text style={styles.breathBackText}>‹</Text>
        </Pressable>
        <Text style={styles.breathTitle}>晨间找太阳</Text>
        <View style={styles.breathBack} />
      </View>
      <View style={styles.morningGuideMap}>
        <View style={styles.todayMorningMapShape} />
        <View style={styles.morningGuideBeam} />
        <Animated.View
          style={[
            styles.todayMorningGlow,
            {
              opacity: pinGlowAnim.interpolate({ inputRange: [0, 1], outputRange: [0.25, 0.82] }),
              transform: [{ scale: pinGlowAnim.interpolate({ inputRange: [0, 1], outputRange: [1, 1.3] }) }]
            }
          ]}
        />
        <View style={styles.todayMorningPin} />
        <Text style={styles.morningGuideLabel}>朝向阳光更强的位置走 8 分钟</Text>
      </View>
      <Text style={styles.sessionCopy}>当前为模拟地图。真机接定位后，会根据用户住址和太阳方向生成路线。</Text>
      <Pressable style={styles.sessionCompleteButton} onPress={() => {
        collectTodayStamp("morning-map", "晨间路线");
        setTodayRoute("home");
      }}>
        <Text style={styles.sessionCompleteText}>完成晨间路线</Text>
      </Pressable>
    </View>
  );

  const openProfilePanel = (panel: Exclude<ProfilePanel, null>) => {
    if (panel === "editName") setProfileNameDraft(vitoraState.profileSurface.displayName);
    setProfilePanel(panel);
  };

  const saveProfileName = () => {
    const displayName = profileNameDraft.trim() || vitoraState.profileSurface.displayName;
    applyVitoraRuntimeState({
      ...vitoraState,
      updatedAt: new Date().toISOString(),
      profileSurface: {
        ...vitoraState.profileSurface,
        displayName
      }
    });
    setProfilePanel(null);
    setToast("昵称已更新");
  };

  const renderProfilePanelRows = () => {
    if (profilePanel === "inbox") {
      return vitoraState.profileSurface.inboxEvents.map((event) => (
        <View key={event.id} style={styles.profilePanelRow}>
          <View style={[styles.profilePanelDot, event.unread && styles.profilePanelDotUnread]} />
          <View style={styles.profilePanelCopy}>
            <Text style={styles.profilePanelRowTitle}>{event.time} · {event.title}</Text>
            <Text style={styles.profilePanelRowBody}>{event.body}</Text>
          </View>
        </View>
      ));
    }
    if (profilePanel === "stamps") {
      return (
        <View style={styles.profileStampGrid}>
          {vitoraState.achievementStamps.map((stamp) => (
            <Pressable
              key={stamp.stampId}
              style={[styles.profileStampItem, stamp.lockedReason && styles.profileStampItemLocked]}
              onPress={() => openStampSheet(stamp, "detail")}
            >
              <Text style={styles.profileStampCode}>{stampCodeFor(stamp)}</Text>
              <Text style={styles.profileStampMonth}>{monthLabelForStamp(stamp.month)}</Text>
              <Image source={stampAssetFor(stamp)} style={styles.profileStampImage} resizeMode="contain" />
              <Text style={styles.profileStampTitle}>{stamp.title}</Text>
              <Text style={styles.profileStampRule} numberOfLines={2}>{stamp.lockedReason ?? displayReasonForStamp(stamp)}</Text>
            </Pressable>
          ))}
        </View>
      );
    }
    const rows =
      profilePanel === "archive"
        ? [
          ["身体人格", `${vitoraState.profile.personaName} · ${vitoraState.profile.personaType}`],
          ["人格码", vitoraState.profile.rawCode],
          ["建档时间", vitoraState.profile.createdAt.slice(0, 10)],
          ["预测模型", "规则预测模型 v1"]
        ]
        : profilePanel === "watch"
          ? [
            ["连接状态", vitoraState.profileSurface.watchStatus.title],
            ["同步说明", vitoraState.profileSurface.watchStatus.body],
            ["最近同步", vitoraState.profileSurface.watchStatus.lastSync],
            ["读取字段", "睡眠、步数、HRV、静息心率、体温变化、周期"]
          ]
          : profilePanel === "vip"
            ? [
              ["TIDE Plus", `新用户 ${vitoraState.profileSurface.membershipStatus.trialDays} 天免费试用`],
              ["权益", vitoraState.profileSurface.membershipStatus.benefits.join(" / ")],
              ["状态", vitoraState.profileSurface.membershipStatus.tier === "plus" ? "已开通" : "未开通"],
              ["说明", "当前为模拟会员页，不接真实支付。"]
            ]
            : [
              ["数据源", vitoraState.profileSurface.watchStatus.title],
              ["非医疗建议", "AI 翻译基于历史数据与实时状态生成，仅供参考。"],
              ["运行 ID", `${vitoraState.prediction.predictionId}`],
              ["主动关心", activeCareEvent.careEventId]
            ];
    return rows.map(([label, value]) => (
      <View key={label} style={styles.profilePanelRow}>
        <Text style={styles.profilePanelRowTitle}>{label}</Text>
        <Text style={styles.profilePanelRowBody}>{value}</Text>
      </View>
    ));
  };

  const renderProfilePanel = () => {
    if (!profilePanel) return null;
    const titleMap: Record<Exclude<ProfilePanel, null>, string> = {
      inbox: "消息中心",
      info: "数据说明",
      editName: "编辑昵称",
      stamps: "油戳收集",
      archive: "个人档案",
      watch: "WATCH 应用",
      vip: "TIDE Plus"
    };
    return (
      <View style={styles.profilePanelLayer}>
        <Pressable style={styles.profilePanelBackdrop} onPress={() => setProfilePanel(null)} />
        <View style={styles.profilePanel}>
          <View style={styles.profilePanelHeader}>
            <Text style={styles.profilePanelTitle}>{titleMap[profilePanel]}</Text>
            <Pressable onPress={() => setProfilePanel(null)}>
              <Text style={styles.profilePanelClose}>×</Text>
            </Pressable>
          </View>
          {profilePanel === "editName" ? (
            <>
              <TextInput
                value={profileNameDraft}
                onChangeText={setProfileNameDraft}
                style={styles.profileNameInput}
                placeholder="输入昵称"
                placeholderTextColor="#9aa0aa"
              />
              <Text style={styles.profilePanelHint}>昵称只用于展示，不会覆盖你的身体人格类型。</Text>
              <Pressable style={styles.profilePanelPrimary} onPress={saveProfileName}>
                <Text style={styles.profilePanelPrimaryText}>保存</Text>
              </Pressable>
            </>
          ) : (
            <ScrollView style={styles.profilePanelScroll} contentContainerStyle={styles.profilePanelScrollContent}>
              {renderProfilePanelRows()}
            </ScrollView>
          )}
        </View>
      </View>
    );
  };

  const renderProfile = () => (
    <View style={styles.nativeProfileLayer}>
      <View style={styles.nativeProfileStatus}>
        <Text style={styles.nativeTime}>20:27</Text>
        <Text style={styles.nativeSignal}>III 4G</Text>
      </View>
      <View style={styles.nativeProfileSheet}>
        <Pressable style={styles.nativeProfileClose} onPress={() => setProfileOpen(false)}>
          <Text style={styles.nativeProfileCloseText}>×</Text>
        </Pressable>
        <View style={styles.nativeProfileMini}>
          <Pressable style={styles.nativeProfileIconButton} onPress={() => openProfilePanel("inbox")}>
            <Text style={styles.nativeProfileMiniText}>✉</Text>
          </Pressable>
          <Pressable style={styles.nativeProfileIconButton} onPress={() => openProfilePanel("info")}>
            <Text style={styles.nativeProfileMiniText}>◎</Text>
          </Pressable>
        </View>
        <View style={styles.nativeProfileHero}>
          <Pressable onPress={() => openProfilePanel("editName")}>
            <Text style={styles.nativeProfileName}>{vitoraState.profileSurface.displayName}</Text>
            <Text style={styles.nativeProfileSub}>与你相遇第 {vitoraState.profileSurface.encounterDays} 天</Text>
            <Text style={styles.nativeProfilePersona}>{vitoraState.profile.personaName} · {vitoraState.profile.personaType}</Text>
          </Pressable>
          <View style={styles.nativeAvatar}>
            <Text style={styles.nativeAvatarText}>♟</Text>
          </View>
        </View>
        <Pressable style={styles.nativePlus} onPress={() => openProfilePanel("stamps")}>
          <View>
            <Text style={styles.nativePlusTitle}>{vitoraState.profile.mythicReference} 邮票册</Text>
            <Text style={styles.nativePlusSub}>{vitoraState.profile.oneLine}</Text>
          </View>
          <Pressable style={styles.nativeMemberPill} onPress={() => openProfilePanel("vip")}>
            <Text style={styles.nativeMemberText}>开通会员</Text>
          </Pressable>
        </Pressable>
        <View style={styles.nativeProfileTiles}>
          <Pressable style={styles.nativeProfileTile} onPress={() => openProfilePanel("stamps")}><Text style={styles.nativeProfileTileText}>♡{`\n`}油戳收集</Text></Pressable>
          <Pressable style={styles.nativeProfileTile} onPress={() => openProfilePanel("archive")}><Text style={styles.nativeProfileTileText}>个人档案</Text></Pressable>
        </View>
        <Pressable style={styles.nativeWatch} onPress={() => openProfilePanel("watch")}>
          <Text style={styles.nativeWatchBox}>□</Text>
          <View>
            <Text style={styles.nativeWatchTitle}>WATCH 应用 ·</Text>
            <Text style={styles.nativeWatchSub}>{vitoraState.profileSurface.watchStatus.body}</Text>
          </View>
          <Text style={styles.nativeWatchArrow}>›</Text>
        </Pressable>
      </View>
      {renderProfilePanel()}
    </View>
  );

  const renderNativeBody = () => {
    if (nativeTab === "health") return healthRoute === "detail" ? renderHealthDetail() : renderHealth();
    if (nativeTab === "today") {
      if (todayRoute === "breathing") return renderBreathingPractice();
      if (todayRoute === "focusTimer") return renderTimedSession("focus");
      if (todayRoute === "metabolismTimer") return renderTimedSession("metabolism");
      if (todayRoute === "morningMap") return renderMorningMapGuide();
      return renderToday();
    }
    if (exploreRoute === "chat") return renderNativeChat();
    if (exploreRoute === "feedback") return renderExploreHome();
    return renderExploreHome();
  };

  const showBottomNav = !(
    (nativeTab === "today" && todayRoute !== "home") ||
    (nativeTab === "explore" && exploreRoute === "chat") ||
    (nativeTab === "health" && healthRoute === "detail")
  );

  return (
    <View style={styles.root}>
      <StatusBar hidden />
      {webSourceUri ? (
        <WebView
          ref={webViewRef}
          source={{ uri: webSourceUri }}
          style={styles.webview}
          containerStyle={styles.webview}
          originWhitelist={["*"]}
          cacheEnabled={false}
          allowFileAccess
          allowFileAccessFromFileURLs
          allowUniversalAccessFromFileURLs
          allowsInlineMediaPlayback
          javaScriptEnabled
          domStorageEnabled
          injectedJavaScriptBeforeContentLoaded={SIMULATOR_WEB_PATCH_WITH_PROBE}
          injectedJavaScript={SIMULATOR_WEB_PATCH_WITH_PROBE}
          mediaPlaybackRequiresUserAction={false}
          bounces={false}
          overScrollMode="never"
          showsHorizontalScrollIndicator={false}
          showsVerticalScrollIndicator={false}
          onLoadEnd={injectSimulatorPatch}
          onMessage={handleWebViewMessage}
          onError={handleWebViewError}
        />
      ) : (
        <View style={styles.loading}>
          {error ? <Text style={styles.error}>{error}</Text> : <ActivityIndicator color="#f4f2ed" />}
        </View>
      )}
      {nativeLayerReady && !onboardingOpen && (
        <View style={styles.nativeLayer}>
          {renderNativeBody()}
          {showBottomNav && (
            <LinearGradient
              pointerEvents="none"
              colors={["rgba(255,255,255,0)", "rgba(82,84,82,0.30)", "rgba(48,49,49,0.50)"]}
              locations={[0, 0.55, 1]}
              style={styles.nativeBottomBackdrop}
            />
          )}
          {showBottomNav && (
            <View style={styles.nativeBottom}>
              <Pressable
                testID="bottom-tab-today"
                style={[styles.nativeTabButton, nativeTab === "today" && styles.nativeTabActive]}
                onPress={() => {
                  setNativeTab("today");
                  setTodayRoute("home");
                  setTodayActiveId("today");
                }}
              >
                <Text style={styles.nativeTabIcon}>☼</Text>
                <Text style={styles.nativeTabText}>今日</Text>
              </Pressable>
              <Pressable
                testID="bottom-tab-explore"
                style={[styles.nativeTabButton, nativeTab === "explore" && styles.nativeTabActive]}
                onPress={() => {
                  setNativeTab("explore");
                  setExploreRoute("home");
                }}
              >
                <Text style={styles.nativeTabIcon}>ϒ</Text>
                <Text style={styles.nativeTabText}>探索</Text>
              </Pressable>
              <Pressable
                testID="bottom-tab-health"
                style={[styles.nativeTabButton, nativeTab === "health" && styles.nativeTabActive]}
                onPress={() => {
                  setNativeTab("health");
                  setHealthRoute("home");
                }}
              >
                <Text style={styles.nativeTabIcon}>⌾</Text>
                <Text style={styles.nativeTabText}>健康</Text>
              </Pressable>
            </View>
          )}
          {showBottomNav && nativeTab === "today" && todayRoute === "home" ? renderTodayComposer() : null}
          {profileOpen && renderProfile()}
          {renderReminderSheet()}
          {renderStampRevealSheet()}
          {toast ? (
            <View style={styles.nativeToast}>
              <Text style={styles.nativeToastText}>{toast}</Text>
            </View>
          ) : null}
        </View>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
    backgroundColor: "#05090b"
  },
  webview: {
    flex: 1,
    backgroundColor: "#05090b"
  },
  loading: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
    paddingHorizontal: 28,
    backgroundColor: "#05090b"
  },
  error: {
    color: "#f4f2ed",
    fontSize: 14,
    lineHeight: 20,
    textAlign: "center"
  },
  nativeLayer: {
    position: "absolute",
    top: 0,
    right: 0,
    bottom: 0,
    left: 0,
    zIndex: 30,
    backgroundColor: "#6f7974"
  },
  nativePageDark: {
    flex: 1,
    backgroundColor: "#68736e"
  },
  softGradientBase: {
    flex: 1,
    overflow: "hidden",
    backgroundColor: "#f4f5f3"
  },
  softGradientTop: {
    position: "absolute",
    top: 0,
    right: 0,
    left: 0,
    height: 280,
    backgroundColor: "#d7ddd8",
    opacity: 0.92
  },
  softGradientGlow: {
    position: "absolute",
    top: 260,
    right: 0,
    left: 0,
    height: 360,
    backgroundColor: "rgba(255,255,255,0.38)"
  },
  softGradientBottom: {
    position: "absolute",
    right: 0,
    bottom: 0,
    left: 0,
    height: 420,
    backgroundColor: "#ffffff",
    opacity: 0.68
  },
  softGradientContent: {
    flex: 1
  },
  glassFill: {
    ...StyleSheet.absoluteFill
  },
  nativeExploreTop: {
    paddingTop: 92,
    paddingRight: 28,
    alignItems: "flex-end"
  },
  nativeDots: {
    flexDirection: "row",
    gap: 10,
    alignItems: "center"
  },
  nativeDot: {
    width: 10,
    height: 10,
    borderRadius: 5,
    backgroundColor: "rgba(115,124,120,0.34)"
  },
  nativeDotActive: {
    backgroundColor: "#dfff68"
  },
  nativeCardScroller: {
    flex: 1
  },
  nativeCardScrollerContent: {
    paddingHorizontal: 24,
    paddingTop: 24,
    paddingBottom: 138
  },
  nativeExploreCard: {
    height: 548,
    marginBottom: 24,
    borderRadius: 28,
    overflow: "hidden",
    backgroundColor: "rgba(124,135,129,0.46)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.24)",
    shadowColor: "#36403c",
    shadowOpacity: 0.18,
    shadowRadius: 28,
    shadowOffset: { width: 0, height: 18 }
  },
  nativeCardImage: {
    flex: 1,
    backgroundColor: "rgba(126,137,131,0.58)"
  },
  nativeCardImageRadius: {
    borderRadius: 28
  },
  nativeCardShade: {
    position: "absolute",
    top: 0,
    right: 0,
    bottom: 0,
    left: 0,
    backgroundColor: "rgba(20,28,28,0.32)"
  },
  nativeFogLayer: {
    position: "absolute",
    top: 0,
    right: 0,
    bottom: 0,
    left: 0,
    opacity: 0.86
  },
  nativeFogReveal: {
    position: "absolute",
    left: 34,
    right: 34,
    bottom: 138,
    height: 148,
    borderRadius: 74,
    backgroundColor: "rgba(255,255,255,0.08)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.18)"
  },
  nativePill: {
    position: "absolute",
    left: 18,
    top: 20,
    zIndex: 2,
    overflow: "hidden",
    borderRadius: 999,
    paddingHorizontal: 20,
    paddingVertical: 8,
    backgroundColor: "rgba(255,255,255,0.24)",
    color: "#fff",
    fontSize: 17,
    fontWeight: "900"
  },
  nativePillInline: {
    alignSelf: "flex-start",
    overflow: "hidden",
    borderRadius: 999,
    paddingHorizontal: 20,
    paddingVertical: 8,
    backgroundColor: "rgba(255,255,255,0.20)",
    color: "#fff",
    fontSize: 17,
    fontWeight: "900"
  },
  nativeCardCopy: {
    position: "absolute",
    left: 24,
    right: 24,
    bottom: 104,
    zIndex: 2
  },
  nativeCardLead: {
    color: "rgba(255,255,255,0.86)",
    fontSize: 18,
    fontWeight: "800",
    marginBottom: 8
  },
  nativeCardTitle: {
    color: "#fff",
    fontSize: 38,
    lineHeight: 43,
    fontWeight: "900"
  },
  nativeCardPrompt: {
    color: "rgba(255,255,255,0.74)",
    fontSize: 16,
    lineHeight: 23,
    fontWeight: "800",
    marginTop: 10
  },
  nativeCardInput: {
    position: "absolute",
    left: 20,
    right: 20,
    bottom: 20,
    zIndex: 3,
    height: 56,
    justifyContent: "center",
    borderRadius: 28,
    paddingHorizontal: 22,
    backgroundColor: "rgba(255,255,255,0.20)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.26)"
  },
  nativeCardInputText: {
    color: "rgba(255,255,255,0.88)",
    fontSize: 18,
    fontWeight: "900"
  },
  nativeDetailContent: {
    paddingHorizontal: 24,
    paddingBottom: 150
  },
  nativeDetailCard: {
    minHeight: 608,
    marginTop: 22,
    borderRadius: 28,
    backgroundColor: "rgba(255,255,255,0.12)",
    overflow: "hidden"
  },
  nativeDetailCopy: {
    position: "absolute",
    left: 28,
    right: 28,
    bottom: 114
  },
  nativeDetailLead: {
    color: "#fff",
    fontSize: 23,
    lineHeight: 31,
    fontWeight: "600",
    marginBottom: 12
  },
  nativeDetailTitle: {
    color: "#fff",
    fontSize: 41,
    lineHeight: 46,
    fontWeight: "900"
  },
  nativeDetailPrompt: {
    color: "rgba(255,255,255,0.78)",
    fontSize: 19,
    lineHeight: 27,
    marginTop: 14
  },
  nativeDetailInput: {
    position: "absolute",
    left: 24,
    right: 24,
    bottom: 26,
    height: 56,
    justifyContent: "center",
    borderRadius: 28,
    paddingHorizontal: 22,
    backgroundColor: "rgba(255,255,255,0.20)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.26)"
  },
  nativeRecentCard: {
    height: 290,
    borderRadius: 28,
    padding: 24,
    marginTop: 24,
    backgroundColor: "rgba(255,255,255,0.10)"
  },
  nativeRecentTitle: {
    marginTop: 70,
    color: "#fff",
    fontSize: 27,
    fontWeight: "900"
  },
  nativeRecentCopy: {
    marginTop: 18,
    color: "rgba(255,255,255,0.76)",
    fontSize: 16,
    lineHeight: 25,
    fontWeight: "700"
  },
  nativeChat: {
    flex: 1,
    backgroundColor: "transparent",
    paddingTop: 58,
    paddingHorizontal: 18
  },
  nativeChatTop: {
    height: 64,
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center"
  },
  nativeRoundButton: {
    width: 54,
    height: 54,
    borderRadius: 27,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(255,255,255,0.55)"
  },
  nativeBackText: {
    fontSize: 42,
    color: "#303838",
    marginTop: -4
  },
  nativeAnalyze: {
    minWidth: 148,
    height: 46,
    overflow: "hidden",
    borderRadius: 23,
    textAlign: "center",
    paddingHorizontal: 18,
    paddingTop: 11,
    backgroundColor: "rgba(255,255,255,0.78)",
    color: UI.colors.textPrimary,
    ...UI.type.bodyStrong
  },
  nativeMessages: {
    flex: 1
  },
  nativeMessagesContent: {
    paddingTop: 54,
    paddingBottom: 132,
    gap: 18
  },
  nativeBubble: {
    maxWidth: 320,
    alignSelf: "flex-start",
    minHeight: 44,
    borderRadius: 22,
    paddingHorizontal: 18,
    paddingVertical: 10,
    backgroundColor: "rgba(244,244,244,0.92)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.78)",
    shadowColor: "#9ca3af",
    shadowOpacity: 0.12,
    shadowRadius: 10,
    shadowOffset: { width: 0, height: 5 }
  },
  nativeBubbleUser: {
    alignSelf: "flex-end",
    minWidth: 96,
    minHeight: 46,
    backgroundColor: "rgba(255,255,255,0.74)"
  },
  nativeBubbleText: {
    color: UI.colors.textPrimary,
    ...UI.type.body
  },
  voiceMessageRow: {
    maxWidth: 342,
    alignSelf: "flex-start",
    flexDirection: "row",
    alignItems: "flex-end"
  },
  voiceMessageRowUser: {
    alignSelf: "flex-end"
  },
  voiceMessageTail: {
    width: 13,
    height: 15,
    marginRight: -2,
    marginBottom: 6,
    borderTopLeftRadius: 12,
    backgroundColor: "rgba(231,232,232,0.94)",
    transform: [{ skewX: "-18deg" }]
  },
  voiceMessageTailUser: {
    marginRight: 0,
    marginLeft: -2,
    borderTopLeftRadius: 0,
    borderTopRightRadius: 12,
    backgroundColor: "rgba(247,248,248,0.94)",
    transform: [{ skewX: "18deg" }]
  },
  voiceMessageBar: {
    minHeight: 44,
    maxWidth: 318,
    borderRadius: 22,
    paddingHorizontal: 18,
    paddingVertical: 10,
    justifyContent: "center",
    backgroundColor: "rgba(231,232,232,0.94)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.82)",
    shadowColor: "#8f9496",
    shadowOpacity: 0.12,
    shadowRadius: 10,
    shadowOffset: { width: 0, height: 5 }
  },
  voiceMessageBarUser: {
    backgroundColor: "rgba(247,248,248,0.94)"
  },
  voiceMessageText: {
    color: "#111827",
    fontSize: 19,
    lineHeight: 26,
    fontWeight: "600"
  },
  audioMessageContent: {
    minWidth: 232,
    gap: 8
  },
  audioMessageTopline: {
    minHeight: 38,
    flexDirection: "row",
    alignItems: "center",
    gap: 10
  },
  audioPlayButton: {
    width: 34,
    height: 34,
    borderRadius: 17,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(17,24,39,0.12)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.76)"
  },
  audioPlayButtonActive: {
    backgroundColor: "rgba(143,123,255,0.26)"
  },
  audioPlayButtonText: {
    color: "#111827",
    fontSize: 13,
    lineHeight: 16,
    fontWeight: "900"
  },
  audioWaveform: {
    flex: 1,
    height: 32,
    flexDirection: "row",
    alignItems: "center",
    gap: 4
  },
  audioWaveBar: {
    width: 3,
    borderRadius: 999,
    backgroundColor: "rgba(17,24,39,0.58)"
  },
  audioVoiceLabel: {
    color: "rgba(17,24,39,0.56)",
    fontSize: 11,
    lineHeight: 14,
    fontWeight: "900"
  },
  audioTranscriptToggle: {
    color: "#8f7bff",
    fontSize: 12,
    lineHeight: 16,
    fontWeight: "900"
  },
  audioTranscriptText: {
    color: "rgba(17,24,39,0.72)",
    fontSize: 14,
    lineHeight: 20,
    fontWeight: "700"
  },
  nativeInputMenu: {
    position: "absolute",
    left: 18,
    right: 18,
    bottom: 98,
    borderRadius: UI.radius.panel,
    padding: 10,
    gap: 8,
    backgroundColor: "rgba(255,255,255,0.94)",
    shadowColor: "#8fa7a1",
    shadowOpacity: 0.18,
    shadowRadius: 18,
    shadowOffset: { width: 0, height: 8 }
  },
  nativeInputMenuItem: {
    minHeight: 44,
    borderRadius: 18,
    paddingHorizontal: 12,
    flexDirection: "row",
    alignItems: "center",
    gap: 10,
    backgroundColor: "rgba(238,244,242,0.72)"
  },
  nativeInputMenuItemActive: {
    backgroundColor: UI.colors.accentSoft
  },
  nativeInputMenuMark: {
    width: 28,
    color: UI.colors.accent,
    fontSize: 18,
    textAlign: "center",
    fontWeight: "900"
  },
  nativeInputMenuText: {
    color: UI.colors.textPrimary,
    ...UI.type.bodyStrong
  },
  nativeQuickRail: {
    position: "absolute",
    left: 18,
    right: 18,
    bottom: 98,
    borderRadius: UI.radius.panel,
    padding: 10,
    gap: 8,
    backgroundColor: "rgba(255,255,255,0.94)",
    shadowColor: "#8fa7a1",
    shadowOpacity: 0.16,
    shadowRadius: 16,
    shadowOffset: { width: 0, height: 8 }
  },
  nativeQuickChip: {
    minHeight: 42,
    borderRadius: 17,
    paddingHorizontal: 14,
    justifyContent: "center",
    backgroundColor: "rgba(143,123,255,0.12)",
    borderWidth: 1,
    borderColor: "rgba(143,123,255,0.24)"
  },
  nativeQuickChipText: {
    color: UI.colors.textPrimary,
    ...UI.type.bodyStrong
  },
  nativeVoicePanel: {
    position: "absolute",
    left: 18,
    right: 18,
    bottom: 98,
    borderRadius: 24,
    padding: 16,
    backgroundColor: "rgba(255,255,255,0.95)",
    shadowColor: "#8fa7a1",
    shadowOpacity: 0.17,
    shadowRadius: 18,
    shadowOffset: { width: 0, height: 8 }
  },
  nativeVoiceTitle: {
    color: UI.colors.textPrimary,
    ...UI.type.sectionTitle
  },
  nativeVoiceCopy: {
    marginTop: 6,
    color: UI.colors.textSecondary,
    ...UI.type.caption
  },
  nativeVoiceButton: {
    marginTop: 12,
    height: 46,
    borderRadius: 23,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: UI.colors.textPrimary
  },
  nativeVoiceButtonActive: {
    backgroundColor: UI.colors.accent
  },
  nativeVoiceButtonText: {
    color: "#fff",
    ...UI.type.bodyStrong
  },
  nativeComposer: {
    position: "absolute",
    left: 18,
    right: 18,
    bottom: 24,
    height: 58
  },
  nativeInputModeButton: {
    width: 58,
    height: 58,
    borderRadius: 29,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(17,20,26,0.72)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.24)"
  },
  nativeInputModeButtonActive: {
    backgroundColor: UI.colors.accentSoft,
    borderColor: "rgba(143,123,255,0.30)"
  },
  nativeInputModeButtonText: {
    color: "#fff",
    fontSize: 30,
    lineHeight: 33,
    fontWeight: "800"
  },
  nativeInputWrap: {
    flex: 1,
    height: 58,
    borderRadius: 29,
    paddingLeft: 20,
    paddingRight: 8,
    flexDirection: "row",
    alignItems: "center",
    gap: 8,
    overflow: "hidden",
    backgroundColor: "rgba(16,19,24,0.58)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.20)",
    shadowColor: "#000",
    shadowOpacity: 0.18,
    shadowRadius: 18,
    shadowOffset: { width: 0, height: 8 }
  },
  nativeInput: {
    flex: 1,
    minWidth: 0,
    height: "100%",
    paddingVertical: 0,
    zIndex: 2,
    color: "#fff",
    ...UI.type.bodyStrong
  },
  nativeSend: {
    color: "#303838",
    fontSize: 24
  },
  nativeSendDisabled: {
    opacity: 0.34
  },
  nativeComposerInlineButton: {
    zIndex: 3,
    width: 42,
    height: 42,
    borderRadius: 21,
    alignItems: "center",
    justifyContent: "center",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.22)",
    backgroundColor: "rgba(255,255,255,0.10)"
  },
  nativeComposerInlinePlus: {
    color: "#fff",
    fontSize: 24,
    lineHeight: 26,
    fontWeight: "900"
  },
  nativeComposerInlineSend: {
    zIndex: 3,
    width: 42,
    height: 42,
    borderRadius: 21,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(255,255,255,0.90)"
  },
  nativeComposerInlineSendIdle: {
    backgroundColor: "rgba(255,255,255,0.18)"
  },
  nativeComposerInlineSendText: {
    color: "#111827",
    fontSize: 22,
    lineHeight: 24,
    fontWeight: "900"
  },
  nativeDoneButton: {
    width: 58,
    height: 58,
    borderRadius: 29,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(17,20,26,0.72)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.24)"
  },
  nativeDoneButtonIdle: {
    backgroundColor: "rgba(255,255,255,0.24)"
  },
  nativeDoneText: {
    color: "#fff",
    fontSize: 32,
    lineHeight: 35,
    fontWeight: "900"
  },
  energyDrawerLayer: {
    position: "absolute",
    top: 0,
    right: 0,
    bottom: 0,
    left: 0,
    zIndex: 320,
    justifyContent: "flex-end"
  },
  energyDrawerScrim: {
    position: "absolute",
    top: 0,
    right: 0,
    bottom: 0,
    left: 0,
    backgroundColor: "rgba(16,20,22,0.26)"
  },
  energyDrawer: {
    height: "42%",
    borderTopLeftRadius: 30,
    borderTopRightRadius: 30,
    paddingHorizontal: 16,
    paddingBottom: 18,
    overflow: "hidden",
    backgroundColor: "rgba(18,21,24,0.72)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.22)",
    shadowColor: "#26312e",
    shadowOpacity: 0.22,
    shadowRadius: 26,
    shadowOffset: { width: 0, height: -10 }
  },
  energyDrawerExpanded: {
    height: "72%"
  },
  energyDrawerHandleHit: {
    height: 22,
    alignItems: "center",
    justifyContent: "center"
  },
  energyDrawerHandle: {
    width: 48,
    height: 5,
    borderRadius: 3,
    backgroundColor: "rgba(255,255,255,0.30)"
  },
  energyDrawerHeader: {
    height: 52,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between"
  },
  energyDrawerKicker: {
    color: "rgba(255,255,255,0.62)",
    ...UI.type.caption
  },
  energyDrawerTitle: {
    marginTop: 2,
    color: "#fff",
    ...UI.type.sectionTitle
  },
  energyDrawerClose: {
    width: 38,
    height: 38,
    borderRadius: 19,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(255,255,255,0.14)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.18)"
  },
  energyDrawerCloseText: {
    color: "#fff",
    fontSize: 25,
    lineHeight: 28,
    fontWeight: "800"
  },
  energyDrawerMessages: {
    flex: 1
  },
  energyDrawerMessagesContent: {
    paddingTop: 6,
    paddingBottom: 92,
    gap: 10
  },
  energyDrawerBubble: {
    maxWidth: "82%",
    alignSelf: "flex-start",
    minHeight: 42,
    borderRadius: 21,
    paddingHorizontal: 14,
    paddingVertical: 10,
    backgroundColor: "rgba(244,244,244,0.92)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.72)"
  },
  energyDrawerBubbleUser: {
    alignSelf: "flex-end",
    backgroundColor: "rgba(255,255,255,0.74)"
  },
  energyDrawerBubbleText: {
    color: UI.colors.textPrimary,
    fontSize: 14,
    lineHeight: 21,
    fontWeight: "800"
  },
  energyDrawerMenu: {
    position: "absolute",
    left: 16,
    right: 16,
    bottom: 84,
    borderRadius: 22,
    padding: 10,
    gap: 8,
    backgroundColor: "rgba(255,255,255,0.96)",
    shadowColor: "#8fa7a1",
    shadowOpacity: 0.18,
    shadowRadius: 18,
    shadowOffset: { width: 0, height: 8 }
  },
  energyDrawerMenuItem: {
    minHeight: 42,
    borderRadius: 17,
    paddingHorizontal: 12,
    flexDirection: "row",
    alignItems: "center",
    gap: 10,
    backgroundColor: "rgba(238,244,242,0.72)"
  },
  energyDrawerMenuItemActive: {
    backgroundColor: UI.colors.accentSoft
  },
  energyDrawerMenuMark: {
    width: 26,
    color: UI.colors.accent,
    fontSize: 17,
    textAlign: "center",
    fontWeight: "900"
  },
  energyDrawerMenuText: {
    color: UI.colors.textPrimary,
    ...UI.type.bodyStrong
  },
  energyDrawerQuickRail: {
    position: "absolute",
    left: 16,
    right: 16,
    bottom: 84,
    borderRadius: 22,
    padding: 10,
    gap: 8,
    backgroundColor: "rgba(255,255,255,0.96)"
  },
  energyDrawerQuickChip: {
    minHeight: 40,
    borderRadius: 17,
    paddingHorizontal: 12,
    justifyContent: "center",
    backgroundColor: "rgba(143,123,255,0.12)"
  },
  energyDrawerQuickText: {
    color: UI.colors.textPrimary,
    ...UI.type.bodyStrong
  },
  energyDrawerVoice: {
    position: "absolute",
    left: 16,
    right: 16,
    bottom: 84,
    borderRadius: 22,
    padding: 14,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    backgroundColor: "rgba(255,255,255,0.96)"
  },
  energyDrawerVoiceText: {
    color: UI.colors.textPrimary,
    ...UI.type.bodyStrong
  },
  energyDrawerVoiceButton: {
    height: 38,
    borderRadius: 19,
    paddingHorizontal: 16,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: UI.colors.textPrimary
  },
  energyDrawerVoiceButtonText: {
    color: "#fff",
    ...UI.type.chip
  },
  energyDrawerComposer: {
    position: "absolute",
    left: 16,
    right: 16,
    bottom: 18,
    height: 54,
    flexDirection: "row",
    gap: 8
  },
  energyDrawerPlus: {
    width: 54,
    height: 54,
    borderRadius: 27,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(16,19,24,0.58)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.20)"
  },
  energyDrawerPlusActive: {
    backgroundColor: UI.colors.accentSoft
  },
  energyDrawerPlusText: {
    color: "#fff",
    fontSize: 28,
    lineHeight: 31,
    fontWeight: "900"
  },
  energyDrawerInputWrap: {
    flex: 1,
    height: 54,
    borderRadius: 27,
    paddingLeft: 16,
    paddingRight: 8,
    flexDirection: "row",
    alignItems: "center",
    overflow: "hidden",
    backgroundColor: "rgba(16,19,24,0.58)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.20)"
  },
  energyDrawerInput: {
    flex: 1,
    minWidth: 0,
    height: "100%",
    paddingVertical: 0,
    zIndex: 2,
    color: "#fff",
    fontSize: 15,
    fontWeight: "800"
  },
  energyDrawerSendButton: {
    width: 54,
    height: 54,
    borderRadius: 27,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(255,255,255,0.88)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.26)"
  },
  energyDrawerSend: {
    color: "#111827",
    fontSize: 24,
    lineHeight: 28,
    fontWeight: "900"
  },
  nativeFeedback: {
    flex: 1,
    paddingTop: 72,
    paddingHorizontal: 28,
    backgroundColor: "transparent"
  },
  nativeFeedbackDark: {
    flex: 1,
    paddingTop: 72,
    paddingHorizontal: 28,
    backgroundColor: "#5d6862"
  },
  nativeFeedbackMist: {
    position: "absolute",
    top: 0,
    right: 0,
    left: 0,
    bottom: 0,
    backgroundColor: "rgba(255,255,255,0.05)"
  },
  nativeFeedbackTop: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 38
  },
  nativeCloseCircle: {
    width: 50,
    height: 50,
    borderRadius: 25,
    alignItems: "center",
    justifyContent: "center",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.34)"
  },
  nativeCloseText: {
    color: "#ffffff",
    fontSize: 30
  },
  nativeStampLarge: {
    width: 244,
    height: 350,
    alignSelf: "center",
    alignItems: "center",
    paddingTop: 38,
    borderWidth: 2,
    borderColor: "rgba(255,255,255,0.78)",
    backgroundColor: "rgba(132,143,137,0.18)"
  },
  nativeFeedbackPerfRow: {
    position: "absolute",
    left: 16,
    right: 16,
    flexDirection: "row",
    justifyContent: "space-between"
  },
  nativeFeedbackPerfTop: {
    top: -6
  },
  nativeFeedbackPerfBottom: {
    bottom: -6
  },
  nativeFeedbackPerfCol: {
    position: "absolute",
    top: 16,
    bottom: 16,
    justifyContent: "space-between"
  },
  nativeFeedbackPerfLeft: {
    left: -6
  },
  nativeFeedbackPerfRight: {
    right: -6
  },
  nativeFeedbackPerfDot: {
    width: 12,
    height: 12,
    borderRadius: 6,
    backgroundColor: "#5d6862",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.70)"
  },
  nativeStampSmall: {
    color: "#fff",
    fontSize: 11,
    letterSpacing: 1,
    opacity: 0.82
  },
  nativeFeedbackStampArt: {
    width: 150,
    height: 150,
    alignItems: "center",
    justifyContent: "center",
    marginTop: 22,
    overflow: "visible"
  },
  nativeDreamPlate: {
    width: 128,
    height: 128,
    borderRadius: 64,
    backgroundColor: "rgba(255,255,255,0.92)",
    borderWidth: 12,
    borderColor: "rgba(255,255,255,0.26)",
    shadowColor: "#ffffff",
    shadowOpacity: 0.18,
    shadowRadius: 24,
    shadowOffset: { width: 0, height: 0 }
  },
  nativeDreamParticle: {
    position: "absolute",
    borderRadius: 999,
    opacity: 0.86
  },
  nativeStampTitle: {
    marginTop: 16,
    color: "#fff",
    fontSize: 16,
    lineHeight: 24,
    letterSpacing: 1,
    textAlign: "center"
  },
  nativeStampSteps: {
    marginTop: 20,
    width: 86,
    height: 34,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center"
  },
  nativeStampStepDot: {
    width: 42,
    height: 42,
    borderRadius: 21,
    backgroundColor: "rgba(188,184,255,0.78)"
  },
  nativeStampStepLine: {
    width: 28,
    height: 10,
    marginHorizontal: -5,
    backgroundColor: "rgba(188,184,255,0.58)"
  },
  nativeStampStep: {
    marginTop: 6,
    color: "#fff",
    fontSize: 14,
    letterSpacing: 1
  },
  nativeStreakRow: {
    marginTop: 38,
    marginHorizontal: 34,
    flexDirection: "row",
    justifyContent: "space-between"
  },
  nativeStreakMain: {
    color: "#fff",
    fontSize: 25,
    lineHeight: 38,
    fontWeight: "900"
  },
  nativeStreakSub: {
    color: "#fff",
    fontSize: 20,
    lineHeight: 36
  },
  nativeFeedbackButton: {
    height: 40,
    borderRadius: 19,
    alignItems: "center",
    justifyContent: "center",
    marginHorizontal: 54,
    marginTop: 12,
    backgroundColor: "rgba(255,255,255,0.26)"
  },
  nativeFeedbackButtonText: {
    color: "#fff",
    fontSize: 17
  },
  stampSheetLayer: {
    position: "absolute",
    top: 0,
    right: 0,
    bottom: 0,
    left: 0,
    zIndex: 360,
    justifyContent: "flex-end"
  },
  stampSheetScrim: {
    position: "absolute",
    top: 0,
    right: 0,
    bottom: 0,
    left: 0,
    backgroundColor: "rgba(18,20,24,0.42)"
  },
  stampSheet: {
    minHeight: "70%",
    maxHeight: "78%",
    borderTopLeftRadius: 34,
    borderTopRightRadius: 34,
    paddingTop: 10,
    paddingHorizontal: 24,
    paddingBottom: 30,
    overflow: "hidden",
    backgroundColor: "rgba(18,21,24,0.72)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.28)",
    shadowColor: "#000",
    shadowOpacity: 0.28,
    shadowRadius: 34,
    shadowOffset: { width: 0, height: -12 }
  },
  stampSheetLiquidA: {
    position: "absolute",
    left: -80,
    top: 70,
    width: 220,
    height: 220,
    borderRadius: 110,
    backgroundColor: "rgba(255,255,255,0.08)"
  },
  stampSheetLiquidB: {
    position: "absolute",
    right: -60,
    bottom: 60,
    width: 240,
    height: 240,
    borderRadius: 120,
    backgroundColor: "rgba(203,215,172,0.08)"
  },
  stampSheetHandle: {
    width: 48,
    height: 5,
    borderRadius: 3,
    alignSelf: "center",
    backgroundColor: "rgba(255,255,255,0.28)"
  },
  stampSheetTop: {
    height: 52,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between"
  },
  stampSheetClose: {
    width: 44,
    height: 44,
    borderRadius: 22,
    alignItems: "center",
    justifyContent: "center",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.34)"
  },
  stampSheetCloseText: {
    color: "#fff",
    fontSize: 28,
    lineHeight: 31
  },
  stampSheetDots: {
    flexDirection: "row",
    gap: 10,
    alignItems: "center"
  },
  stampSheetDot: {
    width: 9,
    height: 9,
    borderRadius: 5,
    backgroundColor: "rgba(255,255,255,0.14)"
  },
  stampSheetDotActive: {
    backgroundColor: "#dcff63"
  },
  stampSheetHero: {
    alignItems: "center",
    marginTop: 4
  },
  stampFrame: {
    width: 244,
    height: 330,
    alignItems: "center",
    justifyContent: "center",
    borderRadius: 8,
    backgroundColor: "#eef3fb",
    shadowColor: "#000",
    shadowOpacity: 0.18,
    shadowRadius: 18,
    shadowOffset: { width: 0, height: 10 }
  },
  stampFrameSmall: {
    transform: [{ scale: 0.92 }]
  },
  stampMonthPill: {
    position: "absolute",
    right: 21,
    top: 26,
    minWidth: 62,
    height: 24,
    borderRadius: 12,
    alignItems: "center",
    justifyContent: "center",
    paddingHorizontal: 9,
    backgroundColor: "rgba(255,255,255,0.82)"
  },
  stampMonthText: {
    color: "#4f5a5f",
    fontSize: 10,
    fontWeight: "900"
  },
  stampCodeText: {
    position: "absolute",
    left: 22,
    top: 27,
    color: "#4f5a5f",
    fontSize: 8,
    letterSpacing: 0.4,
    fontWeight: "900",
    opacity: 0.78
  },
  stampSheetCode: {
    color: "rgba(255,255,255,0.70)",
    fontSize: 12,
    letterSpacing: 0.6,
    fontWeight: "900"
  },
  stampFrameImage: {
    width: 244,
    height: 330,
    borderRadius: 8
  },
  stampAssetPanel: {
    width: 152,
    height: 152,
    alignItems: "center",
    justifyContent: "center",
    marginTop: 24
  },
  stampAssetGlyph: {
    position: "absolute",
    color: "rgba(255,255,255,0.96)",
    fontSize: 30,
    fontWeight: "900",
    textShadowColor: "rgba(40,30,30,0.26)",
    textShadowRadius: 5
  },
  stampFrameTitle: {
    marginTop: 18,
    color: "#fff",
    fontSize: 24,
    lineHeight: 30,
    fontWeight: "900",
    textAlign: "center"
  },
  stampFrameFigure: {
    marginTop: 3,
    color: "rgba(255,255,255,0.72)",
    fontSize: 13,
    fontWeight: "800"
  },
  stampSheetRevealCopy: {
    marginTop: 22,
    color: "rgba(255,255,255,0.78)",
    fontSize: 15,
    textAlign: "center",
    fontWeight: "800"
  },
  stampSheetDetails: {
    marginTop: 18
  },
  stampSheetKicker: {
    color: "#dcff63",
    fontSize: 13,
    fontWeight: "900",
    letterSpacing: 1
  },
  stampSheetTitle: {
    marginTop: 5,
    color: "#fff",
    fontSize: 27,
    lineHeight: 32,
    fontWeight: "900"
  },
  stampSheetReason: {
    marginTop: 8,
    color: "rgba(255,255,255,0.82)",
    fontSize: 15,
    lineHeight: 22,
    fontWeight: "700"
  },
  stampSheetMetaGrid: {
    marginTop: 14,
    flexDirection: "row",
    gap: 12
  },
  stampSheetMeta: {
    flex: 1,
    minHeight: 70,
    borderRadius: 16,
    padding: 12,
    backgroundColor: "rgba(255,255,255,0.12)"
  },
  stampSheetMetaLabel: {
    color: "rgba(255,255,255,0.54)",
    fontSize: 12,
    fontWeight: "900"
  },
  stampSheetMetaValue: {
    marginTop: 6,
    color: "#fff",
    fontSize: 14,
    lineHeight: 19,
    fontWeight: "900"
  },
  stampEvidenceList: {
    marginTop: 12,
    gap: 5
  },
  stampEvidenceText: {
    color: "rgba(255,255,255,0.70)",
    fontSize: 12,
    lineHeight: 17,
    fontWeight: "700"
  },
  stampSheetActions: {
    marginTop: 18,
    flexDirection: "row",
    gap: 12
  },
  stampSheetSecondary: {
    flex: 1,
    height: 48,
    borderRadius: 24,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(255,255,255,0.20)"
  },
  stampSheetSecondaryText: {
    color: "#fff",
    fontSize: 16,
    fontWeight: "900"
  },
  stampSheetPrimary: {
    flex: 1,
    height: 48,
    borderRadius: 24,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(255,255,255,0.88)"
  },
  stampSheetPrimaryText: {
    color: "#27302d",
    fontSize: 16,
    fontWeight: "900"
  },
  nativeHealth: {
    flex: 1,
    backgroundColor: "transparent"
  },
  nativeHealthScroll: {
    flex: 1
  },
  nativeHealthContent: {
    minHeight: 1160,
    paddingTop: 82,
    paddingHorizontal: 22,
    paddingBottom: 230,
    backgroundColor: "#f4f2fb"
  },
  nativeHello: {
    flexDirection: "row",
    alignItems: "center",
    gap: 14,
    marginLeft: 10
  },
  nativeProfileButton: {
    width: 48,
    height: 48,
    borderRadius: 24,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(238,240,236,0.92)"
  },
  nativeProfileIcon: {
    color: "#15191a",
    fontSize: 27
  },
  nativeHi: {
    color: "#fff",
    fontSize: 36,
    lineHeight: 42,
    fontStyle: "italic",
    fontWeight: "800",
    textShadowColor: "rgba(53,58,65,0.24)",
    textShadowRadius: 4,
    textShadowOffset: { width: 0, height: 2 }
  },
  nativeHealthTitle: {
    color: "#fff",
    fontSize: 22,
    lineHeight: 27,
    fontWeight: "900",
    marginLeft: 10,
    marginTop: 8,
    textShadowColor: "rgba(53,58,65,0.24)",
    textShadowRadius: 5,
    textShadowOffset: { width: 0, height: 3 }
  },
  nativeHealthPersona: {
    marginLeft: 10,
    marginTop: 8,
    color: "rgba(81,87,98,0.72)",
    fontSize: 14,
    lineHeight: 20,
    fontWeight: "900"
  },
  nativeTopicRail: {
    marginTop: 10,
    marginHorizontal: 6,
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 8
  },
  nativeTopicChip: {
    minHeight: 32,
    borderRadius: 16,
    paddingHorizontal: 12,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(255,255,255,0.72)",
    borderWidth: 1,
    borderColor: "rgba(220,216,241,0.90)"
  },
  nativeTopicText: {
    color: "#616979",
    fontSize: 12,
    fontWeight: "900"
  },
  nativeStampStage: {
    position: "relative",
    height: 194,
    marginTop: 2
  },
  nativeHealthStamp: {
    position: "absolute",
    width: 90,
    height: 120,
    alignItems: "center",
    justifyContent: "center",
    paddingHorizontal: 4,
    paddingTop: 4,
    backgroundColor: "rgba(255,255,255,0.72)",
    borderRadius: 6,
    shadowColor: "#798088",
    shadowOpacity: 0.15,
    shadowRadius: 7,
    shadowOffset: { width: 0, height: 5 }
  },
  nativeHealthStampLocked: {
    opacity: 0.48
  },
  nativeHealthStampImage: {
    width: 84,
    height: 112
  },
  nativeStampMyth: {
    position: "absolute",
    top: 28,
    color: "rgba(255,255,255,0.94)",
    fontSize: 26,
    fontWeight: "900",
    textShadowColor: "rgba(58,40,38,0.28)",
    textShadowRadius: 4
  },
  nativeStampLockedText: {
    position: "absolute",
    right: 7,
    top: 7,
    color: "#a4a4aa",
    fontSize: 9,
    fontWeight: "900"
  },
  nativeStampPerfRow: {
    position: "absolute",
    left: 9,
    right: 9,
    flexDirection: "row",
    justifyContent: "space-between"
  },
  nativeStampPerfTop: {
    top: -5
  },
  nativeStampPerfBottom: {
    bottom: -5
  },
  nativeStampPerfCol: {
    position: "absolute",
    top: 8,
    bottom: 8,
    justifyContent: "space-between"
  },
  nativeStampPerfLeft: {
    left: -5
  },
  nativeStampPerfRight: {
    right: -5
  },
  nativeStampPerfDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: "#f6f5fb"
  },
  nativeStampArt: {
    position: "relative",
    width: 66,
    height: 54,
    borderRadius: 8,
    overflow: "hidden"
  },
  nativeStampArt_amateur: {
    backgroundColor: "#f3853d"
  },
  nativeStampArt_sleepers: {
    backgroundColor: "#185be8"
  },
  nativeStampArt_steps: {
    backgroundColor: "#f5fff5",
    borderWidth: 1,
    borderColor: "#7bc98d"
  },
  nativeStampArt_gym: {
    backgroundColor: "#ef4b29"
  },
  nativeStampArt_hours: {
    backgroundColor: "#1f64ef"
  },
  nativeHealthStampTitle: {
    marginTop: 8,
    color: "#1b4f9e",
    fontSize: 12,
    fontWeight: "900"
  },
  nativeStampFace: {
    position: "absolute",
    left: 20,
    top: 16,
    width: 46,
    height: 46,
    borderRadius: 23,
    backgroundColor: "#ffd45e"
  },
  nativeStampBand: {
    position: "absolute",
    left: 7,
    right: 6,
    top: 19,
    height: 7,
    borderRadius: 4,
    backgroundColor: "#0a2538"
  },
  nativeStampEyeRow: {
    position: "absolute",
    left: 12,
    right: 12,
    bottom: 8,
    flexDirection: "row",
    justifyContent: "space-between"
  },
  nativeStampEye: {
    width: 10,
    height: 14,
    borderRadius: 6,
    backgroundColor: "#fff"
  },
  nativeStampWaveA: {
    position: "absolute",
    left: -8,
    right: -10,
    bottom: 0,
    height: 28,
    borderTopLeftRadius: 40,
    borderTopRightRadius: 40,
    backgroundColor: "rgba(8,41,147,0.44)"
  },
  nativeStampWaveB: {
    position: "absolute",
    left: -16,
    right: -22,
    bottom: 18,
    height: 24,
    borderTopLeftRadius: 36,
    borderTopRightRadius: 36,
    backgroundColor: "rgba(85,128,255,0.38)"
  },
  nativeStampZ: {
    position: "absolute",
    left: 26,
    top: 9,
    color: "#ffd340",
    fontSize: 22,
    fontWeight: "900",
    transform: [{ rotate: "-14deg" }]
  },
  nativeStampZTwo: {
    left: 55,
    top: 30,
    color: "#fff",
    transform: [{ rotate: "12deg" }]
  },
  nativeStepsCard: {
    position: "absolute",
    left: 13,
    top: 12,
    width: 58,
    height: 44,
    borderWidth: 2,
    borderColor: "#57bd73",
    backgroundColor: "#fff",
    transform: [{ rotate: "-8deg" }]
  },
  nativeStepsPath: {
    position: "absolute",
    left: 40,
    top: 15,
    width: 2,
    height: 42,
    backgroundColor: "#8bcfa0",
    transform: [{ rotate: "38deg" }]
  },
  nativeStepsBud: {
    position: "absolute",
    right: 5,
    bottom: 3,
    width: 31,
    height: 31,
    borderRadius: 16,
    backgroundColor: "#3d82f6"
  },
  nativeGymFace: {
    position: "absolute",
    left: 26,
    top: 15,
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: "#8f190f",
    alignItems: "center",
    justifyContent: "center"
  },
  nativeGymFaceText: {
    color: "#ff8b6e",
    fontSize: 27,
    fontWeight: "900"
  },
  nativeHoursHill: {
    position: "absolute",
    left: -10,
    right: -10,
    bottom: -8,
    height: 42,
    borderTopLeftRadius: 70,
    borderTopRightRadius: 70,
    backgroundColor: "#75ce77"
  },
  nativeHoursMoon: {
    position: "absolute",
    left: 15,
    top: 7,
    color: "#ffdc41",
    fontSize: 24
  },
  nativeHoursZ: {
    position: "absolute",
    left: 30,
    top: 32,
    color: "#dfffea",
    fontSize: 18,
    fontWeight: "900"
  },
  nativeStampA: { left: 20, top: 10, transform: [{ rotate: "-8deg" }] },
  nativeStampB: { left: 132, top: -6, width: 98, transform: [{ rotate: "7deg" }] },
  nativeStampC: { right: 4, top: 46, width: 100, transform: [{ rotate: "-8deg" }] },
  nativeStampD: { left: 88, top: 124, width: 84 },
  nativeStampE: { left: 206, top: 134, width: 84 },
  nativePeriodExperience: {
    marginTop: 4,
    marginBottom: 6,
    marginHorizontal: 8,
    color: "#8f949b",
    fontSize: 13,
    lineHeight: 18,
    fontWeight: "800"
  },
  nativeExperienceBlock: {
    marginTop: 8,
    marginHorizontal: 8,
    borderRadius: 18,
    paddingHorizontal: 14,
    paddingVertical: 12,
    backgroundColor: "rgba(255,255,255,0.58)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.82)"
  },
  nativeExperienceTitle: {
    color: "#7d8490",
    fontSize: 13,
    fontWeight: "900"
  },
  nativeExperienceText: {
    marginTop: 5,
    color: "#4c555c",
    fontSize: 14,
    lineHeight: 19,
    fontWeight: "800"
  },
  nativeExperienceInline: {
    marginTop: 6,
    marginHorizontal: 10,
    color: "rgba(255,255,255,0.88)",
    fontSize: 14,
    lineHeight: 20,
    fontWeight: "900",
    textShadowColor: "rgba(53,58,65,0.22)",
    textShadowRadius: 4,
    textShadowOffset: { width: 0, height: 2 }
  },
  nativeWeekCard: {
    overflow: "hidden",
    borderRadius: 24,
    backgroundColor: "#fff",
    shadowColor: "#202528",
    shadowOpacity: 0.28,
    shadowRadius: 12,
    shadowOffset: { width: 0, height: 8 }
  },
  nativeWeekHeader: {
    paddingHorizontal: 14,
    paddingTop: 10,
    paddingBottom: 8,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    backgroundColor: "#aa9cdb"
  },
  nativeWeekKicker: {
    color: "rgba(255,255,255,0.72)",
    fontSize: 11,
    fontWeight: "900"
  },
  nativeWeekTitle: {
    marginTop: 2,
    color: "#fff",
    fontSize: 16,
    fontWeight: "900"
  },
  nativeWeekTop: {
    minHeight: 116,
    paddingHorizontal: 14,
    paddingTop: 12,
    paddingBottom: 10,
    flexDirection: "row",
    backgroundColor: "#a997db"
  },
  nativeWeekLeft: {
    flex: 1.12
  },
  nativeCountRow: {
    flexDirection: "row",
    alignItems: "flex-end",
    gap: 18,
    marginBottom: 8
  },
  nativeCount: {
    color: "#fff",
    fontSize: 30,
    lineHeight: 34,
    fontWeight: "900"
  },
  nativeCountLabel: {
    color: "rgba(255,255,255,0.82)",
    fontSize: 12,
    marginTop: -4,
    fontWeight: "900"
  },
  nativeHeatmap: {
    width: 126,
    gap: 5
  },
  nativeHeatmapRow: {
    flexDirection: "row",
    alignItems: "center"
  },
  nativeHeatmapCells: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 5
  },
  nativeHeatCell: {
    width: 10,
    height: 10,
    borderRadius: 3,
    backgroundColor: "#d8d9dc"
  },
  nativeHeatCellOn: {
    backgroundColor: "#45bd5e"
  },
  nativeHeatCellDark: {
    backgroundColor: "#2f7d45"
  },
  nativeHeatCellHot: {
    shadowColor: "#61ff79",
    shadowOpacity: 0.42,
    shadowRadius: 5,
    shadowOffset: { width: 0, height: 0 }
  },
  nativeHeatLegend: {
    marginTop: 8,
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 7
  },
  nativeHeatLegendText: {
    color: "rgba(255,255,255,0.76)",
    fontSize: 10,
    fontWeight: "800"
  },
  nativeMonthCard: {
    overflow: "hidden",
    minHeight: 286,
    marginTop: 14,
    borderRadius: 28,
    backgroundColor: "rgba(255,255,255,0.90)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.92)",
    shadowColor: "#263035",
    shadowOpacity: 0.23,
    shadowRadius: 18,
    shadowOffset: { width: 0, height: 12 }
  },
  nativeMonthHeader: {
    paddingHorizontal: 16,
    paddingTop: 13,
    paddingBottom: 7,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    backgroundColor: "#aa9cdb"
  },
  nativeMonthScorePill: {
    minWidth: 66,
    height: 34,
    borderRadius: 17,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(255,255,255,0.28)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.48)"
  },
  nativeMonthScore: {
    color: "#fff",
    fontSize: 16,
    fontWeight: "900"
  },
  nativeMonthStats: {
    paddingHorizontal: 14,
    paddingVertical: 7,
    flexDirection: "row",
    gap: 8,
    backgroundColor: "#aa9cdb"
  },
  nativeMonthStatHigh: {
    overflow: "hidden",
    borderRadius: 12,
    paddingHorizontal: 9,
    paddingVertical: 5,
    color: "#eaffef",
    backgroundColor: "rgba(57,191,89,0.35)",
    fontSize: 11,
    fontWeight: "900"
  },
  nativeMonthStatLow: {
    overflow: "hidden",
    borderRadius: 12,
    paddingHorizontal: 9,
    paddingVertical: 5,
    color: "#fff6df",
    backgroundColor: "rgba(255,178,64,0.28)",
    fontSize: 11,
    fontWeight: "900"
  },
  nativeMonthStatSteady: {
    overflow: "hidden",
    borderRadius: 12,
    paddingHorizontal: 9,
    paddingVertical: 5,
    color: "rgba(255,255,255,0.86)",
    backgroundColor: "rgba(255,255,255,0.18)",
    fontSize: 11,
    fontWeight: "900"
  },
  nativeMonthBody: {
    minHeight: 118,
    paddingHorizontal: 14,
    paddingTop: 8,
    paddingBottom: 10,
    flexDirection: "row",
    gap: 6,
    backgroundColor: "#aa9cdb"
  },
  monthlyEnergyGrid: {
    width: 146,
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 6
  },
  monthlyEnergyCell: {
    width: 11,
    height: 11,
    borderRadius: 3
  },
  monthlyEnergyCellHot: {
    shadowColor: "#61ff79",
    shadowOpacity: 0.42,
    shadowRadius: 5,
    shadowOffset: { width: 0, height: 0 }
  },
  nativeMonthLegend: {
    marginTop: 10,
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 8
  },
  nativeMonthLegendText: {
    color: "rgba(255,255,255,0.76)",
    fontSize: 10,
    fontWeight: "800"
  },
  nativeRadarCaption: {
    marginTop: 6,
    color: "rgba(255,255,255,0.74)",
    fontSize: 9,
    lineHeight: 13,
    textAlign: "center",
    fontWeight: "800"
  },
  heatmapRangeControl: {
    height: 30,
    borderRadius: 15,
    paddingHorizontal: 6,
    flexDirection: "row",
    alignItems: "center",
    gap: 4,
    backgroundColor: "rgba(255,255,255,0.24)"
  },
  heatmapRangeArrow: {
    width: 24,
    height: 24,
    borderRadius: 12,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(255,255,255,0.30)"
  },
  heatmapRangeArrowText: {
    color: "#fff",
    fontSize: 24,
    lineHeight: 24,
    fontWeight: "900"
  },
  heatmapRangeLabel: {
    color: "#fff",
    fontSize: 12,
    fontWeight: "900"
  },
  heatLegendItem: {
    flexDirection: "row",
    alignItems: "center",
    gap: 4
  },
  heatLegendDot: {
    width: 7,
    height: 7,
    borderRadius: 4
  },
  nativeRadarWrap: {
    width: 118,
    alignItems: "center",
    justifyContent: "center"
  },
  nativeRadar: {
    flex: 0.9,
    color: "rgba(255,255,255,0.72)",
    fontSize: 94,
    textAlign: "center",
    paddingTop: 16
  },
  nativeWeekCopy: {
    paddingHorizontal: 16,
    paddingTop: 8,
    paddingBottom: 36,
    color: "#4a5658",
    fontSize: 17,
    lineHeight: 22,
    fontWeight: "900"
  },
  nativeMore: {
    position: "absolute",
    bottom: 14,
    alignSelf: "center",
    color: "#8c8c90",
    fontSize: 20,
    fontWeight: "900"
  },
  nativeMoreButton: {
    position: "absolute",
    left: 0,
    right: 0,
    bottom: 0,
    height: 52,
    alignItems: "center"
  },
  nativeAiRow: {
    marginTop: 28,
    marginHorizontal: 10,
    marginBottom: 16,
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center"
  },
  nativeAiTitle: {
    color: "#9aa4a6",
    fontSize: 21,
    fontWeight: "900"
  },
  nativeDetailPill: {
    height: 31,
    borderRadius: 16,
    paddingHorizontal: 22,
    justifyContent: "center",
    backgroundColor: "#ded3ff"
  },
  nativeDetailPillText: {
    color: "#7d7785",
    fontSize: 16,
    fontWeight: "900"
  },
  nativeMetricGrid: {
    flexDirection: "row",
    gap: 14,
    marginTop: 14,
    paddingHorizontal: 6
  },
  nativeAverageEnergyCard: {
    marginHorizontal: 6,
    borderRadius: 22,
    paddingHorizontal: 20,
    paddingVertical: 18,
    backgroundColor: "rgba(255,255,255,0.94)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.95)",
    shadowColor: "#485052",
    shadowOpacity: 0.18,
    shadowRadius: 12,
    shadowOffset: { width: 0, height: 8 }
  },
  nativeAverageEnergyLabel: {
    color: "#8d979a",
    fontSize: 16,
    fontWeight: "900"
  },
  nativeAverageEnergyValue: {
    marginTop: 4,
    color: "#4b5758",
    fontSize: 60,
    lineHeight: 66,
    fontWeight: "900"
  },
  nativeAverageEnergyCopy: {
    marginTop: 4,
    color: "rgba(75,87,88,0.62)",
    fontSize: 13,
    lineHeight: 18,
    fontWeight: "800"
  },
  nativeMetricCard: {
    flex: 1,
    minHeight: 122,
    borderRadius: 16,
    alignItems: "center",
    padding: 16,
    backgroundColor: "#fff",
    shadowColor: "#485052",
    shadowOpacity: 0.2,
    shadowRadius: 10,
    shadowOffset: { width: 0, height: 6 }
  },
  nativeMetricLabel: {
    color: "#a7b0b2",
    fontSize: 19,
    fontWeight: "900"
  },
  nativeMetricValue: {
    color: "#4b5758",
    fontSize: 56,
    lineHeight: 62,
    fontWeight: "900"
  },
  nativeMetricCopy: {
    marginTop: 4,
    color: "rgba(75,87,88,0.58)",
    fontSize: 12,
    lineHeight: 16,
    textAlign: "center",
    fontWeight: "800"
  },
  nativeExtraCard: {
    marginTop: 14,
    marginHorizontal: 6,
    borderRadius: 18,
    padding: 18,
    backgroundColor: "#fff",
    shadowColor: "#485052",
    shadowOpacity: 0.16,
    shadowRadius: 9,
    shadowOffset: { width: 0, height: 5 }
  },
  nativeExtraValue: {
    marginTop: 4,
    color: "#4b5758",
    fontSize: 42,
    fontWeight: "900"
  },
  nativeExtraCopy: {
    marginTop: 8,
    color: "rgba(75,87,88,0.62)",
    fontSize: 15,
    lineHeight: 22
  },
  healthDetailPage: {
    flex: 1,
    backgroundColor: "#fbfafb"
  },
  healthDetailContent: {
    paddingTop: 48,
    paddingHorizontal: 22,
    paddingBottom: 132,
    minHeight: 1120
  },
  healthDetailHeader: {
    height: 64,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between"
  },
  healthBackButton: {
    width: 54,
    height: 54,
    borderRadius: 27,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "#fff",
    shadowColor: "#d6d2e8",
    shadowOpacity: 0.28,
    shadowRadius: 12,
    shadowOffset: { width: 0, height: 6 }
  },
  healthBackText: {
    color: "#202233",
    fontSize: 43,
    marginTop: -5
  },
  healthDetailDate: {
    color: "#202233",
    fontSize: 22,
    fontWeight: "900"
  },
  healthDateSwitcher: {
    flexDirection: "row",
    alignItems: "center",
    gap: 14
  },
  healthDateArrow: {
    width: 34,
    height: 34,
    borderRadius: 17,
    alignItems: "center",
    justifyContent: "center"
  },
  healthDateArrowText: {
    color: "#202233",
    fontSize: 35,
    lineHeight: 35,
    fontWeight: "700"
  },
  healthHeaderSpacer: {
    width: 54
  },
  healthDetailChips: {
    marginTop: 10,
    marginBottom: 16,
    flexDirection: "row",
    justifyContent: "space-between",
    gap: 6
  },
  healthDetailChip: {
    width: 62,
    height: 62,
    borderRadius: 31,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "#fff",
    shadowColor: "#dad8e6",
    shadowOpacity: 0.24,
    shadowRadius: 14,
    shadowOffset: { width: 0, height: 7 }
  },
  healthDetailChipActive: {
    backgroundColor: "#e9f3ff"
  },
  healthDetailChipLabel: {
    color: "#6d737c",
    fontSize: 13,
    fontWeight: "900"
  },
  healthDetailChipValue: {
    marginTop: 2,
    color: "#111827",
    fontSize: 20,
    fontWeight: "900"
  },
  healthDetailTabs: {
    position: "absolute",
    left: 14,
    right: 14,
    bottom: 18,
    height: 42,
    borderRadius: 23,
    padding: 4,
    flexDirection: "row",
    backgroundColor: "#eeebf7",
    shadowColor: "#c9c5df",
    shadowOpacity: 0.28,
    shadowRadius: 14,
    shadowOffset: { width: 0, height: 8 }
  },
  healthDetailTabButton: {
    flex: 1,
    borderRadius: 19,
    alignItems: "center",
    justifyContent: "center"
  },
  healthDetailTabActive: {
    backgroundColor: "#fff"
  },
  healthDetailTabText: {
    color: "#8a879c",
    fontSize: 13,
    fontWeight: "900"
  },
  healthDetailTabTextActive: {
    color: "#25253a"
  },
  summaryRadarWrap: {
    height: 300,
    marginTop: 6,
    alignItems: "center",
    justifyContent: "center"
  },
  chartLineBase: {
    position: "absolute",
    borderRadius: 2
  },
  healthRadarGraph: {
    position: "relative",
    alignItems: "center",
    justifyContent: "center"
  },
  healthRadarGraphCompact: {
    transform: [{ scale: 0.96 }]
  },
  healthRadarFillWash: {
    position: "absolute",
    width: 116,
    height: 116,
    borderRadius: 58,
    backgroundColor: "rgba(93,224,144,0.16)"
  },
  healthRadarFillWashCompact: {
    width: 70,
    height: 70,
    borderRadius: 35
  },
  healthRadarGridLine: {
    backgroundColor: "rgba(255,255,255,0.80)"
  },
  healthRadarAxisLine: {
    backgroundColor: "rgba(195,196,218,0.55)"
  },
  healthRadarValueLine: {
    backgroundColor: "#28cf76",
    shadowColor: "#28cf76",
    shadowOpacity: 0.18,
    shadowRadius: 4,
    shadowOffset: { width: 0, height: 0 }
  },
  healthRadarRing: {
    position: "absolute",
    borderWidth: 2,
    borderColor: "rgba(255,255,255,0.62)"
  },
  healthRadarAxis: {
    position: "absolute",
    height: 2,
    backgroundColor: "rgba(255,255,255,0.42)"
  },
  healthRadarBlob: {
    position: "absolute",
    width: 126,
    height: 96,
    borderRadius: 34,
    backgroundColor: "rgba(79,216,137,0.22)",
    borderWidth: 3,
    borderColor: "#2fd27a",
    transform: [{ rotate: "19deg" }]
  },
  healthRadarBlobCompact: {
    width: 70,
    height: 54,
    borderRadius: 22,
    borderWidth: 2
  },
  healthRadarDot: {
    position: "absolute",
    width: 10,
    height: 10,
    borderRadius: 5,
    backgroundColor: "#3ee878",
    borderWidth: 2,
    borderColor: "rgba(255,255,255,0.86)"
  },
  healthRadarDotCompact: {
    width: 7,
    height: 7,
    borderRadius: 4,
    borderWidth: 1
  },
  healthRadarLabel: {
    position: "absolute",
    width: 44,
    color: "#7c5cff",
    fontSize: 16,
    textAlign: "center",
    fontWeight: "900"
  },
  healthRadarMetricLayer: {
    position: "absolute",
    left: 0,
    top: 0
  },
  healthRadarCenterScore: {
    zIndex: 2,
    width: 78,
    height: 78,
    borderRadius: 39,
    overflow: "hidden",
    textAlign: "center",
    paddingTop: 11,
    color: "#fff",
    backgroundColor: "rgba(96,221,139,0.28)",
    fontSize: 40,
    fontWeight: "900"
  },
  healthRadarCenterScoreCompact: {
    width: 48,
    height: 48,
    borderRadius: 24,
    paddingTop: 10,
    fontSize: 22
  },
  activityRingPanel: {
    marginTop: 8,
    marginBottom: 22,
    borderRadius: 34,
    paddingTop: 24,
    paddingBottom: 18,
    paddingHorizontal: 18,
    alignItems: "center",
    backgroundColor: "rgba(244,240,255,0.96)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.90)",
    shadowColor: "#d8d1ef",
    shadowOpacity: 0.24,
    shadowRadius: 18,
    shadowOffset: { width: 0, height: 10 }
  },
  activityRingStack: {
    width: 246,
    height: 246,
    alignItems: "center",
    justifyContent: "center"
  },
  activityRing: {
    position: "absolute",
    borderWidth: 11,
    borderStyle: "solid"
  },
  activityRingGap: {
    position: "absolute",
    right: -14,
    top: 18,
    width: 44,
    height: 34,
    borderRadius: 18,
    backgroundColor: "rgba(244,240,255,0.96)"
  },
  activityRingCenter: {
    width: 92,
    height: 92,
    borderRadius: 46,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(255,255,255,0.72)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.92)"
  },
  activityRingScore: {
    color: "#20243a",
    fontSize: 42,
    lineHeight: 46,
    fontWeight: "900"
  },
  activityRingCenterLabel: {
    marginTop: 2,
    color: "#7c5cff",
    fontSize: 14,
    fontWeight: "900"
  },
  activityRingLegend: {
    width: "100%",
    marginTop: 10,
    flexDirection: "row",
    flexWrap: "wrap",
    justifyContent: "center",
    gap: 10
  },
  activityRingLegendItem: {
    minWidth: 92,
    borderRadius: 18,
    paddingHorizontal: 10,
    paddingVertical: 8,
    flexDirection: "row",
    alignItems: "center",
    gap: 8,
    backgroundColor: "rgba(255,255,255,0.68)"
  },
  activityRingLegendDot: {
    width: 10,
    height: 10,
    borderRadius: 5
  },
  activityRingLegendLabel: {
    color: "#6b7080",
    fontSize: 12,
    fontWeight: "800"
  },
  activityRingLegendValue: {
    marginTop: 1,
    color: "#20243a",
    fontSize: 15,
    fontWeight: "900"
  },
  summaryRadarCircle: {
    width: 190,
    height: 190,
    borderRadius: 95,
    borderWidth: 4,
    borderColor: "rgba(255,255,255,0.90)",
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(143,126,255,0.08)"
  },
  summaryRadarPolygon: {
    position: "absolute",
    width: 146,
    height: 146,
    borderRadius: 38,
    borderWidth: 3,
    borderColor: "#2fcf78",
    backgroundColor: "rgba(78,218,143,0.18)",
    transform: [{ rotate: "21deg" }]
  },
  summaryRadarScore: {
    zIndex: 2,
    width: 78,
    height: 78,
    borderRadius: 39,
    overflow: "hidden",
    textAlign: "center",
    paddingTop: 11,
    color: "#fff",
    backgroundColor: "rgba(96,221,139,0.22)",
    fontSize: 40,
    fontWeight: "900"
  },
  summaryRadarLabelTop: {
    position: "absolute",
    top: 18,
    color: "#7c5cff",
    fontSize: 18,
    fontWeight: "900"
  },
  summaryRadarLabelLeft: {
    position: "absolute",
    left: 30,
    top: 112,
    color: "#7c5cff",
    fontSize: 17,
    fontWeight: "900",
    transform: [{ rotate: "-52deg" }]
  },
  summaryRadarLabelRight: {
    position: "absolute",
    right: 24,
    top: 116,
    color: "#7c5cff",
    fontSize: 17,
    fontWeight: "900",
    transform: [{ rotate: "52deg" }]
  },
  summaryRadarLabelBottomLeft: {
    position: "absolute",
    left: 54,
    bottom: 40,
    color: "#7c5cff",
    fontSize: 17,
    fontWeight: "900",
    transform: [{ rotate: "-52deg" }]
  },
  summaryRadarLabelBottomRight: {
    position: "absolute",
    right: 58,
    bottom: 38,
    color: "#7c5cff",
    fontSize: 17,
    fontWeight: "900",
    transform: [{ rotate: "52deg" }]
  },
  summaryTranslateBlock: {
    marginTop: 4,
    marginHorizontal: 8
  },
  summarySectionLabel: {
    color: "#9ca3af",
    fontSize: 23,
    fontWeight: "900"
  },
  summaryPercentRow: {
    marginTop: 10,
    flexDirection: "row",
    alignItems: "center",
    gap: 18
  },
  summaryPercent: {
    color: "#24b879",
    fontSize: 54,
    lineHeight: 58,
    fontWeight: "900"
  },
  summaryPercentCopy: {
    color: "#606774",
    fontSize: 23,
    lineHeight: 25,
    fontWeight: "800"
  },
  summaryBodyCopy: {
    marginTop: 8,
    color: "#20283a",
    fontSize: 18,
    lineHeight: 28,
    fontWeight: "700"
  },
  summaryHeatCard: {
    minHeight: 160,
    marginTop: 20,
    borderRadius: 24,
    padding: 18,
    backgroundColor: "#aa9cdb"
  },
  summaryHeatHeader: {
    marginBottom: 14,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between"
  },
  summaryHeatTitle: {
    color: "#fff",
    fontSize: 18,
    fontWeight: "900"
  },
  summaryHeatGridRows: {
    gap: 10
  },
  summaryHeatGridRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: 12
  },
  summaryHeatGridLabel: {
    width: 42,
    color: "rgba(255,255,255,0.92)",
    fontSize: 18,
    fontWeight: "800"
  },
  summaryHeatGridCells: {
    flex: 1,
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 7
  },
  summaryHeatLabels: {
    width: 58,
    justifyContent: "space-around"
  },
  summaryHeatGrid: {
    flex: 1,
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 8,
    alignContent: "center"
  },
  summaryHeatCell: {
    width: 13,
    height: 13,
    borderRadius: 4,
    backgroundColor: "rgba(240,240,244,0.72)"
  },
  summaryHeatCellOn: {
    backgroundColor: "#40cf61"
  },
  summaryHeatCellDark: {
    backgroundColor: "#2a7b43"
  },
  summaryHeatCellHot: {
    shadowColor: "#61ff79",
    shadowOpacity: 0.42,
    shadowRadius: 5,
    shadowOffset: { width: 0, height: 0 }
  },
  summaryHeatLegend: {
    marginTop: 14,
    flexDirection: "row",
    flexWrap: "wrap",
    justifyContent: "center",
    gap: 14
  },
  summaryHeatLegendText: {
    color: "rgba(255,255,255,0.78)",
    fontSize: 12,
    fontWeight: "800"
  },
  healthAdviceCard: {
    marginTop: 22,
    borderRadius: 24,
    padding: 18,
    backgroundColor: "#fff",
    borderWidth: 1,
    borderColor: "#eceafa"
  },
  healthAdviceTitleRow: {
    flexDirection: "row",
    alignItems: "center",
    marginBottom: 12
  },
  healthAdviceSpark: {
    color: "#8a69ff",
    fontSize: 25,
    marginRight: 8
  },
  healthAdviceTitle: {
    color: "#22263a",
    fontSize: 24,
    fontWeight: "900"
  },
  healthAdviceRow: {
    minHeight: 76,
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
    borderTopWidth: 1,
    borderTopColor: "#efedf8",
    paddingVertical: 10
  },
  healthAdviceIcon: {
    width: 44,
    height: 44,
    borderRadius: 22,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "#eee7ff"
  },
  healthAdviceIconGreen: {
    backgroundColor: "#e4fff2"
  },
  healthAdviceIconText: {
    color: "#825dff",
    fontSize: 22
  },
  healthAdviceCopy: {
    flex: 1
  },
  healthAdviceTime: {
    color: "#825dff",
    fontSize: 20,
    fontWeight: "900"
  },
  healthAdviceTimeGreen: {
    color: "#27c987"
  },
  healthAdviceName: {
    color: "#1f2638",
    fontSize: 17,
    fontWeight: "900"
  },
  healthAdviceText: {
    marginTop: 2,
    color: "#778092",
    fontSize: 13,
    lineHeight: 18,
    fontWeight: "700"
  },
  healthAdviceButton: {
    minWidth: 64,
    height: 34,
    borderRadius: 17,
    alignItems: "center",
    justifyContent: "center",
    borderWidth: 1,
    borderColor: "#9b7cff"
  },
  healthAdviceButtonGreen: {
    borderColor: "#22c987"
  },
  healthAdviceButtonText: {
    color: "#825dff",
    fontSize: 13,
    fontWeight: "900"
  },
  healthAdviceButtonTextGreen: {
    color: "#22c987"
  },
  healthDisclaimer: {
    marginTop: 24,
    color: "#a5abbb",
    fontSize: 14,
    textAlign: "center",
    fontWeight: "700"
  },
  sleepOverviewCard: {
    minHeight: 230,
    borderRadius: 28,
    padding: 22,
    backgroundColor: "#f4f2ff"
  },
  sleepTimes: {
    flexDirection: "row",
    gap: 22,
    marginBottom: 42
  },
  sleepStageWrap: {
    height: 72,
    flexDirection: "row",
    alignItems: "center",
    gap: 4
  },
  sleepStageSegment: {
    height: 34,
    borderRadius: 6
  },
  sleepLegend: {
    marginTop: 22,
    flexDirection: "row",
    justifyContent: "space-between"
  },
  sleepLegendItem: {
    flexDirection: "row",
    alignItems: "flex-start",
    gap: 7
  },
  sleepLegendDot: {
    width: 10,
    height: 10,
    borderRadius: 3,
    marginTop: 5
  },
  sleepLegendLabel: {
    color: "#6f7484",
    fontSize: 15,
    fontWeight: "800"
  },
  sleepLegendValue: {
    marginTop: 2,
    color: "#7f8494",
    fontSize: 14,
    fontWeight: "700"
  },
  sleepDebtBlock: {
    marginTop: 26,
    paddingHorizontal: 10
  },
  sleepDebtLabel: {
    color: "#7d8396",
    fontSize: 23,
    fontWeight: "900"
  },
  sleepDebtRow: {
    marginTop: 12,
    flexDirection: "row",
    alignItems: "flex-end",
    gap: 12
  },
  sleepDebtValue: {
    color: "#7d5cff",
    fontSize: 62,
    lineHeight: 66,
    fontWeight: "900"
  },
  sleepDebtUnit: {
    color: "#7d5cff",
    fontSize: 25,
    lineHeight: 40,
    fontWeight: "900"
  },
  sleepDebtCopy: {
    marginTop: 12,
    color: "#697287",
    fontSize: 17,
    lineHeight: 27,
    fontWeight: "700"
  },
  sleepTrendCard: {
    marginTop: 28,
    padding: 18,
    borderRadius: 22,
    backgroundColor: "#fff"
  },
  sleepTrendHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center"
  },
  sleepTrendTitle: {
    color: "#20243a",
    fontSize: 22,
    fontWeight: "900"
  },
  sleepTrendTabs: {
    height: 32,
    borderRadius: 16,
    padding: 3,
    flexDirection: "row",
    alignItems: "center",
    gap: 2,
    backgroundColor: "#f1edff",
  },
  sleepTrendTabActive: {
    overflow: "hidden",
    borderRadius: 13,
    paddingHorizontal: 13,
    paddingVertical: 5,
    color: "#25263b",
    backgroundColor: "#fff",
    fontSize: 13,
    fontWeight: "900"
  },
  sleepTrendTabText: {
    paddingHorizontal: 8,
    color: "#a3a3b7",
    fontSize: 13,
    fontWeight: "800"
  },
  sleepTrendChart: {
    height: 150,
    marginTop: 10,
    position: "relative",
    borderBottomWidth: 1,
    borderBottomColor: "#deddf0",
    overflow: "hidden"
  },
  sleepTrendGuide: {
    position: "absolute",
    left: 30,
    right: 0,
    height: 1,
    borderTopWidth: 1,
    borderTopColor: "#ebe9f8",
    borderStyle: "dashed"
  },
  sleepTrendLine: {
    backgroundColor: "#8a69ff"
  },
  sleepTrendArea: {
    position: "absolute",
    left: 28,
    right: 8,
    bottom: 18,
    height: 62,
    borderRadius: 16,
    backgroundColor: "rgba(138,105,255,0.08)"
  },
  sleepTrendPoint: {
    position: "absolute",
    width: 9,
    height: 9,
    borderRadius: 5,
    backgroundColor: "#8a69ff"
  },
  sleepTrendAxisLabel: {
    position: "absolute",
    color: "#7f8398",
    fontSize: 12,
    fontWeight: "800"
  },
  sleepTrendBadge: {
    position: "absolute",
    right: 4,
    top: 64,
    overflow: "hidden",
    borderRadius: 14,
    paddingHorizontal: 8,
    paddingVertical: 4,
    color: "#fff",
    backgroundColor: "#7d5cff",
    fontWeight: "900"
  },
  cycleRingCard: {
    height: 338,
    alignItems: "center",
    justifyContent: "center"
  },
  cycleWheelHeader: {
    alignItems: "center",
    marginTop: 16,
    marginBottom: 8
  },
  cycleWheelPhase: {
    color: "#111827",
    fontSize: 24,
    fontWeight: "900"
  },
  cycleWheelNext: {
    marginTop: 6,
    color: "#9294a3",
    fontSize: 17,
    fontWeight: "800"
  },
  cycleWheel: {
    position: "relative",
    width: 292,
    height: 292,
    borderRadius: 146,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(246,242,255,0.72)"
  },
  cycleWheelInner: {
    width: 190,
    height: 190,
    borderRadius: 95,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(255,237,249,0.68)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.78)"
  },
  cycleWheelInnerIcon: {
    color: "rgba(236,87,148,0.48)",
    fontSize: 54
  },
  cycleWheelDay: {
    position: "absolute",
    width: 28,
    height: 28,
    borderRadius: 7,
    alignItems: "center",
    justifyContent: "center",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.82)"
  },
  cycleWheelDayMenstrual: {
    backgroundColor: "#ef2f8c"
  },
  cycleWheelDayFollicular: {
    backgroundColor: "#32c9bd"
  },
  cycleWheelDayOvulation: {
    backgroundColor: "#8d63ff"
  },
  cycleWheelDayLuteal: {
    backgroundColor: "#ffbd42"
  },
  cycleWheelDayFuture: {
    backgroundColor: "rgba(255,255,255,0.34)",
    borderColor: "rgba(255,255,255,0.56)"
  },
  cycleWheelDayCurrent: {
    width: 44,
    height: 44,
    borderRadius: 12,
    zIndex: 4,
    shadowColor: "#9b7cff",
    shadowOpacity: 0.55,
    shadowRadius: 12,
    shadowOffset: { width: 0, height: 0 }
  },
  cycleWheelCurrentGlow: {
    position: "absolute",
    width: 58,
    height: 58,
    borderRadius: 29,
    backgroundColor: "rgba(255,255,255,0.34)"
  },
  cycleWheelCurrentArrow: {
    position: "absolute",
    bottom: -9,
    width: 0,
    height: 0,
    borderLeftWidth: 6,
    borderRightWidth: 6,
    borderTopWidth: 8,
    borderLeftColor: "transparent",
    borderRightColor: "transparent",
    borderTopColor: "#9b7cff"
  },
  cycleWheelDayText: {
    color: "rgba(255,255,255,0.92)",
    fontSize: 13,
    fontWeight: "900"
  },
  cycleWheelDayTextCurrent: {
    color: "#fff",
    fontSize: 24
  },
  cycleWheelPhaseLabel: {
    position: "absolute",
    color: "#8f6bff",
    fontSize: 16,
    fontWeight: "900"
  },
  cycleWheelPhaseLeft: {
    left: -38,
    top: 136
  },
  cycleWheelPhaseRight: {
    right: -38,
    top: 136
  },
  cycleWheelPhaseBottom: {
    bottom: -34
  },
  cycleRing: {
    width: 212,
    height: 212,
    borderRadius: 106,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "#f5f2ff"
  },
  cycleArc: {
    position: "absolute",
    width: 180,
    height: 180,
    borderRadius: 90,
    borderWidth: 14,
    borderColor: "transparent"
  },
  cycleArcTeal: {
    borderLeftColor: "#35cbc7",
    transform: [{ rotate: "6deg" }]
  },
  cycleArcPurple: {
    borderTopColor: "#7c5cff",
    transform: [{ rotate: "16deg" }]
  },
  cycleArcPink: {
    borderRightColor: "#f36f9f",
    transform: [{ rotate: "8deg" }]
  },
  cycleArcAmber: {
    borderBottomColor: "#ffb13e",
    transform: [{ rotate: "-22deg" }]
  },
  cycleFlower: {
    width: 92,
    height: 92,
    borderRadius: 46,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(139,107,255,0.12)"
  },
  cycleFlowerText: {
    color: "#8b6bff",
    fontSize: 56,
    opacity: 0.5
  },
  cyclePhaseText: {
    position: "absolute",
    fontSize: 18,
    fontWeight: "900"
  },
  cyclePhaseTeal: {
    left: 6,
    top: 145,
    color: "#35cbc7"
  },
  cyclePhasePurple: {
    top: 22,
    color: "#7c5cff"
  },
  cyclePhasePink: {
    right: 4,
    top: 145,
    color: "#f36f9f"
  },
  cyclePhaseAmber: {
    bottom: 28,
    color: "#ffb13e"
  },
  cycleInfoBlock: {
    paddingHorizontal: 6
  },
  cycleDayRow: {
    flexDirection: "row",
    alignItems: "flex-end",
    gap: 12
  },
  cycleDay: {
    color: "#9b7cff",
    fontSize: 62,
    lineHeight: 68,
    fontWeight: "900"
  },
  cycleDayCopy: {
    color: "#20243a",
    fontSize: 24,
    lineHeight: 42,
    fontWeight: "900"
  },
  cycleDecodeRow: {
    marginTop: 16,
    flexDirection: "row",
    gap: 12
  },
  cycleDecodeIcon: {
    width: 42,
    height: 42,
    overflow: "hidden",
    borderRadius: 21,
    textAlign: "center",
    paddingTop: 6,
    color: "#9b7cff",
    backgroundColor: "#efe9ff",
    fontSize: 25
  },
  cycleDecodeCopy: {
    flex: 1
  },
  cycleDecodeTitle: {
    color: "#20243a",
    fontSize: 22,
    fontWeight: "900"
  },
  cycleDecodeText: {
    marginTop: 6,
    color: "#6d7488",
    fontSize: 16,
    lineHeight: 25,
    fontWeight: "700"
  },
  cycleNextDate: {
    color: "#232840",
    fontSize: 16,
    lineHeight: 26,
    textAlign: "right",
    fontWeight: "900"
  },
  cycleProgressLabel: {
    marginTop: 22,
    color: "#6d7488",
    fontSize: 16,
    fontWeight: "800"
  },
  cycleProgress: {
    height: 14,
    marginTop: 10,
    flexDirection: "row",
    overflow: "hidden",
    borderRadius: 7,
    backgroundColor: "#efeafc"
  },
  cycleProgressPart: {
    height: 14
  },
  healthModuleHero: {
    minHeight: 430,
    borderRadius: 34,
    padding: 24,
    marginBottom: 22,
    overflow: "hidden",
    shadowColor: "#d4d1de",
    shadowOpacity: 0.22,
    shadowRadius: 18,
    shadowOffset: { width: 0, height: 12 }
  },
  healthModuleHeroFocus: {
    backgroundColor: "#dfe7fb"
  },
  healthModuleHeroMetabolism: {
    backgroundColor: "#f4bd45"
  },
  healthModuleHeroMorning: {
    backgroundColor: "#efe5df"
  },
  healthModuleHeaderRow: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between"
  },
  healthModuleBadge: {
    overflow: "hidden",
    borderRadius: 18,
    paddingHorizontal: 18,
    paddingVertical: 7,
    color: "#fff",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.58)",
    fontSize: 18,
    fontWeight: "900"
  },
  healthModuleTitle: {
    color: "#fff",
    fontSize: 42,
    lineHeight: 48,
    fontWeight: "900"
  },
  healthModuleCopy: {
    marginTop: 14,
    color: "rgba(255,255,255,0.88)",
    fontSize: 17,
    lineHeight: 25,
    fontWeight: "800"
  },
  healthModuleScore: {
    marginTop: 54,
    color: "#fff",
    fontSize: 64,
    lineHeight: 70,
    textAlign: "center",
    fontWeight: "900"
  },
  healthModuleSub: {
    marginTop: 28,
    color: "#686d78",
    fontSize: 16,
    lineHeight: 24,
    textAlign: "center",
    fontWeight: "900"
  },
  focusDetailWave: {
    height: 90,
    marginTop: 22,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    gap: 9
  },
  focusDetailTick: {
    width: 5,
    height: 54,
    borderRadius: 3,
    backgroundColor: "rgba(255,255,255,0.70)"
  },
  focusDetailTickActive: {
    height: 78,
    backgroundColor: "#f1df45"
  },
  healthModuleWaveCard: {
    height: 176,
    marginTop: 18,
    marginBottom: 20,
    borderRadius: 28,
    padding: 18,
    overflow: "hidden",
    backgroundColor: "#f4f2ff",
    borderWidth: 1,
    borderColor: "#ebe8fb"
  },
  healthModuleWaveCardClean: {
    backgroundColor: "transparent",
    borderColor: "rgba(138,105,255,0.18)"
  },
  healthModuleWaveAxisY: {
    position: "absolute",
    left: 24,
    top: 18,
    bottom: 24,
    width: 1,
    backgroundColor: "rgba(86,88,116,0.22)"
  },
  healthModuleWaveAxisX: {
    position: "absolute",
    left: 24,
    right: 22,
    bottom: 24,
    height: 1,
    backgroundColor: "rgba(86,88,116,0.22)"
  },
  healthModuleWaveGuide: {
    position: "absolute",
    left: 24,
    right: 24,
    height: 1,
    backgroundColor: "rgba(150,141,192,0.16)"
  },
  focusModuleWaveLine: {
    backgroundColor: "#8a69ff"
  },
  morningModuleWaveLine: {
    backgroundColor: "#28c989"
  },
  healthModuleWavePoint: {
    position: "absolute",
    width: 10,
    height: 10,
    borderRadius: 5,
    backgroundColor: "#8a69ff",
    borderWidth: 2,
    borderColor: "#fff"
  },
  healthModuleWavePointMorning: {
    backgroundColor: "#28c989"
  },
  healthModuleStateCard: {
    borderRadius: 26,
    padding: 22,
    backgroundColor: "#fff",
    borderWidth: 1,
    borderColor: "#efedf8",
    shadowColor: "#d8d5e3",
    shadowOpacity: 0.2,
    shadowRadius: 16,
    shadowOffset: { width: 0, height: 8 }
  },
  healthModuleStateKicker: {
    color: "#8a69ff",
    fontSize: 16,
    fontWeight: "900"
  },
  healthModuleStateRow: {
    marginTop: 8,
    flexDirection: "row",
    alignItems: "baseline",
    gap: 14
  },
  healthModuleStateScore: {
    color: "#25b879",
    fontSize: 58,
    lineHeight: 64,
    fontWeight: "900"
  },
  healthModuleStateTitle: {
    color: "#20243a",
    fontSize: 22,
    fontWeight: "900"
  },
  healthModuleStateCopy: {
    marginTop: 10,
    color: "#657085",
    fontSize: 16,
    lineHeight: 25,
    fontWeight: "700"
  },
  healthModuleStateHint: {
    marginTop: 14,
    color: "#7d5cff",
    fontSize: 15,
    fontWeight: "900"
  },
  healthModuleMiniStats: {
    marginTop: 18,
    flexDirection: "row",
    gap: 8
  },
  healthModuleMiniStat: {
    overflow: "hidden",
    borderRadius: 14,
    paddingHorizontal: 12,
    paddingVertical: 7,
    color: "#26b779",
    backgroundColor: "#eafff3",
    fontSize: 13,
    fontWeight: "900"
  },
  metabolismActivityDetailCard: {
    backgroundColor: "#f4bd45"
  },
  metabolismDetailRingRow: {
    marginTop: 34,
    flexDirection: "row",
    alignItems: "center",
    gap: 20
  },
  metabolismDetailRing: {
    width: 148,
    height: 148,
    borderRadius: 74,
    borderWidth: 13,
    borderTopColor: "#fff4cf",
    borderRightColor: "#ffe29b",
    borderBottomColor: "rgba(118,82,30,0.32)",
    borderLeftColor: "#fff0c0",
    alignItems: "center",
    justifyContent: "center",
    transform: [{ rotate: "-18deg" }]
  },
  metabolismDetailRingInner: {
    width: 108,
    height: 108,
    borderRadius: 54,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(255,255,255,0.24)",
    transform: [{ rotate: "18deg" }]
  },
  metabolismDetailRingScore: {
    color: "#fff",
    fontSize: 42,
    lineHeight: 46,
    fontWeight: "900"
  },
  metabolismDetailRingLabel: {
    color: "rgba(255,255,255,0.86)",
    fontSize: 14,
    fontWeight: "900"
  },
  metabolismDetailStatsPanel: {
    flex: 1,
    borderRadius: 26,
    padding: 16,
    backgroundColor: "rgba(255,255,255,0.20)"
  },
  metabolismDetailValue: {
    color: "#fff",
    fontSize: 48,
    lineHeight: 54,
    fontWeight: "900"
  },
  metabolismDetailLabel: {
    color: "rgba(255,255,255,0.78)",
    fontSize: 15,
    fontWeight: "900"
  },
  metabolismDetailHint: {
    marginTop: 12,
    color: "rgba(255,255,255,0.88)",
    fontSize: 14,
    lineHeight: 20,
    fontWeight: "800"
  },
  metabolismDetailBar: {
    height: 72,
    marginTop: 28,
    borderRadius: 22,
    overflow: "hidden",
    backgroundColor: "rgba(78,55,24,0.32)"
  },
  metabolismDetailBarFill: {
    width: "72%",
    height: "100%",
    borderRadius: 22,
    backgroundColor: "rgba(255,221,133,0.86)"
  },
  metabolismDetailStats: {
    marginTop: 24,
    flexDirection: "row",
    justifyContent: "space-between"
  },
  metabolismHeartCard: {
    minHeight: 426,
    marginTop: 10,
    marginBottom: 22,
    borderRadius: 34,
    padding: 24,
    overflow: "hidden",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.42)",
    shadowColor: "#7c1821",
    shadowOpacity: 0.24,
    shadowRadius: 20,
    shadowOffset: { width: 0, height: 12 }
  },
  metabolismHeart: {
    marginTop: 32,
    color: "rgba(255,239,214,0.38)",
    fontSize: 138,
    lineHeight: 150,
    textAlign: "center",
    textShadowColor: "rgba(255,196,99,0.28)",
    textShadowRadius: 18
  },
  metabolismHeartScore: {
    marginTop: -112,
    color: "#fff",
    fontSize: 58,
    lineHeight: 66,
    textAlign: "center",
    fontWeight: "900"
  },
  metabolismHeartCopy: {
    marginTop: 76,
    color: "rgba(255,255,255,0.90)",
    fontSize: 17,
    lineHeight: 25,
    fontWeight: "800"
  },
  metabolismHeartStats: {
    marginTop: 22,
    flexDirection: "row",
    justifyContent: "space-between",
    gap: 8
  },
  metabolismHeartStat: {
    flex: 1,
    overflow: "hidden",
    borderRadius: 18,
    paddingVertical: 10,
    color: "#fff",
    textAlign: "center",
    backgroundColor: "rgba(255,255,255,0.18)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.22)",
    fontSize: 14,
    fontWeight: "900"
  },
  morningDetailMap: {
    height: 218,
    marginTop: 32,
    alignItems: "center",
    justifyContent: "center"
  },
  morningMapShape: {
    width: 238,
    height: 152,
    borderRadius: 52,
    borderWidth: 1,
    borderColor: "rgba(86,79,67,0.46)",
    backgroundColor: "rgba(255,251,227,0.54)",
    transform: [{ rotate: "-9deg" }]
  },
  morningMapRoad: {
    position: "absolute",
    left: 104,
    width: 6,
    height: 170,
    borderRadius: 3,
    backgroundColor: "rgba(230,188,74,0.88)"
  },
  morningPin: {
    position: "absolute",
    right: 100,
    top: 56,
    width: 30,
    height: 42,
    borderTopLeftRadius: 18,
    borderTopRightRadius: 18,
    borderBottomLeftRadius: 18,
    backgroundColor: "#edd857",
    transform: [{ rotate: "45deg" }]
  },
  morningDetailStats: {
    marginTop: 6,
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "flex-end"
  },
  morningDetailBig: {
    color: "#302724",
    fontSize: 48,
    lineHeight: 54
  },
  reminderLayer: {
    position: "absolute",
    top: 0,
    right: 0,
    bottom: 0,
    left: 0,
    zIndex: 120,
    justifyContent: "flex-end"
  },
  reminderBackdrop: {
    position: "absolute",
    top: 0,
    right: 0,
    bottom: 0,
    left: 0,
    backgroundColor: "rgba(20,22,28,0.38)"
  },
  reminderPanel: {
    paddingTop: 10,
    paddingHorizontal: 22,
    paddingBottom: 28,
    borderTopLeftRadius: 28,
    borderTopRightRadius: 28,
    overflow: "hidden",
    backgroundColor: "rgba(18,21,27,0.82)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.16)"
  },
  reminderHandle: {
    alignSelf: "center",
    width: 44,
    height: 5,
    borderRadius: 3,
    backgroundColor: "rgba(255,255,255,0.26)",
    marginBottom: 18
  },
  reminderTitle: {
    color: "#ffffff",
    fontSize: 25,
    fontWeight: "900"
  },
  reminderSource: {
    marginTop: 4,
    color: "rgba(255,255,255,0.62)",
    fontSize: 15,
    fontWeight: "800"
  },
  reminderTimeRow: {
    marginTop: 20,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between"
  },
  reminderAdjust: {
    width: 72,
    height: 44,
    borderRadius: 22,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(143,123,255,0.18)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.12)"
  },
  reminderAdjustText: {
    color: "#7d5cff",
    fontSize: 17,
    fontWeight: "900"
  },
  reminderTime: {
    color: "#ffffff",
    fontSize: 48,
    fontWeight: "900"
  },
  reminderQuickRow: {
    marginTop: 18,
    flexDirection: "row",
    gap: 8
  },
  reminderQuick: {
    flex: 1,
    height: 38,
    borderRadius: 19,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(255,255,255,0.10)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.10)"
  },
  reminderQuickActive: {
    backgroundColor: "#7d5cff"
  },
  reminderQuickText: {
    color: "rgba(255,255,255,0.60)",
    fontSize: 14,
    fontWeight: "900"
  },
  reminderQuickTextActive: {
    color: "#fff"
  },
  reminderActions: {
    marginTop: 20,
    flexDirection: "row",
    gap: 12
  },
  reminderCancel: {
    flex: 1,
    height: 48,
    borderRadius: 24,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(255,255,255,0.12)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.12)"
  },
  reminderCancelText: {
    color: "rgba(255,255,255,0.72)",
    fontSize: 16,
    fontWeight: "900"
  },
  reminderConfirm: {
    flex: 1,
    height: 48,
    borderRadius: 24,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(255,255,255,0.88)"
  },
  reminderConfirmText: {
    color: "#171b27",
    fontSize: 16,
    fontWeight: "900"
  },
  nativeProfileLayer: {
    position: "absolute",
    top: 0,
    right: 0,
    bottom: 0,
    left: 0,
    zIndex: 80,
    backgroundColor: "#000"
  },
  nativeProfileStatus: {
    position: "absolute",
    top: 22,
    left: 30,
    right: 16,
    zIndex: 2,
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center"
  },
  nativeTime: {
    overflow: "hidden",
    borderRadius: 18,
    paddingHorizontal: 16,
    paddingVertical: 4,
    color: "#fff",
    backgroundColor: "#ff454b",
    fontSize: 22,
    fontWeight: "900"
  },
  nativeSignal: {
    color: "#fff",
    fontSize: 25,
    fontWeight: "900",
    letterSpacing: 2
  },
  nativeProfileSheet: {
    flex: 1,
    marginTop: 54,
    paddingTop: 88,
    paddingHorizontal: 26,
    backgroundColor: "#f8f7fb",
    borderTopLeftRadius: 24,
    borderTopRightRadius: 24
  },
  nativeProfileClose: {
    position: "absolute",
    right: 24,
    top: 74,
    zIndex: 3
  },
  nativeProfileCloseText: {
    color: "#1d1e24",
    fontSize: 44
  },
  nativeProfileMini: {
    position: "absolute",
    left: 26,
    top: 72,
    flexDirection: "row",
    gap: 24
  },
  nativeProfileIconButton: {
    width: 42,
    height: 42,
    alignItems: "center",
    justifyContent: "center"
  },
  nativeProfileMiniText: {
    color: "#24252a",
    fontSize: 28
  },
  nativeProfileHero: {
    marginTop: 210,
    marginBottom: 34,
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center"
  },
  nativeProfileName: {
    color: "#000",
    fontSize: 38,
    fontWeight: "900"
  },
  nativeProfileSub: {
    marginTop: 12,
    color: "#8d8b96",
    fontSize: 22,
    fontWeight: "900"
  },
  nativeProfilePersona: {
    marginTop: 8,
    color: "#a8a7b0",
    fontSize: 14,
    fontWeight: "800"
  },
  nativeAvatar: {
    width: 88,
    height: 88,
    borderRadius: 44,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(255,255,255,0.58)"
  },
  nativeAvatarText: {
    fontSize: 48
  },
  nativePlus: {
    height: 70,
    borderRadius: 12,
    paddingHorizontal: 18,
    marginBottom: 28,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    backgroundColor: "#222a34"
  },
  nativePlusTitle: {
    color: "#fff",
    fontSize: 27,
    fontWeight: "900"
  },
  nativePlusSub: {
    color: "rgba(255,255,255,0.56)",
    fontSize: 16,
    fontWeight: "800"
  },
  nativeMemberPill: {
    height: 36,
    borderRadius: 18,
    paddingHorizontal: 14,
    justifyContent: "center",
    backgroundColor: "#e3bf53"
  },
  nativeMemberText: {
    color: "#171717",
    fontSize: 17,
    fontWeight: "900"
  },
  nativeProfileTiles: {
    flexDirection: "row",
    justifyContent: "space-between",
    gap: 66,
    marginBottom: 20
  },
  nativeProfileTile: {
    flex: 1,
    height: 96,
    borderRadius: 14,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "#d8d8d8"
  },
  nativeProfileTileText: {
    color: "#1a1c20",
    fontSize: 25,
    textAlign: "center",
    fontWeight: "900"
  },
  nativeWatch: {
    height: 62,
    borderRadius: 16,
    paddingHorizontal: 18,
    flexDirection: "row",
    alignItems: "center",
    gap: 18,
    backgroundColor: "#fff"
  },
  nativeWatchBox: {
    color: "#cbd7e5",
    fontSize: 24
  },
  nativeWatchTitle: {
    color: "#1a1c20",
    fontSize: 22,
    fontWeight: "900"
  },
  nativeWatchSub: {
    color: "#b3b1bc",
    fontSize: 16,
    fontWeight: "900"
  },
  nativeWatchArrow: {
    marginLeft: "auto",
    color: "#aaa",
    fontSize: 32
  },
  profilePanelLayer: {
    position: "absolute",
    top: 0,
    right: 0,
    bottom: 0,
    left: 0,
    zIndex: 30,
    justifyContent: "flex-end"
  },
  profilePanelBackdrop: {
    position: "absolute",
    top: 0,
    right: 0,
    bottom: 0,
    left: 0,
    backgroundColor: "rgba(18,20,28,0.30)"
  },
  profilePanel: {
    maxHeight: "68%",
    borderTopLeftRadius: 28,
    borderTopRightRadius: 28,
    paddingTop: 20,
    paddingHorizontal: 22,
    paddingBottom: 28,
    backgroundColor: "#fff"
  },
  profilePanelHeader: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    marginBottom: 12
  },
  profilePanelTitle: {
    color: "#111827",
    fontSize: 24,
    fontWeight: "900"
  },
  profilePanelClose: {
    color: "#24252a",
    fontSize: 30,
    fontWeight: "600"
  },
  profilePanelScroll: {
    maxHeight: 430
  },
  profilePanelScrollContent: {
    paddingBottom: 8
  },
  profilePanelRow: {
    minHeight: 66,
    borderRadius: 18,
    paddingHorizontal: 16,
    paddingVertical: 12,
    marginTop: 10,
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
    backgroundColor: "#f7f6fb"
  },
  profilePanelDot: {
    width: 9,
    height: 9,
    borderRadius: 5,
    backgroundColor: "#cfd4dd"
  },
  profilePanelDotUnread: {
    backgroundColor: "#7d5cff"
  },
  profilePanelCopy: {
    flex: 1
  },
  profilePanelRowTitle: {
    color: "#1d2330",
    fontSize: 16,
    fontWeight: "900"
  },
  profilePanelRowBody: {
    flex: 1,
    marginTop: 3,
    color: "#6f7684",
    fontSize: 13,
    lineHeight: 18,
    fontWeight: "700"
  },
  profileNameInput: {
    height: 54,
    borderRadius: 18,
    paddingHorizontal: 16,
    color: "#111827",
    backgroundColor: "#f2f0f8",
    fontSize: 20,
    fontWeight: "800"
  },
  profilePanelHint: {
    marginTop: 10,
    color: "#8b90a0",
    fontSize: 13,
    lineHeight: 19,
    fontWeight: "700"
  },
  profilePanelPrimary: {
    height: 50,
    marginTop: 18,
    borderRadius: 25,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "#202633"
  },
  profilePanelPrimaryText: {
    color: "#fff",
    fontSize: 17,
    fontWeight: "900"
  },
  profileStampGrid: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 12
  },
  profileStampItem: {
    width: "47%",
    minHeight: 238,
    borderRadius: 18,
    alignItems: "center",
    paddingHorizontal: 12,
    paddingTop: 14,
    paddingBottom: 12,
    backgroundColor: "#f7f8fb",
    borderWidth: 1,
    borderColor: "rgba(120,132,150,0.14)",
    shadowColor: "#7d8590",
    shadowOpacity: 0.12,
    shadowRadius: 12,
    shadowOffset: { width: 0, height: 7 }
  },
  profileStampItemLocked: {
    opacity: 0.55
  },
  profileStampGlyph: {
    position: "absolute",
    top: 32,
    color: "rgba(255,255,255,0.95)",
    fontSize: 24,
    fontWeight: "900"
  },
  profileStampImage: {
    width: 112,
    height: 150,
    marginTop: 4
  },
  profileStampCode: {
    alignSelf: "stretch",
    color: "#7b8490",
    fontSize: 9,
    letterSpacing: 0.4,
    fontWeight: "900"
  },
  profileStampMonth: {
    position: "absolute",
    top: 12,
    right: 10,
    overflow: "hidden",
    borderRadius: 10,
    paddingHorizontal: 7,
    paddingVertical: 3,
    color: "#59626a",
    backgroundColor: "rgba(255,255,255,0.76)",
    fontSize: 9,
    fontWeight: "900"
  },
  profileStampTitle: {
    marginTop: 8,
    color: "#1d2330",
    fontSize: 16,
    fontWeight: "900"
  },
  profileStampRule: {
    marginTop: 6,
    color: "#707785",
    fontSize: 12,
    lineHeight: 17,
    textAlign: "center",
    fontWeight: "700"
  },
  nativeToday: {
    flex: 1,
    backgroundColor: "transparent"
  },
  nativeTodayScroll: {
    flex: 1
  },
  nativeTodayContent: {
    paddingTop: 56,
    paddingHorizontal: UI.spacing.pageX,
    paddingBottom: 238,
    minHeight: 900,
    position: "relative"
  },
  todayNavRail: {
    position: "relative",
    height: 76,
    marginHorizontal: -18,
    marginBottom: 7
  },
  todayNavContent: {
    paddingHorizontal: 42,
    gap: 10,
    alignItems: "center"
  },
  todayNavFade: {
    position: "absolute",
    top: 0,
    bottom: 0,
    width: 36,
    zIndex: 6,
    overflow: "hidden"
  },
  todayNavFadeLeft: {
    left: 0
  },
  todayNavFadeRight: {
    right: 0
  },
  todayNavFadeSegment: {
    position: "absolute",
    top: 0,
    bottom: 0,
    width: 10,
    backgroundColor: UI.colors.pageBg
  },
  todayNavCircle: {
    width: UI.sizes.todayNavCircle,
    height: UI.sizes.todayNavCircle,
    borderRadius: UI.sizes.todayNavCircle / 2,
    alignItems: "center",
    justifyContent: "center",
    overflow: "visible",
    backgroundColor: UI.colors.surface,
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.92)",
    shadowColor: "#d9d7dc",
    shadowOpacity: 0.22,
    shadowRadius: 12,
    shadowOffset: { width: 0, height: 6 }
  },
  todayNavCircleActive: {
    backgroundColor: "#e7f3ff",
    shadowColor: "#b7d8ff",
    shadowOpacity: 0.48,
    shadowRadius: 18,
    shadowOffset: { width: 0, height: 8 },
    borderColor: "rgba(255,255,255,0.98)"
  },
  todayNavAlertDot: {
    position: "absolute",
    top: 9,
    right: 10,
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: UI.colors.danger
  },
  todayNavLabel: {
    color: UI.colors.textSecondary,
    ...UI.type.chip
  },
  todayNavLabelActive: {
    color: "#5f6570"
  },
  todayNavValue: {
    marginTop: 3,
    color: UI.colors.textPrimary,
    fontSize: 17,
    lineHeight: 21,
    fontWeight: "900",
    maxWidth: 54
  },
  todayNavValueActive: {
    color: "#111826"
  },
  todayArtworkCard: {
    width: "100%",
    borderRadius: 34,
    overflow: "hidden",
    backgroundColor: UI.colors.pageBg,
    shadowColor: "#756b70",
    shadowOpacity: 0.30,
    shadowRadius: 28,
    shadowOffset: { width: 0, height: 18 },
    elevation: 12
  },
  todayArtworkPressable: {
    width: "100%"
  },
  todayArtworkActionHit: {
    position: "absolute",
    left: "24%",
    right: "24%",
    bottom: "5.5%",
    height: 58,
    borderRadius: 29
  },
  todayArtworkImage: {
    width: "100%"
  },
  todayArtworkImageRadius: {
    borderRadius: 34
  },
  todayArtworkMoreButton: {
    position: "absolute",
    top: 20,
    right: 22,
    width: 42,
    height: 32,
    borderRadius: 16,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(255,255,255,0.22)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.45)"
  },
  todayArtworkMoreText: {
    color: "#fff",
    fontSize: 16,
    lineHeight: 18,
    fontWeight: "900",
    letterSpacing: 1
  },
  todayArtworkFocusAdjustHit: {
    position: "absolute",
    top: "53%",
    width: 80,
    height: 78,
    borderRadius: 39
  },
  todayArtworkFocusAdjustLeft: {
    left: "4%"
  },
  todayArtworkFocusAdjustRight: {
    right: "4%"
  },
  todayArtworkSubtitlePatch: {
    position: "absolute",
    left: 31,
    right: 128,
    top: 49,
    minHeight: 54,
    borderRadius: 10,
    justifyContent: "center",
    backgroundColor: "rgba(247,191,119,1)"
  },
  todayArtworkSubtitleText: {
    color: "#fff",
    fontSize: 16,
    lineHeight: 22,
    fontWeight: "900"
  },
  todaySleepTimeRemovalPatch: {
    position: "absolute",
    left: 28,
    right: 28,
    top: "55%",
    height: "22%",
    borderRadius: 34,
    backgroundColor: "rgba(222,216,216,0.98)"
  },
  todayArtworkPulseDot: {
    position: "absolute",
    left: "52%",
    top: "56%",
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: "#9b7cff",
    shadowColor: "#9b7cff",
    shadowOpacity: 0.42,
    shadowRadius: 12,
    shadowOffset: { width: 0, height: 0 }
  },
  todayMainCard: {
    minHeight: 584,
    borderRadius: 36,
    padding: 24,
    position: "relative",
    overflow: "hidden",
    shadowColor: "#d2cbd1",
    shadowOpacity: 0.28,
    shadowRadius: 18,
    shadowOffset: { width: 0, height: 12 }
  },
  todayMainCardSleep: {
    minHeight: 584,
    paddingVertical: 22
  },
  todayLayeredPressable: {
    zIndex: 4
  },
  todayCard_energy: {
    backgroundColor: "transparent"
  },
  todayCard_sleep: {
    backgroundColor: "transparent"
  },
  todayCard_cycle: {
    backgroundColor: "transparent"
  },
  todayCard_focus: {
    backgroundColor: "transparent"
  },
  todayCard_metabolism: {
    backgroundColor: "transparent"
  },
  todayCard_morning: {
    backgroundColor: "transparent"
  },
  todayToneBase: {
    position: "absolute",
    top: 0,
    right: 0,
    bottom: 0,
    left: 0
  },
  todayToneTopWash: {
    position: "absolute",
    top: 0,
    left: 0,
    right: 0,
    height: 218,
    opacity: 0.82
  },
  todayToneBottomGlow: {
    position: "absolute",
    left: -18,
    right: -18,
    bottom: -18,
    height: 176,
    borderTopLeftRadius: 120,
    borderTopRightRadius: 120,
    opacity: 0.88
  },
  todayToneBottomGlowStrong: {
    position: "absolute",
    left: 42,
    right: 42,
    bottom: -10,
    height: 78,
    borderTopLeftRadius: 80,
    borderTopRightRadius: 80,
    opacity: 0.72
  },
  todayCardHeader: {
    minHeight: 124,
    flexDirection: "row",
    justifyContent: "space-between",
    gap: 12,
    zIndex: 4
  },
  todayCardHeaderCopy: {
    flex: 1
  },
  todayCardTitle: {
    color: "#fff",
    fontSize: 39,
    lineHeight: 44,
    fontWeight: "900"
  },
  todayCycleTitleRow: {
    minHeight: 52,
    flexDirection: "row",
    alignItems: "flex-end",
    gap: 5
  },
  todayCycleTitleDay: {
    color: "#9b7cff",
    fontSize: 40,
    lineHeight: 46,
    fontWeight: "900"
  },
  todayCycleTitleUnit: {
    color: "#142033",
    fontSize: 19,
    lineHeight: 28,
    fontWeight: "900"
  },
  todayCardSubtitle: {
    maxWidth: 286,
    marginTop: 8,
    color: "rgba(255,255,255,0.90)",
    fontSize: 15,
    lineHeight: 21,
    fontWeight: "800"
  },
  todayMorePill: {
    minWidth: 70,
    height: 36,
    borderRadius: 18,
    alignItems: "center",
    justifyContent: "center",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.52)"
  },
  todayMoreText: {
    color: "#fff",
    fontSize: 16,
    fontWeight: "900"
  },
  todaySunVisual: {
    position: "relative",
    height: 228,
    justifyContent: "flex-start",
    zIndex: 4
  },
  todayDotMatrixScore: {
    position: "absolute",
    top: 4,
    left: 0,
    right: 0
  },
  todayDotScore: {
    color: "#fff",
    fontSize: 68,
    lineHeight: 72,
    textAlign: "center",
    fontWeight: "900"
  },
  todayDotSub: {
    position: "absolute",
    top: 74,
    left: 0,
    right: 0,
    color: "#fff",
    fontSize: 18,
    textAlign: "center",
    marginTop: 2
  },
  todaySunArc: {
    position: "absolute",
    left: 58,
    right: 58,
    top: 116,
    height: 76,
    borderTopWidth: 4,
    borderLeftWidth: 4,
    borderRightWidth: 4,
    borderColor: "#fff",
    borderTopLeftRadius: 120,
    borderTopRightRadius: 120
  },
  todaySunDot: {
    position: "absolute",
    width: 18,
    height: 18,
    borderRadius: 9,
    backgroundColor: "#fff"
  },
  todaySunHorizon: {
    position: "absolute",
    left: 18,
    right: 18,
    top: 188,
    height: 2,
    backgroundColor: "rgba(255,255,255,0.55)"
  },
  todaySunTime: {
    position: "absolute",
    bottom: 4,
    color: "#fff",
    fontSize: 20,
    lineHeight: 24,
    textAlign: "center"
  },
  todaySleepVisual: {
    height: 246,
    justifyContent: "flex-start",
    zIndex: 4
  },
  todaySleepPanel: {
    height: 62,
    borderRadius: 22,
    paddingHorizontal: 16,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    backgroundColor: "rgba(255,255,255,0.16)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.22)"
  },
  todaySleepTotalRow: {
    flexDirection: "row",
    alignItems: "flex-end"
  },
  todaySleepHourUnit: {
    color: "#fff",
    fontSize: 22,
    marginLeft: 6,
    marginBottom: 2,
    fontWeight: "300"
  },
  todaySleepSmallLabel: {
    marginTop: 4,
    color: "rgba(255,255,255,0.78)",
    fontSize: 11,
    fontWeight: "800"
  },
  todaySleepQuality: {
    alignItems: "flex-end"
  },
  todaySleepQualityLabel: {
    color: "rgba(255,255,255,0.78)",
    fontSize: 13,
    fontWeight: "800"
  },
  todaySleepQualityValue: {
    marginTop: 3,
    color: "#fff",
    fontSize: 20,
    fontWeight: "900"
  },
  todaySleepChart: {
    height: 76,
    marginTop: 8,
    flexDirection: "row",
    alignItems: "flex-end",
    justifyContent: "center",
    gap: 7,
    borderRadius: 18,
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.26)",
    backgroundColor: "rgba(255,255,255,0.12)",
    paddingHorizontal: 18,
    paddingBottom: 10
  },
  todaySleepBar: {
    width: 20,
    borderRadius: 10
  },
  todaySleepAdjustRow: {
    height: 38,
    marginTop: 8,
    paddingHorizontal: 2,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between"
  },
  todaySleepAdjust: {
    width: 52,
    height: 36,
    borderRadius: 18,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(255,255,255,0.88)",
    shadowColor: "#fff",
    shadowOpacity: 0.32,
    shadowRadius: 10,
    shadowOffset: { width: 0, height: 4 }
  },
  todaySleepAdjustText: {
    color: "#19202a",
    fontSize: 25,
    lineHeight: 28,
    fontWeight: "900"
  },
  todaySleepWindowText: {
    color: "rgba(255,255,255,0.76)",
    fontSize: 12,
    fontWeight: "900"
  },
  todaySleepTimeRow: {
    height: 34,
    marginTop: 0,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    gap: 14
  },
  todaySleepTimeDots: {
    color: "#fff",
    fontSize: 16,
    letterSpacing: 3
  },
  todaySleepTimeText: {
    color: "rgba(255,255,255,0.92)",
    fontSize: 16,
    lineHeight: 22,
    fontWeight: "900"
  },
  todaySleepHint: {
    marginTop: 0,
    color: "#eaff66",
    fontSize: 13,
    lineHeight: 18,
    fontWeight: "900"
  },
  todayCycleVisual: {
    height: 258,
    alignItems: "center",
    justifyContent: "center",
    zIndex: 4
  },
  todayCyclePhaseTop: {
    position: "absolute",
    top: 0,
    color: "#101622",
    fontSize: 17,
    lineHeight: 22,
    fontWeight: "900"
  },
  todayCycleDial: {
    width: 244,
    height: 244,
    borderRadius: 122,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(203,213,237,0.62)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.72)"
  },
  todayCycleInner: {
    position: "absolute",
    width: 176,
    height: 176,
    borderRadius: 88,
    backgroundColor: "rgba(209,216,238,0.96)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.52)"
  },
  todayCycleDay: {
    position: "absolute",
    width: 22,
    height: 22,
    borderRadius: 6,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(255,255,255,0.22)"
  },
  todayCycleDay_period: {
    backgroundColor: "#ed2d91"
  },
  todayCycleDay_ovulation: {
    backgroundColor: "rgba(165,128,226,0.72)"
  },
  todayCycleDay_active: {
    width: 34,
    height: 34,
    borderRadius: 8,
    backgroundColor: "rgba(171,128,229,0.76)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.62)"
  },
  todayCycleDayText: {
    color: "#fff",
    fontSize: 11,
    lineHeight: 13,
    fontWeight: "900"
  },
  todayCycleDayText_active: {
    fontSize: 18,
    lineHeight: 22
  },
  todayCycleOrb: {
    position: "absolute",
    borderWidth: 3,
    borderColor: "#f02e91",
    backgroundColor: "rgba(255,255,255,0.70)"
  },
  todayCycleOrb_large: {
    left: 54,
    top: 104,
    width: 38,
    height: 38,
    borderRadius: 19,
    backgroundColor: "rgba(240,46,145,0.42)"
  },
  todayCycleOrb_a: {
    right: 54,
    top: 76,
    width: 38,
    height: 38,
    borderRadius: 19
  },
  todayCycleOrb_b: {
    right: 44,
    top: 130,
    width: 34,
    height: 34,
    borderRadius: 17
  },
  todayCycleOrb_c: {
    left: 112,
    bottom: 44,
    width: 30,
    height: 30,
    borderRadius: 15
  },
  todayCycleCurrentBadge: {
    position: "absolute",
    bottom: -14,
    width: 58,
    height: 42,
    borderRadius: 10,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(178,132,225,0.80)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.52)"
  },
  todayCycleCurrentText: {
    color: "#fff",
    fontSize: 26,
    lineHeight: 30,
    fontWeight: "900"
  },
  todayCyclePhaseLabel: {
    position: "absolute",
    color: "#8f6eff",
    fontSize: 17,
    lineHeight: 22,
    fontWeight: "900"
  },
  todayCyclePhaseLeft: {
    left: 0,
    top: 122
  },
  todayCyclePhaseRight: {
    right: 0,
    top: 136
  },
  todayCyclePhaseBottom: {
    bottom: 0,
    color: "#121212"
  },
  todayFocusVisual: {
    height: 244,
    justifyContent: "center",
    zIndex: 4
  },
  todayFocusShapeWrap: {
    position: "absolute",
    alignSelf: "center",
    top: 22,
    width: 168,
    height: 142,
    opacity: 0.18,
    transform: [{ rotate: "-45deg" }]
  },
  todayFocusShapeLobeLeft: {
    position: "absolute",
    left: 0,
    top: 28,
    width: 92,
    height: 92,
    borderRadius: 46,
    backgroundColor: "#ffffff"
  },
  todayFocusShapeLobeRight: {
    position: "absolute",
    right: 0,
    top: 28,
    width: 92,
    height: 92,
    borderRadius: 46,
    backgroundColor: "#ffffff"
  },
  todayFocusShapePoint: {
    position: "absolute",
    left: 38,
    top: 70,
    width: 92,
    height: 92,
    borderRadius: 18,
    backgroundColor: "#ffffff"
  },
  todayFocusDotRow: {
    flexDirection: "row",
    justifyContent: "center",
    alignItems: "flex-end",
    gap: 16
  },
  todayFocusUnit: {
    color: "#fff",
    fontSize: 30,
    lineHeight: 34,
    fontWeight: "900"
  },
  todayFocusTicks: {
    height: 106,
    marginTop: 26,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    gap: 9
  },
  todayFocusTick: {
    width: 5,
    height: 52,
    borderRadius: 3,
    backgroundColor: "rgba(255,255,255,0.78)"
  },
  todayFocusTickActive: {
    height: 88,
    backgroundColor: "#f2df47"
  },
  todayFocusRange: {
    flexDirection: "row",
    justifyContent: "space-between",
    paddingHorizontal: 10
  },
  todayFocusAdjust: {
    width: 62,
    height: 42,
    overflow: "hidden",
    borderRadius: 21,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(255,255,255,0.84)"
  },
  todayFocusAdjustText: {
    color: "#1f2430",
    fontSize: 28,
    lineHeight: 31,
    fontWeight: "900"
  },
  todayFocusHint: {
    marginTop: 22,
    color: "#656a72",
    fontSize: 15,
    lineHeight: 22,
    textAlign: "center",
    fontWeight: "900"
  },
  todayMetabolismVisual: {
    position: "relative",
    height: 244,
    justifyContent: "center",
    zIndex: 4
  },
  todayMetabolismValue: {
    color: "#fff",
    fontSize: 72,
    lineHeight: 78,
    fontWeight: "900"
  },
  todayHeartBadge: {
    position: "absolute",
    right: 22,
    top: 60,
    width: 86,
    height: 78,
    borderRadius: 42,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(255,217,88,0.34)"
  },
  todayHeartText: {
    color: "#fff",
    fontSize: 32,
    fontWeight: "900"
  },
  todayMetabolismBar: {
    height: 72,
    borderRadius: 22,
    overflow: "hidden",
    marginTop: 24,
    backgroundColor: "rgba(84,57,22,0.28)"
  },
  todayMetabolismFill: {
    width: "72%",
    height: "100%",
    borderRadius: 22,
    flexDirection: "row",
    alignItems: "center",
    gap: 16,
    paddingLeft: 24,
    backgroundColor: "rgba(255,219,127,0.82)"
  },
  todayMetabolismStripe: {
    width: 10,
    height: 54,
    borderRadius: 6,
    backgroundColor: "rgba(233,147,26,0.45)",
    transform: [{ rotate: "-18deg" }]
  },
  todayMetabolismStats: {
    marginTop: 24,
    flexDirection: "row",
    justifyContent: "space-between"
  },
  todayMorningVisual: {
    height: 244,
    justifyContent: "center",
    zIndex: 4
  },
  todayMorningMap: {
    height: 180,
    alignItems: "center",
    justifyContent: "center"
  },
  todayMorningMapShape: {
    width: 242,
    height: 150,
    borderRadius: 48,
    borderWidth: 1,
    borderColor: "rgba(74,67,58,0.44)",
    backgroundColor: "rgba(255,252,226,0.54)",
    transform: [{ rotate: "-9deg" }]
  },
  todayMorningRoad: {
    position: "absolute",
    width: 7,
    height: 150,
    borderRadius: 4,
    backgroundColor: "rgba(230,188,74,0.88)"
  },
  todayMorningPin: {
    position: "absolute",
    right: 96,
    top: 40,
    width: 30,
    height: 42,
    borderTopLeftRadius: 18,
    borderTopRightRadius: 18,
    borderBottomLeftRadius: 18,
    backgroundColor: "#edd857",
    transform: [{ rotate: "45deg" }]
  },
  todayMorningGlow: {
    position: "absolute",
    right: 82,
    top: 34,
    width: 64,
    height: 64,
    borderRadius: 32,
    backgroundColor: "rgba(238,216,76,0.62)"
  },
  todayMorningSunBeam: {
    position: "absolute",
    right: 62,
    top: 20,
    width: 7,
    height: 150,
    borderRadius: 4,
    backgroundColor: "rgba(255,228,97,0.72)",
    transform: [{ rotate: "-4deg" }]
  },
  todayMorningPlace: {
    position: "absolute",
    left: 54,
    bottom: 34,
    color: "#706b62",
    fontSize: 15,
    fontWeight: "900"
  },
  todayMorningStats: {
    marginTop: 8,
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "flex-end"
  },
  todayMorningKm: {
    color: "#302724",
    fontSize: 52,
    lineHeight: 58,
    fontWeight: "400"
  },
  todayMorningMeta: {
    color: "#302724",
    fontSize: 15,
    lineHeight: 24,
    textAlign: "right"
  },
  todayCardAction: {
    alignSelf: "center",
    minWidth: 238,
    height: 52,
    borderRadius: 26,
    alignItems: "center",
    justifyContent: "center",
    paddingHorizontal: 24,
    backgroundColor: "rgba(255,255,255,0.68)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.82)",
    zIndex: 5,
    shadowColor: "#aeeeff",
    shadowOpacity: 0.32,
    shadowRadius: 22,
    shadowOffset: { width: 0, height: 8 }
  },
  todayCardActionText: {
    color: "#1a202b",
    fontSize: 20,
    fontWeight: "900"
  },
  todayMonitorCard: {
    width: "72%",
    height: 104,
    marginTop: 20,
    marginBottom: 156,
    marginLeft: 18,
    borderRadius: 20,
    paddingHorizontal: 22,
    paddingVertical: 14,
    backgroundColor: "#d8d8d8"
  },
  todayMonitorTitle: {
    color: "#121212",
    fontSize: 20,
    fontWeight: "900"
  },
  todayMonitorCopy: {
    marginTop: 8,
    color: "#5b6067",
    fontSize: 14,
    lineHeight: 19,
    fontWeight: "800"
  },
  energyChatPreview: {
    width: "84%",
    minHeight: 122,
    marginTop: 16,
    marginBottom: 142,
    marginLeft: 14,
    borderRadius: UI.radius.card,
    padding: 12,
    backgroundColor: "rgba(255,255,255,0.46)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.72)",
    shadowColor: "#c8c3c2",
    shadowOpacity: 0.26,
    shadowRadius: 18,
    shadowOffset: { width: 0, height: 10 }
  },
  energyChatPreviewMain: {
    borderRadius: 22,
    paddingHorizontal: 16,
    paddingVertical: 14,
    backgroundColor: "rgba(225,225,225,0.60)"
  },
  energyChatPreviewTop: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    marginBottom: 8
  },
  energyChatPreviewKicker: {
    color: UI.colors.textSecondary,
    ...UI.type.caption
  },
  energyChatPreviewBadge: {
    height: 24,
    overflow: "hidden",
    borderRadius: 12,
    paddingHorizontal: 10,
    paddingTop: 4,
    color: UI.colors.accent,
    backgroundColor: UI.colors.accentSoft,
    ...UI.type.chip
  },
  energyChatPreviewTitle: {
    color: UI.colors.textPrimary,
    ...UI.type.sectionTitle
  },
  energyChatPreviewCopy: {
    marginTop: 8,
    color: UI.colors.textSecondary,
    ...UI.type.bodyStrong
  },
  energyChatPreviewHint: {
    marginTop: 10,
    color: UI.colors.accent,
    ...UI.type.caption
  },
  energyLiveList: {
    width: "100%",
    marginTop: 14,
    gap: 12
  },
  energyLiveCard: {
    height: 214,
    borderRadius: 28,
    overflow: "hidden",
    backgroundColor: "rgba(255,255,255,0.34)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.58)",
    shadowColor: "#8c8580",
    shadowOpacity: 0.22,
    shadowRadius: 22,
    shadowOffset: { width: 0, height: 12 }
  },
  energyLiveImage: {
    flex: 1,
    justifyContent: "flex-end"
  },
  energyLiveImageRadius: {
    borderRadius: 28
  },
  energyLiveMeta: {
    paddingHorizontal: 18,
    paddingBottom: 70
  },
  energyLiveKicker: {
    color: "rgba(255,255,255,0.76)",
    ...UI.type.caption
  },
  energyLiveTitle: {
    marginTop: 5,
    color: "#fff",
    ...UI.type.sectionTitle
  },
  energyLiveCopy: {
    marginTop: 4,
    color: "rgba(255,255,255,0.84)",
    ...UI.type.caption
  },
  energyLiveActions: {
    position: "absolute",
    left: 14,
    right: 14,
    bottom: 14,
    flexDirection: "row",
    gap: 10
  },
  energyLiveSound: {
    height: 42,
    borderRadius: 21,
    paddingHorizontal: 18,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(255,255,255,0.20)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.35)"
  },
  energyLiveSoundText: {
    color: "#fff",
    ...UI.type.chip
  },
  energyLiveBreath: {
    flex: 1,
    height: 42,
    borderRadius: 21,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(255,255,255,0.92)"
  },
  energyLiveBreathText: {
    color: UI.colors.textPrimary,
    ...UI.type.bodyStrong
  },
  todayInlineEmpty: {
    width: "100%",
    marginTop: 14,
    borderRadius: 24,
    padding: 18,
    backgroundColor: "rgba(255,255,255,0.46)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.72)"
  },
  todayInlineEmptyTitle: {
    color: UI.colors.textPrimary,
    ...UI.type.bodyStrong
  },
  todayInlineEmptyCopy: {
    marginTop: 6,
    color: UI.colors.textSecondary,
    ...UI.type.caption
  },
  todayInlineChat: {
    width: "100%",
    marginTop: 14,
    gap: 10
  },
  todayInlineBubble: {
    maxWidth: "84%",
    alignSelf: "flex-start",
    minHeight: 42,
    borderRadius: 21,
    paddingHorizontal: 15,
    paddingVertical: 10,
    backgroundColor: "rgba(244,244,244,0.90)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.78)"
  },
  todayInlineBubbleUser: {
    alignSelf: "flex-end",
    backgroundColor: "rgba(255,255,255,0.82)"
  },
  todayInlineBubbleText: {
    color: UI.colors.textPrimary,
    ...UI.type.body
  },
  todayComposerDock: {
    position: "absolute",
    left: 24,
    right: 24,
    bottom: 86,
    height: 58,
    zIndex: 260,
    elevation: 260
  },
  todayComposerCircle: {
    width: 58,
    height: 58,
    borderRadius: 29,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(18,21,24,0.70)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.24)"
  },
  todayComposerCircleIdle: {
    backgroundColor: "rgba(18,21,24,0.38)"
  },
  todayComposerCircleText: {
    color: "#fff",
    fontSize: 30,
    lineHeight: 32,
    fontWeight: "800"
  },
  todayComposerSendText: {
    color: "#fff",
    fontSize: 28,
    lineHeight: 30,
    fontWeight: "900"
  },
  todayComposerInputWrap: {
    flex: 1,
    height: 58,
    borderRadius: 29,
    paddingLeft: 20,
    paddingRight: 8,
    flexDirection: "row",
    alignItems: "center",
    gap: 8,
    overflow: "hidden",
    backgroundColor: "rgba(18,21,24,0.58)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.24)",
    shadowColor: "#000",
    shadowOpacity: 0.24,
    shadowRadius: 18,
    shadowOffset: { width: 0, height: 9 }
  },
  todayComposerInput: {
    flex: 1,
    height: "100%",
    minWidth: 0,
    paddingVertical: 0,
    zIndex: 2,
    color: "#fff",
    ...UI.type.bodyStrong
  },
  todayComposerInlineButton: {
    zIndex: 3,
    width: 42,
    height: 42,
    borderRadius: 21,
    alignItems: "center",
    justifyContent: "center",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.22)",
    backgroundColor: "rgba(255,255,255,0.10)"
  },
  todayComposerInlinePlus: {
    color: "#fff",
    fontSize: 24,
    lineHeight: 26,
    fontWeight: "900"
  },
  todayComposerInlineSend: {
    zIndex: 3,
    width: 42,
    height: 42,
    borderRadius: 21,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(255,255,255,0.90)"
  },
  todayComposerInlineSendIdle: {
    backgroundColor: "rgba(255,255,255,0.18)"
  },
  todayComposerInlineSendText: {
    color: "#111827",
    fontSize: 22,
    lineHeight: 24,
    fontWeight: "900"
  },
  energyChatActions: {
    marginTop: 10,
    flexDirection: "row",
    gap: 8,
    flexWrap: "wrap"
  },
  energyChatActionChip: {
    minHeight: 36,
    borderRadius: 18,
    paddingHorizontal: 12,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(245,245,245,0.92)",
    borderWidth: 1,
    borderColor: "rgba(220,220,220,0.90)"
  },
  energyChatActionPrimary: {
    backgroundColor: UI.colors.textPrimary,
    borderColor: UI.colors.textPrimary
  },
  energyChatActionText: {
    color: UI.colors.textPrimary,
    ...UI.type.chip
  },
  energyChatActionPrimaryText: {
    color: "#fff"
  },
  energyRecordPanel: {
    marginTop: 12,
    borderRadius: 22,
    padding: 14,
    backgroundColor: "rgba(255,255,255,0.72)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.90)"
  },
  energyRecordKicker: {
    color: UI.colors.accent,
    ...UI.type.caption
  },
  energyRecordTitle: {
    marginTop: 4,
    color: UI.colors.textPrimary,
    ...UI.type.bodyStrong
  },
  energyRecordCopy: {
    marginTop: 6,
    color: UI.colors.textSecondary,
    ...UI.type.caption
  },
  energyRecordActions: {
    marginTop: 10,
    flexDirection: "row",
    gap: 8,
    flexWrap: "wrap"
  },
  energyRecordOption: {
    minHeight: 34,
    borderRadius: 17,
    paddingHorizontal: 12,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(17,24,39,0.92)"
  },
  energyRecordOptionText: {
    color: "#fff",
    ...UI.type.chip
  },
  todayReferenceOverlay: {
    position: "absolute",
    top: -82,
    left: -18,
    right: -18,
    height: 852,
    zIndex: 30
  },
  todayReferenceImage: {
    opacity: 1
  },
  todayReferenceOverlayImage: {
    width: "100%",
    height: "100%"
  },
  todayReferenceControls: {
    position: "absolute",
    right: 18,
    bottom: 132,
    flexDirection: "row",
    gap: 8,
    zIndex: 40
  },
  todayReferenceButton: {
    minWidth: 46,
    height: 32,
    borderRadius: 16,
    alignItems: "center",
    justifyContent: "center",
    paddingHorizontal: 10,
    backgroundColor: "rgba(16,18,22,0.72)"
  },
  todayReferenceButtonActive: {
    backgroundColor: "rgba(118,138,255,0.88)"
  },
  todayReferenceButtonText: {
    color: "#fff",
    fontSize: 12,
    fontWeight: "900"
  },
  sessionDotClock: {
    marginTop: 18
  },
  sessionPage: {
    flex: 1,
    paddingTop: 58,
    paddingHorizontal: 24,
    overflow: "hidden"
  },
  sessionCenter: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center"
  },
  sessionLargeClock: {
    marginTop: 30
  },
  sessionCopy: {
    marginTop: 24,
    color: "rgba(28,32,38,0.72)",
    fontSize: 18,
    lineHeight: 28,
    textAlign: "center",
    fontWeight: "800"
  },
  sessionHeart: {
    width: 138,
    height: 124,
    borderRadius: 62,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(255,214,91,0.48)"
  },
  sessionHeartText: {
    color: "#fff",
    fontSize: 42,
    fontWeight: "900"
  },
  sessionFocusOrb: {
    width: 132,
    height: 132,
    borderRadius: 66,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(255,255,255,0.24)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.42)"
  },
  sessionFocusText: {
    color: "#fff",
    fontSize: 48,
    fontWeight: "900"
  },
  sessionCompleteButton: {
    height: 58,
    borderRadius: 29,
    alignItems: "center",
    justifyContent: "center",
    marginBottom: 34,
    backgroundColor: "rgba(255,255,255,0.94)"
  },
  sessionCompleteText: {
    color: "#18202a",
    fontSize: 19,
    fontWeight: "900"
  },
  morningGuidePage: {
    backgroundColor: "#eee3df"
  },
  morningGuideMap: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center"
  },
  morningGuideBeam: {
    position: "absolute",
    width: 10,
    height: 250,
    borderRadius: 5,
    backgroundColor: "rgba(255,224,86,0.62)",
    transform: [{ rotate: "-6deg" }]
  },
  morningGuideLabel: {
    position: "absolute",
    bottom: 96,
    color: "#352b28",
    fontSize: 18,
    fontWeight: "900"
  },
  breathPractice: {
    flex: 1,
    paddingTop: 58,
    paddingHorizontal: 24,
    overflow: "hidden",
    backgroundColor: "#eef5f1"
  },
  breathPracticeExpanded: {
    paddingTop: 36
  },
  breathMistOrb: {
    position: "absolute",
    top: 118,
    alignSelf: "center",
    width: 330,
    height: 330,
    borderRadius: 165,
    backgroundColor: "rgba(255,255,255,0.16)",
    shadowColor: "#ffffff",
    shadowOpacity: 0.36,
    shadowRadius: 70,
    shadowOffset: { width: 0, height: 0 }
  },
  breathHeader: {
    height: 62,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between"
  },
  breathBack: {
    width: 52,
    height: 52,
    borderRadius: 26,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(255,255,255,0.72)"
  },
  breathBackText: {
    color: "#263030",
    fontSize: 38,
    marginTop: -4
  },
  breathTitle: {
    color: "#172222",
    fontSize: 22,
    fontWeight: "900"
  },
  breathEnergyPill: {
    height: 44,
    minWidth: 148,
    borderRadius: 22,
    paddingHorizontal: 16,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(255,255,255,0.24)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.28)"
  },
  breathEnergyPillText: {
    color: "#fff",
    ...UI.type.caption
  },
  breathExpandText: {
    color: "#fff",
    fontSize: 26,
    lineHeight: 28,
    fontWeight: "900"
  },
  breathOrb: {
    width: 230,
    height: 230,
    borderRadius: 115,
    alignSelf: "center",
    alignItems: "center",
    justifyContent: "center",
    marginTop: 116,
    backgroundColor: "rgba(255,255,255,0.52)",
    shadowColor: "#9ed7b8",
    shadowOpacity: 0.36,
    shadowRadius: 42,
    shadowOffset: { width: 0, height: 0 }
  },
  breathOrbInner: {
    width: 132,
    height: 132,
    borderRadius: 66,
    backgroundColor: "rgba(157,215,184,0.50)"
  },
  breathPhase: {
    marginTop: 38,
    color: "#fff",
    fontSize: 30,
    textAlign: "center",
    fontWeight: "900"
  },
  breathCopy: {
    marginTop: 14,
    color: "rgba(255,255,255,0.78)",
    fontSize: 16,
    lineHeight: 24,
    textAlign: "center",
    fontWeight: "700"
  },
  breathBackgroundRail: {
    marginTop: 24,
    flexDirection: "row",
    justifyContent: "center",
    gap: 10
  },
  breathBackgroundChip: {
    height: 36,
    borderRadius: 18,
    paddingHorizontal: 16,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(255,255,255,0.14)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.18)"
  },
  breathBackgroundChipActive: {
    backgroundColor: "rgba(255,255,255,0.28)",
    borderColor: "rgba(255,255,255,0.42)"
  },
  breathBackgroundChipText: {
    color: "#fff",
    ...UI.type.chip
  },
  breathActionRow: {
    position: "absolute",
    left: 24,
    right: 24,
    bottom: 44,
    flexDirection: "row",
    gap: 12
  },
  breathSoundButton: {
    flex: 1,
    height: 56,
    borderRadius: 28,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(255,255,255,0.18)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.28)"
  },
  breathSoundButtonText: {
    color: "#fff",
    fontSize: 17,
    fontWeight: "900"
  },
  breathCompleteInline: {
    flex: 1,
    height: 56,
    borderRadius: 28,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(255,255,255,0.92)"
  },
  breathCompleteInlineText: {
    color: "#172222",
    fontSize: 17,
    fontWeight: "900"
  },
  breathDots: {
    marginTop: 30,
    flexDirection: "row",
    justifyContent: "center",
    gap: 10
  },
  breathDot: {
    width: 9,
    height: 9,
    borderRadius: 5,
    backgroundColor: "rgba(74,88,82,0.22)"
  },
  breathDotActive: {
    backgroundColor: "#57c987"
  },
  breathComplete: {
    position: "absolute",
    left: 40,
    right: 40,
    bottom: 44,
    height: 56,
    borderRadius: 28,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "#172222"
  },
  breathCompleteText: {
    color: "#fff",
    fontSize: 18,
    fontWeight: "900"
  },
  nativeBottom: {
    position: "absolute",
    left: 28,
    right: 28,
    bottom: 16,
    height: UI.sizes.bottomTabHeight,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between"
  },
  nativeBottomBackdrop: {
    position: "absolute",
    left: 0,
    right: 0,
    bottom: 0,
    height: 132
  },
  nativeTabButton: {
    width: UI.sizes.bottomTabButtonWidth,
    height: UI.sizes.bottomTabButtonHeight,
    alignItems: "center",
    justifyContent: "center",
    overflow: "visible",
    shadowColor: "#f5f3df",
    shadowOpacity: 0.12,
    shadowRadius: 10,
    shadowOffset: { width: 0, height: 0 }
  },
  nativeTabActive: {
    shadowColor: "#fff7c7",
    shadowOpacity: 0.58,
    shadowRadius: 20
  },
  nativeTabGlass: {
    ...StyleSheet.absoluteFill,
    borderRadius: UI.sizes.bottomTabButtonHeight / 2,
    overflow: "hidden"
  },
  nativeTabIcon: {
    color: "#fff",
    fontSize: 18
  },
  nativeTabText: {
    color: "#fff",
    fontSize: 13,
    fontWeight: "900"
  },
  nativePlusButton: {
    position: "absolute",
    right: 28,
    bottom: 16,
    width: UI.sizes.bottomPlus,
    height: UI.sizes.bottomPlus,
    borderRadius: UI.sizes.bottomPlus / 2,
    alignItems: "center",
    justifyContent: "center",
    overflow: "hidden",
    backgroundColor: "rgba(28,30,31,0.48)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.20)",
    shadowColor: "#fff6b8",
    shadowOpacity: 0.22,
    shadowRadius: 18,
    shadowOffset: { width: 0, height: 0 }
  },
  nativePlusGlass: {
    ...StyleSheet.absoluteFill,
    borderRadius: UI.sizes.bottomPlus / 2,
    overflow: "hidden"
  },
  nativePlusButtonText: {
    color: "#fff",
    fontSize: 29,
    marginTop: -3
  },
  nativeToast: {
    position: "absolute",
    bottom: 126,
    alignSelf: "center",
    borderRadius: 20,
    paddingHorizontal: 18,
    paddingVertical: 10,
    backgroundColor: "rgba(28,34,34,0.86)"
  },
  nativeToastText: {
    color: "#fff",
    fontSize: 15,
    fontWeight: "900"
  }
});
