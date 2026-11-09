import QtQuick
import qs.components
import qs.core

Item {
    id: root

    required property string title
    required property string artist
    required property bool playing
    required property real position
    required property real duration
    required property string trackKey
    required property bool canPrevious
    required property bool canNext
    required property bool canTogglePlayback
    required property bool canSeek
    readonly property bool dragging: timeline.dragging
    signal previousRequested
    signal nextRequested
    signal toggleRequested
    signal seekRequested(real seconds)

    implicitWidth: Theme.musicContentWidth
    implicitHeight: controls.y + controls.height

    // The single migrating SpotifyWidget occupies the blank artwork slot.
    Column {
        x: Theme.musicArtworkDiameter + Theme.musicMetadataGap
        y: (Theme.musicArtworkDiameter - height) / 2
        width: Math.max(0, root.width - x)
        spacing: Theme.controlGap

        SharedText {
            width: parent.width
            text: root.title || "Unknown title"
            font.pixelSize: Theme.titleFontSize
            font.weight: Font.Medium
            elide: Text.ElideRight
        }

        SharedText {
            width: parent.width
            text: root.artist || "Unknown artist"
            font.pixelSize: Theme.artistFontSize
            color: Theme.textSecondary
            elide: Text.ElideRight
        }
    }

    PlaybackTimeline {
        id: timeline
        y: Theme.musicArtworkDiameter + Theme.musicSectionGap
        width: parent.width
        position: root.position
        duration: root.duration
        contextKey: root.trackKey
        seekable: root.canSeek
        onSeekRequested: seconds => root.seekRequested(seconds)
    }

    Row {
        id: controls
        anchors.horizontalCenter: parent.horizontalCenter
        y: timeline.y + timeline.height + Theme.musicSectionGap
        spacing: Theme.controlGap

        IconButton {
            glyph: "previous"
            actionName: "Previous track"
            enabled: root.canPrevious
            onClicked: root.previousRequested()
        }
        IconButton {
            glyph: root.playing ? "pause" : "play"
            actionName: root.playing ? "Pause" : "Play"
            enabled: root.canTogglePlayback
            onClicked: root.toggleRequested()
        }
        IconButton {
            glyph: "next"
            actionName: "Next track"
            enabled: root.canNext
            onClicked: root.nextRequested()
        }
    }
}
