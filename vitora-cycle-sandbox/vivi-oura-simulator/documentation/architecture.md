# Architecture

## Product Overview

VI2 is an Expo iOS simulator app that wraps a generated WebView experience. The retained product surface is Today, Explore/PillowTalk, Collection, the Vitora onboarding flow, and the small cloud voice companion.

## Stack

- Native shell: Expo + React Native + `react-native-webview`
- Runtime UI: generated static HTML/CSS/JavaScript in `web/index.html`
- Asset bundling: Expo assets declared in `App.tsx`
- Web generation: `scripts/prepare-web-assets.mjs`
- Type safety: TypeScript via `tsc --noEmit`
- iOS target: local simulator app `com.local.vivi.oura`

## Runtime Loading

`App.tsx` first tries to load the remote development WebView:

```text
http://127.0.0.1:8822/vivi-oura-simulator/web/index.html?openTab=vitals&demo=pillowtalk
```

If the remote page fails, it falls back to the bundled `web/index.html` copied into the Expo cache. Runtime URL query forwarding supports `openTab`, `tab`, `demo`, `onboarding`, `showOnboarding`, and `healthSummary`.

## Core Modules

- `App.tsx`: native WebView shell, bundle asset manifest, remote/local fallback, app re-entry cache busting.
- `scripts/prepare-web-assets.mjs`: copies current assets and injects web modules into `web/index.html`.
- `scripts/pillowtalk-explore-v1.js`: Explore/PillowTalk component state machine.
- `scripts/pillowtalk-explore-v1.css`: current PillowTalk visual language.
- `scripts/webview-onboarding-today-v1.js`: onboarding and Today handoff behavior.
- `tools/tts-bakeoff/*`: retained voice tooling; bundled audio is reduced to the `ghost_soft` Xiaoyunduo voice set.

## Current Explore State Model

PillowTalk now keeps one primary flow:

```text
Explore card -> Chat -> End conversation -> Daily collection card
```

Optional analysis is an explicit branch:

```text
Chat -> Analysis button -> Analysis page -> Generate daily card
```

Legacy charge-mode renderers remain only as compatibility function names. They are short-circuited to `window.__vitoraEnsurePillowTalkExploreV1()` so app re-entry and old Tab hooks cannot restore the previous UI.

## Related Documents

- `flows.md`
- `permissions.md`
- `variables.md`
- `tests.md`

## Known Risks / Assumptions

- There is no backend service in this simulator version; chat replies and analysis are local mock logic.
- The WebView generated HTML is large because older Today/health surfaces still exist in the generated app. Explore-specific legacy flows have been disabled, but a future cleanup pass should remove unused CSS once the current UI is frozen.
- The repo remote is not configured in this worktree, so GitHub push requires adding a remote first.
- No scheduled work exists, so no `cron.md`.
- No transactional email exists, so no `emails.md`.
- No public SEO surface exists, so no `seo.md`.
