# Vitora Tab Implementation Contract

## 允许改动入口

优先改以下 SwiftUI 文件：

```text
ios/Vitora/Features/VitoraFeature/VitoraAssistantSurfaceView.swift
ios/Vitora/Features/VitoraFeature/VitoraCompressedHeader.swift
ios/Vitora/Features/VitoraFeature/QuickContextChips.swift
ios/Vitora/Core/DesignSystem/VitoraInputDock.swift
```

允许新增轻量页面内组件，例如统一 topic 上下文摘要卡，但必须服务 Vitora Tab 当前 surface。

## 不允许改动

- 不改三 Tab 结构和路由。
- 不改 AI/数据模型主逻辑。
- 不把周期上下文展开态迁移成 Cycle 首页。
- 不重画 Pixel Vitora IP，不给每个页面单独发明一个 IP。
- 不新增图片资产来替代 `PixelVitoraView` / `PixelVitoraScene`。

## Pixel Vitora 接入规则

页面只能向统一 IP 组件传入：

- 状态：`idle`、`listening`、`thinking`、`confirming`。
- 尺寸。
- 是否显示 glow、sparkles、base shadow。
- 道具状态，如果组件已经支持。

任何造型、材质、眼睛、道具或动效 baseline 的修改，都必须同步更新 `../pixel-vitora-ip/change-log.md`。

## 每次实现后必须做

1. 运行 build。
2. 跑 Vitora assistant surface、visual language、accessibility 关键 UI 测试。
3. 用 iPhone 17 Pro Simulator 截图。
4. 更新 `change-log.md`，记录目的、改动、截图、测试结果和未解决问题。
