# Vitora 产品定位、IA 与竞品评估

日期：2026-07-05  
对象：`final-confirmation-v12` 当前可交互原型，不是生产级健康产品。

## 1. 证据标准与研究方法

本报告按 Ahrefs 关键词研究的精神做产品判断：先找用户真实问题和意图，再看需求能否被产品自然解决，而不是先为已有功能找理由；Ahrefs 把关键词研究定义为发现目标客户会搜索的有价值问题，并强调 intent 和 business potential，[来源](https://ahrefs.com/seo/keyword-research)。

IA 评估按“组织、标签、导航、搜索/发现”四系统看结构是否帮助用户找到并完成任务；NN/g 将 IA 研究、导航、卡片分类、树测试列为核心方法，[来源](https://www.nngroup.com/articles/ia-study-guide/)。Coursera 的 Foundations of Information Architecture 也把重点放在 human-centered design、information-seeking behavior 和结构模式，[来源](https://www.coursera.org/learn/packt-foundations-of-information-architecture-bzsgg)。

本地证据优先级高于产品愿景：当前工程文档明确说它是 Expo iOS simulator app，包着 generated WebView experience，[architecture.md](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/documentation/architecture.md:5)；也明确没有后端，聊天和分析是 local mock logic，[architecture.md](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/documentation/architecture.md:60)。

## 2. 这个 App 是什么

Vitora 当前版本是一个“女性身体状态解释与行动建议”原型：它把睡眠、周期、专注、代谢、抗压和主观记录压成当天可执行建议。代码里的 Today 卡包括今日、睡眠、周期、专注、代谢、晨间，[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:178)，runtime 会生成对应的 Today cards、health summary 和 health details，[runtime.ts](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/src/lib/vitora/runtime.ts:596)。

它现在不是 Swift native，也不是有真实后端的健康产品。壳层是 Expo + React Native + WebView，[architecture.md](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/documentation/architecture.md:9)，WebView 负责加载静态 HTML 和 onboarding，RN 覆盖层负责当前可见主 UI，[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:4243)、[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:4272)。

它现在的数据可信度是“可演示 mock”。runtime 的健康快照 source 是 `mock`，adapterStatus 是 `mock_simulator`，[runtime.ts](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/src/lib/vitora/runtime.ts:264)；watchStatus 也显示当前读取本地 mock 睡眠、周期、HRV、步数和体温变化，[runtime.ts](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/src/lib/vitora/runtime.ts:932)。

核心用户问题可以表达为：我今天为什么累、乱、低效或敏感，以及我现在该做什么。Today 的文案直接把周期、睡眠、专注、代谢解释成“低刺激恢复”“单任务专注”“下午补能”等行动，[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:453)。

## 3. 为什么它可能有存在价值

竞品已经证明“健康数据需要解释”是强需求。Oura app 把 cards 分组到 readiness、sleep、activity、stress、women's health、heart health、metabolic health 和 core metrics，并支持进入趋势/详情，[Oura support](https://support.ouraring.com/hc/en-us/articles/360058599753-How-to-Use-the-Oura-App)。

周期 app 已证明“女性健康理解”是大市场，但它们的重心不同。Clue 定位为 period tracking app、menstrual health resource 和 femtech thought leader，[Clue About](https://helloclue.com/about-clue)；Natural Cycles 主张 FDA-cleared birth control，用温度等数据判断 fertility status，[Natural Cycles](https://www.naturalcycles.com/)，FDA De Novo 也把它定义为用于 contraception 或 conception 的 fertility monitor，[FDA](https://www.accessdata.fda.gov/cdrh_docs/reviews/DEN170052.pdf)。

Vitora 不应该正面做“低配 Oura”“又一个经期 tracker”或“避孕/备孕工具”。Oura 有硬件和长期趋势，Clue/Flo 有周期内容和用户规模，Natural Cycles 有监管门槛；当前 Vitora 没有硬件、临床验证或后端，所以不能靠准确率或医学可信度赢，[architecture.md](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/documentation/architecture.md:58)、[runtime.ts](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/src/lib/vitora/runtime.ts:276)。

它较合理的边缘定位是：面向女性的 AI 身体翻译 companion，把 HealthKit/Oura/手动记录里的周期、睡眠、情绪、专注和能量信号，转成当天节奏建议。这个定位避开避孕/医疗判断，靠“跨信号解释 + 情绪语气 + 行动闭环”与 Oura/Clue/Apple Health 区分。

## 4. 当前 IA 树

以下以当前真实可见 RN 覆盖层为主；WebView 中仍有大量遗留/隐藏 DOM，工程文档也承认 generated HTML 很大，旧 Today/health surfaces 仍存在，[architecture.md](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/documentation/architecture.md:61)。

```text
Vitora
├─ App Shell
│  ├─ WebView 基线：静态 web/index.html、onboarding、旧模拟器表面
│  ├─ RN 覆盖层：nativeLayerReady && !onboardingOpen 时显示
│  └─ Bottom Tab
│     ├─ 今日
│     ├─ 探索
│     └─ 健康
├─ 今日
│  ├─ 顶部圆卡：今日 / 睡眠 / 周期 / 专注 / 代谢 / 晨间
│  ├─ 今日能量主卡：分数、解释、监测条、行动 CTA
│  ├─ 子行动
│  │  ├─ 呼吸练习
│  │  ├─ 专注计时
│  │  ├─ 代谢计时
│  │  └─ 晨间路线
│  └─ Dori 能量分析：输入、照片快卡、聊天保存
├─ 探索
│  ├─ 主题卡：首页、灵感、意识、关系、梦想
│  ├─ 主题详情：最近记录、写点什么
│  └─ Chat：消息列表、分析、键盘/语音/快捷问题、完成
├─ 健康
│  ├─ 个人入口
│  ├─ 30 天能量状态
│  ├─ 雷达图：睡眠 / 周期 / 抗压 / 代谢 / 专注
│  ├─ AI 身体翻译
│  ├─ 指标卡：平均能量 / 睡眠 / 专注 / 抗压 / 代谢
│  └─ 详情页：综合 / 睡眠 / 周期 / 专注 / 代谢
├─ Onboarding
│  ├─ 目标选择
│  ├─ 睡眠/频率/影响/触发因素问题
│  ├─ 健康权限模拟
│  └─ 生成 profile / prediction 后进入 Today
└─ 弹层与辅助
   ├─ 设置提醒
   ├─ profile panel
   ├─ stamp reveal
   └─ WebView 遗留：plus overlay、advisor modal、quick modal、旧 health detail
```

当前三 Tab 和子路由在代码里是明确状态机：`NativeTab = today | explore | health`，Today/Explore/Health 各有子 route，[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:55)；底部导航实际显示“今日 / 探索 / 健康”，[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:4283)。Explore 的主题为灵感、意识、关系、梦想，[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:552)；Health 详情 tabs 为综合、睡眠、周期、专注、代谢，[App.tsx](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/App.tsx:170)。

## 5. PM + IA 评估

### SWOT

| 维度 | 判断 | 证据 |
| --- | --- | --- |
| Strength | “身体翻译 + 当日行动”比普通仪表盘更有情绪价值。 | Today cards 把分数转成行动 CTA，[runtime.ts](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/src/lib/vitora/runtime.ts:602)。 |
| Weakness | 当前只是 mock 原型，不能证明健康准确性或长期留存。 | source 是 mock，[runtime.ts](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/src/lib/vitora/runtime.ts:276)；测试缺 CI 和截图 diff，[tests.md](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/documentation/tests.md:24)。 |
| Opportunity | Apple/Oura/Clue 已教育市场，但仍缺一个“温柔、日常、跨信号解释”的 companion。 | Oura 已分组多健康域，[Oura support](https://support.ouraring.com/hc/en-us/articles/360058599753-How-to-Use-the-Oura-App)；Clue 聚焦 menstrual health，[Clue About](https://helloclue.com/about-clue)。 |
| Threat | Oura、Apple、Fitbit/Google 可以把 AI 健康解释直接做进硬件生态。 | Oura 已拥有硬件数据和 app card 体系，[Oura support](https://support.ouraring.com/hc/en-us/articles/360058599753-How-to-Use-the-Oura-App)。 |

### Positioning Map

| 方向 | Vitora 当前相对位置 |
| --- | --- |
| 医疗/监管可信度 | 低：没有真实 HealthKit 后端、临床验证或 FDA 类定位。 |
| 情绪陪伴与表达 | 高：Explore/PillowTalk 和 Dori chat 是强表达入口，[flows.md](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/documentation/flows.md:42)。 |
| 行动闭环 | 中高：Today 有呼吸、专注、代谢、晨间等行动，但当前多为本地状态。 |
| 数据解释深度 | 中：runtime 有跨指标解释，但数据源是 mock。 |

### JTBD

核心 Job：当我看到身体状态波动、情绪敏感或效率下降时，我想知道这是不是和睡眠/周期/压力有关，并得到一个今天能做的小动作，而不是再看一堆指标。这个 Job 与 runtime 的“今日能量、身体翻译、主要行动”一致，[runtime.ts](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/src/lib/vitora/runtime.ts:596)。

次级 Job：当我有一句话、一个梦、一个关系困惑或一个反复念头时，我想把它记录下来，并让它成为身体状态解释的一部分。Explore flow 明确是卡片到 chat，再到 daily collection card，[architecture.md](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/documentation/architecture.md:35)。

### IA 四系统评估

| 系统 | 优点 | 问题 |
| --- | --- | --- |
| 组织 | 三 Tab 把“今天做什么 / 记录探索 / 健康复盘”分开，基础方向成立。 | `探索`、`健康` 和旧文档里的 `收集` 标签不一致，会伤害信息气味。 |
| 标签 | 今日、睡眠、周期、专注、代谢都是用户可理解词。 | “Dori 能量分析”“AI 身体翻译”“探索”之间关系需要更明确。 |
| 导航 | Bottom Tab 简单，详情页会隐藏底部导航，降低误触。 | WebView 遗留入口和 RN 覆盖入口并存，维护和 QA 成本高。 |
| 搜索/发现 | 健康详情和 Today 卡能从多个入口进入。 | 没有搜索，也没有任务级索引；未来记录变多后，用户难找历史模式。 |

## 6. 结论与建议

1. 定位收敛到“女性 AI 身体翻译 companion”，不要宣称医疗、避孕、诊断或 Oura 替代品；当前证据只能支持解释型、行动建议型原型。

2. P0 IA 建议保持三 Tab：`今日` 负责当日解释和行动，`探索` 负责表达/聊天/记录，`健康` 负责趋势/证据/复盘；不要新增第四个主 Tab。

3. 统一命名：当前报告建议把旧 `收集` 统一改成 `健康` 或明确为 `健康收藏`，否则用户会不清楚“记录、收藏、健康详情”的边界。

4. 数据可信度必须前置表达：在接入真实 HealthKit/Oura 前，所有健康分数都应标记为 mock/demo；现有 tests 文档也显示自动化验证不足，[tests.md](/Users/bytedance/Desktop/Work/vitamin-app/vitora-cycle-sandbox/vivi-oura-simulator/documentation/tests.md:24)。

5. 下一步产品验证不要先堆页面，先验证一个问题：目标用户是否愿意每天打开一个“把身体信号翻译成今天节奏”的 companion。可用 5 个任务做 tree test：看今日建议、理解低能量原因、记录一个感受、查睡眠证据、回看一周模式。
