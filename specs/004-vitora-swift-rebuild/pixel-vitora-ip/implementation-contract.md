# Pixel Vitora Implementation Contract

> 面向：后续 SwiftUI 工程师 / coding agent  
> 目标：让所有 Pixel Vitora 改动都继承同一 IP baseline

## 1. 统一实现入口

后续只能通过统一 Pixel Vitora 组件扩展 IP：

```text
ios/Vitora/Core/DesignSystem/PixelVitoraView.swift
```

主要实现对象：

- `PixelVitoraView`
- `PixelVitoraScene`
- `PixelVitoraState`
- `PixelVitoraAccessory`
- `VitoraFaceTabButton`

不得在 Today、Vitora、Cycle、Support 等页面内单独重画另一个 Pixel Vitora。

## 2. 允许的页面参数

页面只允许传入以下变化：

- state：`idle`、`listening`、`thinking`、`confirming`。
- size：按场景调整。
- accessory：`none`、`clipboard`、`pencil`、`voice`。
- showsSparkles：是否显示少量星点。
- showsBaseShadow：是否显示底部阴影。

页面不得改变：

- 柔体彩色 blob 结构。
- 像素眼结构。
- 粉橙暖光主体 + 青蓝/淡紫空气感的色彩方向。
- 角色身份。
- 禁用方向。

## 3. 必须共用 Baseline 的场景

| 场景 | 要求 |
| --- | --- |
| Today 顶部右上 IP | 使用 `PixelVitoraScene(state: .idle)`。 |
| Vitora 今日建议卡 | 使用 `PixelVitoraScene(state: .confirming, accessory: .clipboard)`。 |
| Energy Reveal | 使用 `PixelVitoraScene(state: .thinking)`。 |
| 底部 Vitora Tab | 使用 `VitoraFaceTabButton`，内部仍引用 `PixelVitoraScene`。 |
| Vitora Tab hero / compressed IP | 继承同一 IP baseline，只改变尺寸和状态强度。 |

## 4. 新增状态或道具流程

新增状态或道具前，必须先更新：

1. `pixel-vitora-ip-spec.md`
2. `implementation-contract.md`
3. `qa-checklist.md`
4. `change-log.md`

新增实现必须满足：

- 不新增第四个主 Tab。
- 不引入任务、打卡、等级或完成率心智。
- 不把 Health / AI 状态只靠 IP 动效表达。
- Reduce Motion 下有静态替代。

## 5. 实现后必跑命令

构建：

```text
xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

关键 UI 回归：

```text
xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:VitoraUITests/TodayPivotUITests -only-testing:VitoraUITests/VisualLanguageSmokeTests test
```

截图：

```text
xcrun simctl io <DEVICE_UDID> screenshot ios/QA/Screenshots/ImplementationV1/<new-ip-screenshot>.png
```

## 6. 完成交付要求

每次 IP 改动完成后，必须在 `change-log.md` 追加：

- 日期。
- 目的。
- 具体改动。
- 截图路径。
- 构建结果。
- UI 测试结果。
- 未解决问题。

没有更新 `change-log.md` 的 IP 改动视为 handoff 不完整。
