# Variables And Secrets

## Configuration

| Name | Used By | Scope | Source | Rotation | Risk |
| --- | --- | --- | --- | --- | --- |
| `REMOTE_WEB_BASE_URI` | `App.tsx` | Client | Constant | Change per local server | Local development URL only |
| `APP_DEMO_QUERY` | `App.tsx` | Client | Constant | Change per target flow | Controls default route |
| `CACHE_ROOT` | `App.tsx` | Client | Expo file-system cache | N/A | Local bundled asset cache |
| TTS provider examples | `tools/tts-bakeoff` | Local tooling | `.env.tts-bakeoff.example` | Provider-specific | Do not commit real API keys |

## Secret Handling

No production secret is required to run the current simulator. Real TTS/API provider keys must stay in local `.env` files and must not be bundled into `web/index.html`, `App.tsx`, or Expo assets.

## Pre-go-live Checklist

- Replace local mock chat engine with an authenticated API if real AI is required.
- Add explicit privacy copy before transmitting PillowTalk text.
- Ensure no provider key is included in Expo bundle assets.
- Confirm remote WebView URL is not a localhost development URL for production.
