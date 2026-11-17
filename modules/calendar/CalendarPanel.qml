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
    property string todayDate: Dates.key(new Date())
    property string selectedDate: todayDate
    readonly property string monthDate: Dates.monthStart(selectedDate)
    property bool formOpen: false
    property string editingGoalId: ""
    property bool deletingGoal: false
    readonly property bool stacked: width < Theme.calendarStackBreakpoint
    readonly property alias agenda: agendaView
    readonly property alias goalEditor: editor.item
    readonly property alias grid: monthGrid
    signal dismissRequested

    function resetToToday(): void {
        todayDate = Dates.key(new Date());
        selectDate(todayDate);
        formOpen = false;
        agendaView.resetDrafts();
        scrollWorkspace(false);
        forceActiveFocus();
    }
    function scrollWorkspace(toDetails: bool): void {
        // Scroll position is interaction state. On a stacked layout, a header
        // action should reveal its editor rather than open it below the fold.
        const view = contentScroll.contentItem as Flickable;
        if (view)
            view.contentY = toDetails && stacked ? Math.max(0, Math.min(details.y, view.contentHeight
                                                                        - view.height)) : 0;
    }
    function selectDate(date: string): void {
        if (!Dates.parse(date))
            return;
        selectedDate = date;
        agendaView.cancelEdit();
        formOpen = false;
    }
    function moveMonth(delta: int): void {
        const next = Dates.moveMonth(monthDate, delta);
        if (next)
            selectDate(next);
        scrollWorkspace(false);
    }
    function editGoal(id: string, deleting: bool): void {
        // Recreate only the editor so each draft is initialized for its goal.
        formOpen = false;
        editingGoalId = id;
        deletingGoal = deleting;
        agendaView.cancelEdit();
        formOpen = true;
        scrollWorkspace(true);
    }
    function handleEscape(): void {
        if (formOpen)
            formOpen = false;
        else if (agendaView.editingTaskId)
            agendaView.cancelEdit();
        else
            dismissRequested();
    }
    function releaseEditors(): void {
        formOpen = false;
        agendaView.resetDrafts();
        focus = false;
    }
    Keys.onEscapePressed: event => {
        root.handleEscape();
        event.accepted = true;
    }

    Item {
        id: header
        x: Theme.calendarPadding
        y: Theme.calendarPadding
        width: parent.width - x * 2
        height: Theme.calendarHeaderHeight
        SharedText {
            width: Math.max(0, navigation.x - Theme.calendarGap)
            height: parent.height
            text: Qt.formatDate(Dates.parse(root.monthDate), "MMMM yyyy")
            font.pixelSize: Theme.calendarTitleFontSize
            color: Theme.calendarText
            elide: Text.ElideRight
        }
        Row {
            id: navigation
            anchors.right: parent.right
            spacing: Theme.calendarBandGap
            IconButton {
                glyph: "left"
                actionName: "Previous month"
                onClicked: root.moveMonth(-1)
            }
            IconButton {
                glyph: "right"
                actionName: "Next month"
                onClicked: root.moveMonth(1)
            }
            TextButton {
                text: "Today"
                onClicked: root.resetToToday()
            }
            TextButton {
                id: addGoal
                implicitWidth: Theme.calendarHeaderActionWidth
                text: "Add goal"
                enabled: root.store.ready
                onClicked: root.editGoal("", false)
                contentItem: Row {
                    spacing: Theme.controlGap
                    PlaybackIcon {
                        icon: "add"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    SharedText {
                        text: addGoal.text
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
            IconButton {
                glyph: "close"
                actionName: "Close calendar"
                onClicked: root.dismissRequested()
            }
        }
    }
    Controls.ScrollView {
        id: contentScroll
        x: Theme.calendarPadding
        y: header.y + header.height + Theme.calendarGap
        width: parent.width - x * 2
        height: Math.max(0, status.y - y - Theme.calendarGap)
        contentWidth: availableWidth
        contentHeight: workspace.height
        Controls.ScrollBar.horizontal.policy: Controls.ScrollBar.AlwaysOff
        clip: true
        Item {
            id: workspace
            width: contentScroll.availableWidth
            height: root.stacked ? Theme.calendarGridMinimumHeight
                                   + Theme.calendarAgendaMinimumHeight + Theme.calendarGap :
                                   Math.max(Theme.calendarGridMinimumHeight,
                                            contentScroll.availableHeight)

            MonthGrid {
                id: monthGrid
                width: root.stacked ? parent.width : (parent.width - Theme.calendarGap)
                                      * Theme.calendarGridFraction
                height: root.stacked ? Theme.calendarGridMinimumHeight : Math.max(
                                           Theme.calendarGridMinimumHeight, parent.height)
                monthDate: root.monthDate
                selectedDate: root.selectedDate
                todayDate: root.todayDate
                goals: root.store.goalData
                onDateSelected: date => root.selectDate(date)
            }
            Item {
                id: details
                x: root.stacked ? 0 : monthGrid.width + Theme.calendarGap
                y: root.stacked ? monthGrid.height + Theme.calendarGap : 0
                width: root.stacked ? parent.width : parent.width - x
                height: root.stacked ? Theme.calendarAgendaMinimumHeight :
                                       contentScroll.availableHeight
                enabled: root.store.ready
                DayAgenda {
                    id: agendaView
                    anchors.fill: parent
                    visible: !root.formOpen
                    enabled: visible
                    store: root.store
                    selectedDate: root.selectedDate
                    onEditGoalRequested: id => root.editGoal(id, false)
                    onDeleteGoalRequested: id => root.editGoal(id, true)
                }
                Loader {
                    id: editor
                    anchors.fill: parent
                    active: root.formOpen
                    sourceComponent: GoalEditor {
                        store: root.store
                        initialDate: root.selectedDate
                        goalId: root.editingGoalId
                        deleting: root.deletingGoal
                        onFinished: root.formOpen = false
                        onCancelRequested: root.formOpen = false
                    }
                }
            }
        }
    }
    Item {
        id: status
        x: Theme.calendarPadding
        y: parent.height - Theme.calendarPadding - height
        width: parent.width - x * 2
        height: Theme.calendarStatusHeight
        SharedText {
            width: parent.width - (retry.visible ? retry.width + Theme.calendarGap : 0)
            text: root.store.error || (!root.store.ready ? "Loading calendar…" : root.store.saving
                                                           ? "Saving…" :
                                                             "Select a day · Goals include their start date")
            color: root.store.error ? Theme.accentForeground : Theme.calendarMutedText
            font.pixelSize: Theme.timelineFontSize
            elide: Text.ElideRight
        }
        TextButton {
            id: retry
            anchors.right: parent.right
            height: parent.height
            text: "Retry"
            visible: root.store.error.length > 0
            enabled: visible
            onClicked: root.store.retry()
        }
    }
}
