# Dynamic Aura Background Visual Evidence

## 目标视频

```text
/Users/youxiang/Desktop/奇妙种子/b92f64c2021729138e25e3d9d0c2360d.mp4
```

视频信息：

- 时长：7:49.83
- 尺寸：832x544
- 帧率：30fps
- 编码：HEVC
- 音频：AAC mono

## 关键帧观察

| Frame | 观察 |
| --- | --- |
| `/private/tmp/vitora-bg-video-analysis/frame-05.jpg` | 设计工具中展示粉紫柔焦流体色场，核心是旋涡和大面积雾化过渡。 |
| `/private/tmp/vitora-bg-video-analysis/frame-06.jpg` | 同一流体结构生成多个颜色变体，说明应按周期做独立色版。 |
| `/private/tmp/vitora-bg-video-analysis/frame-10.jpg` | 蓝、青、绿、暖色变体并列，色相差异明显但整体柔和。 |
| `/private/tmp/vitora-bg-video-analysis/frame-16.jpg` | 变体被放进手机 UI 背景，前景卡片依赖浅色 wash 保持可读。 |

## 当前 App 对比

| Current Screenshot | 问题 |
| --- | --- |
| `ios/QA/Screenshots/ImplementationV1/07-today-target-aligned.png` | 背景主要是静态蓝色光斑，缺少流体 S 型扭转。 |
| `ios/QA/Screenshots/ImplementationV1/17-cycle-target-aligned.png` | Cycle 有暖色感，但背景仍更像 radial glow，不像视频色场。 |
| `ios/QA/Screenshots/ImplementationV1/18-vitora-target-aligned.png` | Vitora 空间感强，但蓝色浓度与 Today/Cycle 不统一。 |

## 当前实现证据

新素材目录：

```text
ios/Vitora/Resources/DynamicAura/
```

当前 poster contact sheet：

```text
/private/tmp/vitora-dynamic-aura-posters.png
```
