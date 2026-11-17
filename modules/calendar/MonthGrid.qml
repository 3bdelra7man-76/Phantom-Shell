pragma ComponentBehavior: Bound

import QtQuick
import qs.components
import qs.core
import "../../core/CalendarDates.js" as Dates

Item {
    id: root

    required property string monthDate
    required property string selectedDate
    required property string todayDate
    required property var goals
    signal dateSelected(string date)
    readonly property string firstDate: Dates.gridStart(monthDate)
    readonly property real weekHeight: (height - Theme.calendarWeekdayHeight) / 6
    readonly property real dayWidth: width / 7
    readonly property int visibleLanes: Math.max(1, Math.min(Theme.calendarMaxBands, Math.floor((weekHeight
                                                                                                 - Theme.calendarDayHeaderHeight)
                                                                                                / (Theme.calendarBandHeight
                                                                                                   + Theme.calendarBandGap))))
    property real _monthOpacity: 1
    implicitHeight: Theme.calendarGridMinimumHeight
    opacity: _monthOpacity
    onMonthDateChanged: monthFade.restart()
    NumberAnimation {
        id: monthFade
        target: root
        property: "_monthOpacity"
        from: 0.65
        to: 1
        duration: Theme.calendarTransitionDuration
    }

    Row {
        Repeater {
            model: 7
            SharedText {
                required property int index
                width: root.dayWidth
                height: Theme.calendarWeekdayHeight
                horizontalAlignment: Text.AlignHCenter
                color: Theme.calendarMutedText
                text: Qt.formatDate(Dates.parse(Dates.addDays("2024-01-01", index)), "ddd")
            }
        }
    }
    Column {
        y: Theme.calendarWeekdayHeight
        Repeater {
            model: 6
            Item {
                id: week
                required property int index
                readonly property string startDate: Dates.addDays(root.firstDate, index * 7)
                readonly property var assignedGoals: Dates.weekLayout(root.goals, startDate)
                width: root.width
                height: root.weekHeight
                Repeater {
                    model: 7
                    TextButton {
                        id: day
                        required property int index
                        readonly property string dateKey: Dates.addDays(week.startDate, index)
                        readonly property bool today: dateKey === root.todayDate
                        readonly property int hiddenGoals: week.assignedGoals.filter(g => g.lane
                                                                                          >= root.visibleLanes
                                                                                          && Dates.contains(
                                                                                              g.startDate,
                                                                                              g.duration,
                                                                                              dateKey)).length
                        x: index * root.dayWidth
                        width: root.dayWidth
                        height: week.height
                        padding: 0
                        Accessible.name: Qt.formatDate(Dates.parse(dateKey), "dddd, d MMMM yyyy") + (
                                             hiddenGoals ? ", " + hiddenGoals + " more goals" : "")
                        onClicked: root.dateSelected(dateKey)
                        background: Rectangle {
                            radius: Theme.calendarBandRadius
                            color: day.dateKey === root.selectedDate ? Theme.calendarSelectedTint :
                                                                       day.hovered
                                                                       ? Theme.calendarHoverTint :
                                                                         "transparent"
                            border.color: Theme.calendarSeparator
                            Behavior on color {
                                ColorAnimation {
                                    duration: Theme.hoverFeedbackDuration
                                }
                            }
                        }
                        contentItem: Item {
                            Rectangle {
                                x: Theme.calendarBandGap
                                width: Theme.calendarDateDiameter
                                height: width
                                radius: width / 2
                                color: day.today ? Theme.accentPrimary : "transparent"
                                SharedText {
                                    anchors.centerIn: parent
                                    text: Number(day.dateKey.slice(-2))
                                    color: day.today ? Theme.calendarText : day.dateKey.slice(0, 7)
                                                       === root.monthDate.slice(0, 7)
                                                       ? Theme.calendarText :
                                                         Theme.calendarMutedText
                                    font.pixelSize: Theme.timelineFontSize
                                }
                            }
                            SharedText {
                                anchors.right: parent.right
                                anchors.rightMargin: Theme.calendarBandGap
                                height: Theme.calendarDayHeaderHeight
                                visible: day.hiddenGoals > 0
                                text: "+" + day.hiddenGoals
                                color: Theme.accentForeground
                                font.pixelSize: Theme.timelineFontSize
                            }
                        }
                    }
                }
                // One segment per goal/week, spanning cells without daily gaps.
                Repeater {
                    model: Dates.weekBands(week.assignedGoals, week.startDate, root.visibleLanes)
                    Rectangle {
                        id: band
                        required property var modelData
                        x: modelData.column * root.dayWidth + Theme.calendarBandGap
                        y: Theme.calendarDayHeaderHeight + modelData.lane * (
                               Theme.calendarBandHeight + Theme.calendarBandGap)
                        width: modelData.span * root.dayWidth - Theme.calendarBandGap * 2
                        height: Theme.calendarBandHeight
                        radius: Theme.calendarBandRadius
                        color: Qt.alpha(modelData.color, Theme.calendarBandOpacity)
                        SharedText {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.calendarBandGap
                            anchors.rightMargin: Theme.calendarBandGap
                            text: band.modelData.name
                            color: Theme.calendarText
                            font.pixelSize: Theme.calendarBandFontSize
                            elide: Text.ElideRight
                        }
                    }
                }
                // Selection stays above bands; today has its separate number disc.
                Repeater {
                    model: 7
                    Rectangle {
                        required property int index
                        x: index * root.dayWidth + 1
                        y: 1
                        width: root.dayWidth - 2
                        height: week.height - 2
                        radius: Theme.calendarBandRadius
                        color: "transparent"
                        border.width: 2
                        border.color: Dates.addDays(week.startDate, index) === root.selectedDate
                                      ? Theme.accentForeground : "transparent"
                        Behavior on border.color {
                            ColorAnimation {
                                duration: Theme.hoverFeedbackDuration
                            }
                        }
                    }
                }
            }
        }
    }
}
