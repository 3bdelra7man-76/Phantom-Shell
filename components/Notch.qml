import QtQuick
import QtQuick.Shapes
import qs.core

Item {
    id: root

    default property alias content: contentContainer.data
    readonly property alias contentItem: contentContainer
    property color color: Theme.surfaceBackground
    property real minimumHeight: Theme.notchHeight
    property real horizontalPadding: Theme.notchHorizontalPadding
    property real verticalPadding: Theme.notchVerticalPadding
    property real bottomCornerRadius: Theme.notchBottomRadius
    property real shoulderWidth: Theme.notchShoulderWidth
    property real shoulderHeight: Theme.notchShoulderHeight
    property real shoulderCurve: Theme.notchShoulderCurve

    readonly property real shoulder: Math.max(0, shoulderWidth)
    readonly property real shoulderDepth: Math.max(0, shoulderHeight)
    readonly property real bottomRadius: {
        const availableWidth = (width - shoulder * 2) / 2;
        const availableHeight = height - shoulderDepth;
        return Math.max(0, Math.min(bottomCornerRadius, availableWidth, availableHeight));
    }

    // Both shoulders are inside these bounds, outside the padded content body.
    implicitWidth: Math.max(contentContainer.implicitWidth + horizontalPadding * 2,
                            bottomCornerRadius * 2) + shoulder * 2
    implicitHeight: Math.max(minimumHeight, contentContainer.implicitHeight + verticalPadding * 2,
                             shoulderDepth + bottomCornerRadius)

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"
            strokeWidth: 0
            startX: 0
            startY: 0

            PathLine {
                x: root.width
                y: 0
            }
            // Horizontal top tangents and vertical side tangents stay smooth
            // while shoulder spread varies independently of the notch height.
            PathCubic {
                x: root.width - root.shoulder
                y: root.shoulderDepth
                control1X: root.width - root.shoulder * root.shoulderCurve
                control1Y: 0
                control2X: x
                control2Y: y * (1 - root.shoulderCurve)
            }
            PathLine {
                x: root.width - root.shoulder
                y: root.height - root.bottomRadius
            }
            PathArc {
                x: root.width - root.shoulder - root.bottomRadius
                y: root.height
                radiusX: root.bottomRadius
                radiusY: root.bottomRadius
                direction: PathArc.Clockwise
            }
            PathLine {
                x: root.shoulder + root.bottomRadius
                y: root.height
            }
            PathArc {
                x: root.shoulder
                y: root.height - root.bottomRadius
                radiusX: root.bottomRadius
                radiusY: root.bottomRadius
                direction: PathArc.Clockwise
            }
            PathLine {
                x: root.shoulder
                y: root.shoulderDepth
            }
            PathCubic {
                x: 0
                y: 0
                control1X: root.shoulder
                control1Y: root.shoulderDepth * (1 - root.shoulderCurve)
                control2X: root.shoulder * root.shoulderCurve
                control2Y: 0
            }
        }
    }

    Item {
        id: contentContainer
        anchors.centerIn: parent
        implicitWidth: childrenRect.width
        implicitHeight: childrenRect.height
        width: implicitWidth
        height: implicitHeight
    }
}
