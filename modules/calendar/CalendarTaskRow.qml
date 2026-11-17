pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls
import qs.components
import qs.core

Item {
    id: root

    required property string taskId
    required property string taskText
    required property bool completed
    required property bool editing
    required property string draft
    signal toggleRequested
    signal editRequested
    signal deleteRequested
    signal saveRequested
    signal cancelRequested
    signal draftEdited(string text)
    implicitHeight: Theme.calendarTaskHeight

    Rectangle {
        anchors.fill: parent
        color: Theme.calendarHoverTint
        opacity: rowHover.hovered ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: Theme.hoverFeedbackDuration
            }
        }
    }
    HoverHandler {
        id: rowHover
        blocking: false
    }
    Rectangle {
        anchors.bottom: parent.bottom
        x: Theme.calendarRowPadding
        width: parent.width - x * 2
        height: 1
        color: Theme.calendarSeparator
    }
    IconButton {
        id: checkbox
        x: Theme.calendarRowPadding
        anchors.verticalCenter: parent.verticalCenter
        width: Theme.calendarActionSize
        height: width
        glyph: root.completed ? "checked" : "unchecked"
        glyphColor: root.completed ? Theme.accentPrimary : Theme.calendarMutedText
        glyphHoverColor: Theme.accentForeground
        actionName: root.completed ? "Reopen task" : "Complete task"
        Accessible.role: Accessible.CheckBox
        Accessible.checkable: true
        Accessible.checked: root.completed
        onClicked: root.toggleRequested()
    }
    SharedText {
        id: title
        x: checkbox.x + checkbox.width + Theme.controlGap
        anchors.verticalCenter: parent.verticalCenter
        width: Math.max(0, editButton.x - x - Theme.controlGap)
        visible: !root.editing
        text: root.taskText
        font.pixelSize: Theme.calendarFontSize
        font.strikeout: root.completed
        color: root.completed ? Theme.calendarMutedText : Theme.calendarText
        elide: Text.ElideRight
        HoverHandler {
            id: titleHover
            blocking: false
        }
    }
    // No editor exists for ordinary rows, including cached/pooled delegates.
    Loader {
        id: editorLoader
        x: title.x
        width: title.width
        height: Theme.inputHeight
        anchors.verticalCenter: parent.verticalCenter
        active: root.editing
        sourceComponent: SharedTextField {
            text: root.draft
            Accessible.name: "Edit task"
            onTextEdited: root.draftEdited(text)
            onAccepted: root.saveRequested()
            Keys.onEscapePressed: event => {
                root.cancelRequested();
                event.accepted = true;
            }
        }
        onLoaded: Qt.callLater(function () {
            const editor = editorLoader.item as SharedTextField;
            if (root.editing && editor) {
                editor.forceActiveFocus();
                editor.selectAll();
            }
        })
    }
    Loader {
        active: titleHover.hovered && title.truncated && !root.editing && root.visible
        sourceComponent: Controls.ToolTip {
            parent: title
            visible: true
            delay: Theme.tooltipDelay
            width: Theme.calendarTooltipWidth
            contentItem: SharedText {
                text: root.taskText
                font.pixelSize: Theme.calendarFontSize
                color: Theme.calendarText
                wrapMode: Text.Wrap
                // Qt's default unlimited line count: show the complete title.
                maximumLineCount: 2147483647
            }
            background: Rectangle {
                color: Theme.calendarSurface
                radius: Theme.calendarSurfaceRadius
                border.color: Theme.calendarSeparator
            }
        }
    }
    IconButton {
        id: editButton
        x: parent.width - Theme.calendarRowPadding - width * 2 - Theme.controlGap
        anchors.verticalCenter: parent.verticalCenter
        width: Theme.calendarActionSize
        height: width
        glyph: root.editing ? "confirm" : "edit"
        glyphColor: root.editing ? Theme.accentForeground : Theme.calendarMutedText
        glyphHoverColor: Theme.accentForeground
        actionName: root.editing ? "Save task" : "Edit task"
        enabled: !root.editing || root.draft.trim().length > 0
        onClicked: root.editing ? root.saveRequested() : root.editRequested()
    }
    IconButton {
        x: parent.width - Theme.calendarRowPadding - width
        anchors.verticalCenter: parent.verticalCenter
        width: Theme.calendarActionSize
        height: width
        glyph: "delete"
        glyphColor: Theme.calendarMutedText
        glyphHoverColor: Theme.accentForeground
        actionName: "Delete task"
        onClicked: root.deleteRequested()
    }
}
