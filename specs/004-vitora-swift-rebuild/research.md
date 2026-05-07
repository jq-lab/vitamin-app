# Vitora Swift Rebuild · 技术研究与决策

> 规格集：`004-vitora-swift-rebuild`
> 批次：Technical Plan / SpecKit Plan Package
> 日期：2026-05-03
> 状态：当前生效

本文档记录 `/speckit.plan` 预期的 Phase 0 research 输出。它解释关键技术选择、被拒绝方案和后续任务应遵守的边界。

## 0. 研究输入

| 来源 | 使用方式 |
| --- | --- |
| `facts.md` | 锁定 P0 产品范围和不做清单。 |
| `spec.md` | 锁定 `REQ-001` 到 `REQ-016`。 |
| `data-model.md` | 锁定 `DM-001` 到 `DM-025`、状态机和领域事件。 |
| `data-privacy-ai-boundaries.md` | 锁定数据级别、HealthKit、AI、日志、提醒、导出和账号移除边界。 |
| `compliance.md` | 锁定合规标识、表达组和 Vitora 输出边界。 |
| `wireframes.md` / `reference.md` / `components.md` / `design-tokens.md` | 锁定视觉与组件实现来源。 |
| 当前 RN 源码和 Simulator 证据 | 只用于理解失败点和可借鉴意图，不作为 Swift 技术目标。 |
| 本地环境 | Xcode 26.4.1；iOS 26.4 Simulator 可用。 |

## 1. 技术决策表

| Decision ID | Decision | Rationale | Rejected Alternatives | Downstream Impact |
| --- | --- | --- | --- | --- |
| TR-001 | 使用纯 Swift / SwiftUI 原生 iOS app。 | 用户偏好 Swift；未来 HealthKit、本地模型、通知和隐私能力更适合原生边界。 | 继续 Expo / RN；混合壳；WebView。 | 新工程放入 `ios/`，不继续扩展 RN `src/`。 |
| TR-002 | 部署目标建议 iOS 18.0+，本机用 Xcode 26.4.1 和 iOS 26.4 Simulator 验证。 | 兼顾 SwiftUI/Observation/SwiftData 时代 API 和较新设备；本机工具链已具备。 | 追求更老系统；只支持最新模拟器。 | tasks 需显式设置 deployment target，并验证当前 simulator。 |
| TR-003 | UI 使用 SwiftUI + Observation，不使用 UIKit 作为主 UI。 | P0 是原生 iOS 体验，SwiftUI 对 Tab、sheet、animation、Dynamic Type 更直接。 | UIKit 全量实现；跨平台 UI。 | ViewModel 使用 `@Observable`，UIKit 只在原生能力需要时桥接。 |
| TR-004 | 使用明确 domain service，而不是全局 store。 | 当前 RN 的 Zustand / mock store 证明内存状态容易断开 A/B、记录、复盘和导出。 | Redux-like mega store；View-local state 直接持久化。 | 任务必须先做 domain services 和 repository，再做 UI 闭环。 |
| TR-005 | 持久层使用 SQLCipher-backed SQLite adapter。 | 004 规格要求本地优先、敏感数据加密、导出和账号移除可追踪；SQLite 更适合可控导出和删除。 | UserDefaults；plain SQLite；只用 SwiftData。 | `PersistenceClient` 隔离具体库；schema 由 `DM-*` 映射。 |
| TR-006 | Keychain 管理本地密钥，CryptoKit 用于导出包和临时 payload 保护。 | 密钥不应和数据同处一个普通文件；导出准备也需要可控保护。 | 把 key 写入 app storage；把导出明文长期缓存。 | `PrivacyVault` 和 `ExportService` 成为 foundational tasks。 |
| TR-007 | HealthKit 是可选增强，读取范围采用 allowlist。 | `REQ-003` 要求拒绝或跳过后 app 仍可用；HK-003 要求最小范围。 | 一次性请求宽权限；无 HealthKit P0。 | onboarding、Today、Cycle 都必须有 low-data branch。 |
| TR-008 | 通知只用于 A/B 和晚间复盘。 | `NF-*` 与 `REQ-007` / `REQ-011` 已收口；泛促活会破坏 calm 体验。 | 泛通知中心；每日 push；任务提醒。 | `NotificationScheduler` 只接收 `DailyIntention` 和 review availability。 |
| TR-009 | AI 通过 `VitoraAIClient` protocol 接入。 | P0 不实现本地模型，但未来 local Gemma / agentic usage 是方向。 | ViewModel 直接调云端 SDK；暴露模型选择 UI。 | AI provider 可替换；业务只依赖 `AIContextPackage`。 |
| TR-010 | AI 输出必须经过 `VitoraOutputGuard`。 | `compliance.md` 要求 Vitora 输出、记录理解和复盘都服从表达边界。 | 直接展示模型原文；仅靠 prompt。 | 所有 AI UI tasks 必须调用 output guard。 |
| TR-011 | 视觉实现必须从 `WF-*` / `RF-*` / `C-*` / `vt.*` 映射到 SwiftUI。 | Figma 和 RN 都不是单一完整真相，已有 source decision 分级。 | 直接复刻 RN 截图；只按文字实现。 | 前端 tasks 必须引用 reference 和 components。 |
| TR-012 | 测试采用 XCTest + XCUITest + quickstart 手动验证。 | P0 的关键风险是状态闭环和交互路径，不只是单函数。 | 只跑单元测试；只做人工点击。 | `qa-contract.md` 定义测试门，`quickstart.md` 定义验收路径。 |

## 2. 存储研究

### 2.1 选择

P0 默认使用 SQLCipher-backed SQLite adapter。实现层必须隐藏在 `PersistenceClient` 后面，业务代码不得知道具体数据库库名。

### 2.2 理由

- `DM-024` 和 `DM-025` 要求导出和账号移除有可追踪状态。
- `DC-02`、`DC-03` 包含健康相关输入、记录理解、A/B 意图和复盘反馈，需要本地保护。
- SQLite 便于做可审计导出、删除、迁移和未来本地模型摘要索引。
- SQLCipher 满足“本地数据加密”的强约束，比只依赖普通 app sandbox 更清晰。

### 2.3 反选

| Alternative | Why Rejected |
| --- | --- |
| UserDefaults | 只适合少量偏好和 UI 状态，不适合领域对象、导出、删除和加密生命周期。 |
| Plain SQLite | 不满足敏感数据加密要求。 |
| SwiftData only | 开发效率高，但加密、导出、细粒度删除和未来摘要索引的可控性不足。 |
| Realm / cloud-first store | 引入不必要同步心智，P0 要本地优先。 |

### 2.4 Implementation Note

如果实现阶段选定的 SQLCipher Swift wrapper 无法在 Xcode 26.4.1 下稳定构建，必须先更新本文和 `decision-log.md`。不得在任务执行中静默降级到 plain storage。

## 3. HealthKit 研究

P0 HealthKit client 只读取 Today / Cycle / Vitora 理解需要的最小类别，并保持用户可跳过。

| Area | P0 Usage | Notes |
| --- | --- | --- |
| Sleep summary | 支持 Today 状态和低数据说明。 | 只保存摘要，不长期复制原始样本序列。 |
| Step count / active energy | 支持活动趋势和 Today 解释。 | 用日内或日级摘要。 |
| Heart rate / resting heart rate / HRV | 支持状态趋势摘要。 | 不在日志或通知中出现数值。 |
| Manual cycle context | Cycle P0 的主来源。 | HealthKit cycle samples 不作为 P0 必要前提。 |

授权状态必须进入 `DM-004`；HealthKit 缺席进入 low-data branch，而不是阻断。

## 4. AI 研究

P0 AI 能力分为四个 product jobs：

1. Today 解释。
2. A/B 轻行动生成。
3. Vitora 记录理解。
4. 晚间复盘总结。

所有 job 必须经过同一条路径：

```text
Domain State → AIContextBuilder → VitoraAIClient → VitoraOutputGuard → UI Confirmation / Display
```

### 4.1 Local Model Future

P0 不实现 local Gemma，也不实现 agent tool。为了未来替换：

- `VitoraAIClient` 不暴露 provider-specific 类型给 feature。
- `AIContextPackage` 不包含 UI 类型。
- `VitoraOutputGuard` 对本地和云端输出一视同仁。
- 工具执行类能力不得在 P0 出现。

## 5. Notification 研究

P0 使用 `UNUserNotificationCenter`，只为两个场景服务：

- A/B 当日意图轻提醒。
- 晚间复盘可用提醒。

通知权限不影响保存 `DailyIntention`。如果用户拒绝通知，app 内仍显示复盘入口。

## 6. Navigation 研究

SwiftUI navigation 使用：

- `TabView` for Today / Vitora / Cycle。
- `NavigationStack` per main area。
- `.sheet` 或 custom bottom sheet for analysis / record / small support edits。
- custom light drawer overlay for IA-040 到 IA-046。
- immersive Vitora chat as a Vitora state that may let tab bar recede but must keep clear exit.

不使用当前 RN 的宽 drawer route pool，不使用 hidden placeholder pages。

## 7. Visual Implementation 研究

Figma 文件没有可复用 token / component library，因此 Swift 需要自建 theme：

- `VitoraTheme.Color` from `vt.color.*`
- `VitoraTheme.Typography` from `vt.font.*`
- `VitoraTheme.Space` / `Radius` / `Motion`
- `C-*` 组件作为 SwiftUI component backlog

实现视觉前必须读取对应 Figma node。无可用 node 的步骤按 `reference.md` 的目标线框实现。

## 8. Testing 研究

测试优先级：

1. Domain tests: 状态机、服务输出、数据边界。
2. Persistence tests: 加密存储、导出、删除、迁移。
3. AI tests: context minimization、output guard、fallback。
4. UI tests: onboarding、Today、A/B、Vitora record、review、Cycle、drawer。
5. Quickstart manual: 真实 simulator 路径。

## 9. Resolved Technical Questions

| Question | Answer |
| --- | --- |
| 是否继续 RN / Expo？ | 否。新实现是纯 Swift 原生 iOS。 |
| 是否把 HealthKit 做成必经门槛？ | 否。它是 P0 可选增强。 |
| 是否实现 local Gemma？ | P0 不实现，但必须保留 adapter 边界。 |
| 是否直接从 RN migration 生成 schema？ | 否。以 `data-model.md` 的 `DM-*` 为领域来源。 |
| 是否用 REST contracts？ | 否。P0 是 mobile local-first app，`contracts/` 表示内部服务契约。 |
