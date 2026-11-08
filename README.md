# QP

A personal Quickshell notch with a local date/time header and a compact Spotify
artwork pill. Click the artwork to move that same music presentation into an
expanded, centered notch with metadata, seeking, and playback controls. Leaving
the panel collapses it. The notch stays attached to the screen's top edge and
centered independently of any widgets to its right.

## Run

Supported reference environment: **Quickshell 0.3.2 / Qt 6.12.0**, Arch Linux,
Niri on Wayland. The compositor needs the Wayland layer-shell protocol. Runtime
imports use Qt Quick, Qt Quick Shapes, Qt Quick Templates, Quickshell Widgets,
and Quickshell's native MPRIS service. Install matching distribution packages
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
clock, metadata, timeline labels, and button labels. It uses
`Theme.effectiveFontFamily`, plain text, and tabular numerals where supported.
Text buttons also inherit this typography. Add future text through `SharedText`.
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
| `components/Notch.qml` | Black vector surface with concave shoulders and rounded bottom corners |
| `components/Pill.qml` | Rounded content surface with configurable padding/minimum height |
| `components/SharedText.qml` | Shared typography and plain-text defaults |
| `components/TextButton.qml` | Pointer button with shared text and hover/pressed feedback |
| `components/CircularArtwork.qml` | Asynchronous circular image, fallback, optional paused presentation |
| `components/CircularProgress.qml` | Clamped normalized progress ring, independent of Spotify |
| `components/PlaybackTimeline.qml` | Position display, elapsed/total labels and drag preview/seek request |
| `modules/island/IslandWindow.qml` | Screen, window flags and animated input regions |
| `modules/island/Island.qml` | Expansion state, geometry, hover coordination, service wiring and one refresh timer |
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

The window is a shallow, full-width transparent layer-shell surface with no top
margin, no work-area reservation and no keyboard focus. It centers only the
notch. `Config.screenName: ""` uses the platform default; set an output name such
as `"eDP-1"` to prefer it. A missing output falls back to the default screen.

Main appearance tokens in `Theme.qml`:

| Tokens | Default / purpose |
| --- | --- |
| `accentPrimary`, `progressAccent` | Exact `#9D00FF` active accent |
| `accentForeground`, `accentSecondary`, `accentMuted` | Readable lighter purple, secondary purple and subdued ring track |
| `surfaceBackground` | Pure black surfaces |
| `pauseIcon`, `pausedOverlayOpacity` | White `#FFFFFF` bars over a black overlay at 0.30 opacity |
| `notchHeight` | 42 pixels, reduced once from 44: one pixel less above/below the same text |
| `notchHorizontalPadding`, `notchVerticalPadding` | 18 / 6; vertical padding remains a minimum for larger font metrics |
| `notchShoulderWidth`, `notchShoulderHeight` | 26 / 14; horizontal spread is independent of depth and notch height |
| `notchShoulderCurve`, `notchBottomRadius` | 0.55 tangent control / 12-pixel lower corner radius |
| `notchWidgetsGap` | 8 pixels after the outer shoulder |
| `widgetsPillHeight`, `artworkDiameter` | Existing compact sizes: 38 / 30 pixels |
| `widgetsHorizontalPadding`, `widgetsVerticalPadding` | 5 / 4 |
| `musicContentWidth`, `musicPadding` | 360 / 20; expanded width includes padding and both shoulders |
| `musicArtworkDiameter`, `musicArtworkDecodedSize` | 72 logical pixels / 216 decoded pixels |
| `musicTopGap`, `musicSectionGap`, `musicBottomPadding` | Expanded vertical spacing |
| `control*`, `timeline*` | Button, timeline, thumb and spacing dimensions |
| `transitionDuration`, `contentFadeDuration`, `contentExitDuration` | 260 / 90 / 40 ms |
| `openingGraceDuration`, `pointerExitDelay` | 400 / 120 ms pointer handoff and cancellable exit delay |

`Config.widgetsTopInset` is 2 pixels, balancing the unchanged 38-pixel pill
against the shorter notch. Sizes are logical pixels; no visual scale transform
shrinks the interface. Cubic shoulder curves have horizontal top tangents and
vertical side tangents; their full spread is inside the notch's bounds. The Qt
curve renderer preserves antialiasing at fractional scaling.

## Expansion and input

Click the compact artwork/ring to open. Hover alone does not open the panel.
`Island.expanded` is the single state flag. A bound, interruptible `reveal` value
animates the notch size, media position/size, and the disappearing Spotify slot.
The notch stays centered throughout. Its date/time header remains visible.
Other widgets keep their pill when Spotify moves into the notch.

Once geometry settles, music controls fade in over 90 ms, making the full opening
about 350 ms. Closing fades controls out promptly while geometry reverses from
its current position. Hidden or transitioning controls are disabled. Artwork
has a constant decode size during movement, avoiding per-frame image reloads.

One non-blocking parent `HoverHandler` observes the solid panel body, including
all child controls. Entry cancels pending closure. A short opening grace allows
movement from the original trigger; entering the panel ends that grace early.
An exit delay is cancellable on re-entry. A timeline drag defers exit until
release. Spotify disappearing closes the panel safely; hot reload resets it to
the compact state.

The input mask follows the animated layout. Collapsed input is limited to the
artwork circle; the date/time notch and pill padding remain display-only.
Expanded input covers the solid body with rounded bottom corners. Decorative
shoulders, their transparent cutouts, gaps and the unused full-width strip pass
input through. This keeps pointer controls usable without an invisible screen
sized input blocker. Keyboard focus and desktop work-area reservation remain
disabled.

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
commands. Playback changes also refresh the final frozen position. The two
single-shot pointer timers do not refresh progress.

The timeline freezes its local preview while dragging, then sends one seek on
release and resumes following playback. A track/player key prevents an old drag
from seeking a replacement track. Releasing outside defers collapse until the
drag finishes. Missing duration shows `--:--`; unavailable seeking dims the thumb.

Previous, Play/Pause, Stop and Next call guarded service methods. Previous/next,
toggle and seeking check the player's advertised capabilities and `CanControl`.
MPRIS has no `CanStop`; Stop is governed by `CanControl` and invokes the actual
native `stop()` action. Disabling a control also prevents its command in the
service, rather than relying on appearance alone.

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
common Qt 6 binary directories; set `QT_BIN_DIR` when needed. The two known Qt
metadata warnings remain visible: `PanelWindow` marked uncreatable and the
MPRIS model's `values` member unresolved. Both APIs run in the supported runtime.
Investigate additional warnings and always pair static checks with a live load.

Verification uses the native Niri session plus isolated MPRIS fixtures and Qt
pointer events, avoiding changes to the user's actual Spotify playback. Checks
cover font fallback/layout, geometry/centering, click versus hover opening,
movement between controls, exit/re-entry, drag preview and release outside,
capability guards and real native action names, interruption/reversal, Spotify
removal, and one periodic refresh timer after repeated hot reloads. The updated
panel was also rendered at 125% scale: text fit, metadata elision, geometry and
centering passed. Wayland tracing confirmed bounded circle/body input regions
through animation, no committed unbounded region, no keyboard focus and no
work-area reservation. No QML errors or binding loops were observed.

Useful manual checks for later changes:

1. Inspect the shorter top-edge notch and both wide concave shoulders at your
   display scale. Confirm date/time stays centered when Spotify appears or closes.
2. Hover over the artwork without clicking, then click and move into the panel.
   Check its header, artwork, metadata and every control without premature closure.
3. Play, pause, stop, seek and change tracks. Check the white pause bars, 30% dimming,
   purple ring, stable dragging and disabled capabilities.
4. Leave/re-enter quickly, leave during expansion, and release a drag outside.
   Check that collapse restores the compact layout and hover does not reopen it.
5. Close Spotify during expansion and reload repeatedly while playing.
6. Click through transparent gaps/cutouts to a known window behind the overlay;
   confirm no keyboard focus or work-area changes.

Sharphy rendering cannot be verified until its font is installed or supplied.
Physical compositor pointer routing, multiple-output hotplug, X11, suspend/timezone
changes, and native Spotify control transitions still need user-session checks;
Qt pointer events and isolated players verify the corresponding application logic.

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
[HoverHandler](https://doc.qt.io/qt-6.12/qml-qtquick-hoverhandler.html).
