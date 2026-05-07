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
| C-TODAY-008 | EnergyRevealHeader | Feature | P0 | REQ-005 |
| C-TODAY-009 | TodayCalendarSheet | Feature | P0 | REQ-013 |
| C-TODAY-010 | TodayStateDetailSheet | Feature | P0 | REQ-004 |
| C-TODAY-011 | BodyFactorsDetailSheet | Feature | P0 | REQ-006 |
| C-TODAY-012 | SuggestionDetailSheet | Feature | P0 | REQ-007 |

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

### 2.4 Cycle

| ID | 名称 | 层级 | 优先级 | 主要规格 |
| --- | --- | --- | --- | --- |
| C-CYCLE-001 | CycleSettingsEntry | Composite | P0 | REQ-014 |
| C-CYCLE-002 | CurrentPhaseRelationCard | Feature | P0 | REQ-012 |
| C-CYCLE-003 | PhaseAxis | Composite | P0 | REQ-012 |
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
| 状态 | todaySelected、vitoraSelected、cycleSelected、inputDockAvoidance、sheetPresented |
| Interactions | tap 切换；sheet 打开时保持或弱化；Vitora 输入聚焦时不得遮挡。 |
| Acceptance | 只有 3 个 tab；中央 face 低凸起；Vitora 页面输入 dock 优先。 |
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
| Content Slots | 数字、状态词、关键窗口、节律曲线、校准问题、动态 chips。 |
| 状态 | richData、lowData、uncertain、calibrated、firstOpen |
| Interactions | tap 状态详情；long-press askable menu；chip 打开 Vitora contextual sheet。 |
| Acceptance | 数字不能单独出现；必须有状态词和关键窗口；不出现独立记录区。 |
| Do Not | 不做常驻大 Energy Ball；不做复杂 dashboard。 |

### C-TODAY-008 · EnergyRevealHeader

| 字段 | 规格 |
| --- | --- |
| Purpose | 保留 Energy Ball 的仪式感和复盘对比价值。 |
| Appears In | IA-011, IA-024 |
| Linked Specs | REQ-005, UF-003, UF-007, WF-T-002, WF-R-001 |
| Tokens | `vt.motion.energyReveal`, `vt.glass.g2.panel`, `vt.glow.pixel.active` |
| 状态 | hidden、pulling、halfExpanded、fullRitual、reviewComparison |
| Interactions | top pull reveal、threshold settle、swipe up dismiss、close。 |
| Acceptance | 默认隐藏；不冒充刷新；复盘可显示前后对比。 |
| Do Not | 不压住 Today 首屏；不长动画阻塞用户。 |

### C-TODAY-007 · VitoraDailySuggestionCard

| 字段 | 规格 |
| --- | --- |
| Purpose | 给出基于状态和身体要素的低负担今日建议。 |
| Appears In | IA-010, IA-015 |
| Linked Specs | REQ-007, UF-004, WF-T-006 |
| Tokens | `vt.glass.g2.panel`, `vt.color.action.blue`, `vt.shadow.glass.low` |
| 状态 | fresh、accepted、changed、notSuitable、reminderSet、reviewPending |
| Interactions | 我试试、换一个、详情、不适合、提醒偏好。 |
| Acceptance | 形成当日意图并连接晚间复盘；不制造任务失败。 |
| Do Not | 不叫“小尝试”弱化 AI 个性化；不只 toast。 |

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
| Acceptance | 像素球状体；眼睛必须 pixel；压缩态仍在左上可见。 |
| Do Not | 不用 smooth orb、人类头像、宠物或普通 icon。 |

### C-VITORA-007 · VitoraInputDock

| 字段 | 规格 |
| --- | --- |
| Purpose | 统一所有 Vitora 输入：文字、语音、快捷上下文、发送。 |
| Appears In | IA-020, IA-021, IA-022, IA-023 |
| Linked Specs | REQ-010, REQ-011, UF-005, UF-006 |
| Tokens | `vt.glass.g3.sheet`, `vt.layout.inputDock.height`, `vt.layout.tab.lowLift` |
| 状态 | empty、typing、sendEnabled、voiceReady、recording、transcribed、aiUnavailable |
| Interactions | type、send、voice record、quick context select、keyboard avoidance。 |
| Acceptance | 不被中央 tab 遮挡；AI 不可用时输入保留并可手动保存。 |
| Do Not | 不做只有 placeholder 的空聊天；不隐藏发送路径。 |

### C-VITORA-010 · VitoraContextualSheet

| 字段 | 规格 |
| --- | --- |
| Purpose | 从 Today / Cycle 对象轻量唤醒 Vitora，不打断原任务。 |
| Appears In | IA-021 |
| Linked Specs | REQ-008, UF-005, WF-V-005 |
| Tokens | `vt.glass.g3.sheet`, `vt.bg.overlay.dim`, `vt.motion.sheet.spring` |
| 状态 | presented、sourceContext、typing、voice、understanding、confirming、saved、dismissed |
| Interactions | close、swipe up full、quick chip、type、voice、confirm。 |
| Acceptance | 顶部显示来源；关闭回来源；保存后更新来源对象。 |
| Do Not | 不直接切到 Vitora tab；不未经确认保存。 |

## 6. Cycle Components

### C-CYCLE-002 · CurrentPhaseRelationCard

| 字段 | 规格 |
| --- | --- |
| Purpose | 解释当前周期阶段与 Today 的关系。 |
| Appears In | IA-030, IA-031 |
| Linked Specs | REQ-012, UF-008, WF-C-001, WF-C-002 |
| Tokens | `vt.glass.g1.clearCard`, `vt.color.phase.*`, `vt.ip.size.decor` |
| 状态 | richData、phaseUncertain、lowConfidence、lowData |
| Interactions | tap 阶段详情；long-press askable menu；二层校准。 |
| Acceptance | 显示阶段、置信度/估算感、Today 意义；不展示日历首页。 |
| Do Not | 不做周期科普墙；不做商业化入口。 |

### C-CYCLE-004 · EnergyDynamicsCard

| 字段 | 规格 |
| --- | --- |
| Purpose | 让用户查看日/周/月能量动态和 Vitora 叙事摘要。 |
| Appears In | IA-030, IA-032 |
| Linked Specs | REQ-012, UF-009, WF-C-001, WF-C-003 |
| Tokens | `vt.glass.g1.clearCard`, `vt.color.action.cyan`, `vt.motion.tap` |
| 状态 | daily、weekly、monthly、selectedPoint、lowData、layerToggled |
| Interactions | segmented control、tap detail、chart point callout、long-press context menu。 |
| Acceptance | 首页只预览；二层可探索趋势和关键点；Vitora 叙事说明为什么。 |
| Do Not | 不重复 Today 当前状态；不堆高级健康图表。 |

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
| `TodayStateOrb` as homepage hero | deprecated | `EnergyRevealHeader` + `TodayStatusCard` |
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
