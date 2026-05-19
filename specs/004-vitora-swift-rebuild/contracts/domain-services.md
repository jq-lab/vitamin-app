# Vitora Swift Rebuild · Domain Services Contract

> Contract: domain-services
> 状态：IA / Design Pivot Adapted

本文档定义 P0 领域服务契约。它不是 Swift protocol 的逐字实现，也不是 API 文档；后续 tasks 必须把这些契约转成 Swift service、repository 和 ViewModel 调用边界。

## 0. 使用规则

| Rule ID | Rule |
| --- | --- |
| DSC-001 | 每个服务必须引用 `REQ-*`、`DM-*` 和 `DE-*`。 |
| DSC-002 | 服务返回 domain state，不返回 SwiftUI View。 |
| DSC-003 | 服务不得直接展示 UI 文案；UI 文案引用 `compliance.md`。 |
| DSC-004 | 服务不得直接写日志中的健康数值或记录原文。 |
| DSC-005 | 如果服务动作会改变持久事实，必须产生可测试状态或领域事件。 |
| DSC-006 | 用户面对命名使用 Vitora；旧 `Luna*` service 名只可作为内部迁移债。 |

## 1. Service Index

| Service ID | Service | Responsibility | Linked Models | Linked Requirements |
| --- | --- | --- | --- | --- |
| DS-001 | AppGateService | 判断 onboarding / Today / low-data 入口。 | DM-003, DM-004 | REQ-001, REQ-003 |
| DS-002 | OnboardingService | 保存最小身份和初始上下文。 | DM-001, DM-002, DM-006 | REQ-001, REQ-002 |
| DS-003 | TodayStateService | 汇总 Today 状态、身体要素、关键窗口和下一步。 | DM-005, DM-006, DM-011, DM-012 | REQ-004 |
| DS-004 | EnergyBowlStateService | 控制 Today Energy Bowl 状态、实时预测和复盘能量对比表达；不再负责顶部下拉 Energy Ball。 | DM-013, DM-014, DM-019 | REQ-005 |
| DS-005 | SuggestionService | 生成和解释 Vitora 今日建议。 | DM-011, DM-012, DM-015 | REQ-007 |
| DS-006 | DailyIntentionService | 保存当日意图、提醒偏好和轻反馈。 | DM-015, DM-016, DM-018 | REQ-007 |
| DS-007 | VitoraAssistantStateService | 生成 Vitora Tab 所需上下文、直接问、快捷上下文和复盘入口。 | DM-011, DM-016, DM-019, DM-021 | REQ-010 |
| DS-008 | VitoraUnderstandingService | 捕获、理解、确认、保存用户告诉 Vitora 的事实。 | DM-008, DM-009, DM-010 | REQ-008, REQ-011, REQ-013 |
| DS-009 | VitoraConversationService | 管理 Vitora 对话消息、rich response 和 AI fallback。 | DM-021, DM-022, DM-023 | REQ-010, REQ-011 |
| DS-010 | EveningReviewService | 判断复盘可用性、保存反馈、生成学习信号。 | DM-016, DM-019, DM-020 | REQ-005, REQ-007 |
| DS-011 | CycleRhythmService | 生成当前周期阶段与今天、阶段详情和置信度。 | DM-006, DM-007, DM-011 | REQ-012 |
| DS-012 | EnergyDynamicsService | 生成日/周/月能量动态、图层、关键点和 Vitora 叙事。 | DM-011, DM-012, DM-020 | REQ-012 |
| DS-013 | NutritionService | 管理营养补给条目。 | DM-010, DM-009 | REQ-013 |
| DS-014 | SupportService | 生成设置 / 支撑项和子页状态。 | DM-004, DM-017, DM-024, DM-025 | REQ-014 |
| DS-015 | DataExportService | 准备和完成导出。 | DM-001 到 DM-025, DM-024 | REQ-015 |
| DS-016 | AccountRemovalService | 执行账号移除和本地状态重置。 | DM-025, DM-003 | REQ-015 |
| DS-017 | AIContextService | 构建最小 AI 上下文并检查输出。 | DM-022, DM-023 | REQ-015, REQ-016 |

## 2. Required State Transitions

| Transition ID | Trigger | Must Update | Event | Must Not |
| --- | --- | --- | --- | --- |
| DST-001 | Onboarding completed | DM-001, DM-002, DM-003 | DE-001 | 强制账号登录。 |
| DST-002 | HealthKit choice changed | DM-004, DM-011 | DE-002 | 阻塞 Today / Vitora / Cycle。 |
| DST-003 | Daily opened | DM-013 | DE-003 | 写入健康内容到 UI 状态。 |
| DST-004 | Energy reveal completed | DM-014, DM-011 | DE-004 | 只播放动效而不落结果。 |
| DST-005 | User tells Vitora a fact | DM-008 | DE-005 | 输入后无反馈地丢失。 |
| DST-006 | Vitora understanding confirmed | DM-009, DM-011 | DE-006 | 未确认就保存理解结果。 |
| DST-007 | Suggestion accepted | DM-016, optional DM-018 | DE-007 | 只显示即时提示。 |
| DST-008 | Suggestion rejected or changed | DM-016 feedback | DE-008 | 产生任务失败感。 |
| DST-009 | Evening review completed | DM-019, DM-020 | DE-009 | 只问是否完成。 |
| DST-010 | Nutrition changed | DM-010, optional DM-009 | DE-010 | 引导交易或促销。 |
| DST-011 | Cycle phase calibrated | DM-006, DM-009 | DE-011 | 让用户直接编辑预测曲线。 |
| DST-012 | Energy dynamic point selected | transient UI state | DE-012 | 把 callout 当成持久事实。 |
| DST-013 | Export requested | DM-024 | DE-013 | 只弹提示而无状态。 |
| DST-014 | Account removal requested | DM-025, DM-003 | DE-014 | 无二次确认。 |
| DST-015 | AI context built | DM-022 | DE-015 | 使用完整历史或无关原文。 |

## 3. Service Acceptance

| ID | Acceptance |
| --- | --- |
| DSA-001 | `DS-003` 在低数据状态下仍返回可用 TodayState。 |
| DSA-002 | `DS-005` 和 `DS-006` 保存选择后，`DS-010` 能读取复盘前置上下文。 |
| DSA-003 | `DS-008` 保存前必须进入 confirming 状态。 |
| DSA-004 | `DS-011` 不把 Cycle 首页变成日历首页。 |
| DSA-005 | `DS-012` 能按日/周/月生成能量动态摘要。 |
| DSA-006 | `DS-015` 导出内容覆盖 P0 已保存用户数据。 |
| DSA-007 | `DS-016` 完成后 AppGate 回到新开始状态。 |
| DSA-008 | `DS-017` 不接收直接身份字段、完整记录原文或无关历史。 |
