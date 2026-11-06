# QP conventions

- Target Quickshell 0.3.2 / Qt 6.12. Consult matching official docs and installed
  `.qmltypes` before adding unfamiliar APIs. Read `README.md` for runtime details.
- Keep `shell.qml` minimal. Window placement/screen/input behavior belongs in
  `modules/island/IslandWindow.qml`; feature wiring belongs in `Island.qml`.
- Shared preferences and appearance live in `core/Config.qml` and `Theme.qml`.
  Native Spotify discovery, stable selection, metadata and progress belong in
  `services/SpotifyService.qml`. Keep the minute clock local to `DateTimeNotch`.
- Use `pragma Singleton` plus Quickshell `Singleton` for shared state. Use
  `import qs.core`, `qs.components`, `qs.services`, and `qs.modules.island`.
  Quickshell generates module metadata; do not maintain source `qmldir` files.
- Components use PascalCase filenames, descriptive camelCase properties and
  `id: root` when useful. Prefer typed interfaces, `required` inputs, `readonly`
  derived state, declarative bindings, and intentional aliases for content slots.
  Do not overwrite derived bindings imperatively. `_selectedPlayer` is deliberate
  mutable service state for stable selection.
- Artwork and progress visuals stay independent of Spotify. Pass feature state
  explicitly into `SpotifyWidget`; route refresh requests back through `Island`.
  Keep one consumer-scoped 1 Hz timer, stopped when hidden/paused/unsupported.
  Quickshell position/length are seconds; call the documented `positionChanged()`
  notification to refresh local extrapolation, without polling commands or D-Bus.
- `Notch.qml` owns the silhouette/content slot; `DateTimeNotch.qml` owns its clock.
  Its bounds must include both concave upper shoulders. Use native vector arcs
  and the curve renderer; keep text padding inside the central body.
- The window spans the selected screen's width at y=0. `Island` centers ONLY the
  notch, then anchors widgets after its outer right shoulder. Never center a Row
  containing both surfaces: widget appearance and width must not move the notch.
- Keep the notch and widgets independently sized. Use the `notch*` and `widgets*`
  theme tokens and `Config.widgetsTopInset`; never add a top margin to the notch
  or shrink the composition with a scale transform.
- Use implicit sizes and `Row` within content slots. Do not mix horizontal anchors
  with Row ownership. Avoid parent/child measurement loops.
  Empty `WidgetsPill` collapses to zero width; binding its visibility to its Row's
  size creates inherited-visibility feedback. Ordinary QML children extend it
  without changing the notch position.
- Keep the overlay transparent, non-focusable, click-through, and non-reserving.
  Preserve true image clipping through `ClippingRectangle`; ordinary rectangle
  clipping is not circular. Rings must handle zero, one, and invalid values.
- Keep paused-state detection in SpotifyService (`MprisPlaybackState.Paused`).
  Pass `paused` through SpotifyWidget into artwork's `showPauseIndicator` input;
  never derive pause from `!playing`. The clipped black overlay is 0.30 opacity,
  the image stays fully opaque when ready, and the ring remains outside dimming.
- `Theme.accentPrimary` is exactly #9D00FF. Use the lighter `accentForeground`,
  `accentSecondary` and muted `accentMuted` via semantic color roles. Surfaces
  stay black and song artwork keeps its original colors. No icon fonts or emoji.
- Centralize visual constants in Theme, user preferences in Config. Keep changes
  proportional to this small project; avoid speculative registries or wrappers.
- Bootstrap tooling with `touch .qmlls.ini`, then `quickshell --path .`.
  Never commit generated `.qmlls.ini` or machine-specific runtime paths.
- Run `scripts/check-qml.sh --format` after QML edits, then
  `scripts/check-qml.sh` and `bash -n scripts/check-qml.sh`. The script resolves
  generated imports. README lists the two known Qt metadata warnings; do not
  hide new warnings or confuse static success with a clean runtime launch.
- Verify on Wayland with `quickshell --path . --no-duplicate --no-color`.
  Follow README's short manual checklist for top-edge/concave geometry,
  independent centering (also add a second widget), paused/stopped distinction,
  30% artwork dimming, purple ring, playback, collapse, clock, reload and input.
  Use isolated MPRIS fixtures if changing live playback would disturb the user.
  Distinguish fixture results from native Spotify checks.
