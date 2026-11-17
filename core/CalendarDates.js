.pragma library

// Civil dates stay local, at noon. Never parse YYYY-MM-DD as a UTC timestamp or
// add 24-hour milliseconds: either approach shifts days around time zones/DST.
function key(date) {
    return String(date.getFullYear()).padStart(4, "0") + "-"
            + String(date.getMonth() + 1).padStart(2, "0") + "-"
            + String(date.getDate()).padStart(2, "0");
}

function parse(value) {
    if (typeof value !== "string" || !/^\d{4}-\d{2}-\d{2}$/.test(value))
        return null;
    const parts = value.split("-").map(Number);
    if (parts[0] < 1 || parts[0] > 9999)
        return null;
    const date = new Date(0);
    date.setFullYear(parts[0], parts[1] - 1, parts[2]);
    date.setHours(12, 0, 0, 0);
    return key(date) === value ? date : null;
}

function addDays(value, days) {
    const date = parse(value);
    if (!date || !Number.isInteger(days))
        return "";
    date.setDate(date.getDate() + days);
    const result = key(date);
    return parse(result) ? result : "";
}

function ordinal(value) {
    const local = parse(value);
    if (!local)
        return NaN;
    const utc = new Date(0);
    utc.setUTCFullYear(local.getFullYear(), local.getMonth(), local.getDate());
    utc.setUTCHours(0, 0, 0, 0);
    return utc.getTime() / 86400000;
}

function dayNumber(start, date) {
    return ordinal(date) - ordinal(start) + 1;
}

function validRange(start, duration) {
    return !!parse(start) && Number.isInteger(duration) && duration >= 1
            && duration <= 30 && addDays(start, duration - 1) !== "";
}

function contains(start, duration, date) {
    return !!parse(date) && validRange(start, duration) && date >= start
            && date <= addDays(start, duration - 1);
}

function monthStart(value) {
    return parse(value) ? value.slice(0, 7) + "-01" : "";
}

function moveMonth(value, delta) {
    const date = parse(monthStart(value));
    if (!date)
        return "";
    date.setMonth(date.getMonth() + delta);
    return parse(key(date)) ? key(date) : "";
}

function gridStart(month) {
    const first = monthStart(month);
    const date = parse(first);
    return date ? addDays(first, -((date.getDay() + 6) % 7)) : "";
}

// Deterministic range packing; ties use stable IDs. Weekly layouts keep this
// ordering, compacting lanes when earlier goals no longer intersect that week.
function lanes(goals) {
    const ordered = goals.slice().sort((a, b) => a.startDate.localeCompare(b.startDate)
                                     || a.id.localeCompare(b.id));
    const ends = [];
    return ordered.map(goal => {
        let lane = ends.findIndex(end => end < goal.startDate);
        if (lane < 0)
            lane = ends.length;
        const end = addDays(goal.startDate, goal.duration - 1);
        ends[lane] = end;
        return Object.assign({}, goal, {lane: lane, endDate: end});
    });
}

function weekBands(goals, weekStart, visibleLanes) {
    const weekEnd = addDays(weekStart, 6);
    return goals.filter(goal => goal.lane < visibleLanes && goal.startDate <= weekEnd
                        && goal.endDate >= weekStart).map(goal => {
        const start = goal.startDate > weekStart ? goal.startDate : weekStart;
        const end = goal.endDate < weekEnd ? goal.endDate : weekEnd;
        return Object.assign({}, goal, {
            column: dayNumber(weekStart, start) - 1,
            span: dayNumber(start, end),
            continuesBefore: goal.startDate < weekStart,
            continuesAfter: goal.endDate > weekEnd
        });
    });
}

function weekLayout(goals, weekStart) {
    const end = addDays(weekStart, 6);
    return lanes(goals.filter(g => g.startDate <= end
        && addDays(g.startDate, g.duration - 1) >= weekStart));
}
