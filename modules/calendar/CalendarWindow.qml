import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.core
import qs.services

PanelWindow {
    id: root

    required property bool opened
    signal dismissRequested
    readonly property alias panel: calendarPanel
    readonly property ShellScreen targetScreen: screen
    property real reveal: opened ? 1 : 0
    // No anchors centers this layer-shell surface on its selected output.
    // The native size stays fixed during the local opacity transition.
    implicitWidth: Math.round(Math.max(1, Math.min(Math.max(targetScreen.width * Theme.calendarWidthRatio,
                                                            Theme.calendarMinimumWidth),
                                                   targetScreen.width - Theme.calendarScreenMargin
                                                   * 2)))
    implicitHeight: Math.round(Math.max(1, Math.min(Math.max(targetScreen.height * Theme.calendarHeightRatio,
                                                             Theme.calendarMinimumHeight),
                                                    targetScreen.height
                                                    - Theme.calendarScreenMargin * 2)))
    visible: opened || reveal > 0
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qp-calendar"
    WlrLayershell.keyboardFocus: opened ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    mask: Region {
        width: root.opened ? root.width : 0
        height: root.opened ? root.height : 0
        radius: Theme.calendarRadius
    }
    Behavior on reveal {
        NumberAnimation {
            duration: Theme.calendarTransitionDuration
            easing.type: Easing.OutCubic
        }
    }
    onOpenedChanged: {
        if (opened)
            calendarPanel.resetToToday();
        else
            calendarPanel.releaseEditors();
    }
    Rectangle {
        anchors.fill: parent
        radius: Theme.calendarRadius
        color: Theme.calendarBackground
        border.color: Theme.accentMuted
        opacity: root.reveal
        CalendarPanel {
            id: calendarPanel
            anchors.fill: parent
            store: CalendarStore
            enabled: root.opened
            onDismissRequested: root.dismissRequested()
        }
    }
}
