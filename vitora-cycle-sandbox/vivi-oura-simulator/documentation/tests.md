# Tests

## Existing Coverage

| Use Case | Rule | Evidence | Status |
| --- | --- | --- | --- |
| JavaScript generation scripts parse | `prepare-web-assets.mjs` must be syntactically valid | `node --check scripts/prepare-web-assets.mjs` | Existing manual command |
| PillowTalk runtime parses | `pillowtalk-explore-v1.js` must be syntactically valid | `node --check scripts/pillowtalk-explore-v1.js` | Existing manual command |
| TypeScript shell compiles | Expo shell must typecheck | `./node_modules/.bin/tsc --noEmit` | Existing manual command |
| WebView generation works | Generated `web/index.html` must be updated before install | `pnpm prepare:web` | Existing manual command |
| iPhone 17 Pro install works | App must install and launch on simulator | `pnpm ios:release --device EE0BC9AB-70C1-40F5-B13E-9C11F748E697` | Existing manual command |
| Re-entry does not restore old UI | Cold relaunch must show PillowTalk Explore | Simulator screenshots: `/private/tmp/vitora-pillowtalk-reinstalled-open.png`, `/private/tmp/vitora-pillowtalk-after-cold-relaunch.png` | Existing manual verification |

## Proposed Tests

| Use Case | Rule | Test Type |
| --- | --- | --- |
| Explore card entry | Every card routes directly to chat | Automated browser/DOM test |
| End conversation | `结束对话` routes to collection card without analysis | Automated browser/DOM test |
| Optional analysis | Analysis page opens only from chat `分析` button | Automated browser/DOM test |
| Onboarding close loop | Final CTA enters Today with profile/prediction state | Manual simulator test |
| Offline bundle fallback | Stopping 8822 still loads bundled assets | Manual simulator test |

## Gaps

- No CI gate currently runs the simulator WebView flow.
- No screenshot diff test exists for PillowTalk visual regressions.
- No automated test currently validates localStorage migration between older and current PillowTalk records.
