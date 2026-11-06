import QtQuick
import qs.components
import qs.core

Item {
    id: root

    required property url artworkSource
    required property real progress
    required property bool playing
    required property bool progressSupported
    required property bool active
    signal refreshRequested

    implicitWidth: Theme.artworkDiameter
    implicitHeight: implicitWidth

    CircularArtwork {
        anchors.fill: parent
        anchors.margins: Theme.progressWidth + Theme.artworkRingGap
        source: root.artworkSource
    }

    CircularProgress {
        anchors.fill: parent
        value: root.progress
    }

    // One modest timer, owned by the visible consumer and destroyed on reload.
    Timer {
        interval: Config.progressRefreshInterval
        running: root.active && root.visible && root.playing && root.progressSupported
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshRequested()
    }

    // Also refresh the frozen position immediately when playback pauses.
    onPlayingChanged: refreshRequested()
}
