# Cycle Page Implementation Contract

> 面向：后续 SwiftUI 工程师 / coding agent  
> 目标：让所有 Cycle 页面改动继承当前页面 baseline

## 1. 允许改动入口

Cycle 页面首页视觉和结构改动只允许优先发生在：

```text
ios/Vitora/Features/CycleFeature/CycleView.swift
ios/Vitora/Features/CycleFeature/CurrentPhaseRelationCard.swift
ios/Vitora/Features/CycleFeature/EnergyDynamicsCard.swift
```

若必须改动共享组件，必须先说明原因，并确认不会影响 Today / Vitora / Support。

## 2. 不允许改动边界

Cycle 页面视觉微调不得改变：

- 三 Tab 结构。
- Cycle sheet 路由。
- 数据模型。
- HealthKit / AI / persistence 合同。
- Pixel Vitora 统一组件。
- Today 顶部日历入口归属。

不得新增：

- 第四个主 Tab。
- Cycle 日历首页。
- 打卡、任务、完成率、连续天数。
- VIP / 订阅 / 商业卡。
- 复杂多指标医疗 dashboard。

## 3. Pixel Vitora 接入规则

涉及页面内 Pixel Vitora 时，必须先读取：

```text
specs/004-vitora-swift-rebuild/pixel-vitora-ip/README.md
specs/004-vitora-swift-rebuild/pixel-vitora-ip/pixel-vitora-ip-spec.md
```

页面只允许传入统一组件参数：

- `state`
- `size`
- `accessory`
- `showsSparkles`
- `showsBaseShadow`

不得在 Cycle 页面内部单独重画另一个 Vitora face。

## 4. 交互接口保持稳定

后续视觉微调不得改变以下外部接口：

```swift
CurrentPhaseRelationCard(onOpenDetail:onAskVitora:)
EnergyDynamicsCard(onOpenDetail:onAskVitora:)
```

必须继续保持：

- 阶段卡 tap 进入阶段详情。
- 能量卡 tap 进入能量详情。
- AskableSurface long-press 可问 Vitora / 告诉不准 / 查看详情。
- 左上头像按钮从 Cycle Header 进入 `我的 / 设置`。
- 右上分享按钮只分享周期卡片截图，不导出记录原文、prompt、完整 AI 输出或隐藏健康数据。

## 5. 可访问性要求

每次改动后必须确认：

- `cycle.phase.card` 触控区域不小于 44pt。
- `cycle.energy.card` 触控区域不小于 44pt。
- `cycle.settings.open` 触控区域不小于 44pt。
- `cycle.share.open` 触控区域不小于 44pt。
- 图表点触控热区不小于 44pt。
- 重要趋势不只靠颜色表达。
- Reduce Motion / Reduce Transparency 下主路径仍可用。

## 6. 实现后必跑命令

构建：

```text
xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

关键 UI 回归：

```text
xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -parallel-testing-enabled NO -only-testing:VitoraUITests/CyclePivotUITests -only-testing:VitoraUITests/VisualLanguageSmokeTests -only-testing:VitoraUITests/AccessibilityUITests test
```

截图：

```text
xcrun simctl io <DEVICE_UDID> screenshot ios/QA/Screenshots/ImplementationV1/<new-cycle-screenshot>.png
```

## 7. 完成交付要求

每次 Cycle 页面改动完成后，必须在 `change-log.md` 追加：

- 日期。
- 目的。
- 具体改动。
- 截图路径。
- 构建结果。
- UI 测试结果。
- 未解决问题。

没有更新 `change-log.md` 的 Cycle 页面改动视为 handoff 不完整。
