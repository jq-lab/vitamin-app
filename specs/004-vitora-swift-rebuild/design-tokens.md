# Vitora Swift Rebuild · Design Tokens

> 规格集：`004-vitora-swift-rebuild`
> 批次：IA / Design Pivot Adaptation
> 日期：2026-05-05
> 状态：当前生效

本文档把 `design-language-demo.md` 的视觉方向正式拆为 token。目标不是 Apple Health dashboard，而是：

**弥散渐变背景 + 清透拟态玻璃组件 + Pixel Vitora 陪伴体**

设计系统代号：**Aura Glass Pixel Companion**。

## 0. 权威规则

| Rule ID | Rule | Constraint |
| --- | --- | --- |
| DT-AUTH-001 | 本文件是 `vt.*` token 权威。 | Swift 代码不得散落硬编码视觉值。 |
| DT-AUTH-002 | `design-language-demo.md` 是 evidence high-rule。 | 本文件已吸收其设计判断，demo 继续保留为证据。 |
| DT-AUTH-003 | 首层 IA 必须使用 aura background + clear glass。 | Today / Vitora / Cycle 首屏不得退回纯白 dashboard。 |
| DT-AUTH-004 | 支撑页优先可读性。 | Support / privacy / export 可使用更强白底玻璃。 |
| DT-AUTH-005 | Pixel Vitora 是品牌 IP token。 | 不得替换为 smooth orb、人类头像、宠物、普通 SF Symbol。 |

## 1. 命名规则

| Category | Pattern | Example |
| --- | --- | --- |
| 背景 | `vt.bg.*` | `vt.bg.aura.today` |
| 色彩 | `vt.color.*` | `vt.color.action.blue` |
| 玻璃材质 | `vt.glass.*` | `vt.glass.g1.clearCard` |
| 字体 | `vt.type.*` | `vt.type.title.page` |
| 间距 | `vt.space.*` | `vt.space.screen.x` |
| 圆角 | `vt.radius.*` | `vt.radius.card` |
| 阴影 / 光晕 | `vt.shadow.*`, `vt.glow.*` | `vt.glow.pixel.idle` |
| 动效 | `vt.motion.*` | `vt.motion.sheet.spring` |
| 布局 | `vt.layout.*` | `vt.layout.tab.lowLift` |

## 2. Aura Background Tokens

动态背景视频、周期色变体和 Reduce Motion 兜底以 `dynamic-aura-background/dynamic-aura-background-spec.md` 为准；本节只保留基础 token 方向。

| Token | Value / Direction | Usage |
| --- | --- | --- |
| `vt.bg.base` | `#F4EEE8 -> #FBF7F1` | 全局暖米纸底，不用纯白。 |
| `vt.bg.aura.today` | radial cyan glow + soft blue wash + faint lavender edge | Today 首层。 |
| `vt.bg.aura.vitora` | large cyan/blue diffuse sphere behind Pixel Vitora, lavender only secondary | Vitora Tab。 |
| `vt.bg.aura.cycle` | light blue base + soft yellow/green/pink phase hints | Cycle 首层。 |
| `vt.bg.aura.support` | subdued blue-white gradient | 支撑页和隐私页。 |
| `vt.bg.overlay.dim` | rgba black/blue dim 8-16% | contextual sheet 背景压暗。 |
| `vt.bg.aura.dynamicVideo` | clean looping fluid aura video + poster fallback | Today / Vitora / Cycle 首层动态背景。 |
| `vt.bg.aura.premium` | warm white base + low-saturation mist + micro texture + bottom frosted fog | 全 App 原生浅霜背景；Today / Vitora / Cycle / Sheet / Onboarding / Support 按 scene 调整。 |
| `vt.bg.paperWarm.base` | `#F4EEE8` | L0 页面底，形成比主卡更低的暖米纸背景。 |
| `vt.bg.paperWarm.lift` | `#FBF7F1` | L0 顶部/中心轻提亮，不作为卡片填充。 |
| `vt.bg.paperWarm.peachMist` | `#F2CDBE` at low opacity | 右上暖雾，用于注册页和页面空气层。 |
| `vt.bg.paperWarm.cyanMist` | `#DDF2F1` at low opacity | 左下青雾，保留 Vitora 水感。 |
| `vt.surface.pearl.main` | `#FFFCF7` | L1 主卡，比背景更亮、更实。 |
| `vt.surface.pearl.inset` | `#F1EDE8` | L2 输入、chips、内嵌信息块。 |
| `vt.shadow.paperLift` | warm gray `#857160` 8-16% | 主卡和内嵌控件短柔影。 |

规则：

- 弥散渐变是空间氛围，不是大块装饰图。
- Warm Paper Aura 为当前色调：暖米纸负责前后关系，蓝 / 青只保留为水感空气层和关键强调。
- 首层页面背景必须比卡片更低明度、更暖，不能和卡片同色。
- 子页面背景必须比首页更白、更安静；阶段色只用于小面积点缀。

## 3. Color Tokens

### 3.1 Core Palette

| Token | Value | Usage |
| --- | --- | --- |
| `vt.color.ink.primary` | `#121826` | 主标题、核心数值。 |
| `vt.color.ink.secondary` | `#5E6677` | 正文、说明。 |
| `vt.color.ink.tertiary` | `#8A93A6` | 次级状态、placeholder。 |
| `vt.color.ink.inverse` | `#FFFFFF` | 深色圆形 CTA / Pixel 眼睛高光。 |
| `vt.color.action.blue` | `#3F8CFF` | 主 CTA、选中、关键趋势点。 |
| `vt.color.action.cyan` | `#52C7F7` | 能量曲线、Pixel Vitora glow。 |
| `vt.color.action.deepBlue` | `#2569E8` | 发送按钮、强调态。 |
| `vt.color.aura.lavender` | `#A8A7FF` | 次级光晕，不作为主按钮色。 |
| `vt.color.aura.mint` | `#B9F2E3` | 玻璃边缘和 Pixel 背景。 |
| `vt.color.phase.menstrual` | `#F48CA8` | 月经阶段点。 |
| `vt.color.phase.follicular` | `#59A9FF` | 卵泡阶段点。 |
| `vt.color.phase.ovulation` | `#63D59A` | 排卵阶段点。 |
| `vt.color.phase.luteal` | `#F4C84E` | 黄体阶段点。 |
| `vt.color.state.attention` | `#FF5A5F` | 少量需要留意点，不用于焦虑红点。 |
| `vt.color.state.positive` | `#2FA66A` | 正向趋势、保存成功。 |

### 3.2 Usage Rules

| Rule ID | Rule |
| --- | --- |
| DT-COLOR-001 | 当前主背景优先暖米纸；蓝/青用于 Vitora 水感、关键动作和局部空气层；紫色只能做柔和边缘层。 |
| DT-COLOR-002 | `attention` 只用于局部数据点或不适合状态，不用于 badge、红点、连续提醒。 |
| DT-COLOR-003 | Cycle 可使用四阶段色，但页面仍保持蓝色系统，不变成彩虹日历。 |
| DT-COLOR-004 | Support 页减少高饱和色，优先可读和可信。 |

## 4. Glass Material Levels

| Token | Material | Visual Rule | Usage |
| --- | --- | --- | --- |
| `vt.glass.g0.backgroundAura` | diffuse aura only | 无边框，无内容承载 | 页面背景。 |
| `vt.glass.g1.clearCard` | rgba white 42-58%, 1px white edge, low blur | 清透、可读、轻浮起 | Today/Cycle 首层主卡。 |
| `vt.glass.g2.panel` | rgba white 62-76%, stronger edge, soft shadow | 信息承载更强 | 二层详情、Vitora 知道、建议卡。 |
| `vt.glass.g3.sheet` | rgba white 78-88%, readable frosted | 任务型 sheet | 3/4 Vitora sheet、详情 sheet。 |
| `vt.glass.g4.support` | rgba white 88-94%, minimal aura | 高可读、低装饰 | 隐私、导出、账号移除、长表单。 |
| `vt.glass.clean.resting` | high white, low chroma edge, short shadow | 干净静息卡 | 主页面和二层普通信息卡。 |
| `vt.glass.clean.elevated` | stronger white fill, clear rim, restrained shadow | 干净抬起态 | 主卡、选中态、可点击摘要卡。 |
| `vt.glass.clean.inset` | lighter white fill, minimal shadow | 内嵌信息块 | 子页面内层说明和辅助容器。 |

规则：

- 首层卡片用 **清透拟态玻璃**，不是厚重 frosted blur。
- 二层可更白、更可读，但仍保留背景气氛。
- 玻璃必须有边界高光和阴影层级，否则会显得 flat。
- 玻璃上不得使用过浅灰色承载关键文字。

## 5. Typography Tokens

| Token | Size / Weight | Usage |
| --- | --- | --- |
| `vt.type.pageTitle` | 26 / 700 | Today、Vitora、Cycle 页面标题。 |
| `vt.type.sectionTitle` | 18 / 700 | 现在状态、身体要素、能量动态。 |
| `vt.type.cardTitle` | 16 / 700 | 卡片标题。 |
| `vt.type.body` | 15 / 500 | 主要说明。 |
| `vt.type.bodyStrong` | 17 / 700 | 建议行动、关键结论。 |
| `vt.type.caption` | 12 / 500 | 图表轴、辅助说明。 |
| `vt.type.micro` | 10 / 500 | 只用于极低权重，不承载关键动作。 |
| `vt.type.energyNumber` | 46-56 / 700 | Energy Ball 或状态数字，必须配状态词。 |

规则：

- 不使用负字距。
- 不用 viewport-based font scaling。
- 中文行高保持 1.35-1.55。
- 大数字不能单独出现，必须搭配状态词和语义。

## 6. Layout / Spacing / Radius

| Token | Value | Usage |
| --- | --- | --- |
| `vt.layout.device.baseWidth` | 393 | 设计基准宽。 |
| `vt.layout.screen.marginX` | 20 | 主内容横向边距。 |
| `vt.layout.content.maxWidth` | 353 | 393 宽设备的主内容宽。 |
| `vt.layout.tab.height` | 76-84 | 底部 tab 高度。 |
| `vt.layout.tab.lowLift` | center button rises 8-14pt only | 避免遮挡 Vitora input dock。 |
| `vt.layout.inputDock.height` | 54-64 | Vitora 输入区域。 |
| `vt.space.xs` | 4 | 微间距。 |
| `vt.space.sm` | 8 | chips 内部。 |
| `vt.space.md` | 12 | 卡片内部组。 |
| `vt.space.lg` | 16 | 标准 padding。 |
| `vt.space.xl` | 24 | section 间距。 |
| `vt.radius.sm` | 10 | 小 chip。 |
| `vt.radius.md` | 16 | 小卡片 / 输入。 |
| `vt.radius.card` | 24 | 首层玻璃卡。 |
| `vt.radius.sheet` | 30 | sheet。 |
| `vt.radius.pill` | 999 | pill / 圆按钮。 |

## 7. Shadow / Glow Tokens

| Token | Value / Direction | Usage |
| --- | --- | --- |
| `vt.shadow.glass.low` | blue shadow 8-14%, y 8-18 | 首层清透卡。 |
| `vt.shadow.glass.medium` | blue/gray 14-20%, y 14-28 | 二层 panel。 |
| `vt.shadow.sheet` | dark 12-18%, y -8 | 3/4 sheet。 |
| `vt.glow.pixel.idle` | cyan glow 24-32 blur | Pixel Vitora idle。 |
| `vt.glow.pixel.active` | cyan + blue glow 36-48 blur | listening / thinking。 |
| `vt.glow.cta` | blue glow 12-18 blur | Vitora face tab selected。 |

规则：glow 服务陪伴体和可交互状态，不能让页面到处发光。

## 8. Pixel Vitora IP Tokens

详细 IP baseline、禁用方向、状态/道具扩展规则以 `pixel-vitora-ip/pixel-vitora-ip-spec.md` 为准；本节只保留 token 摘要。

| Token | Rule |
| --- | --- |
| `vt.ip.shape` | 像素风格球状体，外轮廓可柔和发光，但眼睛和表情必须 pixel。 |
| `vt.ip.material.glassShell` | 玻璃球、厚白 rim、左上高光、右下透光、底部软阴影。 |
| `vt.ip.color.core` | blue/cyan-first；lavender 只做边缘空气感。 |
| `vt.ip.eye.pixelColumn` | 眼睛必须是发光像素柱，不用平滑线条或 emoji。 |
| `vt.ip.eye.idle` | 两个像素竖眼或方块眼，轻微呼吸。 |
| `vt.ip.eye.blink` | 眨眼 120-180ms。 |
| `vt.ip.state.idle` | 稳定呼吸，低亮。 |
| `vt.ip.state.listening` | 眼睛更亮，微扩散光。 |
| `vt.ip.state.thinking` | 轻微 shimmer，背景 aura 流动。 |
| `vt.ip.state.confirming` | 靠近 response card，提示等待确认。 |
| `vt.ip.size.hero` | Vitora Tab 顶部主 IP。 |
| `vt.ip.size.decor` | Today / Cycle 右上装饰 IP。 |
| `vt.ip.size.tab` | 底部中央 face tab。 |
| `vt.ip.accessory.clipboard` | 玻璃小挂件，道具辅助 IP，不抢主体。 |

Do:

- 使用 Pixel Vitora 统一 app / assistant 品牌。
- 在 Today / Cycle 只做轻陪伴或状态提示。
- 在 Vitora Tab 作为“活的 assistant 空间”主角。

Don’t:

- 不用人类头像。
- 不用宠物形象。
- 不用无像素眼睛的 smooth orb。
- 不用普通心形/SF Symbol 代替中央 Vitora face。

## 9. Component Token Mapping

| Component | Required Tokens |
| --- | --- |
| Today 背景 | `vt.bg.aura.today`, `vt.glass.g1.clearCard` |
| Dynamic Aura 背景 | `vt.bg.aura.dynamicVideo`, `dynamic-aura-background/*`, Reduce Motion poster |
| Today 状态卡 | `vt.glass.g1.clearCard`, `vt.color.action.cyan`, `vt.type.energyNumber` |
| Energy Bowl / 实时预测 | `vt.glass.g1.clearCard`, `vt.color.action.cyan`, `vt.type.energyNumber`, `vt.motion.tap` |
| 身体要素 tiles | `vt.glass.g1.clearCard`, `vt.type.caption`, `vt.color.ink.primary` |
| Vitora 今日建议 | `vt.glass.g2.panel`, `vt.color.action.blue`, `vt.shadow.glass.low` |
| Vitora Tab background | `vt.bg.aura.vitora`, `vt.glow.pixel.idle` |
| PixelVitoraHero | `vt.ip.size.hero`, `vt.glow.pixel.active`, `vt.ip.eye.*` |
| Direct Question Strips | `vt.glass.g1.clearCard`, thin horizontal height, minimal shadow |
| Quick Context Chips | icon-only / icon+short label, `vt.glass.g1.clearCard` |
| Vitora Input Dock | `vt.glass.g3.sheet`, `vt.layout.inputDock.height`, keyboard avoidance |
| Contextual Sheet | `vt.glass.g3.sheet`, `vt.bg.overlay.dim`, `vt.motion.sheet.spring` |
| Cycle Phase Card | `vt.glass.g1.clearCard`, phase colors, `vt.ip.size.decor` |
| Energy Dynamics Card | `vt.glass.g1.clearCard`, `vt.color.action.cyan`, chart selection token |
| Support Panels | `vt.glass.g4.support`, reduced aura, high contrast text |

## 10. Motion Tokens

| Token | Rule |
| --- | --- |
| `vt.motion.tap` | 120-180ms scale/opacity feedback。 |
| `vt.motion.contextMenuPress` | 长按时卡片微缩、背景轻暗、触觉反馈。 |
| `vt.motion.sheet.spring` | 3/4 sheet 上下滑动使用 iOS-like spring。 |
| `vt.motion.energyBowl` | 能量碗点击、模式切换和当前时间气泡使用轻量反馈，不模拟刷新。 |
| `vt.motion.pixelBreath` | 2.8-4s 低幅呼吸循环。 |
| `vt.motion.pixelBlink` | 随机轻眨眼，不抢内容。 |
| `vt.motion.reduce` | Reduce Motion 时关闭 shimmer、强弹性和长 glow 变化。 |

## 11. Accessibility Rules

| Rule ID | Rule |
| --- | --- |
| DT-A11Y-001 | 玻璃层上的文字必须通过对比测试，不依赖背景模糊遮盖。 |
| DT-A11Y-002 | 所有主要触控目标不小于 44pt。 |
| DT-A11Y-003 | Pixel Vitora 动效不得成为唯一状态表达。 |
| DT-A11Y-004 | 长按 context menu 必须有二层 `⋯` fallback。 |
| DT-A11Y-005 | 图表不能只靠颜色表达阶段或趋势；需文本/图例/VoiceOver label。 |
| DT-A11Y-006 | Reduce Transparency 时玻璃退化为高可读浅色 surface。 |

## 12. 废弃 Token / 方向

| Deprecated | Replacement |
| --- | --- |
| `#FAFAFA` flat dashboard canvas as page identity | `vt.bg.aura.*` |
| Apple Health-like blue/white cards only | Aura background + clear glass hierarchy |
| `Luna` user-facing tokens | `Vitora` user-facing tokens |
| `TodayStateOrb` permanent hero sizing | `EnergyBowlRealtimePrediction` inline status tokens |
| `CycleCalendarGrid` as Cycle home | Today calendar sheet + Cycle energy dynamics |
| Smooth orb IP | Pixel Vitora ball with pixel eyes |
| Human avatar recommendation card | Pixel Vitora / abstract companion only |

## 13. QA 清单

- `Today / Vitora / Cycle` 首层都使用 aura background。
- 首层卡片以 G1 clear glass 为主；二层用 G2/G3；支撑页用 G4。
- Pixel Vitora 在 Vitora hero、Today 装饰、Cycle 装饰、底部 CTA 中一致。
- Vitora input dock 不被中央 tab 遮挡。
- Direct question 是薄横向玻璃条，不是大功能卡。
- Cycle 使用阶段色作为语义点，不变成彩色日历首页。
- 支撑页减少装饰，保留可读和可信。
