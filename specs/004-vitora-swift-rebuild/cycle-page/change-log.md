# Cycle Page Change Log

> 后续任何 Cycle 页面相关改动都必须追加到本文件。

## 2026-05-28 · 顶部日历融合与能量摘要卡微调

**目的**

按用户对 D-093 截图的反馈，去掉顶部独立 `周期` 标题，让“我的/分享”和周历融合为同一张顶部日历头卡；同时把 `6.5` 从大号设备读数改为小参考 chip，主信息改为今天能量和本周能量。

**具体改动**

- `CycleView.swift`：移除独立 `cycleTopBar`，把我的入口、展开 chevron、分享入口放入 `CycleEnergyCalendarCard`。
- `CycleView.swift`：周历 strip 增加大椭圆底，日期 pill 内保留小圆环能量进度，整体顶距上移。
- `CycleView.swift`：`CycleMetricSummaryCard` 改为左侧 `68 今日` 圆环 + 右侧今日/本周能量文案，小号 `参考 6.5` chip；删除大号 `6.5 mmol/L`、TIR 环和设备状态。
- `facts.md`、`decision-log.md`、`spec.md`、`wireframes.md`、`components.md`、`interaction-acceptance.md`、`cycle-page-spec.md`、`qa-checklist.md`：同步 D-094 / D-095 规则。

## 2026-05-28 · 能量复盘日历 v1.8

**目的**

按用户提供的日历 + `6.5` 参考图，把 Cycle 首屏从花田地图切换为“能量日历折叠/展开 + 指标卡”的信息结构；左侧继续是我的，右侧继续是分享，报告分段入口下移到指标卡下方。

**具体改动**

- `CycleView.swift`：新增 `CycleEnergyDashboardFrame`、`CycleEnergyCalendarCard`、折叠周历 strip、展开月历网格、选中日能量摘要和 `CycleMetricSummaryCard`。
- `CycleView.swift`：Header 移除报告胶囊，只保留左头像、中间轻标题和右分享；`本周 / 趋势对比 / 近期` 移到 `6.5` 指标卡下方。
- `CyclePivotUITests.swift` / `AccessibilityUITests.swift` / `VisualLanguageSmokeTests.swift` 等：将旧 `cycle.flowerMap` / `cycle.mapReport.frame` 断言更新为 `cycle.energyCalendar.*` 和 `cycle.energyMetric.card`。
- `facts.md`、`decision-log.md`、`wireframes.md`、`components.md`、`interaction-acceptance.md`、`cycle-page-spec.md`、`qa-checklist.md`：同步 D-093 / v1.8 规则。

**截图 / 产物**

```text
ios/QA/Screenshots/CycleEnergyCalendar-20260528/cycle-energy-calendar-collapsed.png
```

**构建结果**

```text
xcodebuild -quiet -workspace Vitora.xcworkspace -scheme Vitora -destination id=EE0BC9AB-70C1-40F5-B13E-9C11F748E697 -derivedDataPath /private/tmp/vitora-main-dd ENABLE_USER_SCRIPT_SANDBOXING=NO build
Result: BUILD SUCCEEDED
```

**UI 测试结果**

```text
xcodebuild -quiet -workspace Vitora.xcworkspace -scheme Vitora -destination id=EE0BC9AB-70C1-40F5-B13E-9C11F748E697 -derivedDataPath /private/tmp/vitora-main-dd -parallel-testing-enabled NO -only-testing:VitoraUITests/CyclePivotUITests ENABLE_USER_SCRIPT_SANDBOXING=NO test
Result: TEST FAILED before UI execution because VitoraTests cannot compile Expo modules.
Error: missing required modules: EXConstants, Expo, ExpoAsset, ExpoBlur, ExpoFileSystem, ExpoFont, ExpoHead, ExpoKeepAwake, ExpoLinearGradient, ExpoLinking, ExpoModulesCore, ExpoSQLite, ExpoSecureStore.
```

## 2026-05-27 · 花田地图 v1.7 地图与详情统一外框

**目的**

按用户对图 1 / 图 2 的对比反馈，把当前“地图一块、详情卡一块”的分裂感收拢成参考图那种同一个框内的结构：外层先形成整体容器，再在容器下半区呈现具体详情。

**具体改动**

- `CycleView.swift`：新增 `CycleMapReportFrame`，用一个大圆角细描边容器同时包住 `FlowerMapView` 和 `CycleReviewInsightCard`。
- `CycleView.swift`：`CycleReviewInsightCard` 增加嵌入态，放入统一外框时移除自身独立大圆角背景和阴影，只保留内容 padding。
- `CyclePivotUITests.swift` / `AccessibilityUITests.swift`：增加 `cycle.mapReport.frame` 断言，确保统一外框在首屏存在。
- `cycle-page-spec.md` / `qa-checklist.md` / `components.md` / `interaction-acceptance.md`：同步 v1.7 验收标准。

**截图 / 产物**

```text
ios/QA/Screenshots/CycleUnifiedFrame-20260527/cycle-unified-frame-v2.png
```

**构建结果**

```text
xcodebuild -quiet -workspace Vitora.xcworkspace -scheme Vitora -destination id=EE0BC9AB-70C1-40F5-B13E-9C11F748E697 -derivedDataPath /private/tmp/vitora-main-dd ENABLE_USER_SCRIPT_SANDBOXING=NO build
Result: BUILD SUCCEEDED
```

**UI 测试结果**

```text
xcodebuild -quiet -workspace Vitora.xcworkspace -scheme Vitora -destination id=EE0BC9AB-70C1-40F5-B13E-9C11F748E697 -derivedDataPath /private/tmp/vitora-main-dd -parallel-testing-enabled NO -only-testing:VitoraUITests/CyclePivotUITests -only-testing:VitoraUITests/AccessibilityUITests ENABLE_USER_SCRIPT_SANDBOXING=NO test
Result: TEST FAILED before UI execution because VitoraTests cannot compile Expo modules.
Error: missing required modules: EXConstants, Expo, ExpoAsset, ExpoBlur, ExpoFileSystem, ExpoFont, ExpoHead, ExpoKeepAwake, ExpoLinearGradient, ExpoLinking, ExpoModulesCore, ExpoSQLite, ExpoSecureStore.
```

## 2026-05-27 · 花田地图 v1.6 顶部报告切换与单详情框

**目的**

按用户最新参考图，把 Cycle 页信息结构改为“地图在上，地图下方框住一个具体内容做详细介绍”：删除地图下方的 `本周 / 趋势（对比） / 近期` 文件夹 tab，把 Header 中间胶囊从 `当前城市 / 路线 / 地球` 改为 `本周 / 趋势对比 / 近期`。

**具体改动**

- `CycleView.swift`：新增 `selectedCycleReportTab`，Header 中间胶囊改为报告维度切换。
- `CycleView.swift`：`FlowerMapView` 不再接收顶部 segment；城市预览只由深圳 / 广州节点和点状路线触发。
- `CycleView.swift`：`CycleReviewInsightCard` 删除地图下方文件夹 tab，只保留单张详情报告框，内容随 Header 胶囊切换。
- `CycleView.swift`：清理已不可触发的 `地球预览` 分支，避免旧 `当前城市 / 路线 / 地球` 语义残留。
- `CyclePivotUITests.swift`：周期页断言改为 Header 胶囊 `cycle.review.tab.week / trend / recent`，不再期待旧 `cycle.flowerMap.segment.*`。
- `facts.md`、`decision-log.md`、`spec.md`、`wireframes.md`、`components.md`、`interaction-acceptance.md`、`cycle-page-spec.md`、`qa-checklist.md`：同步 D-084 / v1.6 规则。

**截图 / 产物**

```text
ios/QA/Screenshots/CycleTopReportTabs-20260527/cycle-top-report-tabs-v2.png
```

**构建结果**

```text
xcodebuild -quiet -workspace Vitora.xcworkspace -scheme Vitora -destination id=EE0BC9AB-70C1-40F5-B13E-9C11F748E697 -derivedDataPath /private/tmp/vitora-main-dd ENABLE_USER_SCRIPT_SANDBOXING=NO build
Result: BUILD SUCCEEDED
```

**UI 测试结果**

```text
xcodebuild -quiet -workspace Vitora.xcworkspace -scheme Vitora -destination id=EE0BC9AB-70C1-40F5-B13E-9C11F748E697 -derivedDataPath /private/tmp/vitora-main-dd -parallel-testing-enabled NO -only-testing:VitoraUITests/CyclePivotUITests -only-testing:VitoraUITests/AccessibilityUITests ENABLE_USER_SCRIPT_SANDBOXING=NO test
Result: TEST FAILED before UI execution because VitoraTests cannot compile Expo modules.
Error: missing required modules: EXConstants, Expo, ExpoAsset, ExpoBlur, ExpoFileSystem, ExpoFont, ExpoHead, ExpoKeepAwake, ExpoLinearGradient, ExpoLinking, ExpoModulesCore, ExpoSQLite, ExpoSecureStore.
```

**未解决问题**

- UI test 仍被既有 `VitoraTests` Expo module 缺失阻塞，未进入 Cycle UI 实际执行。
- 花田真实数据仍为 mock 运行态；后续接入真实周期/反馈数据时需要替换 `plantedCount` 和城市进度来源。

## 2026-05-27 · 花田地图 v1.5 路线去背景与本周复盘信息框架

**目的**

按用户最新截图反馈继续减轻 Cycle 顶部花田模块：去掉深圳 / 广州节点后的白色背景，去掉路线条中 `还差 12 格` 明文，去掉右下 `24朵` 的胶囊背景；同时将本周报告改成参考图的“上内容、下信息”结构，用高低柱状图表达本周能量复盘。

**具体改动**

- `CycleView.swift`：路线条移除整条白色胶囊背景和剩余格数 chip，保留深圳起点、12 个小点进度和广州终点；剩余格数只保留在可访问性标签和点击后的解锁说明里。
- `CycleView.swift`：深圳 / 广州节点仅保留圆点 + 城市名，不再叠加白色背景或白描边。
- `CycleView.swift`：地图右下花朵收集入口改成无背景的花朵图标 + `24朵`，点击仍打开花朵说明 sheet。
- `CycleView.swift`：本周报告卡改成上半区日期范围、本周复盘、高低柱状图和计数；下半区为影响来源分布、三段说明、监测摘要和当前周期进度。
- `CyclePivotUITests.swift`：同步断言不再期待可见 `还差 12 格`，并增加 `影响来源分布` 检查。
- `cycle-page-spec.md` / `qa-checklist.md`：同步 v1.5 验收标准。

**截图 / 产物**

```text
ios/QA/Screenshots/CycleCleanRouteReport-20260527/cycle-clean-route-report-v2.png
```

**构建结果**

```text
xcodebuild -quiet -workspace Vitora.xcworkspace -scheme Vitora -destination id=EE0BC9AB-70C1-40F5-B13E-9C11F748E697 -derivedDataPath /private/tmp/vitora-main-dd ENABLE_USER_SCRIPT_SANDBOXING=NO build
Result: BUILD SUCCEEDED
```

**UI 测试结果**

```text
xcodebuild -quiet -workspace Vitora.xcworkspace -scheme Vitora -destination id=EE0BC9AB-70C1-40F5-B13E-9C11F748E697 -derivedDataPath /private/tmp/vitora-main-dd -parallel-testing-enabled NO -only-testing:VitoraUITests/CyclePivotUITests -only-testing:VitoraUITests/AccessibilityUITests ENABLE_USER_SCRIPT_SANDBOXING=NO test
Result: TEST FAILED before UI execution because VitoraTests cannot compile Expo modules.
Error: missing required modules: EXConstants, Expo, ExpoAsset, ExpoBlur, ExpoFileSystem, ExpoFont, ExpoHead, ExpoKeepAwake, ExpoLinearGradient, ExpoLinking, ExpoModulesCore, ExpoSQLite, ExpoSecureStore.
```

**未解决问题**

- UI test 仍被既有 `VitoraTests` Expo module 缺失阻塞，未进入 Cycle UI 实际执行。
- 花田真实数据仍为 mock 运行态；后续接入真实周期/反馈数据时需要替换 `plantedCount` 和城市进度来源。

## 2026-05-27 · 花田地图 v1.4 点状路线与花朵收集入口

**目的**

按用户最新截图反馈，把 Cycle 花田模块继续轻量化：种花引导从实心绿球改为透明虚线圆环，路线条改成深圳到广州的点状格子进度，`手册` 文案从路线条移除，地图右下改为花朵图标 + 已收集数量。

**具体改动**

- `CycleView.swift`：悬浮种花入口改为透明虚线圆环，未种显示幼苗，种下后显示低透明向日葵状态。
- `CycleView.swift`：地图整体下移约 10pt，给路线条和花田之间更多呼吸空间。
- `CycleView.swift`：路线条改为深圳起点、广州终点和中间点状进度格；保留 `还差 N 格` 交互。
- `CycleView.swift`：移除路线条旁的 `手册` 文案按钮，地图右下新增花朵收集入口，显示 `24朵` 并复用花朵说明 sheet。
- `cycle-page-spec.md` / `qa-checklist.md`：同步 v1.4 验收标准。

**截图 / 产物**

```text
ios/QA/Screenshots/CycleRouteDots-20260527/cycle-route-dots-v1.png
```

**构建结果**

```text
xcodebuild -quiet -workspace Vitora.xcworkspace -scheme Vitora -destination id=EE0BC9AB-70C1-40F5-B13E-9C11F748E697 -derivedDataPath /private/tmp/vitora-main-dd ENABLE_USER_SCRIPT_SANDBOXING=NO build
Result: BUILD SUCCEEDED
```

**UI 测试结果**

```text
xcodebuild -quiet -workspace Vitora.xcworkspace -scheme Vitora -destination id=EE0BC9AB-70C1-40F5-B13E-9C11F748E697 -derivedDataPath /private/tmp/vitora-main-dd -parallel-testing-enabled NO -only-testing:VitoraUITests/CyclePivotUITests -only-testing:VitoraUITests/AccessibilityUITests ENABLE_USER_SCRIPT_SANDBOXING=NO test
Result: TEST FAILED before UI execution because VitoraTests cannot compile Expo modules.
Error: missing required modules: EXConstants, Expo, ExpoAsset, ExpoBlur, ExpoFileSystem, ExpoFont, ExpoHead, ExpoKeepAwake, ExpoLinearGradient, ExpoLinking, ExpoModulesCore, ExpoSQLite, ExpoSecureStore.
```

**未解决问题**

- 花田真实数据仍为 mock 运行态；后续接入真实周期/反馈数据时需要替换 `plantedCount` 和城市进度来源。

## 2026-05-26 · 花田地图 v1.3 顶部精简与悬浮种花引导

**目的**

按用户最新反馈，删除三段切换下方的 SummaryCard，让周期页顶部更轻：路线条直接上移，种花入口改为地图上的圆形悬浮引导，`手册` 与 `还差 N 格` 放在同一行。

**具体改动**

- `CycleView.swift`：移除 `FlowerMapView` 中的 SummaryCard 调用，不再显示 `当前城市 / 今日能量 / 地图进度 / 绿色种子大按钮`。
- `CycleView.swift`：新增地图右上的悬浮圆形 `种下今天` 引导，保留 `cycle.flowerMap.plantToday`；种下后显示 `今日已种下`。
- `CycleView.swift`：路线条重做为深圳节点、连接线、广州节点、`还差 N 格` 和同排 `手册`；种下今天后剩余格数从 `12` 变为 `11`。
- `CyclePivotUITests.swift` / `AccessibilityUITests.swift`：移除 SummaryCard 断言，补充 `cycle.flowerMap.remaining`、悬浮种花和手册的回归断言。
- `cycle-page-spec.md` / `qa-checklist.md`：同步 v1.3 验收标准。

**截图 / 产物**

```text
ios/QA/Screenshots/CycleTopSimplify-20260526/cycle-top-simplified-installed.png
```

**构建结果**

```text
xcodebuild -quiet -workspace Vitora.xcworkspace -scheme Vitora -destination id=EE0BC9AB-70C1-40F5-B13E-9C11F748E697 -derivedDataPath /private/tmp/vitora-main-dd ENABLE_USER_SCRIPT_SANDBOXING=NO build
Result: BUILD SUCCEEDED
```

**UI 测试结果**

```text
xcodebuild -quiet -workspace Vitora.xcworkspace -scheme Vitora -destination id=EE0BC9AB-70C1-40F5-B13E-9C11F748E697 -derivedDataPath /private/tmp/vitora-main-dd -parallel-testing-enabled NO -only-testing:VitoraUITests/CyclePivotUITests -only-testing:VitoraUITests/AccessibilityUITests ENABLE_USER_SCRIPT_SANDBOXING=NO test
Result: TEST FAILED before UI execution because VitoraTests cannot compile Expo modules.
Error: missing required modules: EXConstants, Expo, ExpoAsset, ExpoBlur, ExpoFileSystem, ExpoFont, ExpoHead, ExpoKeepAwake, ExpoLinearGradient, ExpoLinking, ExpoModulesCore, ExpoSQLite, ExpoSecureStore.
```

**未解决问题**

- 花田真实数据仍为 mock 运行态；后续接入真实周期/反馈数据时需要替换 `plantedCount` 和城市进度来源。
- 坐标式模拟器点击不稳定；后续交互建议用 XCUITest 可访问性路径固化。

## 2026-05-25 · 花田地图 v1.2 耕地三态与报告卡上移

**目的**

按用户提供的 `/Users/youxiang/Downloads/花园地图服饰2 (1).md`，把 Cycle 顶部花田从“默认绿色草坪”改成进度驱动三态：未种植为棕色耕地，种植中为耕地 + 幼苗/开花，种满后才成为完整绿色花田；同时移除花田下方 `已解锁 / 当前深圳 / 下一站广州` 三张状态卡，让文件夹报告卡上移。

**具体改动**

- `CycleView.swift`：`FlowerMapTileKind` 调整为 `void / emptySoil / sprout / bloom / today / locked`，城市 shape 只决定轮廓，`plantedCount` 决定视觉状态。
- `CycleView.swift`：深圳 shape 重排为 36 格抽象轮廓，保留横向主体、边缘延展和小离岛。
- `CycleView.swift`：空地顶面改为土棕耕地，增加田垄、土粒和小石子纹理；种植后先短暂显示幼苗，再变成今日花。
- `CycleView.swift`：移除花田下方三张状态卡渲染，保留路线条里的 `下一站：广州 / 还差 12 格`。
- `CyclePivotUITests.swift`：增加三态启动参数 `-vitoraUITestCycleFlowerMapPlantedCount 0|8|24|36` 和底部状态卡反向断言。
- `cycle-page-spec.md` / `qa-checklist.md`：同步 v1.2 验收标准。

**截图 / 产物**

```text
ios/QA/Screenshots/CycleRender-20260525/cycle-flower-map-v1.2-00.png
ios/QA/Screenshots/CycleRender-20260525/cycle-flower-map-v1.2-08.png
ios/QA/Screenshots/CycleRender-20260525/cycle-flower-map-v1.2-24.png
ios/QA/Screenshots/CycleRender-20260525/cycle-flower-map-v1.2-36.png
```

**构建结果**

```text
xcodebuild -quiet -workspace Vitora.xcworkspace -scheme Vitora -destination id=E674099B-EB4A-444D-8B9F-639C9D719C2B -derivedDataPath /private/tmp/vitora-cycle-dd ENABLE_USER_SCRIPT_SANDBOXING=NO build
Result: BUILD SUCCEEDED
```

**UI 测试结果**

```text
xcodebuild -quiet -workspace Vitora.xcworkspace -scheme Vitora -destination id=E674099B-EB4A-444D-8B9F-639C9D719C2B -derivedDataPath /private/tmp/vitora-cycle-dd -parallel-testing-enabled NO -only-testing:VitoraUITests/CyclePivotUITests -only-testing:VitoraUITests/VisualLanguageSmokeTests -only-testing:VitoraUITests/AccessibilityUITests ENABLE_USER_SCRIPT_SANDBOXING=NO test
Result: TEST FAILED before UI execution because VitoraTests cannot compile Expo modules.
Error: missing required modules: EXConstants, Expo, ExpoAsset, ExpoBlur, ExpoFileSystem, ExpoFont, ExpoHead, ExpoKeepAwake, ExpoLinearGradient, ExpoLinking, ExpoModulesCore, ExpoSQLite, ExpoSecureStore.
```

**未解决问题**

- 当前 Xcode scheme 的 UI test 仍被既有 `VitoraTests` Expo module 缺失阻塞；本次已通过 app build 和模拟器截图完成视觉验收。

## 2026-05-25 · D-076 花之地图首屏落地规则补充

**目的**

按用户提供的目标图一，把 Cycle 首屏从旧报告卡优先改为“花之地图 + 文件夹报告卡”组合：顶部用等距深圳花之地图表达长期节律与恢复资源，下方继续保留 `本周 / 趋势（对比） / 近期` 报告卡。

**具体改动**

- `cycle-page-spec.md`：补齐三段切换、主信息卡、路线条、等距 tile 地图、右下 `手册` 按钮和三张状态卡规则。
- `cycle-page-spec.md`：明确 `手册` 只作为花朵说明/已收集预览，不恢复花园手册、成长册、任务花园或打卡系统。
- `qa-checklist.md`：增加 `cycle.flowerMap`、种花后 `25/36`、问号说明、手册说明和城市节点切换验收。

**边界**

- 不使用 RN / Expo、图片地图、SVG 地图或复杂动画库。
- 不新增第四主 Tab。
- 不新增打卡、完成率、连续天数、红点、任务清单、成长册、花园手册或种子选择。
- 花之地图数据 v1 保持 mock 运行态：深圳 `24/36`，下一站广州，今日能量 `100/100`。

## 2026-05-24 · D-073 Cycle 报告卡与三页展示图

**目的**

按用户最新报告卡方向，把 Cycle 首页从 D-067 的四个折页 tab 收口为三页报告语言：`本周 / 趋势（对比） / 近期`。iPhone 内使用叠层单卡 + 顶部文件夹标签，1536 展示图使用三张并排报告卡，避免移动端信息过密。

**具体改动**

- `CycleView`：`CycleReviewInsightCard` 改为 3 个文件夹 tab，默认 `本周` 在最前，inactive 标签低饱和露出，主卡与 active 标签融合。
- `CycleView`：`本周` 展示 7 日柱状复盘、三段说明、四格监测摘要和当前周期进度；`趋势（对比）` 展示月度综合对比、4 行蓝色进度条、归因解释和本月总结；`近期` 展示能量折线、监测解释、下一步和黄色描边按钮。
- `QA/Screenshots/VitoraReport/vitora-report-3up.html`：新增 HTML/CSS/SVG 展示图源文件，不引入图表库。
- `QA/Screenshots/VitoraReport/vitora-report-3up-1536x1024.png`：输出三张并排报告卡，尺寸已校验为 `1536×1024`。
- `CyclePivotUITests` / `AccessibilityUITests`：更新为 `cycle.review.tab.week`、`cycle.review.tab.trend`、`cycle.review.tab.recent`，并对旧 `experience / monitoring` 做反向断言。
- `facts.md`、`wireframes.md`、`components.md`、`interaction-acceptance.md`、`tasks.md`、`cycle-page-spec.md`、`qa-checklist.md` 和 decision log 同步为 D-073。

**边界**

- Cycle 首页不恢复日历首页。
- 不再展示旧 `经历 / 监测` 作为一级 tab。
- 不恢复能量动态下方卡、节律洞察卡或 `本周期花架证据`。
- 不新增打卡、完成率、连续天数、红点、复杂医疗 dashboard、订阅/VIP 或第四主 Tab。
- 展示图不进入 app bundle，不影响 iOS 工程运行。

**构建结果**

```text
xcodebuild -workspace Vitora.xcworkspace -scheme Vitora -destination id=EE0BC9AB-70C1-40F5-B13E-9C11F748E697 ENABLE_USER_SCRIPT_SANDBOXING=NO build
Result: BUILD SUCCEEDED
```

**UI 测试结果**

```text
xcodebuild -workspace Vitora.xcworkspace -scheme Vitora -destination id=EE0BC9AB-70C1-40F5-B13E-9C11F748E697 -parallel-testing-enabled NO -only-testing:VitoraUITests/CyclePivotUITests -only-testing:VitoraUITests/AccessibilityUITests ENABLE_USER_SCRIPT_SANDBOXING=NO test
Result: TEST FAILED before UI execution because VitoraTests cannot compile Expo modules.
Error: missing required modules: EXConstants, Expo, ExpoAsset, ExpoBlur, ExpoFileSystem, ExpoFont, ExpoHead, ExpoKeepAwake, ExpoLinearGradient, ExpoLinking, ExpoModulesCore, ExpoSQLite, ExpoSecureStore.
```

**截图 / 产物**

```text
ios/QA/Screenshots/VitoraReport/vitora-report-3up-1536x1024.png
```

## 2026-05-18 · 增加花架证据层但不恢复花田地图

**目的**

按用户最新“睡眠种子玩法”计划，把种子重新定义为建议反馈可视化：Cycle 只展示最近建议是否真的有用，不恢复 `30 天成长册`、花田地图或任务化玩法。

**具体改动**

- `cycle-page-spec.md`：允许低权重 `本周期花架证据`，限定为 7-10 张“建议 → 反馈”的学习结果。
- 保持 `30 天成长册`、种子选择、花田地图、完成率、连续天数、红点和商店货币为禁止项。
- `CycleView` 计划在三件事、能量动态和节律洞察之后插入花架证据卡，不作为首屏主视觉。

**边界**

- 花架是证据层，不是地图、日历、成就或打卡。
- 休眠花卡用中性文案，不表达失败惩罚。

## 2026-05-18 · 移除成长册与花园包装

**目的**

按用户最新 4 张截图反馈，移除 Cycle 可见路径中的 `30 天成长册`、成长卡网格、花园手册和种子选择包装。Cycle 回到长期节律页：三件事总结、能量动态和节律洞察承接周期学习，不做养成、打卡或花园心智。

**具体改动**

- `CycleView`：删除 `CycleReviewGrowthAlbumHero`，首页不再展示 `30 天成长册`、`8 / 30` 或成长卡网格。
- `EnergyDynamicsCard` / `EnergyDynamicsDetailSheet`：删除成长册模型、成长卡网格和成长卡 callout，详情页只保留趋势、证据和 Vitora 叙事。
- `CyclePivotUITests` / `VisualLanguageSmokeTests` / `AccessibilityUITests`：把成长册断言改为负向验收，并把触控验收迁移到三件事页签。
- `facts.md`、`spec.md`、`wireframes.md`、`components.md`、`interaction-acceptance.md`、`quickstart.md` 和 `cycle-page` 规格同步更新为“不得出现”。

**边界**

- 不删除晚间复盘能力本身，只删除种子/花园包装。
- 不新增日历首页、任务清单、完成率、连续天数或商业化入口。

**构建结果**

```text
xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
Result: BUILD SUCCEEDED
```

**UI 测试结果**

```text
xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -parallel-testing-enabled NO -only-testing:VitoraUITests/TodayPivotUITests -only-testing:VitoraUITests/CyclePivotUITests -only-testing:VitoraUITests/VisualLanguageSmokeTests -only-testing:VitoraUITests/AccessibilityUITests -only-testing:VitoraUITests/EveningReviewUITests test
Result: TEST SUCCEEDED，13 tests，0 failures
```

**截图**

```text
ios/QA/Screenshots/ImplementationV1/20260518-remove-growth-cycle.png
```

## 2026-05-18 · 参考图结构复核后的首屏收紧

**目的**

按用户提供的“缴费日历”参考图复核当前 Cycle 首页。参考图只取信息层级、白霜摘要卡、连体页签和列表节奏，不复制账单/日历业务结构。修正上一版中 `30 天成长册` 过早占据首屏、三件事切换被推到下方的问题。

**具体改动**

- `CycleView`：把 `这 30 天，Vitora 看见的三件事` 提到 Header 下方，成为首屏主卡；`30 天成长册` 降到三件事列表之后。
- `CycleView`：保留左头像 `cycle.settings.open` 和右分享 `cycle.share.open`，顶部仍是水感背景 + 轻量日历插画，不改成账单页面。
- `CycleReviewInsightCard`：摘要区由 2x2 大卡片改为参考图式紧凑结构：两项主指标、分割线、两项辅助指标。
- `CycleReviewSnapshotMetric`：新增本地私有指标列组件，约束字号、单行缩放和分割线，避免小屏文字挤压。
- `CycleGrowthAlbumGrid`：保持 30 天成长册为回看层，使用 10 列紧凑网格，避免形成任务进度或打卡心智。

**设计分析结论**

- 原实现主要差距不是控件缺失，而是首屏权重不对：成长册太像主功能，三件事切换不够像参考图中的主列表入口。
- 目标结构应是：左头像 / 右分享导航、标题与轻插画、紧凑白霜摘要卡、连体页签、可点击洞察列表。
- 动效只保留 180ms 页签切换和 120ms 内容淡入；不加入粒子、重游戏反馈或复杂滚动转场。

**不能使用**

- 不用 Playwright 驱动原生 iOS；原生点击验收使用 XCUITest + `xcrun simctl`。
- 不引入 WebView、Three.js、网页组件、旧 RN / Expo。
- 不复制参考图的缴费金额、账单列表、日历首页或商业化结构。
- 不做打卡、连续天数、完成率、未完成红点或任务清单。
- 分享卡不包含记录原文、prompt、完整 AI 输出或隐藏健康数据。

**截图**

```text
ios/QA/Screenshots/ImplementationV1/20260518-cycle-reference-compact-summary-final.png
```

**构建结果**

```text
xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
Result: BUILD SUCCEEDED
```

**UI 测试结果**

```text
xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -parallel-testing-enabled NO -only-testing:VitoraUITests/CyclePivotUITests -only-testing:VitoraUITests/VisualLanguageSmokeTests -only-testing:VitoraUITests/AccessibilityUITests test
Result: TEST SUCCEEDED，7 tests，0 failures
```

**未解决问题**

- 目前仍是 sample 派生数据；真实周期、记录反馈和 Health 数据接入后需要替换数据源。
- 底部 Dock 会自然覆盖滚动内容下缘；首屏核心信息已避开覆盖区，后续可继续细调 Dock 与下方成长册露出比例。

## 2026-05-17 · Cycle 顶部头像分享与三件事卡片切换

**目的**

按最新参考图，把 Cycle 顶部改为左头像我的入口、右分享周期卡片入口，并把“三件事”总结卡改为上方摘要 + 下方卡片式切换，取参考图的白霜玻璃和连体页签语言，不改变 Cycle 的长期节律定位。

**具体改动**

- `CycleView`：Header 改为左上头像按钮、居中 `周期回顾 / 复盘成长 · 洞察规律`、右上分享按钮；`cycle.settings.open` 保留在头像入口，新增 `cycle.share.open`。
- `CycleView`：新增本地 `CycleShareCardSnapshotView` 与 `CycleShareActivityView`，使用 SwiftUI `ImageRenderer` 生成周期摘要图，并通过原生 `UIActivityViewController` 分享。
- `CycleView`：`这 30 天，Vitora 看见的三件事` 改成白色霜状卡片，上方展示当前阶段、本周平均、低谷窗口、待确认摘要；下方 `本周 / 趋势（月） / 周期` 使用卡片式页签切换。
- `CyclePivotUITests` / `AccessibilityUITests`：补齐三件事 tab、头像打开我的、分享 sheet smoke test 和分享按钮 44pt 触控断言。
- `cycle-page` 规格、QA、交互验收和组件文档同步改为左头像我的 + 右分享周期卡片。

**边界**

- 不把 Cycle 改成日历首页。
- 不新增第四个 Tab、打卡、连续天数、完成率、红点、VIP 或商业入口。
- 分享只导出当前周期摘要卡片，不导出记录原文、prompt、完整 AI 输出或隐藏健康数据。
- 左头像是用户入口，不是 Pixel Vitora。

**截图**

```text
ios/QA/Screenshots/ImplementationV1/20260517-cycle-header-share-card-switcher.png
```

**构建结果**

```text
xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
Result: BUILD SUCCEEDED
```

**UI 测试结果**

```text
xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -parallel-testing-enabled NO -only-testing:VitoraUITests/CyclePivotUITests -only-testing:VitoraUITests/VisualLanguageSmokeTests -only-testing:VitoraUITests/AccessibilityUITests test
Result: TEST SUCCEEDED，7 tests，0 failures
```

**未解决问题**

- 周期成长册和三件事摘要仍使用 sample 派生数据；真实周期长度、反馈记录和 Health 数据接入后需要替换数据源。

## 2026-05-17 · 花田地图收敛为 30 天成长册

**目的**

按 `Vitora_Garden_MVP_Document.md`，把 Cycle 首页从高成本花田地图收敛为轻量 `30 天成长册`，承接“花园手册 + 晚间复盘 + 每日成长卡片”的 MVP 闭环。

**具体改动**

- `CycleView`：首页主视觉改为 `30 天成长册`，显示 `8 / 30` 和 30 天成长卡网格，不再展示 `下拉进入花田地图`。
- `CycleView`：总结标题改为 `这 30 天，Vitora 看见的三件事`，副标题改为 `成长册已更新 5月8日 的理解`。
- `EnergyDynamicsCard` / `EnergyDynamicsDetailSheet`：详情层文案同步为周期成长册和成长卡反馈。
- `CyclePivotUITests` / `VisualLanguageSmokeTests`：断言从 `cycle.garden.field` 改为 `cycle.growth.album`。

**边界**

- 不新增底部花园 Tab。
- 不加入商城、VIP、露珠价格、枯萎、失败、红点或连续打卡。
- 成长册是回看与学习层，不是任务进度或成就系统。

## 2026-05-17 · 周期回顾首页与花田主视觉

**目的**

按最新 Today/Cycle 视觉反馈，将 Cycle 首页从“阶段关系卡 + 能量动态卡”升级为“周期回顾”：让花田成为 Vitora 对本周期理解的主视觉，并用三件事总结卡解释长期节律。

**具体改动**

- `CycleView`：Header 改为 `周期回顾 / 复盘成长 · 洞察规律`，保留右上设置入口与 `cycle.settings.open`。
- `CycleView`：新增等距花田主视觉，使用现有 `DailyBloom` 派生数据与参数化小花，不新增任务、打卡或完成率。
- `CycleView`：新增“这片花田告诉 Vitora 的三件事”总结卡，支持 `本周 / 趋势（月） / 周期` 切换。
- `CycleView`：保留 `EnergyDynamicsCard`，并在下方加入 `规律模式 / 有效助力 / 下周期调整` 三张洞察卡。
- `EnergyDynamicsCard`：移除首页能量卡底部重复花田入口，避免花田主视觉和能量卡重复。

**截图**

```text
待补：ios/QA/Screenshots/ImplementationV1/cycle-review-20260517.png
```

**构建结果**

```text
xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
Result: BUILD SUCCEEDED
```

**UI 测试结果**

```text
xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -parallel-testing-enabled NO -only-testing:VitoraUITests/TodayPivotUITests -only-testing:VitoraUITests/CyclePivotUITests -only-testing:VitoraUITests/VisualLanguageSmokeTests -only-testing:VitoraUITests/AccessibilityUITests test
Result: TEST SUCCEEDED，11 tests，0 failures

xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -parallel-testing-enabled NO -only-testing:VitoraUITests/TodayPivotUITests -only-testing:VitoraUITests/CyclePivotUITests test
Result: TEST SUCCEEDED，7 tests，0 failures
```

**未解决问题**

- 周期花田仍使用 sample 派生数据；真实周期长度、反馈记录和 Health 数据接入后需要替换数据源。
- 花田地图下拉目前是轻提示入口，真实“花田地图”展开交互后续可继续完善。

## 2026-05-15 · 白色双态玻璃与周期花田反馈层

**目的**

把 Cycle 页面从彩色玻璃卡继续收敛到“干净白色双态玻璃”，并新增周期花田作为反馈与学习层。花田用于帮助 Vitora 理解周期内每天的状态，不做打卡、完成率或连续天数。

**具体改动**

- `GlassSurface`：新增 `whiteResting` / `whiteActive` 双态玻璃 variant，提供高白度磨砂、白色 rim、柔高光和轻阴影。
- `CurrentPhaseRelationCard`、`EnergyDynamicsCard`、`CycleView` Tip、Cycle 详情信息块：切换到白色双态玻璃，避免卡片大面积彩色底。
- `EnergyDynamicsCard`：在能量动态卡底部新增周期花田入口，文案为“本周期已长出几朵可理解的花”，不展示完成率。
- `EnergyDynamicsCard`：新增 `DailyBloom`、`CycleGardenSummary` 派生模型和 `CycleGardenGrid` / `DailyBloomCell` 参数化小花 UI。
- `EnergyDynamicsDetailSheet`：详情页新增周期花田网格、每日花 callout、“像 / 不太像 / 补充一句”反馈入口，以及“这片花田告诉 Vitora 的三件事”总结。

**设计边界**

- 花田是周期反馈和学习结果，不是独立游戏系统。
- 花形态来自能量、反馈状态和周期阶段的低面积语义点缀。
- 不显示打卡、连续天数、完成率、红点、缺失惩罚或失败状态。
- 不使用每日 AI 生成图片；P0 用 SwiftUI `Canvas` / `Shape` 参数化绘制。

**截图**

```text
ios/QA/Screenshots/ImplementationV1/59-cycle-white-glass-garden.png
```

**构建结果**

```text
xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
Result: BUILD SUCCEEDED
```

**UI 测试结果**

```text
xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -parallel-testing-enabled NO -only-testing:VitoraUITests/CyclePivotUITests -only-testing:VitoraUITests/VisualLanguageSmokeTests test
Result: TEST SUCCEEDED
Executed 3 tests, 0 failures
```

**未解决问题**

- 目前花田使用 sample 派生数据；真实周期长度、反馈记录和 Health 数据接入后需要替换数据源。
- 花田反馈按钮当前复用 Ask Vitora 入口，后续需要接入真实“Vitora 理解确认”保存路径。
- 尚未新增 `DailyBloom` 映射单元测试；下一轮应补 25 / 28 / 30 天格子数量、seed 稳定性和花型映射测试。
- 额外补跑 `AccessibilityUITests` 未通过，失败点集中在既有 Today / Vitora 输入栏与旧测试期望：`primary.tabbar` 标识缺失、左右 Tab 42pt、小输入按钮 30pt、旧 `today.calibration.tell` 入口已被新 Today 结构替换。该失败不是本轮 Cycle 花田改动引入，但后续应单独修复。

## 2026-05-07 · Cycle 首页目标图对齐 baseline

**目的**

将 Cycle 首页对齐 `assets/design_04/cycle_d.png` 方向，让首屏形成“长期节律背景 + 能量动态”的清晰层级，并避免回退到日历首页或 dashboard。

**具体改动**

- `CycleView`：压缩 header，移除 header 下方大型 Tip，把轻 Tip pill 移到能量卡下方。
- `CycleView`：右上 settings 改为小视觉玻璃圆，但保持 44pt 可访问触控范围。
- `CurrentPhaseRelationCard`：重构为小标题、`Day 18 · 黄体期中段`、四色阶段轴、两条 Vitora 叙事、右下小 Pixel Vitora + chevron。
- `EnergyDynamicsCard`：压缩卡片结构，加入日/周/月 segmented、`62%` + `↑5%` 摘要、平滑单曲线、高/中/低轴、默认 `今天 68%` callout、底部 Vitora 叙事行。
- 页面内 Pixel Vitora 使用现有 `PixelVitoraScene` baseline，未单独重画 IP。

**截图**

```text
ios/QA/Screenshots/ImplementationV1/17-cycle-target-aligned.png
```

**构建结果**

```text
xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
Result: BUILD SUCCEEDED
```

**UI 测试结果**

```text
xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -parallel-testing-enabled NO -only-testing:VitoraUITests/CyclePivotUITests -only-testing:VitoraUITests/VisualLanguageSmokeTests -only-testing:VitoraUITests/AccessibilityUITests test
Result: TEST SUCCEEDED
Executed 6 tests, 0 failures
```

**中途发现**

首轮回归发现 `cycle.settings.open` 可访问 frame 约 37pt，小于 44pt。已修复为 36pt 视觉圆 + 44pt 外层触控。

**未解决问题**

- Tip pill 目前是静态轻提示，后续可接入一次性 TipKit 出现/消失规则。
- 低数据、阶段不确定、低置信等状态仍需后续补充视觉矩阵。
- 图表 token 可继续抽象，以便详情页和首页保持一致。
