# Dynamic Aura Background QA Checklist

## 自动验收

```text
xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

建议 UI 回归：

```text
xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -parallel-testing-enabled NO -only-testing:VitoraUITests/TodayPivotUITests -only-testing:VitoraUITests/VisualLanguageSmokeTests -only-testing:VitoraUITests/AccessibilityUITests test
```

## 人工验收

- Today 背景能看到柔焦流体色场，不只是圆形光斑。
- Today / Vitora / Cycle / Sheet / Onboarding / Support 都能看到统一浅霜分层背景，且 accessibility identifier 为 `premium.aura.background.*`。
- 打开 Today 日历，点击不同日期后返回，背景颜色切换。
- Today / Vitora / Cycle 读取同一周期背景状态。
- Pixel Vitora 形象不变，背景不产生新角色感。
- 前景文字、图表、按钮、输入 dock 保持可读。
- Reduce Motion 开启后显示 poster frame，不播放视频。
- Reduce Transparency 开启后背景存在感降低。

## 反向验收

出现以下情况直接不通过：

- 教程录屏、Figma/浏览器 UI、鼠标、文字进入 App 背景。
- 强紫、荧光绿、橙红大面积铺底。
- 背景像新的能量球或新 IP。
- 每个页面各自实现不同背景逻辑。
- 背景导致玻璃卡文字读不清。
- 子页面出现大面积蓝色渐变底、彩色雾面整卡或参考图原素材。
