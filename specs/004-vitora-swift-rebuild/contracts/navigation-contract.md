# Vitora Swift Rebuild · Navigation Contract

> Contract: navigation
> 状态：IA / Design Pivot Adapted

## 0. 使用规则

| Rule ID | Rule |
| --- | --- |
| NC-001 | 主导航只能是 Today / Vitora / Cycle。 |
| NC-002 | 从 Today / Cycle 唤醒 Vitora 默认打开 3/4 contextual sheet，不直接切 Tab。 |
| NC-003 | Contextual sheet、Energy Reveal、二层详情和 support panel 必须有关闭或返回来源路径。 |
| NC-004 | Deferred routes 不可见，不以 disabled row 或 placeholder 出现。 |
| NC-005 | Today 不放常驻抽屉入口；Cycle 右上头像和 Vitora `⋯` 可进入支撑页。 |
| NC-006 | Cycle 首页不包含日历；周期日历从 Today 顶部入口进入。 |

## 1. Route Table

| Route ID | IA | Presentation | Entry | Exit |
| --- | --- | --- | --- | --- |
| NR-001 | IA-000 | App gate state | App launch | Onboarding or Today |
| NR-002 | IA-001 to IA-003 | Onboarding stack | New user | Today |
| NR-003 | IA-010 | Main tab screen | App gate / tab | Other tab or contextual state |
| NR-004 | IA-011 | Pull-to-reveal / full-screen state | First daily open or top pull | Today |
| NR-005 | IA-012 | Sheet / navigation state | Today calendar icon | Today |
| NR-006 | IA-013 | Sheet | Today state card | Today |
| NR-007 | IA-014 | Sheet | Body factors | Today |
| NR-008 | IA-015 | Sheet | Vitora suggestion card | Today |
| NR-009 | IA-020 | Main tab screen | Vitora face tab | Other tab or contextual state |
| NR-010 | IA-021 | 3/4 contextual sheet | Askable surface / chip / context menu | Source screen |
| NR-011 | IA-022 | Full context mode | Sheet swipe up or Vitora tab | Vitora surface or source screen |
| NR-012 | IA-023 | Confirmation sheet/card | User input or voice transcript | Source screen / Vitora |
| NR-013 | IA-024 | Sheet / card | Review available | Today or Vitora |
| NR-014 | IA-030 | Main tab screen | Cycle tab | Other tab or detail |
| NR-015 | IA-031 | Sheet / navigation state | Current phase relation card | Cycle |
| NR-016 | IA-032 | Sheet / navigation state | Energy dynamics card | Cycle |
| NR-017 | IA-033 | Inline state | Cycle low data | Cycle |
| NR-018 | IA-040 to IA-046 | Settings panel / child panel | Cycle avatar or Vitora `⋯` | Source screen |

## 2. State Routing

| State | Required Route Behavior |
| --- | --- |
| No onboarding completion | Only onboarding route is primary. |
| Onboarding complete | Default route is Today. |
| HealthKit skipped / denied | Route to Today low-data state; data sources remain reachable. |
| First open today | Energy Ball may appear; user can skip/close and return to Today. |
| User taps Today calendar | Open Today-owned cycle calendar, not Cycle tab. |
| User taps askable card | Open detail sheet. |
| User long-presses askable card | Open context menu; selecting Vitora action opens contextual sheet. |
| Vitora sheet swiped up | Upgrade to full Vitora context mode with same source. |
| Suggestion accepted | Review state and reminder preference become reachable. |
| Review available | Today/Vitora can surface review; no new main tab. |
| Account removal complete | App returns to gate / new start state. |

## 3. Navigation QA

| QA ID | Check |
| --- | --- |
| NC-QA-001 | XCUITest verifies only Today / Vitora / Cycle main tabs. |
| NC-QA-002 | Today calendar opens from Today top icon and Cycle home has no calendar preview. |
| NC-QA-003 | Contextual Vitora sheet closes back to source and can upgrade full-screen. |
| NC-QA-004 | Energy Reveal, Today details, Cycle details and support panels all have exit paths. |
| NC-QA-005 | Deferred routes are absent from accessible UI. |
