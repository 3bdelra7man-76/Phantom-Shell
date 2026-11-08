pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import qs.components
import qs.core
import qs.services

Item {
    id: root

    required property bool active
    property bool expanded: false
    readonly property alias notchSurface: notch
    readonly property alias musicPresentation: music
    readonly property alias panelBody: panelBounds
    readonly property bool dragging: panel.dragging
    readonly property bool compactInputEnabled: SpotifyService.available && !expanded && reveal
                                                === 0
    readonly property bool panelInputEnabled: SpotifyService.available && expanded
    readonly property real collapsedWidth: header.implicitWidth + Theme.notchHorizontalPadding * 2
                                           + Theme.notchShoulderWidth * 2
    readonly property real collapsedHeight: Math.max(Theme.notchHeight, header.implicitHeight
                                                     + Theme.notchVerticalPadding * 2)
    readonly property real expandedWidth: {
        const padding = (Theme.musicPadding + Theme.musicShoulderWidth) * 2;
        return Math.max(collapsedWidth, Math.min(width, Theme.musicContentWidth + padding));
    }
    readonly property real frameOpeningWidth: Math.max(collapsedWidth, expandedWidth)
    readonly property real compactWidgetsX: width / 2 + collapsedWidth / 2
                                            - Theme.notchShoulderWidth + Theme.notchWidgetsGap
    readonly property real expandedHeight: collapsedHeight + Theme.musicTopGap
                                           + panel.implicitHeight + Theme.musicBottomPadding
    // One animated coordinate drives geometry and the single media presentation.
    property real reveal: expanded ? 1 : 0
    // Ignore subpixel measurement noise when identifying additional widgets.
    readonly property bool otherWidgetsVisible: widgets.contentWidth > spotifySlot.width + 0.1
    implicitHeight: Math.max(notch.height + Theme.screenFrameWidth, widgets.y + widgets.height)

    function openMusic(): void {
        if (SpotifyService.available) {
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
        shoulderWidth: root.interpolate(Theme.notchShoulderWidth, Theme.musicShoulderWidth)
        shoulderHeight: root.interpolate(Theme.notchShoulderHeight, Theme.musicShoulderHeight)
        shoulderCurve: root.interpolate(Theme.notchShoulderCurve, Theme.musicShoulderCurve)
        outlineSpan: root.frameOpeningWidth
        backgroundActive: root.expanded || root.reveal > 0
        background: Component {
            MusicBackdrop {
                artworkSource: SpotifyService.artworkSource
                playing: SpotifyService.playing
                trackTitle: SpotifyService.title
                headerHeight: root.collapsedHeight
                shoulderWidth: notch.shoulder
                active: root.active && root.expanded
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
        x: {
            if (root.otherWidgetsVisible)
                return root.interpolate(root.compactWidgetsX, notch.x + notch.width
                                        + Theme.notchWidgetsGap);
            return root.compactWidgetsX;
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

    RectangularShadow {
        anchors.fill: music
        radius: music.width / 2
        blur: Theme.artworkGlowBlur
        spread: Theme.artworkGlowSpread
        color: Qt.alpha(Theme.accentPrimary, Theme.artworkGlowOpacity)
        opacity: root.reveal
        visible: music.visible && opacity > 0
    }

    SpotifyWidget {
        id: music
        readonly property real compactX: root.compactWidgetsX + Theme.widgetsHorizontalPadding
        readonly property real expandedX: root.width / 2 - root.expandedWidth / 2
                                          + Theme.musicShoulderWidth + Theme.musicPadding
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
        x: notch.x + notch.shoulder + Theme.musicPadding
        y: root.collapsedHeight + Theme.musicTopGap
        width: Math.max(0, notch.width - (notch.shoulder + Theme.musicPadding) * 2)
        // Reveal controls during the final part of geometry, without a second
        // sequential fade that delays the useful end of an otherwise fast open.
        opacity: {
            const start = Theme.contentRevealStart;
            return Math.max(0, (root.reveal - start) / (1 - start));
        }
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
        canSeek: SpotifyService.canSeek
        onPreviousRequested: SpotifyService.previous()
        onNextRequested: SpotifyService.next()
        onToggleRequested: SpotifyService.togglePlayback()
        onSeekRequested: seconds => SpotifyService.seekTo(seconds)
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
            if (!SpotifyService.available)
                root.expanded = false;
        }
    }
}
