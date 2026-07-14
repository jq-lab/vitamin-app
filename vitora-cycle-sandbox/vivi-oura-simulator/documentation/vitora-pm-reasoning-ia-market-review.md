# Vitora PM Reasoning + IA + Market Review

日期：2026-07-05  
对象：`final-confirmation-v12` 当前可交互原型。  
结论先行：Vitora 现在最可信的定位是“女性身体状态操作层 / AI 身体翻译 companion”的原型；不是周期 app、Oura 替代品、医疗诊断或避孕工具。

## 1. PM Reasoning Protocol

本报告使用 `/Users/bytedance/Desktop/Work/David/docs/specs/03_pm_reasoning_protocol.md` 作为方法论主轴。该协议要求把混乱上下文转成 situation assessment、evidence、decision、next action、artifact 和 memory，[03_pm_reasoning_protocol.md](/Users/bytedance/Desktop/Work/David/docs/specs/03_pm_reasoning_protocol.md:5)。核心循环是 orient -> strategy frame -> outcome model -> opportunity discovery -> evidence validation -> solution exploration -> assumption test -> decision -> artifact -> memory，[03_pm_reasoning_protocol.md](/Users/bytedance/Desktop/Work/David/docs/specs/03_pm_reasoning_protocol.md:9)。

本报告因此不把“看起来完整的原型”当作产品证据。协议要求从 outcome 和 user pain 出发，而不是从 feature 出发，[03_pm_reasoning_protocol.md](/Users/bytedance/Desktop/Work/David/docs/specs/03_pm_reasoning_protocol.md:117)；也要求用 evidence hierarchy 和 confidence model 判断建议，[03_pm_reasoning_protocol.md](/Users/bytedance/Desktop/Work/David/docs/specs/03_pm_reasoning_protocol.md:277)、[03_pm_reasoning_protocol.md](/Users/bytedance/Desktop/Work/David/docs/specs/03_pm_reasoning_protocol.md:302)。

当前决策不是 Build PRD。协议明确说：如果付费或高成本行为是最大未验证假设，不要生成 PRD，要生成 evidence test，[03_pm_reasoning_protocol.md](/Users/bytedance/Desktop/Work/David/docs/specs/03_pm_reasoning_protocol.md:346)。

## 2. 这个 App 是什么

Vitora 当前是 Expo/RN + WebView 的 iOS simulator 原型。架构文档说明它是 Expo iOS simulator app，包裹 generated WebView experience，保留 Today、Explore/PillowTalk、Collection、onboarding 和 voice companion，[architecture.md](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/documentation/architecture.md:5)；技术栈是 Expo + React Native + `react-native-webview`，[architecture.md](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/documentation/architecture.md:9)。

它要解决的用户问题是：当用户感觉疲惫、敏感、低效、睡不稳或身体状态不明时，帮助她理解“为什么今天这样”和“现在该做什么”。runtime 会把睡眠、周期、专注、代谢、晨间等信号组成 Today cards，[runtime.ts](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/src/lib/vitora/runtime.ts:596)，并用 primary action 规则把低刺激恢复、睡眠修复、单任务专注、代谢补能和呼吸稳定转成行动，[runtime.ts](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/src/lib/vitora/runtime.ts:430)。

当前真实可见主界面是 `App.tsx` 的 RN 覆盖层，不是纯 WebView。代码里 WebView 仍加载在底层，[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:4242)；RN 层在 `nativeLayerReady && !onboardingOpen` 时显示，[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:4272)。主导航是 `today | explore | health`，[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:55)，底部展示“今日 / 探索 / 健康”，[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:4283)。

当前不是生产健康产品。健康快照固定 `source: "mock"` 和 `adapterStatus: "mock_simulator"`，[runtime.ts](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/src/lib/vitora/runtime.ts:264)；watchStatus 文案也承认当前读取本地 mock 睡眠、周期、HRV、步数和体温变化，[runtime.ts](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/src/lib/vitora/runtime.ts:932)。权限文档说明没有 server-side accounts、roles、claims，[permissions.md](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/documentation/permissions.md:5)，也没有 backend database，[permissions.md](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/documentation/permissions.md:17)。

## 3. 为什么它可能成立

Idea maze 的判断：Vitora 的机会不是“再做一个周期记录器”，而是“女性身体状态操作层”。竞品已经覆盖记录、硬件、周期、避孕和通用健康，但用户仍可能缺一个把周期、睡眠、压力、专注、症状和能量翻译成当天节奏的 companion。

| 产品 | 已有强项 | Vitora 可避开的正面战场 | 证据 |
| --- | --- | --- | --- |
| Oura | 被动硬件数据、Cycle Insights、membership insights。 | 不做硬件和 readiness 替代；做更轻的日常解释与反馈。 | Oura Cycle Insights 预测周期并解释全身影响，[Oura](https://support.ouraring.com/hc/articles/4410663885331-Cycle-Insights)；membership 是硬件后核心体验，[Oura](https://support.ouraring.com/hc/articles/4409086524819-Oura-Membership)。 |
| Apple Health/Vitals | 系统级健康数据、Vitals outliers、隐私心智。 | 不做系统数据仓；做解释与行动层。 | Apple Vitals 聚合夜间指标并提示 outliers，[Apple](https://support.apple.com/en-us/120142)；Cycle Tracking 可记录症状和因素，[Apple](https://support.apple.com/en-us/120356)。 |
| Clue | 女性主导、科学、周期与生命阶段。 | 不做纯周期预测或 birth control 主心智。 | Clue 官网强调 cycle understanding 和 100M+ downloads，[Clue](https://helloclue.com/)；Clue Birth Control 有 FDA clearance，[FDA](https://www.accessdata.fda.gov/cdrh_docs/pdf19/K193330.pdf)。 |
| Flo | 大众女性健康、周期/备孕/怀孕/围绝经内容。 | 不做内容型大众女性健康门户。 | Flo 功能覆盖 period、fertility、pregnancy、perimenopause，[Flo](https://flo.health/)；FTC 曾就敏感健康数据分享发布最终命令，[FTC](https://www.ftc.gov/news-events/news/press-releases/2021/06/ftc-finalizes-order-flo-health-fertility-tracking-app-shared-sensitive-health-data-facebook-google)。 |
| Natural Cycles | FDA-cleared contraception / conception。 | 不碰避孕和医疗风险场景。 | FDA De Novo 认定其用于 contraception 或 conception，[FDA](https://www.accessdata.fda.gov/cdrh_docs/reviews/DEN170052.pdf)；官方主张 93% typical use、98% perfect use，[Natural Cycles](https://www.naturalcycles.com/)。 |
| WHOOP | Strain/recovery/sleep 和 menstrual cycle coaching。 | 不做 performance/athlete 设备心智。 | WHOOP MCI 直接把周期阶段用于 sleep、strain、stress coaching，[WHOOP](https://www.whoop.com/us/en/thelocker/whoop-feature-menstrual-cycle-coaching/)。 |
| Fitbit/Google | Google Health Coach、Fitbit 分发、Gemini coach。 | 不做通用 AI 健康教练；做女性身体语境。 | Google Health Coach 提供 fitness、sleep、wellness guidance，[Google](https://support.google.com/googlehealth/answer/14237011?hl=en)。 |
| Bearable | 症状、情绪、能量、睡眠、药物和相关性。 | 不做重手动日志；做低摩擦解释与 micro-action。 | Bearable 官方强调 tracking 和 correlations，[Bearable](https://bearable.app/)。 |

客观判断：Vitora 的 edge 目前不是数据、模型、监管或分发。Oura/WHOOP/Apple/Google 有更强被动数据，Natural Cycles/Clue 在监管和周期可信度更强，Flo/Clue 有规模和内容。Vitora 只有在证明“每日身体状态 dosing + conversational feedback + 隐私可信 + 建议完成率”更好时，才有真实 edge。信心：中低。

## 4. 当前 IA 树

### 运行态验证口径

我用 iOS simulator MCP 工具启动 `com.local.vivi.oura`，实际点击验证了 Today、Explore、Health、Health detail、ReminderSheet、Profile、Profile 子面板、Stamp reveal、Explore chat、Today focus timer。运行态看到的默认首屏是 Today，包含 6 个横向卡、主行动按钮、Dori 能量分析、底部三 Tab；Explore 主题卡进入 chat，`+` 追加照片占位消息，`✓` 生成油戳；Health 进入 detail 后底部固定为综合/睡眠/周期/专注/代谢；Profile 打开后有油戳收集、个人档案、WATCH、会员等二级面板。源码证据与运行态一致：RN 覆盖层在 `nativeLayerReady && !onboardingOpen` 时显示，[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:4272)；底部 Tab 和全局浮层在同一个 native layer 内挂载，[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:4283)。

### RN 覆盖层主 IA，当前用户可见

```text
Vitora App
├─ WebView 底层承载层
├─ WebView
│  ├─ source: local web/index.html cache 或 remote fallback
│  ├─ injectedJavaScript: simulator patch + runtime storage sync
│  └─ onMessage: vitora-onboarding
│     ├─ payload.open=true -> 打开/保持 Web onboarding，隐藏 RN overlay
│     └─ payload.open=false && completed=true -> apply runtime -> nativeTab=today
├─ RN NativeLayer
│  ├─ 显示条件: nativeLayerReady && !onboardingOpen
│  ├─ 路由状态
│  │  ├─ nativeTab: today | explore | health
│  │  ├─ todayRoute: home | breathing | focusTimer | metabolismTimer | morningMap
│  │  ├─ exploreRoute: home | detail | chat | feedback
│  │  ├─ healthRoute: home | detail
│  │  ├─ healthDetailTab: summary | sleep | cycle | focus | metabolism
│  │  ├─ todayActiveId: today | sleep | cycle | focus | metabolism | morning
│  │  ├─ profilePanel: inbox | info | editName | stamps | archive | watch | vip
│  │  └─ reminderSheet / stampSheet / toast / onboardingOpen
│  ├─ 深链参数
│  │  ├─ nativeTab / nativeRoute
│  │  ├─ healthRoute / healthTab
│  │  ├─ today / todayRoute
│  │  ├─ theme / energyChat / energyQuestion
│  │  └─ profile=1|0
│  └─ Bottom Tab，子页面隐藏
│     ├─ 今日 -> nativeTab=today, todayRoute=home, todayActiveId=today
│     ├─ 探索 -> nativeTab=explore, exploreRoute=home
│     └─ 健康 -> nativeTab=health, healthRoute=home
├─ 今日 Tab
│  ├─ todayRoute=home
│  │  ├─ 横向卡导航
│  │  │  ├─ 今日: chip=综合分；moreTab=summary
│  │  │  ├─ 睡眠: chip=睡眠债；moreTab=sleep
│  │  │  ├─ 周期: chip=D day；moreTab=cycle
│  │  │  ├─ 专注: chip=切换/专注；moreTab=focus
│  │  │  ├─ 代谢: chip=代谢状态；moreTab=metabolism
│  │  │  └─ 晨间: chip=晨间启动；moreTab=summary
│  │  ├─ 主卡，当前挂载静态 artwork
│  │  │  ├─ renderStaticTodayArtworkCard(activeToday)
│  │  │  ├─ 点击卡片或 ••• -> Health detail 对应 tab
│  │  │  ├─ ImageBackground: today / sleep / cycle / focus / metabolism / morning artwork
│  │  │  ├─ 今日 overlay: 今日能量 + 周期/persona 文案
│  │  │  ├─ utility overlay: 各卡片状态文案
│  │  │  ├─ 隐形行动热区 -> handleTodayAction(card)
│  │  │  └─ focus 卡隐藏 + / - 热区 -> adjustFocusMinutes
│  │  ├─ 未挂载动态 Today visual 代码，不算当前用户主路径
│  │  │  ├─ renderDynamicTodayCard
│  │  │  ├─ renderTodaySleepVisual: sleepTargetMinutes / sleepWindowShift / sleepPanResponder / +/- 目标
│  │  │  ├─ renderTodayCycleVisual: 28-day dial
│  │  │  ├─ renderTodayFocusVisual: focusPanResponder / +/- focusMinutes
│  │  │  ├─ renderTodayMetabolismVisual: steps / heart / kcal
│  │  │  └─ renderTodayMorningVisual: map / km / HR / phase
│  │  ├─ 主行动 CTA
│  │  │  ├─ sleep 或 actionType=reminder -> ReminderSheet
│  │  │  ├─ focus -> todayRoute=focusTimer
│  │  │  ├─ metabolism -> todayRoute=metabolismTimer
│  │  │  ├─ morning 或 actionType=map_guidance -> todayRoute=morningMap
│  │  │  └─ today / cycle / other direct_session -> todayRoute=breathing
│  │  ├─ Dori 能量分析 preview
│  │  │  ├─ 点击 preview -> 初始化 Today 内联 energy conversation，并聚焦 composer
│  │  │  ├─ 根据当前卡显示综合分或卡片 monitor
│  │  │  └─ energyRecordPanel 代码存在，但 startEnergyRecord 当前无入口，运行态未验证为可达
│  │  ├─ 今日快卡 live cards
│  │  │  ├─ composer + -> native Alert: 拍照 / 相册 / 先生成示例 / 取消
│  │  │  ├─ 拍照/相册 -> ImagePicker permission
│  │  │  ├─ 权限拒绝或异常 -> sample fallback
│  │  │  ├─ createEnergyLiveCard -> live card list，最多 3 张
│  │  │  ├─ live card: score / advice / source
│  │  │  ├─ 声音播放
│  │  │  ├─ 去呼吸 -> todayRoute=breathing
│  │  │  └─ toast: 已生成今日能量快卡
│  │  ├─ 今日内联聊天
│  │  │  ├─ 空状态: Dori 在这里等你
│  │  │  ├─ 消息列表: user / ai / audio
│  │  │  ├─ audio message: play/pause -> playingAudioMessageId
│  │  │  ├─ 展开/收起原文 -> expandedAudioMessageIds
│  │  │  └─ composer: 文本输入 / + 照片 / ↑ 发送
│  │  └─ DEV reference controls: Ref / opacity
│  ├─ todayRoute=breathing
│  │  ├─ header: 返回 / 今日能量 pill / 展开
│  │  ├─ 白噪音呼吸 orb + elapsed timer
│  │  ├─ 背景切换: mist / forest / moon 等
│  │  ├─ 播放声音 / 暂停声音
│  │  └─ 完成 -> collect stamp -> StampRevealSheet
│  ├─ todayRoute=focusTimer
│  │  ├─ 返回
│  │  ├─ 专注计时 title
│  │  ├─ focusMinutes orb + elapsed timer
│  │  └─ 完成并生成油戳 -> StampRevealSheet
│  ├─ todayRoute=metabolismTimer
│  │  ├─ 返回
│  │  ├─ 代谢计时 title
│  │  ├─ heart/restingHR + elapsed timer
│  │  └─ 完成并生成油戳 -> StampRevealSheet
│  └─ todayRoute=morningMap
│     ├─ 返回
│     ├─ 晨间找太阳 title
│     ├─ 模拟地图 + 阳光方向文案
│     └─ 完成晨间路线 -> StampRevealSheet
├─ 探索 Tab
│  ├─ exploreRoute=home
│  │  ├─ 主题卡流
│  │  │  ├─ 灵感: 哪一句话今天抓住了你？
│  │  │  ├─ 意识: 这一刻你反复想到什么？
│  │  │  ├─ 关系: 探索你的关系模式
│  │  │  └─ 梦想: 你对其中一个梦有什么印象？
│  │  └─ 每张卡: 点击卡片或“写点什么...” -> openNativeChat -> exploreRoute=chat
│  ├─ exploreRoute=chat
│  │  ├─ header: 返回 / 标题=分析 或 Dori 能量分析
│  │  ├─ 消息列表: 初始 AI prompt、用户消息、AI reply、audio message
│  │  ├─ audio message: 播放/暂停、展开/收起原文
│  │  ├─ composer
│  │  │  ├─ 文本输入 -> ↑ 发送，local mock reply
│  │  │  ├─ + -> Explore 模式追加“发送了一张今日状态照片”
│  │  │  └─ ✓ 空输入完成对话 -> conversation stamp
│  │  ├─ 输入菜单，代码存在但当前没有 setChatMenuOpen(true) 入口，运行态不可达
│  │  │  ├─ keyboard
│  │  │  ├─ voice -> 模拟转写
│  │  │  └─ quickActions -> energy quick questions
│  │  └─ 完成后 Explore 模式回 home，Energy 模式 toast 保存
│  ├─ exploreRoute=detail
│  │  └─ renderExploreDetail 存在，但 renderNativeBody 当前不挂载，用户主路径不可达
│  └─ exploreRoute=feedback
│     └─ renderFeedback 存在，但 renderNativeBody 当前映射回 Explore home，用户主路径不可达
├─ 健康 Tab
│  ├─ healthRoute=home
│  │  ├─ 顶部 profile entry: 打开 Profile overlay
│  │  ├─ persona title + 本期正在经历
│  │  ├─ 油戳舞台: 最近 5 枚 stamp，点单枚 -> StampRevealSheet detail
│  │  ├─ 30 天能量状态
│  │  │  ├─ 高精力 / 低精力 / 平稳统计
│  │  │  ├─ 月度 heat grid
│  │  │  ├─ compact radar: 睡眠 / 周期 / 抗压 / 代谢 / 专注
│  │  │  ├─ 本周主线 copy
│  │  │  └─ 更多 -> healthRoute=detail, healthDetailTab=summary
│  │  ├─ AI 身体翻译
│  │  │  └─ 详情 -> healthRoute=detail, healthDetailTab=summary
│  │  └─ 指标卡 grid
│  │     ├─ 平均能量
│  │     ├─ 睡眠
│  │     ├─ 专注
│  │     ├─ 抗压
│  │     ├─ 代谢
│  │     └─ 点击任一指标卡 -> native Alert 解释指标来源
│  ├─ 代码存在但当前未挂载
│  │  └─ renderHealthHeatmapRangeControl: 本周 / 上周
│  └─ healthRoute=detail
│     ├─ header
│     │  ├─ 返回 -> healthRoute=home
│     │  ├─ 日期 -1
│     │  ├─ 日期 label
│     │  └─ 日期 +1
│     ├─ Tab: 综合
│     │  ├─ radar graph
│     │  ├─ score label + percentile copy
│     │  ├─ health detail body
│     │  ├─ AI 建议 rows
│     │  └─ disclaimer
│     ├─ Tab: 睡眠
│     │  ├─ 入睡/起床时间
│     │  ├─ 睡眠阶段 bar: 清醒 / 浅睡 / 深睡 / REM
│     │  ├─ 睡眠负债 block
│     │  ├─ 睡眠负债趋势
│     │  │  └─ range: 7天 / 30天 / 90天
│     │  └─ AI 建议 rows -> ReminderSheet
│     ├─ Tab: 周期
│     │  ├─ phase header + D day
│     │  ├─ 28 天周期轮
│     │  ├─ D day summary
│     │  ├─ 周期解读
│     │  ├─ AI 建议 rows -> ReminderSheet
│     │  └─ medical disclaimer
│     ├─ Tab: 专注
│     │  ├─ wave graph
│     │  ├─ 今日专注状态 card
│     │  ├─ focus score / title / body
│     │  ├─ focusMinutes hint
│     │  └─ AI 建议 rows -> ReminderSheet
│     └─ Tab: 代谢
│        ├─ heart card
│        ├─ metabolism score / body
│        ├─ steps / kcal / km
│        └─ AI 建议 rows -> ReminderSheet
└─ 全局浮层
   ├─ Profile overlay
   │  ├─ 顶部状态条
   │  ├─ inbox icon -> ProfilePanel: 消息中心
   │  ├─ info icon -> ProfilePanel: 数据说明
   │  ├─ close
   │  ├─ hero: displayName / encounterDays / persona -> editName
   │  ├─ membership card: mythicReference 邮票册 -> stamps
   │  ├─ 开通会员 -> ProfilePanel: TIDE Plus
   │  ├─ tile: 油戳收集 -> stamps
   │  ├─ tile: 个人档案 -> archive
   │  └─ WATCH 应用 -> watch
   ├─ ProfilePanel
   │  ├─ inbox: inboxEvents list
   │  ├─ info: 数据源 / 非医疗建议 / 运行 ID / 主动关心
   │  ├─ editName: nickname input / 保存
   │  ├─ stamps: stamp grid -> StampRevealSheet detail
   │  ├─ archive: 身体人格 / 人格码 / 建档时间 / 预测模型
   │  ├─ watch: 连接状态 / 同步说明 / 最近同步 / 读取字段
   │  └─ vip: trial / benefits / tier / simulated payment note
   ├─ ReminderSheet
   │  ├─ source title
   │  ├─ -15 / +15
   │  ├─ quick times: 09:30 / 13:00 / 18:30 / 21:30
   │  └─ 关闭 / 确定 -> toast
   ├─ StampRevealSheet
   │  ├─ mode=award: 已获得油戳
   │  ├─ mode=detail unlocked: 我的油戳
   │  ├─ mode=detail locked: 未解锁油戳
   │  ├─ stamp code / month / title / reason
   │  └─ 完成 / 分享 -> native Share sheet
   ├─ Native system Alert
   │  ├─ 添加今日快卡: 拍照 / 相册 / 先生成示例 / 取消
   │  └─ 指标解释: 平均能量 / 睡眠 / 专注 / 抗压 / 代谢
   ├─ Native Share sheet
   │  └─ shareStamp: 分享油戳标题、reason、code
   └─ Toast
```

证据：类型层定义完整 route / panel / sheet state，[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:55)；state 初始化默认 Today 并包含所有子状态和音频消息状态，[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:901)、[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:929)；WebView onboarding 只有在 `!payload.open && payload.completed` 时才 apply runtime 并切 Today，[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:1403)；深链可直达 today、health detail、profile、energyChat，[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:1267)。当前 Today 渲染读取 `vitoraState.content.todayCards`，[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:1432)，Today cards 的 runtime 生成源在 `composeContent()`，[runtime.ts](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/src/lib/vitora/runtime.ts:602)；四个 Explore themes 来自静态数组，[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:552)。Today 主页面当前挂载 `renderStaticTodayArtworkCard(activeToday)`；`renderDynamicTodayCard()` 和 `renderTodayCardVisual()` 存在但未被 `renderToday()` 调用，[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:3837)、[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:3808)、[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:3524)、[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:3897)。Today 子动作分发在 `handleTodayAction()`，[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:3542)；呼吸页、计时页、晨间页分别在 render 函数中定义，[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:3911)、[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:3963)、[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:3998)。Today energy chat 不切全页，只写入 Today 内联 conversation；照片快卡使用 native alert 选择拍照/相册/示例，权限失败时生成 sample fallback，[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:1718)、[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:1799)、[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:1777)。音频消息的播放和原文展开由 `playingAudioMessageId`、`expandedAudioMessageIds` 控制，[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:1652)。Explore home、chat、detail、feedback render 都存在，但主分发只真正挂了 home/chat，feedback 被映射回 home；`chatMenuOpen` 有菜单状态但没有打开入口，[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:2032)、[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:2088)、[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:2064)、[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:2263)、[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:4219)、[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:2121)。Health home、detail tabs、summary/sleep/cycle/focus/metabolism render、metric alert、未挂载 heatmap range control 和 reminder sheet 分别在源码中定义，[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:3165)、[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:2760)、[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:2818)、[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:2890)、[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:2930)、[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:3037)、[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:3053)、[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:2708)、[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:2528)、[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:3112)。Profile、ProfilePanel、StampRevealSheet 和 native Share sheet 的结构来自对应函数，[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:4165)、[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:4120)、[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:2448)、[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:2396)。

### WebView legacy / onboarding IA

```text
web/index.html
├─ Legacy phone shell
│  ├─ topbar: menu / wordmark / status icon
│  ├─ screens
│  │  ├─ today
│  │  ├─ vitals-screen-v2
│  │  └─ health / 收集
│  ├─ cloudMascot -> advisor
│  ├─ plus overlay
│  ├─ detail modal
│  ├─ quick modal
│  ├─ advisor modal + voiceSheet
│  └─ legacy bottom nav: 今日 / 探索(vitals) / 收集(health) / plus
├─ Legacy Today
│  ├─ hero
│  │  ├─ metric row: 压力 / 准备度 / 睡眠 / 活动量 / 周期
│  │  ├─ gauge / score / label / title / copy
│  │  └─ learnMore -> detail modal
│  ├─ home drawer
│  │  ├─ collapsed / expanded state
│  │  ├─ 今日洞察 summary
│  │  ├─ assistant question input
│  │  ├─ 关键原因 / evidence grid / next step / missing
│  │  ├─ primary / secondary cards
│  │  └─ 今日记录 strip
│  ├─ fixed-today patch
│  │  ├─ slides/chips: today / sleep / cycle / focus / stress / morning
│  │  └─ page pushes -> cards
│  └─ data sheet
│     ├─ 数据与后台 strip
│     ├─ 后台开关
│     ├─ 读取状态
│     ├─ 通知预览
│     └─ 重新建档 -> onboarding
├─ Legacy Vitals / PillowTalk
│  ├─ vitals overview root: #vitalsOverviewV2
│  ├─ vitals detail page
│  │  ├─ readiness / sleep / activity / cycle / heartrate / stress / weekly / sleepdebt
│  │  ├─ close
│  │  ├─ detail body
│  │  └─ detail switcher
│  └─ PillowTalk low-code flow
│     ├─ themes
│     │  ├─ thought / 意识
│     │  ├─ relationship / 关系
│     │  ├─ dream / 梦想
│     │  └─ inspiration / 灵感
│     ├─ route=home
│     │  ├─ InviteHeroCard
│     │  ├─ RecentEntryPanel
│     │  └─ ThemeRail
│     ├─ route=chat
│     │  ├─ ChatHeader
│     │  ├─ MessageList
│     │  └─ InputBar
│     ├─ route=analysis
│     │  ├─ AnalysisResultCard
│     │  ├─ AccountProgressRow: 身体 / 精神 / 意志
│     │  ├─ AudioBar
│     │  └─ 生成今日卡片
│     ├─ route=unlock
│     │  ├─ UnlockProgress
│     │  ├─ CollectionStatsBlock
│     │  ├─ 分享今日卡片
│     │  └─ 完成
│     └─ action layer
│        ├─ open-chat / back-themes / start-analysis
│        ├─ toggle-tag / toggle-expand / toggle-audio
│        ├─ go-unlock / finish-chat / finish-flow
│        └─ share-summary / history stats toast
├─ Legacy Health
│  ├─ 本周生命星球
│  │  ├─ main core: 综合 score
│  │  ├─ planets: 睡眠 / 压力 / 恢复 / 活动 / 周期
│  │  └─ active summary
│  ├─ health node sheet
│  │  ├─ 当前状态 / 为什么
│  │  ├─ 最近 7 天趋势
│  │  ├─ 今日建议
│  │  ├─ 播放语音
│  │  └─ 进入详情
│  ├─ AI 身体翻译 panel
│  │  ├─ 状态 badge
│  │  ├─ title / copy / advice
│  │  ├─ 更多
│  │  └─ 播放语音
│  ├─ voice message card
│  │  ├─ VIVI 留言
│  │  ├─ 展开文字
│  │  └─ 声音选项
│  ├─ voice model picker
│  ├─ tiles: 平均准备度 / 睡眠负债
│  └─ health-detail-page + detail switcher
├─ Legacy 全局 modal/action
│  ├─ plus menu
│  │  ├─ 健康助手
│  │  ├─ 记录生理周期
│  │  ├─ 自由引导
│  │  ├─ 记录饮食
│  │  ├─ 添加标签
│  │  ├─ 添加运动
│  │  └─ 记录运动心率
│  ├─ quick modal
│  │  ├─ quickMap: period / session / meal / tag / workout / workoutHR
│  │  ├─ choice grid
│  │  ├─ note textarea
│  │  └─ 完成记录
│  ├─ detail modal
│  │  ├─ readiness / sleep / activity / cycle / heartrate / glucose / stress / weekly / sleepdebt
│  │  └─ score / title / copy / learnMore
│  └─ advisor modal
│     ├─ prompt chips
│     ├─ mock chat
│     ├─ voice play
│     ├─ chat input / mic / send
│     └─ voiceSheet: preset / speed / pitch / nickname
└─ Onboarding
   ├─ open condition: onboarding deep link or local storage incomplete
   ├─ pages
   │  ├─ entry: 微信登录 / 支付宝登录
   │  ├─ goal: 改善睡眠 / 稳定专注 / 身体线索 / 恢复强度
   │  ├─ questions
   │  │  ├─ 入睡时间
   │  │  ├─ bodyTiming chips
   │  │  ├─ sleepPattern wide choices
   │  │  ├─ sleepFrequency
   │  │  ├─ sleepDuration
   │  │  ├─ sleepImpact
   │  │  └─ sleepTriggers multi-select
   │  ├─ sleep_reminder: hour/minute wheel
   │  ├─ health_intro
   │  ├─ health_permission: 不允许 / 允许 / 全部打开 / permission rows
   │  └─ cycle
   │     ├─ confirm: pmsSignals / pmsNote / periodDay / painLevel / periodLength
   │     ├─ generating
   │     ├─ reading
   │     ├─ personality
   │     ├─ plan
   │     └─ result
   ├─ branches
   │  ├─ health-grant -> cycle
   │  ├─ health-deny -> cycle
   │  ├─ skip-health -> cycle with skipped state
   │  └─ backPage handles cycle stage and skipped health return
   └─ complete
      ├─ sync answers / buildSignals / applyPrediction
      ├─ write onboarding completed localStorage
      ├─ postRuntimeToNative(false,true)
      ├─ close onboarding
      └─ switchTab(today)
```

证据：legacy shell 定义 today/vitals/health 三 screen、cloud mascot、plus overlay、detail/quick/advisor modal 和 bottom nav，[web/index.html](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/web/index.html:4361)、[web/index.html](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/web/index.html:4573)、[web/index.html](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/web/index.html:4581)。Legacy Today hero metrics 和 home drawer 在 HTML 中仍存在，[web/index.html](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/web/index.html:4364)、[web/index.html](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/web/index.html:4378)；legacy tab switcher 仍只认 today/vitals/health，[web/index.html](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/web/index.html:5131)。Legacy Health 生命星球、node sheet、AI 身体翻译、voice picker 和 health detail page 仍在 HTML，[web/index.html](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/web/index.html:4442)、[web/index.html](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/web/index.html:4491)、[web/index.html](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/web/index.html:4516)、[web/index.html](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/web/index.html:4544)、[web/index.html](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/web/index.html:4568)。Onboarding pages、health permission branch、cycle stages 和 complete-to-Today 逻辑在 WebView 内定义，[web/index.html](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/web/index.html:11322)、[web/index.html](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/web/index.html:11499)、[web/index.html](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/web/index.html:11666)、[web/index.html](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/web/index.html:11716)。PillowTalk legacy themes、screens、state routing、rendering 和 action reducer 仍存在，[web/index.html](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/web/index.html:12155)、[web/index.html](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/web/index.html:12251)、[web/index.html](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/web/index.html:12311)、[web/index.html](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/web/index.html:12773)、[web/index.html](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/web/index.html:12922)。

## 5. PM + IA 评价

### SWOT

| 维度 | 判断 | 证据 |
| --- | --- | --- |
| Strength | “身体状态解释 + 当日行动”比普通仪表盘更接近用户高频困惑。 | Today cards 把分数、原因、monitor 和 action 绑定，[runtime.ts](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/src/lib/vitora/runtime.ts:602)。 |
| Weakness | 当前没有真实数据、真实 AI、后端、自动测试或付费证据。 | mock adapter，[runtime.ts](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/src/lib/vitora/runtime.ts:276)；无后端，[permissions.md](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/documentation/permissions.md:17)；测试缺口，[tests.md](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/documentation/tests.md:24)。 |
| Opportunity | 市场从记录走向解释、建议、AI coach，但女性日常状态操作层仍可切。 | Oura/Apple/WHOOP/Google 均在做指标解释或 coach，见上方竞品证据。 |
| Threat | 平台和硬件方可迅速下沉到 AI 解释层。 | Oura、WHOOP、Google 已有数据和 coach 能力。 |

### JTBD

核心 Job：当我今天身体和情绪状态不稳定时，我想快速知道原因、调整工作/运动/恢复强度，并保存反馈，让下次建议更准。功能任务是“安排今天”；情绪任务是“减少我是不是坏掉了的焦虑”；证据任务是“回看模式并解释给自己/医生/伴侣”。

### Positioning Map

```text
                   解释 / 行动
                       ↑
        Oura / WHOOP   |      Vitora 目标位
                       |
通用健康 / 运动 ←──────┼──────→ 女性生理语境
 Apple / Google        |      Clue / Flo / Natural Cycles
                       |
              Bearable / 手动记录
                       ↓
                   记录 / 数据
```

### 四风险

| 风险 | 当前判断 |
| --- | --- |
| Value | 中低：需求合理，但缺少真实用户过去行为、付费、重复使用证据。 |
| Usability | 中：三 Tab 清晰，但 `探索`、`健康`、Dori、AI 身体翻译之间的心智还需要树测试验证。 |
| Feasibility | 中：原型已可跑，但真实 HealthKit、AI、后端、隐私架构尚未实现；变量文档也要求替换 local mock chat engine 和 localhost WebView，[variables.md](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/documentation/variables.md:16)。 |
| Viability | 低：尚无 WTP、订阅、留存或分发证据。 |

### IA 四系统

| 系统 | 评价 |
| --- | --- |
| 组织 | 三 Tab 应收敛为：今日=行动，探索=表达/反馈，健康=证据/复盘。 |
| 标签 | 今日、睡眠、周期、专注、代谢清晰；Dori 能量分析、AI 身体翻译、探索需要更明确关系。 |
| 导航 | RN 主路由清楚；Web legacy 和 RN 覆盖层并存增加维护与 QA 风险。 |
| 搜索/发现 | 当前无搜索；记录增长后需要 history、模式回看和任务级入口。 |

IA 方法来源：Coursera IA 课程强调 human-centered design、information-seeking behavior 和结构模式，[Coursera](https://www.coursera.org/learn/packt-foundations-of-information-architecture-bzsgg)；NN/g 建议用 card sorting 发现用户心智模型、用 tree testing 验证结构可找性，[NN/g IA Study Guide](https://www.nngroup.com/articles/ia-study-guide/)、[NN/g Card Sorting](https://www.nngroup.com/articles/card-sorting-definition/)、[NN/g Tree Testing](https://www.nngroup.com/videos/tree-testing/)；W3C WCAG 2.4 要求帮助用户导航、找到内容并知道位置，[W3C WCAG 2.4](https://www.w3.org/TR/WCAG22/#navigable)。

### Outcome / Metrics

HEART/GSM 的目标应先看 Task Success、Adoption、Retention，而不是页面数。建议 North Star proxy：`每周完成至少 3 次身体状态解释并反馈准/不准/完成的用户数`。输入指标：首次到达 Today 价值、建议完成率、反馈率、7 日回访、Health 复盘到达率。Amplitude North Star 框架强调用一个核心指标连接用户价值和产品动作，[Amplitude](https://amplitude.com/books/north-star/about-north-star-framework)；Google HEART/GSM 用 goals、signals、metrics 连接 UX 和可追踪指标，[Google Research](https://research.google/pubs/measuring-the-user-experience-on-a-large-scale-user-centered-metrics-for-web-applications/)。

## 6. 证据等级与信心

| 判断 | Evidence strength | Confidence | Top uncertainty | What would change decision |
| --- | --- | --- | --- | --- |
| 当前真实能力是本地模拟器、RN 覆盖层、Web onboarding、mock 数据、无后端。 | 高：代码和本地文档一致。 | 高 | 无生产环境行为证据。 | 真实后端、HealthKit、AI 服务和部署证据。 |
| 产品方向是身体状态解释、当日行动、情绪表达记录。 | 中：原型功能完整，但没有用户行为验证。 | 中 | 用户是否愿意每天用它安排节奏。 | 真实用户连续 2 周重复使用并反馈建议有帮助。 |
| 市场存在“从记录到解释/coach”的趋势。 | 中高：Oura/Apple/WHOOP/Google 官方资料支持。 | 中 | 这些趋势是否转化为 Vitora 的独立需求。 | 用户主动放弃竞品 workflow，转向 Vitora。 |
| Vitora 有可防守 edge。 | 低到中：主要是定位推断。 | 中低 | 数据、分发、信任、留存都未验证。 | 建议完成率、7 日留存、付费意愿显著高于替代方案。 |
| 当前应直接 Build PRD。 | 低：协议不支持。 | 低 | 付费和高成本行为未验证。 | 出现 paid pilot、订阅承诺、重复高意图使用或强 workaround 证据。 |

## 7. 决策与下一步测试

决策：`Narrow + Test`。不要进入 PRD。PM 协议规定，PRD 不是证据；当目标用户、频率、workaround、riskiest assumption、success metric 和 instrumentation 未明确时，应说明缺失证据并输出最强测试，[03_pm_reasoning_protocol.md](/Users/bytedance/Desktop/Work/David/docs/specs/03_pm_reasoning_protocol.md:353)。

最强下一步 evidence test：

| 字段 | 设计 |
| --- | --- |
| Riskiest assumption | 目标用户会每周多次使用“身体状态解释 + 当日 action dosing”，并愿意反馈准/不准/完成。 |
| Target audience | 20-40 岁、有周期/睡眠/能量波动困扰、已经用 Apple Health/Oura/Clue/Flo/Bearable 任一工具但仍觉得“看不懂该做什么”的女性。 |
| Test type | 10-15 人 concierge test，连续 14 天，每天人工/半自动生成一张 Today 状态解释卡和一个 micro-action。 |
| Success rule | 至少 60% 参与者连续 7 天内使用 4 天以上；至少 40% 每周完成 3 次 action feedback；至少 3 人表达明确付费或继续使用意愿。 |
| Kill rule | 多数用户只觉得“好看/有趣”，但不按建议行动、不反馈、不复访。 |
| Iterate rule | 用户喜欢解释但不喜欢聊天：收窄到 Today + Health；用户喜欢记录但不信分数：先做 journaling + pattern review。 |
| Proceed rule | 达到 success rule 后，再写 P0 build spec：真实 HealthKit/Oura 输入、隐私边界、反馈模型、最小后端。 |

同时做 IA 验证：用 30-50 张功能/内容卡片做 card sorting，再用 8-12 个 top tasks 做 tree testing。核心任务：看今天为什么低能量、开始一个低刺激行动、记录一条感受、查看睡眠证据、回看一周模式、调整提醒、理解数据来源。Product Talk 的 Opportunity Solution Tree 用 desired outcome -> opportunities -> solutions -> assumption tests 组织发现，[Product Talk](https://www.producttalk.org/opportunity-solution-trees/)；SVPG 四风险要求同时验证 value、usability、feasibility、viability，[SVPG](https://www.svpg.com/four-big-risks/)；Shape Up 要求有 appetite 和 no-gos，[Shape Up](https://basecamp.com/shapeup/1.1-chapter-02)；Mom Test 要求问过去行为而不是“你会不会用”，[Mom Test](https://www.momtestbook.com/)。

No-gos：不做医疗诊断；不做避孕/备孕判断；不声称替代 Oura/Apple Health；不把 mock 分数包装成真实健康预测；不在没有隐私和授权设计前发送敏感文本或健康数值到 AI。
