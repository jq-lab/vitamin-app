# Vitora Tab Page Spec

> 权威执行文件。若本文件与旧 demo 或历史截图冲突，以本文件和 `facts.md` 为准。

## 页面目标

让用户在 Vitora Tab 中看到 Vitora 正在理解今天的身体上下文，并能围绕一个主题继续提问或补充信息。

## 首屏顺序

1. Top controls：返回、静音、更多，使用 40-44pt 玻璃圆按钮。
2. Hero context：背景大 Pixel Vitora 作为空间氛围；文件夹式彩色背板 + 前景双栏玻璃信息卡融合成一个组件，不能遮挡 Top controls。
3. Date context line：无背景轻量文本，靠左连续排布 `今日 · 5月5日（周二） · 黄体期 Day18`。
4. Topic selector：`周期 / 睡眠 / 营养` 是独立横向玻璃组件；默认只显示入口，不显示下方详情卡。
5. Vitora message：小 Pixel Vitora face + 玻璃消息气泡 + 合规短句。
6. Context summary：选择 `周期 / 睡眠 / 营养` topic 后出现统一上下文摘要卡。
7. Sleep seed explanation：当存在睡眠种子时，AI 管家可解释为什么半开、今天建议如何帮助它、哪些反馈能让 Vitora 判断更准。
8. Input Dock：语音/键盘切换、动态 placeholder 文字输入或内联语音条、发送。
9. Bottom Tab：三 Tab，中央 Vitora face 低凸起，不遮挡输入。

## 组件要求

### Hero / Header

- Top controls 必须独立可见；Hero 后方大 IP 和文件夹背板不得压住返回、静音、更多按钮。
- Top controls 必须有真实交互：返回切回 Today，静音切换 `speaker.wave.2` / `speaker.slash` 可见状态，更多打开 Support 设置面板。
- Top controls 的 hit area 固定不小于 44pt；Hero 的 IP、背板、光效和装饰层不得接收 hit testing。
- 背景 Pixel Vitora 必须从左后方探出，露出头部和低像素眼，表达 Vitora 居住在这个空间里；不承担按钮或主要信息。
- Hero 必须是单一文件夹式玻璃组件：后层彩色磨砂背板，前层白色通透信息卡，前层顶部有文件夹边缘/台阶咬合，不能像两个分离圆角卡片叠放。
- Hero 单组件融合规则：背板与前景卡共用外层宽度、统一银白 rim、统一阴影和统一模糊材质；不能分别加两套大圆角、两套投影或两套重边界。
- 背板只从上方和右上露出，露出高度约 54-68pt；前景信息层必须像文件夹页片一样咬住背板，而不是覆盖在背板上的独立白卡。
- 彩色背板左侧只显示低权重 `Vitora 知道`，删除中文 `维他命之道`；背板以柔白、粉橙、淡紫为主，不使用大面积青绿色。
- 前景玻璃卡左栏为今日身体上下文主信息，不展示 `Pixel Vitora` 文案；固定包含三条：黄体期 Day18、睡眠 7.2h · 略低、HRV ↓8%。左栏占主视觉宽度，文字必须完整落在卡片内，不能贴边或溢出到圆角外。
- 前景玻璃卡右栏为辅助摘要区，只显示缩小版 `今日能量 68%`；右栏必须被竖向分隔线明确分块，但不能像独立小卡片。
- Hero 内的 Pixel Vitora 必须放在背板和前景卡之间，靠近右侧分栏线附近，而不是放在独立信息块里；它必须可见但低实体化，露出柔体彩色轮廓和像素眼，不作为前景实体主内容。
- Hero 必须至少有稳定实体卡片态和聊天聚焦态。点击 `AI管家` 进入时使用实体卡片态，不默认大展开；用户上拉超过阈值后进入聊天聚焦态，隐藏 hero 卡并让聊天内容成为主轴。
- 顶部圆按钮不得变成黑色实心 toolbar，也不得替换成 profile avatar。

### Date Context Line

- 形态为无背景轻量文本行，不能像 pill 或按钮；即使可点击，也不能恢复整块玻璃背景。
- 左侧连续显示 `今日 · 5月5日（周二） · 黄体期 Day18`。
- 不使用 sparkles、星星、emoji、chevron 或装饰 icon。
- 点击后在 Vitora 页内打开周期日历 sheet，用于查看或选择周期日期。
- 周期日历关闭后必须仍停留在 Vitora Tab；不能跳转到 Cycle 首页，也不能切回 Today。
- accessibility id 固定为 `vitora.date.context.openCalendar`；sheet 使用 `today.calendar.sheet`。

### Topic Selector / Context Card

- 位于 Date Context Strip 下方，不能放在输入栏内，也不能做成大号功能卡。
- `周期 / 睡眠 / 营养` 必须是一个独立 topic selector，不能塞进 `今天想聊什么` 或输入框 placeholder。
- 默认状态不显示任何 topic 详情卡，避免固定占用聊天空间。
- 点击 topic 后，在 selector 下方弹出对应上下文卡。
- 点击另一个 topic 时，直接切换为对应卡片。
- 上下文卡右上角必须有取消按钮；点击取消后卡片收起且不占空间，topic selector 保持可见。
- 内容固定为 `周期`、`睡眠`、`营养`；不显示 `情绪`、`能量`。
- 横向排布，保留轻滑动/弹性能力，但首屏必须完整露出 3 个 topic。
- 每个 topic 是 36-44pt 高的玻璃 pill；选中态使用白色磨砂底 + 轻彩色高光，未选中态更透明。
- 点击 topic 继续触发现有上下文选择逻辑；topic 只改变聊天上下文，不新增页面或主 Tab。
- `+` 不出现在 Topic Rail 或 Input Dock；手动补充由 Dock 右侧独立圆形 `+` 进入 contextual sheet。

### Vitora Message

- 左侧必须使用当前 Pixel Vitora baseline 的 `messageAvatar` 紧凑变体。
- `messageAvatar` 是微信式圆角方形头像：约 36-38pt，圆角 10-12pt，磨砂玻璃材质，内部只保留轻彩色雾面和两个小像素眼。
- 小像素眼必须是分段块状像素，不是连续竖条；建议每只眼由 2 列 x 3-4 行小方块组成。
- 头像内部彩色只作为中心一小团淡粉橙暖光；乳白透明磨砂壳必须是第一眼主体。
- `messageAvatar` 不能使用完整大 IP、圆形头像、星星、emoji、SF Symbol 或系统头像。
- 气泡使用清透玻璃，文案优先表达建议和解释，不像任务卡。
- 合规短句固定在气泡下方：`本内容仅供生活方式参考，不构成医疗建议`。

### 上下文摘要卡

- 只在用户点击 topic 后展开；默认不显示，避免固定占用聊天空间。
- `周期 / 睡眠 / 营养` 必须使用同一组件结构：icon、标题、关闭按钮、2-3 条关键依据、一句 Vitora 如何带入本次聊天。
- 周期卡固定包含：`黄体期 Day18`、`经期窗口 5月8日-5月12日`、`今晚适合轻量复盘`。
- 睡眠卡固定包含：`睡眠 7.2h · 略低`、`深睡相对够`、`HRV ↓8%`。
- 营养卡固定包含：`今日补给未记录`、`午后低谷前可加蛋白`、`补水和蛋白作为生活方式参考`。
- 这是本次提问的上下文卡，不是 Cycle 首页，不增加主导航。

### Sleep Seed Explanation

- 只在存在睡眠种子时显示，不能替代晚间复盘入口。
- 标题方向：`为什么这颗种子半开`。
- 固定解释三件事：昨晚休息发生了什么、今天建议如何帮助它、用户反馈会如何让 Vitora 判断更准。
- 卡片使用白色霜状玻璃，配低像素 2D 小花，不使用完整花田地图。
- 点击卡片打开 Vitora contextual sheet，来源为 `睡眠种子`。
- 不显示连续天数、完成率、红点、货币、商店、VIP 或失败惩罚。

### Input Dock

- 顺序为语音/键盘、TextField 或内联语音条、send。
- 语音和 send 触控不小于 44pt。
- 键盘出现时 dock 上移，Bottom Tab 与中央 Vitora face 不得遮挡输入。
- TextField placeholder 使用“今日想问什么”方向的动态问题提示，每 2 分钟轮换一次。
- 用户开始输入、语音记录中或辅助功能聚焦输入时，placeholder 轮换必须暂停，避免干扰输入。
- 推荐 placeholder 包括：`我可以补充一件事...`、`为什么今天容易低谷？`、`今天怎么安排更轻一点？`。
- `可以直接问` 固定问题栏不再出现在首屏；推荐问题只进入动态 placeholder 或后续 AI 回复里的追问建议，避免在聊天内容中形成额外堆叠。
- `Vitora 理解为` / `更新后的判断` 这类 Rich Response 不在默认首屏常驻，只能在用户输入、语音或确认动作之后出现。
- 输入栏上方 `AI管家` 选中 pill 必须有从上方向下打的柔白光源、局部 bloom 和顶部 rim；未选中入口只显示房子 icon 与花朵周期 Logo，不显示 `今日` / `周期` 文字；Today / Cycle 只显示 Tab 与右侧圆形 `+`，不显示输入条。
- `AI管家` 选中态使用 Pixel Vitora 紧凑小人标识，不使用星星、普通 sparkle icon 或 SF Symbol 代替。
- 输入栏内部不放 `+`；手动记录由 Dock 右侧独立圆形 `+` 打开 contextual sheet，不能替代发送按钮。
- 语音 listening 状态的波形只有在音量明显升高时增强彩色光和高度；普通 listening 不持续强闪。

## Motion

| 对象 | 参数 |
| --- | --- |
| Hero 入场 | 320ms easeOut，背景大 IP opacity 0.3 -> 0.75，位置只做轻微变化。 |
| Topic pressed | 120ms，scale 0.97。 |
| Topic selected | 180ms easeOut，玻璃底和轻彩色高光过渡。 |
| Topic rail scroll | 使用系统横向惯性滚动，不做夸张弹跳。 |
| 上下文卡展开 | 220-240ms easeOut，opacity + 从 topic selector 下方轻微上移 8pt。 |
| 上下文卡取消 | 180ms easeOut，卡片淡出收起，不留下空白占位。 |
| Placeholder 轮换 | 每 120s 一次，180-240ms 淡入淡出；Reduce Motion 下只静态切换或保持第一条。 |
| Input Dock 聚焦 | 240ms 上移避让键盘，中央 Vitora face 降低 glow。 |
| Input selected spotlight | 180ms easeOut，选中 pill 顶部出现垂直柔白光源和轻 bloom；Reduce Motion 下只保留静态高光。 |
| Chat focus | 上拉超过约 70pt 后 220-240ms easeOut 隐藏 hero，日期行成为顶部内容起点；Reduce Motion 下直接切换。 |
| Reduce Motion | 关闭漂浮、上移动效和 shimmer，只保留 opacity 切换。 |

## 禁止项

- 不改变 Pixel Vitora IP 形象；不得绕过 `pixel-vitora-ip/` spec。
- 不使用 smooth orb、人像、宠物、emoji 或普通 SF Symbol 代替 Vitora face。
- 不把 Vitora Tab 做成 dashboard、功能宫格、空聊天页或营销页。
- 不把 topic 上下文卡做成 Cycle 首页。
- 不新增第四个 Tab。
- 不加入任务、打卡、完成率、红点、连续天数、商业卡、VIP 卡。
- 不使用强紫霓虹、黑重阴影或医疗警报红色。
- 不让底部 Tab 或中央 Vitora face 遮挡 input dock。
- 不把 Hero 做成上下两个独立卡片；文件夹背板和前景信息卡必须在图层、圆角、阴影和高光上融合。
- 不让 Hero 光效、IP 或玻璃层吃掉返回、静音、更多按钮点击。
- 不把 `周期 / 睡眠 / 营养 / 情绪 / 能量` 做成大卡片堆叠或底部工具栏；它们必须在日期条下方以横向 topic rail 呈现。
