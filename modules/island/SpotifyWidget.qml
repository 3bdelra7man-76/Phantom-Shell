import QtQuick
import qs.components
import qs.core

Item {
    id: root

    required property url artworkSource
    required property real progress
    required property bool paused
    property real ringWidth: Theme.progressWidth
    property real artworkGap: Theme.artworkRingGap

    implicitWidth: Theme.artworkDiameter
    implicitHeight: implicitWidth

    CircularArtwork {
        anchors.fill: parent
        anchors.margins: root.ringWidth + root.artworkGap
        source: root.artworkSource
        showPauseIndicator: root.paused
        iconScale: root.width / Theme.artworkDiameter
        // A stable decode size avoids reloading the image on animation frames.
        decodedSize: Theme.musicArtworkDecodedSize
    }

    CircularProgress {
        anchors.fill: parent
        value: root.progress
        lineWidth: root.ringWidth
    }
}
