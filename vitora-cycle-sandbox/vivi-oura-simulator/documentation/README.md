# VI2 Handoff

This folder documents the current iPhone 17 Pro simulator version of the Vitora/VIVI app.

## Current Source Of Truth

- App package: `vivi-oura-simulator`
- Simulator bundle id: `com.local.vivi.oura`
- Simulator target used for validation: `EE0BC9AB-70C1-40F5-B13E-9C11F748E697`
- WebView entry: `web/index.html`
- Web asset generator: `scripts/prepare-web-assets.mjs`
- PillowTalk runtime: `scripts/pillowtalk-explore-v1.js`
- PillowTalk visual layer: `scripts/pillowtalk-explore-v1.css`
- Onboarding runtime: `scripts/webview-onboarding-today-v1.js`
- Onboarding visual layer: `scripts/webview-onboarding-today-v1.css`

## Build Commands

```bash
pnpm install
pnpm prepare:web
pnpm typecheck
pnpm ios:release --device EE0BC9AB-70C1-40F5-B13E-9C11F748E697
```

## Latest Verified Behavior

- App launch and cold relaunch open `探索` with PillowTalk, not the legacy charge UI.
- Exploration cards enter the unified chat flow.
- Chat input produces a local AI reply.
- `结束对话` creates the daily collection card.
- `分析` is only available from the chat page and only runs when explicitly tapped.
