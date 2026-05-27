# Vitora Tab Change Log

## 2026-05-19 · 真实花种接入复盘种子证据

目的：按 D-058，把睡眠种子从抽象方向图标升级为真实花种轻证据层，但不恢复花园化入口。

改动：

- AI 管家复盘分析卡、种子方向选择和花朵阶段对比读取统一 `SleepSeedCard` 的真实花种与阶段。
- 用户仍只选择 `恢复 / 留余量 / 轻动`，不直接从 10 种花中选择。
- 不新增花园 Tab、花园手册、成长册、完成率、连续天数或失败惩罚。

## 2026-05-19 · 底部 Tab 与 AI 输入快捷栏分层

目的：按用户最新交互计划，把主 Tab 切换和 AI 输入快捷键拆成两个清晰层级，减少 `AI管家`、麦克风、发送和全局 `+` 在底部区域的职责混淆。

改动：

- `GlobalVitoraDock`：AI 管家页显示上层输入快捷栏，下层继续保留三主 Tab 和右侧独立圆形 `+`；Today / Cycle 不显示输入栏。
- `VitoraInputDock`：新增 assistant floating / sheet local 样式分支，AI 页使用带低像素 Vitora 标识的浮动输入栏，contextual sheet 保持本地输入栏。
- `VitoraViewModel`：发送后增加短暂 `Vitora 正在整理...` 状态轨；语音录制态继续显示内联波形和键盘返回入口。
- `AI管家` Tab 点击只切换页面，不再自动聚焦键盘；点击输入栏本身才进入输入。

测试：

- Build：通过，`xcodebuild -workspace Vitora.xcworkspace -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`。
- UI 测试尝试运行时被既有 `VitoraTests` Expo module 编译问题拦截，未进入 UI 用例执行。

截图：

- `/private/tmp/vitora-tab-input-today.png`
- `/private/tmp/vitora-tab-input-ai.png`
- `/private/tmp/vitora-tab-input-cycle.png`
- `/private/tmp/vitora-tab-input-voice.png`
- `/private/tmp/vitora-tab-input-processing.png`

## 2026-05-18 · 睡眠种子解释回归为建议反馈说明

目的：按用户最新“睡眠种子玩法”计划，AI 管家不恢复花园化入口，而是解释种子为什么半开、今日建议如何帮助它，以及哪些反馈会让 Vitora 判断更准。

改动：

- `vitora-page-spec.md`：新增 Sleep Seed Explanation 规则。
- 睡眠种子只能作为建议反馈证据，不新增第四 Tab、不显示商店、货币、完成率、连续天数或失败惩罚。
- 点击种子解释应打开来源为 `睡眠种子` 的上下文 sheet，继续承接 Vitora 的解释和校准。

## 2026-05-18 · 移除晚间复盘种子包装

目的：按用户最新截图反馈，移除 AI 管家中的花园化晚间复盘卡和种子选择预览。晚间复盘仍保留为低成本学习路径，但只在复盘可用时展示普通 `今晚复盘` 入口，不展示薄荷芽、小雏菊、月光薰衣草或 `种下今晚的种子`。

改动：

- `VitoraAssistantSurfaceView`：删除 `GardenEveningReviewEntryCard` 和 `MiniSeedGlyph`，改为复用普通 `EveningReviewEntryCard`。
- 复盘入口仅在 `environment.isEveningReviewAvailable` 时出现；未到时间不再以花园/种子卡占据首屏。
- 保持无红点、无连续打卡、无完成率、无失败/枯萎/商城/VIP 表达。

测试：

- `EveningReviewUITests` 增加 `种下今晚的种子`、`薄荷芽`、`小雏菊` 负向断言。
- 本轮组合 UI 回归通过：13 tests，0 failures。

截图：

- `ios/QA/Screenshots/ImplementationV1/20260518-remove-seed-review-vitora.png`

## 2026-05-17 · 晚间复盘种子选择入口

目的：按 `Vitora_Garden_MVP_Document.md`，让 AI 管家承接“晚间复盘时选择种子”的轻闭环，不把花园手册做成直接种植或游戏商城。

改动：

- `VitoraAssistantSurfaceView`：在非周期 topic 下展示 `晚间复盘` 卡，未到时间时引导用户先补充身体变化，到了复盘时间直接进入复盘。
- 新增种子选择预览：薄荷芽、小雏菊、月光薰衣草；卡片展示影响因素和今晚轻动作。
- 保持无红点、无连续打卡、无失败/枯萎/商城/VIP 表达。

## 2026-05-17 · AI 管家聊天聚焦态与统一上下文卡

目的：修正点击 AI 管家后直接大展开、上拉状态串页，以及周期/睡眠/营养上下文卡结构不一致的问题。

改动：

- `VitoraAssistantSurfaceView`：进入 AI 管家时固定使用实体 hero 卡片态，不再默认 `.expanded` 大展开。
- 移除自由拖拽三态跳转，改为 ScrollView 上拉阈值进入聊天聚焦态；聚焦后隐藏 `Vitora 知道` hero 卡，内容从日期行、topic rail、说明、消息和能力反馈开始展示，不切回 Today。
- `VitoraAssistantSurfaceView`：删除周期专属报表卡与睡眠/营养简短卡分叉，新增统一上下文摘要卡，覆盖 `周期 / 睡眠 / 营养`。
- `vitora-page-spec.md` 同步更新 hero 进入态、聊天聚焦态和统一上下文卡规则。

测试：

- 已通过 `xcodebuild build`、Today/AI 管家 4 个关键 UI tests，以及 XXXL 动态字体 Accessibility 测试。

## 2026-05-16 · Header 三态、IP 夹层与霜态玻璃统一

目的：解决 Vitora 聊天页展开/折叠时 Hero 遮挡日期与 topic rail、IP 小人材质和位置不对、底部出现蓝灰绿色旧背景残留的问题。

改动：

- `VitoraCompressedHeader`：将 `compressed` 升级为 `VitoraHeaderMode.expanded / docked / fullChat`，用统一 metrics 管理顶部按钮、Hero、日期行和 topic rail 的间距。
- `VitoraKnowledgeHeroCard`：删除中文 `维他命之道`，只保留低权重 `Vitora 知道`；IP 小人移到背板与前景卡之间，靠近右侧分栏线，展开态露出更多、折叠态不挡字。
- `PixelVitoraView`：新增 `materialStyle` 渲染变体，Hero 小人、消息头像、Tab face 和 ambient background 共享同一 IP baseline，但按场景调整白色霜态外壳、局部透彩和 glow 强度。
- `VitoraAssistantSurfaceView`：底部旧 cyan/green scrim 改为中性白色霜态渐隐，减少输入栏附近蓝灰绿色残留；topic 仍只保留 `周期 / 睡眠 / 营养`。
- Today / Cycle 可见卡片：优先改用 `whiteResting / whiteActive` 霜态玻璃变体，弱化背景纹理穿透和杂色卡片底。
- `vitora-page-spec.md` 与 `pixel-vitora-ip-spec.md` 同步记录三态 Header、IP 夹层位置和材质变体规则。

测试：

- Build：通过，`xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -derivedDataPath /private/tmp/vitora-derived-header-ip build`。
- UI 回归：通过，`VitoraAssistantSurfaceUITests` + `VisualLanguageSmokeTests`，3 tests passed，0 failed。

## 2026-05-15 · Folder Card 展开/折叠分区与 IP 暴露

目的：修正 Vitora 顶部 folder card 在折叠态右侧分区过空、小人几乎不可见，以及展开/折叠状态缺少明确布局指标的问题。

改动：

- `VitoraKnowledgeHeroCard`：右侧摘要区加宽，分割线左右间距重新分配，让左侧三项身体数据和右侧能量/IP 形成明确分块。
- `VitoraKnowledgeHeroCard`：Pixel Vitora 从 38/44pt 小图标提升为折叠 82pt、展开 112pt 的低实体化陪伴层；去掉导致它被白玻璃洗掉的强混合模式和过量 blur，改为正常混合、轻模糊、暖色 glow。
- `VitoraCompressedHeader`：折叠态 hero 容器高度收紧，卡片仍位于顶部按钮下方，保证返回、静音、更多按钮保持独立可点。
- `vitora-page-spec.md`：同步最新规则：topic 只保留 `周期 / 睡眠 / 营养`；Hero 左栏为三项身体上下文主信息，右栏为能量数字与可见 IP；展开态小人暴露面更大，折叠态保护 top controls。

测试：

- Build：通过，`xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`。
- UI 回归：通过，`VitoraAssistantSurfaceUITests` + `VisualLanguageSmokeTests`，3 tests passed，0 failed。

截图：

- `ios/QA/Screenshots/ImplementationV1/58-vitora-folder-ip-right-pane-visible.png`

## 2026-05-15 · 顶部能量信息卡、IP 状态与输入光源

目的：修正 Vitora hero 仍把左侧当作 IP 展示位、卡片空间挤压和输入栏选中态光源不足的问题；让首屏第一眼回到“今日能量 + Vitora 知道”的信息卡。

改动：

- `PixelVitoraState`：新增 `sleeping`、`energetic`、`questioning` 三个状态，用于睡眠、精神、聆听/互动等语境，仍保持柔体彩色小人与低像素眼 baseline。
- `VitoraKnowledgeHeroCard`：左侧从 `Pixel Vitora` 文案 + 实体小人改为今日能量数字模块：`68%`、`今日能量`、`下午 14:00 附近可能低谷`。
- `VitoraKnowledgeHeroCard`：右侧上下文收敛为三条：`黄体期 Day18`、`睡眠 7.2h · 略低`、`HRV ↓8%`，并缩小间距避免文字跑出卡片。
- `VitoraKnowledgeHeroCard`：背后 IP 改为低透明、模糊、screen blend 的去实体化氛围层，不再作为前景主内容。
- `VitoraCompressedHeader`：压缩 hero 容器高度与顶部分布，减少展开状态底部无效留白，保留按钮、hero、日期行的独立空间。
- `VitoraInputDock`：`今日聊天管家` 选中 pill 增加顶部垂直柔白光源、局部 bloom 和顶部 rim；未选中入口降低透明度。
- `VoiceSignalWaveform`：只有音量明显升高时才增强彩色光和波形高度，普通 listening 保持克制。
- `vitora-page-spec.md` 与 `pixel-vitora-ip-spec.md` 同步记录新状态、hero 信息结构和输入栏选中态光源规则。

测试：

- Build：通过，`xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`。
- 关键 Vitora 交互测试：通过，`VitoraAssistantSurfaceUITests/testVitoraTabIsAssistantSurfaceNotEmptyChat`。

截图：

- `ios/QA/Screenshots/ImplementationV1/50-vitora-energy-hero-spotlight.png`
- `ios/QA/Screenshots/ImplementationV1/51-vitora-energy-hero-strong-voice.png`

## 2026-05-15 · 单体 Folder Card、低像素头像与日期日历入口

目的：修正上一版仍像两张卡叠放的问题，并把日期上下文恢复为可点击的周期日历入口；同时把 Vitora 留言头像从缩小版 IP 改为更接近目标的乳白磨砂方形头像。

改动：

- `VitoraCompressedHeader`：新增 `onOpenCalendar`，日期行 `今日 · 5月5日（周二） · 黄体期 Day18` 变为无背景文本按钮，点击后打开本页周期日历 sheet。
- `VitoraAssistantSurfaceView`：新增 `showsCycleCalendar` 与 `selectedCycleDay` 状态，接入 `TodayCalendarSheet`；关闭后仍停留在 Vitora Tab，`问 Vitora` 会切回周期上下文卡。
- `VitoraKnowledgeHeroCard`：不再让背板和前景卡分别绘制独立背景；改为 `folderShell` 统一承载彩色背板、前景文件夹页片、凹口 seam、统一 rim 和阴影。
- `VitoraCompressedHeader`：补足 hero 容器真实高度，并拉开 topic selector 与日期行间距，避免日期上下文被 hero 或下方 topic rail 视觉遮挡。
- `PixelVitoraMessageAvatar`：重做为圆角方形乳白磨砂头像，内部只保留一小团淡粉橙暖光；眼睛改为分段低像素小方块，避免连续竖条和强彩色云雾。
- `VitoraAssistantSurfaceUITests`：增加日期行打开/关闭周期日历 sheet 的断言。
- `vitora-page-spec.md` 与 `pixel-vitora-ip-spec.md` 同步记录日期日历入口、单体 folder card 和 message avatar 的低像素眼规则。

测试：

- Build：通过，`xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`。
- 关键 Vitora 交互测试：通过，`VitoraAssistantSurfaceUITests/testVitoraTabIsAssistantSurfaceNotEmptyChat`。
- Vitora assistant / voice / record send / visual UI tests：通过，5 tests passed，0 failed。

截图：

- `ios/QA/Screenshots/ImplementationV1/49-vitora-folder-avatar-calendar-date-visible.png`

## 2026-05-15 · 顶部文件夹融合、按钮交互与留言头像

目的：解决 Vitora 顶部卡看起来像两张独立卡片、返回/静音按钮点击无反馈、Vitora 留言头像仍像圆形完整 IP 的问题。

改动：

- `VitoraCompressedHeader`：顶部返回、静音、更多按钮改为真实交互；返回切到 Today，静音切换 `speaker.wave.2` / `speaker.slash` 并暴露状态，更多继续打开设置面板。
- 顶部按钮提升交互层级，按钮固定 44pt 热区；Hero 卡、后方 IP 和光效层关闭 hit testing，避免视觉层吃掉点击。
- `VitoraKnowledgeHeroCard`：背板与前景卡收敛为统一文件夹式组件，共用外层阴影、银白 rim 和磨砂材质；前景卡顶部凹口更明确地咬住背板。
- 二次优化：放弃整张 envelope 大填充，避免把日期和 topic 区误框进 hero；改为背板与前景卡宽度对齐，并弱化各自独立描边。
- `PixelVitoraView`：新增 `PixelVitoraMessageAvatar` 紧凑头像变体，用 38pt 圆角方形磨砂玻璃、轻彩色雾面和两个小像素眼替代完整圆形 IP。
- `VitoraAssistantSurfaceView`：Vitora 首条留言左侧头像切换为 `PixelVitoraMessageAvatar`。
- `vitora-page-spec.md` 与 `pixel-vitora-ip-spec.md` 同步记录文件夹卡单组件融合、顶部按钮交互和 message avatar 规则。

测试：

- Build：通过，`xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`。
- Vitora assistant / voice / record send / visual UI tests：通过，5 tests passed，0 failed。
- 二次优化后关键交互回归：`VitoraAssistantSurfaceUITests/testVitoraTabIsAssistantSurfaceNotEmptyChat` 通过。

截图：

- `ios/QA/Screenshots/ImplementationV1/43-vitora-folder-buttons-avatar.png`
- `ios/QA/Screenshots/ImplementationV1/46-vitora-folder-width-aligned.png`

## 2026-05-15 · 顶部卡片下移、日期行轻量化与默认解释卡移除

目的：按最新视觉反馈，减少 Vitora 首屏卡片堆叠，让顶部按钮保持独立，并让日期上下文从玻璃组件退回轻量文本。

改动：

- `VitoraViewModel`：默认不再预置 `Vitora 理解为` rich response；发送后仍插入 `更新后的判断`。
- `VitoraCompressedHeader`：Hero 文件夹卡整体下移，日期上下文改为 `今日 · 5月5日（周二） · 黄体期 Day18` 左对齐文本行，去掉 sparkles icon、背景和 chevron。
- Hero 背板颜色调回柔白、粉橙、淡紫、少量冷蓝空气感，降低大面积青绿色。
- `vitora-page-spec.md` 同步记录 Date Context Line、默认 rich response 禁止常驻和 hero 色彩边界。
- UI 测试增加断言：默认 Vitora 首屏不显示 `Vitora 理解为`，日期三段文本可见。

测试：

- Build：通过，`xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`。
- Vitora assistant / legacy assistant / record send / visual UI tests：通过，5 tests passed，0 failed。

截图：

- `ios/QA/Screenshots/ImplementationV1/42-vitora-header-date-richresponse-cleanup-lowered.png`

## 2026-05-15 · 移除“可以直接问”固定问题栏

目的：按最新截图反馈，移除 Vitora 聊天页中占据纵向空间的 `可以直接问` 固定问题列表，减少聊天内容堆叠。

改动：

- `VitoraAssistantSurfaceView`：移除 `DirectQuestionStrips` 首屏渲染。
- `vitora-page-spec.md`：首屏顺序删除 Direct questions；明确推荐问题只进入动态 placeholder 或后续 AI 回复追问。
- UI 测试同步改为确认 `可以直接问` 不再出现，避免后续回归恢复。

测试：

- Build：通过，`xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`。
- Vitora assistant / legacy assistant / record send / visual UI tests：通过，5 tests passed，0 failed。

## 2026-05-15 · Topic Selector 独立化与卡片右上角取消

目的：把 `周期 / 睡眠 / 营养 / 情绪 / 能量` 从 `今天想聊什么` 入口中拆出来，恢复为独立组件；详情卡默认不占空间，点击 topic 后才出现。

改动：

- `VitoraAssistantSurfaceView`：将 topic 区改为独立横向 `ChatTopicSelector`，不再放进 `今天想聊什么` 折叠入口。
- 默认状态不显示任何上下文详情卡。
- 点击 `周期` 后恢复 `月经周期报表` 卡片；卡片右上角新增取消按钮。
- 点击 `睡眠 / 营养 / 情绪 / 能量` 会切换为对应轻量上下文卡。
- 点击卡片右上角取消后，详情卡收起且不保留空白占位；topic selector 仍保留。
- 点击另一个 topic 时直接切换卡片，不需要先取消。
- `vitora-page-spec.md` 同步更新 Topic Selector / Context Card 规则。

测试：

- Build：通过，`xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`。
- Vitora assistant / legacy assistant / visual UI tests：通过，4 tests passed，0 failed。

## 2026-05-15 · 聊天主题默认隐藏与取消收起

目的：让 `周期 / 睡眠 / 营养 / 情绪 / 能量` 这些话题卡不再常驻占位，减少首屏视觉噪音，并提供明确的取消路径。

改动：

- `VitoraAssistantSurfaceView`：新增 `ChatTopicDisclosure` 状态容器，默认只显示 `今天想聊什么` 轻入口。
- 点击入口后展开横向 `周期 / 睡眠 / 营养 / 情绪 / 能量` topic rail。
- 展开态右侧新增取消按钮，点击后收起 topic rail；若当前有周期上下文报表，也一起收起。
- Topic rail 仍保留原有上下文选择逻辑和 accessibility id，避免影响输入、发送和语音路径。
- `vitora-page-spec.md` 同步更新默认隐藏、点击展开、取消收起和动效规则。

测试：

- Build：通过，`xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`。
- Vitora assistant / legacy assistant / visual UI tests：通过，4 tests passed，0 failed。

## 2026-05-15 · 聊天主题横向化与输入占位轮换

目的：解决 Vitora 页顶部组件互相遮挡、下方聊天内容堆叠过多、输入框提示语不够像聊天入口的问题。

改动：

- `VitoraCompressedHeader`：压缩顶部 hero 垂直占用，补充右侧标题安全区，确保返回、静音、更多按钮不被卡片或标题互相遮挡。
- `VitoraAssistantSurfaceView`：把 `周期 / 睡眠 / 营养 / 情绪 / 能量` 从下方大卡改成日期条下方的横向话题 rail，支持左右滑动选择。
- 移除下方大号“今日聊天管家”主题卡，减少聊天内容堆叠；保留主题选择的原有逻辑和 accessibility id。
- 输入框 placeholder 改为轮换问题：`今天想问什么？`、`为什么今天容易低谷？`、`今天怎么安排更轻一点？`、`我可以补充一件事...`，每 2 分钟切换一次；用户输入或录音时暂停切换。
- `vitora-page-spec.md` 同步更新首屏顺序、Topic Rail、Input Dock placeholder 和 motion/禁用规则。

截图：

- `ios/QA/Screenshots/ImplementationV1/37-vitora-chat-topic-rail.png`

测试：

- Build：通过，`xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`。
- Vitora assistant / visual UI tests：通过，3 tests passed，0 failed。

## 2026-05-14 · Hero 文件夹式融合卡片

目的：把 Vitora 顶部卡从“彩色背板 + 白色信息卡上下分离”改成图三方向的文件夹式融合组件。

改动：

- `VitoraCompressedHeader`：后方大 Pixel Vitora 加大并从左后方探出；前景改为文件夹式玻璃信息卡。
- 新增自定义文件夹前景 shape：前景卡顶部形成台阶/凹口，与彩色背板咬合。
- 彩色背板保留 `维他命之道 / Vitora 知道`，右侧标题与信息列保持同一视觉轴线。
- 继续使用统一 `PixelVitoraView / PixelVitoraScene`，不在页面内单独绘制 IP。
- 二次精调层级：后方大 IP 放在彩色背板之上、前景信息卡之下，去掉页面级多余大 IP 残影，避免组件看起来像两个分离卡片。

截图：

- `ios/QA/Screenshots/ImplementationV1/34-vitora-new-ip-folder-hero.png`

测试：

- Build：通过，`xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`。
- Vitora assistant / visual UI tests：通过，3 tests passed，0 failed。

## 2026-05-07 · Vitora Tab 周期上下文展开态对齐

目的：把 Vitora Tab 从竖向功能栈推进到目标图中的 assistant surface，让周期 chip 展开态成为可交付 baseline。

改动：

- `VitoraCompressedHeader`：改为顶部玻璃圆按钮、背景大 Pixel Vitora、前景双栏玻璃上下文卡、date context strip。
- `VitoraAssistantSurfaceView`：新增小 IP + 玻璃消息气泡，选择 `周期` 时展示 `VitoraCycleContextReportCard`，默认态保留直接问入口。
- `QuickContextChips`：改为输入区上方 compact tool belt，补 selected / pressed 状态。
- `VitoraInputDock`：重排为语音/键盘、输入或内联语音条、send 的一体化玻璃 dock；输入内不再放 plus，并保留现有 voice/text/send accessibility id。
- `VitoraViewModel`：新增测试启动参数 `-vitoraUITestInitialContextCycle`，用于截图验收默认进入周期展开态。

截图：

- `ios/QA/Screenshots/ImplementationV1/18-vitora-target-aligned.png`

测试：

- Build：通过，`xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -derivedDataPath /private/tmp/vitora-derived-vitoraalign build`。
- Vitora assistant / visual / accessibility UI tests：通过，5 tests passed，0 failed。

未解决问题：

- 已进入 simulator 截图验收；后续若改 Input Dock 或 Bottom Tab，仍需重新确认遮挡。
