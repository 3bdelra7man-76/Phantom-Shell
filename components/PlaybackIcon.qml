import QtQuick
import QtQuick.Shapes
import qs.core

Item {
    id: root

    required property string icon
    property color color: icon === "pause" ? Theme.pauseIcon : Theme.accentForeground
    readonly property string path: {
        switch (icon) {
        case "previous":
            return "M5 5 H8 V19 H5 Z M19 5 V19 L9 12 Z";
        case "next":
            return "M16 5 H19 V19 H16 Z M5 5 L15 12 L5 19 Z";
        case "play":
            return "M8 5 L20 12 L8 19 Z";
        case "pause":
            return "M6 5 H10 V19 H6 Z M14 5 H18 V19 H14 Z";
        case "stop":
            return "M6 6 H18 V18 H6 Z";
        default:
            return "";
        }
    }
    implicitWidth: Theme.controlIconSize
    implicitHeight: implicitWidth

    // A shared 24-unit vector grid keeps the five glyphs consistent at any DPI.
    Shape {
        anchors.centerIn: parent
        width: 24
        height: 24
        scale: Math.min(root.width, root.height) / 24
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"
            PathSvg {
                path: root.path
            }
        }
    }
}
