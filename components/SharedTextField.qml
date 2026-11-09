import QtQuick
import QtQuick.Controls.Basic as Controls
import qs.core

Controls.TextField {
    id: root

    implicitHeight: Theme.todoFieldHeight
    leftPadding: Theme.todoFieldPadding
    rightPadding: Theme.todoFieldPadding
    font.family: Theme.effectiveFontFamily
    font.pixelSize: Theme.todoFontSize
    color: Theme.todoText
    placeholderTextColor: Theme.todoMutedText
    selectionColor: Theme.accentPrimary
    selectedTextColor: Theme.textPrimary
    selectByMouse: true
    HoverHandler {
        enabled: root.enabled
        cursorShape: Qt.IBeamCursor
        blocking: false
    }
    background: Rectangle {
        color: Theme.todoFieldBackground
        radius: Theme.todoFieldRadius
        border.color: root.activeFocus ? Theme.accentPrimary : Theme.todoSeparator
    }
}
