# Tasks: Vitora Swift Rebuild P0

**输入**：`/specs/004-vitora-swift-rebuild/` 下的产品、数据、合约、UX 与交付规格
**前置文档**：`plan.md`、`spec.md`、`research.md`、`data-model.md`、`contracts/`、`quickstart.md`、UX 规格
**测试要求**：必须按 `contracts/qa-contract.md` 与 `quickstart.md` 执行
**组织方式**：任务按可独立验证的用户故事分组，先测试、再实现、再验收。

## 格式：`[ID] [P?] [Story] 任务描述`

- **[P]**：可并行执行，原因是文件范围不同，且不依赖尚未完成的任务。
- **[Story]**：用户故事标签，用于追溯。
- **[UI]**：来自 `components.md`、`wireframes.md`、`reference.md`、`interaction-acceptance.md` 的界面任务。
- 每个任务都必须包含明确文件路径。

## IA / Design Pivot 状态说明

- `T001` 到 `T101` 保留为已完成历史，不回滚。
- `T056` 到 `T060`、`T085` 到 `T100` 属于 pivot 前完成的 UI：可保留底层服务、状态机、测试经验和部分组件，但必须由新的 `T102+` adaptation tasks 重构到 Today / Vitora / Cycle 新 IA。
- 旧代码中的 `Luna*` 路径、accessibility id 或类型名可暂时作为 internal migration debt；用户面对文案、正式 specs、新任务和新组件必须使用 `Vitora`。
- `T001-T101` 的旧 `Luna`、旧 `QAJ-*`、旧组件 ID 只作为已完成历史存在；当前产品命名与覆盖检查以 `T102+` 和正式 pivot specs 为准。
- 下一个可执行任务必须从 **Phase 8 · Pivot Baseline Tests** 开始，并按 Phase 8 到 Phase 14 完成整个 pivot block；不能继续旧 Evening Review。

## Phase 1: Setup

**目的**：创建干净的原生 iOS 工程和基础目录。

- [x] T001 在 `ios/Vitora.xcodeproj` 和 `ios/Vitora/VitoraApp.swift` 创建 Vitora SwiftUI 工程壳与 scheme
- [x] T002 在 `ios/Vitora/App/AppEnvironment.swift` 和 `ios/Vitora/App/AppRouter.swift` 创建 app 入口与依赖容器文件
- [x] T003 [P] 在 `ios/Vitora/Core/`、`ios/Vitora/Domains/`、`ios/Vitora/Features/`、`ios/Vitora/Resources/zh-Hans.lproj/` 创建源码目录结构
- [x] T004 [P] 在 `ios/VitoraTests/` 和 `ios/VitoraUITests/` 创建测试 target 目录
- [x] T005 在 `.gitignore` 配置 Swift/Xcode 忽略规则
- [x] T006 在 `ios/Vitora/Resources/zh-Hans.lproj/Localizable.strings` 创建中文字符串占位文件
- [x] T007 按 `quickstart.md` 在 `ios/README.md` 写入构建验证说明
- [x] T008 按 `ios/README.md` 记录的 `xcodebuild` 命令验证初始工程可构建

## Phase 2: Foundational

**目的**：完成所有用户故事都依赖的核心基础设施。

**检查点**：本阶段完成前，不开始任何用户故事实现。

### Foundation Tests

- [x] T009 [P] 在 `ios/VitoraTests/DomainModelTests.swift` 为 `DM-001` 到 `DM-025` 创建领域模型覆盖测试
- [x] T010 [P] 在 `ios/VitoraTests/PersistenceContractTests.swift` 为 `PC-*`、`EXP-*`、`ARM-*` 创建持久化合约测试
- [x] T011 [P] 在 `ios/VitoraTests/AIContextContractTests.swift` 为 `AIC-*`、`AIJ-*`、`AOG-*` 创建 AI 上下文边界测试
- [x] T012 [P] 在 `ios/VitoraTests/NavigationContractTests.swift` 为 `IA-*` 路由门控创建导航合约测试
- [x] T013 [P] 在 `ios/VitoraTests/HealthKitContractTests.swift` 为 `HK-*`、`HKA-*` 与授权状态创建 HealthKit 可选路径测试
- [x] T014 [P] 在 `ios/VitoraTests/NotificationContractTests.swift` 为 `NTC-*`、`NTS-*`、`NTT-*` 创建通知合约测试

### Foundation Implementation

- [x] T015 [P] 在 `ios/Vitora/Core/DesignSystem/VitoraTheme.swift` 实现来自 `vt.*` 的 `VitoraTheme` token 映射
- [x] T016 [P] 在 `ios/Vitora/Core/DesignSystem/Primitives.swift` 实现基础按钮、chip、输入框、进度与合规标签
- [x] T017 [P] 在 `ios/Vitora/Core/DesignSystem/Surfaces.swift` 实现共享表面与 sheet 容器
- [x] T018 [P] 在 `ios/Vitora/Core/Navigation/VitoraRoute.swift` 实现 `IA-000` 到 `IA-046` 的 app 导航枚举与呈现状态
- [x] T019 在 `ios/Vitora/App/AppRouter.swift` 按 `navigation-contract.md` 实现 `AppRouter` 状态转换
- [x] T020 [P] 在 `ios/Vitora/Core/Logging/VitoraLogger.swift` 实现隐私安全日志包装器
- [x] T021 [P] 在 `ios/Vitora/Core/Privacy/KeychainKeyStore.swift` 实现 Keychain 密钥管理器
- [x] T022 在 `ios/Vitora/Core/Persistence/PersistenceClient.swift` 实现加密持久化适配协议与启动流程，并在 `ios/README.md` 记录 SQLCipher Swift wrapper 选择和 fallback
- [x] T023 在 `ios/Vitora/Core/Persistence/Repositories.swift` 实现 `DM-*` 持久化 repository 接口
- [x] T024 [P] 在 `ios/Vitora/Core/HealthKit/HealthKitClient.swift` 实现 HealthKit client 协议与授权状态包装
- [x] T025 [P] 在 `ios/Vitora/Core/Notifications/NotificationScheduler.swift` 实现通知调度协议
- [x] T026 [P] 在 `ios/Vitora/Core/AI/LunaAIClient.swift` 实现 AI client 协议壳
- [x] T027 在 `ios/Vitora/Core/AI/AIContextBuilder.swift` 与 `ios/Vitora/Core/AI/LunaOutputGuard.swift` 实现 `AIContextBuilder` 与 `LunaOutputGuard` 基础壳
- [x] T028 [P] 在 `ios/Vitora/Domains/Onboarding/OnboardingModels.swift` 实现 `DM-001` 到 `DM-004` 的 onboarding 领域模型
- [x] T029 [P] 在 `ios/Vitora/Domains/Today/TodayModels.swift` 实现 `DM-005`、`DM-011` 到 `DM-016` 的 Today 领域模型
- [x] T030 [P] 在 `ios/Vitora/Domains/Luna/LunaModels.swift` 实现 `DM-008` 到 `DM-010` 与 `DM-021` 到 `DM-023` 的 Luna 领域模型
- [x] T031 [P] 在 `ios/Vitora/Domains/Cycle/CycleModels.swift` 实现 `DM-006` 与 `DM-007` 的 Cycle 领域模型
- [x] T032 [P] 在 `ios/Vitora/Domains/Review/ReviewModels.swift` 实现 `DM-017` 到 `DM-020` 的复盘领域模型
- [x] T033 [P] 在 `ios/Vitora/Domains/Support/SupportModels.swift` 实现 `DM-024` 与 `DM-025` 的支撑领域模型
- [x] T034 在 `ios/Vitora/Domains/DomainServices.swift` 实现 `DS-001` 到 `DS-016` 的领域服务协议
- [x] T035 在 `ios/Vitora/Core/Privacy/AppCapabilityState.swift` 实现全局低数据与 AI 不可用状态类型
- [x] T036 运行 foundation 测试套件，并在 `ios/README.md` 记录命令输出

## Phase 3: User Story 1 - 新用户进入可用 Today (Priority: P1) MVP

**目标**：用户无需 WeChat 或 HealthKit 即可完成最小 onboarding，并进入可用的 Today 低数据模式。

**独立测试**：全新安装后进入 onboarding，用户输入最小上下文，跳过 HealthKit，到达 Today，并能返回数据来源设置。

### Tests for User Story 1

- [x] T037 [P] [US1] 在 `ios/VitoraTests/OnboardingDomainTests.swift` 为 `REQ-001`、`REQ-002`、`REQ-003`、`DM-001` 到 `DM-004` 添加 onboarding 领域测试
- [x] T038 [P] [US1] 在 `ios/VitoraUITests/OnboardingLowDataUITests.swift` 为 `QAJ-001` 与 `IAC-QA-001` 添加 XCUITest
- [x] T039 [P] [US1] 在 `ios/VitoraUITests/HealthKitOptionalUITests.swift` 为 `IAC-L-001` 添加 HealthKit 跳过与拒绝状态 UI 断言

### Implementation for User Story 1

- [x] T040 [US1] 在 `ios/Vitora/Domains/Onboarding/AppGateService.swift` 实现 `DS-001` 的 `AppGateService`
- [x] T041 [US1] 在 `ios/Vitora/Domains/Onboarding/OnboardingService.swift` 实现 `DS-002` 的 `OnboardingService`
- [x] T042 [US1] [UI] 在 `ios/Vitora/Features/OnboardingFeature/AppGateView.swift` 按 `C-APP-001`、`RF-000-01`、`RF-002-01` 实现 AppGate 组装屏幕
- [x] T043 [US1] [UI] 在 `ios/Vitora/Features/OnboardingFeature/OnboardingIdentityView.swift` 实现 `IA-001` 注册进入页，并在 `ios/QA/figma-check.md` 记录 Figma 复查
- [x] T044 [US1] [UI] 在 `ios/Vitora/Features/OnboardingFeature/OnboardingContextView.swift` 实现 `IA-002` 聊天式补充信息与 HealthKit / 设备绑定选择屏
- [x] T045 [US1] [UI] `IA-003` ready 屏已按 D-063 合并为 `进入 Vitora` 后直接进入 Today，不再作为独立屏幕
- [x] T046 [US1] 在 `ios/Vitora/Features/OnboardingFeature/OnboardingViewModel.swift` 实现 onboarding view model 状态流
- [x] T047 [US1] 在 `ios/Vitora/Core/HealthKit/HealthKitClient.swift` 实现 HealthKit 可选授权动作
- [x] T048 [US1] 在 `ios/Vitora/Resources/zh-Hans.lproj/Localizable.strings` 添加 onboarding 与低数据中文字符串
- [x] T049 [US1] 运行 US1 单元与 UI 测试，并更新 `ios/README.md` 验证记录

**检查点**：US1 可独立运行，并证明 app 首次进入路径可用。

## Phase 4: User Story 2 - Today 状态、能量仪式、分析 (Priority: P1)

**目标**：回访用户在 3 秒内看到 Today 状态，可执行或跳过能量仪式，并打开有用的分析。

**独立测试**：使用低数据与丰富数据 fixture，Today 能展示状态、下一步、仪式完成或跳过，以及不暴露延期表面的分析 sheet。

### Tests for User Story 2

- [x] T050 [P] [US2] 在 `ios/VitoraTests/TodayStateServiceTests.swift` 为 `REQ-004`、`DM-011`、`DM-012` 添加 Today 状态组装测试
- [x] T051 [P] [US2] 在 `ios/VitoraTests/EnergyRitualServiceTests.swift` 为 `REQ-005`、`DM-013`、`DM-014` 添加能量仪式状态测试
- [x] T052 [P] [US2] 在 `ios/VitoraUITests/TodayFlowUITests.swift` 为 `QAJ-002`、`QAJ-003`、`IAC-QA-003` 添加 Today UI 测试

### Implementation for User Story 2

- [x] T053 [US2] 在 `ios/Vitora/Domains/Today/TodayStateService.swift` 实现 `DS-003` 的 `TodayStateService`
- [x] T054 [US2] 在 `ios/Vitora/Domains/Today/EnergyRitualService.swift` 实现 `DS-004` 的 `EnergyRitualService`
- [x] T055 [US2] 在 `ios/Vitora/Domains/Today/TodayAnalysisService.swift` 实现 `DS-005` 的 `TodayAnalysisService`
- [x] T056 [US2] [UI] 在 `ios/Vitora/Features/TodayFeature/TodayHeaderComponents.swift` 按 `C-TODAY-001`、`C-TODAY-002`、`WF-002`、`RF-002-02` 实现 Today 顶部组件，并在 `ios/QA/figma-check.md` 记录 Figma 复查
- [x] T057 [US2] [UI] 在 `ios/Vitora/Features/TodayFeature/FullEnergyRitualView.swift` 按 `WF-003` / `RF-003-02` 到 `RF-003-08` 实现 `C-TODAY-003 FullEnergyRitual`
- [x] T058 [US2] [UI] 在 `ios/Vitora/Features/TodayFeature/TodaySignalCard.swift` 按 `WF-002` / `RF-002-02` 实现 `C-TODAY-004 TodaySignalCard`
- [x] T059 [US2] [UI] 在 `ios/Vitora/Features/TodayFeature/TodayAnalysisSheet.swift` 按 `IA-012` / `WF-004` / `RF-002-06` / `RF-004-01` 到 `RF-004-08` 实现 `C-TODAY-005 TodayAnalysisSheet`
- [x] T060 [US2] [UI] 在 `ios/Vitora/Features/TodayFeature/TodayView.swift` 按 `IA-010` / `WF-002` / `RF-002-02` 到 `RF-002-09` 实现 Today 主屏
- [x] T061 [US2] 在 `ios/Vitora/Features/TodayFeature/TodayViewModel.swift` 实现 Today view model 与 `IA-013` 低数据分支
- [x] T062 [US2] 在 `ios/Vitora/Resources/zh-Hans.lproj/Localizable.strings` 添加引用 `CL-DEFAULT` 与 `CL-LOW-DATA` 的 Today 与能量仪式字符串
- [x] T063 [US2] 在 `ios/Vitora/App/AppRouter.swift` 集成 Today 路由
- [x] T064 [US2] 运行 US2 单元与 UI 测试，并保存模拟器截图到 `ios/QA/Screenshots/US2/`

**检查点**：US2 在 seeded 领域状态与 app 路由后可独立验证。

## Phase 5: User Story 3 - A/B 当日意图与提醒偏好 (Priority: P1)

**目标**：用户能选择 A/B，形成持久的当日意图，管理提醒偏好，并使稍后的复盘路径可用。

**独立测试**：在分析 sheet 中选择 A 或 B 后，系统持久化意图，展示可编辑提醒偏好，并且不是一次性视觉反馈。

### Tests for User Story 3

- [x] T065 [P] [US3] 在 `ios/VitoraTests/DailyIntentionServiceTests.swift` 为 `REQ-007`、`DM-015`、`DM-016`、`DM-018` 添加 `DailyIntentionService` 测试
- [x] T066 [P] [US3] 在 `ios/VitoraTests/NotificationSchedulerTests.swift` 为 `NTC-*`、`NTS-*`、`NTT-*` 与提醒权限状态添加通知调度测试
- [x] T067 [P] [US3] 在 `ios/VitoraUITests/ABCommitmentUITests.swift` 为 `QAJ-004` 与 `IAC-QA-005` 添加 A/B UI 测试

### Implementation for User Story 3

- [x] T068 [US3] 在 `ios/Vitora/Domains/Today/DailyIntentionService.swift` 实现 `DS-006` 的 `DailyIntentionService`
- [x] T069 [US3] 在 `ios/Vitora/Core/Notifications/NotificationScheduler.swift` 实现已选意图的提醒调度桥接
- [x] T070 [US3] [UI] 在 `ios/Vitora/Features/TodayFeature/ABChoiceGroup.swift` 按 `WF-004` / `RF-004-01` 到 `RF-004-05` 实现 `C-TODAY-006 ABChoiceGroup`，并在 `ios/QA/figma-check.md` 记录 Figma 复查
- [x] T071 [US3] [UI] 在 `ios/Vitora/Features/TodayFeature/ABIntentSummary.swift` 按 `WF-004` / `RF-004-03` 到 `RF-004-06` 实现 `C-TODAY-007 ABIntentSummary`
- [x] T072 [US3] [UI] 在 `ios/Vitora/Features/SupportFeature/ReminderPreferencePanel.swift` 按 `IA-044` / `WF-011` / `RF-004-07` / `RF-010-05` 实现提醒偏好 sheet 入口
- [x] T073 [US3] 在 `ios/Vitora/Features/TodayFeature/TodayAnalysisSheet.swift` 集成 A/B 意图状态
- [x] T074 [US3] 在 `ios/Vitora/Core/Persistence/Repositories.swift` 持久化 `DailyIntention`、`ReminderPreference`、`ReminderInstance`
- [x] T075 [US3] 在 `ios/Vitora/Resources/zh-Hans.lproj/Localizable.strings` 添加无压力感的 A/B 与提醒字符串
- [x] T076 [US3] 运行 US3 单元与 UI 测试，并保存模拟器截图到 `ios/QA/Screenshots/US3/`

**检查点**：US3 能生成持久意图与提醒偏好，不要求复盘 UI 已完成。

## Phase 6: User Story 4 - 旧 Luna 首页与记录保存（pivot 前已完成，保留历史）

**历史目标**：用户能打开旧 Luna，用自然语言或快捷入口记录，确认解析含义，并保存给旧三主区使用的上下文。此阶段已完成，但用户面对命名和 UI 心智必须在 T102+ 迁移为 Vitora。

**历史独立测试**：即使 AI 不可用，旧 Luna 记录流也能保存已确认记录，并更新可见状态。后续实现不得把旧 Luna 用户文案作为当前目标。

### Tests for User Story 4

- [x] T077 [P] [US4] 在 `ios/VitoraTests/LunaHomeServiceTests.swift` 为 `REQ-008` 与 `DM-021` 添加 Luna 首页服务测试
- [x] T078 [P] [US4] 在 `ios/VitoraTests/LunaRecordServiceTests.swift` 为 `REQ-009`、`DM-008`、`DM-009`、`DM-010` 添加记录解析、确认、保存测试
- [x] T079 [P] [US4] 在 `ios/VitoraTests/LunaRecordFallbackTests.swift` 为 `AIC-005` 添加 AI 不可用时的记录保存测试
- [x] T080 [P] [US4] 在 `ios/VitoraUITests/LunaRecordUITests.swift` 为 `QAJ-005`、`IAC-QA-006`、`IAC-QA-007` 添加 Luna 记录 UI 测试

### Implementation for User Story 4

- [x] T081 [US4] 在 `ios/Vitora/Domains/Luna/LunaHomeService.swift` 实现 `DS-007` 的 `LunaHomeService`
- [x] T082 [US4] 在 `ios/Vitora/Domains/Luna/LunaRecordService.swift` 实现 `DS-008` 的 `LunaRecordService`
- [x] T083 [US4] 在 `ios/Vitora/Core/AI/AIContextBuilder.swift` 实现 `AIJ-003` 的 `AIContextBuilder` job 支持
- [x] T084 [US4] 在 `ios/Vitora/Core/AI/LunaOutputGuard.swift` 实现 `AOG-*` 确认守卫
- [x] T085 [US4] [UI] 在 `ios/Vitora/Features/LunaFeature/LunaPixelHomeCard.swift` 按 `WF-005` / `RF-005-01` 实现 `C-LUNA-001 LunaPixelHomeCard`，并在 `ios/QA/figma-check.md` 记录 Figma 复查
- [x] T086 [US4] [UI] 在 `ios/Vitora/Features/LunaFeature/LunaHomeComponents.swift` 按 `WF-005` / `RF-005-01` / `RF-007-02` 实现 `C-LUNA-002 LunaContextBubble` 与 `C-LUNA-003 LunaInputDock`
- [x] T087 [US4] [UI] 在 `ios/Vitora/Features/LunaFeature/LunaRecordSheet.swift` 按 `WF-006` / `RF-005-02` 到 `RF-005-08` 实现 `C-LUNA-004 LunaRecordSheet`
- [x] T088 [US4] [UI] 在 `ios/Vitora/Features/LunaFeature/RecordQuickTypeGrid.swift` 按 `WF-006` / `RF-005-03` 实现 `C-LUNA-005 RecordQuickTypeGrid`
- [x] T089 [US4] [UI] 在 `ios/Vitora/Features/LunaFeature/RecordParsePreview.swift` 按 `WF-006` / `RF-005-04` 到 `RF-005-06` 实现 `C-LUNA-006 RecordParsePreview`
- [x] T090 [US4] 在 `ios/Vitora/Features/LunaFeature/LunaViewModel.swift` 实现 Luna view model 与记录状态机
- [x] T091 [US4] 在 `ios/Vitora/Core/Persistence/Repositories.swift` 持久化 `LunaRecord`、`ParsedUnderstanding`、`NutritionEntry`
- [x] T092 [US4] 在 `ios/Vitora/Resources/zh-Hans.lproj/Localizable.strings` 添加引用 `CL-LUNA`、`CL-NUTRITION`、`CL-AI-UNAVAILABLE` 的 Luna 记录字符串
- [x] T093 [US4] 运行 US4 单元与 UI 测试，并保存模拟器截图到 `ios/QA/Screenshots/US4/`

**历史检查点**：US4 提供捕捉、确认、保存闭环。T102+ 只继承能力，不继承旧用户面对命名和旧 UI 结构。

## Phase 7: User Story 5 - 旧 Luna 沉浸聊天（pivot 前已完成，保留历史）

**历史目标**：用户能通过上滑或点击进入旧 Luna 沉浸聊天，舒适阅读与输入，并能无损返回。此交互心智已被正式 pivot 替换为 Vitora Assistant Surface + contextual sheet upgrade。

**历史独立测试**：旧 Luna 聊天进入沉浸状态后，键盘不会遮住输入或退出入口，记录流仍可到达。后续 T102+ 必须按 Vitora 新 IA 重构。

### Tests for User Story 5

- [x] T094 [P] [US5] 在 `ios/VitoraTests/LunaChatServiceTests.swift` 为 `REQ-010`、`DM-021`、`DM-022`、`DM-023` 添加 Luna chat 领域测试
- [x] T095 [P] [US5] 在 `ios/VitoraUITests/LunaImmersiveChatUITests.swift` 为 `QAJ-006`、`IAC-QA-008`、`IAC-M-004` 添加沉浸聊天 UI 测试

### Implementation for User Story 5

- [x] T096 [US5] 在 `ios/Vitora/Domains/Luna/LunaChatService.swift` 实现 `DS-009` 的 `LunaChatService`
- [x] T097 [US5] 在 `ios/Vitora/Core/AI/AIContextBuilder.swift` 实现 `AIJ-004` 的 `AIContextBuilder` job 支持
- [x] T098 [US5] [UI] 在 `ios/Vitora/Features/LunaFeature/LunaImmersiveChatView.swift` 按 `IA-022` / `WF-007` / `RF-006-02` 到 `RF-006-06` 实现 `C-LUNA-007 LunaImmersiveChatSurface`，并在 `ios/QA/figma-check.md` 记录 Figma 复查
- [x] T099 [US5] 在 `ios/Vitora/Features/LunaFeature/LunaView.swift` 添加上滑进入与返回手势处理
- [x] T100 [US5] 在 `ios/Vitora/Features/LunaFeature/LunaImmersiveChatView.swift` 添加键盘安全输入行为
- [x] T101 [US5] 运行 US5 UI 测试，并保存模拟器截图到 `ios/QA/Screenshots/US5/`

**历史检查点**：US5 只依赖旧 Luna，可在不完成 Cycle 或支撑页时验证。T102+ 不继续旧沉浸聊天作为目标。

## Phase 8: Pivot Baseline Tests（优先级：P1）

**目标**：先把新 IA / 新视觉系统的可执行验收测试立住。完成本阶段前，不开始 UI 重构。

**独立测试**：Today、Vitora、Cycle 三个 Tab 在 simulator 中呈现新 IA；从 Today/Cycle 唤醒 Vitora 使用 3/4 contextual sheet；旧 Luna 用户文案、旧 Today 记录区、旧 Cycle 日历首页不可见。

### Pivot 适配测试

- [x] T102 [P] [PIVOT] 在 `ios/VitoraUITests/PivotNavigationUITests.swift` 添加主导航测试：tab 文案为 Today / Vitora / Cycle，中央为 Vitora face CTA，引用 `IA-010`、`IA-020`、`IA-030`、`IAC-G-001`
- [x] T103 [P] [PIVOT] 在 `ios/VitoraUITests/TodayPivotUITests.swift` 添加 Today 新首页测试：状态卡、周期线轴、Vitora 今日建议存在，独立记录区不存在，引用 `WF-T-001`、`IAC-T-001`
- [x] T104 [P] [PIVOT] 在 `ios/VitoraUITests/VitoraAssistantSurfaceUITests.swift` 添加 Vitora Tab 测试：PixelVitoraHero、Vitora 知道、直接问、快捷上下文、input dock 存在，引用 `WF-V-001`、`IAC-V-001`
- [x] T105 [P] [PIVOT] 在 `ios/VitoraUITests/ContextualVitoraSheetUITests.swift` 添加对象级唤醒测试：Today 状态 chip 打开 3/4 sheet，保存后回 Today，引用 `WF-V-005`、`IAC-V-008`
- [x] T106 [P] [PIVOT] 在 `ios/VitoraUITests/CyclePivotUITests.swift` 添加 Cycle 新首页测试：阶段关系卡与能量动态卡存在，日历首页不存在，引用 `WF-C-001`、`IAC-CY-001`
- [x] T107 [P] [PIVOT] 在 `ios/VitoraUITests/AskableSurfaceUITests.swift` 添加单击详情、长按 context menu、图表 callout、TipKit fallback 验收，引用 `IAC-AS-001` 到 `IAC-AS-005`
- [x] T108 [P] [PIVOT] 在 `ios/VitoraUITests/VisualLanguageSmokeTests.swift` 添加关键 accessibility tree / screenshot smoke：Pixel Vitora、clear glass surfaces、aura backgrounds，并对照 `design-language-demo.md` 与 `assets/design_04/today_tab.png`、`assets/design_04/vitora_tab.png`、`assets/design_04/cycle_d.png` 记录验收，引用 `REQ-016`

**检查点**：T102-T108 通过后，pivot 目标有自动化验收保护，才进入设计系统实现。

## Phase 9: Design System Pivot（优先级：P1）

**目标**：先重建全局视觉基础，避免 Today / Vitora / Cycle 各自临时写样式。

- [x] T109 [PIVOT] 在 `ios/Vitora/Core/DesignSystem/VitoraTheme.swift` 将 token 映射更新为 `vt.bg.aura.*`、`vt.glass.g0` 到 `vt.glass.g4`、`vt.ip.*`、`vt.layout.tab.lowLift`，引用 `design-tokens.md` 与 `design-language-demo.md`
- [x] T110 [PIVOT] 在 `ios/Vitora/Core/DesignSystem/Surfaces.swift` 实现 `AuraBackground`、`GlassSurface`、`InputDockSurface`、`SupportGlassSurface`，引用 `C-APP-005`、`vt.glass.*`
- [x] T111 [PIVOT] 在 `ios/Vitora/Core/DesignSystem/PixelVitoraView.swift` 实现 Pixel Vitora 像素球、眼睛、idle/listening/thinking/confirming 状态，引用 `C-VITORA-001`
- [x] T112 [PIVOT] 在 `ios/Vitora/Core/DesignSystem/AskableSurface.swift` 实现单击详情、长按 context menu wrapper、TipKit hint hook，引用 `C-APP-007` 到 `C-APP-010`
- [x] T113 [PIVOT] 在 `ios/Vitora/Core/DesignSystem/VitoraInputDock.swift` 实现统一输入 dock、语音态、发送态、键盘避让，引用 `C-VITORA-007`

**检查点**：T109-T113 通过后，后续页面只能使用 Aura / Glass / Pixel Vitora 设计系统 primitives，不再继续旧 flat tokens。

## Phase 10: App Shell / Naming Pivot（优先级：P1）

**目标**：把路由、主 Tab、presentation 和用户面对命名迁移到 Vitora pivot 后状态。

- [x] T114 [PIVOT] 在 `ios/Vitora/App/AppRouter.swift` 更新主 tab 状态和 presentation：`Today / Vitora / Cycle`、`VitoraContextualSheet`、`VitoraFullContextMode`、Today/Cycle 二层 sheets，引用 `ia.md`
- [x] T115 [PIVOT] 在 `ios/Vitora/Resources/zh-Hans.lproj/Localizable.strings` 将用户面对 `Luna` 文案迁移为 `Vitora`，保留旧 code identifier 时添加 migration 注释，引用 `F-PRODUCT-002`
- [x] T116 [PIVOT] 在 `ios/VitoraUITests/LegacyLunaTextScanTests.swift` 添加用户面对文本扫描，允许 internal path/id 中临时出现 `luna`，但 UI 文案不得出现 `Luna`

**检查点**：T114-T116 通过后，app shell 不再把旧 Luna 或旧三主区作为用户面对目标。

## Phase 11: Today Pivot（优先级：P1）

**目标**：把 Today 收口为“现在状态 → 今日分析/身体要素 → Vitora 今日建议”。D-047 后首页固定综合 Energy Bowl + 周期线轴，完整实时预测移动到今日分析。

- [x] T117 [PIVOT] [UI] 在 `ios/Vitora/Features/TodayFeature/TodayStatusCard.swift` 实现新 `C-TODAY-003 TodayStatusCard` 和 `C-TODAY-004 RhythmCurve`，引用 `WF-T-001`
- [x] T118 [PIVOT] [UI] 在 `ios/Vitora/Features/TodayFeature/CalibrationChips.swift` 实现 `C-TODAY-005`，点击 chip 打开 `VitoraContextualSheet`，引用 `REQ-008`
- [x] T119 [PIVOT] [UI] 在 `ios/Vitora/Features/TodayFeature/BodyFactorTiles.swift` 实现 `C-TODAY-006` 与二层入口，引用 `WF-T-005`
- [x] T120 [PIVOT] [UI] 在 `ios/Vitora/Features/TodayFeature/VitoraDailySuggestionCard.swift` 实现 `C-TODAY-007`，接入现有 DailyIntentionService，引用 `REQ-007`
- [x] T121 [PIVOT] [UI] 在 `ios/Vitora/Features/TodayFeature/TodayStatusCard.swift` 实现分层 Energy Bowl、查看数据、实时预测、当前时间气泡，引用 `WF-T-002`
- [x] T122 [PIVOT] [UI] 在 `ios/Vitora/Features/TodayFeature/TodayCalendarSheet.swift` 实现 Today 顶部日历 sheet，引用 `WF-T-003`
- [x] T123 [PIVOT] [UI] 在 `ios/Vitora/Features/TodayFeature/TodayView.swift` 重组首页：移除独立记录区和旧常驻 orb，加入右上 Pixel Vitora decoration，并对照 `assets/design_04/today_tab.png` 记录偏差，引用 `WF-T-001`

**检查点**：T117-T123/T185 通过后，Today 必须可在 simulator 中独立 QA：无独立记录区、首页无实时预测图和校准 chips、可点击能量碗/查看数据、今日分析实时预测可读、可从对象唤醒 Vitora。

## Phase 12: Vitora Assistant Pivot（优先级：P1）

**目标**：把旧 Luna 首页 / 旧沉浸聊天重构成 AI-native Vitora assistant surface。

- [x] T124 [PIVOT] [UI] 在 `ios/Vitora/Features/VitoraFeature/VitoraAssistantSurfaceView.swift` 实现完整 Vitora Tab 默认态，并对照 `assets/design_04/vitora_tab.png` 记录偏差，引用 `WF-V-001`
- [x] T125 [PIVOT] [UI] 在 `ios/Vitora/Features/VitoraFeature/VitoraCompressedHeader.swift` 实现滚动压缩态，引用 `WF-V-002`
- [x] T126 [PIVOT] [UI] 在 `ios/Vitora/Features/VitoraFeature/DirectQuestionStrips.swift` 实现薄横向玻璃 cold-start 问题条，引用 `C-VITORA-005`
- [x] T127 [PIVOT] [UI] 在 `ios/Vitora/Features/VitoraFeature/QuickContextChips.swift` 实现 input 上方快捷上下文 icon chips，引用 `C-VITORA-006`
- [x] T128 [PIVOT] [UI] 在 `ios/Vitora/Features/VitoraFeature/VitoraContextualSheet.swift` 实现 3/4 contextual sheet、上滑升级、关闭回来源，引用 `WF-V-005`
- [x] T129 [PIVOT] [UI] 在 `ios/Vitora/Features/VitoraFeature/RichResponseCard.swift` 实现理解确认卡，接入现有记录/AI fallback 服务，引用 `WF-V-004`
- [x] T130 [PIVOT] 在 `ios/Vitora/Features/VitoraFeature/VitoraViewModel.swift` 组装 Today/Cycle context、direct questions、quick context、record confirm 状态

**检查点**：T124-T130 通过后，Vitora Tab 必须不是空聊天页，input dock 不被底部 CTA 遮挡，contextual sheet 可升级完整 Vitora。

## Phase 13: Cycle Pivot（优先级：P1）

**目标**：把 Cycle 收口为长期节律背景和能量动态，不再承担日历首页。

- [x] T131 [PIVOT] [UI] 在 `ios/Vitora/Features/CycleFeature/CurrentPhaseRelationCard.swift` 实现 `C-CYCLE-002` 和 `PhaseAxis`，引用 `WF-C-001`
- [x] T132 [PIVOT] [UI] 在 `ios/Vitora/Features/CycleFeature/EnergyDynamicsCard.swift` 实现日/周/月预览、Vitora narrative row，引用 `WF-C-001`
- [x] T133 [PIVOT] [UI] 在 `ios/Vitora/Features/CycleFeature/CurrentPhaseDetailSheet.swift` 实现透明解释型二层，引用 `WF-C-002`
- [x] T134 [PIVOT] [UI] 在 `ios/Vitora/Features/CycleFeature/EnergyDynamicsDetailSheet.swift` 实现趋势探索、图层、关键点、callout，引用 `WF-C-003`
- [x] T135 [PIVOT] [UI] 在 `ios/Vitora/Features/CycleFeature/CycleView.swift` 重组 Cycle 首页：删除首页日历预览，添加右上设置头像入口，并对照 `assets/design_04/cycle_d.png` 记录偏差，引用 `IAC-CY-001`

**检查点**：T131-T135 通过后，Cycle 首页只能有阶段关系和能量动态两大主组件，日历只能从 Today 顶部进入。

## Phase 14: Pivot QA Gate（优先级：P1）

**目标**：对已拆分完成的 Today / Vitora / Cycle pivot 做 simulator 级整体验收，确认可以进入 Evening Review。

- [x] T136 [PIVOT] 运行 pivot 单元/UI 测试，并保存输出到 `ios/QA/Reports/pivot-adaptation-tests.txt`
- [x] T137 [PIVOT] 使用 Simulator / iosef 逐页点击 Today、Vitora、Cycle、contextual sheet、Cycle 二层，并对照 `design-language-demo.md`、`assets/design_04/today_tab.png`、`assets/design_04/vitora_tab.png`、`assets/design_04/cycle_d.png` 保存截图到 `ios/QA/Screenshots/Pivot/`
- [x] T138 [PIVOT] 在 `ios/QA/pivot-adaptation-report.md` 汇总 IA、功能、视觉对齐结果、设计证据偏差和剩余偏差

**检查点**：T102-T138 全部通过后，才允许进入 Evening Review。

## Phase 15: 晚间复盘与学习信号（优先级：P1）

**目标**：基于新 Energy Ball review 和 Vitora 今日建议完成晚间复盘。

- [x] T139 [P] [REVIEW] 在 `ios/VitoraTests/EveningReviewServiceTests.swift` 为 `REQ-005`、`REQ-007`、`UF-007` 添加复盘可用、反馈、学习信号测试
- [x] T140 [P] [REVIEW] 在 `ios/VitoraUITests/EveningReviewUITests.swift` 为 `WF-R-001`、`IAC-QA-013` 添加复盘 UI 测试
- [x] T141 [REVIEW] 在 `ios/Vitora/Domains/Review/EveningReviewService.swift` 实现最小复盘服务
- [x] T142 [REVIEW] 在 `ios/Vitora/Domains/Review/VitoraLearningSignalService.swift` 实现学习信号派生
- [x] T143 [REVIEW] [UI] 在 `ios/Vitora/Features/VitoraFeature/EveningReviewSheet.swift` 实现 `WF-R-001` Energy Ball review
- [x] T144 [REVIEW] 在 `ios/Vitora/Core/Persistence/Repositories.swift` 持久化 `EveningReview` 与学习信号
- [x] T145 [REVIEW] 运行 Review 测试并保存截图到 `ios/QA/Screenshots/Review/`

## Phase 16: 支撑 / 信任 / 数据控制（优先级：P1）

- [x] T146 [P] [SUPPORT] 在 `ios/VitoraTests/SupportServiceTests.swift` 为 `REQ-014` 添加设置/支撑服务测试
- [x] T147 [P] [SUPPORT] 在 `ios/VitoraTests/NutritionServiceTests.swift` 为 `IA-043` 添加营养补给测试
- [x] T148 [P] [SUPPORT] 在 `ios/VitoraTests/DataControlServiceTests.swift` 为导出、账号移除、HealthKit 数据来源添加测试
- [x] T149 [P] [SUPPORT] 在 `ios/VitoraUITests/SettingsPanelUITests.swift` 为 `WF-S-001`、`IAC-S-001` 添加 UI 测试
- [x] T150 [SUPPORT] 在 `ios/Vitora/Domains/Support/SupportService.swift` 实现支撑入口状态
- [x] T151 [SUPPORT] 在 `ios/Vitora/Domains/Support/NutritionService.swift` 实现营养管理
- [x] T152 [SUPPORT] 在 `ios/Vitora/Domains/Support/DataExportService.swift` 实现数据导出
- [x] T153 [SUPPORT] 在 `ios/Vitora/Domains/Support/AccountRemovalService.swift` 实现账号移除
- [x] T154 [SUPPORT] [UI] 在 `ios/Vitora/Features/SupportFeature/SettingsPanel.swift` 实现 `C-SUPPORT-001`
- [x] T155 [SUPPORT] [UI] 在 `ios/Vitora/Features/SupportFeature/ProfilePanel.swift` 实现 `C-SUPPORT-002`
- [x] T156 [SUPPORT] [UI] 在 `ios/Vitora/Features/SupportFeature/DataSourcePanel.swift` 实现 `C-SUPPORT-003`
- [x] T157 [SUPPORT] [UI] 在 `ios/Vitora/Features/SupportFeature/NutritionManager.swift` 实现 `C-SUPPORT-004`
- [x] T158 [SUPPORT] [UI] 在 `ios/Vitora/Features/SupportFeature/ReminderPreferencePanel.swift` 实现 `C-SUPPORT-005`
- [x] T159 [SUPPORT] [UI] 在 `ios/Vitora/Features/SupportFeature/DataExportPanel.swift` 实现 `C-SUPPORT-006`
- [x] T160 [SUPPORT] [UI] 在 `ios/Vitora/Features/SupportFeature/LegalAccountPanel.swift` 实现 `C-SUPPORT-007`
- [x] T161 [SUPPORT] 运行 Support 测试并保存截图到 `ios/QA/Screenshots/Support/`

## Phase 17: 隐私 / AI / 合规加固（优先级：P1）

- [x] T162 [P] [TRUST] 在 `ios/VitoraTests/AIPrivacyBoundaryTests.swift` 添加 AI context 最小化测试
- [x] T163 [P] [TRUST] 在 `ios/VitoraTests/PrivacyLoggingTests.swift` 添加日志隐私测试
- [x] T164 [P] [TRUST] 在 `ios/VitoraUITests/ComplianceSurfaceUITests.swift` 添加合规标签存在性测试
- [x] T165 [P] [TRUST] 在 `ios/VitoraUITests/AIUnavailableUITests.swift` 添加 AI 不可用 fallback 测试
- [x] T166 [TRUST] 在 `ios/Vitora/Core/AI/VitoraOutputGuard.swift` 或现有 guard 中完成 Vitora 输出合规检查命名/封装
- [x] T167 [TRUST] 在 `ios/Vitora/Core/Privacy/AppCapabilityState.swift` 补齐低数据、AI 不可用、权限拒绝的用户反馈映射
- [x] T168 [TRUST] 在 `ios/QA/Scripts/restricted-expression-scan.sh` 添加本地化字符串限制表达扫描
- [x] T169 [TRUST] 运行 Trust 测试并保存报告到 `ios/QA/Reports/trust-hardening.txt`

## Phase 18: 最终 QA / 打磨

- [x] T170 [P] 在 `ios/VitoraUITests/AccessibilityUITests.swift` 为 Today、Vitora、Cycle、contextual sheet、Support 添加 VoiceOver / Dynamic Type / Reduce Motion 检查
- [x] T171 [P] 在 `ios/VitoraTests/PerformanceSmokeTests.swift` 添加启动、tab 切换、sheet、Energy Reveal 性能 smoke tests
- [x] T172 [P] 在 `ios/QA/manual-qa.md` 写入 `IAC-QA-001` 到 `IAC-QA-015` 的人工 QA checklist
- [x] T173 使用 Simulator / iosef 逐项执行 quickstart，并更新 `ios/QA/quickstart-results.md`
- [x] T174 运行 `xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17' test`，保存输出到 `ios/QA/Reports/xcodebuild-test.txt`
- [x] T175 捕获 onboarding、Today、Energy Reveal、Vitora、contextual sheet、Cycle、Support、Review 最终截图到 `ios/QA/Screenshots/Final/`
- [x] T176 验证反向验收 `IAC-N-001` 到 `IAC-N-010` 均不出现，并保存报告到 `ios/QA/Reports/reverse-acceptance-scan.txt`
- [x] T177 在 `ios/README.md` 更新实现完成说明、剩余 migration debt 和 QA 结果

## 依赖与执行顺序

- `T001-T101` 已完成，保留。
- `T102-T108` 建立 pivot 自动化验收。
- `T109-T113` 先完成 Design System Pivot。
- `T114-T116` 完成 App Shell / Naming Pivot。
- `T117-T123` 完成 Today Pivot。
- `T124-T130` 完成 Vitora Assistant Pivot。
- `T131-T135` 完成 Cycle Pivot。
- `T136-T138` 是 pivot QA gate，全部通过后才允许进入 Review。
- `T139-T145` Evening Review 依赖 pivot adaptation 和已存在当日意图。
- `T146-T161` Support 可在 Review 后或与 Review 后半并行，但不能先于 pivot。
- `T162-T169` Trust hardening 依赖主要表面存在。
- `T170-T177` 最终 QA 依赖所有 P0 表面完成。

## 来源覆盖矩阵

| 来源 | 任务覆盖 |
| --- | --- |
| `REQ-001` to `REQ-003` | 已完成 T037-T049 |
| `REQ-004` to `REQ-006` | pivot 前已完成 T050-T064 + 适配 T117-T123 |
| `REQ-007` | pivot 前已完成 T065-T076 + 适配 T120 + 复盘 T139-T145 |
| `REQ-008` to `REQ-011` | pivot 前已完成 T077-T101 + 适配 T124-T130 |
| `REQ-012` | 适配 T131-T135 |
| `REQ-013` | T122 + pivot QA T137 + final QA T175 |
| `REQ-014` | T135 + T146/T150/T154-T160 |
| `REQ-015` | T162-T169 |
| `REQ-016` | T109-T113 + T108 + 最终 QA |
| `UF-000` to `UF-010` | T102-T177 |
| `IA-010` to `IA-046` | T114-T160 |
| `WF-T-*`, `WF-V-*`, `WF-C-*`, `WF-S-*`, `WF-R-*` | T117-T145, T154-T160 |
| `C-*`, `vt.*`, `IAC-*` | T102-T177 |

## 验证清单

- 当前 `T001-T177` 已完成；没有剩余 P0 implementation task。
- `T102-T138` 已按 Phase 8 到 Phase 14 分段完成 IA / Design Pivot Adaptation。
- `T139-T177` 已完成 Review、Support、Trust 和最终 QA。
- 所有新 UI 任务引用 `WF-*`、`C-*`、`vt.*` 或 `IAC-*`。
- 用户面对 Vitora，不新增 Luna 产品文案。
- Today 没有独立记录区。
- Cycle 首页没有日历预览。
- Vitora Tab 不是空聊天页。
- Pixel Vitora、clear glass、aura background 被实现和验收。
- Today / Vitora / Cycle 首层 UI 必须对照 `assets/design_04/` 设计证据截图记录偏差。

## Post-P0 Layout Refinements · 2026-05-16

- [x] T178 [P] [D-043] 更新 004 规格与决策记录，明确 Vitora Dock 是 Today / Vitora / Cycle 全局 assistant layer。
- [x] T179 [P] [D-043/D-046] 重构 `VitoraInputDock` 为纯输入组件：语音/键盘、文字或内联语音条、发送；移除输入区周期小花和内部 `+`。
- [x] T180 [P] [D-043] 在 App Shell 中新增全局 Vitora Dock，并让 `VitoraViewModel` 在三个主 Tab 间共享。
- [x] T181 [P] [D-043] 更新 UI tests，覆盖全局输入、跨 Tab 发送、语音内联态和 XXXL 字体避让。
- [x] T182 [P] [D-044] 放大 Today 能量碗数字，移除 `今天` / `监测到` 说明字，并把首屏模式切换改为综合/睡眠/周期三项碗底光源托盘。
- [x] T183 [P] [D-045] 将全局 Dock 上排改为左侧 Tab + 右侧 `记录` 快捷键，并让点击 `AI管家` 自动聚焦全局输入。
- [x] T184 [P] [D-046] 收敛全局 Dock：Today / Cycle 隐藏输入条，右侧记录改为独立圆形 `+`，AI 管家输入条移除内部 `+` 并强化发送按钮。
- [x] T185 [P] [D-047] 收敛 Today 首页为综合能量碗 + 碗下周期线轴 + 今日建议；移除首页三模式切换、实时预测图和校准 chips；将综合实时预测移入 `今日分析`，并把 Dock 修正为三 Tab 同胶囊 + 右侧独立圆形 `+`。
- [x] T186 [P] [D-048] 修正 Today 能量数字为单层高对比，首页数据小标签只进入今日分析；周期线轴改为无背景阶段色平滑曲线；全局 Dock 改为 safe-area 承载并在 sheet 展示时隐藏，contextual sheet 使用稳定 title 和本地输入。
- [x] T187 [P] [D-049] 调整 Today 首页为 `68%` 下方状态词 + 宽口能量碗 + 碗底三阶段周期圆弧；把 Vitora 今日建议改为大字号身体翻译、两条组合建议、`一件提醒` 和 icon `换一换` 本地循环。
- [x] T188 [P] [D-050] 修正 Today 周期圆弧为中间下沉并上移到碗底光晕；将 `查看数据` 放到状态词同排；稳定 AI 管家进入态和上拉聊天聚焦态；统一周期/睡眠/营养上下文卡模板。
- [x] T189 [P] [D-051] 将 Today 能量碗升级为屏幕顶部水滴入碗、水位按能量积累的动效；把周期圆弧嵌入碗底白色光晕；将 Cycle 首页升级为 `周期回顾`、等距花田、三件事总结、能量动态和三张节律洞察卡，并更新 UI tests。
- [x] T190 [P] [D-052] 按花园手册 MVP 文档收敛轻闭环：Today 周期圆弧下移到碗外一个字间距；新增花园手册/成长反馈；AI 管家承接晚间复盘种子选择；Cycle 改为 `30 天成长册`，不保留花田地图入口。此方向已被 D-053/D-055 覆盖。
- [x] T191 [P] [D-053] 移除 Today 花园手册、早晨成长反馈、Cycle `30 天成长册` 和花园化种子入口，回到 Today 建议、AI 管家复盘和 Cycle 长期节律三条主路径。
- [x] T192 [P] [D-055] 实现睡眠种子实验层：晚间复盘反馈后选 3 类种子；Today 建议卡解释昨晚种子状态、生理原因和今日行动；AI 管家承接种子解释；Cycle 增加低权重 `本周期花架证据`，并保持无花田地图、无成长册进度、无打卡任务。
- [x] T193 [P] [D-057] 将 AI 管家输入快捷栏与三 Tab 主切换栏上下分层；点击 `AI管家` 只切页不自动聚焦，点击输入栏本身才聚焦；发送中显示 `Vitora 正在整理...` 状态轨。
- [x] T194 [P] [D-058] 新增真实花种素材档案和花园轻证据层：10 种真实花种目录、分阶段资产命名、`SleepSeedCard` 花种字段、Today 进度条、复盘方向选种、早安/晚安卡和 Cycle 花架证据统一读取真实花种。
- [x] T195 [P] [D-059] 将 Today 建议卡顶部改为 `开放态度` 分段进度和花种阶段；移除 `组合推荐/专家建议组合`；默认组合改为 `休息 + 补剂`，`换一换` 放在组合标题旁；`一键提醒` 改为金黄色，并让提醒 Sheet 支持上下滑动调时间和单选提醒。
- [x] T196 [P] [D-060] 将 Today 建议卡标题改为 `今日提醒`，左侧生成低像素早上太阳；推荐组合改为嵌入式大卡，左右竖向行动卡中间加号；数据来源改为动态指标胶囊并移除“监测到”；去掉行动卡勾选控件；提醒 Sheet 顶部展示白雏菊进度条。
- [x] T197 [P] [D-061] 优化 Energy Bowl：水位从 0 映射到分数目标并支持点击增长反馈；当前周期圆弧段加粗着色；能量数字改为黄体期金色低像素密集格和右下对角 `能量低 / 查看数据`；点击碗和点击数据入口统一打开新版 `今日分析`，展示 `黄体期 Day 18`、球形分数报告、关键监测项、综合实时预测和今日推荐。
- [x] T198 [P] [D-062] 将 Today 建议组件改为 `智能监测`：开放状态归属身体翻译器；去掉动态睡眠胶囊、`推荐组合` 和重复 `休息+补剂` 标题；方案改为置顶横向长条卡，集中展示主题和早/中/晚推送时间，行动一行长条用大号 `+` 连接，`换一换` 与金黄色 `一键提醒` 放在卡片下方。
- [x] T199 [P] [D-063] 将 Onboarding 改为两页：注册进入页只处理 Apple / 微信 / QQ / 本地体验和协议；聊天式补充页合并关注方向、恢复方式、周期清晰度和可选设备绑定；点击 `进入 Vitora` 后直接进入 Today。
- [x] T200 [P] [D-064] 将 Today 下滑后的 `智能监测` 内部改为扑克牌式大圆角内嵌卡：移除首页开放状态和白雏菊进度；顶部大标题 `身体翻译器` 占约 1.5/4；下方左侧 `今日推送` 两张竖向行动卡，右侧 `周期建议` 长方形卡；保留 `换一换` 和金黄色 `一键提醒`，不移动能量碗和 Today 页面顺序。
- [x] T201 [P] [D-065] 更新 004 规格、decision log 和 Pixel IP change-log，正式记录 Today 首页蓝晶 Pixel Egg、展开主题弧和 `TodayInsightPanel` 改版。
- [x] T202 [P] [D-065] 在 `ios/Vitora/Core/DesignSystem/PixelEggView.swift` 增加蓝晶混合材质：半透明蓝白外壳、像素晶格、水感颗粒和白/蓝像素眼。
- [x] T203 [P] [D-065] 在 `ios/Vitora/Features/TodayFeature/TodayStatusCard.swift` 将首页模式收口为 `TodayInsightTopic.energy/sleep/period/nutrition`，移除顶部黑色三格 `TopModeSelector`，实现点击小圆球展开/收起半圆弧主题。
- [x] T204 [P] [D-065] 在 `ios/Vitora/Features/TodayFeature/VitoraDailySuggestionCard.swift` 新增 `TodayInsightPanel`，替换 Today 首页旧 `VitoraDailySuggestionCard` 位置，支持今日能量原因/建议/提醒、睡眠、经期和营养详情。
- [x] T205 [P] [D-065] 构建并在 Simulator 保存 Today 默认态、弧展开态、今日能量详情、睡眠详情和营养记录入口截图；反向确认无 Luna、无打卡/完成率/红点、无第四主 Tab。
- [x] T206 [P] [D-066] 更新 004 规格与 decision log，明确主题圆圈逐个展开信息条，独立加号只做快捷记录。
- [x] T207 [P] [D-066] 在 `ios/Vitora/Features/TodayFeature/TodayStatusCard.swift` 将主题入口改为四个默认可见收起圆圈；点击圆圈展开对应信息条，点击其他圆圈切换，点击同一圆圈收起。
- [x] T208 [P] [D-066] 在 Today 首页新增独立快捷记录加号，点击直接打开 Vitora contextual sheet，展开主题时记录来源带主题，否则为 `快捷记录`。
- [x] T209 [P] [D-066] 将 `68/100 查看分析` 移到蓝晶蛋下方居中；将 `CycleSmileArc` 调整为图3样式粗渐变经期条，中心白圆 + 黄色阶段标记。
- [x] T210 [P] [D-066] 构建并保存默认态、主题圆圈展开态、经期条和快捷记录 sheet 截图；反向确认不出现右侧黑色 `X`。
- [x] T211 [P] [D-067] 更新 004 规格与 decision log，明确 Cycle 主回顾卡改为淡色物理折页式 `本周 / 趋势 / 经历 / 监测` 四 tab。
- [x] T212 [P] [D-067] 在 `ios/Vitora/Features/CycleFeature/CycleView.swift` 将 `CycleReviewInsightCard` 替换为四个淡色折页 tab；active tab 与主卡融合，inactive tabs 降饱和露出标签。
- [x] T213 [P] [D-067] 实现四个 tab 内容：本周复盘、趋势对比、经历 pattern、监测时间线；保留 Cycle 下方能量动态、洞察卡和花架证据。
- [x] T214 [P] [D-067] 更新 Cycle UI tests 和 Accessibility tests，覆盖 `cycle.review.tab.experience`、`cycle.review.tab.monitoring` 与 44pt 触控。
- [x] T215 [P] [D-067] 构建并保存 Cycle 本周、趋势、经历、监测四张 active 截图；反向确认无日历首页、无打卡/完成率/红点、无 Luna。
- [ ] T216 [P] [D-069] 更新 004 规格与 decision log，明确 Today 首屏合并为统一圆弧轨道，并暂停 D-068 快捷记录页继续实现。
- [ ] T217 [P] [D-069] 在 `ios/Vitora/Features/TodayFeature/TodayStatusCard.swift` 新增统一圆弧轨道，替代 `TodayTopicOrbitArc` + 独立快捷加号，节点固定为 `能量 / 睡眠 / 经期 / 营养 / +记录`。
- [ ] T218 [P] [D-069] 从 `ios/Vitora/Features/TodayFeature/TodayView.swift` 移除独立 `CycleSmileArc` section，将底部经期能量条并入 Today 主视觉轨道。
- [ ] T219 [P] [D-069] 更新 Today UI tests 与 accessibility ids，覆盖 `today.unifiedOrbit.energy/sleep/period/nutrition/quickRecord/cycleArc`，并反向确认不再出现 `today.cycle.smile.arc`。
- [ ] T220 [P] [D-069] 构建并保存 Today 默认态、能量展开、睡眠展开、经期展开、营养展开和快捷记录 sheet 截图；反向确认无黑色 `X`、无独立下方周期条、无 Playwright/web 依赖、无 Luna。
- [x] T221 [P] [D-068] 更新 facts、wireframes、components、interaction acceptance 和 tasks，明确快捷记录页由 Dock 右侧 `+` 与 Today 统一轨道 `+记录` 双入口打开，并忽略最后一个记账键盘视频/第 5 个参考。
- [x] T222 [P] [D-068] 在 `ios/Vitora/Features/VitoraFeature/VitoraContextualSheet.swift` 将记录页替换为 `手动记录 / AI记录` 双模式，保留来源上下文、关闭回来源和 sheet 展示时隐藏全局 Dock。
- [x] T223 [P] [D-068] 实现手动记录 `症状 / 情绪 / 月经 / 营养 / 更多` sub-tab、分类色彩、圆形选项卡、强度/剂量详情面板、`再记 / 完成` 底部按钮和选中态加深过渡。
- [x] T224 [P] [D-068] 新增 `VitoraQuickRecordParser` 本地规则解析和结构化预览，覆盖 `头痛/头疼`、程度词、B6 与镁剂量，不接真实模型、不新增 schema。
- [x] T225 [P] [D-068] 更新 unit/UI tests：parser 三条规则、`global.record.quick`、`today.unifiedOrbit.quickRecord`、手动 sub-tab、AI 解析预览和完成/再记路径。
- [x] T226 [P] [D-068] 构建并保存 `手动-症状`、`手动-情绪`、`手动-月经`、`手动-营养`、`AI解析结果` 五张截图；反向确认无 Luna、无打卡/完成率/红点、无购买引导、无医学诊断、无完成后时间线页面。
- [ ] T227 [P] [D-070] 更新 facts、wireframes、components、interaction acceptance、tasks 和 decision log，明确 Today 首屏右侧只有一条单半圆弧轨道，展开态是浅白弧形信息条而不是直线胶囊。
- [ ] T228 [P] [D-070] 在 `ios/Vitora/Features/TodayFeature/TodayStatusCard.swift` 将轨道几何收口为同一条椭圆半圆路径，五个节点沿路径紧贴排列且默认不显示旁侧文字。
- [ ] T229 [P] [D-070] 移除选中态旋转 Capsule，改为 Canvas 局部加粗浅白渐变弧段，icon 嵌在弧段起点，数值沿弧线切线方向展示。
- [ ] T230 [P] [D-070] 去掉蛋下方独立经期能量条和 `排卵期 / 黄体期 D18 / 月经期` 标签组，保留经期主题和下方 `TodayInsightPanel`。
- [ ] T231 [P] [D-070] 更新 Today UI tests，构建并保存默认态、能量展开、睡眠展开、经期展开、营养展开和快捷记录 sheet 截图；反向确认无直线胶囊、无斜向圆角矩形、无底部独立周期条、无节点旁文字、无 Luna。
- [x] T232 [P] [D-072] 更新 facts、wireframes、components、interaction acceptance、tasks 和 decision log，明确 Today 顶部压缩日期能量卡与文具周期日历浮层。
- [x] T233 [P] [D-072] 在 `ios/Vitora/Features/TodayFeature/TodayView.swift` 压缩 `TodayHeaderDailyEnergyCard`，仅保留星期、日期、`黄体 D18`、横向能量条和数值。
- [x] T234 [P] [D-072] 调整 `CalendarDrawerOverlay` 为左侧约 3/4 宽浮层，右侧露出暖色虚化 Today 背景且背景不可交互。
- [x] T235 [P] [D-072] 重做 `ios/Vitora/Features/TodayFeature/TodayCalendarSheet.swift` 为文具日历：极简顶部、阶段图例、英文周标题、阶段色虚线月历、浅粉撕边便签和 2x2 木制记忆箱。
- [x] T236 [P] [D-072] 构建并保存 Today 默认态顶部卡片、周期日历抽屉、月切换后状态和更多菜单截图；反向确认 Cycle 首页无日历、无 Luna、无打卡/完成率/红点、无第四主 Tab。
- [x] T237 [P] [D-073] 更新 facts、wireframes、components、interaction acceptance、cycle-page spec、tasks 和 decision log，正式记录 Cycle 报告卡三 tab 与 1536 展示图方向。
- [x] T238 [P] [D-073] 新增 `QA/Screenshots/VitoraReport/vitora-report-3up.html`，用 HTML/CSS/SVG 渲染 `本周 / 趋势（对比） / 近期` 三张并排报告卡，不引入图表库。
- [x] T239 [P] [D-073] 输出并校验 `QA/Screenshots/VitoraReport/vitora-report-3up-1536x1024.png`，尺寸必须为 `1536×1024`，反向确认无手机壳、本子、厚重拟物或 AI 乱码。
- [x] T240 [P] [D-073] 在 `ios/Vitora/Features/CycleFeature/CycleView.swift` 将 `CycleReviewInsightCard` 收口为 `本周 / 趋势（对比） / 近期` 三个文件夹 tab，iPhone 内使用叠层单卡展示。
- [x] T241 [P] [D-073] 实现三页报告内容：本周柱状复盘、趋势月度对比进度条、近期能量折线与下一步按钮，并移除旧 `经历 / 监测` 首页一级 tab。
- [x] T242 [P] [D-073] 更新 `CyclePivotUITests` 和 `AccessibilityUITests`，覆盖三个 tab、内容切换、旧 experience/monitoring 不再出现和 44pt 触控。
- [ ] T243 [P] [D-073] 构建并保存 Cycle 默认态、趋势态、近期态截图；反向确认 Cycle 首页不是日历、无 Luna、无打卡/完成率/红点、无复杂医疗 dashboard、无第四主 Tab。
- [x] T244 [P] [D-074] 更新 facts、wireframes、components、interaction acceptance、tasks 和 decision log，正式记录快捷记录误触修复、删除金额数字键盘、首页花组件和小日历入口。
- [x] T245 [P] [D-074] 在 `ios/Vitora/App/AppRouter.swift` 为 `VitoraContextualSheet` 增加全屏透明 hit-test backdrop，点空白只关闭 sheet，不透传到 Today 日历或 Dock。
- [x] T246 [P] [D-074] 在 `ios/Vitora/Features/VitoraFeature/VitoraContextualSheet.swift` 增加 44pt 关闭按钮和下拉关闭；手动模式删除金额输入、数字键盘和金额提交依赖，仅保留分类、字段、图片/拍照/语音入口，默认分类即可完成。
- [x] T247 [P] [D-074] 在 `ios/Vitora/Features/TodayFeature/EggCompoundView.swift` 新增 SwiftUI/Canvas `FlowerEnergyBloomView` 并替换首页主蛋，保留 `egg.compound.mascot` id、主数字、CTA 和右侧维度切换。
- [x] T248 [P] [D-074] 在 `ios/Vitora/Features/TodayFeature/TodayView.swift` 将 `TodayHeaderDailyEnergyCard` 收口为 38-44pt 小日历 icon，并在日历抽屉开关动画期间禁止后方 hit testing。
- [ ] T249 [P] [D-074] 构建并保存 Today 默认态、快捷记录手动页、AI 页和日历抽屉截图；点击关闭、空白、下拉、分类、更多、媒体入口、再记、完成、AI 示例/发送，反向确认无误触弹窗、无金额数字键盘、无 Luna/打卡/红点/第四 Tab。
- [x] T250 [P] [D-075] 更新 facts、wireframes、components、interaction acceptance、tasks 和 decision log，正式记录 Today 记录反馈条、首屏花区压缩和快捷记录健康大纲。
- [x] T251 [P] [D-075] 在 `ios/Vitora/App/AppEnvironment.swift` 新增运行态 `RecentRecordFeedback`，并让快捷记录完成后关闭 sheet、回写记录摘要和温馨提示。
- [x] T252 [P] [D-075] 在 `ios/Vitora/Features/VitoraFeature/VitoraContextualSheet.swift` 为手动记账和 AI 记录增加 `vitora.record.note.input` 留言条，完成后生成生活方式提示，不新增持久化 schema。
- [x] T253 [P] [D-075] 在 `ios/Vitora/Features/TodayFeature/TodayView.swift` 和 `TodayVitoraMessageCard.swift` 上移 `today.record.feedback`，优先展示最近记录反馈；无记录时展示当前 Vitora 提示。
- [x] T254 [P] [D-075/D-079] 在 `ios/Vitora/Features/TodayFeature/EggCompoundView.swift` 压缩花组件和右侧胶囊维度切换到首屏上方约 1/3，并收短红色虚线避免遮挡反馈条；D-079 后不再保留花下独立主分数。
- [x] T254A [P] [D-075] 在 `ios/Vitora/Features/VitoraFeature/VitoraContextualSheet.swift` 将手动页从 `支出 / 收入 / 转账` 改为 `是经期 / 否经期` + 健康大纲；默认 5 个词条，点击大纲或 `更多` 展开支线，删除财务分类/金额心智。
- [x] T255 [P] [D-076] 更新 facts、wireframes、components、interaction acceptance、cycle-page spec、tasks 和 decision log，正式记录 Cycle 顶部 SwiftUI 花之地图模块。
- [x] T256 [P] [D-076] 在 `ios/Vitora/Features/CycleFeature/CycleView.swift` 新增 `FlowerMapView`、`FlowerMapCity`、`FlowerMapTile` 和 `FlowerKind`，用二维字符串数组绘制深圳不规则菱形地图。
- [x] T257 [P] [D-076] 实现 `种下今天的花`、空地种花、已种花详情、问号说明和城市路线节点交互；种花动效使用 SwiftUI scale + pulse，不引入 RN/Expo、图片素材或地图 SVG。
- [ ] T258 [P] [D-075/D-076] 构建并保存 Today 默认态、Today 记录反馈态、快捷记录手动页、快捷记录 AI 页、Cycle 花之地图默认态、种花后状态和花详情浮层截图；反向确认无第四 Tab、无打卡/完成率/红点、无诊断/购买引导、无后方误触。
- [x] T259 [P] [D-077] 更新 facts、wireframes、components、interaction acceptance、tasks 和 decision log，正式记录 Today 花朵首页与 Aura 背景加浓规则。
- [x] T260 [P] [D-077] 在 `ios/Vitora/Core/DesignSystem/Surfaces.swift` 加浓 Today 左上粉橘和右下蓝绿 Aura，移除底部灰感，增加中部凝态玻璃和底部霜态玻璃层次。
- [x] T261 [P] [D-077] 在 `ios/Vitora/Features/TodayFeature/EggCompoundView.swift` 扩展 `FlowerEnergyBloomView`：三节点时间轴、80% 能量碗、黄体期标签、成长提示和同品种双朵共生气泡。
- [ ] T262 [P] [D-077] 构建并保存 Today 默认态、花朵点击反馈态和向下滚动到底背景截图；反向确认无蛋主视觉、无打卡/完成率/红点、无 Luna、无灰底。
- [x] T263 [P] [D-078] 更新 facts、wireframes、components、interaction acceptance、tasks 和 decision log，正式记录 Today 花朵主视觉阈值、默认 68% 种子苗状态和动效修正规则。
- [x] T264 [P] [D-078] 在 `ios/Vitora/Features/TodayFeature/EggCompoundView.swift` 将 `FlowerEnergyBloomView` 改为 `energyProgress = 0.68` 数据驱动：68% 只进入水桶，未达 80% 显示种子苗，移除整体呼吸缩放，保留慢速轻摆和点击反馈。
- [ ] T265 [P] [D-078] 构建并保存 `Today-68-seedling-default`、点击反馈态、80% 开花 mock 和 100% 共生 mock 截图；反向确认无 68% 开花、无 80% 当前值、无堆叠、无误触弹窗。
- [x] T266 [P] [D-079] 更新 facts、wireframes、components、interaction acceptance、tasks 和 decision log，正式记录移除 Today 花下独立 `68/100 查看分析`。
- [ ] T267 [P] [D-079] 构建并保存 Today 默认态截图，确认花组件下方不再出现 `68/100 查看分析`，右侧维度和下方信息卡仍可用。
- [x] T268 [P] [D-080] 更新 facts、wireframes、components、interaction acceptance、tasks 和 decision log，正式记录 Today 花朵主视觉宽画布、图 2 布局比例目标和右侧胶囊分层规则。
- [x] T269 [P] [D-080] 在 `ios/Vitora/Features/TodayFeature/EggCompoundView.swift` 将 `FlowerEnergyBloomView` 改为接近整屏宽 hero band，重算直线时间线、能量水桶、阈值提示、种子苗和读数层级，并把右侧维度胶囊移出水桶覆盖区。
- [x] T270 [P] [D-080] 构建并保存 `Today-68-seedling-wide-default`、80% 开花 mock、100% 共生 mock 截图；反向确认无堆叠、无胶囊覆盖水桶、无独立 `68/100 查看分析`。
- [x] T271 [P] [D-081] 更新 facts、wireframes、components、interaction acceptance、tasks 和 decision log，正式记录 Today 花朵主视觉疏散排版修正。
- [x] T272 [P] [D-081] 在 `ios/Vitora/Features/TodayFeature/EggCompoundView.swift` 收敛水桶宽度、拉开前天/昨天/今天节点、上移阈值提示并缩小上移右侧维度胶囊，避免图 1 式挤压。
- [x] T273 [P] [D-081] 构建并保存 `Today-68-seedling-spacious-default` 截图；反向确认水桶不横跨历史节点、右侧胶囊不压红线、阈值提示/种子苗/今天标签/读数不堆叠。
- [x] T274 [P] [D-082] 更新 wireframes、components、interaction acceptance、tasks 和 decision log，正式记录移除 Today 反馈条右侧灰色圆形记录/提醒按钮。
- [x] T275 [P] [D-082] 构建并保存 Today 默认态截图，反向确认 `记录饮食 / 补水提醒 / 查看记录 / 继续补充` 等后置圆形按钮不再出现，主反馈条、右侧维度切换和全局快捷记录仍可用。
- [x] T276 [P] [D-083] 更新 facts、wireframes、components、interaction acceptance、tasks 和 decision log，正式记录 Today 折叠态移除维度 chips，并用微缩花盆能量状态替换 compact 小蛋。
- [ ] T277 [P] [D-083] 构建并保存 Today 折叠态截图；反向确认无 `今日 / 睡眠 / 经期 / 营养` 折叠 chips、无 compact Pixel Egg，顶部只显示小日历和微缩花盆 `68/100`。
- [x] T278 [P] [D-085] 更新 facts、wireframes、components、interaction acceptance、tasks 和 decision log，正式记录 Dock `+` 点按手动记录、长按语音记录，以及 AI 记录内 `语音 / 打字` 二级切换。
- [x] T279 [P] [D-085] 在 `ios/Vitora/App/AppEnvironment.swift` 和 `ios/Vitora/App/AppRouter.swift` 新增 `QuickRecordLaunchMode.manual/voice/text`，保持 `global.record.quick` 点按进入手动记录，长按触发 haptic 和语音浮岛后进入 `AI记录 > 语音`，并提供无障碍 `语音记录 / 打字记录` 辅助操作。
- [x] T280 [P] [D-085] 在 `ios/Vitora/Features/VitoraFeature/VitoraContextualSheet.swift` 为 AI 记录新增 `VitoraAIInputMode.voice/text`、语音面板、打字面板、权限拒绝降级打字和本地 parser 解析，不恢复首页常驻输入框或发送按钮。
- [x] T281 [P] [D-085] 更新 `ios/VitoraUITests/ContextualVitoraSheetUITests.swift` 覆盖点按手动、长按语音、AI 打字解析和健康大纲记录路径；主 app build 已通过。
- [x] T282 [P] [D-087] 更新 facts、wireframes、components、interaction acceptance、tasks 和 decision log，正式记录底部 Tab 栏改为一体式白色凹槽 Dock。
- [x] T283 [P] [D-087] 在 `ios/Vitora/App/AppRouter.swift` 将 `GlobalVitoraDock` 从居中玻璃胶囊 + 右侧独立 `+` 改为左右 `今日 / 周期` + 中心凹槽悬浮圆形 `+`，保留 `global.record.quick` 点按手动和长按语音。
- [x] T284 [P] [D-087] 构建并在模拟器检查 Today 底部凹槽 Dock、Tab 切换、点按/长按 `+`、sheet 展示隐藏 Dock 和无底部输入框/发送按钮残留。
- [x] T285 [P] [D-088] 更新 facts、wireframes、components、interaction acceptance、tasks 和 decision log，正式记录底部凹槽 Dock 下移镶嵌与中心 `+` 蓝绿色霜态玻璃微调。
- [x] T286 [P] [D-088] 在 `ios/Vitora/App/AppRouter.swift` 将 `GlobalVitoraDock` 整体下压贴近 bottom safe area，增加轻霜态底部嵌入底座，并将中心 `+` 从蓝紫实心球改为蓝绿色半透明霜态玻璃按钮。
- [x] T287 [P] [D-088] 构建并保存 Today / Cycle 底部 Dock 截图，确认 Dock 镶嵌感、中心 `+` 颜色和点击/长按快捷记录语义不变。
- [x] T288 [P] [D-090] 更新 facts、wireframes、components、interaction acceptance、tasks 和 decision log，正式记录底部 Dock 尺寸收窄、中心 `+` 进一步透明化和短按/长按记录语义。
- [x] T289 [P] [D-090] 在 `ios/Vitora/App/AppRouter.swift` 收窄 `GlobalVitoraDock` 宽高、左右 Tab 胶囊和中心 `+` 按钮尺寸，并降低中心 `+` 的青蓝渐变不透明度，保留短按 `.manual` 与长按 `.voice`。
- [x] T290 [P] [D-090] 构建并保存底部 Dock 截图，确认 Dock 更窄、更薄，中心 `+` 更透明且短按/长按入口仍可用。
