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
    required property string initialDate
    property string goalId: ""
    property bool deleting: false
    property bool confirming: false
    property string confirmedRemoval: ""
    property string message: ""
    readonly property var original: store.goal(goalId)
    readonly property string startDate: startInput.text.trim()
    readonly property int durationDays: Number.isInteger(Number(durationInput.text)) ? Number(
                                                                                           durationInput.text) :
                                                                                       0
    readonly property string goalColor: colorInput.text.trim()
    readonly property bool valid: store.validGoal(nameInput.text, startDate, durationDays,
                                                  goalColor)
    readonly property var affected: {
        return goalId && valid ? store.affectedTasks(goalId, startDate, durationDays) : [];
    }
    readonly property var deletedTasks: {
        return deleting ? store.taskData.filter(t => t.goalId === goalId) : [];
    }
    signal finished
    signal cancelRequested
    onAffectedChanged: confirming = false
    Component.onCompleted: {
        // These are mutable input drafts, initialized once for this editor.
        nameInput.text = original ? original.name : "";
        startInput.text = original ? original.startDate : initialDate;
        durationInput.text = original ? String(original.duration) : "1";
        colorInput.text = original ? original.color : Theme.calendarGoalColors[0];
        nameInput.forceActiveFocus();
    }
    function submit(): void {
        if (deleting) {
            store.deleteGoal(goalId);
            finished();
            return;
        }
        if (!valid || !store.ready)
            return;
        if (affected.length && !confirming) {
            confirmedRemoval = JSON.stringify(affected);
            confirming = true;
            return;
        }
        const saved = goalId ? store.updateGoal(goalId, nameInput.text, startDate, durationDays,
                                                goalColor, confirmedRemoval) : store.addGoal(
                                   nameInput.text, startDate, durationDays, goalColor).length > 0;
        if (saved)
            finished();
        else {
            confirming = false;
            message = "Tasks changed. Review this range and save again.";
        }
    }
    Keys.onEscapePressed: event => {
        root.cancelRequested();
        event.accepted = true;
    }

    SharedText {
        id: heading
        width: parent.width - cancel.width
        height: Theme.calendarHeaderHeight
        text: root.deleting ? "Delete goal?" : root.goalId ? "Edit goal" : "New goal"
        color: Theme.calendarText
        font.pixelSize: Theme.titleFontSize
    }
    IconButton {
        id: cancel
        anchors.right: parent.right
        glyph: "close"
        actionName: "Cancel goal editing"
        onClicked: root.cancelRequested()
    }
    Controls.ScrollView {
        anchors.top: heading.bottom
        anchors.bottom: submitButton.top
        anchors.bottomMargin: Theme.calendarGap
        width: parent.width
        contentWidth: availableWidth
        Controls.ScrollBar.horizontal.policy: Controls.ScrollBar.AlwaysOff
        clip: true
        Column {
            width: parent.width
            spacing: Theme.calendarGap
            SharedText {
                width: parent.width
                visible: root.deleting
                wrapMode: Text.Wrap
                maximumLineCount: 2147483647
                text: root.original ? "Delete “" + root.original.name + "” and all "
                                      + root.deletedTasks.length + " of its tasks on every date?" :
                                      ""
                color: Theme.calendarText
            }
            Column {
                width: parent.width
                spacing: Theme.calendarGap / 2
                visible: !root.deleting && !root.confirming
                SharedText {
                    text: "Goal name"
                    color: Theme.calendarMutedText
                }
                SharedTextField {
                    id: nameInput
                    width: parent.width
                    Accessible.name: "Goal name"
                    placeholderText: "What do you want to achieve?"
                    onAccepted: root.submit()
                }
                SharedText {
                    text: "Start date · YYYY-MM-DD"
                    color: Theme.calendarMutedText
                }
                SharedTextField {
                    id: startInput
                    width: parent.width
                    Accessible.name: "Goal start date"
                    placeholderText: "YYYY-MM-DD"
                }
                SharedText {
                    text: "Duration · 1–30 days, including the start date"
                    color: Theme.calendarMutedText
                }
                SharedTextField {
                    id: durationInput
                    width: parent.width
                    Accessible.name: "Goal duration in days"
                    inputMethodHints: Qt.ImhDigitsOnly
                    validator: IntValidator {
                        bottom: 1
                        top: 30
                    }
                }
                SharedText {
                    width: parent.width
                    text: Dates.validRange(root.startDate, root.durationDays) ? "Ends "
                                                                                + Qt.formatDate(
                                                                                    Dates.parse(
                                                                                        Dates.addDays(
                                                                                            root.startDate,
                                                                                            root.durationDays
                                                                                            - 1)), "ddd, d MMM yyyy") :
                                                                                "Choose a valid date and 1–30 days."
                    color: Theme.accentForeground
                    elide: Text.ElideRight
                }
                SharedText {
                    text: "Goal color"
                    color: Theme.calendarMutedText
                }
                Row {
                    spacing: Theme.calendarBandGap
                    Repeater {
                        model: Theme.calendarGoalColors
                        TextButton {
                            id: swatch
                            required property string modelData
                            width: Theme.calendarActionSize
                            height: width
                            Accessible.name: "Goal color " + modelData
                            onClicked: colorInput.text = modelData
                            contentItem: Item {}
                            background: Rectangle {
                                anchors.centerIn: parent
                                width: Theme.calendarDateDiameter
                                height: width
                                radius: width / 2
                                color: swatch.modelData
                                opacity: swatch.hovered ? 1 : Theme.controlGlyphIdleOpacity
                                border.width: 2
                                border.color: root.goalColor.toLowerCase()
                                              === swatch.modelData.toLowerCase()
                                              ? Theme.calendarText : "transparent"
                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: Theme.hoverFeedbackDuration
                                    }
                                }
                            }
                        }
                    }
                }
                SharedTextField {
                    id: colorInput
                    width: parent.width
                    Accessible.name: "Goal hex color"
                    placeholderText: "#9D00FF"
                    validator: RegularExpressionValidator {
                        regularExpression: /#[0-9a-fA-F]{6}/
                    }
                }
            }
            SharedText {
                width: parent.width
                visible: root.confirming
                text: "This range excludes the following tasks. Confirm to remove them:"
                color: Theme.accentForeground
                wrapMode: Text.Wrap
                maximumLineCount: 4
            }
            Repeater {
                model: root.confirming ? root.affected : []
                SharedText {
                    required property var modelData
                    width: parent.width
                    text: modelData.date + " · " + modelData.text
                    color: Theme.calendarText
                    wrapMode: Text.Wrap
                    maximumLineCount: 2147483647
                }
            }
            SharedText {
                visible: root.message.length > 0
                width: parent.width
                text: root.message
                color: Theme.accentForeground
                wrapMode: Text.Wrap
                maximumLineCount: 3
            }
            TextButton {
                visible: root.confirming
                text: "Back to editing"
                onClicked: root.confirming = false
            }
        }
    }
    TextButton {
        id: submitButton
        anchors.bottom: parent.bottom
        width: parent.width
        text: root.deleting ? "Delete goal and tasks" : root.confirming ? "Remove "
                                                                          + root.affected.length
                                                                          + " tasks and save" :
                                                                          "Save goal"
        enabled: root.store.ready && (root.deleting || root.valid)
        onClicked: root.submit()
    }
}
