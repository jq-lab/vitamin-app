# Phase 16 · Support / Trust QA Report

日期：2026-05-06  
设备：iPhone 17 Simulator  
范围：`T146-T161`, `REQ-014`, `WF-S-001`, `IAC-S-001` 到 `IAC-S-004`

## 自动化结果

| 检查 | 结果 |
| --- | --- |
| Targeted Support tests | 通过，10 tests |
| Full `xcodebuild test` suite | 通过，95 tests |
| Build warnings | 无新增 Swift compiler warning |

## iosef 手动 QA

| 场景 | 结果 | 证据 |
| --- | --- | --- |
| 从 Today 切到 Cycle | 通过 | `ios/QA/Screenshots/Support/01-cycle.png` |
| Cycle 右上头像进入设置 | 通过 | `ios/QA/Screenshots/Support/02-settings-home.png` |
| 设置只显示六个 P0 支撑项 | 通过 | `02-settings-home.png` |
| HealthKit 与数据来源说明低数据仍可用 | 通过 | `03-data-sources.png` |
| 营养补给管理可新增上下文 | 通过 | `05-nutrition-after-add.png` |
| 数据导出需要确认并显示准备完成 | 通过 | `08-export-ready-confirmed.png` |
| 隐私法律与账号移除需要确认并显示完成 | 通过 | `10-account-removed.png` |
| Vitora `⋯` 可进入同一设置面板 | 通过 | `12-vitora-support-entry.png` |

## 发现与修复

- 初次 UI 测试失败是因为子面板根 view 的 accessibility identifier 覆盖了内部按钮 identifier，导致 XCUITest 找不到 `support.export.start` 和 `support.nutrition.add`。
- 已移除子面板根 identifier，只保留具体按钮和路由 identifier；重新跑 targeted tests 与 full suite 均通过。

## 结论

Phase 16 支撑 / 信任 / 数据控制已满足当前规格：设置入口来自 Cycle 右上与 Vitora `⋯`，支撑面板只暴露六个 P0 必需项，数据导出和账号移除都有确认与结果反馈，营养补给作为管理页存在且不引入商业化入口。
