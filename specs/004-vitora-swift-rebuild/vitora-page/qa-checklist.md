# Vitora Tab QA Checklist

## 人工验收

- iPhone 17 Pro 首屏可见：top controls、背景大 IP、双栏玻璃上下文卡、date strip、Vitora message、topic rail、input dock、Bottom Tab；进入时不默认大展开。
- Pixel Vitora 形象与 `pixel-vitora-ip/` baseline 一致，没有被重画或替换。
- 选择 `周期 / 睡眠 / 营养` chip 后显示统一上下文摘要卡，页面仍然是 Vitora Tab，不像 Cycle 首页。
- 上拉后进入聊天聚焦态，隐藏 hero 卡并展示完整聊天内容，不切回 Today。
- Input Dock 不被中央 Vitora face 或 Bottom Tab 遮挡。
- Today / Cycle 底部不显示 Input Dock，只保留居中 Tab 和右侧圆形 `+` 记录。
- Quick Context chips 是 tool belt，不是主导航。
- 文案不出现任务、打卡、完成率、红点、连续天数、VIP 或商业卡。
- 合规短句可见：`本内容仅供生活方式参考，不构成医疗建议`。

## 自动验收

```text
xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -parallel-testing-enabled NO -only-testing:VitoraUITests/VitoraAssistantSurfaceUITests -only-testing:VitoraUITests/VisualLanguageSmokeTests -only-testing:VitoraUITests/AccessibilityUITests test
```

如修改了输入、AI 不可用或语音路径，也要补跑：

```text
-only-testing:VitoraUITests/AIUnavailableUITests
-only-testing:VitoraUITests/LunaRecordUITests
```

## 截图验收

截图路径：

```text
ios/QA/Screenshots/ImplementationV1/18-vitora-target-aligned.png
```

截图启动参数建议：

```text
-vitoraUITestCompletedOnboarding
-vitoraUITestRichToday
-vitoraUITestReviewAvailable
-vitoraUITestInitialTabVitora
-vitoraUITestInitialContextCycle
```

## 反向验收

出现以下任一项直接不通过：

- smooth orb、人像、宠物、emoji、普通 SF Symbol 替代 Vitora face。
- Vitora Tab 变成 dashboard、功能宫格、空聊天页或营销页。
- topic 上下文摘要卡变成 Cycle 首页。
- 新增第四个 Tab。
- 任务、打卡、完成率、红点、连续天数、商业卡、VIP 卡。
- 强紫霓虹、黑重阴影、医疗警报红色。
- Bottom Tab 或中央 Vitora face 遮挡 input dock。
