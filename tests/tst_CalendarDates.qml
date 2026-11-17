import QtQuick
import QtTest
import "../core/CalendarDates.js" as Dates

TestCase {
    name: "CalendarDates"

    function test_strictLocalDates() {
        compare(Dates.key(Dates.parse("2026-11-17")), "2026-11-17");
        compare(Dates.parse("2026-02-29"), null);
        compare(Dates.parse("2024-02-29").getDate(), 29);
        compare(Dates.parse("2026-13-01"), null);
        compare(Dates.parse("2026-1-01"), null);
    }
    function test_inclusiveDurations() {
        verify(Dates.contains("2026-11-17", 1, "2026-11-17"));
        verify(!Dates.contains("2026-11-17", 1, "2026-11-18"));
        compare(Dates.addDays("2026-11-17", 29), "2026-12-16");
        verify(Dates.contains("2026-11-17", 30, "2026-12-16"));
        verify(!Dates.contains("2026-11-17", 30, "2026-12-17"));
        verify(!Dates.validRange("2026-11-17", 0));
        verify(!Dates.validRange("2026-11-17", 31));
        verify(!Dates.validRange("2026-11-17", 1.5));
    }
    function test_calendarArithmeticAcrossDST() {
        compare(Dates.addDays("2026-03-07", 2), "2026-03-09");
        compare(Dates.dayNumber("2026-03-07", "2026-03-09"), 3);
        compare(Dates.addDays("2026-10-24", 2), "2026-10-26");
        compare(Dates.dayNumber("2026-10-24", "2026-10-26"), 3);
        compare(Dates.addDays("2024-02-28", 2), "2024-03-01");
        compare(Dates.addDays("2026-12-31", 1), "2027-01-01");
    }
    function test_monthNavigationAndMondayGrid() {
        compare(Dates.gridStart("2026-11-17"), "2026-10-26");
        compare(Dates.moveMonth("2026-12-31", 1), "2027-01-01");
        compare(Dates.moveMonth("2027-01-31", -1), "2026-12-01");
    }
    function test_stableOverlappingLanesAndWeekSegments() {
        const goals = [
            {id: "b", startDate: "2026-11-01", duration: 30},
            {id: "a", startDate: "2026-11-01", duration: 1},
            {id: "c", startDate: "2026-11-02", duration: 2}
        ];
        const lanes = Dates.lanes(goals);
        compare(lanes.map(g => g.id), ["a", "b", "c"]);
        compare(lanes.map(g => g.lane), [0, 1, 0]);
        const first = Dates.weekBands(lanes, "2026-10-26", 2);
        compare(first.length, 2);
        compare(first[1].column, 6);
        compare(first[1].span, 1);
        verify(first[1].continuesAfter);
        const second = Dates.weekBands(lanes, "2026-11-02", 2);
        const longGoal = second.find(g => g.id === "b");
        compare(longGoal.lane, 1);
        compare(longGoal.span, 7);
        verify(longGoal.continuesBefore && longGoal.continuesAfter);
        compare(Dates.weekBands(lanes, "2026-11-02", 1).map(g => g.id), ["c"]);
        const followingWeek = Dates.weekLayout(goals, "2026-11-09");
        compare(followingWeek.length, 1);
        compare(followingWeek[0].id, "b");
        compare(followingWeek[0].lane, 0);
    }
}
