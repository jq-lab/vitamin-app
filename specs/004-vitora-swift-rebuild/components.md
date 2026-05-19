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
| C-APP-002 | OnboardingStack | Screen | P0 | REQ-001, REQ-002 |
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
| C-TODAY-007 | VitoraDailySuggestionCard | Feature | P0 | REQ-007 |
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
| Interactions | tap 切换；点击 `AI管家` 展开并聚焦输入；右侧圆形 `+` 打开快捷补充 sheet 且不切 Tab；sheet 打开时保持或弱化。 |
| Acceptance | 只有 3 个 tab；Tab 组居中；右侧圆形 `+` 触控不小于 44pt；Today / Cycle 不显示输入条；Tab 和记录均不进入输入胶囊。 |
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

### C-TODAY-003 · TodayStatusCard

| 字段 | 规格 |
| --- | --- |
| Purpose | 首页 3 秒内回答“今天怎么样”。 |
| Appears In | IA-010 |
| Linked Specs | REQ-004, UF-002, WF-T-001 |
| Tokens | `vt.bg.aura.today`, `vt.glass.g1.clearCard`, `vt.color.action.cyan`, `vt.type.energyNumber` |
| Content Slots | 宽口 Energy Bowl 图形、单层高对比放大数字、数字下方状态词与同排 `查看数据`、碗下三阶段反向周期圆弧。 |
| 状态 | richData、lowData、uncertain、calibrated、firstOpen |
| Interactions | 点击能量碗进入状态详情；点击 `查看数据` 进入今日分析/身体要素合并模块；long-press askable menu。 |
| Acceptance | 能量碗图形与数字/查看数据/状态文案必须分层不重叠；`今日能量偏低` 位于 `68%` 下方，`查看数据` 位于状态词右侧同一行；数字不能使用双层虚影或点阵偏移；水滴从屏幕顶部进入碗口，水位按能量显示浅水/半碗/接近满碗，Reduce Motion 下静态水位可读；首页数据小标签只进入今日分析，不在能量碗或建议卡出现；周期线轴必须下移到碗外下方，和碗底保持约一个中文字高度，形成中间下沉的三阶段圆弧，文字全部在下端；首页不出现实时预测图、三模式切换或校准 chips；不出现独立记录区。 |
| Do Not | 不做顶部下拉 Energy Ball；不做复杂 dashboard。 |

### C-TODAY-008 · EnergyBowlAndAnalysisPrediction

| 字段 | 规格 |
| --- | --- |
| Purpose | 首页展示分层综合能量碗与数据入口；今日分析展示完整综合实时预测。 |
| Appears In | IA-010, IA-011 |
| Linked Specs | REQ-005, UF-003, UF-007, WF-T-002, WF-R-001 |
| Tokens | `vt.glass.g1.clearCard`, `vt.color.action.cyan`, `vt.type.energyNumber`, `vt.motion.tap` |
| 状态 | richData、lowData、uncertain、reviewComparison |
| Interactions | 点击能量碗；点击 `查看数据`；在今日分析查看当前时间气泡。 |
| Acceptance | 不冒充刷新；不使用顶部下拉 Energy Ball；首页固定综合能量，不显示睡眠/周期模式切换、实时预测图、数据小标签或校准 chips；首页周期只显示前一阶段/当前阶段/下一阶段三点圆弧，当前 D18 为 `排卵期 / 黄体期 D18 / 月经期`；实时预测移入今日分析，包含数据小标签、高/中/低纵轴、小时点位、当前时间气泡和综合能量解释；`查看数据` 打开综合实时预测 + 横向身体要素 + 综合判断。 |
| Do Not | 不把 Energy Ball 做成下拉头部；不长动画阻塞用户；不展示未接入数据源的血糖判断。 |

### C-TODAY-007 · VitoraDailySuggestionCard

| 字段 | 规格 |
| --- | --- |
| Purpose | 用大字号身体翻译解释今天状态，承接睡眠种子状态，并给出可轮换的两条组合建议。 |
| Appears In | IA-010, IA-015 |
| Linked Specs | REQ-007, UF-004, WF-T-006 |
| Tokens | `vt.glass.g2.panel`, `vt.color.action.blue`, `vt.shadow.glass.low` |
| 状态 | fresh、accepted、changed、notSuitable、reminderSet、reviewPending、seed、halfOpen、bloom、dormant |
| Interactions | `我试试` 进入现有今日分析/提醒路径并可推动睡眠种子继续打开；icon `换一换` 在 `吃+休息 / 运动+吃 / 休息+运动` 三组间循环；卡片/长按仍可解释或校准。 |
| Acceptance | 标题后必须有大字号身体翻译和依据文案；睡眠种子只作为建议反馈证据显示 `状态 / 原因 / 今天怎么帮它`；每组显示两条行动建议，行尾为 `checkmark.circle.fill`；首屏不出现 `为什么` 按钮；形成当日意图并连接晚间复盘；不制造任务失败。 |
| Do Not | 不叫“小尝试”弱化 AI 个性化；不只 toast。 |

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
| Interactions | type、send、voice record、keyboard avoidance；外部 `AI管家` Tab 可触发聚焦。 |
| Acceptance | 顺序固定为语音/键盘、输入或内联语音条、发送；右侧发送固定且空态/可发送态清楚；只在 AI 管家页展开；点击 Today/Cycle/记录不自动聚焦；AI 不可用时输入保留并可手动保存。 |
| Do Not | 不做只有 placeholder 的空聊天；不隐藏发送路径；不在输入区混入 `+`、周期小花、记录键或 Tab 切换按钮。 |

### C-VITORA-010 · VitoraContextualSheet

| 字段 | 规格 |
| --- | --- |
| Purpose | 从 Today / Cycle 对象轻量唤醒 Vitora，不打断原任务。 |
| Appears In | IA-021 |
| Linked Specs | REQ-008, UF-005, WF-V-005 |
| Tokens | `vt.glass.g3.sheet`, `vt.bg.overlay.dim`, `vt.motion.sheet.spring` |
| 状态 | presented、sourceContext、typing、voice、understanding、confirming、saved、dismissed |
| Interactions | close、swipe up full、quick chip、type、voice、confirm；可由右侧圆形 `+` 以 `快捷记录` 来源打开。 |
| Acceptance | 顶部为稳定结构：左侧关闭、居中标题、下方来源摘要；底部固定本地输入条；打开时全局 Dock 隐藏；关闭回来源；保存后更新来源对象；快捷记录不切换到 Vitora Tab、不改写全局输入草稿。 |
| Do Not | 不直接切到 Vitora tab；不未经确认保存。 |

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
| Purpose | 总结“这 30 天，Vitora 看见的三件事”。 |
| Appears In | IA-030 |
| Linked Specs | REQ-012, UF-008, WF-C-001 |
| Tokens | `vt.glass.g2.panel`, `vt.color.action.blue`, `vt.color.phase.*` |
| 状态 | week、monthTrend、cycle |
| Interactions | 卡片式切换 `本周 / 趋势（月） / 周期`；卡片可长按问 Vitora。 |
| Acceptance | 默认本周展示低谷窗口、恢复较好时段、影响因素和待校准天数；选中页签为白色霜状玻璃 + 青色短线；不制造任务完成或失败感。 |
| Do Not | 不显示完成率、连续天数、红点或打卡。 |

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
| Purpose | 低成本展示本周期哪些建议真的对用户有用。 |
| Appears In | IA-030 |
| Linked Specs | REQ-012, UF-008, WF-C-001 |
| Tokens | `vt.glass.g2.panel`, `vt.color.action.blue`, `vt.shadow.glass.low` |
| 状态 | bloom、halfOpen、dormant |
| Interactions | 点击花卡可问 Vitora 或查看对应建议反馈；P0 可先静态展示最近 7-10 张。 |
| Acceptance | 标题为 `本周期花架证据`；只展示“建议 → 反馈”的学习结果；不显示成长册进度、完成率、连续天数、金币、商店或花田地图。 |
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
