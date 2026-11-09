# QP conventions

- Target Quickshell 0.3.2 / Qt 6.12. Consult matching official docs and installed
  `.qmltypes` before adding unfamiliar APIs. Read README for setup and behavior.
- Keep `shell.qml` minimal. Screen/window/input regions belong in `IslandWindow`;
  interaction state, geometry and service wiring belong in `Island`.
- Shared preferences and appearance live in Config/Theme. Use `pragma Singleton`
  plus Quickshell `Singleton`. Use `qs.core`, `qs.components`, `qs.services`, and
  `qs.modules.island`; Quickshell generates import/singleton metadata. Do not add
  source `qmldir` files or commit generated `.qmlls.ini` paths.
- Use PascalCase filenames, descriptive camelCase properties and `id: root` where
  useful. Prefer explicit types, required inputs, readonly derived state, bindings,
  and intentional aliases. Do not overwrite derived bindings imperatively.
- SpotifyService owns selection, metadata, playback/capability state and guarded
  native commands. `_selectedPlayer` is deliberate mutable state for sticky
  selection. Never select the first arbitrary MPRIS player or use browser metadata.
- Keep the minute clock local to DateTimeHeader. This replaces DateTimeNotch so
  one independent Notch surface can grow around header and music. Shared visuals
  (artwork, ring, timeline, buttons/text) must not import Spotify or MPRIS.
- ExpandedMusicPanel receives explicit data/capabilities and emits action signals.
  Island routes commands to SpotifyService. The panel has exactly three controls:
  Previous, Play/Pause, Next. The service retains native stop() without a button.
  Recheck capabilities in service methods even when the button is disabled.
  Controls use IconButton/PlaybackIcon local vectors with accessible action names;
  glyphs represent the action, including white pause. IconButton overrides the
  TextButton surface with a transparent Item in every state; animate glyph opacity
  for feedback. Use a centered Row of three equally spaced buttons; no old Stop
  slot/spacer. Play/Pause stays on the panel centerline; preserve 38px hit areas.
- Use SharedText and Theme.effectiveFontFamily for all text. Sharphy is the
  configured preference, with Noto Sans fallback and optional Theme.fontSource
  loaded by FontLoader. Editable text uses SharedTextField with the same font.
  Do not download substitute fonts. Confirm font metadata
  and report when Sharphy is absent. TextButton also uses the shared typography.
- Notch owns vector geometry/content space. NotchContour is the single contour
  definition for fill/media clipping and the open outline. Include shoulders in
  bounds; separate spread/depth and interpolate compact/expanded geometry with
  reveal. Keep smooth cubic tangents and the curve renderer. The minimum is 42px:
  the old height was reduced once by 2px, without also subtracting from padding.
- Keep the window at y=0 and center ONLY the notch on the selected screen. Widget
  widths must never affect its center. Preserve independent notch/widgets sizing
  and Config.widgetsTopInset. Do not use a visual scale transform for sizing.
- Keep IslandWindow's transparent canvas at the FINAL expanded height. Per-frame
  Wayland surface resizing caused measured 0.9–1.1s opens on Niri. Animate only
  local visuals/input regions; unused canvas remains click-through. The passive
  ScreenFrameWindow is static, with an empty mask. Its outer path joins Notch's
  local open contour at fixed endpoints; no top line crosses the notch. Inset
  centerlines by half the stroke width to keep the full frame visible. Never bind
  the outer frame/opening span to reveal. Compact pill gap is measured from the
  body, excluding shoulder tips; check its rounded upper edge for overlap.
  ScreenFrameContour shares the rounded desktop opening between the opaque black
  fill and colored outline. Outer corners stay square/flush; screenFrameInnerRadius
  rounds the inner opening. Offset the stroke into the black fill with matching
  corner centers/inner edges. Check all four black silhouettes with the outline
  hidden; tinted corner strokes alone do not round the opaque fill.
- Island.activePanel (empty/music/todo) is the interaction source of truth;
  expanded is derived. _closingPanel only retains content during closing. Its reveal animation
  drives notch size and a SINGLE migrating SpotifyWidget. Preserve declarative,
  reversible transitions; avoid timer-driven animation sequences and duplicate
  media items. Keep the header visible; disable hidden/transitioning controls.
  Fade content with the final part of reveal, not an extra sequential animation.
- Keep the canvas at the maximum music/to-do height and frame opening at the
  maximum width, independent of activePanel. Animate local surface dimensions on
  panel switches. The Spotify item still migrates once; the checklist always
  remains available. Preserve existing tuned Theme/Config values; add new tokens.
- TaskStore owns versioned JSON, stable IDs, validation and persistence under
  Quickshell.dataDir. UI passes IDs, never filtered indexes. Gate edits on ready.
  Its native ListModel is canonical; mutate affected roles/rows without replacing
  the model. Maintain the active count with commits. Snapshot into plain JS objects
  before JSON.stringify: direct QML list<var> serialization caused a measured 4.6s
  stall with 1,000 tasks. Defer/coalesce serialization using Qt.callLater.
  Serialize async atomic FileView writes with at most one in flight; coalesce
  pending changes. Handle identical text (no saved signal), and reread FileView's
  cached disk text before retrying failed saves without replacing pending tasks.
  Never overwrite invalid/unsupported task files; show errors and an explicit Retry.
- TodoPanel coordinates filters/edit draft/Escape; TodoTaskRow emits ID-scoped
  actions. Use the native SortFilterProxyModel/ValueFilter supported by Qt 6.12
  (technology preview; recheck on upgrades). Keep the header, full-width quick
  input, filters and status fixed around the bounded, reusable ListView. Incubate
  the list asynchronously after the first opening, then retain it. Row height and
  panel height have fixed theme owners, independent of text/row measurements.
  Keep checkbox/actions in fixed columns; editor and elided title share a flexible
  column. Load only the edited row's field and hovered elided title's tooltip;
  release editors on pooling, retaining draft/ID in TodoPanel. Completed text is
  gray and struck through with a purple checkmark. Cancel edits before Escape
  dismissal. Prefer todo* semantic color/sizing tokens over music colors.
  todoContentWidth is preferred; cap the full surface, including shoulders, to
  the screen minus todoScreenMargin. Preserve existing music/notch tuning.
- Every enabled button inherits a nonblocking pointing-hand HoverHandler from
  TextButton, including IconButton. Custom triggers must set the same cursor.
  SharedTextField keeps an I-beam; PlaybackTimeline keeps its horizontal drag
  cursor. Hover handlers must not steal clicks, selection or drag grabs.
- Only To-do requests WlrKeyboardFocus.OnDemand; release with None on close or
  music switch. No Exclusive focus. Niri requires a text-field click to focus the
  native window after opening; QML forceActiveFocus selects the editor within it.
- Keep one periodic 1Hz progress Timer in Island for both presentation states,
  stopped when hidden/paused/unsupported. Quickshell position/length are seconds.
  Emit documented positionChanged() for local extrapolation; no command/D-Bus
  polling. The scoped 80ms graph timer is separate; never add hover exit timers.
- Click opens; hover never dismisses. OutsideClickCatcher is a temporary transparent
  Top-layer window below the Overlay-layer interactive panel, on the same screen.
  Consume the first complete outside click, then unmap immediately on closing.
  Wait for release so the compositor's pointer grab ends before unmapping.
  Use a passive TapHandler (DragThreshold) in the catcher: exclusive MouseArea
  grabs are canceled when the OnDemand editor deactivates, losing its first click.
  Inside controls do not dismiss. A timeline pointer grab owns release outside,
  so it completes the seek without closing. Guard commits by player/track key.
- Use implicit sizes and Row for content placement; do not mix competing anchors
  with layout ownership. Avoid parent/child measurement loops. Empty WidgetsPill
  collapses to zero width; binding its visibility to row size creates feedback.
  Ordinary children after spotifySlot extend it and remain present on expansion.
- Window input regions follow the animated visible interaction geometry: compact
  artwork circle or expanded rounded solid body. Keep transparent gaps, shoulder
  cutouts and the unused strip click-through. Add corresponding regions for new
  interactive widgets. The only intentional full-screen input surface is the
  catcher while open. Preserve the keyboard policy above and no work reservation.
  Todo hit coordinates must bind to explicit ancestor/Row coordinates: a plain
  mapToItem() call does not track animated ancestor geometry for native masks.
- Preserve true circular clipping via ClippingRectangle, async image loading and
  a stable decoded image size during movement. A normal rounded Rectangle with
  clip:true does not clip circularly. Rings handle zero, one and invalid values.
- Notch fills its contour with the layered backdrop texture via ShapePath
  fillItem; share the geometry with the low-opacity frame. Background Image opacity
  is 0.40, graph opacity 0.20. No unclipped rectangular media behind the silhouette.
  MPRIS exposes artwork, not a playable Spotify video; do not scrape or guess URLs.
- MusicBackdrop composes media/scrim/graph. SpotifyAudioMonitor tracks only bound
  Spotify playback streams (Quickshell marks them isSink), never a mic/desktop mix.
  Reject unknown/empty channel maps before capture to avoid native monitor errors.
  Prefer real native peaks, otherwise explicitly label the equalizer decorative.
  Capture/graph updates stop on close/pause; the backdrop loader unloads at collapse.
  Keep the faint halo local and behind the artwork/ring, with room for its blur.
  Keep the black top gradient bounded to the header. Anchor the graph baseline to
  the panel bottom; the shared silhouette clips it to the lower rounded corners.
- Pause is exactly MprisPlaybackState.Paused, never !playing. Artwork gets the
  clipped black 0.30 overlay; its ready image stays at opacity 1. Pause bars are
  white #FFFFFF, the ring remains outside dimming, and accentPrimary is exactly
  #9D00FF. Other foregrounds use semantic purple roles; surfaces stay black and
  song art retains its colors. No icon fonts or emoji dependencies.
- Keep visual/animation tokens in Theme and preferences in Config. Keep new code
  proportional to the project; avoid widget registries or speculative frameworks.
- Bootstrap with `touch .qmlls.ini` and `quickshell --path .`. Validate QML edits
  with `scripts/check-qml.sh --format`, `scripts/check-qml.sh`, and
  `bash -n scripts/check-qml.sh`. Existing Qt metadata warning categories are documented
  in README; investigate new ones and pair static checks with runtime loading.
- Runtime: `quickshell --path . --no-duplicate --no-color`. Follow README's pointer,
  geometry, font, playback, drag, mask and reload checklist. Use isolated MPRIS
  fixtures to avoid disturbing the user's playback. Distinguish Qt event/fixture
  results from physical compositor routing and native Spotify checks.
