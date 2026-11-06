import QtQuick
import Quickshell
import qs.core

PanelWindow {
    id: root

    // An empty or unmatched name lets the platform choose its default screen.
    screen: Quickshell.screens.find(output => output.name === Config.screenName) ?? null
    anchors.top: true
    margins.top: Config.topMargin
    implicitWidth: Math.ceil(island.implicitWidth)
    implicitHeight: Math.ceil(island.implicitHeight)
    color: "transparent"
    aboveWindows: true
    focusable: false
    exclusionMode: ExclusionMode.Ignore
    // An empty input region passes ALL pointer input to the desktop below.
    mask: Region {}

    Island {
        id: island
        anchors.centerIn: parent
        active: root.visible && root.backingWindowVisible
    }
}
