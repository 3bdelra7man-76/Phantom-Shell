import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import qs.core

PanelWindow {
    id: root

    required property real openingWidth
    readonly property real inset: Theme.screenFrameWidth / 2
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

    // Never bound to reveal: this surface and its outer path stay static.
    // The local notch outline bridges these exact, flat-ended top endpoints.
    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            fillColor: "transparent"
            strokeColor: Qt.alpha(Theme.screenFrameColor, Theme.screenFrameOpacity)
            strokeWidth: Theme.screenFrameWidth
            capStyle: ShapePath.FlatCap
            joinStyle: ShapePath.MiterJoin
            startX: (root.width - root.openingWidth) / 2
            startY: root.inset
            PathLine {
                x: root.inset
                y: root.inset
            }
            PathLine {
                x: root.inset
                y: root.height - root.inset
            }
            PathLine {
                x: root.width - root.inset
                y: root.height - root.inset
            }
            PathLine {
                x: root.width - root.inset
                y: root.inset
            }
            PathLine {
                x: (root.width + root.openingWidth) / 2
                y: root.inset
            }
        }
    }
}
