# VIVI Ecosystem Background Pack

This folder is the local background asset pack used by the VIVI Oura simulator.

## Contents

- 18 JPEG backgrounds: 6 countries x 3 energy states.
- `metadata.json`: source URL, license URL, palette, motion, country, and energy metadata.

## Countries

- `china`
- `japan`
- `norway`
- `iceland`
- `usa`
- `indonesia`

## Energy States

- `low`: fog, rain, shade, lower contrast.
- `mid`: soft light, forest, lake, cloud.
- `high`: morning light, open view, clearer color.

## Runtime Paths

- Source pack: `vivi-oura-simulator/assets/ecosystems/`
- Generated web pack: `vivi-oura-simulator/web/assets/ecosystems/`
- Default China compatibility mirror: `vivi-oura-simulator/web/assets/backgrounds/`

The compatibility mirror lets the currently installed simulator shell load the new China scenes through the older background filenames.

## License

Current first batch uses Pexels images. See `metadata.json` for per-file source URLs and the Pexels license page.
