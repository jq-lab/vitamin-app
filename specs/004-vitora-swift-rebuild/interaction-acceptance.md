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

## 1. 严重级别

| Level | Meaning | Release Rule |
| --- | --- | --- |
| Blocker | 破坏核心学习循环、隐私合规、主导航或保存闭环。 | 不得继续下一阶段。 |
| Major | 路径可完成，但用户心智、反馈、退出或可访问性明显不足。 | P0 前必须修复。 |
| Minor | 不阻塞，但影响高级感、一致性或精致度。 | 记录并排期。 |

## 2. 全局验收

| ID | Rule | Pass | Fail |
| --- | --- | --- | --- |
| IAC-G-001 | 主导航固定为 Today / Vitora / Cycle。 | 三项稳定，中央 Vitora face 低凸起。 | 出现第 4 tab；中央 CTA 遮挡输入 dock。 |
| IAC-G-002 | 用户面对只叫 Vitora。 | 文案、tab、assistant、sheet title 均为 Vitora。 | 出现用户面对 Luna。 |
| IAC-G-003 | 3 秒可理解 Today。 | 首屏看到状态、身体要素、建议。 | 首屏是大 dashboard、空白、纯装饰或任务列表。 |
| IAC-G-004 | 无压力化。 | 无红点、连续天数、完成率、失败惩罚。 | 任何主路径出现打卡压力。 |
| IAC-G-005 | Aura Glass Pixel Companion 视觉门禁。 | 首层有弥散渐变、清透玻璃、Pixel Vitora。 | 退回 Apple Health-like flat white dashboard。 |
| IAC-G-006 | AI 可控。 | Vitora 理解结果可确认、修改、不保存。 | AI 直接写入健康事实。 |
| IAC-G-007 | Sheet 生命周期完整。 | 打开、输入、确认、保存、关闭、回来源都明确。 | 打开后无退出或保存后无反馈。 |
| IAC-G-008 | 可访问性。 | 44pt 触控、VoiceOver label、动态字体、降低动效/透明可用。 | 小目标、文字溢出、只靠颜色或动效表达。 |

## 3. Today 验收

| ID | Rule | Pass | Fail |
| --- | --- | --- | --- |
| IAC-T-001 | Today 首页结构。 | 只有顶部上下文、现在状态、身体要素、Vitora 今日建议。 | 独立 `+记录` 区、过多 dashboard 卡、任务清单。 |
| IAC-T-002 | 状态卡。 | 数字 + 状态词 + 关键窗口 + 节律曲线 + 轻校准。 | 只有百分比；用户不知道下一步。 |
| IAC-T-003 | 校准入口。 | Chips 或“告诉 Vitora”打开 3/4 contextual sheet。 | 跳到 Vitora tab 后用户丢失上下文。 |
| IAC-T-004 | 身体要素。 | 每项有数值、趋势、对今天意义，可二层查看。 | 堆指标但不解释为什么。 |
| IAC-T-005 | Vitora 今日建议。 | `我试试` 保存当日意图；`换一个` 可替换；`详情` 可解释原因。 | 只是 toast 或任务完成压力。 |
| IAC-T-006 | Today 日历入口。 | 顶部日历进入周期日历并返回 Today。 | 日历放到 Cycle 首页作为主卡。 |
| IAC-T-007 | Energy Ball。 | 默认隐藏；首次/下拉/复盘出现；可收起。 | 首页常驻大球压住核心信息；下拉误用刷新。 |
| IAC-T-008 | 低数据。 | Today 仍可用，说明“基于目前信息”，可告诉 Vitora 或管理数据来源。 | 空白、失败感、要求授权后才能继续。 |

## 4. Vitora 验收

| ID | Rule | Pass | Fail |
| --- | --- | --- | --- |
| IAC-V-001 | Vitora Tab 是 AI-native assistant surface。 | Pixel Vitora、Vitora 知道、对话、直接问、快捷上下文、input dock 同屏。 | 空白聊天页；普通功能宫格；dashboard 堆卡。 |
| IAC-V-002 | Pixel Vitora IP。 | 像素球状体，眼睛像素化，呼吸/眨眼轻微。 | smooth orb、人类头像、宠物、普通 icon。 |
| IAC-V-003 | 直接问。 | 薄横向玻璃条，帮助 cold start。 | 大按钮宫格或营销文案。 |
| IAC-V-004 | 快捷上下文。 | 小 icon chips 位于输入区上方，带入上下文。 | 大卡片占满屏幕；和输入断裂。 |
| IAC-V-005 | 输入 dock。 | 文字、语音、发送状态完整；键盘和 tab 不遮挡。 | 无发送路径；中央 CTA 遮挡输入；语音状态无退出。 |
| IAC-V-006 | 滚动压缩态。 | Pixel Vitora 缩到左上，核心上下文压缩成一行。 | 滚动后 IP 消失或顶部仍占半屏。 |
| IAC-V-007 | Rich response。 | Vitora 先展示理解、影响范围、建议更新，用户确认后保存。 | 输入发送后直接消失或直接写入。 |
| IAC-V-008 | Contextual sheet 升级。 | 3/4 sheet 可上滑进入完整 context mode。 | 从来源唤醒后直接切 tab 或打开完全不同页面。 |

## 5. Cycle 验收

| ID | Rule | Pass | Fail |
| --- | --- | --- | --- |
| IAC-CY-001 | Cycle 首页只承担长期节律。 | 阶段关系卡 + 能量动态卡 + 设置入口。 | 周期日历作为首页主卡；重复 Today 当前状态。 |
| IAC-CY-002 | 当前周期阶段与今天。 | 显示阶段、阶段轴、Today 关系、估算/置信度感。 | 只显示 Day 数字，没有说明和 Today 的关系。 |
| IAC-CY-003 | 能量动态。 | 支持日/周/月，显示趋势预览和 Vitora 叙事。 | 堆高级图表、商业化入口或与 Today 价值重复。 |
| IAC-CY-004 | 阶段二层。 | 透明解释：如何判断、预测窗口、对今天意义、校准。 | 二层和首页信息重复，没有新价值。 |
| IAC-CY-005 | 能量二层。 | 趋势探索 + 图层 + 关键点 + callout。 | 只有一张放大的同款曲线。 |
| IAC-CY-006 | 设置入口。 | 右上头像进入 P0 设置/我的。 | 支撑入口藏太深或出现宽设置中心。 |

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
| IAC-QA-002 | Today 首屏丰富数据。 | 状态、身体要素、建议 3 秒内可读。 |
| IAC-QA-003 | Today 顶部下拉。 | Energy Ball 半展开/全屏/收起状态正确。 |
| IAC-QA-004 | 点击 Today 状态卡。 | 进入状态详情；返回 Today。 |
| IAC-QA-005 | 长按 Today 状态卡。 | 出 context menu；选择问 Vitora 打开 3/4 sheet。 |
| IAC-QA-006 | 点击校准 chip。 | Contextual sheet 带今日状态上下文；确认后更新状态。 |
| IAC-QA-007 | 进入 Vitora Tab。 | Pixel Vitora hero、Vitora 知道、直接问、chips、input dock 可见。 |
| IAC-QA-008 | Vitora 输入文字。 | Rich response card 可确认、修改、不保存。 |
| IAC-QA-009 | Vitora 语音入口。 | 录音态、重录、转写并理解路径可见。 |
| IAC-QA-010 | Cycle 首页。 | 阶段关系和能量动态可见；没有日历首页。 |
| IAC-QA-011 | Cycle 能量二层点曲线点。 | 显示 callout；可问 Vitora。 |
| IAC-QA-012 | Today 顶部日历。 | 打开周期日历并返回 Today。 |
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
| IAC-N-005 | Energy Ball 常驻压住 Today 首屏。 |
| IAC-N-006 | Pixel Vitora 被 smooth orb、人类头像、宠物或普通 icon 替代。 |
| IAC-N-007 | Apple Health dashboard-like flat white visual 成为首层方向。 |
| IAC-N-008 | 长按是访问 Vitora 的唯一方式。 |
| IAC-N-009 | AI 输出未经用户确认直接保存为健康事实。 |
| IAC-N-010 | `/speckit.implement` 继续旧 T102 Evening Review 而不先做 pivot adaptation。 |
