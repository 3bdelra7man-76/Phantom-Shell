import QtQuick
import Quickshell
import qs.core

PanelWindow {
    id: root

    // An empty or unmatched name lets the platform choose its default screen.
    screen: Quickshell.screens.find(output => output.name === Config.screenName) ?? null
    // Full width makes the notch's horizontal center a screen coordinate,
    // independent of the number or width of widgets on its right.
    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: Math.ceil(island.implicitHeight)
    color: "transparent"
    aboveWindows: true
    focusable: false
    exclusionMode: ExclusionMode.Ignore
    // An empty input region passes ALL pointer input to the desktop below.
    mask: Region {}

    Island {
        id: island
        anchors.fill: parent
        active: root.visible && root.backingWindowVisible
    }
}
