/* Vitora PillowTalk Explore v1 - low-code component flow */
(function () {
  if (window.__vitoraPillowTalkExploreV1Loaded) return;
  window.__vitoraPillowTalkExploreV1Loaded = true;

  var galleryBase = "./assets/pillowtalk/gallery/";
  var storageKey = "vitora:pillowtalk:lowcodeEntriesV1";
  var stateKey = "vitora:pillowtalk:lowcodeStateV1";

  var assets = {
    home: galleryBase + "green_spark_card_portrait.png",
    relationship: galleryBase + "moon_card_portrait.png",
    dream: galleryBase + "saturn_card_portrait.png",
    inspiration: galleryBase + "sky_color_card_portrait.png",
    analysis: galleryBase + "moon_full_bleed.png",
    tags: galleryBase + "live_duck_card_square.png",
    unlock: galleryBase + "moon_card_portrait.png",
    streak: galleryBase + "green_spark_card_square.png",
    live: galleryBase + "live_duck_card_square.png",
    preparing: galleryBase + "saturn_full_bleed.png",
    comet: galleryBase + "comet_full_bleed.png"
  };

  var themes = {
    thought: {
      id: "thought",
      route: "/themes/thought",
      title: "这一刻你反复想到什么？",
      label: "你的思想",
      account: "思维账户",
      kicker: "把脑海里反复出现的念头放在这里",
      question: "最近哪一个想法总是在你脑海里回来？",
      image: assets.comet,
      tone: "green",
      modes: ["输入", "聊聊", "转录"],
      actions: [
        { id: "input", label: "输入", icon: "input", action: "open-chat", mode: "输入" },
        { id: "chat", label: "聊聊", icon: "wave", action: "open-chat", mode: "聊聊", primary: true },
        { id: "voice", label: "转录", icon: "mic", action: "open-chat", mode: "转录" }
      ]
    },
    relationship: {
      id: "relationship",
      route: "/themes/relationship",
      title: "探索你的关系模式",
      label: "你的关系",
      account: "情感账户",
      kicker: "想想你是如何与他人建立联系的",
      question: "最近哪一段关系让你最想停下来看看？",
      image: assets.relationship,
      tone: "moon",
      modes: ["输入", "聊聊", "转录"],
      actions: [
        { id: "input", label: "输入", icon: "input", action: "open-chat", mode: "输入" },
        { id: "add", label: "添加聊天", icon: "chat", action: "open-chat", mode: "聊聊", primary: true },
        { id: "chat", label: "聊聊", icon: "wave", action: "open-chat", mode: "聊聊" }
      ]
    },
    dream: {
      id: "dream",
      route: "/themes/dream",
      title: "你对其中一个梦有什么印象？",
      label: "你的梦想",
      account: "精神账户",
      kicker: "记录一个梦里留下来的画面",
      question: "你对其中一个梦有什么印象？",
      image: assets.dream,
      tone: "saturn",
      modes: ["输入", "添加聊天", "聊聊"],
      actions: [
        { id: "input", label: "输入", icon: "input", action: "open-chat", mode: "输入" },
        { id: "chat", label: "聊聊", icon: "wave", action: "open-chat", mode: "聊聊", primary: true },
        { id: "voice", label: "转录", icon: "mic", action: "open-chat", mode: "转录" }
      ]
    },
    inspiration: {
      id: "inspiration",
      route: "/themes/inspiration",
      title: "Creativity is the process of having original ideas that have value.",
      label: "你的灵感",
      account: "意志账户",
      kicker: "—Ken Robinson",
      question: "哪一句话今天抓住了你？",
      image: assets.inspiration,
      tone: "green",
      modes: ["输入", "聊聊", "转录"],
      actions: [
        { id: "input", label: "输入", icon: "input", action: "open-chat", mode: "输入" },
        { id: "share", label: "分享句子", icon: "spark", action: "share-quote", primary: true },
        { id: "chat", label: "聊聊", icon: "wave", action: "open-chat", mode: "聊聊" }
      ]
    }
  };

  var themeOrder = ["thought", "inspiration", "dream", "relationship"];
  var tagOptions = [
    "谦逊", "无忧无虑", "休息好", "平静", "连接", "舒服", "充实", "悠然", "被欣赏",
    "受到启发", "安全", "满足", "被重视", "开放", "被接纳", "平衡", "放松", "有同理心",
    "松了一口气", "极乐", "体贴", "有希望", "感激", "高兴", "自豪", "宁静", "有安全感",
    "受尊重", "chill", "自在", "被爱", "感恩", "被支持", "被理解"
  ];

  var initialMessages = {
    thought: [
      { role: "ai", text: "把那个反复回来的念头先放在这里。它不需要完整，只要说出最清楚的一小块。" }
    ],
    relationship: [
      { role: "ai", text: "我们先不急着判断关系，只看一个最近让你有感觉的瞬间。那一刻你更想靠近，还是更想退开？" }
    ],
    dream: [
      { role: "ai", text: "今天开心不，我陪你聊会儿天，会在合适的时机为你显影情绪 Live 卡片" },
      { role: "user", text: "还好吧你" },
      { role: "ai", text: "还好呀！你呢，今天怎么样？" }
    ],
    inspiration: [
      { role: "ai", text: "把那句今天抓住你的话写下来。它打动你的地方，可能就是新的记录入口。" }
    ]
  };

  var screens = {
    home: {
      id: "01_home_invite_green",
      route: "/home",
      title: "首页邀请卡",
      components: [
        {
          id: "invite",
          type: "InviteHeroCard",
          image: assets.home,
          content: {
            eyebrow: "抹茶我们请？",
            meta: "Luminous Green",
            title: "嘿 Cissy！聊一会儿？\n来帮我们一起塑造\npillowtalk 的未来吧。"
          }
        },
        { id: "recent", type: "RecentEntryPanel", action: "open-chat" },
        { id: "themeRail", type: "ThemeRail", action: "open-chat" }
      ]
    },
    chat: {
      id: "09_chat_live_card_duck",
      route: "/chat",
      title: "文本聊天页",
      components: [
        { id: "chatHeader", type: "ChatHeader", action: "back-themes" },
        { id: "messages", type: "MessageList" },
        { id: "input", type: "InputBar", action: "send-message" }
      ]
    },
    analysis: {
      id: "05_analysis_result_moon",
      route: "/analysis-result",
      title: "分析结果页",
      components: [
        { id: "analysisHeader", type: "AnalysisHeader", action: "back-chat" },
        { id: "result", type: "AnalysisResultCard", image: assets.analysis, action: "toggle-expand" },
        { id: "body", type: "AccountProgressRow", title: "身体账户", subtitle: "本月 3 次 · 46 分钟", icon: "body", progress: 58 },
        { id: "spirit", type: "AccountProgressRow", title: "精神账户", subtitle: "累计 8 次 · 126 分钟", icon: "spark", progress: 74 },
        { id: "will", type: "AccountProgressRow", title: "意志账户", subtitle: "本月 2 次 · 32 分钟", icon: "flame", progress: 42 },
        { id: "audio", type: "AudioBar", action: "toggle-audio" },
        { id: "complete", type: "PrimaryButton", text: "生成今日卡片", action: "finish-chat" }
      ]
    },
    unlock: {
      id: "07_unlock_next_mode_moon",
      route: "/unlock-next",
      title: "今日卡片收集",
      components: [
        { id: "unlockHeader", type: "CloseHeader", action: "finish-flow" },
        { id: "unlockProgress", type: "UnlockProgress", image: assets.unlock, action: "toggle-unlock-detail" },
        { id: "collectionStats", type: "CollectionStatsBlock" },
        { id: "share", type: "SecondaryButton", text: "分享今日卡片", action: "share-summary" },
        { id: "complete", type: "PrimaryButton", text: "完成", action: "finish-flow" }
      ]
    }
  };

  var state = loadState();

  function defaultState() {
    return {
      route: "home",
      themeId: "dream",
      mode: "聊聊",
      dayIndex: 5,
      messages: [],
      selectedTags: ["被重视"],
      peopleAdded: false,
      expanded: false,
      liveExpanded: false,
      audioPlaying: false,
      unlockDetail: false,
      actionSheet: false,
      toast: "",
      lastUserText: "",
      currentEntry: null,
      collectionSaved: false
    };
  }

  function loadState() {
    var base = defaultState();
    try {
      var raw = window.localStorage && window.localStorage.getItem(stateKey);
      if (!raw) return base;
      var saved = JSON.parse(raw);
      if (!saved || typeof saved !== "object") return base;
      var merged = Object.assign(base, saved, {
        messages: Array.isArray(saved.messages) ? saved.messages : base.messages,
        selectedTags: Array.isArray(saved.selectedTags) ? saved.selectedTags : base.selectedTags
      });
      if (["themes", "tags", "streak", "input"].indexOf(merged.route) >= 0) {
        merged.route = "home";
        merged.actionSheet = false;
      }
      return merged;
    } catch (_) {
      return base;
    }
  }

  function saveState() {
    try {
      var snapshot = Object.assign({}, state, { toast: "", actionSheet: false, audioPlaying: false });
      window.localStorage.setItem(stateKey, JSON.stringify(snapshot));
    } catch (_) {}
  }

  function loadEntries() {
    try {
      var raw = window.localStorage && window.localStorage.getItem(storageKey);
      var parsed = raw ? JSON.parse(raw) : [];
      return Array.isArray(parsed) ? parsed : [];
    } catch (_) {
      return [];
    }
  }

  function saveEntry(entry) {
    try {
      var entries = loadEntries();
      entries.unshift(entry);
      window.localStorage.setItem(storageKey, JSON.stringify(entries.slice(0, 12)));
    } catch (_) {}
  }

  function hasUserConversation() {
    return Boolean(state.lastUserText) || state.messages.some(function (message) {
      return message && message.role === "user" && message.entered;
    });
  }

  function collectCurrentEntry() {
    var entry = state.currentEntry || buildEntry();
    var userMessages = state.messages.filter(function (message) {
      return message && message.role === "user" && message.entered;
    }).length;
    entry.createdAt = entry.createdAt || new Date().toISOString();
    entry.tags = state.selectedTags.slice();
    entry.account = entry.account || activeTheme().account || "精神账户";
    entry.chatCount = userMessages || (state.lastUserText ? 1 : 0);
    entry.minutes = Math.max(6, entry.chatCount * 8 || 6);
    if (!state.collectionSaved) {
      saveEntry(entry);
      state.collectionSaved = true;
    }
    state.currentEntry = entry;
    return entry;
  }

  function esc(value) {
    return String(value == null ? "" : value)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }

  function attr(value) {
    return esc(value).replace(/\n/g, " ");
  }

  function activeTheme() {
    return themes[state.themeId] || themes.dream;
  }

  function themeById(id) {
    return themes[id] || themes.dream;
  }

  function lines(value) {
    return esc(value).replace(/\n/g, "<br>");
  }

  function button(label, action, className, extra) {
    return '<button type="button" class="' + esc(className || "ptlc-button") + '" data-ptlc-action="' + esc(action || "noop") + '"' + (extra || "") + '>' + label + '</button>';
  }

  function iconButton(icon, action, label, extraClass, extra) {
    return '<button type="button" class="ptlc-icon-button ' + esc(extraClass || "") + '" data-ptlc-action="' + esc(action || "noop") + '" aria-label="' + esc(label || icon) + '"' + (extra || "") + '><span class="ptlc-dot-icon" data-ptlc-icon="' + esc(icon) + '"></span></button>';
  }

  function dotIcon(icon) {
    return '<span class="ptlc-dot-icon" data-ptlc-icon="' + esc(icon) + '"></span>';
  }

  function notify(message) {
    state.toast = message;
    renderExplore();
    window.clearTimeout(notify.timer);
    notify.timer = window.setTimeout(function () {
      state.toast = "";
      renderExplore();
    }, 1150);
  }

  function goto(route) {
    state.route = route;
    state.actionSheet = false;
    if (route === "chat" && !state.messages.length) {
      state.messages = (initialMessages[state.themeId] || initialMessages.dream).slice();
    }
    saveState();
    renderExplore();
  }

  function setTheme(id) {
    state.themeId = id;
    state.messages = [];
    state.expanded = false;
    state.liveExpanded = false;
  }

  function startChat(id, mode) {
    if (id) setTheme(id);
    state.mode = mode || state.mode || "聊聊";
    state.messages = (initialMessages[state.themeId] || initialMessages.dream).slice();
    state.route = "chat";
    state.expanded = false;
    state.liveExpanded = false;
    state.actionSheet = false;
    state.currentEntry = null;
    state.collectionSaved = false;
  }

  function userText() {
    var text = state.messages.filter(function (message) { return message.role === "user"; })
      .map(function (message) { return message.text; })
      .join(" ");
    return text || state.lastUserText || "我梦到自己在海上漂浮，很迷茫";
  }

  function generateReply(text) {
    var raw = String(text || "");
    if (/海|漂浮|梦|水|船|迷茫/.test(raw)) {
      return "我听见这个画面里有一种漂在中间的感觉。你像是在找岸，也像是在确认自己要去哪里。这个梦和最近的关系或工作转折有关吗？";
    }
    if (/男朋友|朋友|关系|吵|靠近|离开|误会|家人/.test(raw)) {
      return "这里有一种想被理解、又不想再解释太多的拉扯。最近这段关系里，你最希望对方看见哪一部分你？";
    }
    if (/压力|累|烦|焦虑|难过|开心|疲惫/.test(raw)) {
      return "先不用急着把它变好。我们可以先给它一个名字：这更像压力、委屈、空掉，还是一种说不清的疲惫？";
    }
    if (state.themeId === "inspiration") {
      return "这句话像一个入口。它抓住你的地方，是因为它说中了现在的你，还是因为它指向一个你想成为的状态？";
    }
    return "我在。你可以继续补充一个细节：画面的颜色、身体感觉、一个人物，或者最先冒出来的一句话。";
  }

  function buildEntry() {
    var theme = activeTheme();
    var text = userText();
    var dreamLike = theme.id === "dream" || /海|漂浮|梦|水|迷茫/.test(text);
    if (dreamLike) {
      return {
        themeId: theme.id,
        account: theme.account || "精神账户",
        headline: "海上漂浮梦境",
        title: "日记条目分析",
        summary: "你最近梦见自己在海上漂浮，这表达了一种在生活中感受到的不确定和漂泊感。",
        body1: "你最近梦见自己在海上漂浮，这表达了一种在生活中感受到的不确定和漂泊感。海洋的意象常常象征着情绪的深度和未知，你当前可能正处于情绪和环境的转换期，特别是涉及到感情和工作方面的迷茫。这样的梦境提醒你，虽然外界环境复杂且动荡，但你正在试图找到自己的平衡点。",
        body2: "结合你之前反复提到与男朋友的冲突和夜间的情绪波动，这种漂浮感也许暗示你内心渴望安全和稳定，但同时又感受到暂时无法完全靠岸。",
        topics: ["海上漂浮", "梦境", "城市意象"]
      };
    }
    return {
      themeId: theme.id,
      account: theme.account || "精神账户",
      headline: theme.label,
      title: "日记条目分析",
      summary: "这段记录里有一个很明确的核心：你正在寻找一种更稳定、更真实的表达方式。",
      body1: "你把一个尚未完全成形的感受说了出来。它可能不是问题本身，而是一个入口，提醒你去看见自己最近在关系、工作或创作中的真实需要。",
      body2: "继续记录会让这些线索慢慢连起来。今天可以先保留一个关键词，把它当作下次对话的起点。",
      topics: [theme.label, "情绪线索", "表达"]
    };
  }

  function topicLines(entry) {
    return (entry.topics || ["海上漂浮", "梦境", "城市意象"]).map(esc).join("<br>");
  }

  function playSummary() {
    state.audioPlaying = !state.audioPlaying;
    if (!state.audioPlaying) {
      try { window.speechSynthesis && window.speechSynthesis.cancel(); } catch (_) {}
      notify("已暂停语音总结");
      return;
    }
    var entry = state.currentEntry || buildEntry();
    var text = "日记条目分析，" + entry.headline + "。" + entry.summary;
    try {
      if (window.speechSynthesis && window.SpeechSynthesisUtterance) {
        var utterance = new SpeechSynthesisUtterance(text);
        utterance.lang = "zh-CN";
        utterance.rate = 0.92;
        utterance.onend = function () {
          state.audioPlaying = false;
          renderExplore();
        };
        window.speechSynthesis.cancel();
        window.speechSynthesis.speak(utterance);
        notify("正在播放语音总结");
        return;
      }
    } catch (_) {}
    try {
      var AudioContext = window.AudioContext || window.webkitAudioContext;
      if (!AudioContext) throw new Error("no audio");
      var context = new AudioContext();
      var osc = context.createOscillator();
      var gain = context.createGain();
      osc.type = "sine";
      osc.frequency.value = 432;
      gain.gain.setValueAtTime(0.0001, context.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.08, context.currentTime + 0.05);
      gain.gain.exponentialRampToValueAtTime(0.0001, context.currentTime + 1.2);
      osc.connect(gain).connect(context.destination);
      osc.start();
      osc.stop(context.currentTime + 1.25);
      window.setTimeout(function () {
        state.audioPlaying = false;
        renderExplore();
      }, 1250);
      notify("正在播放语音总结");
    } catch (_) {
      notify("当前环境无法播放音频");
      state.audioPlaying = false;
    }
  }

  var componentRegistry = {
    WeekdayDotStrip: function () {
      var labels = ["男", "T", "西", "四", "F", "六", "日"];
      return '<div class="ptlc-week-strip" role="group" aria-label="选择日期">' + labels.map(function (label, index) {
        return '<button type="button" class="' + (index === state.dayIndex ? "active" : "") + '" data-ptlc-action="select-day" data-day="' + index + '"><i></i><span>' + esc(label) + '</span></button>';
      }).join("") + '</div>';
    },
    InviteHeroCard: function (component) {
      return '<section class="ptlc-home-stack">' +
        '<article class="ptlc-invite-card ptlc-clickable" data-ptlc-action="open-chat" data-theme="inspiration" style="--pt-img:url(' + attr(component.image) + ')">' +
          '<img src="' + attr(component.image) + '" alt="" aria-hidden="true">' +
          '<div class="ptlc-card-shade"></div>' +
          '<button type="button" class="ptlc-close-dot" data-ptlc-action="dismiss-invite" aria-label="关闭">' + dotIcon("close") + '</button>' +
          '<div class="ptlc-card-meta"><span>' + esc(component.content.eyebrow) + '</span><em>' + esc(component.content.meta) + '</em></div>' +
          '<h2>' + lines(component.content.title) + '</h2>' +
        '</article>' +
      '</section>';
    },
    RecentEntryPanel: function () {
      var entry = loadEntries()[0];
      if (!entry) {
        return '<button type="button" class="ptlc-glass-panel ptlc-recent-empty" data-ptlc-action="open-chat" data-theme="dream">' +
          '<span class="ptlc-pixel-icon">' + dotIcon("eye") + '</span><strong>你的意识</strong><p>从一条梦境、关系或灵感开始。输入后会得到实时回复、分析卡和记录反馈。</p>' +
        '</button>';
      }
      return '<button type="button" class="ptlc-glass-panel ptlc-recent-filled" data-ptlc-action="open-chat" data-theme="' + esc(entry.themeId || state.themeId) + '">' +
        '<span class="ptlc-pixel-icon">' + dotIcon("eye") + '</span><strong>最近记录 · ' + esc(entry.headline) + '</strong><p>' + esc(entry.summary) + '</p>' +
      '</button>';
    },
    ThemeRail: function () {
      return '<section class="ptlc-theme-rail">' + themeOrder.map(function (id) {
        var theme = themeById(id);
        return '<button type="button" class="ptlc-mini-theme ptlc-mini-' + esc(theme.tone) + '" data-ptlc-action="open-chat" data-theme="' + esc(id) + '">' +
          '<img src="' + attr(theme.image) + '" alt="">' +
          '<small>（' + esc(theme.account) + '）</small>' +
          '<span>' + esc(theme.label) + '</span>' +
          '<strong>' + esc(theme.title) + '</strong>' +
        '</button>';
      }).join("") + '</section>';
    },
    ThemeSwitch: function () {
      return '<div class="ptlc-theme-switch">' + themeOrder.map(function (id) {
        var theme = themeById(id);
        return '<button type="button" class="' + (id === state.themeId ? "active" : "") + '" data-ptlc-action="select-theme" data-theme="' + esc(id) + '">' + esc(theme.label.replace("你的", "")) + '</button>';
      }).join("") + '</div>';
    },
    SegmentedTabs: function () {
      var theme = activeTheme();
      return '<div class="ptlc-segmented" role="tablist">' + theme.modes.map(function (mode) {
        return '<button type="button" class="' + (mode === state.mode ? "active" : "") + '" data-ptlc-action="switch-mode" data-mode="' + esc(mode) + '">' + esc(mode) + '</button>';
      }).join("") + '</div>';
    },
    ThemeHeroCard: function () {
      var theme = activeTheme();
      return '<article class="ptlc-theme-hero ptlc-theme-' + esc(theme.tone) + '" style="--pt-img:url(' + attr(theme.image) + ')">' +
        '<img src="' + attr(theme.image) + '" alt="">' +
        '<div class="ptlc-card-shade"></div>' +
        '<button type="button" class="ptlc-label-pill" data-ptlc-action="show-theme-info">' + esc(theme.label) + '</button>' +
        '<button type="button" class="ptlc-info-button" data-ptlc-action="show-theme-info" aria-label="主题说明">' + dotIcon("info") + '</button>' +
        '<div class="ptlc-theme-copy"><em>（' + esc(theme.account) + '）</em><p>' + esc(theme.kicker) + '</p><h2>' + lines(theme.title) + '</h2></div>' +
        '<div class="ptlc-theme-actions">' + theme.actions.map(function (action) {
          return '<button type="button" class="' + (action.primary ? "primary" : "") + '" data-ptlc-action="' + esc(action.action) + '" data-mode="' + esc(action.mode || state.mode) + '"><b>' + dotIcon(action.icon) + '</b><span>' + esc(action.label) + '</span></button>';
        }).join("") + '</div>' +
      '</article>';
    },
    ChatHeader: function () {
      var theme = activeTheme();
      return '<header class="ptlc-flow-header ptlc-chat-header">' +
        iconButton("back", "back-themes", "返回", "large") +
        '<div class="ptlc-chat-title"><small>（' + esc(theme.account) + '）</small><strong>' + esc(theme.label) + '</strong></div>' +
        '<button type="button" class="ptlc-analysis-link" data-ptlc-action="start-analysis">分析</button>' +
      '</header>';
    },
    MessageList: function () {
      var messages = state.messages.length ? state.messages : (initialMessages[state.themeId] || initialMessages.dream);
      return '<div class="ptlc-message-list">' + messages.map(function (message, index) {
        return '<button type="button" class="ptlc-message ' + esc(message.role) + '" data-ptlc-action="message-tools" data-index="' + index + '">' + esc(message.text) + '</button>';
      }).join("") + '</div>';
    },
    InputBar: function () {
      return '<div class="ptlc-chat-composer"><form class="ptlc-input-bar" data-ptlc-chat-form><input data-ptlc-chat-input placeholder="写点什么..." autocomplete="off" aria-label="输入聊天内容"><button type="submit" aria-label="发送">' + dotIcon("input") + '</button></form><button type="button" class="ptlc-end-conversation" data-ptlc-action="finish-chat"><b>' + dotIcon("check") + '</b><span>结束对话</span></button></div>';
    },
    AnalysisHeader: function () {
      return '<header class="ptlc-flow-header">' +
        iconButton("close", "back-chat", "关闭") +
        '<div class="ptlc-segmented compact"><button type="button" data-ptlc-action="switch-mode" data-mode="转录">转录</button><button type="button" class="active" data-ptlc-action="switch-mode" data-mode="分析">分析</button></div>' +
        '<span class="ptlc-header-spacer"></span>' +
      '</header>';
    },
    CloseHeader: function (component) {
      return '<header class="ptlc-flow-header">' + iconButton("close", component.action || "go-home", "关闭") + '<span></span><span></span></header>';
    },
    AnalysisResultCard: function (component) {
      var entry = state.currentEntry || buildEntry();
      return '<article class="ptlc-analysis-card ' + (state.expanded ? "expanded" : "") + '" style="--pt-img:url(' + attr(component.image) + ')">' +
        '<img src="' + attr(component.image) + '" alt="">' +
        '<div class="ptlc-analysis-copy"><h2>' + esc(entry.title) + '</h2><p>' + esc(entry.body1) + '</p><p class="ptlc-more-body">' + esc(entry.body2) + '</p><button type="button" data-ptlc-action="toggle-expand">' + (state.expanded ? "收起" : "查看更多") + '</button></div>' +
      '</article>';
    },
    FeedbackRow: function (component) {
      var subtitle = component.subtitle;
      if (component.id === "mood" && state.selectedTags.length) subtitle = state.selectedTags.join("、");
      if (component.id === "people" && state.peopleAdded) subtitle = "已加入：男朋友、夜间情绪";
      return '<button type="button" class="ptlc-feedback-row" data-ptlc-action="' + esc(component.action) + '"><span class="ptlc-feedback-icon">' + dotIcon(component.icon) + '</span><span><small>' + esc(component.title) + '</small><strong>' + esc(subtitle) + '</strong></span><i>' + dotIcon("plus") + '</i></button>';
    },
    AccountProgressRow: function (component) {
      var progress = Math.max(0, Math.min(100, Number(component.progress) || 0));
      return '<button type="button" class="ptlc-account-row" data-ptlc-action="noop"><span class="ptlc-feedback-icon">' + dotIcon(component.icon) + '</span><span><small>' + esc(component.title) + '</small><strong>' + esc(component.subtitle) + '</strong><em><i style="width:' + progress + '%"></i></em></span><b>' + progress + '%</b></button>';
    },
    AudioBar: function () {
      var entry = state.currentEntry || buildEntry();
      return '<button type="button" class="ptlc-audio-bar ' + (state.audioPlaying ? "playing" : "") + '" data-ptlc-action="toggle-audio"><span></span><div><strong>日记条目分析：' + esc(entry.headline) + '</strong><i></i></div><b>' + dotIcon(state.audioPlaying ? "pause" : "play") + '</b></button>';
    },
    TagIntro: function (component) {
      return '<section class="ptlc-tag-intro"><div><h1>你现在感觉</h1><p>当你理解自己的情绪是什么触发它们，并把它们组织成清晰的名字，新的选择会更容易出现。</p><h3>' + dotIcon("spark") + ' 和谐</h3></div><button type="button" data-ptlc-action="preview-live"><img src="' + attr(component.image) + '" alt="预览情绪卡"></button></section>';
    },
    TagGrid: function () {
      return '<div class="ptlc-tag-grid">' + tagOptions.map(function (tag) {
        return '<button type="button" class="' + (state.selectedTags.indexOf(tag) >= 0 ? "selected" : "") + '" data-ptlc-action="toggle-tag" data-tag="' + esc(tag) + '">' + esc(tag) + '</button>';
      }).join("") + '</div>';
    },
    UnlockProgress: function (component) {
      var entry = state.currentEntry || buildEntry();
      return '<section class="ptlc-unlock">' +
        '<button type="button" class="ptlc-unlock-card" data-ptlc-action="' + esc(component.action) + '"><img src="' + attr(component.image) + '" alt=""><span>' + esc(entry.account || activeTheme().account || "TODAY CARD") + '</span></button>' +
        '<h1>今日卡片已收集</h1>' +
        '<p class="ptlc-unlock-subtitle">' + esc(entry.headline) + ' · ' + esc(entry.chatCount || 1) + ' 次聊天 · ' + esc(entry.minutes || 6) + ' 分钟</p>' +
        '<div class="ptlc-unlock-steps"><button type="button" data-ptlc-action="toggle-unlock-detail" class="active"></button><button type="button" data-ptlc-action="toggle-unlock-detail" class="' + (state.unlockDetail ? "active" : "") + '"></button></div>' +
        (state.unlockDetail ? '<p class="ptlc-unlock-detail">这张卡片已经进入收集，可在“收集”中继续整理。</p>' : '') +
      '</section>';
    },
    CollectionStatsBlock: function () {
      var entry = state.currentEntry || buildEntry();
      return '<section class="ptlc-collection-stats"><div class="ptlc-stats-grid"><button type="button" data-ptlc-action="show-streak"><b>1</b><span>当前连胜</span></button><button type="button" data-ptlc-action="show-entries"><b>5</b><span>条目</span></button><button type="button" data-ptlc-action="show-topics"><strong>' + topicLines(entry) + '</strong><span>主要主题</span></button><button type="button" data-ptlc-action="show-best"><b>1</b><span>最佳连续记录</span></button></div></section>';
    },
    StreakStatsBlock: function (component) {
      var entry = state.currentEntry || buildEntry();
      return '<section class="ptlc-streak-block"><button type="button" class="ptlc-streak-image" data-ptlc-action="open-history"><img src="' + attr(component.image) + '" alt=""></button>' +
        '<div class="ptlc-stats-grid"><button type="button" data-ptlc-action="show-streak"><b>1</b><span>当前连胜</span></button><button type="button" data-ptlc-action="show-entries"><b>5</b><span>条目</span></button><button type="button" data-ptlc-action="show-topics"><strong>' + topicLines(entry) + '</strong><span>主要主题</span></button><button type="button" data-ptlc-action="show-best"><b>1</b><span>最佳连续记录</span></button></div></section>';
    },
    PrimaryButton: function (component) {
      return button(esc(component.text), component.action, "ptlc-primary-button");
    },
    SecondaryButton: function (component) {
      return button('<span>⇧</span>' + esc(component.text), component.action, "ptlc-secondary-button");
    },
    FloatingPlusButton: function (component) {
      return "";
    }
  };

  function renderComponent(component) {
    var renderer = componentRegistry[component.type];
    if (!renderer) return "";
    return renderer(component);
  }

  function renderScreen(screen) {
    var classes = ["ptlc-screen", "ptlc-route-" + state.route, "ptlc-screen-" + screen.id];
    var content = screen.components.map(renderComponent).join("");
    return '<section class="' + classes.join(" ") + '" data-ptlc-route="' + esc(screen.route) + '">' + content + '</section>';
  }

  function renderActionSheet() {
    return "";
  }

  function renderChrome() {
    return "";
  }

  function resetExploreScroll(root) {
    var screen = root && root.querySelector ? root.querySelector(".ptlc-screen") : null;
    if (screen) screen.scrollTop = 0;
    if (root) root.scrollTop = 0;
    var node = root;
    while (node && node !== document.body) {
      try {
        node.scrollTop = 0;
        node.scrollLeft = 0;
      } catch (_) {}
      node = node.parentElement;
    }
    try {
      document.documentElement.scrollTop = 0;
      document.body.scrollTop = 0;
    } catch (_) {}
    try { window.scrollTo(0, 0); } catch (_) {}
  }

  function renderApp() {
    if (!screens[state.route] || ["themes", "tags", "streak", "input"].indexOf(state.route) >= 0) {
      state.route = "home";
      state.actionSheet = false;
    }
    var screen = screens[state.route] || screens.home;
    return '<div class="ptlc-app-shell">' + renderChrome() + renderScreen(screen) + renderActionSheet() + (state.toast ? '<div class="ptlc-toast">' + esc(state.toast) + '</div>' : '') + '</div>';
  }

  function resolveExploreRoot() {
    var panel = document.querySelector("#vitalsOverviewV2") || document.querySelector("[data-panel='vitals']") || document.querySelector(".vitals-page");
    var root = panel && panel.querySelector("[data-charge-mode-v7][data-pillowtalk-explore-v1='1']");
    if (root) return root;
    root = document.querySelector("[data-charge-mode-v7][data-pillowtalk-explore-v1='1']");
    if (root) return root;
    if (!panel) return null;
    root = panel.querySelector("[data-charge-mode-v7]");
    if (root) return root;
    root = document.createElement("section");
    root.className = "vitals-star-page";
    root.setAttribute("data-charge-mode-v7", "");
    panel.innerHTML = "";
    panel.appendChild(root);
    return root;
  }

  function syncTabLabel() {
    try {
      if (typeof syncChargeModeTabLabelV7 === "function") syncChargeModeTabLabelV7();
    } catch (_) {}
    document.querySelectorAll(".tab[data-tab='vitals'] span").forEach(function (node) { node.textContent = "探索"; });
    document.querySelectorAll(".tab[data-tab='health'] span").forEach(function (node) { node.textContent = "收集"; });
  }

  function renderExplore() {
    var root = resolveExploreRoot();
    if (!root) return;
    var previousRoute = root.getAttribute("data-ptlc-route-rendered") || "";
    root.dataset.pillowtalkExploreV1 = "1";
    delete root.dataset.explorePlaceholderV11;
    delete root.dataset.exploreLiveV10;
    delete root.dataset.chargeVisualV8;
    delete root.dataset.chargeVisualV9;
    root.style.removeProperty("--charge-hero-bg");
    root.innerHTML = renderApp();
    root.setAttribute("data-ptlc-route-rendered", state.route);
    if (state.route === "home" || previousRoute !== state.route) {
      resetExploreScroll(root);
      [0, 80, 240, 640, 1200].forEach(function (delay) {
        window.setTimeout(function () { resetExploreScroll(root); }, delay);
      });
    }
    var phone = root.closest(".phone") || document.querySelector(".phone");
    if (phone) phone.classList.toggle("pillowtalk-flow-open", state.route !== "home");
    syncTabLabel();
    if (state.route === "chat") {
      window.setTimeout(function () {
        var input = document.querySelector("[data-ptlc-chat-input]");
        var list = document.querySelector(".ptlc-message-list");
        if (list) list.scrollTop = list.scrollHeight;
      }, 80);
    }
  }

  function shouldAutoOpenPillowTalk() {
    try {
      var params = new URLSearchParams(window.location.search || "");
      return params.get("demo") === "pillowtalk" || params.get("openTab") === "vitals" || params.get("tab") === "vitals";
    } catch (_) {
      return String(window.location.hash || "").indexOf("pillowtalk") >= 0;
    }
  }

  function completeOnboardingForPillowTalkDemo() {
    try {
      var key = "vivi:prediction:onboardingV1";
      var raw = window.localStorage && window.localStorage.getItem(key);
      var saved = raw ? JSON.parse(raw) : {};
      window.localStorage.setItem(key, JSON.stringify(Object.assign({}, saved, {
        onboardingVersion: "body-profile-content-v2",
        completed: true,
        completedAt: Date.now(),
        name: saved.name || "Cissy"
      })));
    } catch (_) {}
  }

  function activateVitalsForPillowTalk() {
    try {
      if (typeof S !== "undefined") S.tab = "vitals";
    } catch (_) {}
    var phone = document.querySelector(".phone");
    if (phone) {
      phone.setAttribute("data-tab", "vitals");
      phone.classList.toggle("pillowtalk-flow-open", state.route !== "home");
      try {
        phone.scrollTop = 0;
        phone.scrollLeft = 0;
      } catch (_) {}
    }
    var order = ["today", "vitals", "health"];
    var activeIndex = order.indexOf("vitals");
    document.querySelectorAll(".screen[data-screen]").forEach(function (screenNode) {
      var name = screenNode.getAttribute("data-screen");
      var active = name === "vitals";
      screenNode.classList.toggle("active", active);
      screenNode.classList.toggle("left", order.indexOf(name) < activeIndex);
      if (active) {
        try {
          screenNode.scrollTop = 0;
          screenNode.scrollLeft = 0;
        } catch (_) {}
      }
    });
    document.querySelectorAll(".tab[data-tab]").forEach(function (buttonNode) {
      buttonNode.classList.toggle("active", buttonNode.getAttribute("data-tab") === "vitals");
    });
    syncTabLabel();
  }

  function openPillowTalkTabFromQuery() {
    if (!shouldAutoOpenPillowTalk()) return;
    completeOnboardingForPillowTalkDemo();
    try {
      if (typeof closeAdvisor === "function") closeAdvisor();
      if (typeof closeQuick === "function") closeQuick();
      if (typeof closeDetail === "function") closeDetail();
      if (typeof closePlus === "function") closePlus();
    } catch (_) {}
    try {
      if (typeof switchTab === "function") switchTab("vitals");
      else if (typeof S !== "undefined") S.tab = "vitals";
    } catch (_) {}
    state.route = "home";
    state.actionSheet = false;
    saveState();
    activateVitalsForPillowTalk();
    renderExplore();
    [0, 80, 240, 700, 1400, 2400].forEach(function (delay) {
      window.setTimeout(function () {
        try {
          if (typeof switchTab === "function") switchTab("vitals");
        } catch (_) {}
        activateVitalsForPillowTalk();
        renderExplore();
      }, delay);
    });
  }

  function handleAction(target, event) {
    var action = target.getAttribute("data-ptlc-action") || "noop";
    var theme = target.getAttribute("data-theme");
    var mode = target.getAttribute("data-mode");
    var tag = target.getAttribute("data-tag");
    var day = target.getAttribute("data-day");

    if (action !== "noop") {
      event.preventDefault();
      event.stopPropagation();
      if (event.stopImmediatePropagation) event.stopImmediatePropagation();
    }

    if (mode) state.mode = mode;
    if (day != null) {
      state.dayIndex = Number(day);
      notify("已切换到 " + ["周一", "周二", "周三", "周四", "周五", "周六", "周日"][state.dayIndex]);
      saveState();
      return;
    }
    if (theme) setTheme(theme);

    if (action === "go-home" || action === "dismiss-invite") {
      state.route = "home";
    } else if (action === "open-card-input") {
      startChat(theme || state.themeId, "输入");
    } else if (action === "open-themes" || action === "open-theme") {
      startChat(theme || state.themeId, mode || "聊聊");
    } else if (action === "select-theme") {
      startChat(theme || state.themeId, mode || "聊聊");
    } else if (action === "switch-mode") {
      notify("已切换到 " + state.mode);
    } else if (action === "open-chat") {
      startChat(theme || state.themeId, mode || state.mode || "聊聊");
    } else if (action === "back-themes") {
      if (state.route === "chat" && hasUserConversation()) {
        collectCurrentEntry();
        state.route = "unlock";
        notify("已生成今日卡片");
      } else {
        state.route = "home";
      }
    } else if (action === "back-chat") {
      state.route = "chat";
    } else if (action === "start-analysis") {
      if (!hasUserConversation()) {
        notify("先聊一句，再生成分析");
        saveState();
        return;
      }
      state.currentEntry = buildEntry();
      state.route = "analysis";
      state.mode = "分析";
      notify("已生成分析");
    } else if (action === "open-tags") {
      notify("账户反馈已合并到分析页");
    } else if (action === "back-analysis" || action === "finish-tags") {
      state.route = "analysis";
      notify(action === "finish-tags" ? "心情已保存" : "已返回分析");
    } else if (action === "toggle-tag" && tag) {
      var index = state.selectedTags.indexOf(tag);
      if (index >= 0) state.selectedTags.splice(index, 1);
      else state.selectedTags.push(tag);
    } else if (action === "toggle-expand") {
      state.expanded = !state.expanded;
    } else if (action === "toggle-live") {
      state.liveExpanded = !state.liveExpanded;
      notify(state.liveExpanded ? "已展开 Live 卡片" : "已收起 Live 卡片");
    } else if (action === "toggle-people") {
      state.peopleAdded = !state.peopleAdded;
      notify(state.peopleAdded ? "已加入人物线索" : "已移除人物线索");
    } else if (action === "toggle-audio") {
      playSummary();
      saveState();
      renderExplore();
      return;
    } else if (action === "go-unlock") {
      if (!hasUserConversation() && !state.currentEntry) {
        notify("先写一点内容");
        saveState();
        return;
      }
      collectCurrentEntry();
      state.route = "unlock";
    } else if (action === "finish-chat") {
      if (!hasUserConversation() && !state.currentEntry) {
        notify("先写一点内容");
        saveState();
        return;
      }
      collectCurrentEntry();
      state.route = "unlock";
      notify("已生成今日卡片");
    } else if (action === "toggle-unlock-detail") {
      state.unlockDetail = !state.unlockDetail;
    } else if (action === "go-streak") {
      state.route = "home";
    } else if (action === "finish-flow") {
      if (!state.collectionSaved) collectCurrentEntry();
      state.route = "home";
      notify("已完成收集");
    } else if (action === "share-summary") {
      notify("已准备分享连续记录");
    } else if (action === "toggle-actionsheet") {
      state.actionSheet = !state.actionSheet;
    } else if (action === "close-actionsheet") {
      state.actionSheet = false;
    } else if (action === "share-quote") {
      notify("已保存这句灵感");
    } else if (action === "show-theme-info") {
      notify(activeTheme().question);
    } else if (action === "open-video") {
      notify("视频模式已预留");
    } else if (action === "message-tools") {
      notify("消息操作已打开");
    } else if (action === "preview-live") {
      notify("正在预览情绪 Live 卡片");
    } else if (action === "open-history" || action === "show-streak" || action === "show-entries" || action === "show-topics" || action === "show-best") {
      notify("已打开记录详情");
    } else if (action === "open-analysis-from-entry") {
      var savedEntry = loadEntries()[0];
      startChat(savedEntry && savedEntry.themeId ? savedEntry.themeId : state.themeId, "聊聊");
    }

    saveState();
    renderExplore();
  }

  document.addEventListener("click", function (event) {
    var target = event.target;
    if (!target || !target.closest) return;
    var actionTarget = target.closest("[data-ptlc-action]");
    if (!actionTarget) return;
    var root = actionTarget.closest("[data-pillowtalk-explore-v1='1']");
    if (!root) return;
    handleAction(actionTarget, event);
  }, true);

  document.addEventListener("submit", function (event) {
    var form = event.target && event.target.closest ? event.target.closest("[data-ptlc-chat-form]") : null;
    if (!form) return;
    var root = form.closest("[data-pillowtalk-explore-v1='1']");
    if (!root) return;
    event.preventDefault();
    event.stopPropagation();
    if (event.stopImmediatePropagation) event.stopImmediatePropagation();
    var input = form.querySelector("[data-ptlc-chat-input]");
    var text = input ? input.value.trim() : "";
    if (!text) {
      notify("先写一点内容");
      return;
    }
    state.lastUserText = text;
    state.messages.push({ role: "user", text: text, entered: true });
    state.messages.push({ role: "ai", text: generateReply(text) });
    state.currentEntry = null;
    state.collectionSaved = false;
    if (state.route !== "chat") state.route = "chat";
    if (input) input.value = "";
    saveState();
    renderExplore();
  }, true);

  function forcePillowTalkExplore() {
    if (shouldAutoOpenPillowTalk()) {
      completeOnboardingForPillowTalkDemo();
      try {
        if (typeof closeAdvisor === "function") closeAdvisor();
        if (typeof closeQuick === "function") closeQuick();
        if (typeof closeDetail === "function") closeDetail();
        if (typeof closePlus === "function") closePlus();
      } catch (_) {}
      try {
        if (typeof S !== "undefined") S.tab = "vitals";
      } catch (_) {}
      activateVitalsForPillowTalk();
    }
    renderExplore();
  }

  function scheduleForcePillowTalkExplore() {
    [0, 80, 240, 700].forEach(function (delay) {
      window.setTimeout(forcePillowTalkExplore, delay);
    });
  }

  window.__vitoraEnsurePillowTalkExploreV1 = forcePillowTalkExplore;
  window.ssEnsureChargeV1 = forcePillowTalkExplore;
  try { ssEnsureChargeV1 = forcePillowTalkExplore; } catch (_) {}
  try { renderChargeContentIntoV7 = function () { forcePillowTalkExplore(); }; } catch (_) {}
  try { ensureChargeModeButtonAuditV1 = forcePillowTalkExplore; } catch (_) {}

  document.addEventListener("DOMContentLoaded", function () {
    window.setTimeout(forcePillowTalkExplore, 0);
    window.setTimeout(openPillowTalkTabFromQuery, 120);
    window.setTimeout(forcePillowTalkExplore, 500);
    window.setTimeout(openPillowTalkTabFromQuery, 700);
  });
  window.addEventListener("pageshow", scheduleForcePillowTalkExplore, true);
  window.addEventListener("focus", scheduleForcePillowTalkExplore, true);
  document.addEventListener("visibilitychange", function () {
    if (!document.hidden) scheduleForcePillowTalkExplore();
  }, true);
  window.setTimeout(forcePillowTalkExplore, 0);
  window.setTimeout(openPillowTalkTabFromQuery, 120);
  window.setTimeout(forcePillowTalkExplore, 900);
  window.setTimeout(openPillowTalkTabFromQuery, 1100);
})();
