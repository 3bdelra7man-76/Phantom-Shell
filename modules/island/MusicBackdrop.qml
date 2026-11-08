import QtQuick
import qs.components
import qs.core
import qs.services

Item {
    id: root

    required property url artworkSource
    required property bool active
    required property bool playing
    required property string trackTitle
    required property real headerHeight
    required property real shoulderWidth
    readonly property string sourceKind: artwork.status === Image.Ready ? "artwork" : "black"
    readonly property string graphMode: graph.mode

    // MPRIS supplies cover art, not a playable Spotify Canvas/video URL.
    Image {
        id: artwork
        anchors.fill: parent
        source: root.artworkSource
        asynchronous: true
        fillMode: Image.PreserveAspectCrop
        sourceSize: Qt.size(Theme.backgroundDecodedSize, Theme.backgroundDecodedSize)
        opacity: status === Image.Ready ? Theme.backgroundArtworkOpacity : 0
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.surfaceBackground
        opacity: Theme.backgroundScrimOpacity
    }

    // Bounded to the header; the remainder keeps its existing artwork opacity.
    Rectangle {
        width: parent.width
        height: root.headerHeight + Theme.headerShadowExtraHeight
        gradient: Gradient {
            GradientStop {
                position: 0
                color: Qt.alpha(Theme.surfaceBackground, Theme.headerShadowOpacity)
            }
            GradientStop {
                position: 1
                color: "transparent"
            }
        }
    }

    SpotifyAudioMonitor {
        id: audio
        active: root.active
        playing: root.playing
        trackTitle: root.trackTitle
    }

    MusicGraph {
        id: graph
        x: root.shoulderWidth
        anchors.bottom: parent.bottom
        width: Math.max(0, parent.width - x * 2)
        height: Theme.graphHeight
        active: root.active
        playing: root.playing
        hasSamples: audio.hasSamples
        peak: audio.peak
    }
}
