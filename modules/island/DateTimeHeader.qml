import QtQuick
import Quickshell
import qs.components
import qs.core

Row {
    id: root

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    spacing: Theme.dateTimeGap

    SharedText {
        text: Qt.formatDateTime(clock.date, Config.dateFormat)
        color: Theme.textSecondary
        font.pixelSize: Theme.dateFontSize
        anchors.verticalCenter: parent.verticalCenter
    }

    SharedText {
        text: Qt.formatDateTime(clock.date, Config.timeFormat)
        color: Theme.textPrimary
        font.pixelSize: Theme.timeFontSize
        font.weight: Font.Medium
        anchors.verticalCenter: parent.verticalCenter
    }
}
