# QP

A small, display-only Quickshell island: a black date/time notch attached to the
top edge of one screen, with a smaller Spotify artwork pill beside its right
shoulder. The notch stays centered on the screen as widgets appear, disappear,
or grow. The widget pill disappears when Spotify closes. There are no controls, popups, or expanded
states in version one.

## Runtime and launch

The supported reference environment is **Quickshell 0.3.2 with Qt 6.12.0**,
tested on Arch Linux, Niri 26.04, Wayland, and the local Spotify desktop client.
Use Quickshell and Qt packages built for each other. Older combinations and X11
have not been validated. The compositor must support the Wayland layer-shell
protocol for the intended panel behavior.

Runtime dependencies:

- Quickshell, including `Quickshell.Services.Mpris` and `Quickshell.Widgets`.
- Qt Quick and Qt Quick Shapes, normally installed with Quickshell.
- A session D-Bus and Spotify desktop for the optional Spotify widget.
- A monospace font; the system's `monospace` alias is used by default.

No `playerctl`, web credentials, scripts, or separate application server are
needed at runtime. Install system packages yourself using your distribution's
package manager; this project does not install packages or change your desktop.

From this directory:

```sh
quickshell --path .
```

From anywhere, for this checkout:

```sh
quickshell --path /home/phantom/QP
```

`qs` is also the installed Quickshell command. Add `--no-duplicate` to prevent
another copy of this configuration from starting. Use Ctrl+C to stop a foreground
instance. Edits to QML files reload automatically. Stop only this configuration
from a separate terminal with `quickshell kill --path /home/phantom/QP`.

To register a named configuration, run this from your checkout after ensuring
the destination does not already exist:

```sh
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/quickshell"
ln -s "$PWD" "${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/qp"
quickshell --config qp
```

Copying the entire project to that `qp` directory also works. Quickshell's CLI
ignores named subdirectories if a top-level `quickshell/shell.qml` exists; in that
case, use `--path` directly. Leave compositor autostart configuration for later;
no autostart or other shell configuration is modified here.

## Reading and changing the code

Start with `shell.qml`, `modules/island/Island.qml`, then `core/Config.qml` and
`core/Theme.qml`.

| Path | Responsibility |
| --- | --- |
| `shell.qml` | Minimal entry point: one island window |
| `core/Config.qml` | Date/time formats, widget top inset, screen preference, refresh interval |
| `core/Theme.qml` | Purple palette, notch geometry, independent widget sizes, padding and transitions |
| `services/SpotifyService.qml` | Native Spotify discovery, stable player selection, metadata and normalized progress |
| `components/Notch.qml` | Vector silhouette, concave shoulders, rounded bottom corners and padded content slot |
| `components/Pill.qml` | Rounded surface with an explicit content slot and configurable minimum height |
| `components/CircularArtwork.qml` | Circular asynchronous image, fallback, optional dimming and pause bars |
| `components/CircularProgress.qml` | Independent normalized progress ring |
| `modules/island/IslandWindow.qml` | Screen selection, full-width shallow transparent panel and input behavior |
| `modules/island/Island.qml` | Feature composition and service-to-widget bindings |
| `modules/island/DateTimeNotch.qml` | Notch surface with a local minute-precision clock and formatted text |
| `modules/island/WidgetsPill.qml` | Horizontal content slot for visible widgets |
| `modules/island/SpotifyWidget.qml` | Supplied artwork/progress presentation and scoped refresh timer |
| `scripts/check-qml.sh` | Development-only formatting and import-aware lint checks |

`Config.timeFormat` defaults to `HH:mm`; `Config.dateFormat` defaults to
`ddd, d MMM`. These use Qt date/time format strings and the local system time.
The clock intentionally updates once per minute, so formats containing seconds
would also require changing its precision. Monospaced text keeps time digits
from changing width.

The notch and widget pill stay black; artwork retains its original colors.
Shared accent roles in `Theme.qml` are:

| Token | Default / use |
| --- | --- |
| `accentPrimary` | `#9D00FF`, exact active progress color |
| `accentForeground` | `#D9A6FF`, readable small foregrounds and pause bars |
| `accentSecondary` | `#B87AE6`, date and fallback music glyph |
| `accentMuted` | `#3E2052`, subdued ring track |
| `textPrimary`, `textSecondary`, `progressAccent`, `progressTrack`, `pauseIcon`, `artworkGlyph` | Semantic aliases of that palette for future widgets |

Geometry and placement are independent of the generic pill defaults:

| Customization point | Default |
| --- | --- |
| `Theme.notchHeight` | 44 logical pixels |
| `Theme.notchHorizontalPadding`, `notchVerticalPadding` | 18 / 6, inside the main body |
| `Theme.notchBottomRadius`, `notchShoulderRadius` | 12 / 14 |
| `Theme.notchWidgetsGap` | 8, measured after the outer right shoulder |
| `Theme.widgetsPillHeight` | 38 |
| `Theme.widgetsHorizontalPadding`, `widgetsVerticalPadding` | 5 / 4 |
| `Theme.artworkDiameter` | 30, including the ring |
| `Theme.progressWidth`, `artworkRingGap` | 1.75 / 1.5 |
| `Config.widgetsTopInset` | 3, centering the 38-pixel pill against the 44-pixel notch |
| `Theme.pausedOverlayOpacity`, `pauseFadeDuration` | 0.30 / 120 ms |
| `Theme.pauseBarWidth`, `pauseBarHeight`, `pauseBarGap` | 2 / 10 / 3 |

These are actual layout dimensions, without visual scale transforms. Surfaces
can grow for larger text or widgets. The notch's implicit width includes both
shoulders plus its padded body. `Notch.qml` uses counterclockwise quarter-circle
arcs for the concave upper shoulders and clockwise arcs for the convex bottom
corners. The curve renderer keeps edges clean at fractional scaling. The clock
component was renamed from `DateTimePill.qml` to `DateTimeNotch.qml` to match it.

`Config.screenName: ""` uses the platform default. Set an output name such as
`"eDP-1"` to prefer it; a missing output falls back to the default. Selection and
fallback stay in the window layer. The window now anchors to the top, left, and
right edges of that screen, with zero top margin. Its height follows the content.
Inside it, `Island.qml` centers **only the notch** with a horizontal-center anchor;
the widgets anchor to the notch's right edge. Widget widths never participate in
notch positioning. The full-width transparent area uses an empty input region,
so it passes clicks through and reserves no work area. `Config.topMargin` was
removed: the notch must stay attached to the top; only the widgets have an inset.

## Spotify state and rendering

`SpotifyService` is a Quickshell reloadable singleton. It observes the native
MPRIS player list and requires a Spotify service name
(`org.mpris.MediaPlayer2.spotify`, including instance suffixes) together with a
Spotify identity or desktop-entry name. Browser track metadata is never used for
discovery. Players are ordered by bus name; a playing instance is preferred,
and the selected instance is retained while it remains in the best tier. A new
selection uses the first bus name in that tier.

`Island.qml` passes artwork, playing/paused state, support state, and progress to
`SpotifyWidget`. The service also exposes `title` and `artist` for later features.
The artwork and progress components know nothing about MPRIS. The image loads
asynchronously with a 96-pixel decode limit, crops proportionally, and uses
`ClippingRectangle` to mask its actual pixels. A local music-note fallback covers
missing, loading, and failed artwork. Pausing does not clear or fade the image.

The service exposes `paused` only for `MprisPlaybackState.Paused`, separately
from `playing`. Stopped or unavailable players do not count as paused.
`SpotifyWidget` passes this to the reusable artwork's optional
`showPauseIndicator` property. A black rectangle at **0.30 opacity** covers the
artwork, with two lighter-purple geometry bars above it. The whole presentation
is inside the circular clip, including when artwork is missing or loading. The
ring is a sibling outside the dimmed area and keeps its normal brightness.
A 120 ms opacity transition applies to the pause presentation; it leaves the
loaded image at opacity 1.

Both `MprisPlayer.position` and `length` are seconds in Quickshell. Unsupported,
nonfinite, or nonpositive durations produce zero progress; valid ratios clamp to
0–1. The ring has a subdued track and advances clockwise from 12 o'clock, with
explicit empty and full cases. A Qt Quick Shape renders partial arcs with the
curve renderer for antialiasing at fractional scale.

Quickshell extrapolates playback position when it is read, but does not notify
continuously. The widget owns one 1 Hz timer, enabled only while its window and
widget are visible, playback is active, and progress is supported. Its refresh
signal calls the service's `refreshPosition()`, which emits the documented
`player.positionChanged()` notification. It performs no periodic D-Bus or command
polling. Pause notifications also refresh the final frozen position. Reloading
destroys the old widget and timer.

## Adding a widget

Add an ordinary QML child after `SpotifyWidget` inside the existing `WidgetsPill`
in `modules/island/Island.qml`, for example:

```qml
Text {
    text: "hello"
    color: Theme.textPrimary
    font.family: Theme.fontFamily
    font.pixelSize: Theme.dateFontSize
    anchors.verticalCenter: parent.verticalCenter
}
```

Give custom widget components useful implicit sizes. `Row` owns horizontal
placement; use vertical centering for shorter content. Set a widget's `visible`
binding from its feature's availability. Hidden widgets and their spacing are
excluded automatically. When no visible children have width, `WidgetsPill`
collapses to zero width without affecting the notch. It deliberately
does not bind its own `visible` to the row's size: inherited invisibility would
otherwise feed back into measurement and prevent it reopening. There is no
widget registry or registration step. Adding widgets never moves the notch.

## Developer tools

Install the matching Qt development tools (`qmlls`, `qmllint`, `qmlformat`;
`qt6-declarative` on this Arch system). Enable Quickshell's supported language
server integration before launching:

```sh
touch .qmlls.ini
quickshell --path .
```

Quickshell fills `.qmlls.ini` with generated `qs.*` modules and absolute import
paths. It is already initialized in this workspace and ignored by Git. Recreate
it on a fresh installation, then configure your editor to run `qmlls`. If needed,
the Qt executables here are in `/usr/lib/qt6/bin`. No CMake project is necessary.
Do not create or commit hand-written `qmldir` files: Quickshell generates the
singleton and root-relative import declarations.

With the shell launched at least once in the current login session:

```sh
scripts/check-qml.sh
scripts/check-qml.sh --format
```

The first command verifies formatting and lints using the generated import root;
the second formats in place, then lints. The script looks in `PATH` and common Qt
6 binary directories; set `QT_BIN_DIR` for another installation. Generated paths
under the session runtime directory must be regenerated after logging in again.

Qt 6.12's linter exits successfully but reports two known metadata limitations:
`PanelWindow` marked uncreatable and the generic MPRIS model's `values` member
unresolved. These exact APIs load and run
on the tested Quickshell version. Warnings remain visible; new warnings still
need investigation. Runtime logs are essential alongside static checks.

## Verification and remaining checks

The updated shell loaded in the actual Niri session with no QML errors or
binding loops; native Spotify artwork and paused presentation were observed.
Formatting and import-aware lint checks pass with the two documented metadata
warnings above. No system packages or compositor settings were changed.

Temporary MPRIS fixtures on an isolated bus verified browser rejection, stable
instance selection, progress advance/pause/resume, seeking, track replacement,
failed artwork, unsupported durations, and player removal. They also verified
that stopped playback does not enable the pause presentation. Repeated reloads
retained one refresh timer; hiding the window stopped it. Native Spotify playback
was left untouched.

Rendered image and geometry checks at 100% and 125% scale verified:

- The notch is at y=0, centered on the screen, with two concave shoulders and
  rounded bottom corners fully inside its bounds.
- Spotify appearance/disappearance and a second 100-pixel widget do not move the
  notch. The right pill grows normally and collapses when empty.
- The widget measures 30 pixels across inside a 40-by-38-pixel pill, inset by 3,
  with an 8-pixel gap after the outer shoulder.
- Loaded artwork retains opacity 1. The black overlay is 0.30 opacity; sampled
  artwork colors retain 70% brightness. Circular alpha clipping is preserved.
- The pause icon has two separate vertical bars and disappears on resume. The
  ring retains its brightness and its active color is exactly `#9D00FF`.
- The inter-surface gap and unused full-width window area are transparent.

A delayed local image response additionally checked pause presentation while an
image was actually loading and after it became ready. The existing clock was
previously verified across a real minute boundary. Wayland tracing verified an
empty input region, disabled keyboard focus and no work-area reservation.

The fixture tools are development probes kept outside the project; they add no
runtime dependency or test framework. For future changes, repeat these small
manual checks in addition to `scripts/check-qml.sh`:

1. With Spotify closed, verify that the notch touches the screen top, both upper
   shoulders flare outward, and the clock is centered on the screen.
2. Open desktop Spotify, play, pause, resume, seek, and change tracks. Artwork
   should stay visible on pause, dim by 30%, and show two lighter-purple bars.
   The purple ring should retain its brightness and freeze when paused.
3. Add a temporary `Text` child to `WidgetsPill`, change its width, and remove it.
   The notch must remain fixed while the pill width changes.
4. Close Spotify while a browser player is active: only the widget pill vanishes.
5. Edit a theme value several times: reloads should stay clean and progress should
   retain its modest cadence. Restore the value afterward.
6. Confirm the local clock across a minute boundary. At fractional display scale,
   inspect the notch shoulders, circular artwork and pause bars.
7. Click through the gap, shoulders and unused transparent strip to a known window
   behind it. The whole overlay is intentionally click-through.

Physical pointer testing, screen hotplug/multiple outputs, X11, suspend/resume,
timezone changes and real Spotify control transitions still need user-session
validation. Playback transitions were verified with isolated fixtures instead.

## Troubleshooting

- **No Spotify pill:** launch the desktop client in the same user session as QP.
  The web player is intentionally ignored. Check service visibility with
  `busctl --user list | rg org.mpris.MediaPlayer2`. A sandboxed client must expose
  its MPRIS service to this session bus. Restarting a client with broken MPRIS
  state can help.
- **Fallback artwork:** the player may omit the URL, a local file may be missing,
  or a remote request may fail. Inspect the Quickshell terminal for image errors.
  There are no API keys to configure; the image source comes directly from MPRIS.
- **Empty or frozen ring:** duration or position may be unsupported, or playback
  may be paused. Zero progress is intentional when safe computation is impossible.
- **Overlap with an existing panel:** this overlay reserves no space and ignores
  other panels' reservations. Adjust `Config.widgetsTopInset` for the widget pill. The notch intentionally
  stays attached to the top edge.
- **Editor cannot resolve `qs.*`:** recreate `.qmlls.ini`, launch the project,
  and restart `qmlls`. Use Qt tooling from the same installation as Quickshell.

API decisions follow the official [Quickshell 0.3.2 documentation](https://quickshell.org/docs/v0.3.2/),
including [MPRIS position updates](https://quickshell.org/docs/v0.3.2/types/Quickshell.Services.Mpris/MprisPlayer/),
[rounded clipping](https://quickshell.org/docs/v0.3.2/types/Quickshell.Widgets/ClippingRectangle/),
and [language-server setup](https://quickshell.org/docs/v0.3.2/guide/install-setup/).
Rendering uses Qt 6.12's [Image](https://doc.qt.io/qt-6.12/qml-qtquick-image.html),
[Shape](https://doc.qt.io/qt-6.12/qml-qtquick-shapes-shape.html), and
[PathAngleArc](https://doc.qt.io/qt-6.12/qml-qtquick-pathanglearc.html) and
[PathArc](https://doc.qt.io/qt-6.12/qml-qtquick-patharc.html) APIs.
