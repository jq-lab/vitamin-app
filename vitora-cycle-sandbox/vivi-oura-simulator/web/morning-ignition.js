(function () {
  var MORNING_ASSET = "./assets/companion/amelia-earhart-electra-public-domain.jpg";
  var SESSION_ID = "morning-sun-map";
  var STORAGE_KEY = "vivi:morningIgnition:lastDone";
  var steps = [
    ["打开驾驶舱", "坐起来，把脚放到地面。"],
    ["检查光线", "拉开窗帘，或打开一盏柔和的灯。"],
    ["给身体加水", "喝三口水，不评价自己昨晚睡得怎样。"],
    ["推离停机坪", "整理被子的一角，告诉身体：床已经结束了。"],
    ["进入跑道", "站起来，选今天第一件很小的事。"]
  ];
  var explore = [
    ["晨间点火", "先从床边启动身体"],
    ["日光检查", "用自然光校准节律"],
    ["三口水", "给身体一个温和信号"],
    ["第一件小事", "把目标缩到十分钟内"]
  ];

  function esc(value) {
    return String(value == null ? "" : value).replace(/[&<>"']/g, function (ch) {
      return {"&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;"}[ch];
    });
  }

  function addStyles() {
    if (document.getElementById("morningIgnitionStyleV1")) return;
    var style = document.createElement("style");
    style.id = "morningIgnitionStyleV1";
    style.textContent = [
      ".morning-ignition-hero-v1{position:relative;width:100%;border:0;text-align:left;color:#fff;cursor:pointer;overflow:hidden;background:linear-gradient(145deg,#172d31 0%,#39433c 48%,#c89158 100%)!important;box-shadow:inset 0 0 0 1px rgba(255,255,255,.16),0 18px 38px rgba(8,19,24,.28)}",
      ".morning-ignition-hero-v1:before{content:\"\";position:absolute;right:-42px;top:-58px;width:220px;height:220px;border-radius:50%;background:radial-gradient(circle,rgba(216,247,150,.42),transparent 68%)}",
      ".morning-ignition-hero-v1 h2,.morning-ignition-hero-v1 p,.morning-ignition-hero-v1 span,.morning-hero-cta-v1{position:relative;z-index:1}",
      ".morning-hero-cta-v1{display:inline-flex;margin-top:18px;height:46px;align-items:center;border-radius:999px;padding:0 18px;background:#d8f796;color:#172528;font-size:14px;font-weight:920}",
      ".morning-ignition-panel-v1{display:grid;gap:13px}.morning-startup-card-v1,.morning-data-card-v1,.morning-step-card-v1,.morning-source-card-v1,.morning-explore-card-v1{border:0;text-align:left;color:#fff;border-radius:24px;background:rgba(255,255,255,.09);box-shadow:inset 0 0 0 1px rgba(255,255,255,.09);backdrop-filter:blur(20px);-webkit-backdrop-filter:blur(20px)}",
      ".morning-startup-card-v1{padding:18px;display:grid;gap:9px;background:linear-gradient(145deg,#182b2f,#4a5644 56%,#c89158)}.morning-startup-card-v1 em{font-style:normal;font-size:12px;font-weight:900;color:#d8f796}.morning-startup-card-v1 strong{font-size:24px;line-height:1.16}.morning-startup-card-v1 span{font-size:13px;line-height:1.45;color:rgba(255,255,255,.78);font-weight:720}.morning-startup-card-v1 b{justify-self:start;margin-top:4px;border-radius:999px;padding:10px 14px;background:#d8f796;color:#172528;font-size:13px}",
      ".morning-data-card-v1{padding:17px;background:#fff;color:#172020}.morning-data-card-v1 span{font-size:12px;font-weight:900;color:rgba(23,32,32,.46)}.morning-data-card-v1 strong{display:block;margin-top:3px;font-size:40px;line-height:1;color:#172020}.morning-data-card-v1 p{margin:8px 0 0!important;color:rgba(23,32,32,.60)!important;font-size:13px!important;line-height:1.48!important}.morning-signal-row-v1{display:flex;gap:8px;flex-wrap:wrap;margin-top:12px}.morning-signal-row-v1 i{font-style:normal;border-radius:999px;padding:7px 10px;background:rgba(23,32,32,.07);font-size:12px;font-weight:820;color:#172020}",
      ".morning-step-grid-v1{display:grid;gap:10px}.morning-step-card-v1{padding:15px;display:grid;grid-template-columns:38px 1fr;column-gap:12px;row-gap:3px;background:#fff;color:#172020}.morning-step-card-v1 i{grid-row:1/3;width:34px;height:34px;border-radius:50%;display:grid;place-items:center;background:#d8f796;color:#172528;font-style:normal;font-weight:920}.morning-step-card-v1 strong{font-size:17px;line-height:1.1}.morning-step-card-v1 span{font-size:12px;line-height:1.42;color:rgba(23,32,32,.58);font-weight:700}",
      ".morning-source-card-v1{display:grid;grid-template-columns:96px 1fr;gap:12px;padding:12px;background:#182528;color:#fff}.morning-source-card-v1 img{width:96px;height:118px;border-radius:18px;object-fit:cover;background:#334}.morning-source-card-v1 span{font-size:10px;font-weight:900;color:#d8f796}.morning-source-card-v1 strong{display:block;margin-top:4px;font-size:16px;line-height:1.18}.morning-source-card-v1 p{margin:6px 0 0!important;font-size:12px!important;line-height:1.45!important;color:rgba(255,255,255,.68)!important}",
      ".morning-explore-grid-v1{display:grid;grid-template-columns:1fr 1fr;gap:10px}.morning-explore-card-v1{padding:14px;background:#fff;color:#172020}.morning-explore-card-v1 strong{display:block;font-size:15px}.morning-explore-card-v1 span{display:block;margin-top:6px;font-size:12px;line-height:1.35;color:rgba(23,32,32,.54);font-weight:700}",
      ".morning-sheet-v1{background:linear-gradient(180deg,#f7faf4,#edf3ef)!important}.morning-sheet-hero-v1{display:grid;grid-template-columns:104px 1fr;gap:13px;align-items:center;margin:16px 0;border-radius:22px;padding:12px;background:#172428;color:#fff}.morning-sheet-hero-v1 img{width:104px;height:132px;border-radius:18px;object-fit:cover}.morning-sheet-hero-v1 span{font-size:10px;font-weight:900;color:#d8f796}.morning-sheet-hero-v1 strong{display:block;margin-top:5px;font-size:18px;line-height:1.18}.morning-sheet-hero-v1 p{margin:6px 0 0!important;color:rgba(255,255,255,.70)!important;font-size:12px!important}",
      ".morning-reason-list-v1{display:grid;gap:8px;margin-bottom:14px}.morning-reason-list-v1 div{border-radius:16px;padding:11px 12px;background:#fff;color:#172020;font-size:12px;line-height:1.38;font-weight:760;box-shadow:inset 0 0 0 1px rgba(23,32,32,.05)}",
      ".morning-sheet-actions-v1{display:grid;grid-template-columns:1fr 96px;gap:10px;margin-top:14px}.morning-sheet-actions-v1 button{height:48px;border:0;border-radius:999px;font-size:14px;font-weight:900}.morning-sheet-actions-v1 .primary{background:#172020;color:#fff}.morning-sheet-actions-v1 .ghost{background:#fff;color:#172020}.morning-sheet-status-v1{min-height:18px;margin-top:10px;text-align:center;font-size:12px;color:#418f80;font-weight:840}"
    ].join("\n");
    document.head.appendChild(style);
  }

  function categoryRow(active) {
    var cats = [["ai", "AI 推荐"], ["sleep", "助眠"], ["meditation", "冥想"], ["focus", "专注"]];
    return '<div class="charge-category-row">' + cats.map(function (item) {
      return '<button class="charge-category-pill ' + (item[0] === active ? "active" : "") + '" type="button" data-charge-category="' + item[0] + '">' + esc(item[1]) + "</button>";
    }).join("") + "</div>";
  }

  function renderHero() {
    return '<div class="charge-hero-rail" id="chargeHeroRailV7"><button class="charge-hero-slide morning-ignition-hero-v1 active" type="button" data-morning-ignition-sheet><span class="vitals-star-tag">AI 为你选</span><h2>身体还在停机坪，先做 8 分钟晨间点火</h2><p>昨晚睡眠中断 + HRV 偏低，今天先不用逼自己高效。</p><div class="morning-hero-cta-v1">开始晨间点火</div></button></div><div class="charge-hero-dots"><button class="charge-hero-dot active" type="button" aria-label="AI 为你选"></button></div>';
  }

  function renderContent() {
    var active = typeof S !== "undefined" && S.chargeCategoryV7 ? S.chargeCategoryV7 : "ai";
    return categoryRow(active) + '<div class="morning-ignition-panel-v1"><div class="charge-section-k">今日精准推荐 · 睡眠 / HRV / 周期</div><button class="morning-startup-card-v1" type="button" data-morning-ignition-sheet><em>AI 为你选</em><strong>身体还在停机坪，先做 8 分钟晨间点火</strong><span>昨晚睡眠中断 + HRV 偏低，今天先不用逼自己高效。</span><b>开始晨间点火</b></button><section class="morning-data-card-v1"><span>晨间启动</span><strong>42%</strong><p>主要来自：睡眠中断 / 醒后心率偏高 / 经前窗口。今天目标不是立刻清醒，而是离开床边。</p><div class="morning-signal-row-v1"><i>睡眠中断</i><i>HRV 偏低</i><i>经前窗口</i></div></section><section class="charge-section"><div class="charge-section-head"><h2>8 分钟起飞前检查</h2><button type="button" data-morning-ignition-sheet>›</button></div><div class="morning-step-grid-v1">' + steps.map(function (step, index) {
      return '<button class="morning-step-card-v1" type="button" data-morning-ignition-sheet><i>' + (index + 1) + "</i><strong>" + esc(step[0]) + "</strong><span>" + esc(step[1]) + "</span></button>";
    }).join("") + '</div></section><section class="morning-source-card-v1"><img src="' + MORNING_ASSET + '" alt=""><div><span>情绪锚点</span><strong>Amelia Earhart · 起飞前检查</strong><p>她不是一睁眼就飞越大洋。每一次起飞，都从检查仪表、确认方向、推离地面开始。</p></div></section><section class="charge-section"><div class="charge-section-head"><h2>还可以探索</h2></div><div class="morning-explore-grid-v1">' + explore.map(function (item) {
      return '<button class="morning-explore-card-v1" type="button" data-morning-ignition-sheet><strong>' + esc(item[0]) + "</strong><span>" + esc(item[1]) + "</span></button>";
    }).join("") + "</div></section></div>";
  }

  function ensureLayer() {
    var layer = document.getElementById("chargePlanLayerV1");
    if (!layer) {
      layer = document.createElement("section");
      layer.id = "chargePlanLayerV1";
      layer.className = "charge-plan-layer-v1";
      document.body.appendChild(layer);
    }
    return layer;
  }

  function renderSheet() {
    var stepHtml = steps.map(function (step, index) {
      return '<div class="morning-step-card-v1"><i>' + (index + 1) + "</i><strong>" + esc(step[0]) + "</strong><span>" + esc(step[1]) + "</span></div>";
    }).join("");
    return '<article class="charge-plan-sheet-v1 morning-sheet-v1" role="dialog" aria-modal="true" aria-label="晨间点火"><header class="vitora-sheet-head-v1"><div><h2>8 分钟晨间点火</h2><p>不是立刻高效，而是陪身体离开床边。</p></div><button class="vitora-sheet-close-v1" type="button" data-charge-plan-close aria-label="关闭">×</button></header><section class="morning-sheet-hero-v1"><img src="' + MORNING_ASSET + '" alt=""><div><span>AMELIA EARHART · PUBLIC DOMAIN</span><strong>每一次起飞，都从停机坪开始。</strong><p>你今天也一样，不需要立刻飞很远。先完成一次起飞前检查。</p></div></section><div class="morning-reason-list-v1"><div>HRV 或恢复信号偏低，先降低启动门槛。</div><div>昨晚睡眠中断，今天不适合用自责硬推。</div><div>经前窗口默认降低刺激，用光线和水分温和启动。</div></div><div class="morning-step-grid-v1">' + stepHtml + '</div><div class="morning-sheet-actions-v1"><button class="primary" type="button" data-morning-ignition-start>开始晨间点火</button><button class="ghost" type="button" data-morning-ignition-done>完成</button></div><div class="morning-sheet-status-v1" data-morning-ignition-status>开始后会播放晨间声场，并保留这 5 个动作。</div></article>';
  }

  function openSheet() {
    addStyles();
    var layer = ensureLayer();
    layer.innerHTML = renderSheet();
    layer.classList.add("open");
    layer.setAttribute("aria-hidden", "false");
  }

  function closeSheet() {
    var layer = document.getElementById("chargePlanLayerV1");
    if (layer) {
      layer.classList.remove("open");
      layer.setAttribute("aria-hidden", "true");
    }
  }

  function start() {
    var status = document.querySelector("[data-morning-ignition-status]");
    if (status) status.textContent = "晨间点火已开始。先坐起来，把脚放到地面。";
    var btn = document.querySelector("[data-morning-ignition-start]");
    if (btn) btn.textContent = "练习进行中";
    if (typeof ssStartSessionV1 === "function") ssStartSessionV1(SESSION_ID);
    else if (typeof startChargeRecommendationV2 === "function" && !startChargeRecommendationV2.__morningIgnitionV1) startChargeRecommendationV2();
  }

  function done() {
    try {
      localStorage.setItem(STORAGE_KEY, new Date().toISOString());
    } catch (_) {}
    var status = document.querySelector("[data-morning-ignition-status]");
    if (status) status.textContent = "已记录。今天先完成第一件很小的事。";
    if (window.SoundscapeEngineV1 && typeof window.SoundscapeEngineV1.stop === "function") window.SoundscapeEngineV1.stop();
    setTimeout(closeSheet, 700);
  }

  function refreshCharge() {
    addStyles();
    var hero = document.querySelector(".vitals-star-copy");
    if (hero) hero.innerHTML = renderHero();
    var box = document.getElementById("chargeContentV7");
    if (box) box.innerHTML = renderContent();
    var page = document.querySelector("[data-charge-mode-v7]");
    if (page) page.setAttribute("data-morning-ignition-v1", "1");
  }

  function installOverrides() {
    addStyles();
    try { renderChargeHeroV7 = renderHero; } catch (_) {}
    try { renderChargeContentV7 = renderContent; } catch (_) {}
    window.renderChargeHeroV7 = renderHero;
    window.renderChargeContentV7 = renderContent;
    var previousOpen = window.ssOpenChargePlayerV1;
    if (!previousOpen || !previousOpen.__morningIgnitionOpenV1) {
      var wrappedOpen = function (title) {
        var name = String(title || "");
        if (name.indexOf("晨间点火") >= 0 || name.indexOf("morning_light") >= 0 || name.indexOf("morning-sun-map") >= 0 || name.indexOf("morning-ignition") >= 0) {
          openSheet();
          return;
        }
        if (typeof previousOpen === "function") return previousOpen.apply(this, arguments);
      };
      wrappedOpen.__morningIgnitionOpenV1 = true;
      window.ssOpenChargePlayerV1 = wrappedOpen;
      try { ssOpenChargePlayerV1 = wrappedOpen; } catch (_) {}
    }
    var morningStart = function () {
      openSheet();
      start();
    };
    morningStart.__morningIgnitionV1 = true;
    window.startChargeRecommendationV2 = morningStart;
    try { startChargeRecommendationV2 = morningStart; } catch (_) {}
    if (typeof switchTab === "function" && !switchTab.__morningIgnitionV1) {
      var previousSwitch = switchTab;
      var wrappedSwitch = function (tab) {
        var result = previousSwitch.apply(this, arguments);
        if (tab === "vitals") setTimeout(refreshCharge, 0);
        return result;
      };
      wrappedSwitch.__morningIgnitionV1 = true;
      switchTab = wrappedSwitch;
      window.switchTab = wrappedSwitch;
    }
    refreshCharge();
  }

  document.addEventListener("click", function (event) {
    var open = event.target.closest && event.target.closest("[data-morning-ignition-sheet]");
    if (open) {
      event.preventDefault();
      event.stopPropagation();
      if (event.stopImmediatePropagation) event.stopImmediatePropagation();
      openSheet();
      return;
    }
    if (event.target.closest && event.target.closest("[data-morning-ignition-start]")) {
      event.preventDefault();
      event.stopPropagation();
      if (event.stopImmediatePropagation) event.stopImmediatePropagation();
      start();
      return;
    }
    if (event.target.closest && event.target.closest("[data-morning-ignition-done]")) {
      event.preventDefault();
      event.stopPropagation();
      if (event.stopImmediatePropagation) event.stopImmediatePropagation();
      done();
    }
  }, true);

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", installOverrides);
  } else {
    installOverrides();
  }
  [80, 360, 900, 1800].forEach(function (delay) {
    setTimeout(installOverrides, delay);
  });
})();
