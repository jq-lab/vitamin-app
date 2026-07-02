export const SIMULATOR_WEB_PATCH = `
(function () {
  if (window.__vitoraNativeSimulatorPatchV1) {
    if (typeof window.__vitoraNativeSimulatorPatchRender === "function") {
      window.__vitoraNativeSimulatorPatchRender();
    }
    return true;
  }
  window.__vitoraNativeSimulatorPatchV1 = true;

  var stateKey = "vitora.native.simulator.patch.v1";
  var collectionKey = "vitora.collection.cards.v1";
  var galleryBase = "./assets/pillowtalk/gallery/";
  var lastActionAt = 0;
  var toastTimer = 0;
  var renderTimer = 0;
  var onboardingSignature = "";

  var themes = [
    {
      id: "relationship",
      tag: "你的关系",
      title: "来帮我们一起塑造 pillowtalk",
      prompt: "今天世界无事发生，可以好好歇着，等一切安静下来",
      image: galleryBase + "green_spark_full_bleed.png",
      stampId: "relationship",
      tone: "teal",
      detailLead: "想想你是如何与他人建立联系的",
      detailTitle: "探索你的关系模式",
      recentTitle: "最近记录 · 你的关系",
      recentCopy: "这段记录里有一个很明确的核心：你正在寻找一种更稳定、更真实的表达方式。",
      feedbackTitle: "海上漂浮\\n城市意象",
      feedbackSub: "当前连胜\\n最佳连续记录"
    },
    {
      id: "dream",
      tag: "你的梦想",
      title: "你对其中一个梦有什么印象？",
      prompt: "写下一个梦里留下来的画面",
      image: galleryBase + "saturn_full_bleed.png",
      stampId: "dream",
      tone: "gray",
      detailLead: "把醒来后仍然清晰的画面留下来",
      detailTitle: "梦境回想",
      recentTitle: "最近记录 · 你的梦想",
      recentCopy: "这段记录里有一些反复出现的画面，可以作为你本周的情绪线索。"
    },
    {
      id: "thought",
      tag: "你的意识",
      title: "这一刻你反复想到什么？",
      prompt: "把脑海里反复出现的念头放在这里",
      image: galleryBase + "comet_full_bleed.png",
      stampId: "thought",
      tone: "green",
      detailLead: "观察那个反复回来的念头",
      detailTitle: "意识线索",
      recentTitle: "最近记录 · 你的意识",
      recentCopy: "这些片段会帮你看到压力、期待和行动之间的关系。"
    },
    {
      id: "inspiration",
      tag: "你的灵感",
      title: "哪一句话今天抓住了你？",
      prompt: "保存一句今天让你有感觉的话",
      image: galleryBase + "sky_color_full_bleed.png",
      stampId: "inspiration",
      tone: "amber",
      detailLead: "把今天抓住你的句子放在这里",
      detailTitle: "灵感句子",
      recentTitle: "最近记录 · 你的灵感",
      recentCopy: "这些句子会变成你之后回看自己的线索。"
    }
  ];

  function esc(value) {
    return String(value == null ? "" : value)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }

  function themeById(id) {
    return themes.filter(function (theme) { return theme.id === id; })[0] || themes[0];
  }

  function stampDef(id) {
    var defs = window.VIVI_STAMP_TEMPLATE && window.VIVI_STAMP_TEMPLATE.defs;
    if (!Array.isArray(defs)) return null;
    return defs.filter(function (def) { return def.id === id; })[0] || defs[0] || null;
  }

  function stampSvg(id, width, height, label, title) {
    var api = window.VIVI_STAMP_TEMPLATE;
    var def = stampDef(id);
    if (api && api.toSvg && def) {
      return api.toSvg(def, { width: width || 160, height: height || 206, label: label || def.label, title: title || def.title });
    }
    return '<svg xmlns="http://www.w3.org/2000/svg" width="' + (width || 160) + '" height="' + (height || 206) + '" viewBox="0 0 160 206"><rect width="160" height="206" rx="14" fill="#f5f5f5"/><text x="80" y="104" text-anchor="middle" fill="#222" font-size="18" font-weight="800">Vitora</text></svg>';
  }

  function loadState() {
    try {
      var saved = JSON.parse(localStorage.getItem(stateKey) || "{}");
      return {
        route: saved.route || "home",
        themeId: saved.themeId || "relationship",
        messages: Array.isArray(saved.messages) ? saved.messages : [],
        cardId: saved.cardId || "",
        profile: !!saved.profile,
        detailId: saved.detailId || "",
        healthRoute: saved.healthRoute || "home",
        healthTab: saved.healthTab || "summary",
        today: saved.today || "today",
        todayRoute: saved.todayRoute || "home",
        focusMinutes: Number(saved.focusMinutes) || 25,
        reminder: saved.reminder || "",
        toast: saved.toast || ""
      };
    } catch (_) {
      return { route: "home", themeId: "relationship", messages: [], cardId: "", profile: false, detailId: "", healthRoute: "home", healthTab: "summary", today: "today", todayRoute: "home", focusMinutes: 25, reminder: "", toast: "" };
    }
  }

  var state = loadState();

  function saveState() {
    try { localStorage.setItem(stateKey, JSON.stringify(state)); } catch (_) {}
  }

  function loadCards() {
    try {
      var cards = JSON.parse(localStorage.getItem(collectionKey) || "[]");
      return Array.isArray(cards) ? cards : [];
    } catch (_) {
      return [];
    }
  }

  function saveCards(cards) {
    try { localStorage.setItem(collectionKey, JSON.stringify(cards.slice(0, 40))); } catch (_) {}
  }

  function uid() {
    return "card-" + Date.now().toString(36) + "-" + Math.random().toString(36).slice(2, 7);
  }

  function firstTab() {
    try {
      var params = new URLSearchParams(location.search || "");
      return params.get("openTab") || params.get("tab") || "";
    } catch (_) {
      return "";
    }
  }

  function phone() {
    return document.querySelector(".phone");
  }

  function onboardingIsOpen() {
    var p = phone();
    return !!(
      document.querySelector(".vob-onboarding-layer-v1.open") ||
      document.querySelector("#vitoraOnboardingLayerV1.open") ||
      (p && p.classList && p.classList.contains("vob-onboarding-open")) ||
      (document.body && document.body.classList && document.body.classList.contains("vob-onboarding-open")) ||
      (document.documentElement && document.documentElement.classList && document.documentElement.classList.contains("vob-onboarding-open"))
    );
  }

  function onboardingCompleted() {
    try {
      var raw = localStorage.getItem("vivi:prediction:onboardingV1") || localStorage.getItem("vitora:onboarding:profile:v1") || "";
      if (!raw) return false;
      var parsed = JSON.parse(raw);
      return !!(parsed && (parsed.completed || parsed.done || parsed.profile));
    } catch (_) {
      return false;
    }
  }

  function queryWantsOnboarding() {
    try {
      var params = new URLSearchParams(location.search || "");
      if (params.get("onboarding") === "1" || params.get("showOnboarding") === "1") return true;
    } catch (_) {}
    return String(location.hash || "").replace(/^#/, "").indexOf("onboarding") === 0;
  }

  function hasOnboardingStorage() {
    try {
      return !!(localStorage.getItem("vivi:prediction:onboardingV1") || localStorage.getItem("vitora:onboarding:profile:v1"));
    } catch (_) {
      return false;
    }
  }

  function ensureOnboardingVisible() {
    if (onboardingCompleted() || onboardingIsOpen()) {
      postOnboardingState(false);
      return;
    }
    if (typeof window.openVitoraOnboardingV1 === "function") {
      try {
        window.openVitoraOnboardingV1();
      } catch (_) {}
    }
    postOnboardingState(false);
  }

  function postOnboardingState(force) {
    var open = onboardingIsOpen();
    var completed = onboardingCompleted();
    var signature = String(open) + ":" + String(completed);
    if (!force && signature === onboardingSignature) return;
    onboardingSignature = signature;
    try {
      window.ReactNativeWebView && window.ReactNativeWebView.postMessage(JSON.stringify({
        scope: "vitora-onboarding",
        open: open,
        completed: completed
      }));
    } catch (_) {}
  }

  function switchTo(tab) {
    try {
      if (typeof window.switchTab === "function") window.switchTab(tab);
    } catch (_) {}
    var p = phone();
    if (p) p.setAttribute("data-tab", tab);
    var order = ["today", "vitals", "health"];
    var idx = order.indexOf(tab);
    document.querySelectorAll(".screen[data-screen]").forEach(function (screen) {
      var name = screen.getAttribute("data-screen");
      screen.classList.toggle("active", name === tab);
      screen.classList.toggle("left", order.indexOf(name) < idx);
    });
    document.querySelectorAll(".tab[data-tab]").forEach(function (button) {
      button.classList.toggle("active", button.getAttribute("data-tab") === tab);
    });
    syncLabels();
  }

  function syncLabels() {
    document.querySelectorAll(".tab[data-tab='vitals'] span").forEach(function (node) { node.textContent = "探索"; });
    document.querySelectorAll(".tab[data-tab='health'] span").forEach(function (node) { node.textContent = "健康"; });
  }

  function exploreRoot() {
    var screen = document.querySelector(".screen[data-screen='vitals']");
    var panel = screen || document.querySelector("#vitalsOverviewV2") || document.querySelector("[data-panel='vitals']") || document.querySelector(".vitals-page");
    var root = screen && screen.querySelector(".rn-native-explore-host[data-native-sim-explore='1']");
    if (!root) {
      if (!panel) return null;
      root = document.createElement("div");
      root.className = "rn-native-explore-host";
      panel.appendChild(root);
    }
    root.setAttribute("data-native-sim-explore", "1");
    return root;
  }

  function healthRoot() {
    return document.querySelector(".screen[data-screen='health']");
  }

  function dots() {
    return '<div class="rn-dots" aria-hidden="true"><i></i><i></i><i></i><i></i><i></i><i class="active"></i><i></i></div>';
  }

  function orb() {
    var colors = ["#b6d2ae", "#f4c7cd", "#a3c9ec", "#f7d38b", "#aaa9d7", "#dba4c6", "#acd6b8", "#f0a89c", "#d9dfdb", "#93c1e6"];
    return '<div class="rn-orb"><div>' + colors.map(function (color, index) {
      var x = [-34, -12, 23, 42, 58, -52, -22, 4, -63, 18][index];
      var y = [-18, 2, 18, -14, 18, 14, 43, -28, -9, -38][index];
      var r = [22, 72, 38, 72, 92, 116, 62, 18, 0, 98][index];
      return '<i style="--c:' + color + ';--x:' + x + 'px;--y:' + y + 'px;--r:' + r + 'deg"></i>';
    }).join("") + '</div></div>';
  }

  function initialMessages(theme) {
    if (theme.id === "relationship") {
      return [
        { role: "ai", text: "今天开心不，我陪你聊会儿天，会在合适的时机为你显影情绪 Live 卡片" },
        { role: "user", text: "" },
        { role: "ai", text: "还好呀！你呢，今天怎么样？" }
      ];
    }
    return [{ role: "ai", text: "先从一个画面、一个身体感觉，或者一句最先冒出来的话开始。" }];
  }

  function reply(text) {
    if (/关系|朋友|家人|误会|吵|想/.test(text)) return "这里有一种想被理解、又不想继续解释的拉扯。你最希望对方看见你的哪一部分？";
    if (/累|焦虑|烦|压力|难过|开心/.test(text)) return "先不用急着把它变好。我们可以先给它一个名字，再看看身体在哪里最先感受到它。";
    return "我在。继续补一个细节就好：一个颜色、一个人物、一个动作，或者最先冒出来的一句话。";
  }

  function renderExploreHome() {
    return '<div class="rn-app"><section class="rn-home"><header>' + dots() + '</header><div class="rn-card-list">' + themes.map(function (theme) {
      return '<article class="rn-card rn-' + esc(theme.tone) + '" data-rn-action="open-card" data-theme="' + esc(theme.id) + '"><img src="' + esc(theme.image) + '" alt=""><span class="rn-pill">' + esc(theme.tag) + '</span><div class="rn-card-copy"><small>' + esc(theme.detailLead) + '</small><h1>' + esc(theme.title) + '</h1><p>' + esc(theme.prompt) + '</p></div><button type="button" data-rn-action="open-card" data-theme="' + esc(theme.id) + '">写点什么...</button></article>';
    }).join("") + '</div></section></div>';
  }

  function renderCardDetail() {
    var theme = themeById(state.themeId);
    return '<div class="rn-app"><section class="rn-detail"><header>' + dots() + '</header><article class="rn-detail-card"><span class="rn-pill">' + esc(theme.tag) + '</span><div class="rn-detail-orb">' + orb() + '</div><div class="rn-detail-copy"><p>' + esc(theme.detailLead) + '</p><h1>' + esc(theme.detailTitle) + '</h1><span>' + esc(theme.prompt) + '</span></div><button type="button" data-rn-action="open-chat" data-theme="' + esc(theme.id) + '">写点什么...</button></article><article class="rn-recent"><span class="rn-pill">' + esc(theme.tag) + '</span><h2>' + esc(theme.recentTitle) + '</h2><p>' + esc(theme.recentCopy) + '</p></article></section></div>';
  }

  function renderChat() {
    var theme = themeById(state.themeId);
    var messages = state.messages.length ? state.messages : initialMessages(theme);
    return '<div class="rn-app"><section class="rn-chat"><header><button type="button" data-rn-action="back-detail" aria-label="返回">‹</button><b>分析</b></header><div class="rn-messages">' + messages.map(function (message) {
      return '<div class="rn-msg ' + esc(message.role) + '">' + esc(message.text) + '</div>';
    }).join("") + '</div><div class="rn-composer"><form data-rn-chat-form><input data-rn-chat-input placeholder="写点什么..." autocomplete="off"><button type="submit">⌁</button></form><button type="button" class="rn-done" data-rn-action="complete-chat">✓</button></div></section></div>';
  }

  function renderFeedback() {
    var theme = themeById(state.themeId);
    return '<div class="rn-app"><section class="rn-feedback"><header><button type="button" data-rn-action="back-home">×</button>' + dots() + '</header><div class="rn-feedback-stamp">' + stampSvg(theme.stampId, 230, 296, "DREAM RECALL", "RECORD 1 MORE DREAM, UNLOCK THE NEXT MODE") + '</div><div class="rn-streak"><strong>' + esc(theme.feedbackTitle || "海上漂浮\\n城市意象") + '</strong><span>' + esc(theme.feedbackSub || "当前连胜\\n最佳连续记录") + '</span></div><div class="rn-feedback-actions"><button type="button" data-rn-action="share">⇧ 分享连续记录</button><button type="button" data-rn-action="finish">完成</button></div>' + (state.toast ? '<div class="rn-toast">' + esc(state.toast) + '</div>' : '') + '</section></div>';
  }

  function renderExplore() {
    var root = exploreRoot();
    if (!root) return;
    var signature = state.route + ":" + state.themeId + ":" + state.messages.length + ":" + (state.toast || "");
    if (root.getAttribute("data-rn-signature") === signature && root.querySelector(".rn-app")) return;
    root.setAttribute("data-rn-signature", signature);
    root.innerHTML = state.route === "chat" ? renderChat() : state.route === "feedback" ? renderFeedback() : renderExploreHome();
    var p = phone();
    if (p) p.classList.toggle("pillowtalk-flow-open", state.route !== "home");
    setTimeout(function () {
      var list = document.querySelector(".rn-messages");
      if (list) list.scrollTop = list.scrollHeight;
    }, 30);
  }

  function profileSheet() {
    return '<div class="rn-profile-layer"><div class="rn-profile-status"><span>20:27</span><b>III 4G</b></div><article class="rn-profile" data-rn-stop><button type="button" class="rn-profile-x" data-rn-action="close-profile">×</button><div class="rn-profile-mini">✉ ◎</div><section class="rn-profile-hero"><div><h1>Scarlett 🐰</h1><p>与相遇的第 84 天</p></div><div class="rn-avatar">♟</div></section><section class="rn-plus"><div><strong>TIDE <em>Plus</em></strong><span>新用户 7 天免费试用</span></div><button type="button">开通会员</button></section><div class="rn-profile-grid"><button type="button"><span>♥</span>收藏</button><button type="button">个人档案</button></div><button type="button" class="rn-watch"><i></i><span><strong>WATCH 应用 ·</strong><small>手腕上的身心健康伙伴</small></span><b>›</b></button></article></div>';
  }

  function heatmap() {
    var hot = { 2: "on", 10: "on", 12: "on", 16: "on", 17: "dark", 18: "dark", 19: "bright", 20: "bright", 23: "bright", 26: "bright", 27: "dark", 28: "dark", 33: "dark", 34: "on", 36: "on", 37: "bright", 38: "on", 39: "dark", 40: "dark", 41: "on", 44: "dark", 45: "on", 46: "on", 47: "bright", 48: "on", 49: "on", 50: "bright", 51: "dark", 52: "on" };
    var html = "";
    for (var i = 0; i < 60; i += 1) html += '<i class="' + (hot[i] || "") + '"></i>';
    return html;
  }

  function healthStamp(id, className) {
    return '<div class="rn-health-stamp ' + className + '">' + stampSvg(id, 132, 170) + '</div>';
  }

  function healthDetailTabs() {
    var tabs = [
      ["summary", "综合"],
      ["sleep", "睡眠"],
      ["cycle", "周期"]
    ];
    return '<nav class="rn-health-detail-tabs">' + tabs.map(function (tab) {
      return '<button type="button" class="' + (state.healthTab === tab[0] ? "active" : "") + '" data-rn-action="health-tab" data-tab="' + tab[0] + '">' + tab[1] + '</button>';
    }).join("") + '</nav>';
  }

  function healthAdviceRows(kind) {
    var rows = kind === "sleep"
      ? [["21:30", "提前放松", "提醒我"], ["22:30", "保持规律", "设置"], ["07:30", "晨间唤醒", "提醒"]]
      : kind === "cycle"
        ? [["09:00", "放缓节奏", "提醒我"], ["18:00", "温和运动", "设置"], ["21:00", "记录感受", "提醒我"]]
        : [["09:30", "放缓节奏，优先休息", "提醒我"], ["13:00", "表达与记录", "设置"], ["18:30", "温和运动", "提醒我"]];
    return '<section class="rn-health-advice"><h2>AI 建议</h2>' + rows.map(function (row) {
      return '<article><b>' + row[0] + '</b><span>' + row[1] + '</span><button type="button" data-rn-action="reminder-open" data-time="' + row[0] + '">' + row[2] + '</button></article>';
    }).join("") + '</section>';
  }

  function renderHealthDetail() {
    var body = "";
    if (state.healthTab === "sleep") {
      body = '<section class="rn-detail-sleep"><div class="rn-sleep-bars"><i></i><i></i><i></i><i></i><i></i><i></i></div><h2>轻度睡眠负债</h2><strong>+2 <small>小时</small></strong><p>你近期睡眠时长略低于身体需求，继续保持规律作息，很快就能回到最佳状态。</p></section>' + healthAdviceRows("sleep");
    } else if (state.healthTab === "cycle") {
      body = '<section class="rn-detail-cycle"><div class="rn-cycle-ring">✿</div><h2><strong>D18</strong> 天 黄体期</h2><p>你目前处于黄体期，身体正在为可能的经期做准备。能量可能有起伏，情绪更敏感。</p><div class="rn-cycle-progress"><i></i><i></i><i></i><i></i></div></section>' + healthAdviceRows("cycle");
    } else {
      body = '<section class="rn-detail-summary"><div class="rn-summary-radar">88</div><h2>身体翻译</h2><strong>72%</strong><p>这周的主要主题：周期适应；行动和表达。你的身体正在进入恢复窗口，建议放缓高消耗任务。</p><div class="rn-detail-heat">' + heatmap() + '</div></section>' + healthAdviceRows("summary");
    }
    return '<section class="rn-health rn-health-detail"><div class="rn-health-inner rn-health-detail-inner"><header class="rn-health-detail-head"><button type="button" data-rn-action="health-back">‹</button><b>‹ 6月2日 ›</b><i></i></header><div class="rn-health-chips"><span>睡眠<br><b>+60</b></span><span>周期<br><b>D24</b></span><span class="active">专注<br><b>+10</b></span><span>抗压<br><b>-10</b></span></div>' + healthDetailTabs() + body + '</div>' + (state.reminder ? '<div class="rn-reminder"><article><h2>设置提醒</h2><strong>' + esc(state.reminder) + '</strong><button type="button" data-rn-action="reminder-confirm">确定</button></article></div>' : '') + (state.toast ? '<div class="rn-toast rn-health-toast">' + esc(state.toast) + '</div>' : '') + '</section>';
  }

  function renderHealth() {
    var root = healthRoot();
    if (!root) return;
    var signature = [state.profile ? "profile" : "plain", state.healthRoute || "home", state.healthTab || "summary", state.reminder || "", state.toast || "", loadCards().length].join(":");
    if (root.getAttribute("data-rn-health-signature") === signature && root.querySelector(".rn-health")) return;
    root.setAttribute("data-rn-health-signature", signature);
    if (state.healthRoute === "detail") {
      root.innerHTML = renderHealthDetail();
      return;
    }
    root.innerHTML = '<section class="rn-health"><div class="rn-health-fade"></div><div class="rn-health-inner"><header class="rn-hello"><button type="button" data-rn-action="open-profile" aria-label="我的">' + userIcon() + '</button><span>Hi</span></header><h1>你知道身体总会回到稳态</h1><section class="rn-stamps">' + healthStamp("inspiration", "amateur") + healthStamp("dream", "sleepers") + healthStamp("thought", "steps") + healthStamp("relationship", "gym") + healthStamp("body", "hours") + '</section><section class="rn-week"><div class="rn-week-top"><div><div class="rn-counts"><strong>154</strong><span>Total</span><strong>51</strong><span>Best</span></div><div class="rn-heat">' + heatmap() + '</div></div><div class="rn-radar">◎</div></div><p>本周你早睡5天高精力状态为早上10点至11点，基础代谢率还剩30%未消耗，</p><button type="button" data-rn-action="health-more">更多</button></section><section class="rn-ai"><b>AI 身体翻译</b><button type="button" data-rn-action="health-detail">详情</button></section><section class="rn-metrics"><article><span>平均准备度</span><strong>88</strong></article><article><span>睡眠负债</span><strong>+2</strong></article></section><section class="rn-extra"><article><span>信息负债</span><strong>+6</strong><p>今天未处理的信息积压偏高，适合把重要对话集中到一个时段处理。</p></article><article><span>平均值</span><strong>76%</strong><p>你的稳定区间仍在恢复，睡眠和早间状态是本周最有价值的线索。</p></article></section></div>' + (state.profile ? profileSheet() : "") + (state.toast ? '<div class="rn-toast rn-health-toast">' + esc(state.toast) + '</div>' : '') + '</section>';
  }

  function userIcon() {
    return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><path d="M18 20a6 6 0 0 0-12 0"/><circle cx="12" cy="10" r="4"/></svg>';
  }

  function addCard() {
    var theme = themeById(state.themeId);
    var userText = state.messages.filter(function (message) { return message.role === "user"; }).map(function (message) { return message.text; }).join(" ").trim();
    var card = {
      id: uid(),
      templateId: theme.stampId,
      sourceCardId: theme.id,
      title: theme.tag.replace("你的", "") + "记录",
      prompt: theme.prompt,
      answerPreview: userText || "这张卡片来自一次新的探索对话，关联内容已保存。",
      relatedMessages: state.messages.slice(),
      createdAt: new Date().toISOString()
    };
    var cards = loadCards().filter(function (item) { return item && item.id !== card.id; });
    cards.unshift(card);
    saveCards(cards);
    state.cardId = card.id;
  }

  function clearToastSoon() {
    clearTimeout(toastTimer);
    toastTimer = setTimeout(function () {
      state.toast = "";
      saveState();
      renderCurrent();
    }, 1700);
  }

  function renderCurrent() {
    syncLabels();
    renderExplore();
    renderHealth();
  }

  function scheduleRender(delay) {
    clearTimeout(renderTimer);
    renderTimer = setTimeout(renderCurrent, delay || 60);
  }

  function handleAction(action, target) {
    if (action === "open-card") {
      var openedTheme = themeById(target.getAttribute("data-theme") || "relationship");
      state.themeId = openedTheme.id;
      state.route = "chat";
      state.messages = initialMessages(openedTheme);
      state.toast = "";
      saveState();
      switchTo("vitals");
      renderExplore();
    } else if (action === "open-chat") {
      var theme = themeById(target.getAttribute("data-theme") || state.themeId);
      state.themeId = theme.id;
      state.route = "chat";
      state.messages = initialMessages(theme);
      state.toast = "";
      saveState();
      switchTo("vitals");
      renderExplore();
    } else if (action === "back-detail") {
      state.route = "home";
      saveState();
      renderExplore();
    } else if (action === "back-home") {
      state.route = "home";
      state.toast = "";
      saveState();
      renderExplore();
    } else if (action === "complete-chat") {
      var input = document.querySelector("[data-rn-chat-input]");
      if (input && input.value.trim()) {
        state.messages.push({ role: "user", text: input.value.trim(), createdAt: new Date().toISOString() });
        state.messages.push({ role: "ai", text: reply(input.value.trim()), createdAt: new Date().toISOString() });
        input.value = "";
      }
      addCard();
      state.route = "feedback";
      saveState();
      renderExplore();
    } else if (action === "share") {
      var text = "我完成了一次 Vitora 连续记录，已经收集到我的健康。";
      if (navigator.share) {
        navigator.share({ title: "Vitora 连续记录", text: text }).then(function () { state.toast = "已打开分享"; saveState(); renderExplore(); clearToastSoon(); }).catch(function () { state.toast = "分享已取消"; saveState(); renderExplore(); clearToastSoon(); });
      } else if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(text).then(function () { state.toast = "已复制分享内容"; saveState(); renderExplore(); clearToastSoon(); }).catch(function () { state.toast = "已生成分享内容"; saveState(); renderExplore(); clearToastSoon(); });
      } else {
        state.toast = "已生成分享内容";
        saveState();
        renderExplore();
        clearToastSoon();
      }
    } else if (action === "finish") {
      state.route = "home";
      state.toast = "已收集到我的健康";
      state.healthRoute = "home";
      saveState();
      switchTo("health");
      renderHealth();
      clearToastSoon();
    } else if (action === "open-profile") {
      state.profile = true;
      saveState();
      renderHealth();
    } else if (action === "close-profile") {
      state.profile = false;
      saveState();
      renderHealth();
    } else if (action === "health-more" || action === "health-detail") {
      state.healthRoute = "detail";
      state.healthTab = "summary";
      state.toast = "";
      saveState();
      renderHealth();
    } else if (action === "health-back") {
      state.healthRoute = "home";
      state.reminder = "";
      state.toast = "";
      saveState();
      renderHealth();
    } else if (action === "health-tab") {
      state.healthRoute = "detail";
      state.healthTab = target.getAttribute("data-tab") || "summary";
      state.reminder = "";
      state.toast = "";
      saveState();
      renderHealth();
    } else if (action === "reminder-open") {
      state.reminder = target.getAttribute("data-time") || "09:30";
      state.toast = "";
      saveState();
      renderHealth();
    } else if (action === "reminder-confirm") {
      state.toast = "已设置 " + (state.reminder || "09:30") + " 提醒";
      state.reminder = "";
      saveState();
      renderHealth();
      clearToastSoon();
    }
  }

  function installStyle() {
    if (document.getElementById("vitoraNativeSimulatorPatchStyle")) return;
    var style = document.createElement("style");
    style.id = "vitoraNativeSimulatorPatchStyle";
    style.textContent = ".rn-native-explore-host[data-native-sim-explore='1']{position:absolute!important;inset:0!important;z-index:120!important;height:100dvh!important;min-height:100dvh!important;overflow:hidden!important;margin:0!important;padding:0!important;background:linear-gradient(180deg,#858e89,#515a56)!important;color:#fff!important;pointer-events:auto!important}.phone[data-tab='vitals'] .topbar{opacity:1!important;pointer-events:auto!important}.rn-app{position:absolute;inset:0;overflow:hidden;font-family:-apple-system,BlinkMacSystemFont,'SF Pro Display','PingFang SC',sans-serif}.rn-home,.rn-detail,.rn-chat,.rn-feedback{position:absolute;inset:0;overflow:hidden}.rn-home{padding:calc(env(safe-area-inset-top,0px) + 74px) 24px calc(env(safe-area-inset-bottom,0px) + 94px);background:linear-gradient(180deg,#8b938d,#525b57)}.rn-home header,.rn-detail header{display:flex;justify-content:flex-end;margin-bottom:20px}.rn-dots{display:flex;gap:10px;align-items:center}.rn-dots i{width:9px;height:9px;border-radius:50%;background:rgba(255,255,255,.38)}.rn-dots i.active{background:#dfff68}.rn-card-list{position:absolute;left:24px;right:24px;top:calc(env(safe-area-inset-top,0px) + 118px);bottom:calc(env(safe-area-inset-bottom,0px) + 100px);overflow-y:auto;padding-bottom:96px;scroll-snap-type:y proximity;-webkit-overflow-scrolling:touch;touch-action:pan-y}.rn-card{position:relative;display:block;width:100%;height:556px;margin:0 0 24px;border:0;border-radius:26px;overflow:hidden;text-align:left;color:#fff;background:#68726d;box-shadow:0 24px 60px rgba(16,22,22,.28);scroll-snap-align:start;appearance:none}.rn-card img{position:absolute;inset:0;width:100%;height:100%;object-fit:cover;filter:saturate(.9) brightness(.82)}.rn-card:after{content:'';position:absolute;inset:0;background:linear-gradient(180deg,rgba(11,18,18,.03),rgba(11,18,18,.18) 47%,rgba(11,18,18,.72))}.rn-gray img{opacity:.18;filter:grayscale(1) brightness(1.55)}.rn-gray:after{background:linear-gradient(180deg,rgba(152,160,154,.54),rgba(71,80,76,.84))}.rn-pill{position:absolute;left:18px;top:20px;z-index:2;height:34px;border-radius:999px;padding:0 24px;display:inline-flex;align-items:center;background:rgba(255,255,255,.22);box-shadow:inset 0 0 0 1px rgba(255,255,255,.16);font-size:15px;font-weight:860;color:#fff}.rn-card-orb{display:none}.rn-orb{width:198px;height:198px;border-radius:50%;display:grid;place-items:center;background:radial-gradient(circle at 50% 45%,#fff 0 58%,#e7e9e5 61%,rgba(255,255,255,.64) 70%,rgba(255,255,255,0) 72%);box-shadow:inset 0 0 0 14px rgba(255,255,255,.18),0 0 0 14px rgba(255,255,255,.18)}.rn-orb>div{width:120px;height:98px;position:relative}.rn-orb i{position:absolute;width:8px;height:18px;border-radius:999px;background:var(--c);opacity:.86;transform:translate(var(--x),var(--y)) rotate(var(--r))}.rn-card-copy{position:absolute;left:24px;right:24px;bottom:76px;z-index:2}.rn-card-copy small{display:block;margin-bottom:8px;font-size:17px;line-height:1.25}.rn-card-copy h1{margin:0;font-size:36px;line-height:1.08;font-weight:940}.rn-card-copy p{margin:12px 0 0;font-size:15px;line-height:1.45;font-weight:780;color:rgba(255,255,255,.78)}.rn-card button{position:absolute;left:20px;right:20px;bottom:20px;z-index:4;height:54px;border:0;border-radius:999px;background:rgba(255,255,255,.24);color:rgba(255,255,255,.88);font-size:17px;font-weight:850;text-align:left;padding:0 24px}.rn-detail{padding:calc(env(safe-area-inset-top,0px) + 92px) 24px calc(env(safe-area-inset-bottom,0px) + 106px);background:linear-gradient(180deg,#777f7a,#515a55);overflow-y:auto;-webkit-overflow-scrolling:touch;touch-action:pan-y}.rn-detail-card{position:relative;min-height:606px;border-radius:26px;overflow:hidden;background:rgba(104,114,109,.68);box-shadow:0 24px 60px rgba(16,22,22,.26)}.rn-detail-card:after{content:'';position:absolute;inset:0;background:linear-gradient(180deg,rgba(255,255,255,.10),rgba(18,25,24,.48))}.rn-detail-orb{position:absolute;left:50%;top:160px;z-index:2;transform:translateX(-50%) scale(1.28)}.rn-detail-copy{position:absolute;left:28px;right:28px;bottom:94px;z-index:2}.rn-detail-copy p{margin:0 0 12px;font-size:23px;line-height:1.35}.rn-detail-copy h1{margin:0;font-size:39px;line-height:1.1;font-weight:940}.rn-detail-copy span{display:block;margin-top:14px;font-size:19px;line-height:1.35;color:rgba(255,255,255,.82)}.rn-detail-card button{position:absolute;left:24px;right:24px;bottom:26px;z-index:3;height:56px;border:0;border-radius:999px;background:rgba(255,255,255,.22);color:rgba(255,255,255,.92);text-align:left;padding:0 24px;font-size:18px;font-weight:850}.rn-recent{height:290px;margin-top:24px;border-radius:26px;background:rgba(255,255,255,.10);padding:24px;color:#fff}.rn-recent .rn-pill{position:static;width:max-content;margin-bottom:72px}.rn-recent h2{margin:0;font-size:25px;line-height:1.18}.rn-recent p{margin:18px 0 0;font-size:15px;line-height:1.6;color:rgba(255,255,255,.78)}.rn-chat{background:linear-gradient(154deg,#fbfdfd,#eef9f7 52%,#d7f3ef);color:#1b2324;padding:calc(env(safe-area-inset-top,0px) + 34px) 18px calc(env(safe-area-inset-bottom,0px) + 18px)}.rn-chat header{height:64px;display:flex;align-items:center;justify-content:space-between}.rn-chat header button{width:52px;height:52px;border:0;border-radius:50%;background:rgba(255,255,255,.50);font-size:35px}.rn-chat header b{height:46px;min-width:118px;border-radius:999px;background:rgba(255,255,255,.78);display:grid;place-items:center;font-size:18px;font-weight:760}.rn-messages{position:absolute;left:18px;right:18px;top:calc(env(safe-area-inset-top,0px) + 138px);bottom:calc(env(safe-area-inset-bottom,0px) + 104px);overflow:auto;display:flex;flex-direction:column;gap:28px;-webkit-overflow-scrolling:touch}.rn-msg{max-width:302px;border-radius:18px;padding:15px 18px;font-size:17px;line-height:1.52;background:rgba(255,255,255,.82);box-shadow:0 12px 30px rgba(70,100,96,.07)}.rn-msg.user{align-self:flex-end;min-width:96px;min-height:46px;background:rgba(255,255,255,.72)}.rn-composer{position:absolute;left:18px;right:18px;bottom:calc(env(safe-area-inset-bottom,0px) + 24px);height:64px;display:flex;gap:10px}.rn-composer form{flex:1;height:64px;border-radius:999px;background:rgba(255,255,255,.88);display:flex;align-items:center;padding:0 8px 0 20px}.rn-composer input{flex:1;border:0;outline:0;background:transparent;font-size:19px}.rn-composer form button{width:42px;height:42px;border:0;background:transparent;font-size:22px}.rn-done{width:64px;height:64px;border:0;border-radius:50%;background:rgba(255,255,255,.18);box-shadow:inset 0 0 0 1px rgba(255,255,255,.72);color:#9ca29e;font-size:38px}.rn-feedback{padding:calc(env(safe-area-inset-top,0px) + 62px) 26px calc(env(safe-area-inset-bottom,0px) + 48px);background:linear-gradient(180deg,#717a75,#505955);text-align:center}.rn-feedback header{display:flex;align-items:center;justify-content:space-between;margin-bottom:44px}.rn-feedback header button{width:48px;height:48px;border:1px solid rgba(255,255,255,.34);border-radius:50%;background:rgba(255,255,255,.10);color:#fff;font-size:28px}.rn-feedback-stamp{width:230px;margin:0 auto 42px}.rn-feedback-stamp svg{width:100%;height:auto}.rn-streak{display:grid;grid-template-columns:1fr 1fr;gap:28px;margin:0 24px 34px;text-align:left}.rn-streak strong,.rn-streak span{white-space:pre-line}.rn-streak strong{font-size:24px;line-height:1.4}.rn-streak span{font-size:18px;line-height:1.45;color:rgba(255,255,255,.82)}.rn-feedback-actions{display:grid;gap:8px;margin:0 auto;max-width:310px}.rn-feedback-actions button{height:38px;border:0;border-radius:999px;background:rgba(255,255,255,.27);color:#fff;font-size:17px}.screen[data-screen='health']{background:#fff!important;overflow:hidden!important}.screen[data-screen='health']>.rn-health{position:absolute;inset:0;overflow-y:auto;background:linear-gradient(180deg,#d5d6ec,#f7f5fb 37%,#fff 70%);-webkit-overflow-scrolling:touch;touch-action:pan-y}.rn-health-inner{position:relative;min-height:1180px;padding:calc(env(safe-area-inset-top,0px) + 64px) 24px calc(env(safe-area-inset-bottom,0px) + 178px);z-index:2}.rn-health-fade{position:absolute;left:-12%;right:-12%;top:0;height:430px;background:radial-gradient(circle at 50% 6%,rgba(255,255,255,.74),rgba(255,255,255,0) 34%),linear-gradient(180deg,rgba(200,202,230,.88),rgba(255,255,255,0));pointer-events:none}.rn-hello{display:flex;align-items:center;gap:12px;margin:0 0 9px 10px}.rn-hello button{width:52px;height:52px;border:0;border-radius:50%;display:grid;place-items:center;background:rgba(238,240,236,.84);color:#171a1c}.rn-hello svg{width:30px;height:30px}.rn-hello span{font-size:38px;font-style:italic;font-weight:780;color:#fff;text-shadow:0 4px 9px rgba(112,111,142,.30)}.rn-health h1{margin:0 0 16px 10px;color:#fff;font-size:28px;line-height:1.16;font-weight:940}.rn-stamps{position:relative;height:300px}.rn-health-stamp{position:absolute;width:95px;filter:drop-shadow(0 7px 8px rgba(58,64,80,.10))}.rn-health-stamp svg{width:100%;height:auto}.rn-health-stamp.amateur{left:22px;top:8px;transform:rotate(-8deg)}.rn-health-stamp.sleepers{left:137px;top:0;width:108px;transform:rotate(7deg)}.rn-health-stamp.steps{right:2px;top:44px;width:105px;transform:rotate(-8deg)}.rn-health-stamp.gym{left:90px;top:154px;width:84px}.rn-health-stamp.hours{left:199px;top:172px;width:85px}.rn-week{position:relative;overflow:hidden;border-radius:23px;background:#fff;box-shadow:0 11px 18px rgba(35,39,44,.26);margin:2px 0 28px}.rn-week-top{min-height:148px;padding:14px 12px;background:linear-gradient(135deg,#c3bfd1,#9d8ede);color:#fff;display:grid;grid-template-columns:1.08fr .92fr;gap:10px}.rn-counts{display:grid;grid-template-columns:auto auto auto auto;gap:6px 8px;align-items:end;margin-bottom:13px}.rn-counts strong{font-size:42px;line-height:.85}.rn-counts span{font-size:12px;opacity:.82}.rn-heat{display:grid;grid-template-columns:repeat(10,12px);grid-auto-rows:12px;gap:7px}.rn-heat i{border-radius:3px;background:#d8d9dc}.rn-heat i.on{background:#45bd5e}.rn-heat i.dark{background:#2f7d45}.rn-heat i.bright{background:#4af25c}.rn-radar{display:grid;place-items:center;font-size:96px;color:rgba(255,255,255,.56)}.rn-week p{padding:13px 13px 46px;margin:0;font-size:23px;line-height:1.24;font-weight:930;color:#4a5658}.rn-week button{position:absolute;left:50%;bottom:12px;transform:translateX(-50%);border:0;background:transparent;color:#8a8c90;font-size:18px;font-weight:900}.rn-ai{display:flex;align-items:center;justify-content:space-between;margin:0 12px 14px}.rn-ai b{font-size:19px;color:#9aa4a6}.rn-ai button{height:28px;border:0;border-radius:999px;padding:0 19px;background:#ded3ff;color:#7d7785;font-size:15px;font-weight:920}.rn-metrics{display:grid;grid-template-columns:1fr 1fr;gap:20px;padding:0 6px 16px}.rn-metrics article,.rn-extra article{border-radius:14px;background:#fff;box-shadow:0 9px 13px rgba(72,79,82,.20);padding:14px;text-align:center}.rn-metrics span,.rn-extra span{display:block;color:#a7b0b2;font-size:17px;font-weight:900}.rn-metrics strong{display:block;color:#4b5758;font-size:54px;line-height:.95}.rn-extra{display:grid;gap:12px;padding:4px 6px 0}.rn-extra article{text-align:left;border-radius:18px}.rn-extra strong{display:block;margin-top:6px;color:#4b5758;font-size:34px}.rn-extra p{margin:8px 0 0;font-size:13px;line-height:1.45;color:rgba(75,87,88,.56)}.rn-health-detail{background:linear-gradient(180deg,#eeeafe,#fff 44%)!important;color:#20243a}.rn-health-detail-inner{min-height:1060px;padding-bottom:56px}.rn-health-detail-head{display:flex;align-items:center;justify-content:space-between;margin-bottom:12px}.rn-health-detail-head button{width:52px;height:52px;border:0;border-radius:50%;background:#fff;font-size:36px;color:#20243a}.rn-health-detail-head b{font-size:21px}.rn-health-detail-head i{width:52px}.rn-health-chips{display:grid;grid-template-columns:repeat(4,1fr);gap:10px;margin-bottom:14px}.rn-health-chips span{height:72px;border-radius:50%;display:grid;place-items:center;background:#fff;color:#6d737c;font-weight:900;box-shadow:0 8px 20px rgba(120,116,150,.12)}.rn-health-chips span.active{background:#e9f3ff}.rn-health-chips b{font-size:24px;color:#111827}.rn-health-detail-tabs{height:42px;border-radius:999px;padding:4px;background:#efecfa;display:grid;grid-template-columns:repeat(3,1fr);gap:4px;margin-bottom:18px}.rn-health-detail-tabs button{border:0;border-radius:999px;background:transparent;font-weight:900;color:#8a879c}.rn-health-detail-tabs button.active{background:#fff;color:#25253a}.rn-detail-summary,.rn-detail-sleep,.rn-detail-cycle{border-radius:24px;background:#fff;padding:18px;margin-bottom:18px}.rn-summary-radar{width:184px;height:184px;border-radius:50%;margin:8px auto 18px;background:radial-gradient(circle,#c9f4dc 0 35%,rgba(125,92,255,.08) 36%);display:grid;place-items:center;color:#fff;font-size:44px;font-weight:900;border:4px solid #fff;box-shadow:0 0 0 1px rgba(125,92,255,.08)}.rn-detail-summary h2{color:#9ca3af}.rn-detail-summary strong{font-size:52px;color:#24b879}.rn-detail-summary p,.rn-detail-sleep p,.rn-detail-cycle p{font-size:16px;line-height:1.55;color:#697287}.rn-detail-heat{display:grid;grid-template-columns:repeat(10,12px);gap:7px;background:#aa9cdb;border-radius:20px;padding:18px;margin-top:16px}.rn-sleep-bars{height:84px;display:flex;align-items:center;gap:5px;margin:18px 0 28px}.rn-sleep-bars i{height:34px;flex:1;border-radius:6px;background:#6c63d5}.rn-sleep-bars i:nth-child(2n){background:#a67cf0}.rn-sleep-bars i:nth-child(3n){background:#d34bd2}.rn-detail-sleep h2{color:#7d8396}.rn-detail-sleep strong{font-size:58px;color:#7d5cff}.rn-detail-sleep small{font-size:22px}.rn-cycle-ring{width:210px;height:210px;border-radius:50%;margin:0 auto 18px;display:grid;place-items:center;background:conic-gradient(#7c5cff 0 28%,#f36f9f 28% 45%,#ffb13e 45% 66%,#35cbc7 66% 100%);color:rgba(255,255,255,.82);font-size:54px}.rn-detail-cycle h2 strong{font-size:56px;color:#9b7cff}.rn-cycle-progress{height:14px;border-radius:999px;overflow:hidden;display:flex;margin-top:18px}.rn-cycle-progress i:nth-child(1){flex:13;background:#38c9c3}.rn-cycle-progress i:nth-child(2){flex:2;background:#ffb643}.rn-cycle-progress i:nth-child(3){flex:13;background:#7d5cf5}.rn-cycle-progress i:nth-child(4){flex:5;background:#ef6b9c}.rn-health-advice{border-radius:24px;background:#fff;border:1px solid #eceafa;padding:18px}.rn-health-advice h2{margin:0 0 10px;font-size:24px}.rn-health-advice article{display:grid;grid-template-columns:58px 1fr 68px;gap:10px;align-items:center;border-top:1px solid #efedf8;padding:10px 0}.rn-health-advice b{color:#825dff;font-size:19px}.rn-health-advice span{font-weight:900}.rn-health-advice button{height:34px;border-radius:999px;border:1px solid #9b7cff;background:#fff;color:#825dff;font-weight:900}.rn-reminder{position:fixed;inset:0;z-index:300;background:rgba(20,22,28,.26);display:flex;align-items:flex-end}.rn-reminder article{width:100%;background:#fff;border-radius:26px 26px 0 0;padding:22px;text-align:center}.rn-reminder strong{display:block;font-size:48px;margin:14px 0;color:#161b2b}.rn-reminder button{height:48px;border:0;border-radius:24px;background:#171b27;color:#fff;font-size:16px;font-weight:900;padding:0 42px}.rn-profile-layer{position:fixed;inset:0;z-index:260;background:#000;display:flex;align-items:flex-end}.rn-profile-status{position:fixed;left:30px;right:16px;top:20px;z-index:262;display:flex;justify-content:space-between;color:#fff}.rn-profile-status span{height:31px;border-radius:999px;padding:0 15px;display:flex;align-items:center;background:#ff454b;font-size:21px;font-weight:930}.rn-profile-status b{font-size:24px;letter-spacing:.12em}.rn-profile{position:relative;width:100%;height:calc(100dvh - 48px);overflow:auto;padding:calc(env(safe-area-inset-top,0px) + 86px) 26px calc(env(safe-area-inset-bottom,0px) + 28px);background:linear-gradient(180deg,#cfd1ea,#f7f5fb 45%,#fff);border-radius:22px 22px 0 0;color:#15161b;animation:rnSheet .26s cubic-bezier(.16,1,.3,1)}.rn-profile-x{position:absolute;right:25px;top:76px;width:44px;height:44px;border:0;background:transparent;font-size:38px}.rn-profile-mini{font-size:27px;word-spacing:26px}.rn-profile-hero{display:flex;align-items:center;justify-content:space-between;margin:200px 0 32px}.rn-profile-hero h1{margin:0;color:#000;font-size:36px}.rn-profile-hero p{margin:13px 0 0;color:#8d8b96;font-size:20px;font-weight:900}.rn-avatar{width:84px;height:84px;border-radius:50%;display:grid;place-items:center;background:rgba(255,255,255,.44);font-size:45px}.rn-plus{height:67px;border-radius:11px;background:#222a34;color:#fff;padding:0 17px;margin-bottom:27px;display:flex;align-items:center;justify-content:space-between}.rn-plus span{display:block;color:rgba(255,255,255,.52)}.rn-plus button{height:34px;border:0;border-radius:999px;background:#e3bf53}.rn-profile-grid{display:grid;grid-template-columns:1fr 1fr;gap:66px;margin-bottom:18px}.rn-profile-grid button{height:93px;border:0;border-radius:13px;background:#d8d8d8;font-size:24px;font-weight:930}.rn-profile-grid span{display:block;color:#d8ebff}.rn-watch{height:60px;border:0;border-radius:15px;background:#fff;width:100%;display:grid;grid-template-columns:40px 1fr 24px;align-items:center;text-align:left;padding:0 18px}.rn-watch i{width:18px;height:18px;border:2px solid #cbd7e5;border-radius:3px}.rn-watch small{display:block;color:#b3b1bc;font-size:16px}.rn-toast{position:fixed;left:50%;bottom:calc(env(safe-area-inset-bottom,0px) + 104px);z-index:280;transform:translateX(-50%);padding:10px 18px;border-radius:999px;background:rgba(28,34,34,.82);color:#fff;font-size:14px;font-weight:900;white-space:nowrap}@keyframes rnSheet{from{transform:translateY(100%)}to{transform:translateY(0)}}@media(max-height:760px){.rn-card{height:500px}.rn-card-list{top:96px}.rn-detail{padding-top:70px}.rn-detail-card{min-height:552px}.rn-health-inner{min-height:1110px;padding-top:48px}}";
    document.head.appendChild(style);
  }

  function onActionEvent(event) {
    var target = event.target && event.target.closest ? event.target.closest("[data-rn-action]") : null;
    if (!target) {
      var tab = event.target && event.target.closest ? event.target.closest(".tab[data-tab]") : null;
      if (tab) setTimeout(renderCurrent, 30);
      return;
    }
    if (event.type === "click" && Date.now() - lastActionAt < 340) return;
    lastActionAt = Date.now();
    event.preventDefault();
    event.stopPropagation();
    if (event.stopImmediatePropagation) event.stopImmediatePropagation();
    handleAction(target.getAttribute("data-rn-action"), target);
  }

  document.addEventListener("pointerup", onActionEvent, true);
  document.addEventListener("click", onActionEvent, true);
  document.addEventListener("submit", function (event) {
    var form = event.target && event.target.closest ? event.target.closest("[data-rn-chat-form]") : null;
    if (!form) return;
    event.preventDefault();
    event.stopPropagation();
    var input = form.querySelector("[data-rn-chat-input]");
    if (input && input.value.trim()) {
      state.messages.push({ role: "user", text: input.value.trim(), createdAt: new Date().toISOString() });
      state.messages.push({ role: "ai", text: reply(input.value.trim()), createdAt: new Date().toISOString() });
      input.value = "";
      saveState();
      renderExplore();
    }
  }, true);

  document.addEventListener("keydown", function (event) {
    if (event.key === "Escape" && state.profile) {
      state.profile = false;
      saveState();
      renderHealth();
    }
  }, true);

  installStyle();
  syncLabels();
  postOnboardingState(true);
  ensureOnboardingVisible();
  window.__vitoraNativeSimulatorPatchRender = renderCurrent;
  window.__vitoraNativeSimulatorPatchScheduleRender = scheduleRender;
  var initial = firstTab();
  if (initial === "health") switchTo("health");
  else if (initial === "today" || !initial) switchTo("today");
  else if (initial === "vitals" || !initial) switchTo("vitals");
  renderCurrent();
  setTimeout(renderCurrent, 80);
  setTimeout(renderCurrent, 260);
  setTimeout(renderCurrent, 800);
  var guardCount = 0;
  var guardTimer = setInterval(function () {
    guardCount += 1;
    renderCurrent();
    if (guardCount > 48) clearInterval(guardTimer);
  }, 250);
  setInterval(renderCurrent, 2400);
  setInterval(function () { ensureOnboardingVisible(); }, 500);
  try {
    var observed = phone() || document.body;
    new MutationObserver(function () {
      scheduleRender(80);
      ensureOnboardingVisible();
    }).observe(observed, { childList: true, subtree: true, attributes: true, attributeFilter: ["data-tab", "class"] });
  } catch (_) {}

})();
true;
`;
