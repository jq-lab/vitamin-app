# Pivot Adaptation QA Report

Date: 2026-05-06

## Scope

This report covers the first implementation round after the IA / design pivot. The implementation target was tasks `T102` through `T138` in `specs/004-vitora-swift-rebuild/tasks.md`.

Validated against:
- `specs/004-vitora-swift-rebuild/wireframes-walkthrough-demo.md`
- `specs/004-vitora-swift-rebuild/design-language-demo.md`
- `specs/004-vitora-swift-rebuild/ia.md`
- `specs/004-vitora-swift-rebuild/components.md`
- `specs/004-vitora-swift-rebuild/interaction-acceptance.md`

## Automated QA

Command:

```text
xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17' -parallel-testing-enabled NO test
```

Result:
- `VitoraTests.xctest`: 57 tests, 0 failures
- `VitoraUITests.xctest`: 23 tests, 0 failures
- Total: 80 tests, 0 failures

Result bundle:

```text
/Users/bytedance/Library/Developer/Xcode/DerivedData/Vitora-axzymyapnnqblcawdisxryovaxfc/Logs/Test/Test-Vitora-2026.05.06_10-59-41-+0800.xcresult
```

## Manual Simulator / iosef QA

Tooling:
- Simulator: `iPhone 17`
- App bundle: `com.vitora.app`
- Launch state: completed onboarding + rich Today data
- Interaction tool: `iosef`

iosef status after recovery:

```text
state: Booted
device: iPhone 17
```

One iosef call briefly hit a `CoreSimulatorService connection invalid` error. I restarted the simulator service path, rechecked `iosef status --json`, relaunched the app, and repeated the remaining Vitora / Cycle manual checks. iosef attach and screenshots worked after recovery.

## Screenshot Evidence

Saved under `ios/QA/Screenshots/Pivot/`:

| File | Validated surface |
| --- | --- |
| `01-today-home.png` | Today home: top calendar entry, status card, body factors, Vitora suggestion, low-lift Vitora CTA. |
| `02-today-calendar-sheet.png` | Today-owned calendar sheet, not Cycle homepage. |
| `03-energy-reveal.png` | Pull-to-reveal Energy Ball ritual layer. |
| `04-contextual-vitora-sheet.png` | 3/4 contextual Vitora sheet from Today Energy Ball. |
| `05-vitora-tab.png` | Vitora assistant surface with Pixel Vitora context, conversation, direct questions, input dock. |
| `06-cycle-home.png` | Cycle homepage with phase relation card and energy dynamics card only. |
| `07-cycle-phase-detail.png` | Cycle phase second-level transparent explanation sheet. |
| `08-cycle-energy-detail.png` | Cycle energy dynamics second-level trend exploration sheet. |
| `09-cycle-energy-callout.png` | Chart data-point callout with `问 Vitora` action. |
| `10-cycle-settings.png` | Cycle top-right settings/profile support entry. |

## IA Findings

Passed:
- Primary tabs are `Today / Vitora / Cycle`; the center CTA uses a Pixel Vitora face and stays low enough to avoid the input dock.
- Today no longer has a standalone `今日记录` section or old `AI管家已生成今日建议` block.
- Today follows the pivot structure: `现在状态 -> 身体要素 -> Vitora 今日建议`.
- Today calendar lives behind the top calendar entry, not on Cycle home.
- Energy Ball is hidden by default and appears through pull-to-reveal.
- Object-level Vitora activation opens a contextual sheet and preserves source context.
- Vitora Tab is not an empty chat page. It includes known context, direct question strips, quick context chips, rich response state, and input dock.
- Cycle home is long-horizon: current phase relation plus energy dynamics, with no calendar homepage.
- Cycle second-level IA adds real depth through explanation, confidence, prediction window, trend layers, key points, and chart callout.
- Support/settings entry is reachable from Cycle top-right profile/settings control.

## Visual Findings

Passed:
- Aura / diffuse gradient background is applied to first-level surfaces.
- Clear glass cards are used across Today, Vitora, and Cycle.
- Pixel Vitora exists as a reusable IP component and central tab face.
- Charts use simplified insight-first visuals rather than dense dashboard layouts.
- Input dock is above the bottom tab zone and does not collide with the center CTA in the Vitora Tab.

Known remaining visual gap:
- This round implements the pivot structure and visual primitives, but it is not yet final pixel-level polish against the generated design references. The next UI rounds should tighten exact spacing, glass translucency, Pixel Vitora art fidelity, and motion nuance against `assets/design_04/*`.

## Functional Findings

Passed:
- Today status card opens status detail.
- Today calendar opens and closes.
- Energy Ball pull-to-reveal works and can open contextual Vitora.
- Contextual Vitora sheet has quick chips, text input, voice affordance, and send affordance.
- Vitora Tab accepts input and produces an understanding/rich response state.
- Cycle phase card opens phase detail.
- Cycle energy card opens energy detail.
- Cycle chart point opens a callout.
- Cycle settings opens the P0 support list.

## Gate Decision

`T102` through `T138` are complete. The app can proceed to the next SpecKit phase: `Phase 15: Evening Review`.

Before the next phase, maintain these guardrails:
- Do not reintroduce standalone Today record sections.
- Do not make Vitora an empty chat page or dashboard grid.
- Do not put the calendar back on Cycle home.
- Do not replace Pixel Vitora with a smooth orb, human avatar, pet, or generic icon.
- Continue using Simulator + iosef manual QA after each implementation round.
