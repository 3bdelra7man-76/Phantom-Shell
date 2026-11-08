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

    // The overlay panel above this surface receives inside presses. The first
    // outside click is consumed here. Complete its release before unmapping so
    // the compositor can end the pointer grab and route the next click normally.
    MouseArea {
        anchors.fill: parent
        enabled: !root.dragging
        acceptedButtons: Qt.AllButtons
        onClicked: root.dismissRequested()
    }
}
