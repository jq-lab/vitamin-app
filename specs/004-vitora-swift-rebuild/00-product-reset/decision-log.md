# Vitora Swift Rebuild · 决策日志过滤器

> Batch: Product Reset
> 日期：2026-05-03
> 目的：在 canonical specs 和 Swift 实现计划前，记录本次产品 reset 的关键判断。

## 决策记录

| 决策 ID | 日期 | 决策 | 理由 | 证据 | 被拒绝的替代方案 | 后果 | 后续 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| D-001 | 2026-05-03 | 完全忽略 prior Claude-generated rebuild spec set | 用户明确指出 prior generated material 可能有旧截图和理解漂移 | 用户对话指令 | 复用 prior generated 结构或截图 | reset docs 从原始 `Spec/` 和 RN 证据重新开始 | 后续文档保持独立 |
| D-002 | 2026-05-03 | 原始 `Spec/` 作为意图、约束、候选池 | 原始 Spec 仍有稳定产品逻辑、合规、流程、候选功能 | `Spec/facts.md`, `Spec/userflows.md`, `Spec/compliance.md` | 全部丢弃旧文档 | 原始想法被过滤，不被照搬 | 后续 specs 引用过滤后的决策 |
| D-003 | 2026-05-03 | 当前 RN app 是证据，不是产品真相 | 用户已确认当前 app 混乱，不应复刻 | 源码扫描显示 mock 存储、Alert 占位、抽屉占位页 | 把 RN app 当唯一真相 | RN 用于说明存在过什么、哪里失败 | 模拟器只做定点查证 |
| D-004 | 2026-05-03 | 第一阶段目标是 P0 Swift MVP | 干净重建需要先收窄范围 | 用户在计划阶段选择 P0 Swift MVP | 追求原始 Spec 或 RN 全量 parity | inventory 中大量功能被标为 P1/P2/Out | 后续 specs 从 P0 切面开始 |
| D-005 | 2026-05-03 | 用决策表作为主要 reset 格式 | keep/redesign/defer/drop 必须可审计 | 用户选择决策表格式 | 只写叙述性文档 | `feature-inventory.md` 成为功能门 | 后续 docs 引用 inventory ID |
| D-006 | 2026-05-03 | 本 batch 不写实现规格 | 先去噪，再做技术计划 | 用户要求先写四个过滤器 | 现在开始 Swift 架构 | 本 batch 无 API、schema、Swift tasks | 技术 plan 作为后续 batch |
| D-007 | 2026-05-03 | 保留学习循环作为产品核心 | 这是 facts、flows、用户意图中最稳定的部分 | `Spec/facts.md` 核心循环、A/B、复盘 | 转成 tracker 或泛聊天 | P0 必须覆盖 morning state、A/B、record、review | 新 `facts.md` 应以此开头 |
| D-008 | 2026-05-03 | 保留 Today / Vitora / Cycle 三主区 | 心智模型稳定，原始 facts 要求三主区；D-032 后用户面对名称统一为 Vitora | `Spec/facts.md`, `Spec/ia.md`, RN tabs, D-032 | 增加第四个主 Tab | 支撑功能保持二级 | 新 IA 保留三主区 |
| D-009 | 2026-05-03 | P0 收缩抽屉/设置面 | 当前范围太宽，造成 placeholder 噪音 | RN drawer 有大量 later 页面 | 发布宽抽屉路由池 | P0 只暴露必要账户、隐私、数据、来源、提醒表面 | 新 IA 隐藏延期路由 |
| D-010 | 2026-05-03 | A/B 保留为核心，但必须诚实 | A/B 是学习动作，只有即时确认会破坏产品闭环 | `Spec/facts.md` 联动；EV-RN-002 确认当前选择方案后已有提醒时间雏形，但缺少 durable intent 和复盘承接 | A/B 只做装饰按钮 | P0 要么有真实意图与复盘路径，要么简化 UI | Swift 前先写 A/B userflow |
| D-011 | 2026-05-03 | Full energy ritual 进入 P0 Swift MVP | 用户确认它是产品第一印象和快速激活价值的一部分 | 原始 animation spec、RN EnergyOrb、用户决策 | 推迟到 P1 | P0 必须定义一个原生、可交付的最小仪式版本 | 后续视觉 batch 决定范围和验收 |
| D-012 | 2026-05-03 | Vitora 优先服务记录和理解，不优先做泛聊天 | Vitora 价值是上下文捕获和引导，不是泛聊天 | `Spec/pages/luna.md`, EV-RN-003 确认旧 Luna 记录入口存在但发送后缺少解析、确认和保存回流 | 做 chat-first assistant | Vitora surface 要突出上下文、校准、复盘和理解确认 | Vitora spec 定义 capture-confirm-save loop |
| D-013 | 2026-05-03 | Cycle 先做简单 | 当前 Cycle 混合了有用节律、日历和过多高级/商业表面；D-037 后日历归 Today 顶部 | `Spec/pages/cycle.md`, EV-RN-005, D-037 | MVP 发布完整展开页 | P0 保留阶段关系和能量动态，深度分析后移 | Cycle spec 从长期节律背景开始 |
| D-014 | 2026-05-03 | P0 不出现 placeholder 页面 | 占位页会让 app 未完成感很强，并放大范围 | RN drawer placeholder pages | 提前展示未来功能 | 延期功能不可见 | IA 必须定义可见 P0 nav |
| D-015 | 2026-05-03 | 隐私与合规是硬门 | 敏感健康数据需要先建立信任 | `Spec/compliance.md`, RN sanitizer 与 plain SQLite 对比 | 把隐私当后续实现细节 | 产品规格必须包含数据所有权和 LLM 最小化 | 新 compliance 与技术 batch 继续规格化 |
| D-016 | 2026-05-03 | Local LLM / Gemma 可延期实现，但必须提前感知 | 用户明确会在后续引入本地 LLM / agentic usage | RN 无相关实现；用户未来目标 | P0 直接实现本地 agent | P0 产品流保持模型无关，但数据、隐私、AI 规格要避免封死未来路径 | 产品 specs 后单独做 AI architecture batch |
| D-019 | 2026-05-03 | Swift 首发不必须 WeChat 登录 | 用户确认 Q-001 答案 | 用户决策 | 把 WeChat 作为 P0 account gate | FI-002 改为 drop；onboarding spec 后续定义非 WeChat 账户路径 | canonical onboarding spec 前决定具体登录/本地模式 |
| D-020 | 2026-05-03 | P0 具备 HealthKit 能力，但用户可跳过 | 用户确认 Q-002 答案 | 用户决策 | manual-only P0；或强制授权后才能使用 | App 必须在无 HealthKit 授权时继续工作，并有低数据体验 | Swift technical plan 定义 HealthKit 权限和数据降级 |
| D-021 | 2026-05-03 | P0 最小晚间复盘要对比当天干预前后效果 | 用户确认 Q-004 答案 | 用户决策，学习循环要求 | 只做泛总结或推迟复盘 | P0 复盘必须让用户感知 app 介入是否有用，用于快速激活 | userflows/spec batch 定义最小复盘内容 |
| D-022 | 2026-05-03 | 营养补给页面保留 | 用户确认 FI-039 | 用户决策，原始 Spec 候选功能 | 延期或移除该页面 | FI-039 改为 keep；P0 收口为设置/管理页 + Vitora 输入流快捷上下文 | 后续 spec 定义记录字段和保存确认 |
| D-023 | 2026-05-03 | Assistant 上滑 / 升级完整态进入 P0 | 用户确认 FI-026 keep for P0 MVP；D-035/D-036 已重新定义为 Vitora surface 与 contextual sheet upgrade | 用户决策，当前 RN 行为证据 | 删除完整 assistant 态或推迟到 P2 | FI-026 改为 keep / P0；正式目标是 Vitora 默认态、压缩态、输入态、语音态、context sheet 升级完整 Vitora | Vitora userflow/spec batch |
| D-024 | 2026-05-03 | Q-005 收口为 P0 轻抽屉，只显示 P0 必需项 | P0 需要隐私、数据、营养补给和提醒支撑，但不能复刻当前宽抽屉 | Simulator 抽屉检查、`src/app/drawer/index.tsx`、用户对 FI-039 / Q-005 的确认 | 删除抽屉；或展示当前宽抽屉和延期路由池 | facts 增加 F-P0-SUPPORT-002；IA 只保留六个支撑项，延期项不可见 | support / compliance / spec batch 继续细化支撑页 |
| D-025 | 2026-05-03 | 当前 app 必须作为新 specs 的实测 evidence / anti-evidence 输入 | 之前 IA/Userflows 主要依赖源码；用户要求真实点击、滑动和观察动效 | EV-RN-001 到 EV-RN-006：Today、A/B、旧 Luna、记录、抽屉、Cycle、日历和宿主导航污染均已用 Simulator / `iosef` 定点确认 | 只凭源码推断；或把旧截图当证据 | IA/Userflows/Inventory/spec 补充实测证据，但仍不把当前视觉作为 Swift 目标 | 后续每个行为不清的 batch 先用 Simulator 定点确认 |
| D-026 | 2026-05-03 | 视觉批次采用 source decision 分级 | Figma 节点有的仍可用、有的已经失效；当前 RN 有真实交互证据，也有明显噪音 | Figma MCP 读取节点；Simulator / `iosef` 点击、滑动和截图；`visual-evidence-map.md` | 盲目信 Figma；或盲目复刻 RN | `wireframes.md` 对每个 P0 界面标记 `figma-primary`、`hybrid`、`needs-redesign` 等判定 | `components.md`、`tasks-ux.md`、`plan.md` 必须引用 `EV-WF-XXX` 和 wireframe ID |
| D-027 | 2026-05-03 | 每个 P0 用户旅程步骤必须有前端最终参考 | 页面级 wireframe 还不等于旅程级实现索引；用户要求每一步都有最终前端参考 | `reference.md`、`wireframes.md`、`visual-evidence-map.md` | 只用页面截图；或只用流程图而没有前端参考 | 新增 `reference.md`，用 `RF-XXX-XX` 将 `UF-000` 到 `UF-010` 的每一步绑定到 `WF-XXX`、IA、证据或目标线框 | `components.md`、`tasks-ux.md`、`tasks.md` 的前端项必须引用 `RF-XXX-XX` |
| D-028 | 2026-05-03 | 组件和 design token 必须重建为 004 权威层 | Figma 文件没有可复用 variables/components；RN 有交互证据但样式散落且混入噪音 | Figma MCP `373:259`, `301:289`, `301:150`, `301:18`；Simulator Today/Luna/Cycle/Drawer 实测；原始 `Spec/components.md` | 直接复用 RN 样式；或等待实现阶段再临时抽组件 | 新增 `components.md` 和 `design-tokens.md`，组件引用 `C-*`，token 使用 `vt.*` | 后续 `tasks-ux.md`、`tasks.md`、Swift 实现必须引用组件 ID 和 token ID |
| D-029 | 2026-05-03 | 交互验收作为 Swift 实现前质量门 | 规格已覆盖 facts、flows、IA、wireframes、reference、components 和 tokens；进入实现前需要一套可执行的通过/失败标准 | Simulator / `iosef` 复查 Onboarding、Today、Today 记录、旧 Luna 首页、旧 Luna 沉浸态、轻抽屉、Cycle；`interaction-acceptance.md` | 直接从规格进入开发；或只验收视觉接近度 | 新增 `interaction-acceptance.md`，用 `IAC-*` 绑定流程、屏幕、组件、低数据、隐私和合规验收 | `tasks-ux.md`、`tasks.md`、自动化脚本和人工 QA 必须引用 `IAC-*` |
| D-030 | 2026-05-03 | 数据 / 领域模型成为技术方案前的领域权威 | P0 specs 已锁定流程、IA、交互验收和数据边界，但 Swift plan 前需要统一领域对象、状态机、事件和导出 / 删除 / AI 可用性 | `facts.md`、`spec.md`、`userflows.md`、`ia.md`、`data-privacy-ai-boundaries.md`、`interaction-acceptance.md`；RN store / service / migration 源码；Simulator 导出、账号移除、旧 Luna 记录检查 | 直接继承当前 RN migrations；或在 `plan.md` 才临时抽数据对象 | 新增 `data-model.md`，以 `DM-*`、`DE-*`、`DMN-*` 作为 plan / tasks 输入 | `plan.md`、`tasks.md`、`speckit.plan` 必须引用 `data-model.md` |
| D-031 | 2026-05-03 | 手写 SpecKit plan package 作为 `/speckit.tasks` 输入 | 004 specs 已有人工校准的 facts、UX、Figma/RN 证据、组件、交互验收和领域模型；直接让 `/speckit.plan` 重新解释会增加漂移风险 | SpecKit Pro 模板、本地 `.specify/templates/plan-template.md`、`tasks-template.md`、004 全量规格 | 现在直接运行 `/speckit.plan` 生成泛化 plan；或只写单个 `plan.md` | 新增 `plan.md`、`research.md`、`contracts/`、`quickstart.md`，把移动端内部服务契约作为 contracts | 下一批做 SpecKit Handoff；之后再运行 `/speckit.tasks`、`/speckit.analyze` 和分 phase implement |
| D-032 | 2026-05-05 | IA pivot 后，用户面对的 AI assistant 与 app 统一命名为 Vitora | 用户明确希望 app 名和 assistant 名统一，Vitora 是全局 Assistant Layer；旧 Luna 名称造成 Tab / 记录 / 聊天 / 建议心智混乱 | `wireframes-walkthrough-demo.md`, 用户 IA pivot 讨论 | 继续使用 Luna 作为产品角色名 | 正式 specs 的用户文案改为 Vitora；旧 Luna 只允许作为代码迁移债务或历史证据，不再作为产品 truth | facts、userflows、ia、spec、components、tasks 全部更新 |
| D-033 | 2026-05-05 | Today 首页收口为“现在状态 → 身体要素 → Vitora 今日建议” | 用户确认该心智最符合轻记录和 retention；独立记录区会让 app 变成打卡/记录工具 | `wireframes-walkthrough-demo.md` Today 最终 IA | 保留能量球 + AI监测今日 + 今日记录 + 建议入口四块并列 | Today 删除独立记录区；记录变成在状态/要素/建议中校准 Vitora | 更新 Today specs 和 UI tasks |
| D-034 | 2026-05-05 | Energy Ball 改为隐藏式仪式层，而不是首页常驻主 UI | 用户希望保留能量球，但不让它压住 Today 主结构；下拉揭示和晚间复盘更能体现仪式感 | `wireframes-walkthrough-demo.md` Energy Ball 动态 | 首页常驻大球；完全删除能量球 | 首页用曲线，Energy Ball 首次打开/下拉/晚间复盘出现 | 更新 wireframes、components、interaction acceptance |
| D-035 | 2026-05-05 | Vitora Tab 是 AI-native assistant surface，不是普通聊天页或功能 dashboard | 用户希望 Vitora 是活的 assistant 空间，有 Pixel Vitora、上下文、对话、快捷上下文和输入 dock | `wireframes-walkthrough-demo.md`, `design-language-demo.md`, `assets/design_04/vitora_tab.png` | 空白聊天页；功能卡片工作台；旧上滑沉浸聊天独立心智 | 默认态、滚动压缩态、输入态、语音态、context card、rich response、3/4 sheet upgrade 都进入正式规格 | 更新 userflows、ia、components、tasks |
| D-036 | 2026-05-05 | 非 CTA 唤醒 Vitora 先打开 3/4 contextual sheet，上滑再进入完整 Vitora | 这样能保持来源上下文，避免从 Today/Cycle 被硬切到另一个 Tab | `wireframes-walkthrough-demo.md` 全局唤醒规则 | 所有入口直接切到 Vitora Tab；到处放显性问 Vitora 按钮 | 新增 AskableSurface、context menu、callout、TipKit、VitoraContextualSheet | 更新 IA、交互验收和 tasks |
| D-037 | 2026-05-05 | Cycle 首页改为“当前周期阶段与今天 + 能量动态”，日历归 Today 顶部入口 | 用户坚持日历从 Today 左上进入；Cycle 应承载长期节律和能量动态 | `wireframes-walkthrough-demo.md`, `assets/design_04/cycle_d.png` | Cycle 首页放日历预览；继续旧基础概览+日历模型 | Cycle 第一层只放阶段关系卡与能量动态卡；二层提供透明解释和趋势探索 | 更新 facts、ia、wireframes、tasks |
| D-038 | 2026-05-05 | 设计语言锁定为“弥散渐变背景 + 清透拟态玻璃组件 + Pixel Vitora 陪伴体” | 用户拒绝 Apple Health dashboard 风格，选择更高级、AI-native、陪伴感强的视觉系统 | `design-language-demo.md`, `assets/design_04/*` | Apple Health dashboard；smooth orb；human avatar；pet mascot | 正式 tokens/components 必须加入 aura/glass/pixel/IP 状态和 low-lift CTA 规则 | 更新 design-tokens、components、interaction acceptance |
| D-039 | 2026-05-05 | `wireframes-walkthrough-demo.md` 与 `design-language-demo.md` 是本轮 pivot 的临时 high-rule evidence | 两个文档记录了正式 specs 之前的最终对齐决定；必须被拆入正式 specs，而不是被实现直接绕过 | 两个 demo markdown 文件 | 继续只实现旧正式 specs；或只读 demo docs 跳过正式 specs | 正式 specs 全量适配后，demo docs 保留为 evidence archive | 本 batch 执行正式规格系统更正 |
| D-040 | 2026-05-05 | 已完成 T001-T101 保留，但 T102 起必须先进入 IA / Design Pivot Adaptation | 当前 Swift 基础设施有价值，但 UI 到 US5 是旧规格产物；继续旧 US6 会扩大返工 | `tasks.md`, 已完成 Swift 文件与 UI 测试 | 从零重写；或继续旧 `/speckit.implement` | tasks 保留完成历史，T102+ 改为 pivot adaptation first | 更新 plan、tasks、quickstart、handoff |
| D-041 | 2026-05-16 | Today 首屏从下拉 Energy Ball 改为 Energy Bowl 主交互 + 实时预测 | 用户在模拟器观察后要求去掉下拉能量球，直接用能量碗承载状态、依据和实时预测，减少首屏提示和仪式层干扰 | 模拟器截图、用户对 Today 能量碗排版和实时预测的反馈 | 继续保留顶部下拉 Energy Ball；完全删除晚间能量对比 | Today 首屏移除下拉入口；能量碗可点开状态详情，并提供数据/依据入口；晚间复盘保留能量对比表达 | 更新 facts、spec、userflows、ia、wireframes、components、interaction acceptance 和 UI tests |
| D-042 | 2026-05-16 | Today 能量碗文字层和碗体分离，查看依据合并为查看数据/今日分析 | 用户在模拟器观察后指出能量碗、数字、标签和状态文案粘连，且查看依据应和睡眠/HRV/心率/周期数据合并展示 | 模拟器截图、用户对能量碗排版和身体要素横向展示的反馈 | 保留右下角悬浮查看依据；让碗体和文字继续叠在一起 | 碗体下移；监测标签上移并在行末提供 `查看数据`；点击进入 `今日分析`，横向展示身体要素并解释综合判断 | 更新 facts、wireframes、components、interaction acceptance、quickstart 和 UI tests |
| D-043 | 2026-05-16 | Vitora 输入改为全局 Dock，Tab 与输入职责分离 | 用户录屏显示语音态挤压成竖排，输入区混入周期小花和多余按钮，缺乏主次和节奏 | 用户录屏、输入栏截图、当前 Swift `VitoraInputDock` 证据 | 只修 Vitora Tab 局部输入；继续把 Tab 头部和输入放进同一大玻璃容器 | Today / Vitora / Cycle 底部使用同一 Vitora Dock 框架；Tab 只负责切换；输入区只保留语音/键盘、文字或内联语音条和发送。后续 D-046 收敛为仅 AI 管家页展开输入条，并移除输入内 `+`。 | 更新 facts、wireframes、components、interaction acceptance、tasks 和 UI tests |
| D-044 | 2026-05-16 | Today 首屏模式切换改为三项碗底光源托盘 | 用户指出数字不够突出，说明文字干扰，五项直线切换和能量碗不够和谐；心率/HRV 只需保留在查看数据依据里 | 用户截图、对能量碗数字和模式切换的反馈 | 继续五项直线分段切换；把心率/HRV 从今日分析完全删除 | 放大数字；移除数字上方 `今天` 和标签上方 `监测到`；首屏切换只显示综合/睡眠/周期，并用碗底光源托盘承接碗体 | 更新 facts、wireframes、components、interaction acceptance、tasks 和 UI tests |
| D-045 | 2026-05-17 | 全局 Dock 上排改为左侧 Tab + 右侧快捷记录，AI 管家触发展开输入 | 用户指出 Tab 切换应靠左，右侧需要独立记录快捷键，输入条只在 AI 管家页自动展开，不应被记录键触发 | 用户截图、对全局 Dock 信息架构和输入焦点的反馈 | 继续居中三 Tab；把记录混进输入胶囊；点击记录时切到 AI 管家并修改草稿 | Dock 上排左侧为 Today / AI管家 / Cycle，右侧为 `记录` 快捷键；记录打开 Vitora contextual sheet 且不切 Tab；点击 `AI管家` 才聚焦全局输入 | 更新 facts、wireframes、components、interaction acceptance、tasks 和 UI tests |
| D-046 | 2026-05-17 | 非 AI 页收起输入条，记录改为独立圆形 `+` | 用户明确纠正：Today / Cycle 只应显示 Tab 切换和记录快捷键，语音输入条只在 AI 管家展开；输入条内部不应再有 `+` | 用户截图、对上一轮实现的纠正反馈 | 继续在 Today / Cycle 显示输入条；保留输入内 `+`；右侧记录继续使用文字 pill | Today / Cycle 底部仅显示居中三 Tab 和右侧圆形 `+`；AI 管家页展开输入条；输入条只含语音/键盘、文本/语音条和强化发送按钮 | 更新 facts、wireframes、components、interaction acceptance、vitora-page spec、tasks 和 UI tests |
| D-047 | 2026-05-17 | Today 首屏收敛为综合能量碗 + 周期线轴 + 今日建议，完整实时预测移入今日分析 | 用户要求把睡眠/周期首页预测切换和首页实时预测图去掉，在碗下放周期线轴，并删除首页校准 chips；Dock 按图二改为三 Tab 同胶囊 + 右侧独立 `+` | 用户截图、对 Today 首屏与 Dock 样式的反馈 | 继续保留首页三模式切换、实时预测图和 `告诉 Vitora/睡得浅/压力大` chips；把睡眠/周期依据完全删除 | Today 首页固定综合能量；碗下展示周期线轴；`查看数据` 的今日分析展示综合实时预测和身体要素四卡；底部 Dock 三 Tab 同处居中玻璃胶囊，右侧独立圆形 `+` | 更新 facts、wireframes、components、interaction acceptance、quickstart、tasks 和 UI tests |
| D-048 | 2026-05-17 | Today 能量视觉、周期线轴和 Dock/Input 状态稳定性修正 | 用户指出能量数字有双层虚影、首页数据小标签应只进今日分析、周期条不应有背景波浪，且输入框和 title 栏反复串页 | 用户截图、对能量视觉、周期线轴、今日建议和 Dock/Input 的反馈 | 保留点阵双层数字；首页继续显示数据小标签；周期线轴继续玻璃背景/波浪；全局 Dock 继续用 zIndex 遮罩并在 sheet 下透出 | 能量数字改为单层高对比；首页只保留查看数据入口，数据小标签进今日分析；周期线轴改为无背景平滑曲线并按阶段着色；今日建议更行动化；全局 Dock 由 safe area 承载且 sheet 展示时隐藏，contextual sheet 使用稳定标题和本地输入 | 更新 facts、wireframes、components、interaction acceptance、quickstart、tasks 和 UI tests |
| D-049 | 2026-05-17 | Today 建议卡、能量碗和周期线轴进一步拟物收敛 | 用户指出身体翻译应放到今日建议后方且字体更大，建议应是 `吃+休息 / 运动+吃 / 休息+运动` 组合轮换；能量状态词应在 68 下方，碗形需更接近参考图，周期线轴应围绕碗底光晕成圆弧且文字全部在下端 | 用户截图、对建议卡、能量碗还原度和周期圆弧的反馈 | 继续解释型建议卡；`换一个` 打开 Vitora 浮层；周期仍为横向曲线并在上方显示气泡；状态词压在碗下 | Today 建议卡改为大字号身体翻译 + 两条组合推荐；`一件提醒` 进入现有提醒/分析路径，`换一换` icon 本地循环；周期线轴改为三阶段圆弧，仅展示前一段/当前段/下一段，全部文字放在下端；能量状态词直接跟随数字 | 更新 facts、wireframes、components、interaction acceptance、quickstart、tasks 和 UI tests |
| D-050 | 2026-05-17 | Today 圆弧反向上移，AI 管家页进入与上下文卡稳定 | 用户指出 Today 碗底圆弧方向理解反了，`查看数据` 应在状态词旁；AI 管家点击进入会直接大展开并串到不稳定状态，上拉应只展示完整聊天框；睡眠和营养卡应与周期卡结构一致 | 用户截图、AI 管家页交互反馈、当前 Swift `VitoraAssistantSurfaceView` 三态拖拽实现证据 | 继续中间上凸圆弧；`查看数据` 单独占一行；AI 管家进入默认 expanded，并用自由拖拽在三态间跳；周期使用专属报表卡而睡眠/营养用简短卡 | Today 状态词与 `查看数据` 同行；周期圆弧反向为碗底下沉弧并上移；AI 管家进入固定实体卡片态，上拉阈值进入聊天聚焦态且不切 Tab；周期/睡眠/营养统一为 `VitoraContextSummaryCard` | 更新 facts、wireframes、components、interaction acceptance、vitora-page spec、quickstart、tasks 和 UI tests |
| D-051 | 2026-05-17 | Today 水滴入碗动效与 Cycle 周期回顾首页升级 | 用户要求水滴从屏幕最顶端下落并进入能量碗，水位按能量状态积累；周期圆弧需上移到碗底白色光晕；Cycle 页面要按参考图完善为周期回顾卡片 | 用户截图、对 Today 动效和 Cycle 周期回顾卡的专业动效/视觉反馈、当前 `EnergyDropEmitter` 只做局部粒子和当前 Cycle 首页仅阶段/能量两卡的代码证据 | 继续局部星光粒子；让水位只做静态渐变；Cycle 继续旧阶段关系卡 + 能量动态卡首页 | Today 新增从屏幕顶部到碗口的水滴/涟漪/水位动效，Reduce Motion 静态水位兜底；周期三阶段圆弧嵌入碗底白色光晕；Cycle 首页升级为 `周期回顾`、等距花田、三件事总结、能量动态和三张洞察卡，仍不引入日历首页、打卡或任务心智 | 更新 facts、spec、wireframes、components、interaction acceptance、cycle-page spec、tasks、UI tests 和 Cycle change-log |
| D-052 | 2026-05-17 | 花园手册 MVP 收敛为轻闭环，Cycle 从花田地图改为 30 天成长册 | 用户提供 `Vitora_Garden_MVP_Document.md` 并标注 Today 周期圆弧应下移到红线区域，和碗保持约一个字空间；文档要求不新增 Tab、不做高成本花田地图，用花园手册 + 晚间复盘 + 每日成长卡片 + 周期成长册形成闭环 | 用户截图、`/Users/youxiang/Desktop/Vitora_Garden_MVP_Package 2/Vitora_Garden_MVP_Document.md`、当前 Cycle 花田地图实现证据 | 新增花园 Tab；保留花田地图下拉；在花园手册里直接种下；引入商城/VIP/露珠价格/枯萎/失败/红点 | Today 周期圆弧下移到碗外下方；Today 新增早晨成长反馈和花园手册 Sheet；AI 管家新增晚间复盘种子选择卡；Cycle 首页和详情改为 `30 天成长册`，不展示花田地图、打卡、连续天数或完成率 | 更新 facts、spec、wireframes、components、interaction acceptance、cycle-page spec/QA/change-log、vitora-page change-log、UI tests 和 Swift 实现 |
| D-053 | 2026-05-18 | 去除成长册、花园手册、种子选择和花园化晚间复盘包装 | 用户连续截图指出 `30 天成长册`、早晨成长反馈、花园手册入口和种子化晚间复盘卡全部需要去除 | 2026-05-18 用户截图与明确指令 | 继续保留四类花园/成长卡可见入口；把晚间复盘做成种植仪式 | Today 只保留状态主路径和 Vitora 今日建议；Cycle 只保留三件事总结、能量动态和节律洞察；Vitora 只在复盘可用时显示最小 `今晚复盘` 入口，不展示种子选择 | 更新 facts、spec、wireframes、components、interaction acceptance、cycle-page docs、vitora-page docs、UI tests 和 Swift 实现 |
| D-054 | 2026-05-18 | 全 App 背景升级为原生浅霜分层系统 | 用户提供干净高级的浅色参考图，并要求 1:1 拆解其干净原因后应用到 App 背景和子页面层次 | 2026-05-18 用户参考图与实现计划 | 直接使用参考图；继续使用旧水纹素材作为全屏底；每页单独写不同背景 | 新增 `PremiumAuraBackground`，Today / Vitora / Cycle / Sheet / Onboarding / Support 使用统一低饱和雾层、微纹理和白霜玻璃层级；旧 `WaterAuraReferenceBackground` 作为兼容 wrapper | 更新 facts、dynamic-aura-background docs、UI tests、截图验收 |
| D-055 | 2026-05-18 | 复盘种子实验层回归为建议反馈可视化 | 用户明确北极星指标是“Vitora 给出正确建议 → 用户愿意试 → 用户反馈有帮助 → Vitora 学得更准”，种子只用于把建议反馈变成可感知生长证据 | 2026-05-18 用户给出的睡眠种子玩法计划 | 完整花田地图、30 天成长册、商店货币、每日 AI 生图、连续天数、完成率或失败惩罚 | 允许晚间复盘反馈后选择 3 类睡眠种子；Today 建议卡显示昨晚种子状态和生理原因；AI 管家解释种子半开原因；Cycle 增加低权重 `本周期花架证据`，不作为首页主视觉或任务系统 | 更新 facts、spec、wireframes、components、interaction acceptance、cycle-page docs、vitora-page docs、UI tests 和 Swift 实现 |
| D-056 | 2026-05-18 | 全 App 色调改为 Warm Paper Aura 强层级 | 用户指出当前仍是死白，组件和背景同色；明确选择“暖米纸强对比 + 底色分区柔影”，要求重新定色调和设计规范 | 2026-05-18 用户参考图一/图二与 Warm Paper Aura 实施计划 | 继续用瓷白背景；只给能量碗局部加背景；用重橙照片或大面积蓝色渐变制造层级 | L0 改为暖米纸底，L1 主卡为珍珠白，L2 内嵌组件为暖灰白；`PremiumAuraBackground`、`PearlGradientSurface`、`GlassSurface` 统一使用暖米纸分区和短柔影 | 更新 facts、design tokens、dynamic-aura-background docs、Swift design system 和截图验收 |
| D-017 | 2026-05-03 | 不复制当前 RN 视觉 | 用户已否定当前 app 质量，视觉需要 reset | RN 源码和模拟器证据 | 逐像素复刻当前 app | 未来视觉真实来源是 Figma + iOS 判断 | 视觉 batch 必须读取 Figma |
| D-018 | 2026-05-03 | 合规 copy 集中管理，本 batch 不复制全文 | reset filters 不应制造过期法律文本 | `Spec/compliance.md` 是当前来源 | 把所有 copy 粘进 reset docs | reset docs 只引用合规来源和约束 | 新 canonical compliance spec 再复制批准文案 |

## 已解决产品问题

| 问题 ID | 答案 | 后果 |
| --- | --- | --- |
| Q-001 | Swift 首发不必须 WeChat 登录 | FI-002 drop；onboarding 后续定义非 WeChat 账户路径 |
| Q-002 | P0 具备 HealthKit 能力，但对用户可选 | App 必须支持未授权/无设备的手动和低数据模式 |
| Q-003 | Full energy ritual 进入 P0 | 视觉 batch 要定义最小可交付仪式版本 |
| Q-004 | P0 最小晚间复盘是“对比 app 当天干预前后的效果” | userflows/spec batch 必须把复盘做成价值激活点，而不只是总结 |
| FI-026 | Vitora contextual sheet / full assistant upgrade 保留在 P0 | Vitora specs 必须覆盖默认态、压缩态、输入态、语音态、rich response、3/4 sheet 升级完整 Vitora |
| Q-005 | P0 保留轻抽屉，只显示 P0 必需支撑项 | facts 与 IA 已收口；宽抽屉、延期项、占位项不进入 P0 可见导航 |

## 开放产品问题

当前无阻塞 Product Reset 和 IA 的开放问题。后续若出现新的 P0 入口争议，先补充本日志，再进入实现规格。

## 决策使用规则

后续 specs 必须至少引用以下之一：

- 本文件中的 Product Reset decision ID
- `feature-inventory.md` 中的 feature inventory ID
- 其他 reset docs 中的产品或 UX 原则

无法追溯到这些来源的功能，不进入 Swift rebuild 范围。
