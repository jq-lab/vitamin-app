# Vitora Swift Rebuild · Quickstart

> 规格集：`004-vitora-swift-rebuild`
> 日期：2026-05-05
> 状态：P0 Swift MVP Final QA Passed
> 目的：给后续回归、视觉微调和下一轮功能开发一个可执行入口。

当前项目已经完成 `T001-T177`，包含 IA / Design Pivot、Today、Vitora、Cycle、Evening Review、Support、Trust hardening 和 Final QA。后续如果继续开发新功能，应先更新 specs / tasks，再运行 `/speckit.analyze`，不要直接追加实现。

## 0. Prerequisites

| 项目 | 要求 |
| --- | --- |
| Xcode | 本机 Xcode 可构建 `ios/Vitora.xcodeproj`。 |
| Simulator | 使用本机可用 iPhone simulator；优先 iPhone 17。 |
| Repo | 当前分支 `004-vitora-swift-rebuild`。 |
| Specs | 使用 `specs/004-vitora-swift-rebuild/`。 |
| Next task | 当前无未完成 P0 task。新功能必须先补 specs/tasks。 |
| QA | 最近完整 suite：109 passed，见 `ios/QA/Reports/xcodebuild-test.txt`。 |

## 1. SpecKit Command Order

当前不要运行：

```text
/speckit.tasks
/speckit.specify
/speckit.ia
/speckit.wireframes
/speckit.components
```

原因：`tasks.md` 已经保留 T001-T101 完成历史，并把 T102-T138 拆成多个 pivot checkpoint。盲目重跑 tasks 可能覆盖进度。

推荐顺序：

```text
/speckit.analyze
```

修复 analyze findings 后，如果存在新的 tasks：

```text
/speckit.implement
```

## 2. Build / Test Commands

```bash
xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17' build
```

```bash
xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17' test
```

如果 simulator 名称不同，可以替换 destination，但 QA 报告必须记录实际设备。

## 3. Pivot Manual QA Path

### Today 检查

1. 打开 app，进入 Today。
2. 确认首屏结构是：
   - 顶部日历 / 周期上下文。
   - 现在状态。
   - 碗下三阶段周期圆弧。
   - Vitora 今日建议。
3. 确认没有独立 `+记录` section。
4. 点击状态卡进入状态详情。
5. 长按状态卡或点击底部圆形 `+`，确认打开 3/4 Vitora sheet 且不切 tab。
6. 确认状态卡内显示单层高对比综合能量数字、`今日能量偏低` 位于 `68%` 下方，`查看数据` 位于状态词右侧同一行；碗体接近宽口半碗，图形与文字不重叠。
7. 确认碗下周期圆弧只显示三个阶段；当前 D18 时为 `排卵期 / 黄体期 D18 / 月经期`，圆弧中间下沉并下移到碗外下方，和碗底保持约一个中文字高度，所有阶段文字在圆弧下端，不出现顶部阶段气泡、横向波浪线或上凸弧。
8. 确认首页不显示 `综合能量68% / 低谷14:00 / 负担偏轻` 小标签，不显示综合/睡眠/周期切换、首页实时预测图或 `告诉 Vitora / 睡得浅 / 压力大` chips。
9. 确认 Today 首页不出现 `花园手册`、`查看成长卡`、`昨晚的薄荷芽发芽了`、`今晚可种` 或种子选择入口。
10. 确认 Vitora 今日建议标题后显示大字号身体翻译和依据；建议组合默认为 `吃 + 休息`，两条建议右侧为勾选 icon；点击 `换一换` icon 可循环到 `运动 + 吃`、`休息 + 运动`；首屏不出现 `为什么` 按钮。
11. 点击 `查看数据`，确认进入今日分析，先看到 `综合能量68% / 低谷14:00 / 负担偏轻` 小标签和综合实时预测，再横向看到睡眠、HRV、心率、周期四个身体要素卡。
12. 点击顶部日历，确认进入周期日历并可返回 Today。

### Vitora 检查

1. 确认 Today / Cycle 底部只显示居中 Tab 组和右侧圆形 `+`，不显示输入条。
2. 点击底部 Tab 组里的 `AI管家`。
3. 确认不是空聊天页，也不是功能 dashboard。
4. 首屏必须有，且进入时不能自动大展开：
   - Pixel Vitora hero。
   - `Vitora 知道` 上下文。
   - 快捷上下文 icon chips。
   - 居中 Tab 组、右侧圆形 `+` 和只在 AI 管家展开的 Input dock。
5. 上拉页面，确认不切回 Today，`Vitora 知道` hero 卡隐藏，完整展示日期行、topic rail、说明、消息、低数据/能力反馈和输入 dock。
6. 点击 `周期 / 睡眠 / 营养`，确认三者都使用同一套上下文摘要卡结构，且不再出现周期专属报表。
7. 确认输入条内没有 `+`，只有语音/键盘、文字或语音条、发送。
8. 输入一句话，确认 Vitora 生成理解确认卡。
9. 回到 Today，点击右侧圆形 `+`，确认打开来源为 `快捷记录` 的 3/4 Vitora sheet 且不切换到 AI 管家；sheet 展示时背景全局 Dock 不透出，底部使用 sheet 自己的输入条。
10. 触发语音入口，确认录音态和转写/理解路径可见。

### Cycle 检查

1. 进入 Cycle。
2. 确认首页展示：
   - `周期回顾` 标题和 `复盘成长 · 洞察规律`。
   - 左上头像我的入口。
   - 右上周期卡片分享入口。
   - `这 30 天，Vitora 看见的三件事` 总结卡。
   - 能量动态。
   - 规律模式 / 有效助力 / 下周期调整三张洞察卡。
3. 确认 Cycle 首页没有日历预览、`30 天成长册`、花园手册、种子选择或任务完成心智。
4. 点击三件事总结卡的 `本周 / 趋势（月） / 周期`，确认下方内容同步切换。
5. 点击能量动态卡进入趋势探索二层。
6. 点曲线数据点，确认出现 callout。
7. 长按卡片，确认出现 context menu，可问 Vitora。

### 支撑 / 信任检查

1. 从 Cycle 右上头像进入设置。
2. 确认只显示 P0 支撑项：
   - 个人资料
   - HealthKit 与数据来源
   - 营养补给
   - 提醒偏好
   - 数据导出
   - 隐私法律与账号移除
3. 确认没有 VIP、主题、小组件、帮助墙、养成进度。

## 4. Required Screenshots

| Screenshot | Compare Against |
| --- | --- |
| Today home | `WF-T-001`, `design-language-demo.md`, `assets/design_04/today_tab.png` |
| Energy reveal half/full | `WF-T-002` |
| Today calendar | `WF-T-003` |
| Today state detail | `WF-T-004` |
| Body factors detail | `WF-T-005` |
| Suggestion detail | `WF-T-006` |
| Vitora default | `WF-V-001`, `design-language-demo.md`, `assets/design_04/vitora_tab.png` |
| Vitora compressed | `WF-V-002` |
| Vitora voice | `WF-V-003` |
| Rich response | `WF-V-004` |
| Contextual sheet | `WF-V-005` |
| Cycle home | `WF-C-001`, `design-language-demo.md`, `assets/design_04/cycle_d.png` |
| Cycle phase detail | `WF-C-002` |
| Cycle energy detail | `WF-C-003` |
| Support settings | `WF-S-001` |
| Evening review | `WF-R-001` |

## 5. Reverse Acceptance Scan

阶段结束时必须确认：

- UI 文案不出现用户面对 `Luna`。
- Today 没有独立记录 section。
- Cycle 首页没有日历。
- Vitora Tab 不是空聊天页。
- Pixel Vitora 没有被 smooth orb / 人类头像 / 宠物替代。
- 首层视觉不是 Apple Health dashboard-like flat white。
- AI 理解未经确认不会保存。

## 6. Privacy QA

| Check | Expected |
| --- | --- |
| HealthKit skipped | App remains usable. |
| Logs | No health values, record text, AI prompt or full AI reply. |
| Export | Includes all P0 saved user data. |
| Account removal | Clears local data and returns to AppGate. |
| AI unavailable | User input is preserved and can be saved manually. |

## 7. Completion Rule

本 quickstart 通过后，QA 结果应记录在：

- `ios/QA/quickstart-results.md`
- `ios/QA/manual-qa.md`
- `ios/QA/final-qa-report.md`
