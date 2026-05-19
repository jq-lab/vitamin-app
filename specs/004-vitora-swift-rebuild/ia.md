# Vitora Swift Rebuild · Information Architecture

> Spec set: `004-vitora-swift-rebuild`
> Batch: IA · Pivot Adapted
> 日期：2026-05-05
> 状态：当前生效

本文档是 Swift rebuild 的信息架构权威。它定义 P0 导航模型、屏幕清单、入口规则、状态路由和延期路由，不定义 Swift 架构、数据库、API 或具体视觉尺寸。

## 0. Authority Rules

| Rule ID | Rule | Constraint | Source |
| --- | --- | --- | --- |
| IAA-001 | `facts.md` 是最高事实来源。 | 冲突时先更新 facts。 | F-SOURCE-001 |
| IAA-002 | `userflows.md` 是流程来源。 | 每个 P0 入口必须服务至少一个 P0 flow。 | UFA-001 |
| IAA-003 | `wireframes-walkthrough-demo.md` 是本轮 IA pivot evidence。 | 本文件吸收其核心决定。 | F-SOURCE-005 |
| IAA-004 | `design-language-demo.md` 是视觉材质和组件气质 evidence。 | 与材质、IP、Tab、sheet 相关 IA 必须服从。 | F-SOURCE-006 |
| IAA-005 | 当前 app 只作 evidence / anti-evidence。 | 不复制旧宽抽屉、旧记录跳转、旧沉浸态或旧 Cycle 日历首页。 | F-SOURCE-003 |

## 1. Navigation Model

P0 使用四类导航/呈现：

| Model | 作用 | 规则 |
| --- | --- | --- |
| Primary Tab | 三主区：Today / Vitora / Cycle。 | 不增加第 4 个 Tab。 |
| Contextual Sheet | 非 CTA 唤醒 Vitora、建议详情、状态详情、支撑编辑。 | 3/4 或 full-height sheet 保留来源上下文。 |
| Detail Screen / Sheet | Today 周期日历、状态详情、今日分析/身体要素、Cycle 阶段/能量二层。 | 单击主路径进入；长按只是快捷路径。 |
| Support / Settings | 个人资料、数据来源、营养、提醒、导出、隐私法律与账号移除。 | 从 Cycle 右上 profile/settings 或 Vitora 支撑入口进入。 |

### 1.1 Primary Tabs

| 主区 | 逻辑路由 | 职责 | P0 规则 | 关联事实 |
| --- | --- | --- | --- | --- |
| Today | `/today` | 今日状态、身体要素、Vitora 今日建议。 | 默认启动主区；不放独立记录区；日历从顶部进入。 | F-P0-TODAY-001, F-P0-TODAY-002 |
| Vitora | `/vitora` | 全局 AI assistant surface。 | 中央 Pixel Vitora face CTA；不是空聊天页，不是普通 dashboard。 | F-P0-VITORA-001 |
| Cycle | `/cycle` | 长期节律背景和能量动态。 | 首页只放阶段关系卡和能量动态卡；设置从右上进入。 | F-P0-CYCLE-001 |

### 1.2 Global Vitora Wake Rules

| Source | Wake Behavior | Source Context |
| --- | --- | --- |
| Today 状态卡 | 打开 3/4 Vitora sheet。 | 当前状态、低谷窗口、曲线摘要。 |
| Today 身体要素 | 打开 3/4 Vitora sheet。 | 被点击指标、数值、趋势、对今天意义。 |
| Today 建议卡 | 打开建议详情或 Vitora sheet。 | 今日建议、原因、提醒偏好。 |
| Today 周期日历 | 打开 Vitora sheet。 | 选中日期、周期阶段、预测窗口。 |
| Cycle 阶段卡 | 长按 menu 或二层 `⋯` 打开 Vitora sheet。 | 周期阶段、置信度、对 Today 意义。 |
| Cycle 能量动态 | 点选 callout 或长按打开 Vitora sheet。 | 粒度、点位、趋势摘要。 |
| Vitora Tab | 打开完整 assistant surface。 | 当前全局上下文。 |

规则：

| Rule ID | Rule |
| --- | --- |
| IAW-001 | 非 CTA 唤醒不直接切 Tab。 |
| IAW-002 | 3/4 sheet 上滑后可升级完整 Vitora。 |
| IAW-003 | Sheet 关闭后返回来源组件，并保留已输入草稿或明确取消。 |
| IAW-004 | Vitora 理解必须先确认，再保存。 |

## 2. Screen Inventory

| 屏幕 ID | 逻辑路由 | 屏幕 / 状态 | 呈现方式 | 父级 | 优先级 | 关联流程 | 关联事实 | 决策 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| IA-000 | `/` | App Gate | State gate | App root | P0 | UF-001, UF-002 | F-P0-ONBOARDING-001 | keep |
| IA-001 | `/onboarding/start` | 最小身份 | Screen | Onboarding | P0 | UF-001 | F-P0-ONBOARDING-001 | keep |
| IA-002 | `/onboarding/context` | 周期上下文、关注点、HealthKit 选择 | Screen | Onboarding | P0 | UF-001 | F-P0-DATA-001, F-P0-DATA-002 | keep |
| IA-003 | `/onboarding/ready` | 本地准备和学习循环说明 | Screen | Onboarding | P0 | UF-001 | F-P0-NAV-001 | keep |
| IA-010 | `/today` | Today 首页 | Main tab | Primary nav | P0 | UF-002 | F-P0-TODAY-001 | redesign |
| IA-011 | `/today/energy-bowl` | Energy Bowl / 实时预测 / 查看数据 | Inline status interaction | Today | P0 | UF-003 | F-P0-ORB-001 | redesign |
| IA-012 | `/today/calendar` | 周期日历 | Detail sheet/screen | Today | P0 | UF-002, UF-009 | F-P0-TODAY-002 | moved from Cycle |
| IA-013 | `/today/state-detail` | 今日状态详情 | Full-height sheet | Today | P0 | UF-002, UF-005 | F-P0-TODAY-001 | new |
| IA-014 | `/today/body-factors` | 今日分析 / 身体要素 | Full-height sheet | Today | P0 | UF-002, UF-005 | F-P0-TODAY-001 | new |
| IA-015 | `/today/suggestion` | Vitora 今日建议详情 | Full-height sheet | Today | P0 | UF-004 | F-P0-AB-001 | redesign |
| IA-016 | `/today/low-data` | 低数据状态 | Inline state | Today | P0 | UF-002 | F-P0-DATA-002 | keep |
| IA-017 | `/today/suggestion/sleep-seed` | 睡眠种子状态块 | Inline block | Today suggestion | P0 | UF-004, UF-007 | F-P0-REVIEW-001, F-P0-ORB-001 | new |
| IA-020 | `/vitora` | Vitora Assistant Surface | Main tab | Primary nav | P0 | UF-006 | F-P0-VITORA-001 | renamed/redesign |
| IA-021 | `/vitora/context-sheet` | 3/4 Contextual Vitora Sheet | Contextual sheet | Any source | P0 | UF-005 | F-P0-VITORA-002 | new |
| IA-022 | `/vitora/full-context` | Full Vitora Context Mode | Full screen / tab surface | Vitora | P0 | UF-006 | F-P0-VITORA-001 | replaces old immersive chat |
| IA-023 | `/vitora/record-confirm` | Vitora 理解确认 | Sheet/card | Vitora | P0 | UF-005, UF-006 | F-P0-RECORD-001 | redesign |
| IA-024 | `/vitora/review` | 最小晚间复盘 | Sheet/card | Vitora / Today | P0 | UF-007 | F-P0-REVIEW-001 | redesign |
| IA-030 | `/cycle` | Cycle 首页 | Main tab | Primary nav | P0 | UF-008 | F-P0-CYCLE-001 | redesign |
| IA-031 | `/cycle/phase-detail` | 当前周期阶段详情 | Full-height sheet | Cycle | P0 | UF-009 | F-P0-CYCLE-002 | new |
| IA-032 | `/cycle/energy-dynamics` | 能量动态详情 | Full-height sheet | Cycle | P0 | UF-009 | F-P0-CYCLE-002 | new |
| IA-033 | `/cycle/low-data` | Cycle 低数据状态 | Inline state | Cycle | P0 | UF-008 | F-P0-DATA-002 | redesign |
| IA-040 | `/support` | 支撑 / 我的 | Sheet or screen | Cycle/Vitora | P0 | UF-010 | F-P0-SUPPORT-001 | redesign |
| IA-041 | `/support/profile` | 个人资料 | Support child | Support | P0 | UF-010 | F-P0-SUPPORT-001 | keep |
| IA-042 | `/support/data-sources` | HealthKit 与数据来源 | Support child | Support | P0 | UF-001, UF-010 | F-P0-DATA-001 | keep |
| IA-043 | `/support/nutrition` | 营养补给管理 | Support child | Support | P0 | UF-010 | F-P0-SUPPLEMENT-001 | keep |
| IA-044 | `/support/reminders` | A/B 与复盘提醒偏好 | Support child | Support | P0 | UF-004, UF-007 | F-P0-AB-001 | keep |
| IA-045 | `/support/data-export` | 数据导出 | Support child | Support | P0 | UF-010 | F-PRIVACY-005 | keep |
| IA-046 | `/support/legal-account` | 隐私法律与账号移除 | Support child | Support | P0 | UF-010 | F-PRIVACY-005 | keep |

## 3. Area IA

### 3.1 Today IA

```text
Today
├── Top Context
│   ├── Calendar icon -> IA-012
│   ├── Cycle phase/date
│   └── Pixel Vitora decoration
├── Current Status Card -> IA-013
│   ├── Energy Bowl -> IA-013
│   ├── evidence button -> IA-014
│   ├── realtime prediction -> IA-011
│   ├── metric mode rail
│   └── calibration chips -> IA-021
├── Body Factors -> IA-014
├── Vitora Daily Suggestion -> IA-015
└── Bottom Tabs
```

Rules:

| Rule ID | Rule |
| --- | --- |
| IAT-001 | Today 不放独立 `+记录` section。 |
| IAT-002 | 状态卡和 Energy Bowl 是首页主视觉；Today 首屏不使用顶部下拉 Energy Ball。 |
| IAT-003 | 日历从 Today 顶部进入，不进入 Cycle 首页。 |
| IAT-004 | 任何校准都进入 Vitora contextual sheet，而不是切到 Vitora Tab。 |

### 3.2 Vitora IA

```text
Vitora Tab
├── Pixel Vitora hero / compressed IP
├── Vitora Knows context block
├── Date/context strip
├── Conversation area
│   ├── assistant message
│   ├── direct question strips
│   ├── rich response card
│   └── record confirmation
├── Quick context chips
├── Input dock
└── Bottom tabs with low-lift Vitora face
```

Rules:

| Rule ID | Rule |
| --- | --- |
| IAV-001 | Vitora Tab 默认打开 assistant surface，不打开空白聊天。 |
| IAV-002 | Conversation 是主线，功能入口不铺成 dashboard。 |
| IAV-003 | Quick context chips 贴近 input dock，不作为页面主导航。 |
| IAV-004 | 输入区优先于底部 CTA，CTA 只低凸起。 |
| IAV-005 | 旧“上滑沉浸聊天”被替换为：3/4 contextual sheet 上滑升级 + Vitora surface 滚动压缩态。 |

### 3.3 Cycle IA

```text
Cycle
├── Header
│   ├── title
│   └── profile/settings -> IA-040
├── Current Phase Relation Card -> IA-031
├── Energy Dynamics Card -> IA-032
├── TipKit hint
└── Bottom Tabs
```

Rules:

| Rule ID | Rule |
| --- | --- |
| IAC-001 | Cycle 首页不放周期日历。 |
| IAC-002 | 阶段卡解释“当前周期阶段与今天”。 |
| IAC-003 | 能量动态卡解释长期趋势，不重复 Today 今日状态。 |
| IAC-004 | 长按卡片打开 context menu，单击进入二层。 |

### 3.4 Support IA

Support 不是主 Tab，不是宽抽屉，不是未来功能墙。

| Visible Item | Route | Entry |
| --- | --- | --- |
| 个人资料 | IA-041 | Cycle 右上 / Vitora support |
| HealthKit 与数据来源 | IA-042 | 低数据提示 / Support |
| 营养补给 | IA-043 | Support 管理 / Vitora 快捷新增 |
| 提醒偏好 | IA-044 | 建议详情 / Support |
| 数据导出 | IA-045 | Support |
| 隐私法律与账号移除 | IA-046 | Support |

## 4. State-based Navigation

| State ID | Trigger | Available Navigation | Hidden / Restricted |
| --- | --- | --- | --- |
| IAS-001 | No onboarding completion | Onboarding only, then Today. | Main tabs hidden until onboarding exits. |
| IAS-002 | Onboarding complete | Today / Vitora / Cycle. | WeChat gate absent. |
| IAS-003 | First open today | Energy Ball half/full state, then Today. | No drawer during ritual. |
| IAS-004 | HealthKit skipped/denied | Today low-data, Vitora contextual input, support data sources. | HealthKit cannot block app. |
| IAS-005 | Suggestion accepted | Intention saved, reminder optional, review later. | No task list or completion debt. |
| IAS-006 | User long-presses askable object | Context menu, then Vitora sheet. | Long-press is not only path. |
| IAS-007 | User selects chart point | Callout, optional ask Vitora. | Callout does not replace detail page. |
| IAS-008 | Evening review available | Vitora review, Today suggestion state, optional notification. | No fourth tab. |
| IAS-009 | Support needed | Support sheet/screen six items. | No broad drawer route pool. |

## 5. Hidden / Deferred Route Table

| Candidate Route / Surface | P0 Visibility | Reason |
| --- | --- | --- |
| Assistant growth / streak / level | Hidden | Creates progress pressure. |
| Subscription / VIP | Hidden | P0 proves core value first. |
| Widgets / IoT / multi-device deep | Hidden | Native extensions and hardware depth are after MVP. |
| Search/explore history | Hidden | Needs mature record history. |
| Cycle calendar homepage | Hidden | Calendar belongs to Today top entry. |
| Cycle advanced analysis / commercial surface | Hidden | P0 Cycle is phase relation + energy dynamics. |
| Today standalone record section | Hidden | Recording is contextual Vitora calibration. |
| Apple Health dashboard screens | Hidden | 违反视觉方向。 |
| Local Gemma controls | Hidden | Future direction, no P0 visible controls. |

## 6. Cross-flow Map

| Userflow | Required IA Entries |
| --- | --- |
| UF-000 | IA-010, IA-015, IA-021, IA-024 |
| UF-001 | IA-000, IA-001, IA-002, IA-003, IA-042 |
| UF-002 | IA-010, IA-012, IA-013, IA-014, IA-015, IA-016 |
| UF-003 | IA-011 |
| UF-004 | IA-015, IA-044, IA-024 |
| UF-005 | IA-021, IA-023 |
| UF-006 | IA-020, IA-022, IA-023 |
| UF-007 | IA-024 |
| UF-008 | IA-030, IA-031, IA-032, IA-033 |
| UF-009 | IA-031, IA-032, IA-021 |
| UF-010 | IA-040 to IA-046 |

## 7. IA 质量门禁

| 门禁 | 要求 |
| --- | --- |
| 主导航 | 只能是 Today / Vitora / Cycle。 |
| 命名 | 用户面对 assistant 统一为 Vitora。 |
| Today | 无独立记录区；Energy Ball 是隐藏仪式层；日历从顶部进入。 |
| Vitora | 默认是有上下文、对话、chips 和输入 dock 的 assistant surface。 |
| Cycle | 阶段关系 + 能量动态；不做日历首页。 |
| 可询问对象 | 单击详情、长按 context menu、图表点 callout。 |
| 支撑区 | 只显示六类 P0 支撑项；无未来占位路由。 |
| 视觉 | 必须服从 Aura Glass Pixel Companion。 |

## 8. 使用规则

后续 `spec.md`、`wireframes.md`、`components.md`、`tasks.md` 不得新增本文未列出的 P0 可见主路由。若实现需要保留旧代码路径或 accessibility identifier，必须在 tasks 中标记为 migration debt，不能让用户面对旧命名或旧 IA。
