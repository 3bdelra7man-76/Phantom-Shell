# QP

A personal Quickshell date/time notch, compact Spotify widget and calendar trigger.
Music expands into the centered notch with artwork, metadata, seeking and three
floating playback controls. The calendar opens a separate, centered monthly goal
planner on the same screen. Both close on an outside click, consuming that first
click; moving the pointer away leaves them open.

## Run

Supported reference environment: **Quickshell 0.3.2 / Qt 6.12.0**, Arch Linux,
Niri on Wayland. The compositor needs the Wayland layer-shell protocol. Runtime
imports use Qt Quick (Shapes, Templates, Controls/Basic and Effects), Quickshell Widgets,
and native MPRIS/PipeWire services plus Quickshell.Io. Install matching distribution packages
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
clock, metadata, timeline labels, calendar entries and text button labels. Editable text uses
`SharedTextField.qml` with the same shared font preference. It uses
`Theme.effectiveFontFamily`, plain text, and tabular numerals where supported.
Icon controls use local vector paths and accessible action names; text buttons
also inherit this typography. Add future text through `SharedText`.
The header keeps the existing 12-pixel date and 14-pixel time; metadata uses
16/12 pixels and timeline labels 11 pixels. Long metadata is elided on one line.

## Architecture

`shell.qml` creates `IslandWindow`; start reading there, `Island.qml`, and `Theme.qml`.

| File | Responsibility |
| --- | --- |
| `core/Config.qml` | Date/time formats, output preference, widget inset and progress refresh interval |
| `core/Theme.qml` | Shared Sharphy/fallback typography, palette, geometry and animation settings |
| `core/CalendarDates.js` | Strict local date keys, inclusive ranges, Monday grids and deterministic band packing |
| `services/CalendarStore.qml` | Goal/task validation, stable IDs, range-change guards and atomic JSON persistence |
| `services/SpotifyService.qml` | Sticky native Spotify selection, metadata, playback state and guarded commands |
| `services/SpotifyAudioMonitor.qml` | Scoped native capture of an identified Spotify playback stream |
| `components/SharedText.qml`, `SharedTextField.qml` | Consistent text and editable inputs |
| `components/TextButton.qml`, `IconButton.qml`, `PlaybackIcon.qml` | Shared hand cursor, hover feedback, accessible actions and local vectors |
| `components/Notch.qml`, `NotchContour.qml` | One contour for the notch fill, media clipping and open outline |
| `components/ScreenFrameContour.qml` | Rounded inner desktop opening shared by black fill and frame outline |
| `components/CircularArtwork.qml`, `CircularProgress.qml`, `PlaybackTimeline.qml` | Reusable music visuals independent of Spotify |
| `modules/island/IslandWindow.qml` | Screen choice, fixed notch canvas, native input masks and calendar window composition |
| `modules/island/Island.qml` | Active presentation, notch/music animation, widget layout and single progress timer |
| `modules/island/OutsideClickCatcher.qml` | Temporary screen-local dismissal surface below interactive windows |
| `modules/island/ScreenFrameWindow.qml` | Passive opaque frame with rounded inner corners and an empty input mask |
| `modules/island/DateTimeHeader.qml`, `WidgetsPill.qml` | Local minute clock and ordinary extensible widget composition |
| `modules/island/ExpandedMusicPanel.qml`, `SpotifyWidget.qml`, `MusicBackdrop.qml` | Music controls, single migrating artwork and backdrop/graph |
| `modules/calendar/CalendarWindow.qml` | Centered layer-shell window, rounded hit region, local fade and keyboard policy |
| `modules/calendar/CalendarPanel.qml` | Month/date selection, responsive workspace and editor coordination |
| `modules/calendar/MonthGrid.qml` | Fixed 42-day grid, weekly range bands, today/selection and overflow |
| `modules/calendar/DayAgenda.qml` | Virtualized goal headers and day-task rows, ID-scoped edit drafts |
| `modules/calendar/GoalEditor.qml` | Goal draft, inclusive end preview and task-removal confirmation |
| `modules/calendar/CalendarTaskRow.qml` | Checkbox, elided title, lazy inline editor, full-title tooltip and actions |

Shared visuals do not import Spotify/MPRIS. Feature components receive explicit
state/store inputs. Quickshell generates the `qs.*` imports and singleton metadata;
there are no source `qmldir` files. The standalone checklist, its panel and task
store have been removed. Existing `tasks.json` data is left untouched and is not
read, migrated or overwritten by the calendar.

## Calendar

The calendar button sits to the right of Spotify and remains available without it.
Each opening selects today. Navigate with the arrows, choose **Today**, or click
any visible date, including an adjacent month's dates. Weeks begin on Monday;
six fixed rows keep the grid steady when goals and tasks change.

The default window is **70% of screen width and 45% of screen height**, centered
on the notch's output. Minimum preferences of 860×420 logical pixels are capped
to fit the screen with 24-pixel margins. At 1920×1080 it is 1344×486. Most width
belongs to the grid; the selected-day agenda is on the right. Below the stacking
breakpoint, the grid and agenda stack in a scrolling workspace. Header/navigation
and status remain outside that scroll. Goal fields and the day agenda scroll
independently; the form's save action stays visible.

**Add goal** starts with the selected date and one day. Enter a name, a valid
`YYYY-MM-DD` local date, an integer duration from 1 to 30, and a preset or `#RRGGBB`
color. The start is day one; the form previews the inclusive end date. A one-day
goal occupies only its start date. Colored, named bands span cells and continue
in subsequent week rows/months. Stable start-date/ID ordering packs lanes; each
week compacts goals that still intersect it. `+N` identifies goals beyond the
available lanes. The selected-day agenda always includes **all** active goals,
even those behind overflow. Today's purple date disc and the selected cell's
light outline stay visible above the bands.

Each active goal shows its name/color, day number and completed-task count.
Add a task beneath that goal with Enter or the plus icon. Text is trimmed and
empty tasks are rejected; new tasks are unchecked. Check/uncheck to complete or
reopen. Completed tasks have both a checkmark and muted strikethrough. Edit inline
with Enter/confirm to save, or Escape to cancel; delete with the row's trash icon.
Drafts use task IDs, including when rows are recycled. Long text elides with its
full title available on hover and in the editor.

Editing a range that excludes dates with tasks first lists **every affected task
and its date**. Confirm **Remove N tasks and save** to apply that change, or return
to editing/cancel. The store rechecks the exact reviewed tasks before deleting;
a stale confirmation cannot remove a newly added or changed task. Remaining dates
keep their tasks and IDs. Goal deletion explicitly confirms removal of that goal
and all its tasks; unrelated goals remain intact.

Escape cancels a goal draft or active task edit first, then closes the calendar.
The calendar alone requests `WlrKeyboardFocus.OnDemand`; closing immediately sets
it to `None` and clears its native input mask. No Exclusive keyboard focus is used.
**On Niri, click inside the calendar to acquire native keyboard focus before
using the keyboard.** QML selects the appropriate editor within that window.
Closing or switching to music releases keyboard focus. Calendar/task drafts are
not committed until their save/add action.

## Calendar storage

The dedicated file is **`Quickshell.dataDir/calendar.json`**. For this checkout
with the default XDG directory:

```text
/home/phantom/.local/share/quickshell/by-shell/a6a53cc7ffd425e04ed994998a2ce5ec/calendar.json
```

Back it up for reinstallations. The shell ID can change if the checkout is moved
or renamed; `XDG_DATA_HOME` changes the base directory. Run one QP instance for
this file. Tasks use stable IDs, a stable goal ID and a local civil date, so two
active goals or two dates never share a completion state.

```json
{
  "version": 1,
  "goals": [
    { "id": "goal-id", "name": "Practice", "startDate": "2026-11-17", "duration": 30, "color": "#9D00FF" }
  ],
  "tasks": [
    { "id": "task-id", "goalId": "goal-id", "date": "2026-11-17", "text": "First session", "completed": false }
  ]
}
```

The store validates the entire file, including duplicate IDs, ranges, colors,
completion types and task/goal/date references, before publishing data. Loading
is asynchronous; edits wait for readiness. A missing file starts empty. Invalid
or unsupported data is preserved, edits are blocked and **Retry** is offered.
Back up/repair the file or move it aside before retrying; it is never silently
replaced. Dates are parsed as local civil dates, with noon-based arithmetic and
UTC day ordinals for counting across daylight-saving boundaries.

Native models are canonical; plain JavaScript snapshots feed views and JSON.
Committed changes coalesce with `Qt.callLater` and use asynchronous, atomic
`FileView` writes with at most one write in flight. Rapid changes save the latest
state in order. Identical text is handled because FileView skips its saved signal.
Save failures preserve pending data in memory and the previous file; resolve the
filesystem problem and Retry before restarting. Retry rereads the disk cache
without replacing pending data. Closing the window leaves the store/save alive.

## Appearance and input

Existing music/notch geometry, theme and animation values were kept. Only settings
used solely by the removed standalone feature were retired; calendar settings
are independent. Change `core/Theme.qml`:

| Tokens | Purpose |
| --- | --- |
| `fontFamily`, `fallbackFontFamily`, `fontSource` | Sharphy preference, fallback and optional portable licensed font |
| `accentPrimary`, `accentForeground`, `accentMuted` | Exact `#9D00FF`, readable purple and muted purple |
| `notch*`, `musicShoulder*`, `widgets*`, `artwork*` | Existing tuned notch, shoulders, compact pill and artwork |
| `screenFrameWidth`, `screenFrameInnerRadius`, `screenFrameFill`, `screenFrameOpacity` | Flush black frame, rounded desktop opening and subtle outline |
| `transitionDuration`, `contentRevealStart` | Unchanged 240 ms music reveal and content fade |
| `calendarWidthRatio`, `calendarHeightRatio`, `calendarMinimum*`, `calendarScreenMargin` | Window sizing/bounds |
| `calendarRadius`, `calendarPadding`, `calendarGap` | Rounded surface and content spacing |
| `calendarStackBreakpoint`, `calendarGridFraction`, `calendarGridMinimumHeight`, `calendarAgendaMinimumHeight` | Two-column/stacked layout |
| `calendarBackground`, `calendarSurface`, `calendarText`, `calendarMutedText` | Near-black surfaces, off-white and muted text |
| `calendarSelectedTint`, `calendarHoverTint`, `calendarSeparator` | Selected date, hover fills and dividers |
| `calendarGoalColors`, `calendarBand*`, `calendarMaxBands` | Preset colors, range geometry/opacity and overlap capacity |
| `calendarTask*`, `calendarGoalHeaderHeight`, `calendarActionSize` | Day-agenda rows and action sizes |
| `calendarTransitionDuration` | Independent 160 ms calendar fade/month transition |
| `input*` | Shared field dimensions and typography |

`Config.timeFormat` is `HH:mm`, `dateFormat` is `ddd, d MMM`; the local clock uses
minute precision. `Config.screenName` chooses an output (empty/unmatched means
the platform default). `Config.widgetsTopInset` retains its tuned value.
Only the notch is horizontally centered; widget widths never affect it. The
frame has square outer corners flush to physical edges and four rounded inner
corners in its **opaque black fill**, even with the outline hidden.

`Island.activePanel` is empty, `music`, or `calendar`. Only music expands the
notch. Calendar is a separate window, so switching reverses the music reveal
while mapping/fading the planner. One Spotify item migrates between the compact
pill and expanded music panel; one 1 Hz progress timer owns both presentations.
The notch window retains a fixed final music canvas; native window resizing on
every animation frame previously caused 0.9–1.1 second opens on Niri.

Both interactive windows use the Overlay layer. The temporary full-screen
Top-layer catcher sits below them on the same output. It uses a passive TapHandler
and waits for release: **the first outside click is consumed**, then the catcher
unmaps as closing begins. The next click reaches the desktop. Inside clicks and
a seek drag released outside do not dismiss. The calendar mask matches its rounded
body; transparent corners pass to the catcher while open and to the desktop after
closing. The frame and unused notch canvas remain click-through, with no work-area
reservation. Enabled buttons have a pointing hand, fields an I-beam and the timeline
a horizontal drag cursor. Buttons share brief glyph hover/pressed feedback.

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

## Extending and checking

Add ordinary QML children after `calendarButton` inside `WidgetsPill` in `Island.qml`.
Give each a sensible implicit size and availability binding. The Row owns placement;
empty content collapses without a visibility/measurement loop. Interactive additions
also need explicit hit regions in `IslandWindow`. Keep window configuration separate
from feature state, service commands separate from reusable visuals, and use shared
text/button components. New modules can import `qs.modules.calendar`.

Bootstrap the generated imports/language-server paths:

```sh
touch .qmlls.ini
quickshell --path .
```

Use matching Qt `qmlls`, `qmllint`, and `qmlformat`. Quickshell regenerates the
machine-specific, ignored `.qmlls.ini`; do not add source `qmldir` files. Checks:

```sh
scripts/check-qml.sh --format
scripts/check-qml.sh
bash -n scripts/check-qml.sh
QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME= /usr/lib/qt6/bin/qmltestrunner -input tests
```

The QML script covers `modules/*/*.qml`, including calendar. Set `QT_BIN_DIR` if Qt
utilities are elsewhere. Known installed-metadata warnings are the four
`PanelWindow` types marked uncreatable and the native MPRIS/PipeWire `values`
members; investigate any new category. `tests/tst_CalendarDates.qml` checks strict
local dates, inclusive 1/30-day ranges, leap days, DST counting, navigation, weekly
packing and overflow segments. For frame diagnosis, use temporary instrumentation
and `--log-rules 'qt.scenegraph.time.renderloop=true'`; keep frame loops out of QP.

Calendar replacement verification used isolated data and a private MPRIS fixture.
Qt interaction checks at 100% and 125% covered the default/stacked layouts,
one- and 30-day goals, week/month boundaries, overlaps/overflow, task editing,
completion independence, range confirmation, deletion and restart persistence.
A 60-task agenda exercised delegate recycling, retained drafts and quick-entry
focus. Temporary filesystem failures exercised ordered saves, Retry, invalid JSON
and task dates outside their goal; personal files were not modified. Date tests
passed in Cairo, New York and Berlin time zones.

Native Niri clicks verified the trigger with Spotify absent, centered dimensions,
all four rounded window corners, keyboard typing/Enter, Escape priority/focus
release, outside-click consumption and the following desktop click. Panel
switching, Spotify disappearing and rapid reversals were checked with a private
player. Static checks retain only the documented metadata warnings; live loading
and interaction showed no QML errors or binding loops. Real Spotify commands and
Sharphy rendering were not exercised; the font is still unavailable.

Manual/runtime checklist:

1. Open the calendar with Spotify absent and present; confirm centered size,
   rounded corners, today/selection, keyboard focus and unchanged notch geometry.
2. Create one- and 30-day goals across weeks/months, overlap enough for `+N`, and
   click every relevant day. Compare names, day numbers, colors and task counts.
3. Add/edit/complete/reopen/delete tasks under overlapping goals and on different
   dates. Scroll a long agenda while editing; drafts must remain tied to IDs.
4. Shrink/move a goal over task-bearing days; inspect the affected-task list and
   cancel/confirm. Verify a stale confirmation cannot discard a later edit.
5. Restart after Saving clears and verify goals, dates, IDs and completion states.
   Back up data before testing invalid-file or failed-save recovery.
6. Test Escape from an editor and the calendar, outside clicks after editing,
   switching to music, and Spotify closing while the calendar remains open.
7. Check default and fractional scales, the stacked small-window layout, cursor
   feedback, and the black frame corners with the colored outline hidden.
8. Check music controls, seeking across the panel boundary, pause dim/icon, graph,
   rapid reversals and reloads. No duplicate media/progress timers should appear.

Sharphy metrics still require the actual font. Native Spotify commands, a full
reboot, output hotplug and X11 are separate session checks; isolated fixture tests
must not disturb personal playback or write real calendar data.

## Troubleshooting

- **No music widget:** desktop Spotify must expose native MPRIS on the session bus;
  browser metadata is intentionally ignored. Inspect `busctl --user list`.
- **Missing artwork:** loading/failure uses the local fallback; no API key is needed.
  This MPRIS integration has no playable Spotify video URL.
- **Disabled music action:** check native player capabilities and duration.
- **Calendar typing/Escape:** on Niri first click inside the calendar to focus it.
  Save/add commits a draft; Escape first cancels an editor before dismissal.
- **Calendar load/save error:** keep the data file, resolve the reported problem,
  and Retry. Pending unsaved changes remain in memory; avoid restarting first.
- **Unexpected font:** install Sharphy or configure its licensed URL/family above.
- **Unresolved `qs.*`:** bootstrap `.qmlls.ini`, launch once and restart matching `qmlls`.

Official API references: [Quickshell 0.3.2](https://quickshell.org/docs/v0.3.2/),
[PanelWindow](https://quickshell.org/docs/v0.3.2/types/Quickshell/PanelWindow/),
[ShellScreen](https://quickshell.org/docs/v0.3.2/types/Quickshell/ShellScreen/),
[Region](https://quickshell.org/docs/v0.3.2/types/Quickshell/Region/),
[FileView](https://quickshell.org/docs/v0.3.2/types/Quickshell.Io/FileView/),
[WlrKeyboardFocus](https://quickshell.org/docs/v0.3.2/types/Quickshell.Wayland/WlrKeyboardFocus/),
[MPRIS](https://quickshell.org/docs/v0.3.2/types/Quickshell.Services.Mpris/MprisPlayer/),
[Qt 6.12 ListView](https://doc.qt.io/qt-6.12/qml-qtquick-listview.html),
[HoverHandler](https://doc.qt.io/qt-6.12/qml-qtquick-hoverhandler.html),
[ShapePath](https://doc.qt.io/qt-6.12/qml-qtquick-shapes-shapepath.html).
