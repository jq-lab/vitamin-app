# Dynamic Aura Background Implementation Contract

## 工程入口

背景组件入口：

```text
ios/Vitora/Core/DesignSystem/Surfaces.swift · PremiumAuraBackground
ios/Vitora/Core/DesignSystem/DynamicAuraBackground.swift
```

页面只能传入 `PremiumAuraScene` 或 `DynamicAuraVariant`、`intensity` 和必要的语音态信号，不能在 Today / Vitora / Cycle 内单独写新视频播放器或新渐变算法。`WaterAuraReferenceBackground` 只作为兼容 wrapper，内部必须走 `PremiumAuraBackground`。

## 状态来源

- `AppEnvironment.selectedCycleDay`
- `AppEnvironment.selectedAuraVariant`
- `AppEnvironment.selectCycleDay(_:)`

Today 日历选择日期后更新全局周期 day；Today / Vitora / Cycle 读取同一 variant，保持空间语言统一。

## 资源规则

资源放在：

```text
ios/Vitora/Resources/DynamicAura/
```

每个 variant 必须同时有：

- `dynamic-aura-{variant}.mp4`
- `dynamic-aura-{variant}-poster.png`

如果视频不存在，组件必须降级到 poster；如果 poster 也不存在，才降级到旧 `AuraBackground`。

## 接入边界

- 允许替换 Today / Vitora / Cycle 首层底色、Onboarding、Support 和所有 Sheet 背景。
- 不改三主 Tab。
- 不改 Pixel Vitora。
- 不改 AI/健康数据模型。
- 不把 Cycle 改成日历页。
- 不把 Today 加任务/打卡/完成率。

每次背景视觉改动后必须更新 `change-log.md` 并重新截图。
