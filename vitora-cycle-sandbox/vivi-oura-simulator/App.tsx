import { Asset } from "expo-asset";
import * as FileSystem from "expo-file-system/legacy";
import { StatusBar } from "expo-status-bar";
import {
  AppState,
  AppStateStatus,
  ActivityIndicator,
  Alert,
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

const CACHE_ROOT = `${FileSystem.cacheDirectory ?? ""}vivi-oura-web/`;
const APP_DEMO_QUERY = "openTab=today";
const REMOTE_WEB_BASE_URI = "http://127.0.0.1:8822/vivi-oura-simulator/web/index.html";
const FALLBACK_TRANSPARENT_PNG =
  "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/p9sAAAAASUVORK5CYII=";

type WebAsset = {
  module: number;
  target: string;
};

type NativeTab = "today" | "explore" | "health";
type ExploreRoute = "home" | "detail" | "chat" | "feedback";
type HealthRoute = "home" | "detail";
type HealthDetailTab = "summary" | "sleep" | "cycle" | "focus" | "metabolism" | "morning";
type TodayCardId = "today" | "sleep" | "focus" | "metabolism" | "morning";
type TodayRoute = "home" | "breathing";
type HealthDetailSource = TodayCardId | "cycle" | "health";
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
  tone: "energy" | "sleep" | "focus" | "metabolism" | "morning";
  moreTab: HealthDetailTab;
  monitor: string;
  action: string;
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
  role: "ai" | "user";
  text: string;
};
type HealthStampTone = "amateur" | "sleepers" | "steps" | "gym" | "hours";

const HEALTH_DETAIL_TABS: { id: HealthDetailTab; label: string }[] = [
  { id: "summary", label: "综合" },
  { id: "sleep", label: "睡眠" },
  { id: "cycle", label: "周期" },
  { id: "focus", label: "专注" },
  { id: "metabolism", label: "代谢" },
  { id: "morning", label: "晨间" }
];

const REMINDER_QUICK_TIMES = ["09:30", "13:00", "18:30", "21:30"];
const TODAY_CARDS: TodayCard[] = [
  {
    id: "today",
    label: "今日",
    chipValue: "80%",
    title: "今日能量",
    subtitle: "今日黄体期适合**",
    score: "70",
    tone: "energy",
    moreTab: "summary",
    monitor: "综合今日得分 80%，睡眠拉高恢复窗口，下午适合低刺激推进。",
    action: "开始 4 分钟呼吸"
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
    action: "开始第 1 级睡眠修复"
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
    action: "开始第 1 级专注"
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
    action: "代谢开启"
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
    moreTab: "morning",
    monitor: "晨间启动 +10；自然光和轻走会帮助今天更早进入稳态。",
    action: "打开晨间路线"
  }
];

function SoftGradientBackground({ children }: { children: ReactNode }) {
  return (
    <View style={styles.softGradientBase}>
      <View style={styles.softGradientTop} />
      <View style={styles.softGradientGlow} />
      <View style={styles.softGradientBottom} />
      <View style={styles.softGradientContent}>{children}</View>
    </View>
  );
}

const EXPLORE_THEMES: ExploreTheme[] = [
  {
    id: "relationship",
    tag: "你的关系",
    title: "探索你的关系模式",
    prompt: "今天世界无事发生，可以好好歇着，等一切安静下来",
    image: require("./web/assets/pillowtalk/gallery/moon_full_bleed.png"),
    lead: "想想你是如何与他人建立联系的",
    detailTitle: "探索你的关系模式"
  },
  {
    id: "dream",
    tag: "你的梦想",
    title: "你对其中一个梦有什么印象？",
    prompt: "写下一个梦里留下来的画面",
    image: require("./web/assets/pillowtalk/gallery/saturn_full_bleed.png"),
    lead: "把醒来后仍然清晰的画面留下来",
    detailTitle: "梦境回想"
  },
  {
    id: "thought",
    tag: "你的意识",
    title: "这一刻你反复想到什么？",
    prompt: "把脑海里反复出现的念头放在这里",
    image: require("./web/assets/pillowtalk/gallery/comet_full_bleed.png"),
    lead: "观察那个反复回来的念头",
    detailTitle: "意识线索"
  },
  {
    id: "inspiration",
    tag: "你的灵感",
    title: "哪一句话今天抓住了你？",
    prompt: "保存一句今天让你有感觉的话",
    image: require("./web/assets/pillowtalk/gallery/sky_color_full_bleed.png"),
    lead: "把今天抓住你的句子放在这里",
    detailTitle: "灵感句子"
  }
];

function initialNativeMessages(theme: ExploreTheme): NativeMessage[] {
  return [
    { role: "ai", text: "今天开心不，我陪你聊会儿天，会在合适的时机为你显影情绪 Live 卡片" },
    { role: "user", text: "" },
    { role: "ai", text: theme.id === "relationship" ? "还好呀！你呢，今天和谁的关系最占心思？" : "还好呀！你呢，今天怎么样？" }
  ];
}

function nativeReply(text: string) {
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

export default function App() {
  const webViewRef = useRef<any>(null);
  const [localWebUri, setLocalWebUri] = useState<string | null>(null);
  const [webSourceUri, setWebSourceUri] = useState<string>("");
  const [runtimeQuery, setRuntimeQuery] = useState<string>("");
  const [error, setError] = useState<string | null>(null);
  const [nativeTab, setNativeTab] = useState<NativeTab>("today");
  const [exploreRoute, setExploreRoute] = useState<ExploreRoute>("home");
  const [healthRoute, setHealthRoute] = useState<HealthRoute>("home");
  const [healthDetailTab, setHealthDetailTab] = useState<HealthDetailTab>("summary");
  const [healthDetailSource, setHealthDetailSource] = useState<HealthDetailSource>("health");
  const [todayActiveId, setTodayActiveId] = useState<TodayCardId>("today");
  const [todayRoute, setTodayRoute] = useState<TodayRoute>("home");
  const [focusMinutes, setFocusMinutes] = useState(25);
  const [reminderSheet, setReminderSheet] = useState<ReminderSheetState>(null);
  const [activeThemeId, setActiveThemeId] = useState(EXPLORE_THEMES[0].id);
  const [nativeMessages, setNativeMessages] = useState<NativeMessage[]>(() => initialNativeMessages(EXPLORE_THEMES[0]));
  const [draft, setDraft] = useState("");
  const [profileOpen, setProfileOpen] = useState(false);
  const [toast, setToast] = useState("");
  const [onboardingOpen, setOnboardingOpen] = useState(false);
  const [onboardingCompleted, setOnboardingCompleted] = useState(false);
  const [nativeLayerReady, setNativeLayerReady] = useState(false);

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
      const nextTheme = EXPLORE_THEMES.find((theme) => theme.id === nextThemeId) ?? activeTheme;
      if (nextThemeId) setActiveThemeId(nextTheme.id);
      if (nextTab === "today") {
        setNativeTab("today");
        setTodayRoute("home");
        if (!nextToday) setTodayActiveId("today");
      } else if (nextTab === "explore" || nextTab === "health") {
        setNativeTab(nextTab);
      }
      if (nextToday === "today" || nextToday === "sleep" || nextToday === "focus" || nextToday === "metabolism" || nextToday === "morning") {
        setNativeTab("today");
        setTodayActiveId(nextToday);
      }
      if (nextTodayRoute === "home" || nextTodayRoute === "breathing") {
        setNativeTab("today");
        setTodayRoute(nextTodayRoute);
      }
      if (nextRoute === "home" || nextRoute === "detail" || nextRoute === "chat" || nextRoute === "feedback") {
        setNativeTab("explore");
        setExploreRoute(nextRoute);
        if (nextRoute === "chat") setNativeMessages(initialNativeMessages(nextTheme));
      }
      if (nextHealthRoute === "home" || nextHealthRoute === "detail") {
        setNativeTab("health");
        setHealthRoute(nextHealthRoute);
      }
      if (nextHealthTab === "summary" || nextHealthTab === "sleep" || nextHealthTab === "cycle" || nextHealthTab === "focus" || nextHealthTab === "metabolism" || nextHealthTab === "morning") {
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
  };

  const handleWebViewMessage = (event: { nativeEvent: { data: string } }) => {
    const raw = event.nativeEvent.data;
    try {
      const payload = JSON.parse(raw) as { scope?: string; open?: boolean; completed?: boolean };
      if (payload.scope === "vitora-onboarding") {
        setOnboardingOpen(Boolean(payload.open));
        setOnboardingCompleted(Boolean(payload.completed));
        setNativeLayerReady(true);
        if (!payload.open && payload.completed) {
          setNativeTab("today");
          setTodayRoute("home");
          setTodayActiveId("today");
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
  const activeToday = TODAY_CARDS.find((card) => card.id === todayActiveId) ?? TODAY_CARDS[0];
  const focusPanResponder = PanResponder.create({
    onStartShouldSetPanResponder: () => false,
    onMoveShouldSetPanResponder: (_, gesture) => Math.abs(gesture.dx) > 8,
    onPanResponderMove: (_, gesture) => {
      const raw = 25 + gesture.dx / 4.6;
      const stepped = Math.round(raw / 5) * 5;
      setFocusMinutes(Math.max(10, Math.min(50, stepped)));
    }
  });

  const openTodayCard = (id: TodayCardId) => {
    setNativeTab("today");
    setTodayRoute("home");
    setTodayActiveId(id);
  };

  const openTodayMore = (id: TodayCardId) => {
    const card = TODAY_CARDS.find((item) => item.id === id) ?? TODAY_CARDS[0];
    setHealthDetailSource(id);
    openHealthDetail(card.moreTab, id);
  };

  const openBreathingPractice = (source: TodayCardId = todayActiveId) => {
    setNativeTab("today");
    setTodayActiveId(source);
    setTodayRoute("breathing");
  };

  const completeBreathingPractice = () => {
    setTodayRoute("home");
    setToast("已完成一次呼吸恢复");
  };

  const openThemeDetail = (theme: ExploreTheme) => {
    openNativeChat(theme);
  };

  const openNativeChat = (theme = activeTheme) => {
    setActiveThemeId(theme.id);
    setNativeMessages(initialNativeMessages(theme));
    setDraft("");
    setNativeTab("explore");
    setExploreRoute("chat");
  };

  const sendNativeMessage = () => {
    const text = draft.trim();
    if (!text) return;
    setNativeMessages((messages) => [...messages, { role: "user", text }, { role: "ai", text: nativeReply(text) }]);
    setDraft("");
  };

  const completeNativeChat = () => {
    const text = draft.trim();
    if (text) {
      setNativeMessages((messages) => [...messages, { role: "user", text }, { role: "ai", text: nativeReply(text) }]);
      setDraft("");
    }
    setExploreRoute("feedback");
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
    setNativeTab("health");
    setHealthRoute("detail");
    setHealthDetailTab(tab);
  };

  const closeHealthDetail = () => {
    setHealthRoute("home");
  };

  const openReminderSheet = (source: string, defaultTime: string) => {
    setReminderSheet({ source, time: defaultTime });
  };

  const updateReminderTime = (time: string) => {
    setReminderSheet((sheet) => (sheet ? { ...sheet, time } : sheet));
  };

  const confirmReminder = () => {
    if (reminderSheet) setToast(`已设置 ${reminderSheet.time} 提醒`);
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
          <Pressable key={theme.id} style={styles.nativeExploreCard} onPress={() => openThemeDetail(theme)}>
            <ImageBackground source={theme.image} resizeMode="cover" style={styles.nativeCardImage} imageStyle={styles.nativeCardImageRadius}>
              <View style={styles.nativeCardShade} />
              <Text style={styles.nativePill}>{theme.tag}</Text>
              <View style={styles.nativeCardCopy}>
                <Text style={styles.nativeCardLead}>{theme.lead}</Text>
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
        <Text style={styles.nativePill}>{activeTheme.tag}</Text>
        <View style={styles.nativeDetailCopy}>
          <Text style={styles.nativeDetailLead}>{activeTheme.lead}</Text>
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
    <View style={styles.nativeChat}>
      <View style={styles.nativeChatTop}>
        <Pressable style={styles.nativeRoundButton} onPress={() => setExploreRoute("home")}>
          <Text style={styles.nativeBackText}>‹</Text>
        </Pressable>
        <Text style={styles.nativeAnalyze}>分析</Text>
      </View>
      <ScrollView style={styles.nativeMessages} contentContainerStyle={styles.nativeMessagesContent}>
        {nativeMessages.map((message, index) => (
          <View key={`${message.role}-${index}`} style={[styles.nativeBubble, message.role === "user" && styles.nativeBubbleUser]}>
            <Text style={styles.nativeBubbleText}>{message.text || " "}</Text>
          </View>
        ))}
      </ScrollView>
      <View style={styles.nativeComposer}>
        <View style={styles.nativeInputWrap}>
          <TextInput value={draft} onChangeText={setDraft} placeholder="写点什么..." placeholderTextColor="#8a9292" style={styles.nativeInput} />
          <Pressable onPress={sendNativeMessage}>
            <Text style={styles.nativeSend}>⌁</Text>
          </Pressable>
        </View>
        <Pressable style={styles.nativeDoneButton} onPress={completeNativeChat}>
          <Text style={styles.nativeDoneText}>✓</Text>
        </Pressable>
      </View>
    </View>
  );

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

  const renderHealthStamp = (title: string, tone: HealthStampTone, style: object) => (
    <View style={[styles.nativeHealthStamp, style]}>
      {renderStampPerfs()}
      {renderStampArt(tone)}
      <Text style={styles.nativeHealthStampTitle}>{title}</Text>
    </View>
  );

  const renderHealthDetailChips = () => {
    const chips = [
      { label: "今日", value: "80%", active: healthDetailTab === "summary" },
      { label: "睡眠", value: "+30", active: healthDetailTab === "sleep" },
      { label: "专注", value: "-30", active: healthDetailTab === "focus" },
      { label: "代谢", value: "-15", active: healthDetailTab === "metabolism" },
      { label: "晨间", value: "+10", active: healthDetailTab === "morning" }
    ];
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
      <Text style={styles.healthDetailDate}>{healthDetailSource === "health" ? "‹ 6月2日 ›" : "今日详情"}</Text>
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
      <View style={styles.summaryRadarWrap}>
        <Text style={styles.summaryRadarLabelTop}>Code Rev.</Text>
        <Text style={styles.summaryRadarLabelLeft}>Commits</Text>
        <Text style={styles.summaryRadarLabelRight}>Code Rev.</Text>
        <Text style={styles.summaryRadarLabelBottomLeft}>Pull Req.</Text>
        <Text style={styles.summaryRadarLabelBottomRight}>Issues</Text>
        <View style={styles.summaryRadarCircle}>
          <Text style={styles.summaryRadarScore}>88</Text>
          <View style={styles.summaryRadarPolygon} />
        </View>
      </View>
      <View style={styles.summaryTranslateBlock}>
        <Text style={styles.summarySectionLabel}>身体翻译</Text>
        <View style={styles.summaryPercentRow}>
          <Text style={styles.summaryPercent}>72%</Text>
          <Text style={styles.summaryPercentCopy}>高于{`\n`}的用户</Text>
        </View>
        <Text style={styles.summaryBodyCopy}>这周的主要主题：周期适应；行动和表达。你的身体正在进入恢复窗口，建议放缓高消耗任务。</Text>
      </View>
      <View style={styles.summaryHeatCard}>
        <View style={styles.summaryHeatLabels}>
          <Text>精力</Text>
          <Text>情绪</Text>
          <Text>压力</Text>
        </View>
        <View style={styles.summaryHeatGrid}>
          {Array.from({ length: 54 }).map((_, index) => (
            <View key={index} style={[styles.summaryHeatCell, index % 3 === 0 && styles.summaryHeatCellOn, index % 7 === 0 && styles.summaryHeatCellDark]} />
          ))}
        </View>
      </View>
      {renderSuggestionRows([
        { icon: "☕", time: "09:30", title: "放缓节奏，优先休息", copy: "保证充足睡眠和低强度活动，帮助身体恢复。", action: "提醒我" },
        { icon: "□", time: "13:00", title: "表达与记录", copy: "通过写作或倾诉，梳理想法，释放情绪压力。", action: "设置" },
        { icon: "◒", time: "18:30", title: "温和运动", copy: "选择瑜伽、散步等温和运动，促进循环与放松。", action: "提醒我" }
      ])}
      <Text style={styles.healthDisclaimer}>AI 翻译基于历史数据与实时状态生成，仅供参考ⓘ</Text>
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

  const renderHealthSleepDetail = () => (
    <>
      <View style={styles.sleepOverviewCard}>
        <View style={styles.sleepTimes}>
          <Text>23:10  入睡</Text>
          <Text>07:42☼ 起床</Text>
        </View>
        {renderSleepStageBar()}
        <View style={styles.sleepLegend}>
          <Text>■ 清醒{`\n`}18 分钟</Text>
          <Text>■ 浅睡{`\n`}2 小时 10 分</Text>
          <Text>■ 深睡{`\n`}1 小时 32 分</Text>
          <Text>■ REM{`\n`}1 小时 8 分</Text>
        </View>
      </View>
      <View style={styles.sleepDebtBlock}>
        <Text style={styles.sleepDebtLabel}>轻度睡眠负债</Text>
        <View style={styles.sleepDebtRow}>
          <Text style={styles.sleepDebtValue}>✦+2</Text>
          <Text style={styles.sleepDebtUnit}>小时</Text>
        </View>
        <Text style={styles.sleepDebtCopy}>你近期睡眠时长略低于身体需求，已产生轻度睡眠负债。继续保持规律作息，很快就能回到最佳状态。</Text>
      </View>
      <View style={styles.sleepTrendCard}>
        <View style={styles.sleepTrendHeader}>
          <Text style={styles.sleepTrendTitle}>睡眠负债趋势</Text>
          <Text style={styles.sleepTrendTabs}>7天   30天   90天</Text>
        </View>
        <View style={styles.sleepTrendChart}>
          <View style={[styles.sleepTrendPoint, { left: 32, top: 66 }]} />
          <View style={[styles.sleepTrendPoint, { left: 86, top: 42 }]} />
          <View style={[styles.sleepTrendPoint, { left: 150, top: 63 }]} />
          <View style={[styles.sleepTrendPoint, { left: 218, top: 78 }]} />
          <View style={[styles.sleepTrendPoint, { left: 280, top: 90 }]} />
          <Text style={styles.sleepTrendBadge}>+2</Text>
        </View>
      </View>
      {renderSuggestionRows([
        { icon: "◜", time: "21:30", title: "提前放松", copy: "今晚提前 30 分钟休息，减少夜间高刺激内容。", action: "提醒我", tone: "green" },
        { icon: "◷", time: "22:30", title: "保持规律", copy: "尽量固定入睡时间，帮助更快恢复睡眠节律。", action: "设置" },
        { icon: "☼", time: "07:30", title: "晨间唤醒", copy: "起床后接触自然光，帮助白天更清醒。", action: "提醒" }
      ])}
    </>
  );

  const renderHealthCycleDetail = () => (
    <>
      <View style={styles.cycleRingCard}>
        <View style={styles.cycleRing}>
          <View style={[styles.cycleArc, styles.cycleArcTeal]} />
          <View style={[styles.cycleArc, styles.cycleArcPurple]} />
          <View style={[styles.cycleArc, styles.cycleArcPink]} />
          <View style={[styles.cycleArc, styles.cycleArcAmber]} />
          <View style={styles.cycleFlower}>
            <Text style={styles.cycleFlowerText}>✿</Text>
          </View>
        </View>
        <Text style={[styles.cyclePhaseText, styles.cyclePhaseTeal]}>卵泡期</Text>
        <Text style={[styles.cyclePhaseText, styles.cyclePhasePurple]}>黄体期</Text>
        <Text style={[styles.cyclePhaseText, styles.cyclePhasePink]}>经期</Text>
        <Text style={[styles.cyclePhaseText, styles.cyclePhaseAmber]}>排卵期</Text>
      </View>
      <View style={styles.cycleInfoBlock}>
        <View style={styles.cycleDayRow}>
          <Text style={styles.cycleDay}>D18</Text>
          <Text style={styles.cycleDayCopy}>天  黄体期</Text>
        </View>
        <View style={styles.cycleDecodeRow}>
          <Text style={styles.cycleDecodeIcon}>✿</Text>
          <View style={styles.cycleDecodeCopy}>
            <Text style={styles.cycleDecodeTitle}>周期解读</Text>
            <Text style={styles.cycleDecodeText}>你目前处于黄体期，身体正在为可能的经期做准备。能量可能有起伏，情绪更敏感，也更容易感到疲惫。</Text>
          </View>
          <Text style={styles.cycleNextDate}>6月9日{`\n`}还有 10 天</Text>
        </View>
        <Text style={styles.cycleProgressLabel}>当前周期进度</Text>
        <View style={styles.cycleProgress}>
          <View style={[styles.cycleProgressPart, { backgroundColor: "#38c9c3", flex: 13 }]} />
          <View style={[styles.cycleProgressPart, { backgroundColor: "#ffb643", flex: 2 }]} />
          <View style={[styles.cycleProgressPart, { backgroundColor: "#7d5cf5", flex: 13 }]} />
          <View style={[styles.cycleProgressPart, { backgroundColor: "#ef6b9c", flex: 5 }]} />
        </View>
      </View>
      {renderSuggestionRows([
        { icon: "☕", time: "09:00", title: "放缓节奏，优先休息", copy: "上午先安排轻量任务，减少高消耗工作。", action: "提醒我", tone: "green" },
        { icon: "♙", time: "18:00", title: "温和运动，舒缓身心", copy: "选择瑜伽、散步等低强度运动，促进循环与放松。", action: "设置", tone: "green" },
        { icon: "□", time: "21:00", title: "记录感受，倾听身体", copy: "记录情绪与身体变化，帮助你更好理解自己的周期。", action: "提醒我" }
      ])}
      <Text style={styles.healthDisclaimer}>数据仅供参考，不作为医疗建议</Text>
    </>
  );

  const renderHealthFocusDetail = () => (
    <>
      <View style={[styles.healthModuleHero, styles.healthModuleHeroFocus]}>
        <Text style={styles.healthModuleTitle}>专注</Text>
        <Text style={styles.healthModuleCopy}>切换成本偏高，今天更适合把任务压成单线程。</Text>
        <Text style={styles.healthModuleScore}>-{Math.max(10, 55 - focusMinutes)}</Text>
        <Text style={styles.healthModuleSub}>建议 {focusMinutes} 分钟单任务专注，先降低切换成本。</Text>
        <View style={styles.focusDetailWave}>
          {Array.from({ length: 18 }).map((_, index) => (
            <View key={index} style={[styles.focusDetailTick, index === Math.round((focusMinutes - 10) / 40 * 17) && styles.focusDetailTickActive]} />
          ))}
        </View>
      </View>
      {renderSuggestionRows([
        { icon: "◎", time: "10:30", title: "单任务开始", copy: "只打开当前任务相关窗口，先工作 25 分钟。", action: "提醒我" },
        { icon: "□", time: "14:00", title: "通知降噪", copy: "下午关闭非必要通知，避免重复切换。", action: "设置" },
        { icon: "◌", time: "16:30", title: "呼吸复位", copy: "注意力下降时先做 3 分钟呼吸，再继续推进。", action: "提醒我" }
      ])}
    </>
  );

  const renderHealthMetabolismDetail = () => (
    <>
      <View style={[styles.healthModuleHero, styles.healthModuleHeroMetabolism]}>
        <View style={styles.healthModuleHeaderRow}>
          <Text style={styles.healthModuleTitle}>代谢</Text>
          <Text style={styles.healthModuleBadge}>差</Text>
        </View>
        <Text style={styles.healthModuleCopy}>昨晚睡眠连续性会影响下午专注和恢复速度。</Text>
        <Text style={styles.metabolismDetailValue}>4,151</Text>
        <View style={styles.metabolismDetailBar}>
          <View style={styles.metabolismDetailBarFill} />
        </View>
        <View style={styles.metabolismDetailStats}>
          <Text>◍ 5.21 km</Text>
          <Text>◷ 413 min</Text>
          <Text>⚡1343 kcal</Text>
        </View>
      </View>
      {renderSuggestionRows([
        { icon: "☕", time: "15:00", title: "加餐恢复", copy: "补充温和能量，降低下午恢复压力。", action: "提醒我", tone: "green" },
        { icon: "◒", time: "17:30", title: "轻走 8 分钟", copy: "不做强刺激，只把循环拉回来。", action: "设置" },
        { icon: "□", time: "20:30", title: "代谢回看", copy: "记录今晚食欲和疲劳感，作为明天预测线索。", action: "提醒我" }
      ])}
    </>
  );

  const renderHealthMorningDetail = () => (
    <>
      <View style={[styles.healthModuleHero, styles.healthModuleHeroMorning]}>
        <View style={styles.healthModuleHeaderRow}>
          <Text style={styles.healthModuleTitle}>晨间计划</Text>
          <Text style={styles.healthModuleBadge}>省电模式</Text>
        </View>
        <Text style={styles.healthModuleCopy}>当前可能更容易疲惫、轻水肿、食欲波动、情绪敏感。</Text>
        <View style={styles.morningDetailMap}>
          <View style={styles.morningMapShape} />
          <View style={[styles.morningMapRoad, { transform: [{ rotate: "10deg" }] }]} />
          <View style={[styles.morningMapRoad, { transform: [{ rotate: "-28deg" }], left: 54 }]} />
          <View style={styles.morningPin} />
        </View>
        <View style={styles.morningDetailStats}>
          <Text><Text style={styles.morningDetailBig}>29.60</Text> KM</Text>
          <Text>141 bpm{`\n`}6:16 / Km</Text>
        </View>
      </View>
      {renderSuggestionRows([
        { icon: "☼", time: "07:20", title: "窗边光照", copy: "醒后先接触自然光，降低启动成本。", action: "提醒我", tone: "green" },
        { icon: "◒", time: "07:40", title: "轻走路线", copy: "用 8 分钟路线完成晨间唤醒。", action: "设置" },
        { icon: "□", time: "08:10", title: "记录晨间反馈", copy: "记录疲劳、水肿和食欲变化。", action: "提醒我" }
      ])}
    </>
  );

  const renderHealthDetail = () => (
    <ScrollView style={styles.healthDetailPage} contentContainerStyle={styles.healthDetailContent} showsVerticalScrollIndicator={false}>
      {renderDetailHeader()}
      {renderHealthDetailChips()}
      {renderHealthDetailTabs()}
      {healthDetailTab === "sleep"
        ? renderHealthSleepDetail()
        : healthDetailTab === "cycle"
          ? renderHealthCycleDetail()
          : healthDetailTab === "focus"
            ? renderHealthFocusDetail()
            : healthDetailTab === "metabolism"
              ? renderHealthMetabolismDetail()
              : healthDetailTab === "morning"
                ? renderHealthMorningDetail()
                : renderHealthSummaryDetail()}
    </ScrollView>
  );

  const renderReminderSheet = () => {
    if (!reminderSheet) return null;
    return (
      <View style={styles.reminderLayer}>
        <Pressable style={styles.reminderBackdrop} onPress={() => setReminderSheet(null)} />
        <View style={styles.reminderPanel}>
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
        </View>
      </View>
    );
  };

  const renderHealth = () => (
    <ScrollView style={styles.nativeHealth} contentContainerStyle={styles.nativeHealthContent} showsVerticalScrollIndicator={false}>
      <View style={styles.nativeHello}>
        <Pressable style={styles.nativeProfileButton} onPress={() => setProfileOpen(true)}>
          <Text style={styles.nativeProfileIcon}>♙</Text>
        </Pressable>
        <Text style={styles.nativeHi}>Hi</Text>
      </View>
      <Text style={styles.nativeHealthTitle}>你知道身体总会回到稳态</Text>
      <View style={styles.nativeStampStage}>
        {renderHealthStamp("Amateur", "amateur", styles.nativeStampA)}
        {renderHealthStamp("Sleepers", "sleepers", styles.nativeStampB)}
        {renderHealthStamp("75,000 steps", "steps", styles.nativeStampC)}
        {renderHealthStamp("Gym bros", "gym", styles.nativeStampD)}
        {renderHealthStamp("40 hours", "hours", styles.nativeStampE)}
      </View>
      <View style={styles.nativeWeekCard}>
        <View style={styles.nativeWeekTop}>
          <View style={styles.nativeWeekLeft}>
            <View style={styles.nativeCountRow}>
              <Text style={styles.nativeCount}>154</Text>
              <Text style={styles.nativeCountLabel}>Total</Text>
              <Text style={styles.nativeCount}>51</Text>
              <Text style={styles.nativeCountLabel}>Best</Text>
            </View>
            <View style={styles.nativeHeatmap}>
              {Array.from({ length: 60 }).map((_, index) => (
                <View key={index} style={[styles.nativeHeatCell, index % 3 === 0 && styles.nativeHeatCellOn, index % 7 === 0 && styles.nativeHeatCellDark]} />
              ))}
            </View>
          </View>
          <Text style={styles.nativeRadar}>◎</Text>
        </View>
        <Text style={styles.nativeWeekCopy}>本周你早睡5天高精力状态为早上10点至11点，基础代谢率还剩30%未消耗，</Text>
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
      <View style={styles.nativeMetricGrid}>
        <View style={styles.nativeMetricCard}>
          <Text style={styles.nativeMetricLabel}>平均准备度</Text>
          <Text style={styles.nativeMetricValue}>88</Text>
        </View>
        <View style={styles.nativeMetricCard}>
          <Text style={styles.nativeMetricLabel}>睡眠负债</Text>
          <Text style={styles.nativeMetricValue}>+2</Text>
        </View>
      </View>
      <View style={styles.nativeExtraCard}>
        <Text style={styles.nativeMetricLabel}>信息负债</Text>
        <Text style={styles.nativeExtraValue}>+6</Text>
        <Text style={styles.nativeExtraCopy}>今天未处理的信息积压偏高，适合把重要对话集中到一个时段处理。</Text>
      </View>
      <View style={styles.nativeExtraCard}>
        <Text style={styles.nativeMetricLabel}>平均值</Text>
        <Text style={styles.nativeExtraValue}>76%</Text>
        <Text style={styles.nativeExtraCopy}>你的稳定区间仍在恢复，睡眠和早间状态是本周最有价值的线索。</Text>
      </View>
    </ScrollView>
  );

  const renderTodayChips = () => (
    <View style={styles.todayChipRow}>
      {TODAY_CARDS.map((card) => (
        <Pressable key={card.id} style={[styles.todayChip, todayActiveId === card.id && styles.todayChipActive]} onPress={() => openTodayCard(card.id)}>
          <Text style={styles.todayChipLabel}>{card.label}</Text>
          <Text style={styles.todayChipValue}>{card.chipValue}</Text>
        </Pressable>
      ))}
    </View>
  );

  const renderTodayEnergyVisual = () => (
    <View style={styles.todaySunVisual}>
      <Text style={styles.todayDotScore}>70</Text>
      <Text style={styles.todayDotSub}>On Track</Text>
      <View style={styles.todaySunArc} />
      <View style={[styles.todaySunDot, { left: 76, top: 98 }]} />
      <View style={[styles.todaySunDot, { left: 172, top: 98 }]} />
      <View style={[styles.todaySunDot, { left: 268, top: 98 }]} />
      <Text style={[styles.todaySunTime, { left: 14 }]}>6:14{`\n`}Sunrise</Text>
      <Text style={[styles.todaySunTime, { left: 134 }]}>Good Sun</Text>
      <Text style={[styles.todaySunTime, { right: 10 }]}>17:21{`\n`}Sunset</Text>
    </View>
  );

  const renderTodaySleepVisual = () => (
    <View style={styles.todaySleepVisual}>
      <View style={styles.todaySleepChart}>
        {[
          ["#ea66c7", 90],
          ["#5c96df", 52],
          ["#bc3dd1", 82],
          ["#5c96df", 78],
          ["#bc3dd1", 88],
          ["#5c96df", 58],
          ["#bc3dd1", 86],
          ["#5c96df", 55],
          ["#ea66c7", 96]
        ].map(([color, height], index) => (
          <View key={index} style={[styles.todaySleepBar, { backgroundColor: String(color), height: Number(height) }]} />
        ))}
      </View>
      <Text style={styles.todaySleepTime}>08 : 00{`\n`}····{`\n`}06 : 00</Text>
      <Text style={styles.todaySleepHint}>建议你补充 20 分钟睡眠</Text>
    </View>
  );

  const renderTodayFocusVisual = () => (
    <View style={styles.todayFocusVisual} {...focusPanResponder.panHandlers}>
      <Text style={styles.todayFocusMinutes}>{focusMinutes}<Text style={styles.todayFocusUnit}> 分钟</Text></Text>
      <View style={styles.todayFocusTicks}>
        {Array.from({ length: 19 }).map((_, index) => {
          const active = Math.round((focusMinutes - 10) / 40 * 18) === index;
          return <View key={index} style={[styles.todayFocusTick, active && styles.todayFocusTickActive]} />;
        })}
      </View>
      <View style={styles.todayFocusRange}>
        <Text style={styles.todayFocusRangeText}>25</Text>
        <Text style={styles.todayFocusRangeText}>50</Text>
      </View>
      <Text style={styles.todayFocusHint}>建议 {focusMinutes} 分钟单任务专注，先降低切换成本。</Text>
    </View>
  );

  const renderTodayMetabolismVisual = () => (
    <View style={styles.todayMetabolismVisual}>
      <Text style={styles.todayMetabolismValue}>4,151</Text>
      <View style={styles.todayHeartBadge}><Text style={styles.todayHeartText}>80</Text></View>
      <View style={styles.todayMetabolismBar}>
        <View style={styles.todayMetabolismFill}>
          {Array.from({ length: 7 }).map((_, index) => <View key={index} style={styles.todayMetabolismStripe} />)}
        </View>
      </View>
      <View style={styles.todayMetabolismStats}>
        <Text>◍ 5.21 km</Text>
        <Text>◷ 413 min</Text>
        <Text>⚡1343 kcal</Text>
      </View>
    </View>
  );

  const renderTodayMorningVisual = () => (
    <View style={styles.todayMorningVisual}>
      <View style={styles.todayMorningMap}>
        <View style={styles.todayMorningMapShape} />
        <View style={[styles.todayMorningRoad, { transform: [{ rotate: "-24deg" }] }]} />
        <View style={[styles.todayMorningRoad, { left: 98, transform: [{ rotate: "8deg" }] }]} />
        <View style={styles.todayMorningPin} />
        <Text style={styles.todayMorningPlace}>静安寺</Text>
      </View>
      <View style={styles.todayMorningStats}>
        <Text style={styles.todayMorningKm}>29.60</Text>
        <Text style={styles.todayMorningMeta}>KM{`\n`}141 bpm{`\n`}6:16 / Km</Text>
      </View>
    </View>
  );

  const renderTodayCardVisual = (card: TodayCard) => {
    if (card.id === "sleep") return renderTodaySleepVisual();
    if (card.id === "focus") return renderTodayFocusVisual();
    if (card.id === "metabolism") return renderTodayMetabolismVisual();
    if (card.id === "morning") return renderTodayMorningVisual();
    return renderTodayEnergyVisual();
  };

  const todayCardToneStyle = (tone: TodayCard["tone"]) => {
    if (tone === "sleep") return styles.todayCard_sleep;
    if (tone === "focus") return styles.todayCard_focus;
    if (tone === "metabolism") return styles.todayCard_metabolism;
    if (tone === "morning") return styles.todayCard_morning;
    return styles.todayCard_energy;
  };

  const handleTodayAction = (card: TodayCard) => {
    if (card.id === "sleep") {
      openReminderSheet("睡眠修复", "21:30");
      return;
    }
    openBreathingPractice(card.id);
  };

  const renderToday = () => (
    <ScrollView style={styles.nativeToday} contentContainerStyle={styles.nativeTodayContent} showsVerticalScrollIndicator={false}>
      {renderTodayChips()}
      <View style={[styles.todayMainCard, todayCardToneStyle(activeToday.tone)]}>
        <View style={styles.todayCardHeader}>
          <View>
            <Text style={styles.todayCardTitle}>{activeToday.title}</Text>
            <Text style={styles.todayCardSubtitle}>{activeToday.subtitle}</Text>
          </View>
          <Pressable style={styles.todayMorePill} onPress={() => openTodayMore(activeToday.id)}>
            <Text style={styles.todayMoreText}>更多</Text>
          </Pressable>
        </View>
        {renderTodayCardVisual(activeToday)}
        <Pressable style={styles.todayCardAction} onPress={() => handleTodayAction(activeToday)}>
          <Text style={styles.todayCardActionText}>{activeToday.action}</Text>
        </Pressable>
      </View>
      <Pressable style={styles.todayMonitorCard} onPress={() => (activeToday.id === "sleep" ? openReminderSheet("睡眠修复", "21:30") : openBreathingPractice(activeToday.id))}>
        <Text style={styles.todayMonitorTitle}>监测到</Text>
        <Text style={styles.todayMonitorCopy}>{activeToday.monitor}</Text>
      </Pressable>
    </ScrollView>
  );

  const renderBreathingPractice = () => (
    <View style={styles.breathPractice}>
      <View style={styles.breathHeader}>
        <Pressable style={styles.breathBack} onPress={() => setTodayRoute("home")}>
          <Text style={styles.breathBackText}>‹</Text>
        </Pressable>
        <Text style={styles.breathTitle}>呼吸恢复</Text>
        <View style={styles.breathBack} />
      </View>
      <View style={styles.breathOrb}>
        <View style={styles.breathOrbInner} />
      </View>
      <Text style={styles.breathPhase}>吸气 / 呼气</Text>
      <Text style={styles.breathCopy}>跟随圆形节奏，把注意力从高刺激任务拉回身体。完成后会回到今日计划。</Text>
      <View style={styles.breathDots}>
        {[0, 1, 2, 3].map((item) => <View key={item} style={[styles.breathDot, item === 1 && styles.breathDotActive]} />)}
      </View>
      <Pressable style={styles.breathComplete} onPress={completeBreathingPractice}>
        <Text style={styles.breathCompleteText}>完成呼吸</Text>
      </Pressable>
    </View>
  );

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
        <Text style={styles.nativeProfileMini}>✉   ◎</Text>
        <View style={styles.nativeProfileHero}>
          <View>
            <Text style={styles.nativeProfileName}>Scarlett 🐰</Text>
            <Text style={styles.nativeProfileSub}>与相遇的第 84 天</Text>
          </View>
          <View style={styles.nativeAvatar}>
            <Text style={styles.nativeAvatarText}>♟</Text>
          </View>
        </View>
        <View style={styles.nativePlus}>
          <View>
            <Text style={styles.nativePlusTitle}>TIDE Plus</Text>
            <Text style={styles.nativePlusSub}>新用户 7 天免费试用</Text>
          </View>
          <View style={styles.nativeMemberPill}>
            <Text style={styles.nativeMemberText}>开通会员</Text>
          </View>
        </View>
        <View style={styles.nativeProfileTiles}>
          <View style={styles.nativeProfileTile}><Text style={styles.nativeProfileTileText}>♡{`\n`}收藏</Text></View>
          <View style={styles.nativeProfileTile}><Text style={styles.nativeProfileTileText}>个人档案</Text></View>
        </View>
        <View style={styles.nativeWatch}>
          <Text style={styles.nativeWatchBox}>□</Text>
          <View>
            <Text style={styles.nativeWatchTitle}>WATCH 应用 ·</Text>
            <Text style={styles.nativeWatchSub}>手腕上的身心健康伙伴</Text>
          </View>
          <Text style={styles.nativeWatchArrow}>›</Text>
        </View>
      </View>
    </View>
  );

  const renderNativeBody = () => {
    if (nativeTab === "health") return healthRoute === "detail" ? renderHealthDetail() : renderHealth();
    if (nativeTab === "today") return todayRoute === "breathing" ? renderBreathingPractice() : renderToday();
    if (exploreRoute === "chat") return renderNativeChat();
    if (exploreRoute === "feedback") return renderFeedback();
    return renderExploreHome();
  };

  const showBottomNav = !(
    (nativeTab === "today" && todayRoute === "breathing") ||
    (nativeTab === "explore" && (exploreRoute === "chat" || exploreRoute === "feedback")) ||
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
            <View style={styles.nativeBottom}>
              <Pressable
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
          {showBottomNav && (
            <Pressable style={styles.nativePlusButton} onPress={() => setToast("新的收集入口已准备")}>
              <Text style={styles.nativePlusButtonText}>＋</Text>
            </Pressable>
          )}
          {profileOpen && renderProfile()}
          {renderReminderSheet()}
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
    bottom: 84,
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
    backgroundColor: "rgba(255,255,255,0.28)"
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
    bottom: 104
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
    backgroundColor: "rgba(255,255,255,0.24)"
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
    backgroundColor: "#e7f7f4",
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
    minWidth: 118,
    height: 46,
    overflow: "hidden",
    borderRadius: 23,
    textAlign: "center",
    paddingTop: 11,
    backgroundColor: "rgba(255,255,255,0.78)",
    color: "#1c2222",
    fontSize: 19,
    fontWeight: "800"
  },
  nativeMessages: {
    flex: 1
  },
  nativeMessagesContent: {
    paddingTop: 80,
    paddingBottom: 112,
    gap: 28
  },
  nativeBubble: {
    maxWidth: 320,
    alignSelf: "flex-start",
    borderRadius: 18,
    paddingHorizontal: 18,
    paddingVertical: 14,
    backgroundColor: "rgba(255,255,255,0.82)"
  },
  nativeBubbleUser: {
    alignSelf: "flex-end",
    minWidth: 96,
    minHeight: 46,
    backgroundColor: "rgba(255,255,255,0.70)"
  },
  nativeBubbleText: {
    color: "#252d2d",
    fontSize: 18,
    lineHeight: 28
  },
  nativeComposer: {
    position: "absolute",
    left: 18,
    right: 18,
    bottom: 28,
    height: 66,
    flexDirection: "row",
    gap: 10
  },
  nativeInputWrap: {
    flex: 1,
    height: 66,
    borderRadius: 33,
    paddingLeft: 20,
    paddingRight: 12,
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "rgba(255,255,255,0.90)"
  },
  nativeInput: {
    flex: 1,
    color: "#202828",
    fontSize: 20
  },
  nativeSend: {
    color: "#303838",
    fontSize: 24
  },
  nativeDoneButton: {
    width: 66,
    height: 66,
    borderRadius: 33,
    alignItems: "center",
    justifyContent: "center",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.84)"
  },
  nativeDoneText: {
    color: "#909896",
    fontSize: 40
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
  nativeHealth: {
    flex: 1,
    backgroundColor: "#ffffff"
  },
  nativeHealthContent: {
    minHeight: 1300,
    paddingTop: 104,
    paddingHorizontal: 24,
    paddingBottom: 230,
    backgroundColor: "#f6f5fb"
  },
  nativeHello: {
    flexDirection: "row",
    alignItems: "center",
    gap: 14,
    marginLeft: 10
  },
  nativeProfileButton: {
    width: 58,
    height: 58,
    borderRadius: 29,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(238,240,236,0.92)"
  },
  nativeProfileIcon: {
    color: "#15191a",
    fontSize: 34
  },
  nativeHi: {
    color: "#fff",
    fontSize: 46,
    fontStyle: "italic",
    fontWeight: "800",
    textShadowColor: "rgba(53,58,65,0.24)",
    textShadowRadius: 4,
    textShadowOffset: { width: 0, height: 2 }
  },
  nativeHealthTitle: {
    color: "#fff",
    fontSize: 29,
    lineHeight: 35,
    fontWeight: "900",
    marginLeft: 10,
    marginTop: 12,
    textShadowColor: "rgba(53,58,65,0.24)",
    textShadowRadius: 5,
    textShadowOffset: { width: 0, height: 3 }
  },
  nativeStampStage: {
    position: "relative",
    height: 282
  },
  nativeHealthStamp: {
    position: "absolute",
    width: 100,
    height: 132,
    alignItems: "center",
    paddingHorizontal: 12,
    paddingTop: 13,
    backgroundColor: "#fff",
    borderRadius: 6,
    shadowColor: "#798088",
    shadowOpacity: 0.15,
    shadowRadius: 7,
    shadowOffset: { width: 0, height: 5 }
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
    width: 76,
    height: 62,
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
    marginTop: 9,
    color: "#1b4f9e",
    fontSize: 14,
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
  nativeStampA: { left: 20, top: 24, transform: [{ rotate: "-8deg" }] },
  nativeStampB: { left: 132, top: 0, width: 112, transform: [{ rotate: "7deg" }] },
  nativeStampC: { right: 4, top: 72, width: 116, transform: [{ rotate: "-8deg" }] },
  nativeStampD: { left: 86, top: 158, width: 94 },
  nativeStampE: { left: 204, top: 174, width: 94 },
  nativeWeekCard: {
    overflow: "hidden",
    borderRadius: 24,
    backgroundColor: "#fff",
    shadowColor: "#202528",
    shadowOpacity: 0.28,
    shadowRadius: 12,
    shadowOffset: { width: 0, height: 8 }
  },
  nativeWeekTop: {
    minHeight: 150,
    padding: 16,
    flexDirection: "row",
    backgroundColor: "#a997db"
  },
  nativeWeekLeft: {
    flex: 1.1
  },
  nativeCountRow: {
    flexDirection: "row",
    alignItems: "flex-end",
    gap: 8,
    marginBottom: 16
  },
  nativeCount: {
    color: "#fff",
    fontSize: 40,
    fontWeight: "900"
  },
  nativeCountLabel: {
    color: "rgba(255,255,255,0.82)",
    fontSize: 13,
    marginBottom: 7
  },
  nativeHeatmap: {
    width: 164,
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 7
  },
  nativeHeatCell: {
    width: 12,
    height: 12,
    borderRadius: 3,
    backgroundColor: "#d8d9dc"
  },
  nativeHeatCellOn: {
    backgroundColor: "#45bd5e"
  },
  nativeHeatCellDark: {
    backgroundColor: "#2f7d45"
  },
  nativeRadar: {
    flex: 0.9,
    color: "rgba(255,255,255,0.72)",
    fontSize: 94,
    textAlign: "center",
    paddingTop: 16
  },
  nativeWeekCopy: {
    padding: 18,
    paddingBottom: 48,
    color: "#4a5658",
    fontSize: 24,
    lineHeight: 32,
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
    gap: 20,
    paddingHorizontal: 6
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
    fontSize: 62,
    lineHeight: 72,
    fontWeight: "900"
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
    paddingBottom: 54,
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
    height: 42,
    marginBottom: 18,
    borderRadius: 23,
    padding: 4,
    flexDirection: "row",
    backgroundColor: "#eeebf7"
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
    height: 318,
    marginTop: 6,
    alignItems: "center",
    justifyContent: "center"
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
    flexDirection: "row",
    backgroundColor: "#aa9cdb"
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
    overflow: "hidden",
    borderRadius: 16,
    paddingHorizontal: 14,
    paddingVertical: 7,
    color: "#8f91ad",
    backgroundColor: "#f1edff",
    fontSize: 13,
    fontWeight: "800"
  },
  sleepTrendChart: {
    height: 150,
    marginTop: 10,
    borderBottomWidth: 1,
    borderBottomColor: "#deddf0",
    borderTopWidth: 1,
    borderTopColor: "#eeeeff"
  },
  sleepTrendPoint: {
    position: "absolute",
    width: 9,
    height: 9,
    borderRadius: 5,
    backgroundColor: "#8a69ff"
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
    height: 330,
    alignItems: "center",
    justifyContent: "center"
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
  metabolismDetailValue: {
    marginTop: 64,
    color: "#fff",
    fontSize: 76,
    lineHeight: 82,
    fontWeight: "900"
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
    backgroundColor: "rgba(20,22,28,0.26)"
  },
  reminderPanel: {
    paddingTop: 10,
    paddingHorizontal: 22,
    paddingBottom: 28,
    borderTopLeftRadius: 28,
    borderTopRightRadius: 28,
    backgroundColor: "#fff"
  },
  reminderHandle: {
    alignSelf: "center",
    width: 44,
    height: 5,
    borderRadius: 3,
    backgroundColor: "#d8d8e4",
    marginBottom: 18
  },
  reminderTitle: {
    color: "#1f2432",
    fontSize: 25,
    fontWeight: "900"
  },
  reminderSource: {
    marginTop: 4,
    color: "#858a9a",
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
    backgroundColor: "#f0edff"
  },
  reminderAdjustText: {
    color: "#7d5cff",
    fontSize: 17,
    fontWeight: "900"
  },
  reminderTime: {
    color: "#161b2b",
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
    backgroundColor: "#f6f4fb"
  },
  reminderQuickActive: {
    backgroundColor: "#7d5cff"
  },
  reminderQuickText: {
    color: "#737787",
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
    backgroundColor: "#f2f2f5"
  },
  reminderCancelText: {
    color: "#626777",
    fontSize: 16,
    fontWeight: "900"
  },
  reminderConfirm: {
    flex: 1,
    height: 48,
    borderRadius: 24,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "#171b27"
  },
  reminderConfirmText: {
    color: "#fff",
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
  nativeToday: {
    flex: 1,
    backgroundColor: "#f8f6f5"
  },
  nativeTodayContent: {
    paddingTop: 82,
    paddingHorizontal: 20,
    paddingBottom: 210,
    minHeight: 860
  },
  todayChipRow: {
    height: 72,
    flexDirection: "row",
    justifyContent: "space-between",
    gap: 8,
    marginBottom: 14
  },
  todayChip: {
    flex: 1,
    height: 66,
    borderRadius: 33,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "#fff",
    shadowColor: "#d9d7dc",
    shadowOpacity: 0.22,
    shadowRadius: 12,
    shadowOffset: { width: 0, height: 6 }
  },
  todayChipActive: {
    backgroundColor: "#e8f3ff"
  },
  todayChipLabel: {
    color: "#666c75",
    fontSize: 13,
    fontWeight: "900"
  },
  todayChipValue: {
    marginTop: 3,
    color: "#111826",
    fontSize: 19,
    fontWeight: "900"
  },
  todayMainCard: {
    minHeight: 468,
    borderRadius: 34,
    padding: 22,
    overflow: "hidden",
    shadowColor: "#d2cbd1",
    shadowOpacity: 0.28,
    shadowRadius: 18,
    shadowOffset: { width: 0, height: 12 }
  },
  todayCard_energy: {
    backgroundColor: "#f5bd47"
  },
  todayCard_sleep: {
    backgroundColor: "#d0e8ff"
  },
  todayCard_focus: {
    backgroundColor: "#dee6fb"
  },
  todayCard_metabolism: {
    backgroundColor: "#efb73d"
  },
  todayCard_morning: {
    backgroundColor: "#eee3dc"
  },
  todayCardHeader: {
    minHeight: 98,
    flexDirection: "row",
    justifyContent: "space-between",
    gap: 12
  },
  todayCardTitle: {
    color: "#fff",
    fontSize: 42,
    lineHeight: 48,
    fontWeight: "900"
  },
  todayCardSubtitle: {
    maxWidth: 246,
    marginTop: 8,
    color: "rgba(255,255,255,0.90)",
    fontSize: 17,
    lineHeight: 24,
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
    height: 238,
    justifyContent: "center"
  },
  todayDotScore: {
    color: "#fff",
    fontSize: 68,
    lineHeight: 72,
    textAlign: "center",
    fontWeight: "900"
  },
  todayDotSub: {
    color: "#fff",
    fontSize: 18,
    textAlign: "center",
    marginTop: 2
  },
  todaySunArc: {
    position: "absolute",
    left: 72,
    right: 72,
    top: 122,
    height: 82,
    borderTopWidth: 5,
    borderLeftWidth: 5,
    borderRightWidth: 5,
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
  todaySunTime: {
    position: "absolute",
    bottom: 22,
    color: "#fff",
    fontSize: 20,
    lineHeight: 24,
    textAlign: "center"
  },
  todaySleepVisual: {
    height: 238,
    justifyContent: "center"
  },
  todaySleepChart: {
    height: 108,
    flexDirection: "row",
    alignItems: "flex-end",
    justifyContent: "center",
    gap: 7,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.26)",
    backgroundColor: "rgba(255,255,255,0.12)",
    paddingHorizontal: 18,
    paddingBottom: 20
  },
  todaySleepBar: {
    width: 22,
    borderRadius: 10
  },
  todaySleepTime: {
    marginTop: 24,
    color: "#fff",
    fontSize: 34,
    lineHeight: 42,
    textAlign: "center",
    fontWeight: "300"
  },
  todaySleepHint: {
    marginTop: 18,
    color: "#eaff66",
    fontSize: 17,
    fontWeight: "900"
  },
  todayFocusVisual: {
    height: 238,
    justifyContent: "center"
  },
  todayFocusMinutes: {
    color: "#fff",
    fontSize: 62,
    textAlign: "center",
    fontWeight: "900"
  },
  todayFocusUnit: {
    fontSize: 33
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
    paddingHorizontal: 18
  },
  todayFocusRangeText: {
    overflow: "hidden",
    borderRadius: 18,
    paddingHorizontal: 15,
    paddingVertical: 5,
    color: "#1f2430",
    backgroundColor: "rgba(255,255,255,0.82)",
    fontSize: 18,
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
    height: 238,
    justifyContent: "center"
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
    height: 238,
    justifyContent: "center"
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
    height: 54,
    borderRadius: 27,
    alignItems: "center",
    justifyContent: "center",
    paddingHorizontal: 24,
    backgroundColor: "rgba(255,255,255,0.92)"
  },
  todayCardActionText: {
    color: "#1a202b",
    fontSize: 20,
    fontWeight: "900"
  },
  todayMonitorCard: {
    width: "72%",
    minHeight: 90,
    marginTop: 20,
    marginLeft: 18,
    borderRadius: 20,
    paddingHorizontal: 22,
    paddingVertical: 16,
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
    lineHeight: 20,
    fontWeight: "800"
  },
  breathPractice: {
    flex: 1,
    paddingTop: 58,
    paddingHorizontal: 24,
    backgroundColor: "#eef5f1"
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
    color: "#172222",
    fontSize: 30,
    textAlign: "center",
    fontWeight: "900"
  },
  breathCopy: {
    marginTop: 14,
    color: "#67706d",
    fontSize: 16,
    lineHeight: 24,
    textAlign: "center",
    fontWeight: "700"
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
    right: 96,
    bottom: 14,
    height: 64,
    borderRadius: 32,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-around",
    backgroundColor: "rgba(110,116,113,0.78)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.24)"
  },
  nativeTabButton: {
    width: 70,
    height: 52,
    borderRadius: 26,
    alignItems: "center",
    justifyContent: "center"
  },
  nativeTabActive: {
    backgroundColor: "rgba(255,255,255,0.18)"
  },
  nativeTabIcon: {
    color: "#fff",
    fontSize: 22
  },
  nativeTabText: {
    color: "#fff",
    fontSize: 16,
    fontWeight: "900"
  },
  nativePlusButton: {
    position: "absolute",
    right: 28,
    bottom: 14,
    width: 64,
    height: 64,
    borderRadius: 32,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgba(110,116,113,0.84)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.25)"
  },
  nativePlusButtonText: {
    color: "#fff",
    fontSize: 34,
    marginTop: -4
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
