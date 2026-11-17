import QtQuick
import QtQuick.Controls.Basic as Controls
import qs.core

Controls.TextField {
    id: root

    implicitHeight: Theme.inputHeight
    leftPadding: Theme.inputPadding
    rightPadding: Theme.inputPadding
    font.family: Theme.effectiveFontFamily
    font.pixelSize: Theme.inputFontSize
    color: Theme.calendarText
    placeholderTextColor: Theme.calendarMutedText
    selectionColor: Theme.accentPrimary
    selectedTextColor: Theme.textPrimary
    selectByMouse: true
    HoverHandler {
        enabled: root.enabled
        cursorShape: Qt.IBeamCursor
        blocking: false
    }
    background: Rectangle {
        color: Theme.calendarSurface
        radius: Theme.inputRadius
        border.color: root.activeFocus ? Theme.accentPrimary : Theme.calendarSeparator
    }
}
