# Dynamic Aura Background Change Log

## 2026-05-18 · Warm Paper Aura 强层级修正

| 项 | 内容 |
| --- | --- |
| 目的 | 用户指出当前仍像死白瓷面，组件和背景同色；本次按“暖米纸强对比 + 底色分区柔影”重新锁定色调。 |
| 背景 | `PremiumAuraBackground` 改为暖米纸底、右上 peach mist、左下 cyan mist，降低白色 wash 和 material 叠层。 |
| 卡片 | `PearlGradientSurface` 固定为 L1 珍珠白主卡；`GlassSurface.clean*` 改用珍珠白/暖灰白填充和 warm gray `paperLift` 短柔影。 |
| 页面 | Today 能量状态卡保留单张主卡并加强碗下暖灰承托影；Onboarding 保持单张大卡，输入和 chips 使用暖灰白 inset。 |
| 限制 | 不使用外部图、不做重橙照片感、不回到大面积蓝色渐变、不新增任务/打卡/成长体系。 |

## 2026-05-18 · B 版白霜卡片结构优化

| 项 | 内容 |
| --- | --- |
| 目的 | 用户选择 B 方案：保留注册页干净渐变方向，但进一步明确卡片结构和内容重心；解决 Today 能量盆在纯白背景里层次不清的问题。 |
| 设计修正 | 不是只给“能量碗”局部加背景，而是把全局背景和主卡片都改成参考图式的珍珠白、暖白、浅青低饱和渐变；降低瓷白遮罩，避免页面整体发白。 |
| Today | `TodayStatusCard` 的整张能量状态卡改用 `PearlGradientSurface`，让能量盆落在统一的珍珠渐变卡面里；保留碗口、水位和底部柔影，不再额外制造杂乱内层卡。 |
| Onboarding | `OnboardingPageCard` 回到单张大卡结构，移除内嵌内容玻璃卡和折角装饰；IP 柔光、标题、输入和按钮共享同一张珍珠白渐变卡面。 |
| 组件 | 新增 `PearlGradientSurface` 作为可复用主卡承载面；`PremiumAuraBackground` 降低白遮罩和粉橙强度，避免 Vitora/子页面出现过重橙色照片感。 |
| 限制 | 不使用参考图本身，不引入网页组件/旧 RN/Expo，不新增主 Tab、成长册、任务或打卡心智。 |

## 2026-05-18 · Premium Aura 原生浅霜背景

| 项 | 内容 |
| --- | --- |
| 目的 | 按用户浅色参考图拆解结果，把全 App 背景升级为干净、高级、有层次的低饱和原生分层系统。 |
| 规格 | `facts.md` 新增 D-054；`dynamic-aura-background` specs 允许 `PremiumAuraBackground` 作为全 App 背景入口。 |
| 工程 | 新增 `PremiumAuraBackground` / `PremiumAuraScene`；`WaterAuraReferenceBackground` 改为兼容 wrapper；Today / Vitora / Cycle / Sheet / Onboarding / Support 接入对应 scene。 |
| 玻璃 | `GlassSurface` 新增 cleanResting / cleanElevated / cleanInset，并将主要页面卡片改为更白、更低阴影的 clean 状态。 |
| 验证 | `xcodebuild ... build` 通过；`TodayPivotUITests`、`VitoraAssistantSurfaceUITests`、`CyclePivotUITests`、`OnboardingLowDataUITests`、`EveningReviewUITests`、`AccessibilityUITests`、`VisualLanguageSmokeTests` 共 24 个 UI 测试通过。 |
| 截图 | `ios/QA/Screenshots/ImplementationV1/PremiumAura-20260518/01-premium-aura-today.png` 到 `07-premium-aura-cycle.png`。 |

## 2026-05-08 · Initial Dynamic Aura Implementation

| 项 | 内容 |
| --- | --- |
| 目的 | 将用户视频中的柔焦流体色场转为 Vitora 周期动态背景系统。 |
| 规格 | 新增 `dynamic-aura-background/` spec pack。 |
| 素材 | 新增 5 个 clean video variants 和 5 张 poster。 |
| 工程 | 新增 `DynamicAuraVideoBackground`，Today / Vitora / Cycle 首层接入。 |
| 交互 | Today 日历点击日期更新 `selectedCycleDay` 和背景 variant。 |
| 限制 | 本机没有离线 ASR，`video-transcript.md` 先记录视觉转写，完整口播逐字稿待补。 |
| 验证 | `xcodebuild ... build` 通过；`TodayPivotUITests`、`VisualLanguageSmokeTests`、`AccessibilityUITests` 共 6 个 UI 测试通过。 |
| 截图 | `ios/QA/Screenshots/ImplementationV1/19-dynamic-aura-today.png` |
| 录屏 | `ios/QA/Screenshots/ImplementationV1/20-dynamic-aura-today-loop-10s.mp4` |
| 未解决 | 本机没有离线 ASR，`video-transcript.md` 先记录视觉转写，完整口播逐字稿待补；Reduce Motion 仍需在系统设置实机路径单独截图复核。 |
