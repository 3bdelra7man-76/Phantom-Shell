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
- Island.activePanel (empty/music/calendar) is the interaction source of truth.
  Only music expands the notch; CalendarWindow is a separate centered surface on
  IslandWindow's screen. CalendarOpen is derived; never add a second independent
  open flag or a standalone checklist/task store. One reveal still drives the
  notch and SINGLE migrating SpotifyWidget. Preserve reversible bindings and tuned
  music/geometry/timing. Hidden or transitioning controls must not accept input.
  The fixed canvas/frame opening is sized for music only, independent of activePanel.
- CalendarWindow owns centered sizing (70% width / 45% height, bounded by screen
  margins), rounded input mask, local fade and OnDemand keyboard policy. Keep the
  window's native dimensions fixed during fades. CalendarPanel owns selected date,
  month navigation and editor coordination; its month is derived from selection.
  At small sizes stack grid/details and scroll content; header/status remain fixed.
  Give layout dimensions one owner; never measure parent height from children
  whose height refers back to the parent, including transient responsive changes.
- CalendarStore owns native goal/task models, stable IDs, strict validation and
  versioned calendar.json under Quickshell.dataDir. Tasks belong to goal ID + local
  YYYY-MM-DD date. Gate edits on ready. Use plain JS snapshots for JSON; direct
  QML list<var> serialization previously caused a 4.6s stall with 1,000 tasks.
  Defer/coalesce writes with Qt.callLater; serialize async atomic FileView writes
  with at most one in flight. Handle identical text (no saved signal), and reread
  FileView's disk cache before retrying saves without replacing pending data.
  Never overwrite invalid/unsupported files; show errors and explicit Retry.
  The legacy tasks.json file is left untouched; there is no implicit migration.
- CalendarDates.js owns strict civil-date parsing, noon-based local day arithmetic,
  UTC ordinals and inclusive 1–30 day ranges. Never parse ISO keys as UTC timestamps
  or advance by 24-hour milliseconds. MonthGrid always has 42 Monday-first cells.
  Pack weekly bands deterministically by start/ID; compact lanes between weeks.
  Today/selection remain distinct above colored bands. Overflow must never hide
  goals from the selected-day agenda.
- GoalEditor holds a mutable draft, shows inclusive end-date preview and lists
  excluded tasks/dates before destructive range edits. CalendarStore requires the
  exact reviewed task signature, rejecting stale confirmations. Keep Save visible
  outside scrolling fields. Goal deletion explicitly includes all that goal's tasks.
- DayAgenda uses a bounded reusable ListView with lightweight heterogeneous rows;
  editing/add drafts use goal/task IDs, never view indexes. Pooling releases row
  editors; scrolling must never attach a draft to another task. CalendarTaskRow
  uses a lazy editor/full-title tooltip, fixed checkbox/action columns and flexible
  elided text. Completed text is gray/struck through with a purple checkmark.
  Escape cancels an active editor first, then dismisses the calendar.
- Every enabled button inherits a nonblocking pointing-hand HoverHandler from
  TextButton, including IconButton. Custom triggers must set the same cursor.
  SharedTextField keeps an I-beam; PlaybackTimeline keeps its horizontal drag
  cursor. Hover handlers must not steal clicks, selection or drag grabs.
- Only CalendarWindow requests WlrKeyboardFocus.OnDemand; release with None on
  close or music switch. No Exclusive focus. On Niri click inside the calendar to
  focus its native window; QML forceActiveFocus selects the editor within it.
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
  Calendar trigger hit coordinates must bind to explicit ancestor/Row coordinates: a plain
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
  `bash -n scripts/check-qml.sh`. Run pure date tests with
  `QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME= /usr/lib/qt6/bin/qmltestrunner -input tests`. Existing Qt metadata warning categories are documented
  in README; investigate new ones and pair static checks with runtime loading.
- Runtime: `quickshell --path . --no-duplicate --no-color`. Follow README's pointer,
  geometry, font, playback, drag, mask and reload checklist. Use isolated MPRIS
  fixtures to avoid disturbing the user's playback. Distinguish Qt event/fixture
  results from physical compositor routing and native Spotify checks.
