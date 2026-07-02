# Runtime Flows

## App Launch And Re-entry

Actor: local tester on iPhone 17 Pro simulator.

Precondition: `com.local.vivi.oura` is installed.

Success outcome: App opens the current PillowTalk Explore page and does not flash old charge UI.

Steps:

1. Native app loads `REMOTE_WEB_URI` with `openTab=vitals&demo=pillowtalk`.
2. `web/index.html` loads generated scripts.
3. `pillowtalk-explore-v1.js` sets `window.__vitoraEnsurePillowTalkExploreV1`.
4. Legacy `renderChargeContentIntoV7`, `ssEnsureChargeV1`, and `ensureChargeModeButtonAuditV1` are overridden to call the PillowTalk renderer.
5. `pageshow`, `focus`, and `visibilitychange` schedule a forced PillowTalk render.

State changes: local UI state only, stored in browser localStorage for PillowTalk records.

Trust boundaries: native shell to local WebView only. No remote API call is required for the UI flow.

## Onboarding To Today

Actor: first-time local tester.

Precondition: onboarding localStorage state is absent or reset.

Success outcome: registration flow completes and enters Today.

Steps:

1. Onboarding assets and scripts are injected by `prepare-web-assets.mjs`.
2. User progresses through entry, goal, questions, health permission, generation, reading, plan, and result screens.
3. Final CTA writes onboarding/profile/prediction state.
4. The app switches to Today and restores the bottom Tab.

State changes: localStorage onboarding/profile/prediction records.

Trust boundaries: local WebView storage only.

## Explore Card To Chat

Actor: local tester.

Precondition: Explore tab is active.

Success outcome: any Explore card opens the same chat page.

Steps:

1. User taps a card for thought, inspiration, dream, relationship, or recent record.
2. `handleAction()` sets the selected theme and calls `startChat()`.
3. Chat renders with message list, input, `结束对话`, and explicit `分析`.

State changes: selected theme, current route, message array.

Trust boundaries: none outside WebView.

## Chat Completion To Collection

Actor: local tester.

Precondition: user has sent at least one message or there is a current entry.

Success outcome: daily collection card is generated.

Steps:

1. User enters text.
2. Local reply engine appends an AI response.
3. User taps `结束对话`.
4. `collectCurrentEntry()` stores the entry.
5. Route changes to collection card page.

State changes: localStorage PillowTalk entries.

## Optional Analysis

Actor: local tester.

Precondition: chat page is open.

Success outcome: analysis page appears only after explicit tap.

Steps:

1. User taps `分析` in the chat header.
2. `start-analysis` builds or reuses the current entry.
3. Analysis page renders account progress for body, spirit, thought, and will accounts.
4. User taps generate/complete and reaches the same collection card page.

State changes: current entry and optional analysis state.
