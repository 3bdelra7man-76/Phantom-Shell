import QtQuick
import QtQuick.Shapes
import qs.core

Item {
    id: root

    required property real value
    property real lineWidth: Theme.progressWidth
    property color accent: Theme.progressAccent
    property color trackColor: Theme.progressTrack
    readonly property real normalizedValue: {
        return Number.isFinite(value) ? Math.max(0, Math.min(1, value)) : 0;
    }
    readonly property real diameter: Math.min(width, height)
    readonly property real arcRadius: Math.max(0, (diameter - lineWidth) / 2)

    implicitWidth: Theme.artworkDiameter
    implicitHeight: implicitWidth

    Rectangle {
        anchors.centerIn: parent
        width: root.diameter
        height: width
        radius: width / 2
        color: "transparent"
        border.width: root.lineWidth
        border.pixelAligned: false
        border.color: root.normalizedValue === 1 ? root.accent : root.trackColor
        antialiasing: true
    }

    // Separate full/empty cases avoid degenerate arcs and round-cap dots at zero.
    Shape {
        anchors.fill: parent
        visible: root.normalizedValue > 0 && root.normalizedValue < 1
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: root.accent
            strokeWidth: root.lineWidth
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"

            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root.arcRadius
                radiusY: root.arcRadius
                startAngle: -90
                sweepAngle: 360 * root.normalizedValue
            }
        }
    }
}
