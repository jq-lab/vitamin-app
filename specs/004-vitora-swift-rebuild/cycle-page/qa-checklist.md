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

- Header：左上头像入口、`周期回顾`、副标题、右上分享。
- `这 30 天，Vitora 看见的三件事` 总结卡。
- 能量动态卡主体。
- 三张节律洞察卡。
- Bottom Tab。

## 3. 组件验收

| 区域 | 必须通过 |
| --- | --- |
| Header | 标题紧凑；左上头像进入我的/设置；右上分享生成周期卡片截图；两者触控不小于 44pt。 |
| 三件事总结 | 有卡片式 `本周 / 趋势（月） / 周期`，默认显示低谷窗口、恢复较好时段、影响因素、仍需校准。 |
| 能量卡 | 有日/周/月、`62%`、`↑5%`、平滑单曲线、`今天 68%` callout、高中低轴、叙事行。 |
| 节律洞察卡 | 有 `规律模式`、`有效助力`、`下周期调整`，不出现任务或完成压力。 |
| Pixel Vitora | 继承 `pixel-vitora-ip/` baseline，不单独重画。 |

## 4. 可访问性验收

必须确认：

- `cycle.review.tab.week` frame 宽高都不小于 44pt。
- `cycle.energy.card` frame 宽高都不小于 44pt。
- `cycle.settings.open` frame 宽高都不小于 44pt。
- `cycle.share.open` frame 宽高都不小于 44pt。
- `cycle.energy.point.today` 触控热区不小于 44pt。
- Dynamic Type 下主卡仍可进入。
- Reduce Motion / Reduce Transparency 下主路径可用。

## 5. 反向验收

出现以下任一情况，直接不通过：

- Cycle 首页是日历。
- 首页出现任务、打卡、完成率、连续天数或红点。
- 首页出现 `30 天成长册`、花园手册、种子选择、花田地图、任务花园、成就、连续记录或失败状态。
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
