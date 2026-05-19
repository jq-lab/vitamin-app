# Vitora Design Handoff Gap Report

Date: 2026-05-07

This report turns the current visual comparison screenshots into a design-to-engineering gap matrix. It is a QA companion to `specs/004-vitora-swift-rebuild/design-handoff.md`.

## Evidence

| Artifact | Path |
| --- | --- |
| Main tab comparison | `ios/QA/Screenshots/ComparisonV2/01-tabs_before_after.png` |
| Today comparison | `ios/QA/Screenshots/ComparisonV2/02-today_before_after.png` |
| Vitora comparison | `ios/QA/Screenshots/ComparisonV2/03-vitora_before_after.png` |
| Cycle comparison | `ios/QA/Screenshots/ComparisonV2/04-cycle_before_after.png` |
| Support function wall | `ios/QA/Screenshots/ComparisonV2/05-support_functions_current.png` |
| Two core targets vs current | `ios/QA/Screenshots/ComparisonV2/06-two_design_targets_vs_current.png` |

Design targets:

- `assets/design_04/today_tab.png`
- `assets/design_04/vitora_tab.png`
- `assets/design_04/cycle_d.png`
- `assets/design_04/vitora_chip_clicked.png`

## Gap Priority

| Priority | Meaning |
| --- | --- |
| P0 | Blocks the intended product mental model or violates canonical facts. |
| P1 | Needed for target visual fidelity and design handoff completeness. |
| P2 | Polish, nuance, or future refinement after core handoff is stable. |

## Page Gap Matrix

| Area | Priority | Gap | Required design addition | Acceptance |
| --- | --- | --- | --- | --- |
| Onboarding | P1 | Current page is functional but reads as a system form. | Add Aura Glass onboarding direction, Pixel Vitora entry state, low-data reassurance, and completion feedback. | First launch conveys Vitora brand and still allows low-data entry. |
| Today | P1 | Structure matches, but glass depth, aura, and Pixel Vitora presence are weaker than target. | Specify G1/G2 layers, right-top IP scale, suggestion card density, and state curve emphasis. | Matches `today_tab.png` hierarchy without becoming dashboard-like. |
| Energy Reveal | P1 | Motion behavior exists but lacks design parameters. | Add reveal threshold, half/full heights, ball glow/scale, spring and Reduce Motion fallback. | Pull feels like ritual reveal, not refresh. |
| Today Calendar | P1 | Main path exists; uncertainty and correction states are under-specified. | Add selected day, forecast window, low confidence, and "date/feeling inaccurate" state. | User can understand current cycle position and correct Vitora. |
| Contextual Sheet | P1 | Sheet works; source preservation and save feedback need stricter design. | Add fixed source header, dim strength, dock placement, confirm/save animation. | Sheet always returns to source and never saves without confirmation. |
| Vitora Tab | P0 | Current surface can still feel like a function stack rather than a living assistant space. | Increase Pixel Vitora hero role, create clear conversation priority, define quick context adjacency. | Default view clearly shows assistant surface: IP, known context, dialogue, questions, chips, dock. |
| Quick Context | P1 | Chips exist, but state model is not complete. | Add idle/pressed/selected/expanded/dismissed examples. | Chips stay near input and do not become page navigation. |
| Review | P1 | Review loop exists; learning signal hierarchy is not fully specified. | Add before/after comparison emphasis, submitted feedback, learning signal and return path. | Does not look like task completion; shows Vitora learning. |
| Cycle | P1 | Structure is close; chart, IP, and TipKit details need polish. | Define chart tokens, phase colors, Pixel Vitora decor, Tip lifetime. | Cycle remains long-horizon rhythm, no calendar homepage. |
| Cycle Details | P1 | Details exist; confidence/prediction/meaning could be more structured. | Add fixed content order and confidence language. | User sees how Vitora judged phase and what today means. |
| Chart Callout | P1 | Callout exists; hot area and transition need spec. | Add 44pt touch region, callout placement, ask Vitora transition. | Tapping chart point reveals meaning and can open Vitora. |
| Support | P1 | P0 routes exist; G4 practical surface needs formal examples. | Add list row, child panel, danger confirmation, completed state specs. | Only six P0 support items, readable and non-commercial. |
| Data / Nutrition / Reminder / Export / Privacy | P1 | Functional paths exist; empty/error/permission states need design completion. | Add state matrix and copy rules for each support panel. | No medical/commercial tone; export/removal confirmation is explicit. |

## Design Completion Checklist

Use this checklist before assigning engineering implementation:

- [ ] Page goal is one sentence and user-value based.
- [ ] P0/P1/hidden information priority is listed.
- [ ] Components map to `C-*` or a named candidate.
- [ ] States include low data, empty, loading, error, permission denied, confirmed, and AI unavailable where relevant.
- [ ] Interactions include tap, long press, drag, sheet, keyboard, voice, and return path where relevant.
- [ ] Motion includes duration, easing, threshold, Reduce Motion, and Reduce Transparency behavior.
- [ ] Visual specs cite `vt.*` tokens.
- [ ] Target screenshot and current screenshot are linked.
- [ ] Unacceptable regressions are listed.

## Engineering Readiness Definition

A screen is ready for engineering when:

- The page spec can be implemented without asking design to decide layout hierarchy.
- Every interactive state has one visible output and one recovery path.
- Motion can be reproduced with named timing/easing values.
- Accessibility fallback is known before implementation.
- QA can compare against a screenshot and a written acceptance line.

## Current Gate

Current Swift implementation has the P0 behavior and IA in place. The next gap is design fidelity and interaction-motion completeness, not broad feature expansion.
