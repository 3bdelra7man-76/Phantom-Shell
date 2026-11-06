# QP

A small, display-only Quickshell island: a black date/time pill and a separate
Spotify artwork pill, centered together at the top of one screen. The Spotify
pill disappears when Spotify closes. There are no controls, popups, or expanded
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
| `core/Config.qml` | Date/time formats, top margin, screen preference, refresh interval |
| `core/Theme.qml` | Colors, fonts, pill dimensions, gaps, padding, artwork size, fade duration |
| `services/SpotifyService.qml` | Native Spotify discovery, stable player selection, metadata and normalized progress |
| `components/Pill.qml` | Rounded surface with an explicit content slot and content-driven size |
| `components/CircularArtwork.qml` | Asynchronous image, proportional crop, true circular clipping, local fallback |
| `components/CircularProgress.qml` | Independent normalized progress ring |
| `modules/island/IslandWindow.qml` | Screen selection, compact transparent panel, placement and input behavior |
| `modules/island/Island.qml` | Feature composition and service-to-widget bindings |
| `modules/island/DateTimePill.qml` | Local minute-precision `SystemClock` and formatted text |
| `modules/island/WidgetsPill.qml` | Horizontal content slot for visible widgets |
| `modules/island/SpotifyWidget.qml` | Supplied artwork/progress presentation and scoped refresh timer |
| `scripts/check-qml.sh` | Development-only formatting and import-aware lint checks |

`Config.timeFormat` defaults to `HH:mm`; `Config.dateFormat` defaults to
`ddd, d MMM`. These use Qt date/time format strings and the local system time.
The clock intentionally updates once per minute, so formats containing seconds
would also require changing its precision. Monospaced text keeps time digits
from changing width.

The starting theme uses black surfaces, white time, muted date text, 44-pixel pill
height, 8-pixel separation, a 34-pixel artwork/ring assembly, and green progress.
The top margin is 12 logical pixels. Sizes are logical pixels, including on
scaled screens. Pill height can grow to accommodate larger fonts or widgets.
`Config.screenName: ""` uses the platform default. Set an output name such as
`"eDP-1"` to prefer it; a missing output falls back to the default. Selection and
fallback stay in the window layer. The single top anchor centers the compact
window horizontally as its content changes.

## Spotify state and rendering

`SpotifyService` is a Quickshell reloadable singleton. It observes the native
MPRIS player list and requires a Spotify service name
(`org.mpris.MediaPlayer2.spotify`, including instance suffixes) together with a
Spotify identity or desktop-entry name. Browser track metadata is never used for
discovery. Players are ordered by bus name; a playing instance is preferred,
and the selected instance is retained while it remains in the best tier. A new
selection uses the first bus name in that tier.

`Island.qml` passes artwork, playing state, support state, and progress to
`SpotifyWidget`. The service also exposes `title` and `artist` for later features.
The artwork and progress components know nothing about MPRIS. The image loads
asynchronously with a 96-pixel decode limit, crops proportionally, and uses
`ClippingRectangle` to mask its actual pixels. A local music-note fallback covers
missing, loading, and failed artwork. Pausing does not clear the image.

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
collapses to zero width, so the outer row also drops the pill gap. It deliberately
does not bind its own `visible` to the row's size: inherited invisibility would
otherwise feed back into measurement and prevent it reopening. There is no
widget registry or registration step.

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

Qt 6.12's linter exits successfully but reports three known metadata limitations:
`PanelWindow` marked uncreatable, its `margins.top` group unresolved, and the
generic MPRIS model's `values` member unresolved. These exact APIs load and run
on the tested Quickshell version. Warnings remain visible; new warnings still
need investigation. Runtime logs are essential alongside static checks.

## Verification and remaining checks

The implementation was loaded in the actual Niri session with no QML errors or
binding loops. Native Spotify discovery, artwork and paused state were observed.
Separate temporary MPRIS fixtures on an isolated session bus exercised browser
rejection, deterministic instance selection, playback advance/pause/resume,
seeking, track replacement, instance removal, unsupported positions and missing,
zero and negative durations. Image captures checked circular transparency,
proportional cropping, fallback, and empty/full rings. A 125% scale render also
verified circular clipping, transparent inter-pill space, and the clockwise
quarter arc. The local clock updated correctly across a real minute boundary.
Layout checks confirmed
44-pixel height, 46-pixel widget pill width, 8-pixel gap, and empty-pill collapse.
Repeated reloads retained a single refresh timer; hiding the window stopped it.
Wayland tracing checked the empty input region, disabled keyboard focus, and
absence of work-area reservation.

The fixture tools are development probes, kept outside the project; they add no
runtime dependency or test framework. For future changes, repeat these small
manual checks in addition to `scripts/check-qml.sh`:

1. Start with Spotify closed: only the date/time pill should be centered.
2. Open desktop Spotify, play, pause, resume, seek, and change tracks. Artwork
   should stay visible on pause; only active supported playback should advance.
3. Close Spotify while a browser player is active: the right pill should vanish.
4. Edit a theme value several times: reloads should stay clean and progress should
   retain its modest cadence. Restore the value afterward.
5. Confirm the clock across a minute boundary and the combined horizontal center.
6. On your compositor, click through the inter-pill gap and rounded corners to a
   known window behind it. The whole island is intentionally click-through.

Physical pointer testing, screen hotplug/multiple outputs, X11, suspend/resume,
timezone changes, and real Spotify seeking/closing still need user-session
validation. The native Spotify playback was left untouched; playback transitions
were verified with isolated fixtures instead.

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
  other panels' reservations. Adjust `Config.topMargin` yourself.
- **Editor cannot resolve `qs.*`:** recreate `.qmlls.ini`, launch the project,
  and restart `qmlls`. Use Qt tooling from the same installation as Quickshell.

API decisions follow the official [Quickshell 0.3.2 documentation](https://quickshell.org/docs/v0.3.2/),
including [MPRIS position updates](https://quickshell.org/docs/v0.3.2/types/Quickshell.Services.Mpris/MprisPlayer/),
[rounded clipping](https://quickshell.org/docs/v0.3.2/types/Quickshell.Widgets/ClippingRectangle/),
and [language-server setup](https://quickshell.org/docs/v0.3.2/guide/install-setup/).
Rendering uses Qt 6.12's [Image](https://doc.qt.io/qt-6.12/qml-qtquick-image.html),
[Shape](https://doc.qt.io/qt-6.12/qml-qtquick-shapes-shape.html), and
[PathAngleArc](https://doc.qt.io/qt-6.12/qml-qtquick-pathanglearc.html) APIs.
