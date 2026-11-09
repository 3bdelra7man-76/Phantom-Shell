pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic as Controls
import QtQml.Models
import Quickshell.Widgets
import qs.components
import qs.core
import qs.services

FocusScope {
    id: root

    required property TaskStore store
    property string filter: "all"
    property string editingId: ""
    property string draft: ""
    property bool _listRequested: false
    readonly property alias taskList: listLoader.item
    signal closeRequested
    implicitWidth: Theme.todoContentWidth
    // Row contents, typing and scrolling never determine notch geometry.
    implicitHeight: Theme.todoHeaderHeight + Theme.todoFieldHeight + Theme.todoFilterHeight
                    + Theme.todoListHeight + Theme.todoStatusHeight + Theme.todoSectionGap * 4

    SortFilterProxyModel {
        id: filteredTasks
        sourceModel: root.store.model
        filters: ValueFilter {
            roleName: "completed"
            value: root.filter === "completed"
            enabled: root.filter !== "all"
        }
    }

    function focusInput(): void {
        if (enabled) {
            root.forceActiveFocus();
            if (input.enabled)
                input.forceActiveFocus();
        }
    }
    function addTask(): void {
        if (store.add(input.text)) {
            input.clear();
            focusInput();
        }
    }
    function cancelEdit(): void {
        editingId = "";
        draft = "";
        focusInput();
    }
    function saveEdit(): void {
        if (store.rename(editingId, draft))
            cancelEdit();
    }
    function handleEscape(): void {
        if (editingId)
            cancelEdit();
        else
            closeRequested();
    }
    onEnabledChanged: {
        if (enabled) {
            _listRequested = true;
            Qt.callLater(focusInput);
        } else {
            editingId = "";
            draft = "";
            focus = false;
        }
    }
    Keys.onEscapePressed: event => {
        root.handleEscape();
        event.accepted = true;
    }

    Column {
        width: root.width
        spacing: Theme.todoSectionGap
        Item {
            width: parent.width
            height: Theme.todoHeaderHeight
            SharedText {
                text: "To-do"
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.todoText
                font.pixelSize: Theme.titleFontSize
                font.weight: Font.Medium
            }
            SharedText {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: root.store.activeCount + " active"
                color: Theme.todoMutedText
            }
        }
        Item {
            width: parent.width
            height: Theme.todoFieldHeight
            SharedTextField {
                id: input
                anchors.fill: parent
                rightPadding: Theme.todoFieldPadding + Theme.todoActionSize + Theme.controlGap
                enabled: root.store.ready
                placeholderText: "Add a task…"
                Accessible.name: "New task"
                onAccepted: root.addTask()
                Keys.onEscapePressed: event => {
                    root.handleEscape();
                    event.accepted = true;
                }
            }
            IconButton {
                x: parent.width - width - Theme.todoFieldPadding
                anchors.verticalCenter: parent.verticalCenter
                width: Theme.todoActionSize
                height: width
                glyph: "add"
                glyphColor: Theme.accentPrimary
                glyphHoverColor: Theme.accentForeground
                actionName: "Add task"
                enabled: root.store.ready && input.text.trim().length > 0
                onClicked: root.addTask()
            }
        }
        Row {
            height: Theme.todoFilterHeight
            spacing: Theme.controlGap
            Repeater {
                model: ["all", "active", "completed"]
                TextButton {
                    id: filterButton
                    required property string modelData
                    implicitWidth: Math.max(Theme.controlMinimumWidth, contentItem.implicitWidth
                                            + Theme.controlPadding * 2)
                    height: Theme.todoFilterHeight
                    text: modelData.charAt(0).toUpperCase() + modelData.slice(1)
                    onClicked: {
                        root.cancelEdit();
                        root.filter = modelData;
                    }
                    contentItem: SharedText {
                        text: filterButton.text
                        color: root.filter === filterButton.modelData ? Theme.accentForeground :
                                                                        Theme.todoMutedText
                        horizontalAlignment: Text.AlignHCenter
                    }
                    background: Rectangle {
                        radius: Theme.todoFieldRadius
                        color: root.filter === filterButton.modelData ? Theme.todoSelectedTint :
                                                                        filterButton.hovered
                                                                        ? Theme.todoHoverTint :
                                                                          "transparent"
                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.hoverFeedbackDuration
                            }
                        }
                    }
                }
            }
        }
        ClippingRectangle {
            width: parent.width
            height: Theme.todoListHeight
            radius: Theme.todoSurfaceRadius
            color: Theme.todoSurface
            Loader {
                id: listLoader
                anchors.fill: parent
                // Incubate the list after the geometry transition; keep it warm
                // for subsequent openings without rebuilding a settled view.
                active: root._listRequested
                asynchronous: true
                opacity: status === Loader.Ready ? 1 : 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.panelSwitchFadeDuration
                    }
                }
                sourceComponent: ListView {
                    id: list
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    model: filteredTasks
                    cacheBuffer: Theme.todoRowHeight * 2
                    reuseItems: true
                    delegate: TodoTaskRow {
                        id: row
                        width: ListView.view.width
                        editing: root.editingId === row.taskId
                        draft: editing ? root.draft : ""
                        enabled: root.store.ready
                        onDraftEdited: text => root.draft = text
                        onToggleRequested: {
                            const id = row.taskId;
                            root.cancelEdit();
                            root.store.toggle(id);
                        }
                        onEditRequested: {
                            root.draft = row.taskText;
                            root.editingId = row.taskId;
                        }
                        onSaveRequested: root.saveEdit()
                        onCancelRequested: root.cancelEdit()
                        onDeleteRequested: {
                            const id = row.taskId;
                            root.cancelEdit();
                            root.store.remove(id);
                        }
                    }
                    Controls.ScrollBar.vertical: Controls.ScrollBar {
                        contentItem: Rectangle {
                            implicitWidth: Theme.todoScrollBarWidth
                            radius: width / 2
                            color: Theme.todoMutedText
                        }
                    }
                    SharedText {
                        anchors.centerIn: parent
                        visible: root.store.ready && list.count === 0
                        color: Theme.todoMutedText
                        text: root.filter === "active" ? "No active tasks." : root.filter
                                                         === "completed" ? "No completed tasks." :
                                                                           "No tasks yet."
                    }
                }
            }
        }
        // Fixed footer prevents async save/error messages from moving the list.
        Item {
            width: parent.width
            height: Theme.todoStatusHeight
            SharedText {
                width: root.store.error ? parent.width - retry.width - Theme.controlGap :
                                          parent.width
                maximumLineCount: 2
                wrapMode: Text.Wrap
                font.pixelSize: Theme.timelineFontSize
                color: Theme.todoMutedText
                text: root.store.error || (!root.store.ready ? "Loading tasks…" : root.store.saving
                                                               ? "Saving…" : "")
            }
            TextButton {
                id: retry
                anchors.right: parent.right
                visible: root.store.error.length > 0
                enabled: visible
                text: "Retry"
                onClicked: root.store.retry()
            }
        }
    }
}
