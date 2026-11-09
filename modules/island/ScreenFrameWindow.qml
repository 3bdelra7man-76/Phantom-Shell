import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import qs.components
import qs.core

PanelWindow {
    id: root

    required property real openingWidth
    readonly property real thickness: Theme.screenFrameWidth
    readonly property real outlineWidth: Theme.screenFrameWidth
    readonly property real innerRadius: {
        const available = Math.min(width, height) / 2 - thickness;
        return Math.max(0, Math.min(Theme.screenFrameInnerRadius, available));
    }
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    color: "transparent"
    focusable: false
    exclusionMode: ExclusionMode.Ignore
    mask: Region {}
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qp-frame"

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        ScreenFrameContour {
            surfaceWidth: root.width
            surfaceHeight: root.height
            openingWidth: root.openingWidth
            inset: root.thickness
            cornerRadius: root.innerRadius
            closeOuterEdge: true
            fillColor: Theme.screenFrameFill
            strokeColor: "transparent"
        }
        ScreenFrameContour {
            surfaceWidth: root.width
            surfaceHeight: root.height
            openingWidth: root.openingWidth
            // Offset the stroke into the black border. Both paths have the
            // same corner centers, and the stroke's inner edge meets the fill.
            inset: root.thickness - root.outlineWidth / 2
            cornerRadius: root.innerRadius + root.outlineWidth / 2
            fillColor: "transparent"
            strokeColor: Qt.alpha(Theme.screenFrameColor, Theme.screenFrameOpacity)
            strokeWidth: root.outlineWidth
        }
    }
}
