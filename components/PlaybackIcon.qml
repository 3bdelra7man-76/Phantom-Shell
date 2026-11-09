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
        case "checklist":
            return "M3 5 L5 7 L8 3 L9.5 4 L5 10 L1.5 6 Z M11 5 H22 V7 H11 Z M3 12 H7 V16 H3 Z M11 13 H22 V15 H11 Z M3 19 H7 V23 H3 Z M11 20 H22 V22 H11 Z";
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
