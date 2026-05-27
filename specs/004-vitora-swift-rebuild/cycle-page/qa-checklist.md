# Cycle Page QA Checklist

> 适用于每次 Cycle 页面视觉、布局、图表、Tip 或接入规则改动。

## 1. 自动验收

构建：

```text
xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

关键 UI 回归：

```text
xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -parallel-testing-enabled NO -only-testing:VitoraUITests/CyclePivotUITests -only-testing:VitoraUITests/VisualLanguageSmokeTests -only-testing:VitoraUITests/AccessibilityUITests test
```

必须通过：

- `CyclePivotUITests`
- `VisualLanguageSmokeTests`
- `AccessibilityUITests`

## 2. 截图验收

每次实现后导出 iPhone 17 Pro Simulator 截图：

```text
xcrun simctl io <DEVICE_UDID> screenshot ios/QA/Screenshots/ImplementationV1/<new-cycle-screenshot>.png
```

人工检查首屏必须可见：

- Header：左上头像入口、右上分享；不显示 `周期回顾` 大标题和副标题。
- Header 中间胶囊：`本周 / 趋势对比 / 近期`，默认 `本周`，点击后切换地图下方同一张详情报告框。
- 统一地图报告框：一个大圆角细描边容器同时包住路线、花田地图、花朵收集入口和下方详情内容，不应看成上下两个独立区域。
- 花之地图：点状 `深圳 ··· 广州` 路线条、300-340pt 舒展等距 tile 地图、地图上透明虚线圆形 `种下今天` 引导、地图右下无背景的花朵图标 + 已收集数量入口；三段切换下方不再出现 SummaryCard，路线条不显示 `手册` 或 `还差 N 格` 明文，地图下方不再出现 `已解锁 / 当前深圳 / 下一站广州` 三张状态卡。
- 详情报告框：地图下方不再显示文件夹式 `本周 / 趋势（对比） / 近期` 标签，只显示当前胶囊选中内容的具体介绍；内容必须嵌入统一外框，不再作为独立大阴影卡片。
- 默认 `本周` 内容：上半区日期范围 + 本周复盘高低柱状图，下半区影响来源分布、三段说明、本周监测摘要和当前周期进度。
- Bottom Tab。

## 3. 组件验收

| 区域 | 必须通过 |
| --- | --- |
| Header | 左上头像进入我的/设置；中间胶囊展示 `本周 / 趋势对比 / 近期`；右上分享生成周期卡片截图；头像与分享触控不小于 44pt；不显示可见页面标题。 |
| 统一外框 | 存在 `cycle.mapReport.frame`；外框同时包住路线、花田地图、花朵收集入口和详情报告；内层报告不再单独投大阴影，不形成两个分离 section。 |
| 花之地图 | 有 `cycle.flowerMap`；显示无白色胶囊背景的深圳节点、点状进度和广州节点；不显示 `还差 12 格` 明文，不显示 `cycle.flowerMap.summary`；点击透明悬浮种花圆环后文案变 `今日已种下`，路线进度可访问性标签更新剩余 11 格；模块外层不再使用大包裹卡挤压地图。 |
| 地图交互 | 空地可种花；已种花可查看详情；点状路线或广州节点可进入下一站预览 / 解锁说明；深圳节点可返回当前城市；右下花朵收集入口只打开花朵说明/已收集预览/稀有度/已收集数量；城市 shape 只由地图内深圳 / 广州节点和点状路线触发。 |
| 地图视觉 | 地图主体高度约 300-340pt、横向舒展；`0/36` 为棕色耕地，`1...35/36` 为耕地 + 幼苗/开花层级，`36/36` 才成为完整绿色花田；空地 `+` 少量出现并集中在下一站方向；大型树类最多 1-2 个；未解锁城市使用真实 shape 但降饱和。 |
| 布局上移 | `已解锁 / 当前深圳 / 下一站广州` 三张状态卡不渲染；单张详情报告框直接跟随花田地图模块上移。 |
| 报告卡 | 地图下方只有一个嵌入式详情内容区，不再出现文件夹式 `本周 / 趋势（对比） / 近期` 三 tab；顶部胶囊切换后，详情框内容同步切换。 |
| 本周 | 展示本周复盘、日期范围、7 日高低柱状图、影响来源分布、重点发现、为什么、下周建议、本周监测摘要和当前周期进度。 |
| 趋势（对比） | 展示月度综合对比、4 行蓝色进度条、归因解释和本月总结。 |
| 近期 | 展示近期能量折线图、监测到了什么、近期结论 / 下一步和黄色描边按钮。 |
| Pixel Vitora | 继承 `pixel-vitora-ip/` baseline，不单独重画。 |

## 4. 可访问性验收

必须确认：

- `cycle.review.tab.week` frame 宽高都不小于 44pt。
- `cycle.review.tab.trend` frame 宽高都不小于 44pt。
- `cycle.review.tab.recent` frame 宽高都不小于 44pt。
- `cycle.mapReport.frame` 在首屏可见。
- `cycle.flowerMap.plantToday` frame 宽高都不小于 44pt。
- `cycle.flowerMap.remaining` frame 宽高都不小于 44pt。
- `cycle.flowerMap.handbook` frame 宽高都不小于 44pt。
- `cycle.settings.open` frame 宽高都不小于 44pt。
- `cycle.share.open` frame 宽高都不小于 44pt。
- Dynamic Type 下主卡仍可进入。
- Reduce Motion / Reduce Transparency 下主路径可用。

## 5. 反向验收

出现以下任一情况，直接不通过：

- Cycle 首页是日历。
- 首页出现任务、打卡、完成率、连续天数或红点。
- 首页出现 `30 天成长册`、花园手册、种子选择、任务花田地图、任务花园、成就、连续记录或失败状态。
- 首页出现 VIP、订阅、商业卡。
- 首页变成复杂多指标医疗 dashboard。
- 左上 profile/settings 被替换成 Pixel Vitora。
- 右上分享导出记录原文、prompt、完整 AI 输出或隐藏健康数据。
- Pixel Vitora 被 smooth orb、人类头像、宠物、emoji 或普通 icon 替代。
- 底部 Tab 遮挡输入、叙事行或 Tip。
- 健康文案出现诊断、治疗、保证预测或焦虑警报。

## 6. Handoff 检查

每次 Cycle 页面改动完成后必须：

- 保存截图。
- 更新 `change-log.md`。
- 若改变目标或规则，先更新 `cycle-page-spec.md`。
- 若改变 IP 状态、道具或视觉，先更新 `pixel-vitora-ip/` 对应文件。
