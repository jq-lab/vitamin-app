# Pixel Vitora QA Checklist

> 每次 Pixel Vitora 相关改动后必须执行本清单。

## 1. 人工视觉验收

| 项 | Pass 标准 |
| --- | --- |
| 主体 | 第一眼是柔体彩色 blob，不是普通图标、能量球或旧蓝色玻璃球。 |
| 轮廓 | 非完美圆形的有机软团轮廓可见。 |
| 外壳 | 半透明乳白外壳可见，不能完全实心。 |
| rim | 白色 / 银白柔和边可见，柔和但不消失。 |
| 主色 | 粉橙暖光为主体；青蓝 / 淡紫只在边缘和深处出现。 |
| 高光 | 左上柔光高光可见。 |
| 透光 | 右下有冷色透光或空气感。 |
| 眼睛 | 像素柱眼清楚，不是圆点、线条、emoji 或 SF Symbol。 |
| 阴影 | 有轻悬浮感，底部软阴影不过重。 |
| 星点 | 少量像素星点，不密集、不抢内容。 |
| clipboard | 是辅助玻璃道具，不抢建议文字。 |
| Tab face | 中央 Vitora face 低凸起，不遮挡内容或 input dock。 |

## 2. 页面一致性验收

| 场景 | Pass 标准 |
| --- | --- |
| Today 顶部 | 小尺寸 idle IP，右上品牌信号清楚。 |
| 今日建议卡 | confirming + clipboard，IP 是建议来源，不是任务插图。 |
| Energy Reveal | thinking 状态可更亮，但不常驻压住 Today 首屏。 |
| 底部 Tab | selected / unselected 仍是同一个 Pixel Vitora baseline。 |
| Vitora Tab | hero / compressed IP 不重设角色形态。 |

## 3. 自动回归

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

## 4. 反向验收

出现以下任一项，直接不通过：

- smooth orb。
- 回退到旧蓝色玻璃球。
- 人类头像。
- 动物或宠物型 IP。
- emoji / 卡通脸。
- 普通 SF Symbol、heart icon、chat icon 替代 Vitora face。
- 强紫霓虹主体。
- 黑色大圆或重 3D 球。
- 硬塑料玩具、商业盲盒或过度拟人公仔质感。
- 任务、打卡、完成率、连续天数、等级、红点表达。
- 每个页面单独发明不同 IP。
- 道具抢主角。
- 动效抢阅读或无法通过 Reduce Motion 关闭。

## 5. 上下文恢复验收

新 agent 只读以下两个文件后，必须能说清楚当前 IP 方向：

```text
specs/004-vitora-swift-rebuild/pixel-vitora-ip/README.md
specs/004-vitora-swift-rebuild/pixel-vitora-ip/pixel-vitora-ip-spec.md
```

应能准确复述：

- 当前 baseline 截图。
- 角色是柔体彩色 blob + 像素眼。
- 眼睛必须是 pixel column eyes。
- 禁用旧蓝色玻璃球、smooth orb、人像、宠物、emoji、普通 icon。
- 工程入口是统一 `PixelVitoraView` / `PixelVitoraScene`。
- 每次改动必须更新 `change-log.md`。
