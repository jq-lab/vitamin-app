# Vitora Design Handoff

> 规格集：`004-vitora-swift-rebuild`  
> 日期：2026-05-07  
> 状态：设计交付规范补充  
> 依据：`facts.md`、`design-tokens.md`、`components.md`、`interaction-acceptance.md`、`ios/QA/Screenshots/ComparisonV2/`

本文档把当前“目标设计 vs Swift 实现”的差异，转成设计师、交互动效设计师和工程师可共同使用的交付清单。它不替代 `facts.md`、`design-tokens.md` 或 `components.md`；若冲突，以 `facts.md` 和正式规格链为准。

## 1. 交付原则

| 原则 | 工程可执行含义 |
| --- | --- |
| 页面目标先于视觉形容词 | 每个页面先写“用户在这里完成什么”，再写氛围。 |
| 首屏优先级可验收 | 标明 P0、P1、可隐藏内容；工程可按 3 秒可读性验收。 |
| 组件化表达 | 页面必须拆成 Header、主卡、辅助卡、输入区、Sheet、Tab、Callout 等组件。 |
| 状态矩阵完整 | rich data、low data、empty、loading、error、permission denied、confirmed、AI unavailable 都要有设计。 |
| 动效有参数 | 触发阈值、时长、缓动、回弹、Reduce Motion 替代必须写清楚。 |
| 视觉 token 归属明确 | 所有新设计必须映射到 `vt.*` token，不新增散落颜色或玻璃样式。 |
| Pixel Vitora 有独立 spec | 涉及 IP 造型、材质、表情、道具或动效时，必须按 `pixel-vitora-ip/pixel-vitora-ip-spec.md` 交付。 |
| Cycle 页面有独立 spec | 涉及 Cycle 首页视觉、布局、图表、Tip 或 Tab 避让时，必须按 `cycle-page/cycle-page-spec.md` 交付。 |
| Vitora Tab 有独立 spec | 涉及 Vitora assistant surface、Quick Context、Input Dock 或周期上下文展开态时，必须按 `vitora-page/vitora-page-spec.md` 交付。 |
| Dynamic Aura 背景有独立 spec | 涉及首层背景、周期色、视频素材、Reduce Motion 兜底时，必须按 `dynamic-aura-background/dynamic-aura-background-spec.md` 交付。 |
| 截图可对照 | 每个页面交付目标图、当前图、允许偏差、不可接受错误。 |

## 2. 页面差异矩阵

| 页面 / 功能 | 理想目标 | 当前实现 | 设计补充项 | 工程验收项 |
| --- | --- | --- | --- | --- |
| Onboarding | 第一眼建立 Vitora 品牌，轻量收集称呼、周期上下文和 HealthKit 选择；低数据也可继续。 | 功能可用，但偏系统表单。 | 增加 Aura Glass 背景、Pixel Vitora 引导、低数据说明、完成进入 Today 的轻反馈。 | 首屏出现 Vitora 品牌和最小输入；跳过 HealthKit 后进入低数据 Today；无 WeChat gate。 |
| Today 首页 | 浅蓝弥散背景、清透状态卡、右上 Pixel Vitora、身体要素、今日建议、低凸起 Vitora tab face。 | 信息结构基本到位。 | 强化玻璃层级、右上 Pixel Vitora 存在感、建议卡叙事密度、背景光感。 | 3 秒内读到状态、依据、建议；无独立记录区；目标图参考 `assets/design_04/today_tab.png`。 |
| Dynamic Aura 背景 | 柔焦流体色场随周期阶段变色，Today 日历选择日期后返回首页可见变化。 | 已有静态 AuraBackground，动态视频背景为新增 baseline。 | 后续补完整 ASR 逐字稿、视频循环无缝性和 Reduce Motion 视觉复核。 | 执行规格以 `dynamic-aura-background/dynamic-aura-background-spec.md` 为准；不能直接使用教程录屏。 |
| Energy Reveal | 下拉后像能量球仪式层，有半展开、全屏、收起连续动效。 | 已有下拉功能态。 | 定义触发阈值、半展开高度、能量球缩放/发光、释放回弹。 | 默认隐藏；下拉不是刷新；Reduce Motion 下无强弹性。 |
| Today 日历 | 从 Today 顶部进入，只解释“今天在周期时间线的位置”。 | 已有入口和 sheet。 | 补选中日、预测窗口、低置信、日期不准反馈状态。 | 日历不出现在 Cycle 首页；可返回 Today；可告诉 Vitora 日期/感受不准。 |
| Contextual Vitora Sheet | 保留来源上下文，快速补充并确认保存。 | 已实现 3/4 sheet。 | 明确 sheet 高度、背景压暗、输入 dock、确认后反馈动效。 | 顶部显示来源；关闭回来源；保存前必须确认。 |
| Vitora Tab | 活的 assistant surface：大 Pixel Vitora、上下文卡、对话、直接问、chips、input dock。 | 当前 baseline 已对齐 `18-vitora-target-aligned.png`。 | 后续补低数据、AI 不可用、语音录入和键盘态的精细视觉。 | 执行规格以 `vitora-page/vitora-page-spec.md` 为准；默认态同时可见 Pixel Vitora、Vitora 知道、直接问、chips、input dock。 |
| Quick Context Chips | 输入区附近的小工具带，点击后展开上下文卡。 | 当前 `周期` chip 展开态已形成 baseline。 | 补 idle、pressed、selected、expanded、dismissed 的 Figma 标注和 motion 参数。 | chips 不变成主导航；展开卡贴近输入区；输入 dock 不被 tab 遮挡；周期展开态以 `vitora-page/` 为准。 |
| Evening Review | 对比早上状态与晚间感受，形成学习信号，不像任务完成率。 | 已有复盘 sheet。 | 补学习信号视觉层级、提交后反馈、返回 Vitora / Today 路径。 | 不问“完成了吗”；提交后显示学习信号；可继续告诉 Vitora 更多细节。 |
| Cycle 首页 | 阶段关系 + 能量动态两大卡；Pixel Vitora / TipKit 轻提示；不做日历首页。 | 当前 baseline 已对齐 `17-cycle-target-aligned.png`。 | 后续补低数据/低置信状态、图表 token、Tip 出现/消失规则。 | 首页只放阶段关系和能量动态；执行规格以 `cycle-page/cycle-page-spec.md` 为准。 |
| Cycle 阶段详情 | 解释 Vitora 如何判断、预测窗口、今天意义。 | 已有详情页。 | 将置信度、预测窗口、今天意义做成固定信息架构。 | 显示阶段、置信度/估算感、预测窗口；可回 Cycle。 |
| Cycle 能量详情 / Callout | 图表点选后解释关键点，可问 Vitora。 | 已实现详情和 callout。 | 定义图表点选热区、callout 位置、问 Vitora 转场。 | 点选关键点出现 callout；可问 Vitora；图表不只靠颜色表达。 |
| Support 设置 | 六个 P0 支撑项，实用、低装饰、强可读。 | 已实现较完整。 | 形成 G4 practical surface：列表、危险动作、确认反馈。 | 只显示六个 P0 支撑项；无 VIP/主题/小组件/帮助墙。 |
| 数据来源 / 营养 / 提醒 / 导出 / 隐私 | 不商业化、不医学化、低数据可用、导出/移除有确认。 | 功能路径已覆盖。 | 补空态、错误态、权限拒绝态、完成态文案和动效。 | 导出/移除有确认和完成反馈；日志不含健康数值、记录原文、prompt 或完整 AI 输出。 |

## 3. 页面交付模板

每个页面交付必须按以下 8 项填写，缺一项不得进入工程实现。

| 字段 | 写法 | 示例 |
| --- | --- | --- |
| 页面目标 | 一句话说明用户完成什么。 | Today：用户 3 秒内知道今天状态、依据和可轻试的下一步。 |
| 信息优先级 | P0 / P1 / 可隐藏。 | P0：状态数值、状态词、关键窗口、身体要素、Vitora 建议。 |
| 组件拆分 | 使用 `C-*` 或候选组件名。 | `TodayStatusCard`、`BodyFactorTiles`、`VitoraDailySuggestionCard`。 |
| 状态矩阵 | 列出正常、低数据、空态、错误等。 | richData、lowData、calibrated、aiUnavailable。 |
| 交互规则 | tap、long-press、drag、sheet、return path。 | 状态卡 tap 进详情，long-press 可问 Vitora。 |
| 动效参数 | 时长、缓动、阈值、无障碍替代。 | sheet 320ms spring；Reduce Motion 改 180ms fade。 |
| 视觉 token | 引用 `vt.*`。 | `vt.bg.aura.today`、`vt.glass.g1.clearCard`。 |
| 验收截图 | 目标图、当前图、不可接受错误。 | `ComparisonV2/02-today_before_after.png`。 |

涉及 Pixel Vitora 的页面或组件还必须补充：

- 当前是否继承 `pixel-vitora-ip/` baseline。
- 使用的 IP 状态：`idle`、`listening`、`thinking` 或 `confirming`。
- 使用的道具：`none`、`clipboard`、`pencil` 或 `voice`。
- 对照截图：`ios/QA/Screenshots/ImplementationV1/15-ip-glass-simulator-visible.png` 或新一轮 baseline。
- 是否更新 `pixel-vitora-ip/change-log.md`。

## 4. Motion Spec

### 4.1 Token 档位

| 档位 | 时长 | 用途 |
| --- | --- | --- |
| `vt.motion.fast` | 120-180ms | tap、chip pressed、button feedback。 |
| `vt.motion.base` | 240ms | 普通页面内状态切换、保存反馈。 |
| `vt.motion.sheet` | 320ms | sheet present / dismiss、contextual Vitora。 |
| `vt.motion.ritual` | 480ms | Energy Reveal、Pixel Vitora 进入/呼吸强调。 |

### 4.2 缓动规则

| 场景 | 缓动 | 约束 |
| --- | --- | --- |
| 普通转场 | easeOut | 不要 overshoot。 |
| 玻璃卡 / sheet 回弹 | iOS-like spring | 只用于非危险动作。 |
| 危险确认 | easeInOut | 不用弹性、不用 playful 动效。 |
| Pixel Vitora 呼吸 | 2.8-4s low amplitude loop | 不抢文字阅读。 |
| Reduce Motion | fade / direct state change | 关闭 shimmer、强弹性和长 glow。 |
| Reduce Transparency | higher opacity surface | G1/G2 升级为更白、更高对比 surface。 |

### 4.3 关键交互规格

| 交互 | 触发 | 阶段 | 对象变化 | 验收 |
| --- | --- | --- | --- | --- |
| Energy Bowl / Analysis Prediction | Today 状态卡与 `查看数据` | bowlPressed → detail；dataPressed → analysisPresented | 首页状态卡保持单层高对比综合能量碗与无背景周期线轴；今日分析承载数据小标签和完整实时预测。 | 首页不显示顶部下拉 Energy Ball、数据小标签、实时预测图或三模式切换；今日分析图表有当前时间气泡。 |
| Contextual Sheet | 对象级 ask / chip / `⋯` | sourcePressed → dim → sheetPresented → confirming → saved | 来源卡保持可见但压暗；sheet 用 G3；input dock 贴底。 | 关闭回来源；保存前确认；保存后来源对象更新或显示学习信号。 |
| Vitora Tab 输入 | input dock 聚焦 | idle → typing → sendEnabled → thinking → response | Pixel Vitora 进入 thinking；输入 dock 避开 tab；response card 用 G2。 | 可确认、修改、不保存；AI 不可用时保留手动路径。 |
| Quick Context Chips | chip tap | pressed → selected → expanded → dismissed | chip 轻缩放；展开上下文卡贴近输入区；其他 chips 降低权重。 | 不占满页面；不和主对话抢优先级。 |
| Cycle Chart Callout | 图表点 tap | pointSelected → callout → askVitora | 点位高亮；callout 避免遮挡曲线；`问 Vitora` 打开 contextual sheet。 | 热区不小于 44pt；VoiceOver 读出点位含义。 |
| Support danger action | 导出/账号移除 tap | start → confirm → processing → done | 无 playful 弹性；按钮和状态文案清楚。 | 必须二次确认；完成反馈明确；错误不泄露敏感内容。 |

## 5. 组件补充清单

| 组件 | 必须补齐的设计项 | 禁止项 |
| --- | --- | --- |
| Dynamic Aura Video | 五个周期色视频变体、poster fallback、日期切换 crossfade、Reduce Motion/Transparency 替代。 | 教程录屏残留、每页单独背景、背景形成新 IP。 |
| Pixel Vitora | hero、decor、tab 三种尺寸；idle/listening/thinking/confirming 四状态；blink/breath 参数。 | smooth orb、人类头像、宠物、普通 SF Symbol。 |
| Glass Card | G1/G2/G3/G4 示例；文字对比；Reduce Transparency 替代。 | 纯白 dashboard 卡、过重磨砂导致不可读。 |
| Status Card | 单层高对比综合能量数字 + 状态词 + 查看数据 + 碗下无背景周期线轴。 | 只展示百分比、双层虚影数字、首页数据小标签、首页实时预测图、首页校准 chips 或医疗警报感。 |
| Body Tile | 睡眠、HRV、心率、周期四类 icon、数值、趋势、低数据占位。 | 红点、完成率、任务状态。 |
| Suggestion Card | 建议动作、依据、我试试、换一个、详情、晚间复盘连接。 | toast 后结束、任务清单心智。 |
| Input Dock | voice/keyboard、text 或 inline voice、send、keyboard avoidance、AI unavailable；记录 plus 独立在全局 Dock 右侧。 | 被中央 tab 遮挡；只留 placeholder；输入区混入记录 plus。 |
| Quick Chips | icon+短标签、选中、展开、取消。 | 变成大卡片导航或占满页面。 |
| Sheet | 3/4 高度、稳定标题、来源上下文、关闭/上滑、本地输入、背景全局 Dock 隐藏、保存反馈。 | 直接切走来源页面；未确认保存；sheet 和背景 Dock 叠加。 |
| Tab Bar | 三 Tab、中央 Pixel Vitora face、低凸起、输入避让。 | 第四 Tab、heart icon、黑色大圆。 |
| Chart Callout | 点位、热区、callout 箭头、问 Vitora、无障碍 label。 | 只靠颜色表达趋势。 |

## 6. 截图与 QA 对照

| 对照图 | 用途 |
| --- | --- |
| `ios/QA/Screenshots/ComparisonV2/01-tabs_before_after.png` | Today / Vitora / Cycle 主 Tab 总览。 |
| `ios/QA/Screenshots/ComparisonV2/02-today_before_after.png` | Today 首页、Energy Reveal、日历、Context Sheet、Review。 |
| `ios/QA/Screenshots/ComparisonV2/03-vitora_before_after.png` | Vitora surface、Quick Context、输入 dock、设置入口。 |
| `ios/QA/Screenshots/ComparisonV2/04-cycle_before_after.png` | Cycle 首页、阶段详情、能量详情、callout、设置入口。 |
| `ios/QA/Screenshots/ComparisonV2/05-support_functions_current.png` | Support / Trust 当前功能状态墙。 |
| `ios/QA/Screenshots/ComparisonV2/06-two_design_targets_vs_current.png` | 两张核心目标图与当前核心页面。 |

验收时每个页面必须记录：

- 目标截图。
- 当前实现截图。
- 差异项是否属于允许偏差。
- 若不允许，补充到“设计补充项”或转为新任务。

## 7. 设计规范交付目录

最终交付给工程时，按以下目录组织：

```text
Vitora Design Handoff
├── 01 Vision.md
├── 02 Foundations.md
├── 03 Components.md
├── 04 Screens.md
├── 05 States.md
├── 06 Motion.md
└── 07 QA Checklist.md
```

当前 repo 对应关系：

| 交付文件 | 当前来源 |
| --- | --- |
| 01 Vision | `facts.md`、`design-language-demo.md`、`visual-evidence-map.md` |
| 02 Foundations | `design-tokens.md` |
| 03 Components | `components.md`、本文件第 5 节 |
| 04 Screens | `wireframes.md`、本文件第 2 节 |
| 05 States | `interaction-acceptance.md`、`compliance.md`、`data-privacy-ai-boundaries.md` |
| 06 Motion | `design-tokens.md` 第 10 节、本文件第 4 节 |
| 07 QA Checklist | `quickstart.md`、`ios/QA/manual-qa.md`、`ios/QA/design-handoff-gap-report.md` |

## 8. 后续任务入口

后续若要把视觉目标继续推进到商业级 polish，先把差异转成新 specs/tasks：

1. Today / Vitora / Cycle 主 Tab 先做视觉和 motion polish。
2. 再补 Onboarding / Review / Support 的状态和完成反馈。

## Onboarding Next Visual Direction

后续注册页 / onboarding 视觉方向锁定为“双钛玻璃 + 翻页完成登记”：

- 每一页仍只收集 P0 最小上下文，不新增账号门槛、习惯任务、打卡承诺或商业卡。
- 页面容器使用浅色双层钛玻璃质感：乳白主面、银灰边、柔阴影、低饱和高光。
- 每完成一页登记，触发一次轻量 page-turn / page-curl 过渡；Reduce Motion 下改为淡入或短滑动。
- 该方向目前只作为下一阶段规格，不进入本轮 Today / 输入栏 / Tab 实现范围。
3. 每次 UI 改动后保存 simulator 截图，并更新 `ios/QA/design-handoff-gap-report.md`。
4. 新实现不得破坏 `facts.md` 的 P0 边界：三主 Tab、无打卡、无完成率、HealthKit 可选、Pixel Vitora 一致。
