# Vitora Swift Rebuild · 组件规格

> 规格集：`004-vitora-swift-rebuild`
> 批次：IA / Design Pivot Adaptation
> 日期：2026-05-05
> 状态：当前生效

本文档定义 Swift rebuild P0 的正式组件边界。它已吸收 `wireframes-walkthrough-demo.md` 与 `design-language-demo.md`，并废弃旧 Luna / 旧 Today record / 旧 Cycle calendar home 组件方向。

## 0. 权威规则

| Rule ID | Rule | Constraint |
| --- | --- | --- |
| C-AUTH-001 | `spec.md` 决定组件行为。 | 每个 P0 组件必须服务至少一个 `REQ-*`。 |
| C-AUTH-002 | `ia.md` 决定组件位置。 | 组件不得新增 IA 之外的主路由。 |
| C-AUTH-003 | `wireframes.md` 决定结构。 | 组件不得恢复旧 wireframe。 |
| C-AUTH-004 | `design-tokens.md` 决定视觉 token。 | 组件只引用 `vt.*`，不得散落新样式。 |
| C-AUTH-005 | 用户面对统一使用 Vitora。 | `Luna*` 组件名只可作为 legacy migration note，不可作为新产品组件。 |
| C-AUTH-006 | Cycle 首页执行规格见 `cycle-page/cycle-page-spec.md`。 | 涉及 Cycle 首页视觉、布局、图表、Tip 或 Tab 避让时，先读 `cycle-page/` spec pack。 |
| C-AUTH-007 | Vitora Tab 执行规格见 `vitora-page/vitora-page-spec.md`。 | 涉及 assistant surface、Quick Context、Input Dock 或周期展开态时，先读 `vitora-page/` spec pack。 |
| C-AUTH-008 | Dynamic Aura 背景执行规格见 `dynamic-aura-background/dynamic-aura-background-spec.md`。 | 涉及首层视频背景、周期色变体或 Reduce Motion poster 时，先读 `dynamic-aura-background/` spec pack。 |

## 1. 组件字段模板

| 字段 | 是否必需 | 含义 |
| --- | --- | --- |
| Component ID | Yes | `C-AREA-XXX`，稳定引用。 |
| Name | Yes | 中文名 + implementation candidate。 |
| Layer | Yes | Foundation / Primitive / Composite / Feature / Screen。 |
| Purpose | Yes | 组件提供的用户价值。 |
| Appears In | Yes | 关联 IA。 |
| Linked Specs | Yes | `REQ-*`, `UF-*`, `IA-*`, `WF-*`。 |
| Tokens | Yes | 依赖的 `vt.*` token。 |
| 状态 | Yes | 正常、低数据、输入、加载、确认、错误等。 |
| Interactions | Yes | tap、long-press、drag、type、voice、confirm。 |
| Acceptance | Yes | 可验收标准。 |
| Do Not | Yes | 明确禁止的旧行为。 |

## 2. 组件索引

### 2.1 App / Global

| ID | 名称 | 层级 | 优先级 | 主要规格 |
| --- | --- | --- | --- | --- |
| C-APP-001 | AppGate | Screen | P0 | REQ-001, IA-000 |
| C-APP-002 | OnboardingStack | Screen | P0 | REQ-001, REQ-002; 注册进入页 + 聊天式补充页，完成后直接进入 Today |
| C-APP-003 | PrimaryTabBar | Composite | P0 | IA-010, IA-020, IA-030 |
| C-APP-004 | VitoraFaceTabButton | Composite | P0 | REQ-010, WF-V-001 |
| C-APP-005 | ScreenScaffold | Composite | P0 | all WF |
| C-APP-006 | NativeSheetSurface | Composite | P0 | IA-011 to IA-024 |
| C-APP-007 | AskableSurface | Composite | P0 | REQ-009 |
| C-APP-008 | ContextMenuAction | Composite | P0 | REQ-009 |
| C-APP-009 | CalloutBubble | Composite | P0 | WF-C-003 |
| C-APP-010 | TipKitHint | Composite | P0 | REQ-009 |

### 2.2 Today

| ID | 名称 | 层级 | 优先级 | 主要规格 |
| --- | --- | --- | --- | --- |
| C-TODAY-001 | DateCycleContextStrip | Feature | P0 | REQ-004, REQ-013 |
| C-TODAY-002 | TodayPixelVitoraDecoration | Feature | P0 | REQ-016 |
| C-TODAY-003 | TodayStatusCard | Feature | P0 | REQ-004 |
| C-TODAY-004 | RhythmCurve | Composite | P0 | REQ-004 |
| C-TODAY-005 | CalibrationChips | Composite | P0 | REQ-008 |
| C-TODAY-006 | BodyFactorTiles | Feature | P0 | REQ-006 |
| C-TODAY-007 | TodayInsightPanel | Feature | P0 | REQ-007 |
| C-TODAY-008 | EnergyBowlRealtimePrediction | Feature | P0 | REQ-005 |
| C-TODAY-009 | TodayCalendarSheet | Feature | P0 | REQ-013 |
| C-TODAY-010 | TodayStateDetailSheet | Feature | P0 | REQ-004 |
| C-TODAY-011 | BodyFactorsDetailSheet | Feature | P0 | REQ-006 |
| C-TODAY-012 | SuggestionDetailSheet | Feature | P0 | REQ-007 |
| C-TODAY-013 | MorningGrowthFeedbackCard | Feature | P0 | REQ-011, REQ-012 |
| C-TODAY-014 | GardenManualSheet | Feature | P0 | REQ-011, REQ-012 |

### 2.3 Vitora

| ID | 名称 | 层级 | 优先级 | 主要规格 |
| --- | --- | --- | --- | --- |
| C-VITORA-001 | PixelVitoraHero | Feature | P0 | REQ-010, REQ-016 |
| C-VITORA-002 | VitoraKnowsPanel | Composite | P0 | REQ-010 |
| C-VITORA-003 | VitoraDateContextStrip | Composite | P0 | REQ-010 |
| C-VITORA-004 | AssistantMessageBubble | Composite | P0 | REQ-010 |
| C-VITORA-005 | DirectQuestionStrips | Composite | P0 | REQ-010 |
| C-VITORA-006 | QuickContextChips | Composite | P0 | REQ-010, REQ-011 |
| C-VITORA-007 | VitoraInputDock | Composite | P0 | REQ-010, REQ-011 |
| C-VITORA-008 | VoiceRecordStatePanel | Composite | P0 | REQ-011 |
| C-VITORA-009 | RichResponseCard | Composite | P0 | REQ-011 |
| C-VITORA-010 | VitoraContextualSheet | Feature | P0 | REQ-008 |
| C-VITORA-011 | VitoraFullContextMode | Feature | P0 | REQ-008, REQ-010 |
| C-VITORA-012 | UnderstandingConfirmSheet | Feature | P0 | REQ-011 |
| C-VITORA-013 | GardenEveningReviewEntryCard | Feature | P0 | REQ-011 |

### 2.4 Cycle

| ID | 名称 | 层级 | 优先级 | 主要规格 |
| --- | --- | --- | --- | --- |
| C-CYCLE-001 | CycleHeaderActions | Composite | P0 | REQ-012, REQ-014 |
| C-CYCLE-002 | CycleReviewGrowthAlbumHero | Feature | P0 | REQ-012 |
| C-CYCLE-003 | CycleReviewInsightCard | Feature | P0 | REQ-012 |
| C-CYCLE-004 | EnergyDynamicsCard | Feature | P0 | REQ-012 |
| C-CYCLE-005 | GranularitySegment | Primitive | P0 | REQ-012 |
| C-CYCLE-006 | EnergyDynamicsChart | Composite | P0 | REQ-012 |
| C-CYCLE-007 | VitoraNarrativeRow | Composite | P0 | REQ-012 |
| C-CYCLE-008 | CurrentPhaseDetailSheet | Feature | P0 | IA-031 |
| C-CYCLE-009 | EnergyDynamicsDetailSheet | Feature | P0 | IA-032 |
| C-CYCLE-010 | FlowerMapView | Feature | P0 | D-076 |
| C-CYCLE-011 | CycleEnergyCalendarDashboard | Feature | P0 | D-093 |

### 2.5 Support / Trust

| ID | 名称 | 层级 | 优先级 | 主要规格 |
| --- | --- | --- | --- | --- |
| C-SUPPORT-001 | SettingsPanel | Feature | P0 | REQ-014 |
| C-SUPPORT-002 | ProfilePanel | Feature | P0 | IA-041 |
| C-SUPPORT-003 | DataSourcePanel | Feature | P0 | IA-042 |
| C-SUPPORT-004 | NutritionManager | Feature | P0 | IA-043 |
| C-SUPPORT-005 | ReminderPreferencePanel | Feature | P0 | IA-044 |
| C-SUPPORT-006 | DataExportPanel | Feature | P0 | IA-045 |
| C-SUPPORT-007 | LegalAccountPanel | Feature | P0 | IA-046 |
| C-SUPPORT-008 | ComplianceLabel | Primitive | P0 | REQ-015 |

## 3. Global Components

### C-APP-003 · PrimaryTabBar

| 字段 | 规格 |
| --- | --- |
| Purpose | 固定三个主区：Today / Vitora / Cycle。 |
| Appears In | IA-010, IA-020, IA-030 |
| Linked Specs | REQ-004, REQ-010, REQ-012, WF-T-001, WF-V-001, WF-C-001 |
| Tokens | `vt.layout.tab.*`, `vt.glass.g2.panel`, `vt.glow.cta` |
| 状态 | todaySelected、vitoraSelected、cycleSelected、globalInputDock、quickRecord、sheetPresented |
| Interactions | tap 切换；点击 `AI管家` 只切换到 Assistant Surface 并展示输入快捷栏，点击输入栏本身才聚焦键盘；D-087 后中心凹槽悬浮圆形 `+` 打开快捷补充 sheet 且不切 Tab，长按进入语音记录；sheet 打开时隐藏。 |
| Acceptance | 只有 3 个 tab；底部为一体式白色圆角凹槽 Dock，左右承载 `今日 / 周期`，中心悬浮圆形 `+` 触控不小于 44pt；D-088 后 Dock 下移贴近底部并带一层轻霜态嵌入底座，中心 `+` 为蓝绿色半透明霜态玻璃；D-090 后 Dock 本体与左右 Tab 胶囊进一步收窄，中心 `+` 更轻、更透明，短按手动记录、长按语音记录不变；Today / Cycle 不显示输入条；Tab 和记录均不进入输入胶囊，不保留右侧独立圆形 `+`。 |
| Do Not | 不用心形普通图标代替 Vitora face；不新增第四 tab。 |

### C-APP-007 · AskableSurface

| 字段 | 规格 |
| --- | --- |
| Purpose | 让真实 UI 对象可被询问，同时避免首页堆按钮。 |
| Appears In | Today cards, Cycle cards, detail charts |
| Linked Specs | REQ-009, UF-005, WF-G-005 to WF-G-008 |
| Tokens | `vt.motion.contextMenuPress`, `vt.glass.g1.clearCard` |
| 状态 | normal、pressed、contextMenuOpen、calloutSelected、sheetLaunching |
| Interactions | tap 详情；long-press context menu；chart point tap callout；`⋯` fallback。 |
| Acceptance | 不懂长按的用户仍可单击进入详情；TipKit 只教学一次。 |
| Do Not | 不把长按作为唯一入口；不在每个卡片常驻问 Vitora 按钮。 |

## 4. Today Components

### C-TODAY-001 · DateCycleContextStrip

| 字段 | 规格 |
| --- | --- |
| Purpose | 在 Today 左上角用最小占位提供日期、周期阶段和能量入口。 |
| Appears In | IA-010 |
| Linked Specs | REQ-004, REQ-013, WF-T-001, WF-T-003 |
| Tokens | `vt.glass.g1.clearCard`, `vt.color.energy.yellow`, `vt.type.caption` |
| 状态 | todaySelected、lowData |
| Interactions | 点击整卡打开 Today 周期日历浮层。 |
| Acceptance | 宽约 190-205pt、高约 66-72pt；只显示星期、日期、`黄体 D18`、横向能量条和数值 `68`；不显示睡眠、步数、日历 icon 或冗长 `/100` 占位。 |
| Do Not | 不把顶部入口做成大日历组件或信息 dashboard。 |

### C-TODAY-009 · TodayCalendarSheet

| 字段 | 规格 |
| --- | --- |
| Purpose | 从 Today 快速理解当天周期背景，并回看当月阶段。 |
| Appears In | IA-012 |
| Linked Specs | REQ-013, WF-T-003 |
| Tokens | `vt.bg.aura.sheet`, `vt.glass.g2.panel`, `vt.shadow.glass.low`, `vt.color.phase.*` |
| 状态 | open、monthChanging、daySelected、moreMenu |
| Interactions | 返回 Today、切换月份、选择日期、打开更多、点击记忆箱。 |
| Acceptance | 左侧约 3/4 宽纸质浮层，右侧露出虚化 Today 背景；顶部无“周期日历”标题和说明副标题；月历使用英文周标题和阶段色虚线圆点；5 号黑色实心选中、4 号蓝描边、16-20 粉、21-28 绿、29-31 橙；下方为浅粉撕边便签和 2x2 木制记忆箱。 |
| Do Not | 不放到 Cycle 首页；不保留行动链、过去几天、大白卡统计块、普通彩色 memory box 或底部双按钮噪音。 |

### C-TODAY-003 · TodayStatusCard

| 字段 | 规格 |
| --- | --- |
| Purpose | 首页 3 秒内回答“今天怎么样”。 |
| Appears In | IA-010 |
| Linked Specs | REQ-004, UF-002, WF-T-001 |
| Tokens | `vt.bg.aura.today`, `vt.glass.g1.clearCard`, `vt.color.action.cyan`, `vt.type.energyNumber` |
| Content Slots | 低代码日期标题、创意趋势卡、共享聊天记录卡。 |
| 状态 | collapsed、expanded、topicEnergy、topicSleep、topicPeriod、topicNutrition、lowData |
| Interactions | 点击低代码日期标题打开左侧周期日历抽屉；创意趋势卡只表达状态和温馨留言；long-press askable menu。 |
| Acceptance | 顶部黑色三格 `TopModeSelector` 不出现；主视觉为 SwiftUI/Canvas `FlowerEnergyBloomView`，包含橙色半碗能量弧、中心花茎花朵、左右虚线轨道、前天/昨天/今天节点；不得使用外部图片；保留 `egg.compound.mascot` id；`PixelFrostedGlassEgg` 保留为设计系统备用但不作为首页主视觉；D-075 后花组件和右侧维度切换压缩在首屏上方约 1/3，红色虚线不遮挡聊天/反馈条；D-078 后当前默认 `68%` 只进入能量碗，今天节点未满 `80%` 时显示种子苗和阈值提示，不显示成熟向日葵或 `100% 同品种双朵共生` 气泡；达到 `80%` 后才切换为向日葵，达到 100% 且同品种时才显示共生气泡；时间线为直线，移除整体呼吸缩放，仅保留慢速轻摆和点击一次性反馈；D-079 后花组件下方不显示独立 `68/100 查看分析`；D-080 后主视觉采用接近整屏宽的 hero band，右侧维度胶囊必须独立悬浮且不覆盖水桶、`68%`、今天节点、阈值提示或红色虚线；D-081 后继续降低挤压感：水桶宽度收敛、历史节点更疏散、阈值提示上移、右侧胶囊缩小并上移，所有信息不能堆叠在水桶中心；D-083 后折叠/聊天态不再显示 `今日 / 睡眠 / 经期 / 营养` chips；D-086 后折叠/聊天态为直接浮在现有 Aura 背景上的全屏前景聊天卡，不显示外层磨砂玻璃底板，旧顶部小日历和微缩花盆在完全折叠时淡出，卡片头部展示日期与 `Today` 像素标题，聊天框顶部用轻量原生像素小图表达当前时间、深圳区域和周期背景，消息区不显示左侧虚线时间轴或时间胶囊，Vitora 消息使用柔白 Pixel 头像 + 气泡，用户消息右对齐；记录完成后上移反馈条显示记录摘要和温馨提示，反馈条右侧不显示灰色圆形附加记录/提醒按钮；不出现实时预测图、校准 chips、收割/花粉/图鉴/种子兑换、连续打卡、外层磨砂玻璃底板、常驻输入框或独立记录区。 |
| Do Not | 不做顶部下拉 Energy Ball；不做复杂 dashboard；不把花画成厚重拟物或外部图片；不在花组件下方重复展示主数字和 CTA。 |

D-086/D-089/D-091 补充：前景白色聊天卡左右贴近可用宽度，底部延伸到 Dock 后方；日期和像素 `Today` 头部更靠左上；右上汉堡菜单为 `today.collapsed.calendarMenu`，点击打开左侧周期日历抽屉。D-089 后展开态暂停花朵玩法主视觉，使用 `today.creativeTrend.card` 小型创意趋势卡，不展示水桶、种子苗、花朵成长或右侧维度胶囊。D-091 后展开态也使用同一个聊天记录卡，不再显示旧三环 `TodayInsightPanel` 首页卡。

### C-TODAY-008 · EnergyBowlAndAnalysisPrediction

| 字段 | 规格 |
| --- | --- |
| Purpose | 首页展示分层综合能量碗与数据入口；今日分析展示完整综合实时预测。 |
| Appears In | IA-010, IA-011 |
| Linked Specs | REQ-005, UF-003, UF-007, WF-T-002, WF-R-001 |
| Tokens | `vt.glass.g1.clearCard`, `vt.color.action.cyan`, `vt.type.energyNumber`, `vt.motion.tap` |
| 状态 | richData、lowData、uncertain、reviewComparison |
| Interactions | 点击能量碗；点击 `查看数据`；在今日分析查看球形分数报告、监测项解释、综合实时预测和今日推荐。 |
| Acceptance | 不冒充刷新；不使用顶部下拉 Energy Ball；首页固定综合能量，不显示睡眠/周期模式切换、实时预测图、数据小标签或校准 chips；首页周期只显示前一阶段/当前阶段/下一阶段三点圆弧，当前 D18 为 `排卵期 / 黄体期 D18 / 月经期`，当前阶段段落加粗着色；今日分析顶部显示 `黄体期 Day 18`，球形纹路报告中间显示 68 分，下面列出睡眠、HRV、周期等关键监测项、解释综合实时预测，并直接给出今日推荐；能量碗和 `查看数据` 打开同一张今日分析。 |
| Do Not | 不把 Energy Ball 做成下拉头部；不长动画阻塞用户；不展示未接入数据源的血糖判断。 |

### C-TODAY-007 · TodayInsightPanel

| 字段 | 规格 |
| --- | --- |
| Purpose | 用主题化信息框承接首页下方具体内容，替换旧 `智能监测` 首页位置。 |
| Appears In | IA-010, IA-015 |
| Linked Specs | REQ-007, UF-004, WF-T-006 |
| Tokens | `vt.glass.g2.panel`, `vt.color.action.blue`, `vt.shadow.glass.low` |
| 状态 | energySummary、energyExpanded、sleepDetail、periodDetail、nutritionRecord、reminderSet |
| Interactions | 随主题弧选择切换内容；点击 `今日能量` 标题或 `为什么` 展开原因列表、轻建议和 `✓ 提醒`；`✓ 提醒` 复用现有提醒 Sheet；`+ 记一笔` 打开 Vitora contextual sheet，不切换主 Tab；睡眠、经期、营养主题展示各自详情。 |
| Acceptance | `今日能量` 默认结构为三枚环形指标、营养/补充 chips、Vitora 黄色提示、黑色 `+ 记一笔` 和 `今日 68/100`；睡眠主题展示睡眠时长、恢复、HRV 等依据；经期主题展示黄体期 D18 阶段解释和建议；营养主题展示补水/补给记录，并明确只记录已在使用内容，不做购买引导；卡内可展示 HRV/心率作为依据，但不得变成首页弧上主题；形成当日意图并连接晚间复盘；不制造任务失败。 |
| Do Not | 不保留首页扑克牌式 `智能监测` 作为主信息框；不做任务清单、打卡、完成率或销售化营养入口。 |

### C-TODAY-013 · MorningGrowthFeedbackCard

| 字段 | 规格 |
| --- | --- |
| Purpose | 已移出 P0 可见路径。Today 不再展示早晨成长反馈卡。 |
| Appears In | IA-010 |
| Linked Specs | REQ-011, REQ-012, UF-007 |
| Tokens | `vt.glass.g2.panel`, `vt.color.phase.*`, `vt.shadow.glass.low` |
| 状态 | removed |
| Interactions | 无。 |
| Acceptance | Today 首页不得出现“昨晚的薄荷芽发芽了”“查看成长卡”等成长反馈入口。 |
| Do Not | 不把昨晚复盘包装成任务结算或奖励结算页。 |

### C-TODAY-014 · GardenManualSheet

| 字段 | 规格 |
| --- | --- |
| Purpose | 已移出 P0 可见路径。Today 不再展示花园手册入口或 Sheet。 |
| Appears In | IA-017 |
| Linked Specs | REQ-011, REQ-012, UF-007, UF-008 |
| Tokens | `vt.glass.g3.sheet`, `vt.color.phase.*`, `vt.shadow.glass.low` |
| 状态 | removed |
| Interactions | 无。 |
| Acceptance | Today 首页和子页面不得出现 `花园手册`、今晚可种、最近成长卡或成长册跳转。 |
| Do Not | 不新增花园 Tab；不显示商城、VIP、露珠价格、枯萎、失败、红点或连续打卡。 |

## 5. Vitora Components

### C-VITORA-001 · PixelVitoraHero

| 字段 | 规格 |
| --- | --- |
| Purpose | 建立“Vitora 活在 app 里”的 IP 感。 |
| Appears In | IA-020, IA-021, IA-022 |
| Linked Specs | REQ-010, REQ-016, WF-V-001, WF-V-002 |
| Tokens | `vt.ip.*`, `vt.glow.pixel.*`, `vt.bg.aura.vitora` |
| 状态 | idle、listening、thinking、confirming、compressed |
| Interactions | subtle breath、blink、scroll compress；P0 不要求完整互动游戏化。 |
| Acceptance | 像素球状体；眼睛必须 pixel；Vitora Tab 内 hero、背景氛围和小 face 必须服从 `vitora-page/vitora-page-spec.md`；造型、材质、表情、道具必须服从 `pixel-vitora-ip/pixel-vitora-ip-spec.md`。 |
| Do Not | 不用 smooth orb、人类头像、宠物或普通 icon。 |

### C-VITORA-007 · VitoraInputDock

| 字段 | 规格 |
| --- | --- |
| Purpose | AI 管家页统一 Vitora 输入：文字、语音和发送。 |
| Appears In | IA-010, IA-020, IA-021, IA-022, IA-023, IA-030 |
| Linked Specs | REQ-010, REQ-011, UF-005, UF-006 |
| Tokens | `vt.glass.g3.sheet`, `vt.layout.inputDock.height`, `vt.layout.tab.lowLift` |
| 状态 | empty、typing、sendEnabled、voiceReady、recording、transcribed、aiUnavailable |
| Interactions | type、send、voice record、keyboard avoidance；点击输入栏本身触发聚焦。 |
| Acceptance | 顺序固定为语音/键盘、输入或内联语音条、发送；右侧发送固定且空态/可发送态清楚；只在 AI 管家页展开；点击 Today/Cycle/记录不自动聚焦；AI 不可用时输入保留并可手动保存。 |
| Do Not | 不做只有 placeholder 的空聊天；不隐藏发送路径；不在输入区混入 `+`、周期小花、记录键或 Tab 切换按钮。 |

### C-VITORA-010 · VitoraContextualSheet

| 字段 | 规格 |
| --- | --- |
| Purpose | 从 Today / Cycle 对象轻量唤醒 Vitora，不打断原任务。 |
| Appears In | IA-021 |
| Linked Specs | REQ-008, UF-005, WF-V-005 |
| Tokens | `vt.glass.g3.sheet`, `vt.motion.sheet.spring` |
| 状态 | presented、sourceContext、manualHealth、aiHealth、aiVoice、aiText、periodStateSelected、outlineExpanded、optionSelected、mediaSelected、noteEditing、parsePreview、voicePermissionFallback、saved、dismissed |
| Interactions | close、下拉关闭、点空白关闭、切换 `手动记账 / AI记录`、切换 `语音 / 打字`、切换 `是经期 / 否经期`、展开健康大纲、展开更多支线、选择/取消词条、选择图片/拍照/语音入口、填写留言条、AI 语音记录、转打字、AI 本地解析、再记、完成；可由 Dock 中心凹槽圆形 `+` 点按打开手动记录，也可由长按 `+` 或无障碍 `语音记录 / 打字记录` 直接打开对应 AI 输入态。 |
| Acceptance | 只保留前景白色圆角底部卡片；AppRouter 在 sheet 打开时提供全屏透明 hit-test backdrop 拦截后方点击，点空白只关闭不透传；顶部保留拖拽条并新增 44pt 关闭按钮 `vitora.context.close`；双模式为 `手动记账 / AI记录`，Dock `+` 点按默认 `手动记账` active，长按默认 `AI记录 > 语音` active；手动模式显示 `是经期 / 否经期`，默认展示 5-8 个健康大纲，每个大纲默认露出 5 个高频词条，点击大纲或 `更多` 展开全部支线，词条用 Apple SF Symbols 且点击即可选中/取消；`是经期` 包含经期情况、身体状态、心情、服药、营养补充剂、健康小忌，`否经期` 包含白带、身体状态、心情、皮肤、爱爱、营养补充剂、健康小忌；下方包含日期/周期上下文字段、图片/拍照/语音入口和 `vitora.record.note.input` 留言条；不显示 `支出 / 收入 / 转账`、财务分类、金额输入卡、备注金额区、数字键盘或删除键；完成按钮不会卡在不可点击状态；AI 模式内有 `语音 / 打字` 二级切换，语音态展示 mic、录音状态、转写展示、`重新说 / 转打字 / 解析`，权限拒绝或不可用时降级到打字；打字态展示一句话输入、发送、快捷示例、`AI 已拆出字段` 预览卡和同一留言条；打开时全局 Dock 隐藏；关闭回来源；快捷记录不切换到 Vitora Tab、不改写全局输入草稿；完成后只写入运行态 `RecentRecordFeedback` 并关闭，不进入时间线。 |
| Do Not | 不直接切到 Vitora tab；不未经确认保存；不接真实模型；不新增财务或健康 schema；不展示 Luna 文案、购买引导、医学诊断或完成后时间线。 |

### C-VITORA-013 · GardenEveningReviewEntryCard

| 字段 | 规格 |
| --- | --- |
| Purpose | 在 AI 管家页承接晚间复盘入口与睡眠种子解释，不新增独立花园路径。 |
| Appears In | IA-020, IA-024 |
| Linked Specs | REQ-011, UF-007 |
| Tokens | `vt.glass.g2.panel`, `vt.color.phase.*`, `vt.shadow.glass.low` |
| 状态 | available、lockedUntilEvening、seed、halfOpen、bloom、dormant |
| Interactions | 点击进入晚间复盘；点击种子解释打开 Vitora 上下文补充。 |
| Acceptance | 晚间复盘反馈后可选择 3 个种子方向；AI 管家解释种子为何半开、今日建议如何帮助它、哪些反馈能让 Vitora 判断更准。 |
| Do Not | 不显示强提醒、红点、连续打卡、商城、VIP、露珠价格、失败惩罚或完整花园入口。 |

## 6. Cycle Components

### C-CYCLE-001 · CycleHeaderActions

| 字段 | 规格 |
| --- | --- |
| Purpose | 在 Cycle Header 提供我的/设置入口和轻量周期卡片分享。 |
| Appears In | IA-030 |
| Linked Specs | REQ-012, REQ-014, WF-C-001 |
| Tokens | `vt.glass.g1.clearCard`, `vt.motion.tap` |
| 状态 | resting、pressed、shareSheetPresented、settingsPresented |
| Interactions | 左上头像打开 `我的 / 设置`；右上分享生成周期卡片截图并调用原生 iOS 分享面板。 |
| Acceptance | 两个入口触控不小于 44pt；头像不是 Pixel Vitora；分享不导出记录原文、prompt、完整 AI 输出或隐藏健康数据；首页执行细节服从 `cycle-page/cycle-page-spec.md`。 |
| Do Not | 不新增第四个 Tab；不做 WebView 分享；不把头像当作 assistant IP。 |

### C-CYCLE-002 · CycleReviewGrowthAlbumHero

| 字段 | 规格 |
| --- | --- |
| Purpose | 已移出 P0 可见路径。Cycle 不再展示 30 天成长册。 |
| Appears In | IA-030, IA-031 |
| Linked Specs | REQ-012, UF-008, WF-C-001, WF-C-002 |
| Tokens | `vt.glass.g1.clearCard`, `vt.color.phase.*`, `vt.shadow.glass.low` |
| 状态 | removed |
| Interactions | 无。 |
| Acceptance | Cycle 首页不得出现 `30 天成长册`、8/30、成长卡网格或种下/发芽/花苞/盛开图例；首页执行细节服从 `cycle-page/cycle-page-spec.md`。 |
| Do Not | 不做周期科普墙；不做商业化入口。 |

### C-CYCLE-003 · CycleReviewInsightCard

| 字段 | 规格 |
| --- | --- |
| Purpose | 在能量日历和 6.5 指标卡下方承接详情内容，解释本周、趋势对比和近期状态。 |
| Appears In | IA-030 |
| Linked Specs | REQ-012, UF-008, WF-C-001 |
| Tokens | `vt.glass.g2.panel`, `vt.color.phase.*`, `vt.motion.tabCrossfade` |
| 状态 | week、trendComparison、recent、reduceMotion |
| Interactions | D-093 后由指标卡下方的 `本周 / 趋势对比 / 近期` 三段入口驱动内容切换；切换时 220-280ms cross-fade + 内容轻微 fade-up；卡片内详情继承当前 tab accent。 |
| Acceptance | 详情内容区位于报告入口下方并可继续滚动查看；默认本周展示标题、状态摘要、7 日柱状图、三段说明、四格监测摘要和当前周期进度；趋势（对比）展示月度综合对比、4 行蓝色进度条、归因解释和本月总结；近期展示能量折线图、监测到了什么、近期结论 / 下一步和黄色描边按钮；三个胶囊触控不小于 44pt；不制造任务完成或失败感。 |
| Do Not | 不重排整个 Cycle 首页；不显示完成率、连续天数、红点、打卡、购买引导或医学诊断。 |

### C-CYCLE-010 · FlowerMapView

| 字段 | 规格 |
| --- | --- |
| Purpose | 在 Cycle 顶部用轻量花之地图承接长期节律和恢复资源积累，同时把 D-073 报告卡保留在下方作为主要解释层。 |
| Appears In | IA-030, WF-C-001 |
| Linked Specs | D-076 |
| Tokens | `vt.bg.aura.cycle`, `vt.glass.g1.clearCard`, `vt.motion.tap` |
| Content Slots | 深圳 / 广州点状路线、透明圆形种花引导、二维字符串轮廓地图、不规则菱形 tile、花朵收集入口、花朵详情浮层、玩法说明浮层。 |
| 状态 | readyToPlant、plantedToday、tileEmptySoil、tileSprout、tileBloom、tileToday、tileLocked、detailPresented、helpPresented、citySelected |
| Interactions | 点击 `种下今天的花` 或成熟状态下点击空地，把今日花种到下一个空格；点击已种花朵展示日期、能量和状态详情；点击问号展示玩法说明；点击城市路线节点切换查看未来城市阶段。 |
| Acceptance | 原生 SwiftUI 实现，不使用 RN/Expo、图片素材、地图 SVG 或复杂动画库；地图和下方详情必须位于同一个大圆角描边外框内；种花动效为 0.72→1.0 scale + 淡黄 pulse；种下后透明圆形引导显示 `今日已种下`。 |
| Do Not | 不做打卡、完成率、连续天数、红点、任务失败；不把花之地图变成第四主 Tab、完整花园系统或成长册；不删除 D-073 报告卡。 |

### C-CYCLE-011 · CycleEnergyCalendarDashboard

| 字段 | 规格 |
| --- | --- |
| Purpose | 在 Cycle 首页用折叠/展开能量日历和 `6.5` 指标卡承接周期复盘首屏。 |
| Appears In | IA-030, WF-C-001 |
| Linked Specs | D-093 |
| Tokens | `vt.bg.aura.cycle`, `vt.glass.g1.clearCard`, `vt.motion.tap` |
| Content Slots | 融合式我的/分享入口、折叠周历 strip、展开月历网格、选中日能量细进度条、今日/本周能量摘要、小号 `6.5` 参考 chip、底部报告分段入口。 |
| 状态 | collapsed、expanded、selectedDay、week、trendComparison、recent、reduceMotion |
| Interactions | 点击 chevron 展开/收起月历；点击日期更新选中日能量摘要；点击 `本周 / 趋势对比 / 近期` 切换滚动后的报告详情；左上我的/右上分享保持原有语义。 |
| Acceptance | 使用原生 SwiftUI 绘制；左上我的、右上分享和周历 strip 融合在同一张大圆角顶部卡内；折叠态每天是大椭圆 pill + 内部圆环能量进度，展开态所有日期有细进度条；摘要卡主信息为今天能量和本周平均，`6.5` 只作为小参考 chip；不显示任务勾选、失败、完成率、连续天数、红点或经期管理 dashboard。 |
| Do Not | 不使用 RN/Expo、图片素材、SVG；不恢复花园手册、成长册、任务花田地图或额外 Tab；不把 `6.5` 文案写成诊断或治疗建议。 |

### C-CYCLE-004 · EnergyDynamicsCard

| 字段 | 规格 |
| --- | --- |
| Purpose | 让用户查看日/周/月能量动态和 Vitora 叙事摘要。 |
| Appears In | IA-030, IA-032 |
| Linked Specs | REQ-012, UF-009, WF-C-001, WF-C-003 |
| Tokens | `vt.glass.g1.clearCard`, `vt.color.action.cyan`, `vt.motion.tap` |
| 状态 | daily、weekly、monthly、selectedPoint、lowData、layerToggled |
| Interactions | segmented control、tap detail、chart point callout、long-press context menu。 |
| Acceptance | 首页只预览；二层可探索趋势和关键点；Vitora 叙事说明为什么；首页执行细节服从 `cycle-page/cycle-page-spec.md`。 |
| Do Not | 不重复 Today 当前状态；不堆高级健康图表。 |

### C-CYCLE-006 · CycleSeedEvidenceShelf

| 字段 | 规格 |
| --- | --- |
| Purpose | 用真实花种低成本展示本周期哪些建议真的对用户有用。 |
| Appears In | IA-030 |
| Linked Specs | REQ-012, UF-008, WF-C-001 |
| Tokens | `vt.glass.g2.panel`, `vt.color.action.blue`, `vt.shadow.glass.low` |
| 状态 | wilted、score60、score80、score100 |
| Interactions | 点击花卡可问 Vitora 或查看对应建议反馈；P0 可先静态展示最近 7-10 张。 |
| Acceptance | 标题为 `本周期花架证据`；只展示“建议 → 反馈”的学习结果；花卡读取统一 `SleepSeedCard` 的真实花种、阶段和分数；不显示成长册进度、完成率、连续天数、金币、商店或花田地图。 |
| Do Not | 不作为 Cycle 主视觉；不显示 `30 天成长册`、8/30、种子选择或每日网格。 |

## 7. Support Components

### C-SUPPORT-001 · SettingsPanel

| 字段 | 规格 |
| --- | --- |
| Purpose | P0 支撑入口：个人、数据、营养、提醒、导出、隐私/账号。 |
| Appears In | IA-040 to IA-046 |
| Linked Specs | REQ-014, UF-010, WF-S-001 |
| Tokens | `vt.glass.g4.support`, `vt.bg.aura.support` |
| 状态 | home、childPanel、exportPreparing、removalConfirming、done |
| Interactions | row tap、back、confirm danger action、dismiss。 |
| Acceptance | 只显示 P0 必需六类；危险动作有确认和结果反馈。 |
| Do Not | 不显示 VIP、主题、帮助墙、小组件、完整养成。 |

## 8. Legacy Component Remap

| Old Component | Status | Replacement |
| --- | --- | --- |
| `TodayStateOrb` as homepage hero | deprecated | `EnergyBowlRealtimePrediction` + `TodayStatusCard` |
| `TodayQuickRecordCarousel` | removed | `CalibrationChips` + `VitoraContextualSheet` |
| `LunaPixelHomeCard` | renamed / redesigned | `PixelVitoraHero` + `VitoraKnowsPanel` |
| `LunaContextBubble` | renamed | `AssistantMessageBubble` |
| `LunaInputDock` | renamed | `VitoraInputDock` |
| `LunaRecordSheet` | redesigned | `VitoraContextualSheet` + `UnderstandingConfirmSheet` |
| `LunaImmersiveChatSurface` | deprecated as mental model | `VitoraAssistantSurface` + `VitoraFullContextMode` |
| `CycleOverviewCard` old basic card | replaced | `CurrentPhaseRelationCard` |
| `CycleCalendarGrid` on Cycle home | removed from Cycle home | `TodayCalendarSheet` |
| Wide drawer | removed | `SettingsPanel` |

## 9. QA 清单

- 每个首层组件都有 `vt.glass.g1/g2` 或 `vt.bg.aura.*` token 归属。
- 所有新 Vitora 组件使用 `Vitora` 命名；旧 `Luna` 只作为迁移债说明。
- Today 没有独立记录组件。
- Cycle 没有首页日历组件。
- Vitora Tab 有 PixelVitoraHero、VitoraKnowsPanel、DirectQuestionStrips、QuickContextChips、VitoraInputDock。
- AskableSurface、ContextMenuAction、CalloutBubble、TipKitHint 都有明确交互和 fallback。
