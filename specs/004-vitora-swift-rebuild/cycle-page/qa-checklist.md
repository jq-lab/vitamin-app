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

- 顶部日历头卡：左上头像入口、右上分享和折叠周历在同一张大圆角卡片里；不显示独立 `周期` 或 `周期回顾` 大标题。
- 能量日历卡：折叠态显示 7 天周历 strip，每天以圆环/细线表达能量，选中日高亮；点击 chevron 后可展开整月能量进度条。
- 能量摘要卡：日历下方可见今日能量圆环、本周平均和小号 `6.5` 参考 chip；不显示大号 `6.5 mmol/L` 设备读数卡。
- 报告入口：`本周 / 趋势对比 / 近期` 位于指标卡下方，不在 Header 中；默认 `本周`，点击后切换下方详情报告内容。
- 默认 `本周` 内容：上半区日期范围 + 本周复盘高低柱状图，下半区影响来源分布、三段说明、本周监测摘要和当前周期进度。
- Bottom Tab。

## 3. 组件验收

| 区域 | 必须通过 |
| --- | --- |
| 顶部日历头卡 | 左上头像进入我的/设置；右上分享生成周期卡片截图；头像与分享触控不小于 44pt；两者和周历 strip 在同一张大圆角卡片里；不显示独立 `周期` 标题。 |
| 能量日历 | 存在 `cycle.energyCalendar.card`；折叠态有 `cycle.energyCalendar.strip` 和 `cycle.energyCalendar.toggle`；周历每天有圆环能量进度，选中日有摘要进度条。 |
| 展开月历 | 点击 `cycle.energyCalendar.toggle` 后出现 `cycle.energyCalendar.month`、`2026年5月` 和所有日期的细进度条；不得使用任务勾选、失败红叉、完成率或打卡图标。 |
| 能量摘要卡 | 存在 `cycle.energyMetric.card`；显示今日能量、本周平均和小号 `6.5` 参考 chip；不显示大号 `6.5 mmol/L`、TIR 环或设备连接状态；不出现诊断或治疗判断。 |
| 报告卡 | `本周 / 趋势对比 / 近期` 三段入口位于指标卡下方；切换后，详情框内容同步切换。 |
| 本周 | 展示本周复盘、日期范围、7 日高低柱状图、影响来源分布、重点发现、为什么、下周建议、本周监测摘要和当前周期进度。 |
| 趋势（对比） | 展示月度综合对比、4 行蓝色进度条、归因解释和本月总结。 |
| 近期 | 展示近期能量折线图、监测到了什么、近期结论 / 下一步和黄色描边按钮。 |
| Pixel Vitora | 继承 `pixel-vitora-ip/` baseline，不单独重画。 |

## 4. 可访问性验收

必须确认：

- `cycle.review.tab.week` frame 宽高都不小于 44pt。
- `cycle.review.tab.trend` frame 宽高都不小于 44pt。
- `cycle.review.tab.recent` frame 宽高都不小于 44pt。
- `cycle.energyDashboard.frame` 在首屏可见。
- `cycle.energyCalendar.toggle` frame 宽高都不小于 44pt。
- `cycle.energyCalendar.day.30` frame 宽高都不小于 44pt。
- `cycle.energyMetric.card` 在首屏可见。
- `cycle.settings.open` frame 宽高都不小于 44pt。
- `cycle.share.open` frame 宽高都不小于 44pt。
- Dynamic Type 下主卡仍可进入。
- Reduce Motion / Reduce Transparency 下主路径可用。

## 5. 反向验收

出现以下任一情况，直接不通过：

- Cycle 首页是任务日历、经期管理 dashboard 或打卡页；D-093 能量复盘日历不得出现任务/完成/连续天数心智。
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
