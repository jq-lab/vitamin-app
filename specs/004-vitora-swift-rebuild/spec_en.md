# Vitora Swift Rebuild · Product Specification

> Spec set: `004-vitora-swift-rebuild`
> Batch: Core Product Spec
> Date: 2026-05-03
> Status: current

This document is the P0 product specification for the Swift rebuild. It defines product behavior, value, states, evidence, and acceptance criteria. It does not define Swift architecture, data schema, API endpoints, visual dimensions, or implementation tasks.

## 0. Authority Rules

| Rule ID | Rule | Constraint | Source |
| --- | --- | --- | --- |
| SPA-001 | `facts.md` is the highest source for this spec set. | If this file conflicts with `facts.md`, update `facts.md` first. | F-SOURCE-001 |
| SPA-002 | `userflows.md` provides the P0 user path source. | Every P0 requirement must map to at least one P0 userflow. | UFA-001 |
| SPA-003 | `ia.md` provides the navigation and screen source. | This spec cannot add a visible P0 route outside IA. | IAA-002, IAD-006 |
| SPA-004 | Product Reset filters decide keep / redesign / defer / drop. | Dropped or deferred surfaces cannot re-enter P0 through this file. | D-004, D-024 |
| SPA-005 | Original `Spec/` is a candidate pool only. | Useful intent can be reused only after passing `004` facts and reset filters. | F-SOURCE-002 |
| SPA-006 | Current RN app is evidence / anti-evidence. | Current visual style, placeholder actions, and broad navigation are not Swift targets. | F-SOURCE-003, D-025 |

### 0.1 Current App Simulator Evidence

This spec uses a fresh iOS Simulator pass from 2026-05-03 as evidence. The pass rendered the current Vitora app in iOS Simulator, then used direct taps, swipes, screenshots, and accessibility reads to inspect Today, Today analysis, A/B selection, Luna home, Luna record, Luna immersive chat, Luna drawer, Cycle expanded content, and Cycle calendar.

| Evidence ID | Interaction | Product Learning | Spec Impact |
| --- | --- | --- | --- |
| EV-RN-001 | Opened Today and tapped the `AI analysis` entry beside the energy orb. | Today is anchored by cycle context, a large energy orb, AI monitoring, four support metrics, generated suggestion entry, and record entry. | REQ-004, REQ-005, REQ-006 |
| EV-RN-002 | Scrolled Today analysis and selected A/B option B. | A/B selection currently creates an instant alert and a reminder time, but does not show a durable intent or review path. | REQ-007, REQ-011 |
| EV-RN-003 | Opened Luna, swiped between pixel home and full-screen chat, and used the `+` record path. | Luna has the correct home-to-chat gesture idea and record surface, but the current record send ends at acknowledgement without structured confirmation. | REQ-008, REQ-009, REQ-010 |
| EV-RN-004 | Opened Luna drawer and scrolled visible menu items. | Drawer contains useful support items mixed with deferred routes and future-feature noise. | REQ-014 |
| EV-RN-005 | Opened Cycle, inspected expanded content, then tapped calendar. | Cycle calendar is useful P0 evidence; expanded analytics, commercial entry, and extra insight surfaces must be narrowed. | REQ-012 |
| EV-RN-006 | Tapped the iOS navigation back label that appears as `Cycle`. | The label belongs to simulator / host navigation state, not Vitora IA. | SPA-006 |

## 1. Product Definition

Vitora is a private iOS body-rhythm companion app. It helps the user answer:

> "How am I today, and what can I lightly try?"

Luna is Vitora's AI companion role. Luna explains, records, suggests, reviews, and learns. Luna must serve the learning loop rather than becoming a generic chat surface.

The P0 Swift MVP proves one loop:

1. Today gives a clear daily state.
2. The first daily visit can use a small energy ritual to help the user understand that state.
3. Luna gives a small A/B action when there is enough context.
4. The user records, tries, skips, or gives light feedback.
5. Evening review compares the app's same-day intervention with later user feedback.
6. Luna uses the feedback to make future guidance more personal.

## 2. P0 Success Criteria

| Success ID | Criterion | Covered By |
| --- | --- | --- |
| S-P0-001 | A new user can enter Today without WeChat and without HealthKit authorization. | REQ-001, REQ-002, REQ-003 |
| S-P0-002 | Within 3 seconds of Today becoming usable, the user can understand state, cycle context, reason or trend, and next step. | REQ-004 |
| S-P0-003 | First daily open can show a purposeful energy ritual and then return to Today without trapping the user. | REQ-005 |
| S-P0-004 | A/B selection creates an intent and later review path, not only an instant confirmation. | REQ-006, REQ-007, REQ-011 |
| S-P0-005 | Luna can capture a lightweight record through natural language or quick entries, then confirm and save it. | REQ-008, REQ-009 |
| S-P0-006 | Luna immersive chat is reachable and reversible from Luna home. | REQ-010 |
| S-P0-007 | Cycle gives basic rhythm context and a calendar entry without exposing advanced surfaces as P0. | REQ-012 |
| S-P0-008 | Nutrition and support capabilities are reachable through the narrowed light drawer and Luna quick-add path. | REQ-013, REQ-014 |
| S-P0-009 | Compliance, privacy, and AI boundaries are visible product constraints, not later implementation details. | REQ-015, REQ-016 |

## 3. P0 Requirements

### REQ-001 · App Gate

| Field | Value |
| --- | --- |
| Requirement ID | REQ-001 |
| Area | App Gate |
| Priority | P0 Swift MVP |
| Product Behavior | On first launch, Vitora routes the user to onboarding. After onboarding completion, Vitora routes to Today. The app must not block entry on WeChat account binding. |
| User Value | The user reaches value quickly without account friction. |
| Inputs | Local onboarding completion state; optional account state; optional HealthKit authorization state. |
| Outputs | Onboarding route for new users; Today route for completed users; low-data mode flag if external data is unavailable. |
| States | first launch; onboarding incomplete; onboarding complete; low-data mode. |
| Linked Facts | F-P0-ONBOARDING-001, F-P0-ONBOARDING-002, F-P0-DATA-002 |
| Linked Userflows | UF-001, UF-002 |
| Linked IA | IA-000, IA-001, IA-002, IA-003 |
| Current RN Evidence | Current app gates onboarding through mock WeChat plus nickname and birthday; manual path is visible but not functional. This is anti-evidence. |
| Acceptance Criteria | User can complete P0 onboarding without WeChat; skipping HealthKit still enters Today; returning users land in Today. |
| Out of Scope | WeChat account gate; phone-code login; payment setup; account migration. |

### REQ-002 · Minimal Onboarding Context

| Field | Value |
| --- | --- |
| Requirement ID | REQ-002 |
| Area | Onboarding |
| Priority | P0 Swift MVP |
| Product Behavior | Onboarding collects only the minimum context Luna needs: preferred name, birthday context, basic cycle context, and 2-3 focus areas. |
| User Value | Luna can personalize the first day without making onboarding feel like a form wall. |
| Inputs | Preferred name; birthday context; last cycle context if provided; cycle length if provided; focus areas; optional free-text focus. |
| Outputs | Initial Luna context; onboarding completion state; Today first-open trigger. |
| States | required fields present; optional fields skipped; ready screen complete; onboarding complete. |
| Linked Facts | F-P0-ONBOARDING-001, F-P0-NAV-001 |
| Linked Userflows | UF-001 |
| Linked IA | IA-001, IA-002, IA-003 |
| Current RN Evidence | Current onboarding has useful three-step structure, but the first page over-weights account setup and mock device connection. |
| Acceptance Criteria | The user can finish with minimum context only; optional cycle details can be skipped; completion leads to Today and the first Today flow. |
| Out of Scope | Full account setup; broad device ecosystem; report upload; nutrition setup as required onboarding. |

### REQ-003 · HealthKit And Low-data Mode

| Field | Value |
| --- | --- |
| Requirement ID | REQ-003 |
| Area | HealthKit / Data Source |
| Priority | P0 Swift MVP |
| Product Behavior | Vitora offers HealthKit authorization as an optional enhancement. If the user skips or denies it, the app continues with manual and low-data paths. |
| User Value | The app remains useful for users without a watch, without authorization, or before enough history exists. |
| Inputs | HealthKit authorization result; available local health samples; manual records; onboarding context. |
| Outputs | Data availability state; low-data Today state; data source support path. |
| States | authorized; skipped; denied; low-data; enough context; not enough context. |
| Linked Facts | F-P0-DATA-001, F-P0-DATA-002, F-P0-SUPPORT-002 |
| Linked Userflows | UF-001, UF-002, UF-003, UF-008, UF-010 |
| Linked IA | IA-002, IA-013, IA-042 |
| Current RN Evidence | Current app shows device and health source candidates, but they are mock-style surfaces. |
| Acceptance Criteria | HealthKit denial does not block Today, Luna, or Cycle; Today clearly shows what it can still do; user can revisit data sources from support. |
| Out of Scope | Deep device management; non-HealthKit device SDK scope; automated device troubleshooting. |

### REQ-004 · Today First Open

| Field | Value |
| --- | --- |
| Requirement ID | REQ-004 |
| Area | Today |
| Priority | P0 Swift MVP |
| Product Behavior | Today answers current state, cycle context, reason or trend, and one useful next step within 3 seconds of the screen becoming usable. |
| User Value | The user does not need to decode a dashboard before getting value. |
| Inputs | Available health data; cycle context; records; A/B status; low-data state. |
| Outputs | Daily status summary; cycle context; explanation entry; record entry; optional A/B entry. |
| States | first daily open; normal open; low-data; A/B available; no useful next step. |
| Linked Facts | F-P0-TODAY-001, F-P0-NAV-001, F-PRODUCT-004, F-PRODUCT-006 |
| Linked Userflows | UF-000, UF-002 |
| Linked IA | IA-010, IA-013 |
| Current RN Evidence | EV-RN-001: Today shows a top cycle context row, a large energy orb, `AI analysis` entry, `AI monitoring today` card, four support metric tiles, a generated-suggestion entry, Today records, and `+ record`. This proves the daily-state intent but also shows density risk. |
| Acceptance Criteria | Today has a clear primary state; no task debt is shown; no permanent drawer entry appears; low-data mode remains useful. |
| Out of Scope | Custom task cards; dense chart dashboard; completion status; streak or red-dot pressure. |

### REQ-005 · Full Energy Ritual

| Field | Value |
| --- | --- |
| Requirement ID | REQ-005 |
| Area | Energy / Orb |
| Priority | P0 Swift MVP |
| Product Behavior | The first daily Today visit may show a minimal energy ritual that reveals how Vitora formed today's state and then returns to Today or analysis. |
| User Value | The first moment of the day feels meaningful and explains the state rather than only decorating it. |
| Inputs | Daily status inputs; data availability; cycle context; first-open state. |
| Outputs | Ritual state; one-line explanation; next step; completion of first-open state. |
| States | ritual start; enough data; low-data ritual; analysis entry; skipped or completed. |
| Linked Facts | F-P0-ORB-001, F-P0-ORB-002 |
| Linked Userflows | UF-002, UF-003 |
| Linked IA | IA-011, IA-012 |
| Current RN Evidence | EV-RN-001: tapping the energy analysis entry opens a dimmed Today overlay with a bottom-sheet style analysis surface. Swift P0 should preserve the purpose of reveal and understanding, not the current timing, density, or overlay treatment. |
| Acceptance Criteria | Ritual is optional after first reveal; user can reach Today or analysis without confusion; low-data ritual does not overstate certainty. |
| Out of Scope | Copying current timing; long blocking animation; decorative-only orb sequence. |

### REQ-006 · Today Analysis

| Field | Value |
| --- | --- |
| Requirement ID | REQ-006 |
| Area | Today Analysis |
| Priority | P0 Swift MVP |
| Product Behavior | Today analysis explains the state in plain language, shows only necessary supporting context, and offers A/B only when a useful same-day action exists. |
| User Value | The user understands why Vitora says what it says and what can be lightly tried. |
| Inputs | Daily state; contributing factors; cycle context; record context; data confidence. |
| Outputs | Explanation; support context; optional A/B choices; not-suitable feedback path. |
| States | analysis available; not enough context; A/B available; A/B not useful; feedback captured. |
| Linked Facts | F-P0-ORB-002, F-P0-AB-001, F-P0-AB-002 |
| Linked Userflows | UF-003, UF-004 |
| Linked IA | IA-012 |
| Current RN Evidence | EV-RN-001 and EV-RN-002: current analysis shows energy score, four support metrics, plain-language explanation, a same-day suggestion timeline, and A/B options. The intent is useful; density, dimmed layering, and weak follow-through are anti-evidence. |
| Acceptance Criteria | A/B is absent when not useful; analysis has a clear reason and next step; not-suitable feedback can be captured without pressure. |
| Out of Scope | Multi-dimensional explanation lists; always-on A/B; one-off confirmation as final behavior. |

### REQ-007 · A/B Commitment And Reminder Path

| Field | Value |
| --- | --- |
| Requirement ID | REQ-007 |
| Area | A/B Suggestion |
| Priority | P0 Swift MVP |
| Product Behavior | Selecting A or B forms a same-day intent, optionally connects to reminder preference, and creates an evening review path. |
| User Value | The user understands that selection means "I will try this today" and that Luna can learn from the result. |
| Inputs | A/B options; selected option; optional reminder preference; notification permission state; evening review availability. |
| Outputs | Same-day intent; reminder preference state; review entry; feedback expectation. |
| States | A selected; B selected; not suitable; skipped; reminder wanted; reminder not wanted; review pending. |
| Linked Facts | F-P0-AB-001, F-P0-AB-002, F-P0-REVIEW-001 |
| Linked Userflows | UF-004, UF-007 |
| Linked IA | IA-012, IA-023, IA-044 |
| Current RN Evidence | EV-RN-002: selecting option B shows an instant alert with the selected action and a reminder time. This is stronger than a toast, but it still does not expose a durable same-day intent, editable reminder preference, or evening review path. |
| Acceptance Criteria | A/B selection is stored as today's intent; reminder preference is offered only when useful; evening review can find the intent later. |
| Out of Scope | VIP learning memory; full notification center; task checklist. |

### REQ-008 · Luna Home

| Field | Value |
| --- | --- |
| Requirement ID | REQ-008 |
| Area | Luna |
| Priority | P0 Swift MVP |
| Product Behavior | Luna home presents a calm companion surface with pixel Luna, current context, record entry, chat entry, and review entry when available. |
| User Value | The user knows where to tell Luna something, ask a follow-up, or finish the day's loop. |
| Inputs | Current daily state; cycle context; recent records; review availability; low-data state. |
| Outputs | Context bubble; quick record entries; chat entry; review card or quiet state. |
| States | normal home; record-focused; review available; low-data; immersive chat available. |
| Linked Facts | F-P0-LUNA-001, F-P0-LUNA-002, F-P0-RECORD-001 |
| Linked Userflows | UF-005, UF-006, UF-007 |
| Linked IA | IA-020, IA-021, IA-023 |
| Current RN Evidence | EV-RN-003: Luna has pixel home, `AI conversation / record book` top tabs, drawer entry, current context bubble, quick action pills, a bottom input dock, and a reversible full-screen chat state. Search, topic selector, broad theme controls, and placeholder actions are anti-evidence. |
| Acceptance Criteria | Record entry is prominent; review entry appears only when useful; support drawer is reachable; placeholder actions are not visible. |
| Out of Scope | Search history; broad topic control; generic assistant mode unrelated to Vitora. |

### REQ-009 · Luna Record Capture

| Field | Value |
| --- | --- |
| Requirement ID | REQ-009 |
| Area | Luna Record |
| Priority | P0 Swift MVP |
| Product Behavior | Luna supports natural-language record capture and a small set of quick record types. Each capture must parse or structure, show a short confirmation, then save or cancel. |
| User Value | Recording feels lighter than a form while still creating reliable context for Today, A/B, and review. |
| Inputs | Natural-language text; quick record type; optional mood or thought; nutrition quick-add; edit confirmation. |
| Outputs | Confirmed record; canceled record; saved Luna context; updated low-data context. |
| States | manual entry; AI entry; parse pending; confirmation; saved; canceled; needs edit. |
| Linked Facts | F-P0-LUNA-001, F-P0-RECORD-001, F-P0-SUPPLEMENT-001 |
| Linked Userflows | UF-005, UF-009 |
| Linked IA | IA-021, IA-043 |
| Current RN Evidence | EV-RN-003: `+` opens a manual / AI record sheet; AI record examples fill the input, the send button shows a sent acknowledgement, and the sheet closes back to chat. There is no visible parse result, editable confirmation, or saved-record feedback loop. |
| Acceptance Criteria | At least one natural-language path and core quick record paths save real records; each saved record can be used as Luna context; placeholder-only record actions are absent. |
| Out of Scope | Deep forms for every category; record history search; camera recognition beyond P0 nutrition quick-add intent. |

### REQ-010 · Luna Immersive Chat

| Field | Value |
| --- | --- |
| Requirement ID | REQ-010 |
| Area | Luna Immersive Chat |
| Priority | P0 Swift MVP |
| Product Behavior | Luna supports a reversible transition between pixel home and immersive chat. The immersive state must focus on reading and input rather than simply showing a status banner. |
| User Value | The user can move from companion home into focused conversation when needed. |
| Inputs | Swipe-up gesture or explicit chat entry; text input; record intent inside chat; exit gesture. |
| Outputs | Immersive chat state; return to Luna home; optional record capture. |
| States | pixel home; entering chat; immersive chat; returning home; record capture from chat. |
| Linked Facts | F-P0-LUNA-002, F-P0-LUNA-003, F-P0-RECORD-001 |
| Linked Userflows | UF-006, UF-005 |
| Linked IA | IA-022 |
| Current RN Evidence | EV-RN-003: swipe gestures move between pixel home and full-screen chat, with a banner saying the full-screen state is active and a persistent input dock. The transition intent is valid; Swift P0 must make the focused chat state more useful than a status banner over compressed home content. |
| Acceptance Criteria | Swipe or explicit entry changes focus meaningfully; exit returns to Luna home; record capture remains reachable from chat. |
| Out of Scope | Local model controls; generic productivity assistant; hidden navigation with no recovery path. |

### REQ-011 · Evening Review

| Field | Value |
| --- | --- |
| Requirement ID | REQ-011 |
| Area | Evening Review |
| Priority | P0 Swift MVP |
| Product Behavior | Evening review appears only when there is a same-day A/B intent or meaningful record. It compares what Vitora suggested or captured earlier with later user feedback. |
| User Value | The user can feel whether the app helped today, and Luna learns without creating pressure. |
| Inputs | A/B intent; same-day records; user feedback; reminder preference; time context. |
| Outputs | Review card; feedback result; learning signal for future suggestions; quiet state if no review is useful. |
| States | review available; opened; feedback captured; skipped; no review. |
| Linked Facts | F-P0-REVIEW-001, F-P0-AB-001, F-PRODUCT-003 |
| Linked Userflows | UF-004, UF-007 |
| Linked IA | IA-023, IA-044 |
| Current RN Evidence | Current repo has partial review components and scheduler logic, but they are not integrated into the visible P0 loop. |
| Acceptance Criteria | Review can state what the app prompted earlier; user can answer with low effort; no review appears when there is nothing meaningful to revisit. |
| Out of Scope | Weekly review; long-form coaching; VIP memory layer. |

### REQ-012 · Cycle Basic Overview And Calendar

| Field | Value |
| --- | --- |
| Requirement ID | REQ-012 |
| Area | Cycle |
| Priority | P0 Swift MVP |
| Product Behavior | Cycle shows basic rhythm context and provides a calendar entry. Advanced expanded surfaces are hidden in P0. |
| User Value | The user understands cycle context without being pushed into a heavy analytics surface. |
| Inputs | Cycle context; saved records; selected date; low-data state. |
| Outputs | Basic overview; calendar entry; date context; record prompt when context is missing. |
| States | enough cycle context; low cycle context; calendar view; date selected; record needed. |
| Linked Facts | F-P0-CYCLE-001, F-P0-NAV-001, F-P0-DATA-002 |
| Linked Userflows | UF-008 |
| Linked IA | IA-030, IA-031 |
| Current RN Evidence | EV-RN-005: Cycle exposes rhythm context, learning-progress style content, energy monitoring, calendar entry, VIP learning path, and a colored calendar view with insight and reminder controls. P0 keeps basic overview plus calendar value, while hiding advanced and commercial surfaces. |
| Acceptance Criteria | P0 Cycle has overview and calendar path; advanced swipe-up content is not visible as P0; missing context leads to Luna record. |
| Out of Scope | Advanced charts; search / explore; full growth system; commercial analysis entry. |

### REQ-013 · Nutrition Capability

| Field | Value |
| --- | --- |
| Requirement ID | REQ-013 |
| Area | Nutrition |
| Priority | P0 Swift MVP |
| Product Behavior | Nutrition is available as a light drawer management page and as a Luna record quick-add. It records what the user already uses as context for Luna. |
| User Value | Luna can understand a relevant personal context without turning onboarding or Today into a shopping or promotion surface. |
| Inputs | Nutrition item name; optional timing; optional note; source route. |
| Outputs | Saved nutrition context; edited context; canceled change; empty state with add action. |
| States | no entries; add; edit; saved; canceled; launched from drawer; launched from Luna record. |
| Linked Facts | F-P0-SUPPLEMENT-001, F-P0-SUPPORT-002 |
| Linked Userflows | UF-009, UF-005 |
| Linked IA | IA-021, IA-043 |
| Current RN Evidence | Current app has nutrition in drawer and record panel, plus onboarding candidates. P0 keeps drawer + Luna quick-add and removes onboarding friction. |
| Acceptance Criteria | Nutrition can be added from Luna record; nutrition can be managed from drawer; empty state does not imply user must add anything. |
| Out of Scope | Product search marketplace; purchase flow; required onboarding nutrition setup. |

### REQ-014 · Light Drawer Support

| Field | Value |
| --- | --- |
| Requirement ID | REQ-014 |
| Area | Support |
| Priority | P0 Swift MVP |
| Product Behavior | The light drawer contains only P0 support items: profile, HealthKit and data sources, nutrition, reminder preferences, data export, privacy/legal and account removal. |
| User Value | The user can manage trust and data without seeing a future-feature menu. |
| Inputs | Entry source; current support state; authorization state; account state. |
| Outputs | Support home; selected support child; return to source screen. |
| States | opened from Luna; opened from Cycle; contextual support from Today; child item opened; closed. |
| Linked Facts | F-P0-SUPPORT-001, F-P0-SUPPORT-002, F-PRIVACY-005 |
| Linked Userflows | UF-009, UF-010 |
| Linked IA | IA-040, IA-041, IA-042, IA-043, IA-044, IA-045, IA-046 |
| Current RN Evidence | EV-RN-004: current wide drawer includes profile, Luna growth, data charts, nutrition, health background, data sources, subscription, reminders, widgets, settings, help or feedback, data export, and privacy / account removal. This confirms the candidate pool, but P0 must narrow it to a light drawer. |
| Acceptance Criteria | Drawer has no placeholder rows; all visible rows are P0 support; closing returns to source; Today has no permanent drawer button. |
| Out of Scope | Broad settings hub; widgets; subscription; help center; chart hub; Luna growth page. |

### REQ-015 · Compliance And Privacy Boundaries

| Field | Value |
| --- | --- |
| Requirement ID | REQ-015 |
| Area | Compliance / Privacy |
| Priority | P0 Swift MVP |
| Product Behavior | Health-related displays, Luna replies, analysis, review, and support pages must use approved compliance labels and privacy rules. Sensitive health data is local-first and protected. |
| User Value | The user can trust Vitora with private health context. |
| Inputs | Health-related content; AI input context; logs; export request; account removal request. |
| Outputs | Approved compliance label; minimized AI context; safe log behavior; export flow; account removal flow. |
| States | health content visible; AI content generated; export requested; account removal requested; error state. |
| Linked Facts | F-COMPLIANCE-001, F-COMPLIANCE-002, F-COMPLIANCE-003, F-PRIVACY-001, F-PRIVACY-002, F-PRIVACY-003, F-PRIVACY-004, F-PRIVACY-005 |
| Linked Userflows | UF-010, UF-005, UF-007 |
| Linked IA | IA-040, IA-045, IA-046 |
| Current RN Evidence | Current repo includes sanitizer and compliance constants, but data protection is not sufficient as a final product guarantee. |
| Acceptance Criteria | Approved labels appear where required; AI inputs are minimized; health values do not appear in logs; export and account removal are reachable. |
| Out of Scope | Rewriting full compliance copy in this file; technical encryption plan; server retention implementation. |

### REQ-016 · AI And Future Local Model Readiness

| Field | Value |
| --- | --- |
| Requirement ID | REQ-016 |
| Area | AI / Future Local LLM |
| Priority | P0 Swift MVP boundary |
| Product Behavior | P0 may use AI to explain, suggest, review, and understand records, but it must not expose local model controls. Product and data boundaries must keep future local Gemma / agentic usage possible. |
| User Value | P0 can ship with useful Luna behavior while avoiding architectural dead ends for later privacy and offline improvements. |
| Inputs | Minimal context for Luna; user record; A/B history; review feedback; privacy constraints. |
| Outputs | Luna explanation; suggestion; record understanding; review summary; future-safe boundary notes. |
| States | cloud-backed AI; offline or unavailable AI; future local model candidate; no visible model control. |
| Linked Facts | F-P0-AI-001, F-P0-AI-002, F-AI-001, F-AI-002, F-OUT-006 |
| Linked Userflows | UF-005, UF-006, UF-007, UF-106 |
| Linked IA | IAS-009 |
| Current RN Evidence | Current RN has AI service shells and sanitizer helpers, but no local model or agent surface. |
| Acceptance Criteria | No P0 screen exposes local model controls; all AI behavior remains within product facts; future AI plan can choose model placement later. |
| Out of Scope | Local Gemma runtime; agent tool execution; model picker; prompt engineering spec. |

## 4. State Requirements

| State ID | Trigger | Product Requirement | Covered By |
| --- | --- | --- | --- |
| ST-001 | No onboarding completion | Only onboarding is primary; app exits to Today after completion. | REQ-001, REQ-002 |
| ST-002 | HealthKit skipped or denied | App enters low-data mode and remains fully navigable. | REQ-003 |
| ST-003 | First daily Today open | Energy ritual can appear, then returns to Today or analysis. | REQ-005 |
| ST-004 | Normal Today open | Today shows daily state directly. | REQ-004 |
| ST-005 | Analysis has useful action | A/B appears and can form a same-day intent. | REQ-006, REQ-007 |
| ST-006 | A/B selected | Reminder preference and evening review path become available. | REQ-007, REQ-011 |
| ST-007 | Evening has no useful context | Review stays quiet and does not create pressure. | REQ-011 |
| ST-008 | Luna receives a record | Luna confirms and saves before using it as context. | REQ-009 |
| ST-009 | Cycle has low context | Cycle shows basic explanation and points to Luna record. | REQ-012 |
| ST-010 | User opens support | Light drawer shows only P0 support items. | REQ-014 |

## 5. Low-data Requirements

| Low-data Rule ID | Requirement |
| --- | --- |
| LDR-001 | Low-data is a normal P0 state, not an error state. |
| LDR-002 | Today must still answer what is known now and what the user can lightly do next. |
| LDR-003 | Luna record must become the primary way to improve context when HealthKit is absent. |
| LDR-004 | Cycle must request only the minimum cycle context needed for basic calendar usefulness. |
| LDR-005 | The support drawer must let the user revisit HealthKit and data source choices. |
| LDR-006 | A/B should not appear if there is not enough context for a useful same-day action. |

## 6. Compliance / Privacy / AI Boundaries

| Boundary ID | Requirement | Covered By |
| --- | --- | --- |
| BPA-001 | Approved compliance labels are required on health-related cards, Luna health-related replies, and review surfaces. | REQ-015 |
| BPA-002 | Sensitive health data is local-first and protected by the later technical plan. | REQ-015 |
| BPA-003 | AI context must be minimized and stripped of direct identity fields. | REQ-015, REQ-016 |
| BPA-004 | Logs and crash output must not include health values. | REQ-015 |
| BPA-005 | Data export and account removal are P0 support capabilities. | REQ-014, REQ-015 |
| BPA-006 | Future local model and agentic usage is allowed as a later direction, but P0 has no visible model control. | REQ-016 |

## 7. Deferred / Out Requirements

| Candidate | P0 Status | Reason | Source |
| --- | --- | --- | --- |
| WeChat account gate | Out | User confirmed Swift first release does not require it. | F-OUT-001, D-019 |
| Broad drawer route pool | Out | It creates placeholder navigation and scope noise. | F-OUT-002, D-024 |
| Full VIP system | Deferred | P0 must prove the learning loop first. | F-OUT-003 |
| Widgets and deep device ecosystem | Deferred | Native extension and device breadth can follow the core loop. | F-OUT-004 |
| Full Luna growth system | Deferred | Progress and day-count framing can create pressure. | F-OUT-005 |
| Local model execution | Deferred | Product and data boundaries must remain future-ready. | F-OUT-006, REQ-016 |
| Current RN visual style and host navigation artifacts | Out | Current app is evidence only; EV-RN-006 confirms simulator / host navigation labels are not Vitora IA. | F-OUT-007, D-017 |
| Custom task card | Out | It pushes Today toward task management. | F-OUT-008 |
| Cycle advanced expanded surface | Deferred | P0 keeps basic overview and calendar only. | F-P0-CYCLE-001, FI-032 |
| Search / explore | Deferred | Requires mature record history. | UF-102 |

## 8. Cross-reference Matrix

### 8.1 Facts Coverage

| Fact Group | Requirements |
| --- | --- |
| F-PRODUCT-001 to F-PRODUCT-006 | REQ-004, REQ-006, REQ-008, REQ-011 |
| F-P0-ONBOARDING-001 to F-P0-ONBOARDING-002 | REQ-001, REQ-002 |
| F-P0-DATA-001 to F-P0-DATA-002 | REQ-003, REQ-004, REQ-012 |
| F-P0-NAV-001 | REQ-004, REQ-008, REQ-012, REQ-014 |
| F-P0-TODAY-001, F-P0-ORB-001, F-P0-ORB-002 | REQ-004, REQ-005, REQ-006 |
| F-P0-AB-001, F-P0-AB-002 | REQ-006, REQ-007, REQ-011 |
| F-P0-LUNA-001 to F-P0-LUNA-003 | REQ-008, REQ-009, REQ-010 |
| F-P0-RECORD-001 | REQ-009, REQ-010, REQ-012 |
| F-P0-CYCLE-001 | REQ-012 |
| F-P0-REVIEW-001 | REQ-007, REQ-011 |
| F-P0-SUPPORT-001, F-P0-SUPPORT-002 | REQ-014, REQ-015 |
| F-P0-SUPPLEMENT-001 | REQ-009, REQ-013 |
| F-P0-AI-001, F-P0-AI-002 | REQ-016 |
| F-COMPLIANCE-001, F-COMPLIANCE-002, F-COMPLIANCE-003, F-PRIVACY-001, F-PRIVACY-002, F-PRIVACY-003, F-PRIVACY-004, F-PRIVACY-005, F-AI-001, F-AI-002 | REQ-015, REQ-016 |

### 8.2 Userflow Coverage

| Userflow | Requirements |
| --- | --- |
| UF-000 | REQ-004, REQ-006, REQ-007, REQ-009, REQ-011 |
| UF-001 | REQ-001, REQ-002, REQ-003 |
| UF-002 | REQ-001, REQ-004, REQ-005 |
| UF-003 | REQ-005, REQ-006 |
| UF-004 | REQ-006, REQ-007 |
| UF-005 | REQ-008, REQ-009 |
| UF-006 | REQ-010 |
| UF-007 | REQ-007, REQ-011 |
| UF-008 | REQ-012 |
| UF-009 | REQ-009, REQ-013, REQ-014 |
| UF-010 | REQ-003, REQ-014, REQ-015 |

### 8.3 IA Coverage

| IA IDs | Requirements |
| --- | --- |
| IA-000 | REQ-001 |
| IA-001 to IA-003 | REQ-001, REQ-002, REQ-003 |
| IA-010 | REQ-004 |
| IA-011 | REQ-005 |
| IA-012 | REQ-006, REQ-007 |
| IA-013 | REQ-003, REQ-004 |
| IA-020 | REQ-008 |
| IA-021 | REQ-009, REQ-013 |
| IA-022 | REQ-010 |
| IA-023 | REQ-011 |
| IA-030 to IA-031 | REQ-012 |
| IA-040 | REQ-014 |
| IA-041 | REQ-014 |
| IA-042 | REQ-003, REQ-014 |
| IA-043 | REQ-013, REQ-014 |
| IA-044 | REQ-007, REQ-014 |
| IA-045 | REQ-014, REQ-015 |
| IA-046 | REQ-014, REQ-015 |
| IAS-009 | REQ-016 |

## 9. Acceptance Criteria

| Acceptance ID | Requirement |
| --- | --- |
| AC-001 | `spec.md` contains no dependency on prior generated rebuild material. |
| AC-002 | All P0 facts in `facts.md` map to at least one `REQ-XXX`. |
| AC-003 | `UF-000` through `UF-010` map to one or more requirements. |
| AC-004 | Every P0 IA screen or state has requirement coverage. |
| AC-005 | Dropped and deferred candidates are listed only in Deferred / Out Requirements, not as P0 behavior. |
| AC-006 | No requirement describes Expo, React Native, or current RN route behavior as the Swift target. |
| AC-007 | Low-data mode is explicitly supported across onboarding, Today, Luna, Cycle, and support. |
| AC-008 | A/B requirements include same-day intent, reminder preference, and evening review path. |
| AC-009 | Nutrition is reachable through drawer management and Luna quick-add. |
| AC-010 | Privacy, compliance, and AI boundaries are explicit enough for later compliance and technical batches. |

## 10. Usage Rule

Future `wireframes.md`, `components.md`, `plan.md`, and `tasks.md` must reference the `REQ-XXX` IDs in this file. A future feature cannot enter P0 unless it maps to a P0 fact, a P0 userflow, and a P0 IA entry.

If a future document needs to change product scope, update `facts.md` and `decision-log.md` first, then update this file.
