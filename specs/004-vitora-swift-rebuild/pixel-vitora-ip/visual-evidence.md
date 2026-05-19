# Pixel Vitora Visual Evidence

> 目的：记录目标参考、当前实现和 baseline 选择，防止上下文丢失后重新解释 IP 方向。

## 1. 证据等级

| 等级 | 含义 |
| --- | --- |
| Direction Reference | 用户提供或设计目标图，用于判断质感方向。 |
| Implementation Baseline | 当前 App 内已实现、可构建、可复用、可回归的 baseline。 |
| Iteration Evidence | 中间迭代截图，用于理解为何选择当前 baseline。 |

## 2. Direction Reference

历史用户目标图定义了第一阶段玻璃球方向：

- Header IP：玻璃球、厚白 rim、蓝青主体、竖向像素眼、柔白星点、底部悬浮阴影。
- Suggestion IP：玻璃球、左竖眼 + 右短像素表情、clipboard 小道具、柔和发光。

2026-05-14 用户更新 IP 方向：把 IP 形象换成柔软、半透明、粉橙暖光主体的彩色 blob，并保留像素眼。该方向覆盖旧蓝色玻璃球 baseline。

这些图是质感和 IP 气质参考，不是逐像素复刻要求。App 内最终仍以 SwiftUI 原生可复用 baseline 为准。

## 3. Implementation Baseline

当前锁定 baseline：

```text
/Users/youxiang/Desktop/Vitora-WaterAura-三页截图/20-vitora-new-blob-ip.png
```

选择原因：

- 已在 iPhone 17 Pro Simulator 渲染。
- Vitora Tab 顶部氛围、小 face、底部 Vitora Tab 同时可见。
- 已包含柔体彩色 blob、半透明外壳、像素柱眼和低凸起 tab face。
- 已通过构建。

## 4. Iteration Evidence

| 截图 | 用途 |
| --- | --- |
| `ios/QA/Screenshots/ImplementationV1/13-ip-glass-final.png` | 第一轮玻璃材质与 clipboard 改造后截图，整体偏淡。 |
| `ios/QA/Screenshots/ImplementationV1/14-ip-glass-final-tuned.png` | 第二轮提高蓝青主体、收紧像素眼后的截图。 |
| `ios/QA/Screenshots/ImplementationV1/15-ip-glass-simulator-visible.png` | 旧玻璃球 baseline，已被 2026-05-14 新 IP 方向覆盖。 |
| `/Users/youxiang/Desktop/Vitora-WaterAura-三页截图/20-vitora-new-blob-ip.png` | 当前柔体彩色 blob baseline，已在模拟器中渲染。 |

## 5. 证据使用规则

- 新设计可以参考目标图，但不得推翻当前 baseline 的角色方向。
- 新实现必须对比 `/Users/youxiang/Desktop/Vitora-WaterAura-三页截图/20-vitora-new-blob-ip.png`。
- 如果新截图第一眼不再像同一个 Pixel Vitora，视为跑偏。
- 如果新截图只在某个页面好看，但破坏 Today / Vitora / Tab 一致性，视为不通过。
