# Vitora Swift Rebuild · 功能过滤清单

> Batch: Product Reset
> 日期：2026-05-03
> 目的：在 canonical Swift specs 之前过滤候选功能。

允许的 `Decision`：`keep`、`redesign`、`defer`、`drop`、`needs-user-decision`。

允许的 `Priority`：`P0 Swift MVP`、`P1 After MVP`、`P2 Backlog`、`Out`。

## Inventory

| ID | Area | Candidate Feature | Source | User Value | Current RN Evidence | UX Health | Decision | Priority | Reason | Next Spec Target |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| FI-001 | Onboarding | 3 页极速注册 | `Spec/facts.md`, `Spec/pages/onboarding.md` | 快速建立初始上下文 | `src/app/onboarding/1.tsx`, `2.tsx`, `3.tsx` 已存在 | 结构有用，视觉粗糙 | redesign | P0 Swift MVP | 产品结构正确，但 Swift 版需要原生控件和更干净的节奏 | `userflows.md`, `spec.md` |
| FI-002 | Onboarding | WeChat 登录作为账户路径 | 原始 Spec | 账户连续性和支付路径 | Simulator 确认当前 Onboarding 第 1 页把 mock WeChat 作为下一步门槛；手动按钮可见但无效 | Swift 首发不需要 | drop | Out | 用户确认 Swift 首发不必须 WeChat 登录；P0 不设置 WeChat account gate | none |
| FI-003 | Onboarding | 昵称和生日 | 原始 Spec | 个性化和年龄上下文 | 本地 state 已实现 | 健康 | keep | P0 Swift MVP | 小而有用，风险低 | `spec.md` |
| FI-004 | Onboarding | HealthKit / 设备连接可选 | 原始 Spec, RN, 用户决策 | 数据更准，但不阻塞手动路径 | `DeviceConnector`，延迟成功 mock | 意图健康，实现不真实 | redesign | P0 Swift MVP | 用户确认 P0 具备 HealthKit 能力，但对用户可选；未授权时 app 必须以手动/低数据模式工作 | `spec.md`, 后续 `plan.md` |
| FI-005 | Onboarding | 关注点选择 | 原始 Spec, RN | 告诉 Vitora 先看什么 | `FOCUS_AREAS` | 健康 | keep | P0 Swift MVP | 低成本高价值的初始偏好 | `spec.md` |
| FI-006 | Onboarding | 营养补给 setup 入口 | 原始 Spec, RN | 记录用户已有补充背景 | onboarding 第 2 页三入口 | 有价值但可能增加摩擦 | redesign | P1 After MVP | 保留为可选能力，P0 不拖慢注册 | backlog |
| FI-007 | Onboarding | 定制中进度页 | 原始 Spec, RN | 教用户理解产品循环 | `onboarding/3.tsx` 模拟进度 | 有用，但必须诚实 | redesign | P0 Swift MVP | 若后台工作不真实，文案和状态必须改为本地准备中 | `userflows.md` |
| FI-008 | Today | 三个常驻主 Tab | `Spec/facts.md`, IA, RN, D-032 | 稳定心智模型 | `src/app/(tabs)/_layout.tsx` | 基本健康 | keep | P0 Swift MVP | Today / Vitora / Cycle 继续作为主结构；旧 Luna 命名已被 Vitora 替换 | `ia.md` |
| FI-009 | Today | Vitora 中心 Tab 强调 | 原始 Spec, RN, D-035 | 强化全局 assistant 地位 | RN 对旧 Luna 页隐藏 tab bar；新设计使用 low-lift Pixel Vitora face CTA | 产品关键，需重做 | redesign | P0 Swift MVP | 保留中央 CTA，但必须避免遮挡 input dock，并使用 Pixel Vitora face | `ia.md`, `design-tokens.md`, `components.md` |
| FI-010 | Today | 今日能量状态 | 原始 Spec, RN | 回答核心问题 | Today 中硬编码 `ENERGY_DATA` | 产品关键，数据 mock | redesign | P0 Swift MVP | 保留概念；Swift 规格必须定义低数据/真实数据状态 | `facts.md`, `spec.md` |
| FI-011 | Energy/Orb | Today 能量球 | 原始 Spec, RN, D-034 | 快速读懂今日状态并建立仪式感 | `EnergyOrbPersistent` 证明视觉资产存在 | 有价值，但不能常驻压住首页 | redesign | P0 Swift MVP | 改为每日首次、下拉揭示和晚间复盘中的 Energy Ball；首页主状态使用节律曲线 | `wireframes.md`, `components.md` |
| FI-012 | Energy/Orb | 首次打开全屏能量仪式 | 原始 Spec, RN, 用户决策 | 建立每日仪式感，快速激活产品价值 | Simulator / source 确认 `EnergyOrbFullNew` 由当日首次打开触发，并在约 8.7 秒后出现分析表面 | 产品关键，但必须控制复杂度 | redesign | P0 Swift MVP | 用户确认 Full energy ritual 进入 P0；Swift 规格需定义原生、可交付的最小仪式版本 | 后续视觉规格 |
| FI-013 | Energy/Orb | 分析页小能量球 | 原始 Spec, RN | 让解释和分数关联 | `EnergyOrbModal` | 健康 | redesign | P0 Swift MVP | 只在它帮助理解时保留 | `spec.md` |
| FI-014 | Today | AI 监测今日时间线 | 原始 Spec, RN | 给出一天节律 | `HomeMonitorCard`, `MonitorCurve` | 有用但可能密集 | redesign | P0 Swift MVP | 保留轻量时间线，避免第一版复杂图表 | `spec.md` |
| FI-015 | Today | 经期/睡眠/心情记录卡 | 原始 Spec, RN | 轻量补充上下文 | `HomeRecordSection`, `RecordPanel` | 有用，但混入自定义任务噪音 | redesign | P0 Swift MVP | 保留三类关键记录；删除自定义任务编辑 | `spec.md` |
| FI-016 | Today | 自定义任务卡 | RN drift | 个性化但不服务核心循环 | `CustomTaskEditorModal` | 噪音 | drop | Out | 会把产品推向任务管理 | none |
| FI-017 | Analysis | 点击能量后的分析 sheet | 原始 Spec, RN | 解释原因并给出下一步 | EV-RN-001 确认点击能量分析入口后出现 dimmed overlay + bottom-sheet 分析表面，含能量、四指标、解释文本、同日建议和 A/B 表面 | 有用，但层级和密度过重 | redesign | P0 Swift MVP | 用原生 sheet/card 重做，减少指标，接入真实 A/B 路径 | `spec.md`, `userflows.md` |
| FI-018 | Analysis | 四个指标卡 | 原始 Spec, RN | 支撑今日解释 | hard-coded metric array | 混合 | redesign | P0 Swift MVP | 只保留必要支撑指标，避免仪表盘化 | `spec.md` |
| FI-019 | A/B Suggestion | 分析中的 A/B 方案 | `Spec/facts.md`, RN | 核心学习动作 | EV-RN-002 确认选择方案 B 后出现已选方案和提醒时间；已有提醒雏形，但缺少 durable intent、可编辑提醒偏好和复盘入口 | 产品关键，实现不完整 | redesign | P0 Swift MVP | 必须形成意图和复盘路径，不能只是即时反馈 | `facts.md`, `userflows.md` |
| FI-020 | A/B Suggestion | “不合适”替代路径 | 原始 Spec, RN | 避免强迫选择 | RN 仅 Alert | 有用但完整记忆较重 | redesign | P1 After MVP | P0 可先收集轻反馈，深度调整后移 | `spec.md` |
| FI-021 | A/B Suggestion | VIP A-prime 记忆 | 原始 Spec, RN service hook | 长期学习 | `useABChoice`, `preferenceService` mock | 有价值但和商业化耦合 | defer | P1 After MVP | MVP 不依赖 VIP 学习记忆 | 后续 VIP spec |
| FI-022 | Vitora | Vitora 主 Tab：AI-native assistant surface | 原始 Spec, RN, D-035 | 主动找 Vitora、理解上下文、继续对话和复盘 | `src/app/(tabs)/luna/index.tsx` 证明旧 assistant surface 存在 | 产品关键，旧视觉噪音多 | redesign | P0 Swift MVP | 重做为活的 assistant 空间，不是空聊天页或普通 dashboard | `ia.md`, `spec.md`, `wireframes.md` |
| FI-023 | Vitora | Pixel Vitora 陪伴体 | 原始 Spec, RN, D-038 | 建立陪伴感和品牌识别 | RN hand/hero 组件存在；`assets/design_04/vitora_tab.png` 锁定像素球方向 | 有用，必须品牌化 | redesign | P0 Swift MVP | 使用像素风格发光小球，不用 smooth orb、人像、宠物或普通 icon | `design-tokens.md`, `components.md` |
| FI-024 | Vitora | 自然语言轻校准 / 记录 | 原始 Spec, RN, D-036 | 最快捕获会影响状态和建议的上下文 | EV-RN-003 确认 AI 记录示例可填入并发送，但只得到已发送确认，没有可见解析、编辑确认或保存回流 | 产品关键，还不真实 | redesign | P0 Swift MVP | 保留输入路径；必须实现理解-确认-保存，并从 Today/Cycle 对象上下文唤醒 | `userflows.md`, `spec.md` |
| FI-025 | Vitora | 快捷上下文 / 手动补充 | 原始 Spec, RN, D-036 | 服务不想打字或偏好点选的用户 | `RecordPanel` 有身体/心情/想法 tabs | 有用，但旧表单占位多 | redesign | P0 Swift MVP | P0 改为 quick context icon chips 和少量对象级校准 chips，不做独立打卡面板 | `components.md`, `wireframes.md` |
| FI-026 | Vitora | 从 assistant surface / contextual sheet 升级完整 Vitora | RN drift, 用户决策, D-035, D-036 | 需要更沉浸时进入完整 AI assistant，同时保留来源上下文 | `fullChatMode`, `PanResponder` 证明上滑模式存在，但旧实现像跳到另一个页面 | 用户确认保留意图，需重定义 | keep | P0 Swift MVP | 保留“局部 3/4 sheet ↔ 完整 Vitora”升级体验，不复制旧 Luna 上滑沉浸细节 | `userflows.md`, `spec.md`, `ia.md` |
| FI-027 | Vitora | 搜索记录历史 | RN drift / 原始意图 | 后期检索 | 旧 Luna 页 Alert 占位 | 非 MVP | defer | P2 Backlog | 需要成熟数据模型后再做 | backlog |
| FI-028 | Evening Review | 最小晚间复盘：干预前后效果对比 | 原始 Spec, partial RN, 用户决策 | 让用户当天感受到 app 的实际用处，快速激活 | `EnvelopeCard`, `reviewScheduler` | 产品关键，未整合 | redesign | P0 Swift MVP | 用户确认 P0 要实现最小复盘：对比 app 当天干预前后的效果，而不是只写总结 | `userflows.md`, `spec.md` |
| FI-029 | Evening Review | 未点击后降频 | 原始 Spec, RN service | 尊重注意力 | `reviewScheduler.ts` 有逻辑 | 健康但偏细节 | defer | P1 After MVP | 推送真实落地后再规格化 | 后续通知 spec |
| FI-030 | Cycle/Hormone | Cycle Tab 长期节律首页 | 原始 Spec, RN, D-037 | 提供周期阶段、Today 关系和长周期能量动态 | EV-RN-005 确认当前 Cycle 暴露节律上下文、学习进度、能量监测、日历入口和 VIP 路径 | 有用但过重 | redesign | P0 Swift MVP | P0 首页只保留“当前周期阶段与今天”和“能量动态”两大组件 | `spec.md`, `ia.md` |
| FI-031 | Cycle/Hormone | 周期日历 | 原始 Spec, RN, D-037 | 支持周期上下文和日期回看 | `src/app/(tabs)/today/hormone.tsx` | 有用，但入口需要收口 | redesign | P0 Swift MVP | 日历保留，但入口归 Today 顶部日历 icon，不放 Cycle 首页 | `ia.md`, `spec.md` |
| FI-032 | Cycle/Hormone | 手部交互和上滑展开 | 原始 Spec, RN | 形成独特节律体验 | EV-RN-005 确认上滑/展开态暴露高级分析、能量监测、日历入口和 VIP 表面 | 设计成本高 | defer | P1 After MVP | 等 Figma/native 执行更稳再做 | 后续视觉规格 |
| FI-033 | Cycle/Hormone | Vitora 了解度 | 原始 Spec, RN | 表达学习进展 | `GrowthMeter`, cycle bars | 可能变成进度压力 | redesign | P1 After MVP | P0 不显示天数压力，只保留必要学习信号 | 后续 Vitora spec |
| FI-034 | Cycle/Hormone | 深度维度分析 | 原始 Spec, RN | 高级洞察 | RN 展开态很多行 | 太重 | defer | P2 Backlog | 不需要用于证明 MVP 闭环 | backlog |
| FI-035 | Drawer/Profile | 个人/账户基础 | 原始 Spec, RN | 身份和账号所有权 | `drawer/profile.tsx` | 有用 | keep | P0 Swift MVP | 支撑面，小范围保留 | `ia.md` |
| FI-036 | Drawer/Profile | 数据导出 | compliance, RN | 用户数据所有权 | `drawer/data-export.tsx` Alert 占位 | 必需，需重做 | redesign | P0 Swift MVP | 即使 UI 简单，也必须在产品范围内 | `compliance.md`, `spec.md` |
| FI-037 | Drawer/Profile | 法律与隐私 | compliance, RN | 信任和发布准备 | `drawer/legal.tsx` | 必需 | redesign | P0 Swift MVP | 保留，后续写原生流程 | `compliance.md` |
| FI-038 | Drawer/Profile | 数据来源连接设置 | 原始 Spec, RN placeholder | 管理授权来源 | `drawer/devices.tsx` placeholder | 取决于 HealthKit 是否 P0 | redesign | P0 Swift MVP | 如果 P0 使用设备数据就保留，否则 P1 | `facts.md` 用户决策 |
| FI-039 | Drawer/Profile | 营养补给页面 | 原始 Spec, RN, 用户决策 | 管理用户已有补充记录 | `drawer/supplements.tsx` | 有用，且用户确认保留 | keep | P0 Swift MVP | 用户确认保留；IA batch 再决定它是抽屉可见路由、记录流入口，还是两者都有 | `ia.md`, `spec.md` |
| FI-040 | Drawer/Profile | Vitora 养成页 | 原始 Spec, RN | 陪伴进展 | `drawer/luna-growth.tsx` | 有压力风险 | defer | P1 After MVP | P0 不做陪伴天数驱动 | backlog |
| FI-041 | Drawer/Profile | 大范围抽屉页面 | 原始 Spec, RN | 未来设置和报告 | EV-RN-004 确认当前宽抽屉展示 profile、data charts、nutrition、data sources、subscription、reminders、widgets、settings、help/feedback、export、privacy/account removal 等混合项 | 范围膨胀 | drop | Out | P0 不出现占位导航，有需求再加 | none |
| FI-042 | Notifications | A/B 配套提醒 | 原始 Spec, service mock | 支撑用户已选行动 | `notificationService.ts` mock array | 有价值，有权限复杂度 | redesign | P0 Swift MVP | 如果 P0 有 A/B，就在合适时机请求权限 | `userflows.md` |
| FI-043 | Notifications | 每日早晨提醒 | 原始 Spec | 提醒回访 | 无真实整合 | 可选 | defer | P1 After MVP | 产品初版可不依赖每日 push | backlog |
| FI-044 | AI/Local LLM | 云端 LLM 生成和对话 | 原始 Spec, RN service shell | 支撑 Vitora 解释和生成 | `promptBuilder`, `sseClient`, sanitizer | 有用，但非 Swift 特有 | redesign | P0 Swift MVP | 产品层只定义 Vitora 能力；技术边界后续再定 | 后续技术 plan |
| FI-045 | AI/Local LLM | 本地 Gemma / agentic usage | 用户未来目标 | 隐私、延迟、离线潜力 | RN 无实现 | 未来架构，必须提前感知 | defer | P2 Backlog | 可延期实现，但后续产品、数据、隐私、AI 技术规格必须为未来引入本地 LLM/agentic usage 预留判断空间 | 后续 AI 架构 batch |
| FI-046 | Privacy/Data | 敏感数据加密 | compliance, RN partial | 信任和底线 | RN 使用 plain `expo-sqlite`; SecureStore 只管小值 | 明显缺口 | redesign | P0 Swift MVP | Swift 重建必须把本地加密设为硬要求 | 后续技术 plan |
| FI-047 | Privacy/Data | LLM 输入最小化 | compliance, RN | 降低数据暴露 | `sanitizer.ts` 存在 | 健康 | keep | P0 Swift MVP | 进入产品和技术规格 | `compliance.md`, 后续 plan |
| FI-048 | Privacy/Data | 禁用表达过滤 | compliance, RN | 保持 Vitora 语言安全 | `bannedWordFilter.ts`, constants | 健康 | keep | P0 Swift MVP | 作为内容约束继承 | `compliance.md` |
| FI-049 | VIP/Subscription | 订阅管理 | 原始 Spec, RN placeholder | 商业化 | `drawer/subscription.tsx` placeholder | 非 MVP | defer | P1 After MVP | 核心价值跑通后再定义 | 后续 business spec |
| FI-050 | VIP/Subscription | 行为洞察式升级提示 | 原始 Spec, RN insight engine | 更自然的商业化 | `insightEngine.ts` | 原则好 | defer | P1 After MVP | 保留原则，推迟实现 | 后续 VIP spec |
| FI-051 | Widgets/Devices | iOS 小组件 | 原始 Spec, RN placeholder | 快速 glance | `drawer/widgets.tsx` placeholder | 非 MVP | defer | P2 Backlog | 原生 extension 后置 | backlog |
| FI-052 | Widgets/Devices | 多设备生态 | 原始 Spec | 更丰富数据 | RN 只有 mock 连接 | 太宽 | defer | P2 Backlog | 从 HealthKit/手动路径开始 | 后续 device spec |

## P0 Swift MVP 候选切面

P0 只应包含：

- 最小 onboarding
- 三个主 Tab
- Today 今日状态
- HealthKit 能力进入 P0，但用户可跳过，app 必须支持手动/低数据模式
- 能量/分析入口和 P0 最小 Full energy ritual
- A/B 选择和诚实后续路径
- Vitora AI-native assistant surface、contextual sheet、输入 dock 和理解确认
- 对象级轻校准 / 记录捕获
- Cycle 长期节律首页，以及 Today 顶部周期日历
- 最小晚间复盘：对比当天干预前后的效果
- 个人资料、法律隐私、数据导出、营养补给页面
- 加密本地健康数据与 LLM 输入最小化要求

其他功能必须不可见或明确延期。

## Current RN Anti-Evidence Summary

当前 RN app 证明产品有足够多的表面，也证明为什么必须先过滤：

- 很多 UI 路径最终只是 `Alert.alert`，存在入口不等于产品完成。
- A/B 联动有可见即时确认和提醒时间雏形，但还没有 durable intent、可编辑提醒偏好和复盘入口。
- 本地数据库使用 plain Expo SQLite，与产品隐私底线不一致。
- 抽屉过宽，出现大量 placeholder 页面，干扰核心循环。
- 旧 Luna 和 Cycle 页面混合了有价值想法与视觉/交互噪音。
- 多个组件依赖硬编码或 mock 数据，不能成为 canonical 数据行为。

这些观察用于裁剪，而不是复刻。

## Fresh Simulator Evidence · 2026-05-03

| Area | Fresh Finding | Inventory Impact |
| --- | --- | --- |
| Onboarding | 当前 Vitora Onboarding 第 1 页可见 WeChat mock、昵称、生日、设备/HealthKit 候选和手动按钮。 | FI-001 保留结构；FI-002 作为反例 drop；FI-004 必须从 mock 改为真实可选能力。 |
| Today / Energy | EV-RN-001：Today 包含周期上下文、能量球、AI monitoring、四个支撑指标、建议入口和记录入口；能量分析打开 dimmed overlay + bottom-sheet 分析表面。 | FI-012 / FI-017 / FI-019 保留产品意图，但 Swift 必须收敛复杂度并接入真实闭环。 |
| A/B | EV-RN-002：选择方案 B 后出现已选方案和提醒时间。 | FI-019 保留；P0 必须补齐 durable intent、提醒偏好和复盘路径。 |
| Vitora | EV-RN-003：旧 Luna 首页、上滑沉浸态、`+` 记录 sheet 和 AI 示例发送均已确认；当前发送只得到已发送确认。 | FI-022 到 FI-026 的核心意图成立；搜索、主题和占位动作仍是噪音；必须重构为 Vitora assistant surface，并补齐理解-确认-保存。 |
| Cycle | EV-RN-005：Cycle 暴露节律上下文、学习进度、能量监测、日历入口、VIP 路径和日历页。 | FI-030 / FI-031 保留；FI-032 / FI-034 / FI-040 / FI-049 继续延期或隐藏。 |
| Drawer | EV-RN-004：当前抽屉为宽侧栏，菜单池明显超过 P0。 | FI-035 到 FI-039 中的必要支撑保留；FI-041 继续 drop；D-024 收口为轻抽屉。 |
| Host navigation | EV-RN-006：Simulator 左上角 `Cycle` 返回标签属于宿主导航状态。 | 不把宿主标签写成 Vitora IA 或功能候选。 |
