import QtQuick
import QtQuick.Shapes

// Shared inner contour. The fill closes around the physical outer boundary;
// the outline follows only the desktop opening and the fixed notch joins.
ShapePath {
    id: root

    required property real surfaceWidth
    required property real surfaceHeight
    required property real openingWidth
    required property real inset
    required property real cornerRadius
    property bool closeOuterEdge: false
    readonly property real leftJoin: (surfaceWidth - openingWidth) / 2
    readonly property real rightJoin: (surfaceWidth + openingWidth) / 2
    startX: leftJoin
    startY: inset
    capStyle: ShapePath.FlatCap

    PathLine {
        x: root.inset + root.cornerRadius
        y: root.inset
    }
    PathArc {
        x: root.inset
        y: root.inset + root.cornerRadius
        radiusX: root.cornerRadius
        radiusY: root.cornerRadius
        direction: PathArc.Counterclockwise
    }
    PathLine {
        x: root.inset
        y: root.surfaceHeight - root.inset - root.cornerRadius
    }
    PathArc {
        x: root.inset + root.cornerRadius
        y: root.surfaceHeight - root.inset
        radiusX: root.cornerRadius
        radiusY: root.cornerRadius
        direction: PathArc.Counterclockwise
    }
    PathLine {
        x: root.surfaceWidth - root.inset - root.cornerRadius
        y: root.surfaceHeight - root.inset
    }
    PathArc {
        x: root.surfaceWidth - root.inset
        y: root.surfaceHeight - root.inset - root.cornerRadius
        radiusX: root.cornerRadius
        radiusY: root.cornerRadius
        direction: PathArc.Counterclockwise
    }
    PathLine {
        x: root.surfaceWidth - root.inset
        y: root.inset + root.cornerRadius
    }
    PathArc {
        x: root.surfaceWidth - root.inset - root.cornerRadius
        y: root.inset
        radiusX: root.cornerRadius
        radiusY: root.cornerRadius
        direction: PathArc.Counterclockwise
    }
    PathLine {
        x: root.rightJoin
        y: root.inset
    }
    // Collapsing the remaining segments leaves an open path for the outline.
    PathLine {
        x: root.rightJoin
        y: root.closeOuterEdge ? 0 : root.inset
    }
    PathLine {
        x: root.closeOuterEdge ? root.surfaceWidth : root.rightJoin
        y: root.closeOuterEdge ? 0 : root.inset
    }
    PathLine {
        x: root.closeOuterEdge ? root.surfaceWidth : root.rightJoin
        y: root.closeOuterEdge ? root.surfaceHeight : root.inset
    }
    PathLine {
        x: root.closeOuterEdge ? 0 : root.rightJoin
        y: root.closeOuterEdge ? root.surfaceHeight : root.inset
    }
    PathLine {
        x: root.closeOuterEdge ? 0 : root.rightJoin
        y: root.closeOuterEdge ? 0 : root.inset
    }
    PathLine {
        x: root.closeOuterEdge ? root.leftJoin : root.rightJoin
        y: root.closeOuterEdge ? 0 : root.inset
    }
    PathLine {
        x: root.closeOuterEdge ? root.leftJoin : root.rightJoin
        y: root.inset
    }
}
