import QtQuick
import QtQuick.Shapes

// One contour definition serves the fill, media clipping and screen outline.
ShapePath {
    id: root

    required property real surfaceWidth
    required property real surfaceHeight
    required property real shoulderWidth
    required property real shoulderHeight
    required property real shoulderCurve
    required property real bottomRadius
    property real offsetX: 0
    property real topInset: 0
    property real leftExtension: 0
    property real rightExtension: 0
    property bool closeTop: true

    startX: offsetX - leftExtension
    startY: topInset
    joinStyle: ShapePath.RoundJoin
    capStyle: ShapePath.FlatCap

    PathLine {
        x: root.offsetX
        y: root.topInset
    }
    PathCubic {
        x: root.offsetX + root.shoulderWidth
        y: root.shoulderHeight
        control1X: root.offsetX + root.shoulderWidth * root.shoulderCurve
        control1Y: root.topInset
        control2X: x
        control2Y: root.topInset + (y - root.topInset) * (1 - root.shoulderCurve)
    }
    PathLine {
        x: root.offsetX + root.shoulderWidth
        y: root.surfaceHeight - root.bottomRadius
    }
    PathArc {
        x: root.offsetX + root.shoulderWidth + root.bottomRadius
        y: root.surfaceHeight
        radiusX: root.bottomRadius
        radiusY: root.bottomRadius
        direction: PathArc.Counterclockwise
    }
    PathLine {
        x: root.offsetX + root.surfaceWidth - root.shoulderWidth - root.bottomRadius
        y: root.surfaceHeight
    }
    PathArc {
        x: root.offsetX + root.surfaceWidth - root.shoulderWidth
        y: root.surfaceHeight - root.bottomRadius
        radiusX: root.bottomRadius
        radiusY: root.bottomRadius
        direction: PathArc.Counterclockwise
    }
    PathLine {
        x: root.offsetX + root.surfaceWidth - root.shoulderWidth
        y: root.shoulderHeight
    }
    PathCubic {
        x: root.offsetX + root.surfaceWidth
        y: root.topInset
        control1X: root.offsetX + root.surfaceWidth - root.shoulderWidth
        control1Y: root.topInset + (root.shoulderHeight - root.topInset) * (1 - root.shoulderCurve)
        control2X: x - root.shoulderWidth * root.shoulderCurve
        control2Y: root.topInset
    }
    PathLine {
        x: root.offsetX + root.surfaceWidth + root.rightExtension
        y: root.topInset
    }
    PathLine {
        x: root.closeTop ? root.startX : root.offsetX + root.surfaceWidth + root.rightExtension
        y: root.topInset
    }
}
