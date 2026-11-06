import QtQuick
import Quickshell.Widgets
import qs.core

ClippingRectangle {
    id: root

    required property url source
    property int decodedSize: Theme.artworkDecodedSize
    readonly property bool ready: artwork.status === Image.Ready

    implicitWidth: Theme.artworkDiameter
    implicitHeight: implicitWidth
    radius: Math.min(width, height) / 2
    color: Theme.artworkFallback
    antialiasing: true

    Text {
        anchors.centerIn: parent
        text: "♪"
        color: Theme.artworkGlyph
        font.pixelSize: Theme.fallbackFontSize
        visible: !root.ready || artwork.opacity < 1
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
}
