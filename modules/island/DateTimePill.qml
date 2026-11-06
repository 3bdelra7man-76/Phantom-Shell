import QtQuick
import Quickshell
import qs.components
import qs.core

Pill {
    id: root

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Row {
        spacing: Theme.dateTimeGap

        Text {
            text: Qt.formatDateTime(clock.date, Config.dateFormat)
            color: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.dateFontSize
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: Qt.formatDateTime(clock.date, Config.timeFormat)
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.timeFontSize
            font.weight: Font.Medium
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
