# Vitora Swift Rebuild · QA Contract

> Contract: qa
> 状态：IA / Design Pivot Adapted

## 0. QA Rules

| Rule ID | Rule |
| --- | --- |
| QAC-001 | 每个 P0 phase 必须有可独立验证的 XCTest 或 XCUITest。 |
| QAC-002 | UI tests 必须覆盖 `UF-000` 到 `UF-010` 的主路径。 |
| QAC-003 | 所有交互验收必须引用 `IAC-*`。 |
| QAC-004 | 隐私测试必须验证日志、AI context、导出和账号移除边界。 |
| QAC-005 | 每个 UI phase 必须使用 Simulator / iosef 交互复查并保存截图。 |
| QAC-006 | 视觉实现必须对照 `design-language-demo.md`、`design-tokens.md` 和 `wireframes.md`。 |

## 1. Required Test Suites

| Suite ID | Suite | Covers |
| --- | --- | --- |
| QAS-001 | `VitoraDomainTests` | `DM-*`, `DE-*`, domain services。 |
| QAS-002 | `VitoraPersistenceTests` | persistence, export, account removal, encrypted storage. |
| QAS-003 | `VitoraAITests` | context minimization, output guard, AI fallback. |
| QAS-004 | `VitoraHealthKitTests` | authorization states and low-data behavior. |
| QAS-005 | `VitoraNotificationTests` | suggestion and review reminders. |
| QAS-006 | `VitoraUITests` | onboarding, Today, Vitora, Cycle, support, review. |
| QAS-007 | `VitoraAccessibilityTests` | VoiceOver labels, Dynamic Type, touch target, reduce motion/transparency. |

## 2. Minimum UI Journeys

| Journey ID | Must Verify | Linked IAC |
| --- | --- | --- |
| QAJ-001 | New user completes onboarding without WeChat or HealthKit. | IAC-QA-001 |
| QAJ-002 | Returning user opens Today and sees state/body/suggestion. | IAC-QA-002 |
| QAJ-003 | Energy Bowl opens state detail, evidence button opens body factors, realtime prediction shows current bubble. | IAC-QA-003 |
| QAJ-004 | Today state card opens detail. | IAC-QA-004 |
| QAJ-005 | Askable surface long-press opens context menu and Vitora sheet. | IAC-QA-005 |
| QAJ-006 | Today calibration chip opens contextual Vitora and saves confirmed update. | IAC-QA-006 |
| QAJ-007 | Vitora Tab shows Pixel Vitora surface, context, direct questions, chips and input dock. | IAC-QA-007 |
| QAJ-008 | Vitora input produces rich response confirmation. | IAC-QA-008 |
| QAJ-009 | Vitora voice entry shows recording/transcription path. | IAC-QA-009 |
| QAJ-010 | Cycle home shows phase relation and energy dynamics, not calendar home. | IAC-QA-010 |
| QAJ-011 | Cycle energy detail supports point callout and Vitora question. | IAC-QA-011 |
| QAJ-012 | Today top calendar opens cycle calendar and returns to Today. | IAC-QA-012 |
| QAJ-013 | Evening review compares morning state and evening feedback. | IAC-QA-013 |
| QAJ-014 | Support/settings only contains P0 support items. | IAC-QA-014 |
| QAJ-015 | Accessibility path passes on main screens and sheets. | IAC-QA-015 |

## 3. Release Gate

| Gate ID | Required Before P0 Complete |
| --- | --- |
| QAG-001 | `xcodebuild test` passes for unit and UI suites. |
| QAG-002 | `quickstart.md` manual path passes on current simulator. |
| QAG-003 | Restricted expression scan passes on app strings and touched specs. |
| QAG-004 | Screenshots for Today, Vitora, contextual sheet, Cycle, support and review match `WF-*` intent. |
| QAG-005 | No deferred IA route appears in UI test accessibility tree. |
| QAG-006 | Reverse acceptance `IAC-N-001` 到 `IAC-N-010` all pass. |
