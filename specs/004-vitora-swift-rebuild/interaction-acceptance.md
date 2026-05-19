# Vitora Swift Rebuild · 交互验收规格

> 规格集：`004-vitora-swift-rebuild`
> 批次：IA / Design Pivot Adaptation
> 日期：2026-05-05
> 状态：当前生效

本文档定义 P0 交互、状态、视觉语言和 QA 门禁。它已废弃旧 Luna 沉浸聊天唯一心智、旧 Cycle 日历首页、旧 Today 独立记录入口和 Apple Health dashboard 视觉方向。

## 0. 权威规则

| Rule ID | Rule |
| --- | --- |
| IAC-AUTH-001 | 若实现与 `facts.md`、`spec.md`、`ia.md`、`wireframes.md` 冲突，交互验收不通过。 |
| IAC-AUTH-002 | `wireframes-walkthrough-demo.md` 和 `design-language-demo.md` 是 pivot evidence；正式验收以本文和对应 formal specs 为准。 |
| IAC-AUTH-003 | 每个 `/speckit.implement` phase 结束必须按本文跑 simulator / iosef / XCUITest / 人工截图 QA。 |
| IAC-AUTH-004 | 旧代码中的 Luna 命名可暂存为迁移债，但用户面对 UI 和新规格验收必须使用 Vitora。 |
| IAC-AUTH-005 | Cycle 首页视觉、布局、图表、Tip 和 Tab 避让验收必须同时读取 `cycle-page/qa-checklist.md`。 |
| IAC-AUTH-006 | Vitora Tab assistant surface、Quick Context、Input Dock 和周期展开态验收必须同时读取 `vitora-page/qa-checklist.md`。 |
| IAC-AUTH-007 | Today / Vitora / Cycle 首层动态背景、周期色变化和 Reduce Motion 兜底验收必须同时读取 `dynamic-aura-background/qa-checklist.md`。 |

## 1. 严重级别

| Level | Meaning | Release Rule |
| --- | --- | --- |
| Blocker | 破坏核心学习循环、隐私合规、主导航或保存闭环。 | 不得继续下一阶段。 |
| Major | 路径可完成，但用户心智、反馈、退出或可访问性明显不足。 | P0 前必须修复。 |
| Minor | 不阻塞，但影响高级感、一致性或精致度。 | 记录并排期。 |

## 2. 全局验收

| ID | Rule | Pass | Fail |
| --- | --- | --- | --- |
| IAC-G-001 | 主导航固定为 Today / Vitora / Cycle。 | 三项稳定，Tab 切换区居中，右侧有独立圆形 `+` 记录键；Today / Cycle 不显示输入条，AI 管家显示输入条；sheet 展示时全局 Dock 不透出。 | 出现第 4 tab；中央 CTA 遮挡输入 dock；Tab 图标或记录键混入输入胶囊；非 AI 页仍显示输入条；sheet 背后仍可见或可点全局 Dock。 |
| IAC-G-002 | 用户面对只叫 Vitora。 | 文案、tab、assistant、sheet title 均为 Vitora。 | 出现用户面对 Luna。 |
| IAC-G-003 | 3 秒可理解 Today。 | 首屏看到状态、身体要素、建议。 | 首屏是大 dashboard、空白、纯装饰或任务列表。 |
| IAC-G-004 | 无压力化。 | 无红点、连续天数、完成率、失败惩罚。 | 任何主路径出现打卡压力。 |
| IAC-G-005 | Aura Glass Pixel Companion 视觉门禁。 | 首层有弥散渐变、清透玻璃、Pixel Vitora。 | 退回 Apple Health-like flat white dashboard。 |
| IAC-G-009 | Dynamic Aura 背景统一。 | Today / Vitora / Cycle 首层背景读取同一周期色状态，动效不抢内容。 | 每页单独背景、教程录屏残留、背景遮挡信息。 |
| IAC-G-006 | AI 可控。 | Vitora 理解结果可确认、修改、不保存。 | AI 直接写入健康事实。 |
| IAC-G-007 | Sheet 生命周期完整。 | 打开、输入、确认、保存、关闭、回来源都明确。 | 打开后无退出或保存后无反馈。 |
| IAC-G-008 | 可访问性。 | 44pt 触控、VoiceOver label、动态字体、降低动效/透明可用。 | 小目标、文字溢出、只靠颜色或动效表达。 |

## 3. Today 验收

| ID | Rule | Pass | Fail |
| --- | --- | --- | --- |
| IAC-T-001 | Today 首页结构。 | 只有顶部上下文、现在状态、碗下周期线轴、Vitora 今日建议；睡眠种子只能出现在今日建议卡内作为低权重反馈证据。 | 独立 `+记录` 区、首页身体要素卡、首页实时预测图、花园手册、成长册入口、过多 dashboard 卡、任务清单、花园 Tab。 |
| IAC-T-002 | 状态卡。 | 单层高对比综合能量数字 + 屏幕顶部水滴入碗动效 + 按能量显示的水位 + 数字下方状态词与同排 `查看数据` + 碗外下方中间下沉的三阶段周期圆弧，和碗底约一个中文字高度间距。 | 只有百分比；水滴只在局部飘动或像星光粒子；水位不随能量变化；状态词压在碗体下方；`查看数据` 远离状态词；数字有双层虚影；周期圆弧贴住碗底或上移进碗底光晕；首页仍显示数据小标签、睡眠/周期预测切换或实时预测图。 |
| IAC-T-003 | 记录/校准入口。 | 对象长按或全局圆形 `+` 打开 3/4 contextual sheet。 | 首页显示校准 chips；跳到 Vitora tab 后用户丢失上下文。 |
| IAC-T-004 | 身体要素。 | 每项有数值、趋势、对今天意义，可二层查看。 | 堆指标但不解释为什么。 |
| IAC-T-005 | Vitora 今日建议。 | 标题后显示大字号身体翻译和依据；显示 `昨晚种子状态 / 原因 / 今天让它继续打开`；两条建议组成 `吃+休息 / 运动+吃 / 休息+运动` 轮换组合；`我试试` 进入现有分析/提醒路径并可推动种子打开；icon `换一换` 只在卡内循环；每条建议尾部为勾选 icon。 | 只是 toast、只建议休息、仍有 `为什么` 首屏按钮、`换一换` 跳去 Vitora 浮层、首页建议卡堆数据小标签或制造任务完成压力。 |
| IAC-T-006 | Today 日历入口。 | 顶部日历进入周期日历并返回 Today。 | 日历放到 Cycle 首页作为主卡。 |
| IAC-T-007 | Energy Bowl / 今日分析。 | 首屏无顶部下拉 Energy Ball；水滴从屏幕顶部安全区上方落入碗口，入水有轻涟漪，水位按综合能量表现浅水/半碗/接近满碗，Reduce Motion 下静态水位仍可读；能量碗图形和数字/查看数据/状态文案分层不重叠；数字上方无 `今天`，标签上方无 `监测到`；`查看数据` 与状态词同排；首页数据小标签不存在；首页固定综合能量并在碗外下方显示按阶段色渲染的中间下沉三阶段圆弧，圆弧和碗底保持约一个中文字高度，当前 D18 只显示 `排卵期 / 黄体期 D18 / 月经期` 且文字全部在圆弧下端；能量碗可进入状态详情；`查看数据` 进入今日分析，显示数据小标签、综合实时预测、身体要素四卡和综合判断。 | 仍显示“轻轻下拉”提示；下拉误用刷新；水滴只在卡片局部闪烁或像星光粒子；文字压在碗体上；周期线轴仍是横向波浪、上凸弧、贴住碗底或顶部气泡；首页仍有数据小标签、三模式切换、实时预测图或校准 chips；今日分析缺少坐标、当前时间气泡或身体要素依据。 |
| IAC-T-008 | 低数据。 | Today 仍可用，说明“基于目前信息”，可告诉 Vitora 或管理数据来源。 | 空白、失败感、要求授权后才能继续。 |

## 4. Vitora 验收

| ID | Rule | Pass | Fail |
| --- | --- | --- | --- |
| IAC-V-001 | Vitora Tab 是 AI-native assistant surface。 | Pixel Vitora、Vitora 知道、对话、直接问、快捷上下文、input dock 同屏；具体执行以 `vitora-page/vitora-page-spec.md` 为准。 | 空白聊天页；普通功能宫格；dashboard 堆卡。 |
| IAC-V-002 | Pixel Vitora IP。 | 继承 `pixel-vitora-ip/pixel-vitora-ip-spec.md` 的玻璃像素小球 baseline；眼睛像素化，呼吸/眨眼轻微。 | smooth orb、人类头像、宠物、普通 icon；每页单独发明不同 IP。 |
| IAC-V-003 | 直接问。 | 薄横向玻璃条，帮助 cold start。 | 大按钮宫格或营销文案。 |
| IAC-V-004 | 快捷上下文。 | 小 icon chips 位于日期行下方，带入上下文；`周期 / 睡眠 / 营养` 都使用统一上下文摘要卡，右上角可取消。 | 大卡片占满屏幕；和输入断裂；周期使用专属报表而睡眠/营养只是简短卡；把报表做成 Cycle 首页。 |
| IAC-V-005 | 输入 dock。 | Dock 由 bottom safe area 承载；上排居中 Tab 右圆形 `+`，AI 管家页下排顺序固定为语音/键盘、输入或内联语音条、发送；输入条内无 `+`；右侧发送固定且状态清楚；点击 `AI管家` 自动聚焦输入，点击圆形 `+` 只打开快捷补充 sheet；sheet 打开时全局 Dock 隐藏；键盘和 tab 不遮挡。 | 无发送路径；中央 CTA 遮挡输入；记录键进入输入胶囊；点击记录切到 Vitora Tab；非 AI 页显示输入条；sheet 与背景 Dock 叠加；语音状态无退出；语音态文字竖排或按钮挤压。 |
| IAC-V-006 | 聊天聚焦态。 | 点击 `AI管家` 后先保持实体 hero 卡片态；用户上拉后隐藏 hero 卡，完整展示日期行、topic rail、说明、消息、能力反馈和输入 dock，不切回 Today。 | 点击进入即大展开；上拉后跳回 Today；顶部仍占半屏；聊天内容被底部 Dock 遮挡。 |
| IAC-V-007 | Rich response。 | Vitora 先展示理解、影响范围、建议更新，用户确认后保存。 | 输入发送后直接消失或直接写入。 |
| IAC-V-008 | Contextual sheet 升级。 | 3/4 sheet 可上滑进入完整 context mode。 | 从来源唤醒后直接切 tab 或打开完全不同页面。 |

## 5. Cycle 验收

| ID | Rule | Pass | Fail |
| --- | --- | --- | --- |
| IAC-CY-001 | Cycle 首页只承担长期节律。 | `周期回顾` + 左上我的入口 + 右上周期卡片分享 + 三件事总结 + 能量动态 + 三张节律洞察卡 + 低权重 `本周期花架证据`；具体执行以 `cycle-page/cycle-page-spec.md` 为准。 | 周期日历、30 天成长册、花园手册、种子选择或花田地图作为首页主卡；重复 Today 当前状态；出现任务、打卡、完成率或连续天数。 |
| IAC-CY-002 | 周期回顾理解。 | 三件事总结和能量动态共同说明当前周期阶段、Today 关系和估算/待校准感。 | 只显示 Day 数字，没有说明和 Today 的关系；花园/成长卡像日历或任务完成度。 |
| IAC-CY-003 | 能量动态。 | 支持日/周/月，显示趋势预览和 Vitora 叙事。 | 堆高级图表、商业化入口或与 Today 价值重复。 |
| IAC-CY-004 | 阶段二层。 | 透明解释：如何判断、预测窗口、对今天意义、校准。 | 二层和首页信息重复，没有新价值。 |
| IAC-CY-005 | 能量二层。 | 趋势探索 + 图层 + 关键点 + callout。 | 只有一张放大的同款曲线。 |
| IAC-CY-006 | 顶部入口。 | 左上头像进入 P0 设置/我的；右上分享只分享当前周期卡片截图。 | 支撑入口藏太深、出现宽设置中心、分享导出记录原文或隐藏健康数据。 |

## 6. Askable Surface 验收

| ID | Rule | Pass | Fail |
| --- | --- | --- | --- |
| IAC-AS-001 | 单击是主路径。 | 卡片单击进入二层 IA。 | 单击只弹 callout 或无反应。 |
| IAC-AS-002 | 长按是 shortcut。 | 长按打开 iOS context menu：问 Vitora / 告诉不准 / 查看详情。 | 长按是唯一入口；菜单项超过 3 个且无关。 |
| IAC-AS-003 | Callout 是局部解释。 | 点图表点显示小气泡，可进入问 Vitora。 | Callout 替代二层详情。 |
| IAC-AS-004 | TipKit 教学。 | 第一次停留 2-3 秒后轻提示一次，成功使用后消失。 | 每次弹提示或完全无可发现性。 |
| IAC-AS-005 | 二层 fallback。 | 二层有 `⋯` 或小 Vitora 图标打开同样 actions。 | 不会长按的用户无法访问 Vitora 动作。 |

## 7. Support / Trust 验收

| ID | Rule | Pass | Fail |
| --- | --- | --- | --- |
| IAC-S-001 | 支撑项边界。 | 只显示个人资料、HealthKit/数据来源、营养补给、提醒偏好、数据导出、隐私法律与账号移除。 | VIP、主题、小组件、帮助墙、养成进度进入 P0。 |
| IAC-S-002 | 隐私合规。 | 导出/移除有确认、进度、完成反馈；日志无健康数值和记录原文。 | 危险动作无确认；日志泄露敏感内容。 |
| IAC-S-003 | 营养补给。 | 管理页在支撑区；快捷新增可从 Vitora context 发生。 | 营养入口商业化或强销售。 |
| IAC-S-004 | 提醒偏好。 | 只服务今日建议和晚间复盘；权限拒绝不影响意图。 | 通知成为使用门槛。 |

## 8. QA 场景

| ID | Scenario | Expected |
| --- | --- | --- |
| IAC-QA-001 | 新装打开，跳过 HealthKit。 | 完成 onboarding，进入低数据 Today。 |
| IAC-QA-002 | Today 首屏丰富数据。 | 综合能量碗、单层高对比数字、数字下方状态词、碗底三阶段周期圆弧、身体翻译和组合建议 3 秒内可读；首页没有数据小标签、实时预测图和校准 chips。 |
| IAC-QA-003 | Today Energy Bowl。 | 点击能量碗进入状态详情；点击 `查看数据` 进入今日分析；数据小标签、综合实时预测当前时间气泡、横向身体要素卡可见。 |
| IAC-QA-004 | 点击 Today 状态卡。 | 进入状态详情；返回 Today。 |
| IAC-QA-005 | 长按 Today 状态卡。 | 出 context menu；选择问 Vitora 打开 3/4 sheet。 |
| IAC-QA-006 | 点击全局圆形 `+` 或对象长按校准。 | Contextual sheet 带来源上下文；确认后更新理解，不切换主 Tab。 |
| IAC-QA-007 | 进入 Vitora Tab。 | Pixel Vitora hero、Vitora 知道、直接问、chips、input dock 可见。 |
| IAC-QA-008 | Vitora 输入文字。 | Rich response card 可确认、修改、不保存。 |
| IAC-QA-008A | 全局快捷记录。 | 点击 Dock 右侧圆形 `+` 打开来源为 `快捷记录` 的 Vitora contextual sheet，看到快捷补充，不切换到 Vitora Tab。 |
| IAC-QA-009 | Vitora 语音入口。 | 录音态、重录、转写并理解路径可见。 |
| IAC-QA-010 | Cycle 首页。 | 周期回顾、花田、三件事总结、能量动态和三张洞察卡可见；没有日历首页。 |
| IAC-QA-011 | Cycle 能量二层点曲线点。 | 显示 callout；可问 Vitora。 |
| IAC-QA-012 | Today 顶部日历。 | 打开周期日历并返回 Today。 |
| IAC-QA-012A | Today 日历选择不同日期。 | 返回 Today 后背景按周期阶段 crossfade 变化，Reduce Motion 下显示 poster。 |
| IAC-QA-013 | 晚间复盘。 | 显示早上状态和晚间反馈，不问“完成了吗”。 |
| IAC-QA-014 | 设置入口。 | 只显示 P0 支撑项。 |
| IAC-QA-015 | Accessibility。 | 动态字体、VoiceOver、Reduce Motion/Transparency 通过。 |

## 9. 反向验收：出现即失败

| ID | Fail Pattern |
| --- | --- |
| IAC-N-001 | 用户面对 UI 出现 Luna。 |
| IAC-N-002 | Today 有独立常驻 `+记录` section。 |
| IAC-N-003 | Cycle 首页是日历。 |
| IAC-N-004 | Vitora Tab 是空白聊天或功能 dashboard。 |
| IAC-N-005 | Today 首屏出现顶部下拉 Energy Ball 提示或常驻大能量球压住核心信息。 |
| IAC-N-006 | Pixel Vitora 被 smooth orb、人类头像、宠物或普通 icon 替代。 |
| IAC-N-007 | Apple Health dashboard-like flat white visual 成为首层方向。 |
| IAC-N-008 | 长按是访问 Vitora 的唯一方式。 |
| IAC-N-009 | AI 输出未经用户确认直接保存为健康事实。 |
| IAC-N-010 | `/speckit.implement` 继续旧 T102 Evening Review 而不先做 pivot adaptation。 |
