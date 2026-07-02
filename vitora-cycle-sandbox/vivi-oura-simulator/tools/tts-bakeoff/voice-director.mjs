const performanceScripts = {
  today_ready: {
    clean:
      "我在这儿。今天状态不错，昨晚的恢复托住了你。重要事情，可以先放在上午推进。",
    cloud_natural:
      "嗯，我在这儿。今天状态不错，昨晚的恢复托住了你。重要的事，我们先放在上午，慢慢往前推。",
    cloud_curious:
      "诶，我刚刚看了一眼。你今天状态还可以。别一下子冲太猛，我们先把上午这一小步走稳。",
    cloud_recovery:
      "先别急。昨晚的恢复托住了你一点。今天可以推进，但我们把节奏放轻一点。",
    cloud_performance:
      "[softly] 嗯，我在这儿。[pause] 今天状态不错，昨晚的恢复托住了你。[teasing] 重要的事，我们先放在上午，慢慢往前推。",
    cloud_soft_recovery:
      "[softly] 先别急。[pause] 昨晚的恢复托住了你一点。今天可以推进，[long pause] 但我们把节奏放轻一点。",
    health_trust:
      "今天状态不错，恢复条件比较稳。重要任务可以放在上午，但晚上仍然要留出恢复时间。",
    noir_low_male:
      "[softly] 嗯。先停一下。[pause] 今天的底子，还算稳。重要的事，放在上午。[long pause] 慢慢来，不用证明什么。",
    young_male_support:
      "嗯……我看了一下。今天底子还不错。重要的事，先放上午。别一口气塞满。先拿下一小步……好，先这样。",
    confidante_sister:
      "今天状态是稳的。你可以把重要的事放在上午慢慢推进，晚上记得给自己留一点恢复时间。",
    noir_en:
      "[softly] But I know you. [pause] You move faster when the room gets quiet. [long pause] So today, take the first step before the noise comes back.",
  },
  sleep_recovery_good: {
    clean:
      "昨晚睡得挺有效率，心率也比较稳。今天可以正常工作，训练前后记得慢一点热身和收操。",
    cloud_natural:
      "昨晚睡得挺有效率。心率也比较稳。今天可以正常工作，训练前后，记得慢一点热身和收操。",
    cloud_curious:
      "我看到了，昨晚睡眠挺争气的。今天可以正常动起来，不过热身和收操，不要省掉。",
    cloud_recovery:
      "昨晚身体修得还不错。今天可以正常工作，但训练前后都慢一点，让状态稳稳落下来。",
    cloud_performance:
      "[softly] 昨晚睡得挺有效率。心率也比较稳。[pause] 今天可以正常工作，训练前后，记得慢一点热身和收操。",
    cloud_soft_recovery:
      "[softly] 昨晚身体修得还不错。[pause] 今天可以正常工作，但训练前后都慢一点，让状态稳稳落下来。",
    health_trust:
      "昨晚睡眠效率良好，心率稳定。今天适合正常工作和轻中强度活动，训练后注意收操。",
    noir_low_male:
      "[softly] 昨晚睡得有效率。[pause] 身体把地面铺稳了。今天可以动，但别把恢复当成理所当然。",
    young_male_support:
      "昨晚睡得还挺有效率。今天可以正常动起来，不过热身和收操别省，稳一点更好。",
    confidante_sister:
      "昨晚的睡眠帮你恢复了不少。今天可以正常安排工作和活动，但训练之后要慢慢收回来。",
    noir_en:
      "[softly] Your sleep did more than rest you. [pause] It held the ground under your feet.",
  },
  sleep_recovery_weak: {
    clean:
      "今天先别急。醒来觉得累，不是你懒，是身体还没完全修好。我们把节奏放轻一点。",
    cloud_natural:
      "今天先别急。醒来觉得累，不是你懒。是身体还没完全修好。我们把节奏放轻一点。",
    cloud_curious:
      "嗯？今天醒来还是累，对吧。不是你不行，是身体还在修补。我们先换一个轻一点的版本。",
    cloud_recovery:
      "先慢一点。身体还没完全修好，不是你做得不好。今天把强度放轻，状态会更稳。",
    cloud_performance:
      "[softly] 今天先别急。[pause] 醒来觉得累，不是你懒。是身体还没完全修好。[long pause] 我们把节奏放轻一点。",
    cloud_soft_recovery:
      "[softly] 先慢一点。[pause] 身体还没完全修好，不是你做得不好。[long pause] 今天把强度放轻，状态会更稳。",
    health_trust:
      "今天恢复偏弱。疲惫感更可能来自睡眠修复不足，建议降低训练强度并提前休息。",
    noir_low_male:
      "[softly] 嗯……累，不是失败。[pause] 是身体还没修完。今晚把声音放低一点。[long pause] 先别硬扛。",
    young_male_support:
      "嗯，今天醒来还是累，对吧。先别急。不是你不行。是恢复没跟上。我们换轻一点……好，先这样。",
    confidante_sister:
      "今天先别急着责怪自己。身体还没完全修好，所以你会觉得累。把强度降下来，会更稳。",
    noir_en:
      "[softly] Tired is not a verdict. [pause] It is a message. [long pause] Listen before you answer.",
  },
  stress_attention: {
    clean:
      "压力这里，需要稍微看一下。今天别把事情排太满，下午留八分钟呼吸恢复，会舒服很多。",
    cloud_natural:
      "压力这里，我想稍微看一下。今天别把事情排太满。下午留八分钟呼吸恢复，会舒服很多。",
    cloud_curious:
      "我发现压力有点往上冒。别担心，不是坏掉了。今天少塞一件事，下午呼吸八分钟。",
    cloud_recovery:
      "压力这里需要被照顾一下。今天少一点刺激，少一点赶。下午给身体八分钟，它会松下来。",
    cloud_performance:
      "[softly] 压力这里，我想稍微看一下。[pause] 今天别把事情排太满。下午留八分钟呼吸恢复，会舒服很多。",
    cloud_soft_recovery:
      "[softly] 压力这里需要被照顾一下。[pause] 今天少一点刺激，少一点赶。[long pause] 下午给身体八分钟，它会松下来。",
    health_trust:
      "今天压力信号偏高。建议减少连续高强度任务，下午安排一次八分钟呼吸恢复。",
    noir_low_male:
      "[softly] 好。压力还在。[pause] 先别急着处理所有事。留八分钟，让身体慢慢松开。",
    young_male_support:
      "诶，压力有点往上冒了。没事。先少塞一件事。下午八分钟呼吸。先把身体放下来……嗯，先这样。",
    confidante_sister:
      "压力这块需要被照顾一下。今天少一点赶，下午留八分钟呼吸恢复，你会舒服很多。",
    noir_en:
      "[softly] Pressure does not always arrive loudly. [pause] Sometimes it waits under the skin.",
  },
  cycle_follicular: {
    clean:
      "现在是卵泡期，身体更容易进入行动状态。可以推进计划，但晚上还是别熬太晚。",
    cloud_natural:
      "现在是卵泡期。身体更容易进入行动状态。可以推进计划，但晚上别熬太晚。",
    cloud_curious:
      "这个阶段，身体会更想往前走。可以推进计划，但别趁状态好就把晚上也填满。",
    cloud_recovery:
      "卵泡期的状态在上升。今天可以做一点推进，但晚上还是把恢复留出来。",
    cloud_performance:
      "[softly] 现在是卵泡期。身体更容易进入行动状态。[pause] 可以推进计划，但晚上别熬太晚。",
    cloud_soft_recovery:
      "[softly] 卵泡期的状态在上升。[pause] 今天可以做一点推进，但晚上还是把恢复留出来。",
    health_trust:
      "当前处于卵泡期，行动感通常更好。建议推进计划，同时保持稳定作息。",
    noir_low_male:
      "[softly] 身体开了一扇窗。[pause] 可以推进。但别把夜晚也交出去。",
    young_male_support:
      "现在是卵泡期，行动感会更好一点。可以推进计划，但晚上别熬太晚。",
    confidante_sister:
      "卵泡期通常会更容易进入行动状态。今天可以推进计划，同时把作息稳住。",
    noir_en:
      "[softly] The body opens a window. [pause] Not forever. [long pause] Just enough for one clear move.",
  },
  workout_decision: {
    clean:
      "今天不太适合硬练。恢复还没完全跟上，换成拉伸或快走，会更适合你。",
    cloud_natural:
      "今天不太适合硬练。恢复还没完全跟上。换成拉伸或快走，会更适合你。",
    cloud_curious:
      "想练也可以，但别硬顶。我们把高强度换掉，快走二十分钟，身体会更愿意配合。",
    cloud_recovery:
      "今天换轻一点。恢复还没完全跟上，拉伸或快走，比硬练更适合。",
    cloud_performance:
      "[softly] 今天不太适合硬练。[pause] 恢复还没完全跟上。换成拉伸或快走，会更适合你。",
    cloud_soft_recovery:
      "[softly] 今天换轻一点。[pause] 恢复还没完全跟上，拉伸或快走，比硬练更适合。",
    health_trust:
      "今天不建议高强度训练。恢复负荷偏高，建议选择拉伸、快走或低强度活动。",
    noir_low_male:
      "[softly] 今天别硬练。[pause] 力量不一定要大声。拉伸，快走，都够了。",
    young_male_support:
      "今天可以动，但别硬练。快走二十分钟，或者拉伸一下，会更适合现在的状态。",
    confidante_sister:
      "今天不太适合高强度训练。我们换成快走或拉伸，让身体慢慢跟上来。",
    noir_en:
      "[softly] Strength is not always louder. [pause] Today, let it be precise.",
  },
  food_craving: {
    clean:
      "今天特别想吃甜食，不是意志力差。身体在要能量，先加一点蛋白质，会更稳。",
    cloud_natural:
      "今天特别想吃甜食，不是意志力差。身体在要能量。先加一点蛋白质，会更稳。",
    cloud_curious:
      "诶，想吃甜的了？这不一定是馋。身体可能在要能量，我们先补一点蛋白质。",
    cloud_recovery:
      "想吃甜食的时候，先别责怪自己。身体可能在找能量。先吃一点更稳的东西。",
    cloud_performance:
      "[teasing] 诶，想吃甜的了？[pause] 这不一定是馋。身体可能在要能量，我们先补一点蛋白质。",
    cloud_soft_recovery:
      "[softly] 想吃甜食的时候，先别责怪自己。[pause] 身体可能在找能量。先吃一点更稳的东西。",
    health_trust:
      "今天的甜食渴望可能与能量需求有关。建议先补充蛋白质，再决定是否需要甜食。",
    noir_low_male:
      "[softly] 想吃甜的，不只是欲望。[pause] 那是身体在要能量。先给它一点更稳的东西。",
    young_male_support:
      "想吃甜的了？不一定是馋。身体可能在要能量，先补一点蛋白质会更稳。",
    confidante_sister:
      "想吃甜食的时候，先别责怪自己。身体可能是在要能量，先吃一点蛋白质，再决定要不要甜食。",
    noir_en:
      "[softly] Desire is data. [pause] It tells you where the body is asking to be held.",
  },
  ai_reply_short: {
    clean:
      "可以动，但换轻一点。今天快走二十分钟，比硬练更适合。",
    cloud_natural:
      "可以动，但换轻一点。今天快走二十分钟，比硬练更适合。",
    cloud_curious:
      "可以动。只是别硬练。我们换成快走二十分钟，聪明一点，也轻一点。",
    cloud_recovery:
      "可以动，但先轻一点。今天快走二十分钟，身体会更舒服。",
    cloud_performance:
      "[softly] 可以动，但换轻一点。[pause] 今天快走二十分钟，比硬练更适合。",
    cloud_soft_recovery:
      "[softly] 可以动，但先轻一点。[pause] 今天快走二十分钟，身体会更舒服。",
    health_trust:
      "可以运动，但建议降低强度。今天快走二十分钟更适合当前恢复状态。",
    noir_low_male:
      "[softly] 可以动。[pause] 轻一点。今天不要用力证明。二十分钟快走，就够了。",
    young_male_support:
      "可以动。嗯……但别硬练。快走二十分钟。聪明一点，也轻一点。好，先这样。",
    confidante_sister:
      "可以运动，只是强度要轻一点。今天快走二十分钟，会比硬练更适合你。",
    noir_en:
      "[softly] Move, yes. [pause] But softer. [long pause] Let the body answer without force.",
  },
  ai_reply_long: {
    clean:
      "你的准备度是八十八，睡眠也在良好区间。今天可以安排比较难的任务，但训练别加码，晚上给身体留一点缓冲。",
    cloud_natural:
      "你的准备度是八十八，睡眠也在良好区间。今天可以安排比较难的任务。但训练别加码，晚上给身体留一点缓冲。",
    cloud_curious:
      "我看了一下。准备度八十八，睡眠也不错。难一点的任务可以放今天，但训练别加码，好吗？",
    cloud_recovery:
      "准备度和睡眠都还不错。今天可以做重要任务，但晚上别把身体用空。留一点缓冲。",
    cloud_performance:
      "[softly] 我看了一下。准备度八十八，睡眠也不错。[pause] 难一点的任务可以放今天，但训练别加码，好吗？",
    cloud_soft_recovery:
      "[softly] 准备度和睡眠都还不错。[pause] 今天可以做重要任务，但晚上别把身体用空。留一点缓冲。",
    health_trust:
      "准备度和睡眠都处在良好区间。今天适合安排重点任务，但不建议额外增加训练强度。",
    noir_low_male:
      "[softly] 准备度八十八。睡眠也站住了。[pause] 今天可以做难一点的事。但别加码训练。",
    young_male_support:
      "我看了一下，准备度八十八，睡眠也不错。重点任务可以放今天，训练就别再加码了。",
    confidante_sister:
      "准备度和睡眠都还不错。今天适合安排重点任务，但晚上别把身体用空，要留一点缓冲。",
    noir_en:
      "[softly] You have enough today. [pause] Not endless, not fragile. [long pause] Enough.",
  },
};

const defaultInstructions = {
  clean: "清晰、自然、可信。不要客服腔，不要强表演。",
  cloud_natural: "年轻、轻软、贴近；像云朵从右下角探出来轻声提醒。短句之间自然停顿。",
  cloud_curious: "更好奇、更灵动，有眼神感；不要过甜，不要幼态，不要夸张。",
  cloud_recovery: "更慢、更安抚，适合睡眠恢复和压力提醒；轻轻靠近，不要训话。",
  cloud_performance: "使用语气标签；聪明软萌、轻靠近，带自然停顿和轻微俏皮。",
  cloud_soft_recovery: "使用语气标签；安抚、低刺激、慢半拍，不要客服腔。",
  health_trust: "温柔、可信、专业但不冰冷；适合健康建议。",
  noir_low_male: "低沉、冷白、克制，像贴近耳边的电影旁白；短句、停顿多，不训话。",
  young_male_support: "年轻男中音、清亮、自然陪伴；不要油腻，不要装可爱。",
  confidante_sister: "成熟、温柔、可信，像知心姐姐在解释身体信号；慢一点，但不要客服腔。",
  noir_en: "Cold, intimate, cinematic, restrained. Soft pauses and no overacting.",
};

export function stripPerformanceTags(value) {
  return String(value)
    .replace(/\[[^\]]+\]/g, "")
    .replace(/[ \t]+\n/g, "\n")
    .replace(/[ \t]{2,}/g, " ")
    .replace(/\s+([，。！？,.!?])/g, "$1")
    .trim();
}

function tagsFrom(value) {
  return Array.from(String(value).matchAll(/\[([^\]]+)\]/g)).map((match) => match[1]);
}

function chooseVariant({ profile, voice }) {
  if (voice.directorVariant) return voice.directorVariant;
  if (profile.id === "elevenlabs_v3") return "cloud_performance";
  if (/cloud|ghost|cute/i.test(voice.presetId || voice.style || "")) return "cloud_natural";
  if (/warm|sister/i.test(voice.presetId || voice.style || "")) return "health_trust";
  return "clean";
}

export function directScript({ profile, voice, text, forcedVariant }) {
  const variant = forcedVariant || chooseVariant({ profile, voice });
  const textScripts = performanceScripts[text.id] || {};
  const rawScript = textScripts[variant] || textScripts.clean || text.text;
  const supportsTags = profile.id === "elevenlabs_v3";
  const spokenText = supportsTags ? rawScript : stripPerformanceTags(rawScript);

  return {
    sourceText: text.text,
    text: spokenText,
    rawScript,
    variant,
    tags: tagsFrom(rawScript),
    instructions: voice.instructions || defaultInstructions[variant] || defaultInstructions.clean,
    tagsEnabled: supportsTags,
  };
}
