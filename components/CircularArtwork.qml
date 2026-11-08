pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Widgets
import qs.core

ClippingRectangle {
    id: root

    required property url source
    // Presentation only: the caller decides which playback state merits this.
    property bool showPauseIndicator: false
    property real iconScale: 1
    property int decodedSize: Theme.artworkDecodedSize
    readonly property bool ready: artwork.status === Image.Ready

    implicitWidth: Theme.artworkDiameter
    implicitHeight: implicitWidth
    radius: Math.min(width, height) / 2
    color: Theme.artworkFallback
    antialiasing: true

    SharedText {
        anchors.centerIn: parent
        text: "♪"
        color: Theme.artworkGlyph
        font.pixelSize: Math.round(Theme.fallbackFontSize * root.iconScale)
        visible: !root.ready || artwork.opacity < 1
        opacity: 1 - pausedPresentation.opacity
    }

    Image {
        id: artwork
        anchors.fill: parent
        source: root.source
        asynchronous: true
        sourceSize: Qt.size(root.decodedSize, root.decodedSize)
        fillMode: Image.PreserveAspectCrop
        smooth: true
        opacity: root.ready ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.artworkFadeDuration
            }
        }
    }

    // These siblings are clipped along with the image. The ring is outside
    // this component, so dimming never affects its color or brightness.
    Item {
        id: pausedPresentation
        anchors.fill: parent
        opacity: root.showPauseIndicator ? 1 : 0
        visible: opacity > 0

        Rectangle {
            anchors.fill: parent
            color: Theme.artworkShade
            opacity: Theme.pausedOverlayOpacity
        }

        Row {
            anchors.centerIn: parent
            spacing: Theme.pauseBarGap * root.iconScale

            Repeater {
                model: 2

                Rectangle {
                    width: Theme.pauseBarWidth * root.iconScale
                    height: Theme.pauseBarHeight * root.iconScale
                    color: Theme.pauseIcon
                }
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.pauseFadeDuration
            }
        }
    }
}
