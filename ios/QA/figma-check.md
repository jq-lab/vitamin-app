# Figma 复查记录

## 2026-05-04 · Phase 3 / US1

- 范围：`WF-001` 新手引导三步路径，以及 `RF-000-01`、`RF-001-01` 到 `RF-001-06`、`RF-002-01`。
- Figma MCP：已读取项目权威文件 `d4B55gG7gEG4t2XEYW9IyY` 的节点 `373:259`，确认当前可访问的高保真画面主要提供 Today 视觉语言：浅背景、柔和蓝色强调、iOS 容器层级、底部三主区结构。
- Onboarding 结论：规格中 `EV-WF-001` 已标记“无有效当前节点 / needs-redesign”，因此本轮不复刻旧 RN 新手引导，也不从 Today 节点硬推导完整 onboarding 视觉。
- 实现取向：用 SwiftUI 原生表单、进度条、可点击 chip、HealthKit 可选区和 ready 页完成最小产品路径；后续视觉精修 batch 需要补充或确认 onboarding 专属 Figma 节点。
- 验收状态：US1 UI 测试覆盖“输入称呼 -> 跳过 HealthKit -> 进入 Today -> 低数据模式可见”，产品路径已闭合。

## 2026-05-04 · Phase 4 / US2

- 范围：`WF-002` Today 主屏、`WF-003` Full Energy Ritual、`WF-004` Today Analysis Sheet，以及 `RF-002-*`、`RF-003-*`、`RF-004-*`。
- Figma MCP：已读取项目权威文件 `d4B55gG7gEG4t2XEYW9IyY` 的节点 `373:259`、`250:24`、`250:27`。`373:259` 作为 Today 视觉基准；`250:27` 作为分析 sheet 的结构基准；`250:24` 基本为空白覆盖，不作为实现依据。
- 实现取向：保留浅底、柔和蓝、能量圆、日期/周期上下文、iOS sheet 层级；把当前 P0 实现降密度为“今日状态 -> 下一步 -> 能量仪式/分析/记录”三类行动，不暴露延期表面。辅助信号卡只放入分析 sheet，避免 Today 首屏与浮动 tab 产生视觉冲突。
- Simulator 复查：使用 `iosef describe` 读取可访问性树，使用 `iosef tap` 点击“开始能量仪式”“查看结果”“查看分析”，确认低数据 Today、仪式运行态、仪式结果态、丰富数据 Today、分析 sheet 均可达。
- 截图证据：
  - `ios/QA/Screenshots/US2/today-low-data.png`
  - `ios/QA/Screenshots/US2/today-ritual.png`
  - `ios/QA/Screenshots/US2/today-ritual-result.png`
  - `ios/QA/Screenshots/US2/today-rich.png`
  - `ios/QA/Screenshots/US2/today-analysis.png`
- 验收状态：US2 单元与 UI 测试覆盖 Today 低数据、丰富数据、能量仪式完成/跳过、分析 sheet 内容与延期表面隐藏。

## 2026-05-04 · Today Figma 对齐修正

- 范围：`FRI-TODAY-001` / Figma node `373:259`，修正当前 Swift Today 首页与 Figma 主参考的明显偏差。
- Figma MCP：重新读取 `d4B55gG7gEG4t2XEYW9IyY` 的 `373:259`，确认结构为顶部日期/周期条、大径向能量球、`AI分析 →`、`AI监测今日` 玻璃卡、AI 管家建议入口、`今日记录`、底部三主区且 Luna 中央强调。
- 实现修正：
  - 去掉 Today 的系统 large navigation title，改为 Figma 风格首屏结构。
  - 将系统 TabView 替换为自定义三主区底栏：`今日 / AI管家 / 周期`，中央 Luna 使用黑色圆形心形入口。
  - 重写 Today 能量球为径向刻度环、中心玻璃圆、蓝色状态文案和 `AI分析 →` 入口。
  - 重写 `AI监测今日` 卡片，补齐 14:00 低谷提醒、曲线、四个指标小卡和建议入口。
  - 补回 `AI管家已生成今日建议` 与 `今日记录 / + 记录` 区域。
- 截图证据：
  - `/Users/bytedance/Desktop/Work/vitora/ios/QA/Screenshots/US2/today-figma-alignment-2026-05-04-v3.png`
- 仍未 1:1 的点：
  - 记录区的像素插画是 Swift 原生近似，不是 Figma 原图资产。
  - 能量环刻度、玻璃阴影、曲线和设备内边距是原生近似值，后续可继续按截图微调。
  - 当前截图包含真实 Simulator 状态栏和外壳 chrome，Figma 节点是设计画布，不应把两者的外壳区域做 1:1 比较。
- 验收状态：最终 full test 已通过，`iosef view` 可稳定抓取当前可见 Simulator。

## 2026-05-04 · Today 事件行与底部 Tab 细节修正

- 范围：`FRI-TODAY-001` / Figma node `373:259`，针对人工复查指出的两个具体偏差做局部修正。
- 修正 1：`AI监测今日` 卡片内的 `14:00 低谷提醒` 改为左侧锚定；右侧只保留曲线、时间点和 `预计低谷` 标记，避免把事件标题挤到中间。
- 修正 2：底部三主区改为更贴近 iOS 的浮层底栏：保留 3 个主导航、短标签、SF Symbol 图标、Luna 中央强调，并让背景延展到底部安全区，减少硬白块和设备底部之间的断裂感。
- Apple HIG 对齐：Tab bar 只用于顶层导航，保持可见，使用短标签和系统图标；布局必须尊重安全区，避免与设备交互区冲突。
- 截图证据：
  - `/Users/bytedance/Desktop/Work/vitora/ios/QA/Screenshots/US2/today-figma-alignment-2026-05-04-v4.png`
- 仍未 1:1 的点：
  - 底部 Tab 是 Swift 原生近似实现，不是 Figma 画布导出的精确矢量；后续如要 1:1，需要继续按 Figma 节点量测圆角、中心按钮垂直位置、阴影和底部安全区高度。
  - Today 记录区仍使用 Swift 原生像素插画近似，未接入 Figma 原始图层资产。

## 2026-05-04 · Phase 5 / US3 A/B 当日意图与提醒偏好

- 范围：`WF-004` Today Analysis / A-B、`WF-011` Reminder Preferences、`RF-004-01` 到 `RF-004-08`、`RF-010-05`、`C-TODAY-006`、`C-TODAY-007`、`C-SUPPORT-005`。
- Figma MCP：已读取 `d4B55gG7gEG4t2XEYW9IyY` 的 `250:27`，确认 Today 分析 sheet 的白色圆角弹层、关闭入口、`今日分析` 标题、支撑指标区、AI 今日建议、两方案行和提醒开关结构。该节点负责弹层视觉基调；A/B 选择后的 durable intent、提醒偏好和晚间复盘路径按 004 规格重设计，不照搬 Figma 里的即时建议表面。
- 实现取向：
  - `ABChoiceGroup` 在分析 sheet 内提供 A/B 两个方向和“今天不太适合这些”轻反馈。
  - 选择 A/B 后写入 `DailyIntention`，在分析 sheet 内显示 `ABIntentSummary` 和 `ReminderPreferencePanel`。
  - 提醒偏好使用原生开关和步进器，可配置小尝试提醒与轻复盘提醒；通知权限被拒绝时不阻塞当日意图。
  - 关闭分析 sheet 后，Today 主屏用紧凑的“今天的小尝试”状态行替代原 AI 建议行，避免新增大卡片把内容压到底部 Tab 下。
- Simulator 复查：使用 `iosef tap` 打开 `AI分析 →`、滚动到 A/B 区、选择方案 A、开启提醒、关闭 sheet；使用 `iosef describe` 确认可访问树出现 `今天的小尝试`、`提前加餐 + 短走动`、`已准备轻提醒`、提醒开关 `value="1"`，并确认 Today 主屏摘要可见。
- 截图证据：
  - `/Users/bytedance/Desktop/Work/vitora/ios/QA/Screenshots/US3/ab-today-start-v2.png`
  - `/Users/bytedance/Desktop/Work/vitora/ios/QA/Screenshots/US3/ab-options-v2.png`
  - `/Users/bytedance/Desktop/Work/vitora/ios/QA/Screenshots/US3/ab-reminder-enabled-v2.png`
  - `/Users/bytedance/Desktop/Work/vitora/ios/QA/Screenshots/US3/ab-today-summary-v2.png`
- 仍未 1:1 的点：
  - A/B 已选后的持久意图是 004 redesign，不是 Figma 原图里的单纯建议列表；当前视觉选择是为了体现“当日承诺 + 晚间复盘路径”。
  - 提醒偏好使用 SwiftUI 原生开关和 stepper，未自定义成 Figma 里可能存在的视觉开关细节；后续如要更像 Figma，需要在组件批次里继续量测开关、行高、间距和状态色。
  - Today 主屏的 A/B 状态行是紧凑实现，优先保证不与底部 Tab 冲突；是否要做更接近 Figma 的独立卡片，需要下一轮视觉微调时由用户确认。
- 验收状态：`xcodebuild ... -parallel-testing-enabled NO test` 通过 53 个测试；并行 UI clone 曾触发一次 Simulator 诊断超时，但失败用例单独重跑通过，非产品代码失败。

## 2026-05-04 · Phase 6 / US4 Luna 首页与记录保存

- 范围：`WF-005` Luna 首页、`WF-006` Luna 记录 sheet、`REQ-008`、`REQ-009`、`C-LUNA-001` 到 `C-LUNA-006`。
- Figma MCP：已读取 `d4B55gG7gEG4t2XEYW9IyY` 的 `301:289`、`301:150`、`301:18`。`301:289` 作为 Luna 首页视觉基准，包含顶部轻抽屉入口、`AI 对话 / 记录本` 切换、白色圆角 Luna 像素卡、日期/周期上下文、上下文气泡和底部输入 dock；`301:150` / `301:18` 作为手动记录与 AI 记录 sheet 的视觉基准。
- 实现取向：
  - `LunaView` 不再是占位页，接入三主区中的 Luna tab。
  - Luna 首页保留 Figma 的浅底、像素 Luna、白色大圆角卡、日期上下文、Luna 气泡和底部输入 dock。
  - 底部输入 dock 固定在 tab bar 上方，不进入滚动内容，避免真实手指点击被底栏覆盖。
  - 记录 sheet 提供 `手动记录 / AI 记录` 模式、自然语言示例、快捷类别、输入区、解析确认和保存/取消闭环。
  - 解析确认卡和保存成功卡是 004 规格重设计：Figma 只提供记录入口视觉，`REQ-009` 要求确认后才能进入 Luna 上下文。
- Simulator 复查：
  - `iosef tap` 实际点击 Luna tab、底部 plus、示例记录、解析按钮、保存按钮，确认自然语言记录路径可达。
  - `iosef view` 在本轮仍输出黑图，不作为视觉证据；有效截图使用 `xcrun simctl io booted screenshot` 采集。
  - `iosef describe` 本轮只返回顶层 `AXApplication`，因此本轮 accessibility 细节以 XCUITest 结果为准。
- 截图证据：
  - `/Users/bytedance/Desktop/Work/vitora/ios/QA/Screenshots/US4/luna-home-fixed-simctl.png`
  - `/Users/bytedance/Desktop/Work/vitora/ios/QA/Screenshots/US4/luna-record-sheet-fixed-simctl.png`
  - `/Users/bytedance/Desktop/Work/vitora/ios/QA/Screenshots/US4/luna-record-sheet-example-selected-simctl.png`
  - `/Users/bytedance/Desktop/Work/vitora/ios/QA/Screenshots/US4/luna-record-preview-simctl.png`
  - `/Users/bytedance/Desktop/Work/vitora/ios/QA/Screenshots/US4/luna-record-saved-simctl.png`
- 仍未 1:1 的点：
  - Pixel Luna 使用 Swift 原生方块近似，不是 Figma 原始矢量/位图资产。
  - Sheet 的高度、字体粗细、曲线阴影和输入框细节是 SwiftUI 原生近似；如需进一步贴近 Figma，需要继续逐项量测 `301:150` / `301:18`。
  - 当前只实现 Luna 首页与记录保存；沉浸聊天上滑态、轻抽屉真实内容和晚间复盘入口分别留给 US5、US8、US6。
- 验收状态：`xcodebuild ... -parallel-testing-enabled NO test` 通过 64 个测试；US4 目标测试覆盖 Luna 首页、自然语言记录、解析确认保存、营养快捷记录、AI 不可用兜底和 Today 记录入口复用 Luna sheet。

## 2026-05-04 · Phase 7 / US5 Luna 沉浸聊天

- 范围：`WF-007` Luna 沉浸聊天、`RF-006-02` 到 `RF-006-06`、`REQ-010`、`C-LUNA-007`。
- Figma MCP：已读取 `d4B55gG7gEG4t2XEYW9IyY` 的 `301:676`。该节点确认沉浸聊天的视觉方向：顶部 `AI 对话 / 记录本 / 主题·总账`、大 Luna 像素卡、日期行、便签式记录入口、Luna 气泡、快捷 chips 和底部输入 dock。
- 实现取向：
  - `LunaImmersiveChatView` 作为全屏沉浸态覆盖 Luna 首页，打开后隐藏底部三主区，退出后回到 Luna 首页。
  - 支持从 Luna 首页上滑进入，也支持从底部输入 dock / 发送按钮进入。
  - 聊天输入、发送、Luna 回复、快捷 chips、聊天中打开记录 sheet 都已接入真实状态；AI 不可用时走可恢复兜底回复。
  - `AIContextBuilder` 增加沉浸聊天上下文 job，只带最小化、脱敏后的近期对话和 Today/记录摘要。
  - 本轮 QA 发现两个交互问题并已修复：上滑命中区域过窄，以及沉浸态打开后底层 Luna 首页仍进入可访问树；另外记录 sheet 增加明确关闭按钮，避免用户只能依赖下滑猜测退出。
- Simulator 复查：
  - 使用 `iosef tap` 点击 Luna tab，`iosef swipe` 从 Luna 首页上滑进入沉浸聊天，`iosef type` 输入文本，`iosef tap` 发送、打开记录 sheet、关闭记录 sheet、退出回 Luna 首页。
  - 使用 `iosef describe` 确认沉浸态打开后可访问树只暴露聊天层，不再暴露底层 tabbar / Luna 首页内容；记录 sheet 可访问树包含 `关闭记录`。
  - `iosef view` 本机偶尔仍输出黑图，因此视觉证据使用 `xcrun simctl io ... screenshot` 采集；交互仍由 iosef 实际点按、滑动和输入完成。
- 截图证据：
  - `/Users/bytedance/Desktop/Work/vitora/ios/QA/Screenshots/US5/luna-us5-home-after-tap.png`
  - `/Users/bytedance/Desktop/Work/vitora/ios/QA/Screenshots/US5/luna-us5-chat-after-swipe.png`
  - `/Users/bytedance/Desktop/Work/vitora/ios/QA/Screenshots/US5/luna-us5-chat-after-send.png`
  - `/Users/bytedance/Desktop/Work/vitora/ios/QA/Screenshots/US5/luna-us5-chat-record-sheet.png`
  - `/Users/bytedance/Desktop/Work/vitora/ios/QA/Screenshots/US5/luna-us5-home-after-exit.png`
- 仍未 1:1 的点：
  - Pixel Luna 仍是 Swift 原生方块近似，不是 Figma 原始资产。
  - 沉浸聊天当前更偏“可用 P0 对话面”，卡片尺寸、顶部主题区、便签色、气泡宽度和键盘状态还可以按 `301:676` 继续做视觉微调。
  - `主题·总账` 目前是静态视觉元素，不开放延期的主题总控功能，符合 P0 边界。
- 验收状态：US5 targeted 测试通过；完整 `xcodebuild ... -parallel-testing-enabled NO test` 通过 70 个测试，覆盖 57 个单元测试与 13 个 UI 测试。
