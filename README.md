# QP

A personal Quickshell notch with a local date/time header and a compact Spotify
artwork pill. Click the artwork to move that same music presentation into an
expanded, centered notch with metadata, seeking, icon controls and an artwork
backdrop and a passive screen frame. Moving the pointer away leaves it open; clicking outside closes it.
The notch stays attached to the screen's top edge and centered independently of
any widgets to its right.

## Run

Supported reference environment: **Quickshell 0.3.2 / Qt 6.12.0**, Arch Linux,
Niri on Wayland. The compositor needs the Wayland layer-shell protocol. Runtime
imports use Qt Quick (Shapes, Templates and Effects), Quickshell Widgets,
and native MPRIS/PipeWire services. Install matching distribution packages
yourself; this project does not install packages or change compositor/autostart
settings. A session D-Bus and the desktop Spotify client enable music features.

From this directory:

```sh
quickshell --path .
```

From anywhere, for this checkout:

```sh
quickshell --path /home/phantom/QP
```

`qs` is also the installed Quickshell command. Add `--no-duplicate` to avoid a
second instance of this configuration. QML changes reload automatically. Ctrl+C
stops a foreground instance; from another terminal use
`quickshell kill --path /home/phantom/QP` to stop only QP.

To register this checkout as a named configuration, run the following from its
root after ensuring the destination does not already exist:

```sh
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/quickshell"
ln -s "$PWD" "${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/qp"
quickshell --config qp
```

Copying the complete project into that `qp` directory also works. A top-level
`quickshell/shell.qml` makes Quickshell ignore named subdirectories; use `--path`
in that case. Runtime operation needs no `playerctl`, web credentials, Python,
Node, or command polling.

## Typography

The preferred family is **Sharphy**, centralized in `Theme.fontFamily`.
Installed font metadata was checked: Sharphy is **not installed in the tested
environment**, and no font file was supplied in the project. QP uses the installed
`Noto Sans` fallback until Sharphy is available; no replacement was downloaded.
Actual Sharphy metrics and clipping therefore still need checking after install.

Install a licensed copy yourself and check its family metadata, for example:

```sh
fc-scan --format '%{family}\n' /path/to/your/font.otf
fc-list : family | sort -u
```

Set `Theme.fontFamily` to the reported family if it differs from `Sharphy`, then
restart QP. For a font kept inside the project, set `Theme.fontSource` in
`core/Theme.qml`, for example `Qt.resolvedUrl("../assets/fonts/Sharphy.otf")`.
The existing `FontLoader` loads that portable URL and uses its actual family
name. Keep any font's license with the file. An empty URL uses installed fonts.

All text goes through `components/SharedText.qml`, including artwork fallback,
clock, metadata, timeline labels, and future text button labels. It uses
`Theme.effectiveFontFamily`, plain text, and tabular numerals where supported.
Icon controls use local vector paths and accessible action names; text buttons
also inherit this typography. Add future text through `SharedText`.
The header keeps the existing 12-pixel date and 14-pixel time; metadata uses
16/12 pixels and timeline labels 11 pixels. Long metadata is elided on one line.

## Architecture

Start with `shell.qml`, `modules/island/Island.qml`, and `core/Theme.qml`.

| File | Responsibility |
| --- | --- |
| `shell.qml` | One island window |
| `core/Config.qml` | Date/time formats, output preference, widget inset, refresh interval |
| `core/Theme.qml` | Typography/font loading, colors, geometry and animation tokens |
| `services/SpotifyService.qml` | Discovery, stable selection, metadata, capabilities and guarded native commands |
| `services/SpotifyAudioMonitor.qml` | Scoped native peak capture from a strictly identified Spotify output stream |
| `components/Notch.qml`, `NotchContour.qml` | Shared contour for black base, clipped textured fill and open notch outline |
| `components/Pill.qml` | Rounded content surface with configurable padding/minimum height |
| `components/SharedText.qml` | Shared typography and plain-text defaults |
| `components/TextButton.qml` | Shared button surface, disabled and animated hover/pressed styling |
| `components/IconButton.qml`, `PlaybackIcon.qml` | Three floating, accessible playback icons; transparent hit areas |
| `components/MusicGraph.qml` | Low-profile peak-history or decorative graph, independent of Spotify |
| `components/CircularArtwork.qml` | Asynchronous circular image, fallback, optional paused presentation |
| `components/CircularProgress.qml` | Clamped normalized progress ring, independent of Spotify |
| `components/PlaybackTimeline.qml` | Position display, elapsed/total labels and drag preview/seek request |
| `modules/island/IslandWindow.qml` | Screen, fixed-size transparent canvas and animated input regions |
| `modules/island/ScreenFrameWindow.qml` | Static, passive outer screen frame, with an opening for the local notch contour |
| `modules/island/Island.qml` | Expansion state, geometry, service wiring, local glow and one progress refresh timer |
| `modules/island/OutsideClickCatcher.qml` | Temporary screen-local outside-click dismissal below the interactive overlay |
| `modules/island/MusicBackdrop.qml` | Artwork/scrim/graph composition supplied to the notch texture fill |
| `modules/island/DateTimeHeader.qml` | Local minute-precision clock and date/time row |
| `modules/island/WidgetsPill.qml` | Extensible horizontal container for visible widgets |
| `modules/island/SpotifyWidget.qml` | One artwork/ring presentation used in both states |
| `modules/island/ExpandedMusicPanel.qml` | Metadata, timeline and control layout with explicit inputs/signals |

The former `DateTimeNotch.qml` became `DateTimeHeader.qml`: the clock stays local
to its feature while one separate `Notch` surface can grow around both header
and music. Reusable artwork, ring, timeline and button components do not import
Spotify or MPRIS. `Island` supplies their data and routes action signals to the
service. There is one Spotify service and one artwork/ring item, not two copies
crossfading between locations.

## Appearance and placement

`Config.timeFormat` defaults to `HH:mm`; `dateFormat` to `ddd, d MMM`. Both use
local Qt date/time formatting. The clock updates once per minute; displaying
seconds would require changing its precision too.

The main window is a full-width transparent layer-shell canvas with a fixed
height large enough for the expanded panel. Only its visible interaction regions
receive input; unused canvas passes through. It has no top margin, work-area
reservation or keyboard focus. It centers only the notch. A second, passive
window draws the static screen frame with an empty input region.
`Config.screenName: ""` uses the platform default; set an output name such
as `"eDP-1"` to prefer it. A missing output falls back to the default screen.

Main appearance tokens in `Theme.qml`:

| Tokens | Default / purpose |
| --- | --- |
| `accentPrimary`, `progressAccent` | Exact `#9D00FF` active accent |
| `accentForeground`, `accentSecondary`, `accentMuted` | Readable lighter purple, secondary purple and subdued ring track |
| `surfaceBackground` | Pure black surfaces |
| `pauseIcon`, `pausedOverlayOpacity` | White `#FFFFFF` bars over a black overlay at 0.30 opacity |
| `notchHeight` | 42 pixels, reduced once from 44: one pixel less above/below the same text |
| `notchHorizontalPadding`, `notchVerticalPadding` | 22 / 6; vertical padding remains a minimum for larger font metrics |
| `notchShoulderWidth`, `notchShoulderHeight` | 36 / 14; horizontal spread is independent of depth and notch height |
| `notchShoulderCurve`, `notchBottomRadius` | 0.55 tangent control / 18-pixel lower corner radius |
| `musicShoulderWidth`, `musicShoulderHeight`, `musicShoulderCurve` | 76 / 28 / 0.62 expanded shoulder geometry, blended from the compact values |
| `notchWidgetsGap` | 2.5 pixels from the compact body edge, excluding the top shoulder tip |
| `screenFrameWidth`, `screenFrameColor`, `screenFrameOpacity` | 2 pixels, clock-text color, 0.15 opacity |
| `widgetsPillHeight`, `artworkDiameter` | Existing compact sizes: 38 / 30 pixels |
| `widgetsHorizontalPadding`, `widgetsVerticalPadding` | 5 / 4 |
| `musicContentWidth`, `musicPadding` | 360 / 20; expanded width includes padding and both shoulders |
| `musicArtworkDiameter`, `musicArtworkDecodedSize` | 72 logical pixels / 216 decoded pixels |
| `musicTopGap`, `musicSectionGap`, `musicBottomPadding` | Expanded vertical spacing |
| `controlIconButtonSize`, `controlIconSize` | 38-pixel hit area / 20-pixel vector grid |
| `control*`, `timeline*` | Button, timeline, thumb and spacing dimensions; glyph idle/pressed opacity 0.85 / 0.60 |
| `backgroundArtworkOpacity`, `backgroundDecodedSize`, `backgroundScrimOpacity` | 0.40 / 1024 pixels / 0.12 |
| `headerShadowOpacity`, `headerShadowExtraHeight` | 0.85 top black gradient, fading out 8 pixels below the header area |
| `graphOpacity`, `graphBarCount`, `graphHeight`, `graphUpdateInterval` | 0.20 / 32 / 54 pixels / 80 ms; baseline flush with the lower contour |
| `artworkGlowOpacity`, `artworkGlowBlur`, `artworkGlowSpread` | 0.18 / 12 / 1, fading with expansion |
| `transitionDuration`, `contentRevealStart` | 240 ms; controls fade with the final 35% of the same reveal coordinate |

`Config.widgetsTopInset` is 2 pixels, balancing the unchanged 38-pixel pill
against the shorter notch. Sizes are logical pixels; no visual scale transform
shrinks the interface. Cubic shoulder curves have horizontal top tangents and
vertical side tangents; their full spread is inside the notch's bounds. The Qt
curve renderer preserves antialiasing at fractional scaling. Compact pill
placement uses the body edge: the rounded pill top clears the shoulder, with a
visible gap.

The frame is one continuous visual outline: static side/bottom edges and outer
top segments join the animated local notch contour. It sweeps down one shoulder,
around the body, and back up the other; no horizontal border crosses the notch.
`NotchContour` defines both the fill/clip path and this outline. Stroke centerlines
are inset by half their width so the entire 2-pixel frame stays on-screen. The
same join coordinates are used by both windows, including at fractional scales.
The black surface still reaches y=0 above that inset centerline.

## Expansion and input

Click the compact artwork/ring to open. Hover alone does not open the panel.
`Island.expanded` is the single state flag. A bound, interruptible `reveal` value
animates the notch size, media position/size, and the disappearing Spotify slot.
The notch stays centered throughout. Its date/time header remains visible.
Other widgets keep their pill when Spotify moves into the notch.

Geometry and control opacity share one 240 ms transition. Controls fade in during
the final part of expansion and are enabled only when fully open. Closing reverses
from the current reveal value and disables controls immediately. The compact
shoulders blend into a wider, deeper expanded contour. Artwork keeps a constant
decode size during movement, avoiding per-frame image reloads.

Moving outside does not dismiss. Click an icon to operate a control; the play/pause
glyph shows the action it will perform. Every button has an accessible action
name and the existing 38-pixel hit area. There are exactly three controls:
Previous, Play/Pause, Next. The removed Stop slot remains empty so the surviving
icons retain their previous positions. All backgrounds stay transparent; glyph
color/opacity supplies hover and pressed feedback. Disabled controls fade to a
muted state. Pause glyphs remain white, including when the action changes.

The main window uses the Wayland **Overlay** layer with bounded animated input
regions. A transparent **Top**-layer catcher is mapped below it only while the
panel is open, on the same screen. Inside clicks reach the panel; an outside
click completes on the catcher and begins collapse. **The first outside click
is consumed by dismissal.** Waiting for its release ends the compositor's
pointer grab cleanly. The catcher unmaps as collapse begins, so the next click
can reach the desktop normally. Other outputs are not covered. No keyboard focus
or desktop work-area reservation is taken by either window.

The timeline's normal pointer grab owns a drag that began inside the panel,
including release outside. That release seeks and leaves the panel open; it is
not a new outside click. A fresh outside click dismisses afterward. There are no
hover exit or opening grace timers. Repeated open/close requests reverse the
same bound animation. Spotify disappearance closes safely, and reload resets to
the compact state.

## Background, graph and glow

The existing MPRIS integration exposes cover artwork but **no supported playable
Spotify video/Canvas URL**. QP uses current-track artwork; it does not interpret
Spotify track/web URIs as video, scrape media, or add a login. There is no video
player/resource to leave running after close.

An asynchronous, proportionally cropped image fills the expanded notch at
**0.40 opacity** above its black base. A light black scrim (0.12) keeps text
readable. Missing/loading/failed artwork leaves the black base. Track URL changes
update the background. `Notch` uses Qt 6.12 `ShapePath.fillItem` with a hidden
`ShaderEffectSource`: the fill is clipped to the exact shoulder and lower-corner
path during both transitions. The shared contour also draws the frame's local
outline. A bounded black gradient darkens the top edge and fades to transparent
just below the clock/header; the rest keeps the existing artwork opacity.
A loader unloads the backdrop and its audio monitor after collapse; capture and
graph updates stop immediately when closing begins.

The graph is **0.20 opacity**, anchored against the very bottom of the panel and
clipped by its rounded lower contour, behind the timeline and icons. When available,
`PwNodePeakMonitor` captures a native Spotify playback stream (identified by its
bound application/binary properties, with a track-name preference). The display
is a rolling **amplitude peak history**, not a frequency spectrum. It never
monitors the desktop mix or microphone. With multiple matching streams it uses
the track match, then the lowest node ID. Tracker/monitor resources are scoped
to the open panel; paused playback disables capture and leaves the graph at rest.

If a matching stream, supported channel map, or peak samples are unavailable,
a lightweight **decorative equalizer** animates while playing. Streams reporting
unknown channel positions are rejected before capture to avoid repeated native
monitor errors. Its sine-based movement is not measured
beats or frequencies. There is one modest 80 ms graph timer, distinct from the
1 Hz position timer, and neither runs continuously while closed. No Cava process
or audio-command polling is required.

A local `RectangularShadow` with circular radius makes the faint purple halo
behind the expanded artwork. It fades with the existing expansion coordinate;
padding leaves room for its blur. The crisp `#9D00FF` ring, white pause glyph and
30% artwork shade remain separate from the halo.

## Animation performance

The slow opening was reproduced on the native Niri session before tuning timing.
A temporary fixture recorded wall-clock geometry/control completion and Qt frame
intervals, with `qt.scenegraph.time.renderloop` diagnostics. A nominal 260 ms
geometry animation took roughly **860–1133 ms** on repeated openings, with
40–100 ms frame gaps. Turning off the backdrop/glow left it slow; fixing the
Wayland window at its expanded height reduced geometry completion to **274–281
ms**, while preserving media. This isolated per-frame surface resizing as the
main bottleneck. The configure/commit synchronization is the likely cause of
the stalls; Qt reported little actual rendering work, and removing media had
little effect.

The window now keeps that fixed transparent canvas and changes only the local
visuals/input regions. The static outer frame is a separate passive surface;
only its small central contour animates. Glow stays local to the circle, the top
gradient stays within the header, and the existing scoped graph cadence remains.
After this fix, the reveal duration was set to 240 ms and the extra sequential
90 ms control fade removed. Measured first/repeated openings reached geometry
**and controls in 254–268 ms**, with frame intervals mostly 5–7 ms (maximum 11 ms
in that run). These are local fixture measurements, not a universal frame-rate
guarantee.

For later diagnosis, enable Qt's supported scene-graph timings:

```sh
QSG_RENDER_TIMING=1 quickshell --path . --no-duplicate --no-color \
  --log-rules 'qt.scenegraph.time.renderloop=true'
```

Do not animate the layer-shell surface height or the outer frame with `reveal`.
Use temporary frame instrumentation for profiling; keep frame loops out of the
runtime project. Continue distinguishing rendering time from compositor waits.

## Spotify, timeline and commands

Discovery requires a native `org.mpris.MediaPlayer2.spotify` service name
(including instance suffixes) plus Spotify identity/desktop information. Browser
metadata cannot qualify. Selection prefers playing instances and retains the
current instance within that tier; new ties are ordered by bus name.

The service exposes title, artist, artwork, playback state, track key and
capabilities. `paused` means exactly `MprisPlaybackState.Paused`; stopped is a
different state. Paused artwork retains its image at opacity 1. A clipped black
rectangle at 0.30 opacity dims only the image/fallback, with white geometry bars
above it. The purple ring is a sibling outside the dimmed area.

Quickshell position and length are both **seconds**. Invalid or unsupported
lengths yield safe zero progress and disable seeking. One 1 Hz timer in `Island`
emits the documented `player.positionChanged()` notification only while visible,
playing and supported. It updates local extrapolation without polling D-Bus or
commands. Playback changes also refresh the final frozen position. The graph
uses its own open-panel update cadence; there are no hover dismissal timers.

The timeline freezes its local preview while dragging, then sends one seek on
release and resumes following playback. A track/player key prevents an old drag
from seeking a replacement track. Releasing outside completes the seek without dismissing the panel. Missing duration shows `--:--`; unavailable seeking dims the thumb.

The Previous, Play/Pause and Next icons call guarded service methods. Previous/next,
toggle and seeking check the player's advertised capabilities and `CanControl`.
There is no visible Stop control; the service retains its native `stop()` command
for future use. Disabled actions are guarded in the service too.

## Adding another widget

Add an ordinary QML child after `spotifySlot` inside `WidgetsPill` in `Island.qml`:

```qml
SharedText {
    text: "hello"
    anchors.verticalCenter: parent.verticalCenter
}
```

Give custom widgets sensible implicit sizes and a `visible` binding from their
feature's availability. `Row` owns horizontal positioning. Empty content collapses
the surface to zero width; do not bind the pill's visibility to its row's size,
which creates inherited-visibility feedback. Additional widgets retain their
surface when Spotify expands and never move the notch's center. For a new
interactive widget, also add its visible hit region in `IslandWindow.qml`.

## Developer checks

Use matching Qt `qmlls`, `qmllint`, and `qmlformat` tools. Bootstrap the supported
Quickshell language-server integration before launch:

```sh
touch .qmlls.ini
quickshell --path .
```

Quickshell manages `.qmlls.ini` and generates root-relative `qs.*` modules and
singleton metadata. The configuration contains machine-specific paths and is
Git-ignored. Recreate it on a fresh installation and configure your editor to run
`qmlls`. No CMake project or hand-written source `qmldir` is required.

After launching once in the current login session:

```sh
scripts/check-qml.sh --format
scripts/check-qml.sh
bash -n scripts/check-qml.sh
```

The script uses generated import paths and looks for Qt tools in `PATH` or
common Qt 6 binary directories; set `QT_BIN_DIR` when needed. Known Qt metadata
warnings remain visible for the three `PanelWindow` types (marked uncreatable)
and the MPRIS/PipeWire models' `values` members (unresolved).
Both APIs run in the supported runtime.
Investigate additional warnings and always pair static checks with a live load.

Verification uses the native Niri session, isolated MPRIS fixtures, rendered
image checks, and Qt pointer events without changing actual Spotify playback.
The native click-catcher test uses a small private receiver surface, checking
that the dismissal click is consumed and the following click reaches that
surface. The background was verified with both a fixture image and the native
Spotify track's cover URL, plus black fallback. No playable video is supplied.
The tested native Spotify stream reports unknown channel positions, so the
decorative graph was verified, including animation while playing and resting
while paused. Real peak-history rendering still needs a supported audio stream.
Rendering was checked at 100% and 125% scale. Three reloads at 125% retained one
music presentation and one progress timer, with the catcher and backdrop removed
in the collapsed state. The ordinary project launch also loaded without QML
errors; lint reports only the metadata warnings described above.

The three floating controls, bright-cover header gradient, bottom graph and
compact body gap were checked at both scales. Pixel comparisons at 125% found
no missing or doubled frame strokes at the two joins, no border across the notch
opening, and no change to the static outer frame across opening/closing. Native
pointer routing confirmed the passive frame does not block the next click after
outside dismissal. Performance measurements are recorded above.

Useful manual checks for later changes:

1. Inspect both shoulder states, lower radii, continuous screen frame and 2.5-pixel
   body-to-pill gap at your scale; confirm centering and clean joins throughout transitions.
2. Open by clicking artwork, then move away: it should remain open. Operate each
   icon and check hover, pressed, disabled and accessible action-name states.
3. Drag the timeline outside and release: it should seek and stay open. Click
   outside afterward: collapse should start, consuming that first click only.
4. Change tracks while expanded; check the cropped background, circular paused
   presentation, faint glow and unobtrusive graph. Pause and confirm the graph rests.
5. Rapidly open/close and close Spotify during expansion. Check capture/graph
   updates stop on closing and backdrop resources unload after the transition.
6. Repeat reloads and run the QML checks. Only the position and open-graph timers
   should repeat; no hidden catcher or duplicate media items should accumulate.

Sharphy rendering still needs its font installed or supplied. Video cannot be
verified because this integration supplies no playable video source. Native
Spotify control transitions, multiple-output hotplug and X11 remain separate
user-session checks; isolated players exercise the command/interaction logic.

## Troubleshooting

- **No music widget:** start desktop Spotify on the same session bus. Check
  `busctl --user list | rg org.mpris.MediaPlayer2`. Browser Spotify is ignored;
  sandboxed clients must expose MPRIS to the session.
- **Missing artwork:** inspect the terminal for URL/file errors; the local fallback
  and paused presentation work during loading and failure. No API key is needed.
- **Disabled timeline or controls:** check the player's capabilities and duration;
  not every player supports every MPRIS action.
- **Unexpected font:** install Sharphy or configure a licensed font URL/family as
  described above, then restart. QP intentionally falls back when it is absent.
- **Unresolved `qs.*` in your editor:** recreate `.qmlls.ini`, launch QP, and restart
  `qmlls` from the same Qt installation as Quickshell.

API references: [Quickshell 0.3.2](https://quickshell.org/docs/v0.3.2/),
[MPRIS](https://quickshell.org/docs/v0.3.2/types/Quickshell.Services.Mpris/MprisPlayer/),
[Region](https://quickshell.org/docs/v0.3.2/types/Quickshell/Region/),
[Qt 6.12 Text](https://doc.qt.io/qt-6.12/qml-qtquick-text.html),
[font](https://doc.qt.io/qt-6.12/qml-font.html),
[PathCubic](https://doc.qt.io/qt-6.12/qml-qtquick-pathcubic.html), and
[ShapePath.fillItem](https://doc.qt.io/qt-6.12/qml-qtquick-shapes-shapepath.html),
[RectangularShadow](https://doc.qt.io/qt-6.12/qml-qtquick-effects-rectangularshadow.html), and
[PwNodePeakMonitor](https://quickshell.org/docs/v0.3.2/types/Quickshell.Services.Pipewire/PwNodePeakMonitor/).
