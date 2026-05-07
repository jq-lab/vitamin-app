# Vitora Swift Rebuild · AI Context Contract

> Contract: ai-context
> 状态：IA / Design Pivot Adapted

## 0. Rules

| Rule ID | Rule |
| --- | --- |
| AIC-001 | AI 输入只能来自 `AIContextPackage`。 |
| AIC-002 | `AIContextPackage` 必须由 `AIContextBuilder` 生成。 |
| AIC-003 | 直接身份字段、完整历史、无关原文不得进入 AI。 |
| AIC-004 | AI 输出必须经过 output guard 才能展示或保存；旧 `LunaOutputGuard` 可作为内部迁移实现名。 |
| AIC-005 | AI 不可用时，记录仍可保存，Today / Vitora / Cycle 仍可用。 |
| AIC-006 | P0 不暴露本地模型或 agent 控制 UI。 |
| AIC-007 | 用户面对输出称为 Vitora 的理解、建议或回复，不称为 Luna。 |

## 1. AI Jobs

| Job ID | Job | Inputs | Output | Must Reference |
| --- | --- | --- | --- | --- |
| AIJ-001 | Today explanation | TodayState summary, CycleContext summary, low-data state | User-facing explanation draft | REQ-004, REQ-006 |
| AIJ-002 | Suggestion generation | EnergySummary, body factors, cycle context, constraints | VitoraSuggestion draft | REQ-007 |
| AIJ-003 | Vitora contextual understanding | Source context, user draft, quick chip, user confirmation context | ParsedUnderstanding draft | REQ-008, REQ-011 |
| AIJ-004 | Vitora assistant response | Recent minimized conversation, current source context, current intent | VitoraResponseDraft | REQ-010 |
| AIJ-005 | Evening review summary | DailyIntention, morning state, user feedback, selected records | Review summary draft | REQ-005, REQ-007 |
| AIJ-006 | Cycle trend narrative | Cycle phase, energy dynamics summary, selected data point | VitoraNarrative draft | REQ-012 |

## 2. Context Package Shape

| Section | Allowed | Not Allowed |
| --- | --- | --- |
| user_context | Preference label, broad focus areas. | Real name, account ID, contact, exact address. |
| today_context | Status summary, body factor trends, low-data flag. | Raw HealthKit series, detailed logs. |
| cycle_context | Phase relation summary, confidence, date window. | Over-wide history unrelated to current task. |
| source_context | Askable object ID, visible summary, selected chart point. | Full screen dump or hidden private state. |
| record_context | User-confirmed summary. | Unconfirmed raw long input after confirmation is complete. |
| intention_context | Current suggestion/intention and reminder category. | Task completion pressure or streak data. |
| review_context | Same-day before/after feedback summary. | Long private history not needed for current job. |

## 3. Output Guard

| Guard ID | Check |
| --- | --- |
| AOG-001 | Output must use Vitora tone from `compliance.md` companion copy rules. |
| AOG-002 | Output must not claim unavailable data. |
| AOG-003 | Output must not use restricted expression types from `CX-*`. |
| AOG-004 | Output must include required compliance label context when long or health-related. |
| AOG-005 | Output failure must map to `CL-AI-UNAVAILABLE` or low-data recovery. |
| AOG-006 | Parsed understanding must show impact scope and require user confirmation before save. |

## 4. Future Local Model Boundary

| Future ID | Rule |
| --- | --- |
| AIF-001 | Local model can replace current AI client only after facts and decision log update. |
| AIF-002 | Local model cannot bypass `AIContextBuilder` or output guard. |
| AIF-003 | Agent tool execution is not a P0 service and must not appear in P0 routes. |
| AIF-004 | Future local model storage must use the same privacy and export/delete rules for retained summaries. |

## 5. Tests

| Test ID | Test |
| --- | --- |
| AIT-001 | Context builder removes direct identity fields. |
| AIT-002 | Context builder does not include raw HealthKit series. |
| AIT-003 | Contextual understanding requires user confirmation before save. |
| AIT-004 | AI unavailable path preserves draft record. |
| AIT-005 | Output guard blocks restricted expression categories. |
| AIT-006 | User-facing AI text uses Vitora naming. |
