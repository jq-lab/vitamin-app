# VI2 Vitora Simulator

This is the retained current simulator version of the Vitora/VIVI app.

## What This Folder Contains

- Expo iOS simulator shell in `App.tsx`
- Generated WebView app in `web/index.html`
- Source injection scripts in `scripts/`
- PillowTalk Explore implementation in `scripts/pillowtalk-explore-v1.js` and `scripts/pillowtalk-explore-v1.css`
- Onboarding implementation in `scripts/webview-onboarding-today-v1.js` and `scripts/webview-onboarding-today-v1.css`
- Current image/audio assets in `assets/` and `web/assets/`
- Handoff documentation in `documentation/`

## Run

```bash
pnpm install
pnpm prepare:web
pnpm typecheck
pnpm ios:release --device EE0BC9AB-70C1-40F5-B13E-9C11F748E697
```

## Verified Current Behavior

- Launch and cold relaunch open the current `探索` PillowTalk UI.
- Legacy charge/explore UI renderers are short-circuited to the PillowTalk renderer.
- Chat flow is unified: card -> chat -> end conversation -> daily collection card.
- Analysis is explicit only: chat -> `分析` -> analysis -> daily collection card.
- Only Xiaoyunduo/ghost-soft voice MP3 files remain bundled.
