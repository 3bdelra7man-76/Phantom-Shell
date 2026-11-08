import QtQuick
import qs.components
import qs.core
import qs.services

Item {
    id: root

    required property bool active
    property bool expanded: false
    readonly property alias notchSurface: notch
    readonly property alias musicPresentation: music
    readonly property alias panelBody: panelHoverArea
    readonly property bool compactInputEnabled: SpotifyService.available && !expanded && reveal
                                                === 0
    readonly property bool panelInputEnabled: SpotifyService.available && expanded
    readonly property real collapsedWidth: header.implicitWidth + Theme.notchHorizontalPadding * 2
                                           + Theme.notchShoulderWidth * 2
    readonly property real collapsedHeight: Math.max(Theme.notchHeight, header.implicitHeight
                                                     + Theme.notchVerticalPadding * 2)
    readonly property real expandedWidth: {
        const padding = (Theme.musicPadding + Theme.notchShoulderWidth) * 2;
        return Math.max(collapsedWidth, Math.min(width, Theme.musicContentWidth + padding));
    }
    readonly property real expandedHeight: collapsedHeight + Theme.musicTopGap
                                           + panel.implicitHeight + Theme.musicBottomPadding
    // One animated coordinate drives geometry and the single media presentation.
    property real reveal: expanded ? 1 : 0
    // Ignore subpixel measurement noise when identifying additional widgets.
    readonly property bool otherWidgetsVisible: widgets.contentWidth > spotifySlot.width + 0.1
    implicitHeight: Math.max(notch.height, widgets.y + widgets.height)

    function openMusic(): void {
        if (SpotifyService.available) {
            openingGrace.restart();
            expanded = true;
        }
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
        width: root.interpolate(root.collapsedWidth, root.expandedWidth)
        height: root.interpolate(root.collapsedHeight, root.expandedHeight)
    }

    DateTimeHeader {
        id: header
        anchors.horizontalCenter: notch.horizontalCenter
        y: (root.collapsedHeight - height) / 2
    }

    WidgetsPill {
        id: widgets
        x: {
            if (root.otherWidgetsVisible)
                return notch.x + notch.width + Theme.notchWidgetsGap;
            return root.width / 2 + root.collapsedWidth / 2 + Theme.notchWidgetsGap;
        }
        y: Config.widgetsTopInset
        // Other widgets retain their surface as Spotify leaves the pill.
        opacity: root.otherWidgetsVisible ? 1 : 1 - root.reveal

        Item {
            id: spotifySlot
            implicitWidth: SpotifyService.available ? Theme.artworkDiameter * (1 - root.reveal) : 0
            implicitHeight: Theme.artworkDiameter
        }
    }

    SpotifyWidget {
        id: music
        readonly property real compactX: root.width / 2 + root.collapsedWidth / 2
                                         + Theme.notchWidgetsGap + Theme.widgetsHorizontalPadding
        readonly property real expandedX: root.width / 2 - root.expandedWidth / 2
                                          + Theme.notchShoulderWidth + Theme.musicPadding
        readonly property real compactY: Config.widgetsTopInset + Theme.widgetsVerticalPadding
        readonly property real expandedY: root.collapsedHeight + Theme.musicTopGap
        x: root.interpolate(compactX, expandedX)
        y: root.interpolate(compactY, expandedY)
        width: root.interpolate(Theme.artworkDiameter, Theme.musicArtworkDiameter)
        height: width
        visible: SpotifyService.available
        artworkSource: SpotifyService.artworkSource
        progress: SpotifyService.progress
        paused: SpotifyService.paused
        ringWidth: root.interpolate(Theme.progressWidth, Theme.musicProgressWidth)
        artworkGap: root.interpolate(Theme.artworkRingGap, Theme.musicArtworkRingGap)

        MouseArea {
            anchors.fill: parent
            enabled: root.compactInputEnabled
            cursorShape: Qt.PointingHandCursor
            onClicked: root.openMusic()
        }
    }

    ExpandedMusicPanel {
        id: panel
        x: notch.x + Theme.notchShoulderWidth + Theme.musicPadding
        y: root.collapsedHeight + Theme.musicTopGap
        width: Math.max(0, notch.width - (Theme.notchShoulderWidth + Theme.musicPadding) * 2)
        opacity: root.expanded && root.reveal === 1 ? 1 : 0
        visible: opacity > 0
        enabled: root.expanded && root.reveal === 1 && opacity === 1
        title: SpotifyService.title
        artist: SpotifyService.artist
        playing: SpotifyService.playing
        position: SpotifyService.position
        duration: SpotifyService.duration
        trackKey: SpotifyService.trackKey
        canPrevious: SpotifyService.canPrevious
        canNext: SpotifyService.canNext
        canTogglePlayback: SpotifyService.canTogglePlayback
        canStop: SpotifyService.canStop
        canSeek: SpotifyService.canSeek
        onPreviousRequested: SpotifyService.previous()
        onNextRequested: SpotifyService.next()
        onToggleRequested: SpotifyService.togglePlayback()
        onStopRequested: SpotifyService.stop()
        onSeekRequested: seconds => SpotifyService.seekTo(seconds)

        Behavior on opacity {
            NumberAnimation {
                duration: root.expanded ? Theme.contentFadeDuration : Theme.contentExitDuration
            }
        }
    }

    // The parent hover observer continues tracking across every child control.
    Item {
        id: panelHoverArea
        x: notch.x + Theme.notchShoulderWidth
        width: Math.max(0, notch.width - Theme.notchShoulderWidth * 2)
        height: notch.height

        HoverHandler {
            id: panelHover
            enabled: root.panelInputEnabled
            blocking: false
            onHoveredChanged: {
                if (hovered)
                    openingGrace.stop();
            }
        }
    }

    Timer {
        id: openingGrace
        interval: Theme.openingGraceDuration
    }

    Timer {
        interval: Theme.pointerExitDelay
        running: root.expanded && !panelHover.hovered && !panel.dragging && !openingGrace.running
        onTriggered: root.expanded = false
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
            if (!SpotifyService.available)
                root.expanded = false;
        }
    }
}
