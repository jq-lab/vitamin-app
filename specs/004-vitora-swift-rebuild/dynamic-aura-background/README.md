# Dynamic Aura Background Spec Pack

> 当前目标视频：`/Users/youxiang/Desktop/奇妙种子/b92f64c2021729138e25e3d9d0c2360d.mp4`
> 当前实现入口：`ios/Vitora/Core/DesignSystem/DynamicAuraBackground.swift`
> 当前素材目录：`ios/Vitora/Resources/DynamicAura/`

## 先读顺序

1. `dynamic-aura-background-spec.md`
2. `implementation-contract.md`
3. `visual-evidence.md`
4. `qa-checklist.md`
5. `change-log.md`

涉及 Pixel Vitora 形象时，还必须读取：

```text
specs/004-vitora-swift-rebuild/pixel-vitora-ip/README.md
specs/004-vitora-swift-rebuild/pixel-vitora-ip/pixel-vitora-ip-spec.md
```

## 当前 Baseline

背景方向是柔焦流体色场，不是静态 radial glow。当前实现使用 5 个干净循环视频素材：

- `dynamic-aura-default.mp4`
- `dynamic-aura-menstrual.mp4`
- `dynamic-aura-follicular.mp4`
- `dynamic-aura-ovulation.mp4`
- `dynamic-aura-luteal.mp4`

每个视频都有同名 `-poster.png`，用于 Reduce Motion、Reduce Transparency 或视频加载失败。

## 硬规则

后续背景只能扩展当前“轻流体、清透、周期感”的方向，不能直接使用教程录屏，不能出现 Figma/浏览器/鼠标/文字残留，不能形成新的 IP 或抢 Pixel Vitora 的主视觉。
