pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic as Controls
import qs.components
import qs.core
import qs.services
import "../../core/CalendarDates.js" as Dates

FocusScope {
    id: root

    required property CalendarStore store
    required property string selectedDate
    property string editingTaskId: ""
    property string draft: ""
    property var addDrafts: ({})
    property string _addFocusGoalId: ""
    readonly property var entries: {
        return store.agenda(selectedDate);
    }
    signal editGoalRequested(string goalId)
    signal deleteGoalRequested(string goalId)
    readonly property alias taskList: list
    onSelectedDateChanged: {
        resetDrafts();
        list.positionViewAtBeginning();
    }
    function resetDrafts(): void {
        cancelEdit();
        addDrafts = ({});
        _addFocusGoalId = "";
    }
    function cancelEdit(): void {
        editingTaskId = "";
        draft = "";
    }
    function saveEdit(): void {
        if (store.renameTask(editingTaskId, draft))
            cancelEdit();
    }
    function setAddDraft(goalId: string, text: string): void {
        const next = Object.assign({}, addDrafts);
        next[goalId] = text;
        addDrafts = next;
    }
    function addTask(goalId: string): void {
        if (store.addTask(goalId, selectedDate, addDrafts[goalId] || "")) {
            setAddDraft(goalId, "");
            _addFocusGoalId = goalId;
            Qt.callLater(restoreAddFocus);
        }
    }
    function restoreAddFocus(): void {
        if (!_addFocusGoalId || !visible || !enabled)
            return;
        const index = entries.findIndex(e => e.kind === "add" && e.goalId === _addFocusGoalId);
        if (index < 0)
            return;
        // The flattened view may replace its add row after a commit. Restore
        // focus to that goal's new row, keeping quick entry and scrolling usable.
        list.positionViewAtIndex(index, ListView.Contain);
        list.forceLayout();
        const entry = list.itemAtIndex(index) as Loader;
        if (entry && entry.item) {
            const scope = entry.item as Item;
            scope.forceActiveFocus();
        }
    }

    SharedText {
        id: heading
        width: parent.width
        height: Theme.calendarHeaderHeight
        text: Qt.formatDate(Dates.parse(root.selectedDate), "dddd, d MMMM")
        color: Theme.calendarText
        font.pixelSize: Theme.titleFontSize
        elide: Text.ElideRight
    }
    ListView {
        id: list
        anchors.top: heading.bottom
        anchors.bottom: parent.bottom
        width: parent.width
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        model: root.entries
        cacheBuffer: Theme.calendarTaskHeight * 2
        reuseItems: true
        delegate: Loader {
            id: entry
            required property var modelData
            property bool pooled: false
            active: !pooled
            ListView.onPooled: pooled = true
            ListView.onReused: pooled = false
            onLoaded: {
                if (modelData.kind === "add" && root._addFocusGoalId === modelData.goalId)
                    Qt.callLater(root.restoreAddFocus);
            }
            width: ListView.view.width
            height: modelData.kind === "goal" ? Theme.calendarGoalHeaderHeight : modelData.kind
                                                === "add" ? Theme.calendarTaskAddHeight :
                                                            Theme.calendarTaskHeight
            sourceComponent: modelData.kind === "goal" ? goalHeader : modelData.kind === "add"
                                                         ? taskInput : taskRow

            Component {
                id: goalHeader
                Item {
                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.calendarSurfaceRadius
                        color: Theme.calendarSurface
                    }
                    Rectangle {
                        x: Theme.calendarRowPadding
                        y: Theme.calendarRowPadding
                        width: Theme.calendarColorDotSize
                        height: width
                        radius: width / 2
                        color: entry.modelData.color
                    }
                    SharedText {
                        x: Theme.calendarRowPadding * 2 + Theme.calendarColorDotSize
                        y: Theme.calendarRowPadding / 2
                        width: Math.max(0, edit.x - x - Theme.calendarGap)
                        text: entry.modelData.name
                        color: Theme.calendarText
                        font.weight: Font.Medium
                        elide: Text.ElideRight
                    }
                    SharedText {
                        x: Theme.calendarRowPadding
                        y: Theme.calendarGoalHeaderHeight / 2
                        width: parent.width - x * 2
                        font.pixelSize: Theme.timelineFontSize
                        color: Theme.calendarMutedText
                        text: "Day " + entry.modelData.day + " of " + entry.modelData.duration
                              + " · " + entry.modelData.done + " of " + entry.modelData.total
                              + " done"
                    }
                    IconButton {
                        id: edit
                        x: parent.width - width * 2 - Theme.calendarRowPadding
                        width: Theme.calendarActionSize
                        height: width
                        glyph: "edit"
                        actionName: "Edit goal " + entry.modelData.name
                        onClicked: root.editGoalRequested(entry.modelData.goalId)
                    }
                    IconButton {
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.calendarRowPadding
                        width: Theme.calendarActionSize
                        height: width
                        glyph: "delete"
                        actionName: "Delete goal " + entry.modelData.name
                        onClicked: root.deleteGoalRequested(entry.modelData.goalId)
                    }
                }
            }
            Component {
                id: taskRow
                CalendarTaskRow {
                    taskId: entry.modelData.id
                    taskText: entry.modelData.text
                    completed: entry.modelData.completed
                    editing: root.editingTaskId === taskId
                    draft: editing ? root.draft : ""
                    onDraftEdited: text => root.draft = text
                    onEditRequested: {
                        root._addFocusGoalId = "";
                        root.draft = taskText;
                        root.editingTaskId = taskId;
                    }
                    onSaveRequested: root.saveEdit()
                    onCancelRequested: root.cancelEdit()
                    onToggleRequested: {
                        root.cancelEdit();
                        root.store.toggleTask(taskId);
                    }
                    onDeleteRequested: {
                        root.cancelEdit();
                        root.store.deleteTask(taskId);
                    }
                }
            }
            Component {
                id: taskInput
                FocusScope {
                    SharedTextField {
                        id: input
                        x: Theme.calendarRowPadding
                        width: parent.width - x * 2
                        rightPadding: Theme.calendarActionSize + Theme.inputPadding
                        text: root.addDrafts[entry.modelData.goalId] || ""
                        placeholderText: "Add a task to this day…"
                        Accessible.name: "New task for goal"
                        focus: true
                        onActiveFocusChanged: {
                            if (activeFocus)
                                root._addFocusGoalId = entry.modelData.goalId;
                        }
                        onTextEdited: root.setAddDraft(entry.modelData.goalId, text)
                        onAccepted: root.addTask(entry.modelData.goalId)
                    }
                    IconButton {
                        anchors.right: input.right
                        width: Theme.calendarActionSize
                        height: Theme.inputHeight
                        glyph: "add"
                        actionName: "Add task"
                        enabled: (root.addDrafts[entry.modelData.goalId] || "").trim().length > 0
                        onClicked: root.addTask(entry.modelData.goalId)
                    }
                }
            }
        }
        Controls.ScrollBar.vertical: Controls.ScrollBar {}
        SharedText {
            anchors.centerIn: parent
            width: parent.width - Theme.calendarGap * 2
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            maximumLineCount: 4
            color: Theme.calendarMutedText
            visible: root.entries.length === 0
            text: "This day is open.\nAdd a goal to start planning."
        }
    }
}
