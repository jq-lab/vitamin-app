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
   - 身体要素。
   - Vitora 今日建议。
3. 确认没有独立 `+记录` section。
4. 点击状态卡进入状态详情。
5. 点击 `告诉` 或状态 chip，确认打开 3/4 Vitora sheet 且不切 tab。
6. 顶部下拉，确认 Energy Ball 半展开 / 全屏 / 收起。
7. 点击顶部日历，确认进入周期日历并可返回 Today。

### Vitora 检查

1. 点击中央 Vitora face tab。
2. 确认不是空聊天页，也不是功能 dashboard。
3. 首屏必须有：
   - Pixel Vitora hero。
   - `Vitora 知道` 上下文。
   - 直接问薄玻璃条。
   - 快捷上下文 icon chips。
   - Input dock。
4. 输入一句话，确认 Vitora 生成理解确认卡。
5. 触发语音入口，确认录音态和转写/理解路径可见。
6. 滚动页面，确认 Pixel Vitora 压缩但仍可见。

### Cycle 检查

1. 进入 Cycle。
2. 确认首页只有：
   - 当前周期阶段与今天。
   - 能量动态。
   - 右上头像/设置入口。
3. 确认 Cycle 首页没有日历预览。
4. 点击阶段卡进入透明解释型二层。
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
