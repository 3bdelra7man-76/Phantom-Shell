import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    required property bool armed
    required property bool dragging
    signal dismissRequested

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    visible: armed
    color: "transparent"
    focusable: false
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "qp-dismissal"

    // A passive grab survives Qt's window-deactivation cleanup when the
    // OnDemand editor loses focus. Close on release so the compositor finishes
    // its pointer grab before this window unmaps; the following click passes.
    Item {
        anchors.fill: parent
        TapHandler {
            enabled: !root.dragging
            acceptedButtons: Qt.AllButtons
            gesturePolicy: TapHandler.DragThreshold
            onTapped: root.dismissRequested()
        }
    }
}
