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
        case "calendar":
            return "M5 2 H7 V5 H17 V2 H19 V5 H22 V22 H2 V5 H5 Z M4 10 V20 H20 V10 Z M6 12 H9 V15 H6 Z M11 12 H14 V15 H11 Z M16 12 H19 V15 H16 Z M6 16 H9 V19 H6 Z M11 16 H14 V19 H11 Z";
        case "left":
            return "M15 3 L6 12 L15 21 L17 19 L10 12 L17 5 Z";
        case "right":
            return "M9 3 L18 12 L9 21 L7 19 L14 12 L7 5 Z";
        case "close":
            return "M5 3 L12 10 L19 3 L21 5 L14 12 L21 19 L19 21 L12 14 L5 21 L3 19 L10 12 L3 5 Z";
        case "add":
            return "M11 4 H13 V11 H20 V13 H13 V20 H11 V13 H4 V11 H11 Z";
        case "edit":
            return "M4 16 L15 5 L19 9 L8 20 L3 21 Z M16 4 L18 2 L22 6 L20 8 Z";
        case "delete":
            return "M4 5 H9 V3 H15 V5 H20 V7 H4 Z M6 9 H18 L17 22 H7 Z";
        case "confirm":
            return "M3 12 L8 17 L20 4 L22 6 L8 21 L1 14 Z";
        case "unchecked":
            return "M3 3 H21 V21 H3 Z M5 5 V19 H19 V5 Z";
        case "checked":
            return "M3 3 H21 V21 H3 Z M5 12 L10 17 L19 7 L17 5 L10 13 L7 10 Z";
        default:
            return "";
        }
    }
    implicitWidth: Theme.controlIconSize
    implicitHeight: implicitWidth

    // Playback and task actions share one filled 24-unit vector grid.
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
