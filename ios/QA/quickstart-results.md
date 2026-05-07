# Vitora Final Quickstart Results

> 日期：2026-05-07  
> 设备：iPhone 17 Simulator (`12FE11C1-501C-4505-8E31-714059815052`)  
> 工具：Xcode / XCTest / `iosef` / Simulator  
> 规格：`specs/004-vitora-swift-rebuild/quickstart.md`

## 执行摘要

最终 quickstart 路径已跑通。自动化覆盖主要由 XCUITest 完成；人工式 Simulator 操作由 `iosef` 完成，包括点击、输入、滑动和截图。

`iosef` 在 sandbox 内调用 HID/AX 查询时曾触发 CoreSimulatorService connection invalid；改用已授权的外部权限执行 `iosef wait/type/tap` 后恢复，截图和交互均可继续。该问题是 macOS Simulator 自动化权限/服务稳定性问题，不是 Vitora app 崩溃或业务阻塞。

## 实际命令与结果

| 步骤 | 命令 / 工具 | 结果 |
| --- | --- | --- |
| Simulator 状态 | `xcrun simctl list devices booted` | iPhone 17 booted。 |
| iosef 状态 | `~/.local/bin/iosef status --json` | 连接 iPhone 17 local session。 |
| Onboarding 截图 | `iosef view --output .../01-onboarding.png` | Pass。 |
| Onboarding 输入 | `iosef type --identifier onboarding.identity.name --text XiaoWei` | Pass；字段成功输入。 |
| Today rich state 启动 | `xcrun simctl launch ... -vitoraUITestCompletedOnboarding -vitoraUITestRichToday -vitoraUITestReviewAvailable` | Pass。 |
| Today 截图 | `iosef view --output .../02-today-home.png` | Pass。 |
| Energy Reveal | `iosef swipe --x-start 196 --y-start 150 --x-end 196 --y-end 470` | Pass；`03-energy-reveal.png`。 |
| Vitora Tab | `iosef tap --identifier tab.vitora` | Pass；`04-vitora-tab.png`。 |
| Contextual Sheet | `iosef tap --identifier today.state.askVitora` | Pass；`05-contextual-vitora-sheet.png`。 |
| Cycle | `iosef tap --identifier tab.cycle` | Pass；`06-cycle-home.png`。 |
| Support | `iosef tap --identifier cycle.settings.open` | Pass；`07-support-settings.png`。 |
| Evening Review | `iosef tap --identifier vitora.review.open` | Pass；`08-evening-review.png`。 |

## 截图清单

| 场景 | 路径 |
| --- | --- |
| Onboarding | `ios/QA/Screenshots/Final/01-onboarding.png` |
| Today | `ios/QA/Screenshots/Final/02-today-home.png` |
| Energy Reveal | `ios/QA/Screenshots/Final/03-energy-reveal.png` |
| Vitora Tab | `ios/QA/Screenshots/Final/04-vitora-tab.png` |
| Contextual Vitora Sheet | `ios/QA/Screenshots/Final/05-contextual-vitora-sheet.png` |
| Cycle | `ios/QA/Screenshots/Final/06-cycle-home.png` |
| Support | `ios/QA/Screenshots/Final/07-support-settings.png` |
| Evening Review | `ios/QA/Screenshots/Final/08-evening-review.png` |

## 结论

- quickstart P0 主路径可继续作为后续开发 smoke path。
- `/speckit.implement` 后续轮次仍应保留 `xcodebuild test + iosef screenshot/interactions` 的组合。
- `iosef` 若再次遇到 CoreSimulatorService invalid，优先使用外部权限重试交互命令；不要把该问题误判为 app 功能失败。
