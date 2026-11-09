pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import qs.components
import qs.core
import qs.services

Item {
    id: root

    required property bool active
    property string activePanel: ""
    property string _closingPanel: "music"
    readonly property bool expanded: activePanel !== ""
    readonly property string presentedPanel: activePanel || _closingPanel
    readonly property bool todoOpen: activePanel === "todo"
    readonly property alias todoPresentation: todo
    readonly property alias todoTrigger: todoButton
    // Explicit coordinate dependencies keep the native mask in sync with Row
    // placement and the animated pill; mapToItem() alone does not track them.
    readonly property real todoInputX: widgets.x + widgets.contentItem.x + todoButton.x
    readonly property real todoInputY: widgets.y + widgets.contentItem.y + todoButton.y
    onActivePanelChanged: {
        if (activePanel)
            _closingPanel = activePanel;
    }
    readonly property alias notchSurface: notch
    readonly property alias musicPresentation: music
    readonly property alias panelBody: panelBounds
    readonly property bool dragging: panel.dragging
    readonly property bool compactInputEnabled: SpotifyService.available && activePanel !== "music"
                                                && musicReveal === 0
    readonly property bool panelInputEnabled: expanded
    readonly property real collapsedWidth: header.implicitWidth + Theme.notchHorizontalPadding * 2
                                           + Theme.notchShoulderWidth * 2
    readonly property real collapsedHeight: Math.max(Theme.notchHeight, header.implicitHeight
                                                     + Theme.notchVerticalPadding * 2)
    readonly property real musicExpandedWidth: {
        const padding = (Theme.musicPadding + Theme.musicShoulderWidth) * 2;
        return Math.max(collapsedWidth, Math.min(width, Theme.musicContentWidth + padding));
    }
    readonly property real todoExpandedWidth: {
        const preferred = Theme.todoContentWidth + (Theme.todoPadding + Theme.musicShoulderWidth)
              * 2;
        const available = width - Theme.todoScreenMargin * 2;
        return Math.max(collapsedWidth, Math.min(available, preferred));
    }
    readonly property real expandedWidth: presentedPanel === "todo" ? todoExpandedWidth :
                                                                      musicExpandedWidth
    readonly property real frameOpeningWidth: Math.max(collapsedWidth, musicExpandedWidth,
                                                       todoExpandedWidth)
    readonly property real compactWidgetsX: width / 2 + collapsedWidth / 2
                                            - Theme.notchShoulderWidth + Theme.notchWidgetsGap
    readonly property real musicExpandedHeight: collapsedHeight + Theme.musicTopGap
                                                + panel.implicitHeight + Theme.musicBottomPadding
    readonly property real todoExpandedHeight: collapsedHeight + Theme.todoTopGap
                                               + todo.implicitHeight + Theme.todoBottomPadding
    readonly property real canvasHeight: Math.max(musicExpandedHeight, todoExpandedHeight)
                                         + Theme.screenFrameWidth
    readonly property real expandedHeight: presentedPanel === "todo" ? todoExpandedHeight :
                                                                       musicExpandedHeight
    property real surfaceWidth: expandedWidth
    property real surfaceHeight: expandedHeight
    readonly property bool surfaceSettled: Math.abs(surfaceWidth - expandedWidth) < 0.1 && Math.abs(surfaceHeight
                                                                                                    - expandedHeight)
                                           < 0.1
    readonly property real contentOpacity: Math.max(0, (reveal - Theme.contentRevealStart) / (1
                                                                                              - Theme.contentRevealStart))
    // One animated coordinate drives geometry and the single media presentation.
    property real reveal: expanded ? 1 : 0
    // Panel selection has its own blend so switching midway through expansion
    // can reverse the same artwork's movement without jumping.
    property real musicParticipation: presentedPanel === "music" ? 1 : 0
    readonly property real musicReveal: reveal * musicParticipation
    Behavior on musicParticipation {
        enabled: root.reveal > 0
        NumberAnimation {
            duration: Theme.transitionDuration
            easing.type: Easing.InOutCubic
        }
    }
    Behavior on surfaceWidth {
        enabled: root.reveal > 0
        NumberAnimation {
            duration: Theme.transitionDuration
            easing.type: Easing.InOutCubic
        }
    }
    Behavior on surfaceHeight {
        enabled: root.reveal > 0
        NumberAnimation {
            duration: Theme.transitionDuration
            easing.type: Easing.InOutCubic
        }
    }
    implicitHeight: Math.max(notch.height + Theme.screenFrameWidth, widgets.y + widgets.height)

    function openMusic(): void {
        if (SpotifyService.available) {
            activePanel = "music";
        }
    }

    function openTodo(): void {
        activePanel = "todo";
    }
    function closePanel(): void {
        activePanel = "";
    }

    function musicInterpolate(from: real, to: real): real {
        return from + (to - from) * musicReveal;
    }

    function interpolate(from: real, to: real): real {
        return from + (to - from) * reveal;
    }

    Behavior on reveal {
        NumberAnimation {
            duration: Theme.transitionDuration
            easing.type: Easing.InOutCubic
        }
    }

    Notch {
        id: notch
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.alignWhenCentered: false
        width: root.interpolate(root.collapsedWidth, root.surfaceWidth)
        height: root.interpolate(root.collapsedHeight, root.surfaceHeight)
        shoulderWidth: root.interpolate(Theme.notchShoulderWidth, Theme.musicShoulderWidth)
        shoulderHeight: root.interpolate(Theme.notchShoulderHeight, Theme.musicShoulderHeight)
        shoulderCurve: root.interpolate(Theme.notchShoulderCurve, Theme.musicShoulderCurve)
        outlineSpan: root.frameOpeningWidth
        backgroundActive: root.presentedPanel === "music" && (root.expanded || root.reveal > 0)
        background: Component {
            MusicBackdrop {
                artworkSource: SpotifyService.artworkSource
                playing: SpotifyService.playing
                trackTitle: SpotifyService.title
                headerHeight: root.collapsedHeight
                shoulderWidth: notch.shoulder
                active: root.active && root.activePanel === "music"
                opacity: root.reveal
            }
        }
    }

    DateTimeHeader {
        id: header
        anchors.horizontalCenter: notch.horizontalCenter
        y: (root.collapsedHeight - height) / 2
    }

    WidgetsPill {
        id: widgets
        x: root.interpolate(root.compactWidgetsX, notch.x + notch.width + Theme.notchWidgetsGap)
        y: Config.widgetsTopInset

        Item {
            id: spotifySlot
            implicitWidth: SpotifyService.available ? Theme.artworkDiameter * (1
                                                                               - root.musicReveal) :
                                                      0
            implicitHeight: Theme.artworkDiameter
            visible: SpotifyService.available && implicitWidth > 0
        }
        IconButton {
            id: todoButton
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.todoWidgetSize
            height: width
            glyph: "checklist"
            actionName: "To-do"
            tooltipText: "To-do"
            onClicked: root.openTodo()
        }
    }

    RectangularShadow {
        anchors.fill: music
        radius: music.width / 2
        blur: Theme.artworkGlowBlur
        spread: Theme.artworkGlowSpread
        color: Qt.alpha(Theme.accentPrimary, Theme.artworkGlowOpacity)
        opacity: root.musicReveal
        visible: music.visible && opacity > 0
    }

    SpotifyWidget {
        id: music
        readonly property real compactX: widgets.x + Theme.widgetsHorizontalPadding
        readonly property real expandedX: root.width / 2 - root.musicExpandedWidth / 2
                                          + Theme.musicShoulderWidth + Theme.musicPadding
        readonly property real compactY: Config.widgetsTopInset + Theme.widgetsVerticalPadding
        readonly property real expandedY: root.collapsedHeight + Theme.musicTopGap
        x: root.musicInterpolate(compactX, expandedX)
        y: root.musicInterpolate(compactY, expandedY)
        width: root.musicInterpolate(Theme.artworkDiameter, Theme.musicArtworkDiameter)
        height: width
        visible: SpotifyService.available
        artworkSource: SpotifyService.artworkSource
        progress: SpotifyService.progress
        paused: SpotifyService.paused
        ringWidth: root.musicInterpolate(Theme.progressWidth, Theme.musicProgressWidth)
        artworkGap: root.musicInterpolate(Theme.artworkRingGap, Theme.musicArtworkRingGap)

        MouseArea {
            anchors.fill: parent
            enabled: root.compactInputEnabled
            cursorShape: Qt.PointingHandCursor
            onClicked: root.openMusic()
        }
    }

    Item {
        id: panelClip
        x: notch.x + notch.shoulder
        y: root.collapsedHeight
        width: Math.max(0, notch.width - notch.shoulder * 2)
        height: Math.max(0, notch.height - y - (root.presentedPanel === "todo" ? Theme.todoBottomPadding :
                                                                                 Theme.musicBottomPadding))
        clip: true

        ExpandedMusicPanel {
            id: panel
            x: Theme.musicPadding
            y: Theme.musicTopGap
            width: Math.max(0, notch.width - (notch.shoulder + Theme.musicPadding) * 2)
            // Reveal controls during the final part of geometry, without a second
            // sequential fade that delays the useful end of an otherwise fast open.
            opacity: root.presentedPanel === "music" && root.surfaceSettled ? root.contentOpacity :
                                                                              0
            visible: opacity > 0
            enabled: root.activePanel === "music" && root.reveal === 1 && root.surfaceSettled
            Behavior on opacity {
                enabled: root.reveal === 1
                NumberAnimation {
                    duration: Theme.panelSwitchFadeDuration
                }
            }
            title: SpotifyService.title
            artist: SpotifyService.artist
            playing: SpotifyService.playing
            position: SpotifyService.position
            duration: SpotifyService.duration
            trackKey: SpotifyService.trackKey
            canPrevious: SpotifyService.canPrevious
            canNext: SpotifyService.canNext
            canTogglePlayback: SpotifyService.canTogglePlayback
            canSeek: SpotifyService.canSeek
            onPreviousRequested: SpotifyService.previous()
            onNextRequested: SpotifyService.next()
            onToggleRequested: SpotifyService.togglePlayback()
            onSeekRequested: seconds => SpotifyService.seekTo(seconds)
        }

        TodoPanel {
            id: todo
            x: Theme.todoPadding
            y: Theme.todoTopGap
            width: Math.max(0, parent.width - Theme.todoPadding * 2)
            store: TaskStore
            opacity: root.presentedPanel === "todo" && root.surfaceSettled ? root.contentOpacity : 0
            visible: opacity > 0
            enabled: root.activePanel === "todo" && root.reveal === 1 && root.surfaceSettled
            onCloseRequested: root.closePanel()
            Behavior on opacity {
                enabled: root.reveal === 1
                NumberAnimation {
                    duration: Theme.panelSwitchFadeDuration
                }
            }
        }
    }

    // The window's bounded input region follows only the solid panel body.
    Item {
        id: panelBounds
        x: notch.x + notch.shoulder
        width: Math.max(0, notch.width - notch.shoulder * 2)
        height: notch.height
    }

    // Both compact and expanded presentations share this one refresh owner.
    Timer {
        interval: Config.progressRefreshInterval
        running: root.active && music.visible && SpotifyService.playing
                 && SpotifyService.progressSupported
        repeat: true
        triggeredOnStart: true
        onTriggered: SpotifyService.refreshPosition()
    }

    Connections {
        target: SpotifyService
        function onAvailableChanged(): void {
            if (!SpotifyService.available && root.activePanel === "music")
                root.closePanel();
        }
    }
}
