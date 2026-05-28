# Vitora Swift Rebuild · 产品规格

> 规格集：`004-vitora-swift-rebuild`
> 批次：核心产品规格 · IA / Design Pivot Adapted
> 日期：2026-05-05
> 状态：当前生效

本文档是 Swift rebuild 的 P0 产品规格。它定义产品行为、用户价值、状态和验收标准；不定义 Swift 架构、数据库结构、API endpoint、视觉尺寸或具体任务。

英文旧保留版 `spec_en.md` 已不再作为当前产品事实来源。后续默认引用本文档。

## 0. 权威规则

| 规则 ID | 规则 | 约束 | 来源 |
| --- | --- | --- | --- |
| SPA-001 | `facts.md` 是最高事实来源。 | 冲突时先更新 facts。 | F-SOURCE-001 |
| SPA-002 | `userflows.md` 是用户路径来源。 | 每条 P0 需求必须映射至少一个 P0 flow。 | UFA-001 |
| SPA-003 | `ia.md` 是导航和屏幕来源。 | 不能新增 IA 之外的 P0 可见路由。 | IAA-001 |
| SPA-004 | `wireframes-walkthrough-demo.md` 和 `design-language-demo.md` 已被吸收为 pivot evidence。 | 本文不再服从旧 Luna / 旧 Cycle / 旧 dashboard 方向。 | F-SOURCE-005, F-SOURCE-006 |
| SPA-005 | 当前 app 是 evidence / anti-evidence。 | 当前 UI、宽抽屉、旧记录跳转、旧沉浸聊天不作为复刻目标。 | F-SOURCE-003 |

## 1. 产品定义

Vitora 是一个私密的 iOS 身体节律陪伴应用。它帮助用户回答：

> “我今天怎么样，以及我可以轻轻试什么？”

Vitora 同时是 app 名和用户面对的 AI assistant 名。Vitora 是全局 Assistant Layer：它解释、记录、建议、复盘、学习，并可以在 Today、Cycle 和 Vitora Tab 中根据来源上下文被唤醒。

P0 Swift MVP 要证明一个闭环：

1. Today 给出现在状态、身体要素和 Vitora 今日建议。
2. 用户不需要打卡，只在 Vitora 缺少事实时告诉它一件重要变化。
3. Vitora 先理解确认，再保存事实并更新判断或建议。
4. 用户接受或调整今日建议，形成当日意图。
5. 晚间复盘对比当天 app 介入前后效果，并可选择一颗睡眠种子作为明早验证方向。
6. Today / Vitora / Cycle 用睡眠种子把“建议是否真的帮到你”可视化成低成本反馈证据。
7. Cycle 提供长期节律背景、能量动态和花架证据，不重复 Today。

## 2. P0 成功标准

| 成功标准 ID | 标准 | 覆盖 |
| --- | --- | --- |
| S-P0-001 | 用户无需 WeChat、无需 HealthKit 授权即可进入可用 Today。 | REQ-001 to REQ-003 |
| S-P0-002 | Today 3 秒内回答状态、依据和下一步。 | REQ-004 |
| S-P0-003 | Energy Bowl 在 Today 首屏承载综合状态和查看数据入口；完整实时预测进入今日分析，不依赖顶部下拉仪式层。 | REQ-005 |
| S-P0-004 | Vitora 今日建议能形成当日意图、晚间复盘和睡眠种子反馈路径。 | REQ-006, REQ-007 |
| S-P0-005 | Vitora contextual sheet 可从重要对象唤醒，完成理解确认保存。 | REQ-008, REQ-009 |
| S-P0-006 | Vitora Tab 是完整 assistant surface，不是空聊天页。 | REQ-010 |
| S-P0-007 | Cycle 展示周期回顾、花架证据、能量动态和二层探索。 | REQ-012 |
| S-P0-008 | 支撑能力可达且不变成宽设置中心。 | REQ-013 to REQ-015 |
| S-P0-009 | Aura Glass Pixel Companion 视觉系统进入正式规格。 | REQ-016 |

## 3. P0 需求

### REQ-001 · App 入口

| 字段 | 规格 |
| --- | --- |
| 区域 | App / Onboarding |
| 优先级 | P0 Swift MVP |
| 产品行为 | 首次启动进入最小 onboarding；完成后进入 Today；WeChat 不作为进入门槛。 |
| 用户价值 | 用户快速进入价值体验，不被账号摩擦阻断。 |
| 输入 | 本地 onboarding 状态、可选 HealthKit 授权状态、可选本地账户状态。 |
| 输出 | Onboarding route、Today route、低数据状态。 |
| 状态 | firstLaunch、needsOnboarding、readyToday、lowData。 |
| 关联事实 | F-P0-ONBOARDING-001, F-P0-DATA-002 |
| 关联流程 | UF-001, UF-002 |
| 关联 IA | IA-000 to IA-003 |
| 验收标准 | 用户可跳过 HealthKit 进入 Today；无 WeChat gate；回访用户落到 Today。 |
| 不在范围 | WeChat 登录 gate、手机号登录、支付设置。 |

### REQ-002 · 最小 Onboarding 上下文

| 字段 | 规格 |
| --- | --- |
| 区域 | Onboarding |
| 优先级 | P0 Swift MVP |
| 产品行为 | Onboarding 拆成注册进入页 + 聊天式补充页；注册页只选择 Apple / 微信 / QQ / 本地体验并处理协议，不再询问昵称；补充页由 Pixel Vitora 像聊天一样逐项提问，合并关注方向、恢复方式、周期清晰度和可选设备绑定；完成后直接进入 Today。 |
| 用户价值 | Vitora 能个性化第一天，但 onboarding 不像表单墙。 |
| 输入 | 进入方式、关注方向、恢复方式、周期清晰度、HealthKit / 设备绑定选择。 |
| 输出 | 初始 Vitora 上下文、onboarding 完成状态。 |
| 状态 | minimalComplete、optionalSkipped、healthKitConnected、healthKitSkipped。 |
| 关联事实 | F-P0-ONBOARDING-001, F-P0-DATA-001 |
| 关联流程 | UF-001 |
| 关联 IA | IA-001, IA-002, IA-003 |
| 验收标准 | 可跳过非必填项；低数据仍可继续；不要求每日记录承诺。 |
| 不在范围 | 宽设备生态、报告上传、营养补给必填。 |

### REQ-003 · HealthKit 可选 / 低数据

| 字段 | 规格 |
| --- | --- |
| 区域 | Data |
| 优先级 | P0 Swift MVP |
| 产品行为 | HealthKit 是可选增强；拒绝、跳过或撤销后 app 继续可用。 |
| 用户价值 | 无设备、未授权或数据不足的用户仍可使用 Vitora。 |
| 输入 | HealthKit 授权、健康样本、手动记录、onboarding 上下文。 |
| 输出 | 数据可用状态、低数据 Today、数据来源支撑入口。 |
| 状态 | authorized、skipped、denied、revoked、lowData、enoughContext。 |
| 关联事实 | F-P0-DATA-001, F-P0-DATA-002 |
| 关联流程 | UF-001, UF-002, UF-010 |
| 关联 IA | IA-002, IA-016, IA-042 |
| 验收标准 | HealthKit 不阻塞 Today / Vitora / Cycle；低数据说明具体、非责备。 |
| 不在范围 | 深度设备排障、第三方设备 SDK。 |

### REQ-004 · Today 首页

| 字段 | 规格 |
| --- | --- |
| 区域 | Today |
| 优先级 | P0 Swift MVP |
| 产品行为 | Today 首页按“现在状态 → 周期线轴 → Vitora 今日建议”组织；身体要素进入 `查看数据 / 今日分析`。 |
| 用户价值 | 用户 3 秒内知道今天状态、为什么、下一步。 |
| 输入 | 今日能量状态、周期上下文、睡眠/HRV/心率、记录、建议状态。 |
| 输出 | 综合状态卡、周期线轴、今日建议、查看数据入口。 |
| 状态 | richData、lowData、uncertain、calibrated、suggestionAvailable。 |
| 关联事实 | F-P0-TODAY-001 |
| 关联流程 | UF-002 |
| 关联 IA | IA-010, IA-013, IA-014, IA-015, IA-016 |
| 验收标准 | 无独立记录区；无 dashboard 堆叠；状态必须有数字+状态词+关键窗口；每个主卡可进入二层。 |
| 不在范围 | 自定义任务卡、今日记录 carousel、连续天数、红点。 |

### REQ-005 · Energy Bowl / 实时预测

| 字段 | 规格 |
| --- | --- |
| 区域 | Today / Energy |
| 优先级 | P0 Swift MVP |
| 产品行为 | Today 首屏直接使用综合 Energy Bowl 作为状态交互；能量碗和 `查看数据` 都进入同一个 `今日分析`；首页碗下显示周期线轴，完整综合实时预测、监测项解释和今日推荐移入今日分析。 |
| 用户价值 | 用户不需要发现下拉手势，也能看到当前状态、周期背景和判断依据；需要完整预测时进入今日分析。 |
| 输入 | 当日状态、睡眠/HRV/心率/周期、低数据状态、当前时间点。 |
| 输出 | 综合能量碗、周期线轴、依据入口、今日分析里的实时预测、当前时间气泡、详情路径。 |
| 状态 | richData、lowData、uncertain、calibrated、reviewComparison。 |
| 关联事实 | F-P0-ORB-001, F-P0-REVIEW-001 |
| 关联流程 | UF-003, UF-007 |
| 关联 IA | IA-011, IA-024 |
| 验收标准 | 首屏无顶部下拉 Energy Ball 提示；水位从 0 动画到按分数映射的目标水位，点击碗或数据入口有短暂增长反馈；首页不显示综合/睡眠/周期模式切换、实时预测图或校准 chips；碗下周期线轴可读，当前周期段颜色和线宽加重；能量数字大号、低像素密集格、按当前周期阶段着色并带柔光；今日分析顶部显示当前周期阶段和天数，用球形纹路报告统一睡眠、HRV、周期监测项、解释、综合实时预测和今日推荐；低数据不夸大确定性；复盘可显示前后对比。 |
| 不在范围 | 顶部下拉能量球、长阻塞动画、刷新控件语义、未接入数据源的血糖状态。 |

### REQ-006 · 身体要素

| 字段 | 规格 |
| --- | --- |
| 区域 | Today |
| 优先级 | P0 Swift MVP |
| 产品行为 | 身体要素用睡眠、HRV、心率、周期四项解释今日状态。 |
| 用户价值 | 用户知道 Vitora 为什么这样判断。 |
| 输入 | 指标数值、趋势、周期上下文、数据来源状态。 |
| 输出 | 四个 factor tiles、二层详情、管理数据来源入口。 |
| 状态 | fullData、partialData、missingMetric、lowConfidence。 |
| 关联事实 | F-P0-TODAY-001 |
| 关联流程 | UF-002, UF-005 |
| 关联 IA | IA-014 |
| 验收标准 | 每项有数值/趋势/对今天意义；可问 Vitora；不能堆复杂图。 |
| 不在范围 | 高级健康图表、诊断解释。 |

### REQ-007 · Vitora 今日建议 / 当日意图

| 字段 | 规格 |
| --- | --- |
| 区域 | Today / Suggestion |
| 优先级 | P0 Swift MVP |
| 产品行为 | Vitora 今日建议提供一个低负担行动，可形成当日意图、连接晚间复盘；首页智能监测以扑克牌式内嵌卡展示今日推送和周期建议，花朵进度只在提醒 Sheet 等二层反馈处出现。 |
| 用户价值 | 用户知道今天可以轻轻试什么，理解身体为什么这样，并能看到建议是否真的有用。 |
| 输入 | 今日状态、身体要素、周期上下文、用户记录、提醒偏好。 |
| 输出 | 智能监测卡、今日推送、周期建议、详情、换一换、一键提醒、提醒偏好、二层花园进度条、复盘引用。 |
| 状态 | fresh、accepted、changed、notSuitable、reminderSet、reviewPending、seed、halfOpen、bloom、dormant。 |
| 关联事实 | F-P0-AB-001, F-P0-REVIEW-001 |
| 关联流程 | UF-004, UF-007 |
| 关联 IA | IA-015, IA-024, IA-044 |
| 验收标准 | `换一换` 可调整今日推送和周期建议；`一键提醒` 打开提醒设置并保留二层花园进度；晚间复盘能引用；Today 首页智能监测卡显示 `身体翻译器`、`今日推送` 和 `周期建议`，不显示首页花朵进度、完整花园实景或任务完成压力。 |
| 不在范围 | 任务完成率、打卡、VIP 学习记忆。 |

### REQ-008 · 上下文告诉 Vitora

| 字段 | 规格 |
| --- | --- |
| 区域 | Global Vitora |
| 优先级 | P0 Swift MVP |
| 产品行为 | 从 Today/Cycle 重要对象唤醒 Vitora 时，先打开 3/4 contextual sheet，带来源上下文。 |
| 用户价值 | 用户不用离开当前任务，也能让 Vitora 解释或校准。 |
| 输入 | 来源对象、上下文摘要、快捷补充、文本/语音输入。 |
| 输出 | Vitora 理解确认、保存事实、更新来源判断。 |
| 状态 | sheetPresented、typing、voiceReady、understanding、confirming、saved、dismissed。 |
| 关联事实 | F-P0-VITORA-002, F-P0-RECORD-001 |
| 关联流程 | UF-005 |
| 关联 IA | IA-021, IA-023 |
| 验收标准 | 来源清晰；关闭回来源；上滑可升级；AI 结果可确认/修改/不用更新。 |
| 不在范围 | 直接切 Tab、到处放常驻“问 Vitora”按钮、未经确认保存。 |

### REQ-009 · 可询问界面对象

| 字段 | 规格 |
| --- | --- |
| 区域 | Global Interaction |
| 优先级 | P0 Swift MVP |
| 产品行为 | 首页和二层重要对象支持单击详情、长按 context menu、图表点 callout。 |
| 用户价值 | UI 干净，同时 Vitora 可随处被自然唤醒。 |
| 输入 | 卡片、图表点、阶段轴、指标 tile、建议卡。 |
| 输出 | 详情页、context menu、callout、Vitora sheet。 |
| 状态 | normal、pressed、contextMenu、callout、sheetLaunched。 |
| 关联事实 | F-P0-VITORA-002 |
| 关联流程 | UF-005, UF-009 |
| 关联 IA | IA-013, IA-014, IA-015, IA-031, IA-032 |
| 验收标准 | 单击永远是主路径；长按不是唯一入口；TipKit 一次性教学；二层有 `⋯` fallback。 |
| 不在范围 | 首页常驻大量问 Vitora 按钮、callout 替代详情页。 |

### REQ-010 · Vitora Assistant Surface

| 字段 | 规格 |
| --- | --- |
| 区域 | Vitora Tab |
| 优先级 | P0 Swift MVP |
| 产品行为 | Vitora Tab 默认显示 AI-native assistant surface：Pixel Vitora、Vitora 知道、对话、直接问、快捷上下文、晚间复盘卡、真实花种/睡眠种子解释、输入 dock。 |
| 用户价值 | 用户打开 Vitora 就知道它知道什么、能问什么、能补充什么，以及为什么某颗种子处在当前状态。 |
| 输入 | Today 状态、周期上下文、近期记录、建议、睡眠种子、复盘可用性、用户输入。 |
| 输出 | assistant surface、conversation、quick context chips、晚间复盘入口、睡眠种子解释、input dock、rich response、record confirmation。 |
| 状态 | default、scrolledCompressed、inputFocused、voiceRecording、contextCard、richResponse、lowData。 |
| 关联事实 | F-P0-VITORA-001, F-P0-VITORA-003 |
| 关联流程 | UF-006 |
| 关联 IA | IA-020, IA-022, IA-023, IA-024 |
| 验收标准 | 不打开空白聊天；直接问是薄玻璃条；chips 在 input 上方；全局 input dock 在 Today / Vitora / Cycle 常驻，Tab 和输入职责分离。 |
| 不在范围 | 旧单一沉浸聊天页、功能宫格、dashboard 卡片堆叠。 |

### REQ-011 · Vitora 记录 / 理解确认

| 字段 | 规格 |
| --- | --- |
| 区域 | Vitora / Record |
| 优先级 | P0 Swift MVP |
| 产品行为 | 用户输入文字或快捷上下文后，Vitora 生成理解确认，用户确认后才保存。 |
| 用户价值 | AI 显得聪明但可控，避免黑盒写入健康事实。 |
| 输入 | 文本、快捷 chip、语音转写、来源上下文。 |
| 输出 | 理解结果、影响范围、更新建议、确认/修改/不用更新。 |
| 状态 | draft、parsing、confirming、saved、edited、cancelled、aiUnavailable。 |
| 关联事实 | F-P0-RECORD-001, F-AI-001 |
| 关联流程 | UF-005, UF-006 |
| 关联 IA | IA-023 |
| 验收标准 | AI 不可用时可手动保存；保存后回来源并更新状态；日志不含原文。 |
| 不在范围 | 未确认直接保存、长表单、医疗判断。 |

### REQ-012 · Cycle 长期概览

| 字段 | 规格 |
| --- | --- |
| 区域 | Cycle |
| 优先级 | P0 Swift MVP |
| 产品行为 | Cycle 首页展示长期节律回顾：顶部为融合“我的/分享”和周历 strip 的大圆角能量复盘日历头卡，折叠态显示大椭圆日期 pill 与内部能量圆环，展开态显示整月能量进度条；下方保留今日/本周能量摘要卡和 `本周 / 趋势对比 / 近期` 报告详情。 |
| 用户价值 | 用户理解长期节律如何影响近期能量，并看到 Vitora 从周期里学到了什么，而不是进入任务或打卡日历。 |
| 输入 | 周期上下文、今日状态、历史能量、睡眠/HRV 摘要、记录事件。 |
| 输出 | 能量复盘日历、今日/本周能量摘要卡、小号 `6.5` 参考 chip、三段报告入口、单张详情报告框、二层详情入口、设置入口、分享入口。 |
| 状态 | richData、lowData、phaseUncertain、daily、weekly、monthly。 |
| 关联事实 | F-P0-CYCLE-001, F-P0-CYCLE-002 |
| 关联流程 | UF-008, UF-009 |
| 关联 IA | IA-030, IA-031, IA-032, IA-033 |
| 验收标准 | 首页有 `cycle.energyCalendar.card`、`cycle.energyMetric.card` 和指标卡下方三段报告入口；点击 chevron 可展开整月能量进度；可长按问 Vitora；不出现成长册进度、打卡、完成率、连续天数、红点或任务清单。 |
| 不在范围 | 任务日历首页、经期管理 dashboard、高级商业化表面、复杂多指标趋势。 |

### REQ-013 · Today 周期日历

| 字段 | 规格 |
| --- | --- |
| 区域 | Today / Calendar |
| 优先级 | P0 Swift MVP |
| 产品行为 | Today 顶部日历进入周期日历，解释今天在周期时间线的位置。 |
| 用户价值 | 用户从 Today 快速理解“今天为什么是这个周期背景”。 |
| 输入 | 日期、周期阶段、预测窗口、已记录事件。 |
| 输出 | 左侧约 3/4 宽文具浮层、周期图例、英文周标题月历、选中日期、浅粉撕边便签、今日洞察/记录摘要、木制记忆箱。 |
| 状态 | todaySelected、dateSelected、predicted、recorded、lowConfidence。 |
| 关联事实 | F-P0-TODAY-002 |
| 关联流程 | UF-002, UF-009 |
| 关联 IA | IA-012 |
| 验收标准 | 从 Today 顶部压缩日期能量卡进入；能返回 Today；不把 Cycle 首页变成日历；浮层顶部无“周期日历”大标题和说明副标题；右侧保留虚化 Today 背景；月历阶段色、便签内容和木制记忆箱符合 D-072。 |
| 不在范围 | 高级周期分析、医疗预测。 |

### REQ-014 · 支撑 / 设置

| 字段 | 规格 |
| --- | --- |
| 区域 | Support |
| 优先级 | P0 Swift MVP |
| 产品行为 | 支撑区只显示 P0 必需项：个人资料、数据来源、营养补给、提醒偏好、数据导出、隐私法律与账号移除。 |
| 用户价值 | 用户能管理信任、数据、提醒和上下文，但不会看到未来功能墙。 |
| 输入 | 当前账户/本地状态、授权状态、营养条目、提醒偏好、导出/移除动作。 |
| 输出 | 支撑列表、子面板、状态反馈。 |
| 状态 | supportHome、childPanel、exportPreparing、removalConfirming、done。 |
| 关联事实 | F-P0-SUPPORT-001, F-P0-SUPPORT-002 |
| 关联流程 | UF-010 |
| 关联 IA | IA-040 to IA-046 |
| 验收标准 | 只显示六类支撑项；危险动作有确认；关闭返回来源。 |
| 不在范围 | 宽抽屉、VIP、小组件、帮助墙、主题商城。 |

### REQ-015 · 隐私 / 合规 / AI 边界

| 字段 | 规格 |
| --- | --- |
| 区域 | Trust |
| 优先级 | P0 Swift MVP |
| 产品行为 | 所有健康、AI、营养、趋势、复盘和导出/移除表面必须遵守合规、隐私和数据控制边界。 |
| 用户价值 | 用户相信 Vitora 是私密、可控、非诊断的陪伴工具。 |
| 输入 | 用户数据、AI context、日志、通知、导出/移除动作。 |
| 输出 | 合规提示、最小化 AI context、日志脱敏、导出、账号移除。 |
| 状态 | compliant、blockedExpression、aiUnavailable、exportReady、removed。 |
| 关联事实 | F-COMPLIANCE-001 to F-AI-002 |
| 关联流程 | UF-005, UF-006, UF-010 |
| 关联 IA | IA-023, IA-040 to IA-046 |
| 验收标准 | 不记录健康数值/原文/prompt/完整 AI 输出；AI 输出过 guard；导出和移除可达。 |
| 不在范围 | 医疗诊断、治疗建议、模型控制面板。 |

### REQ-016 · 视觉系统

| 字段 | 规格 |
| --- | --- |
| 区域 | Design System |
| 优先级 | P0 Swift MVP |
| 产品行为 | 正式 UI 必须使用 Aura Glass Pixel Companion：弥散渐变背景、清透拟态玻璃组件、Pixel Vitora 陪伴体。 |
| 用户价值 | App 有高级、AI-native、陪伴感强的品牌体验，而不是系统健康 dashboard。 |
| 输入 | design-language-demo、design_04 reference images、wireframes。 |
| 输出 | tokens、components、wireframes、QA acceptance。 |
| 状态 | firstLevelGlass、secondLevelReadableGlass、supportPracticalSurface、pixelIdle、pixelListening、pixelThinking。 |
| 关联事实 | F-VISUAL-001 to F-VISUAL-005 |
| 关联流程 | UF-002, UF-003, UF-006, UF-008 |
| 关联 IA | IA-010, IA-020, IA-030 |
| 验收标准 | 背景 blue/cyan-first；Pixel Vitora 不是 smooth orb/human/pet；Vitora tab CTA 低凸起；input dock 不被遮挡。 |
| 不在范围 | Apple Health dashboard、纯白卡片 SaaS UI、重紫梦幻 UI。 |

## 4. 状态要求

| State | Required Behavior |
| --- | --- |
| Low Data | 明确“基于目前信息”，提供告诉 Vitora / 数据来源入口。 |
| AI Unavailable | 保留输入，允许手动确认保存，不显示失败羞辱。 |
| Suggestion Accepted | 保存当日意图，晚间可复盘，不显示任务债务。 |
| Sleep Seed | 只表达建议反馈证据，可为 `seed / halfOpen / bloom / dormant`；不表达完成率、连续天数或惩罚。 |
| Context Sheet Dismissed | 回来源，输入未保存时给明确取消或草稿策略。 |
| Voice Planned | P0 可不实现完整对话语音，但 UI 和规格保留语音记录入口。 |
| 旧代码命名 | 旧 Luna 代码命名可暂存，用户面对文案和正式 specs 必须使用 Vitora。 |

## 5. 验收标准

| ID | Criteria |
| --- | --- |
| AC-001 | 所有 P0 主路径只显示 Today / Vitora / Cycle。 |
| AC-002 | Today 首页没有独立记录区，只有状态校准和对象级告诉 Vitora。 |
| AC-003 | Vitora Tab 首屏不是空聊天，也不是功能 dashboard。 |
| AC-004 | Cycle 首页展示能量复盘日历、`6.5` 指标卡和周期报告详情；不展示任务日历、打卡、完成率、连续天数、花架证据、旧能量动态或节律洞察卡。 |
| AC-005 | Askable surface 的单击、长按、callout、TipKit 逻辑可验收。 |
| AC-006 | 设计语言符合 `design-language-demo.md`。 |
| AC-007 | 旧 T102 Evening Review 不作为下一实施阶段；先执行 pivot adaptation。 |

## 6. 使用规则

后续 `plan.md`、`tasks.md`、Swift 实现和 QA 必须覆盖 REQ-001 到 REQ-016。若某项实现恢复旧 Luna 产品文案、旧 Today 独立记录区、旧 Cycle 日历首页、旧沉浸聊天页或旧 Apple Health dashboard 视觉，应视为不符合 P0 规格。
