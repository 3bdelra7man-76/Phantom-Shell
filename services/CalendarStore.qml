pragma Singleton

import QtQuick
import QtQml.Models
import Quickshell
import Quickshell.Io
import "../core/CalendarDates.js" as Dates

Singleton {
    id: root

    readonly property string storagePath: Quickshell.dataPath("calendar.json")
    readonly property bool ready: !_loading && _loadError === ""
    readonly property bool saving: _saving || _retryingSave || _revision !== _savedRevision
    readonly property string error: _loadError || _saveError
    readonly property int goalsRevision: _goalsRevision
    readonly property int tasksRevision: _tasksRevision
    property int _goalsRevision: 0
    property int _tasksRevision: 0
    property bool _loading: true
    property string _loadError: ""
    property string _saveError: ""
    property bool _saving: false
    property bool _retryingSave: false
    property int _revision: 0
    property int _savedRevision: 0
    property int _writingRevision: 0

    ListModel {
        id: goalsModel
    }
    ListModel {
        id: tasksModel
    }

    function goalIndex(id: string): int {
        for (let i = 0; i < goalsModel.count; ++i)
            if (goalsModel.get(i).goalId === id)
                return i;
        return -1;
    }
    function taskIndex(id: string): int {
        for (let i = 0; i < tasksModel.count; ++i)
            if (tasksModel.get(i).taskId === id)
                return i;
        return -1;
    }
    // Revision arguments make plain snapshots observable after committed edits.
    readonly property var goalData: collectGoals(_goalsRevision)
    readonly property var taskData: collectTasks(_tasksRevision)
    function goal(id: string): var {
        return goalData.find(g => g.id === id) || null;
    }
    function collectGoals(revision: int): var {
        const rows = [];
        for (let i = 0; i < goalsModel.count; ++i) {
            const row = goalsModel.get(i);
            rows.push({
                          id: row.goalId,
                          name: row.name,
                          startDate: row.startDate,
                          duration: row.duration,
                          color: row.goalColor
                      });
        }
        return rows;
    }
    function collectTasks(revision: int): var {
        const rows = [];
        for (let i = 0; i < tasksModel.count; ++i) {
            const row = tasksModel.get(i);
            rows.push({
                          id: row.taskId,
                          goalId: row.goalId,
                          date: row.date,
                          text: row.taskText,
                          completed: row.completed
                      });
        }
        return rows;
    }
    function snapshot(): var {
        // JSON always traverses plain JS objects, never a QML list<var>.
        return {
            version: 1,
            goals: goalData,
            tasks: taskData
        };
    }
    function validGoal(name: string, start: string, duration: int, color: string): bool {
        return name.trim().length > 0 && Dates.validRange(start, duration) && /^#[0-9a-fA-F]{6}$/.test(
                    color);

    }
    function load(text: string): void {
        if (!_loading)
            return;
        try {
            const data = JSON.parse(text);
            if (data.version !== 1 || !Array.isArray(data.goals) || !Array.isArray(data.tasks))
                throw new Error("Unsupported calendar file");
            const goalIds = new Map();
            const taskIds = new Set();
            for (const g of data.goals) {
                if (!g || typeof g.id !== "string" || !g.id || goalIds.has(g.id) || typeof g.name !== "string"
                        || typeof g.color !== "string" || !Number.isInteger(g.duration) || !validGoal(
                            g.name, g.startDate, g.duration, g.color))
                    throw new Error("Invalid goal");
                goalIds.set(g.id, g);
            }
            for (const t of data.tasks) {
                const g = t && goalIds.get(t.goalId);
                if (!g || typeof t.id !== "string" || !t.id || taskIds.has(t.id) || typeof t.text !== "string"
                        || !t.text.trim() || typeof t.completed !== "boolean" || !Dates.contains(
                            g.startDate, g.duration, t.date))
                    throw new Error("Invalid task");
                taskIds.add(t.id);
            }
            // Validate everything before replacing either model.
            goalsModel.clear();
            tasksModel.clear();
            for (const g of data.goals)
                goalsModel.append({
                                      goalId: g.id,
                                      name: g.name.trim(),
                                      startDate: g.startDate,
                                      duration: g.duration,
                                      goalColor: g.color
                                  });
            for (const t of data.tasks)
                tasksModel.append({
                                      taskId: t.id,
                                      goalId: t.goalId,
                                      date: t.date,
                                      taskText: t.text.trim(),
                                      completed: t.completed
                                  });
            ++_goalsRevision;
            ++_tasksRevision;
            _loadError = "";
        } catch (error) {
            _loadError
                    = "Calendar file is invalid. Original data preserved; repair it, then retry.";
        }
        _loading = false;
    }
    function newId(): string {
        let id;
        do {
            id = Date.now().toString(36) + "-" + Math.random().toString(36).slice(2);
        } while (goalIndex(id) >= 0 || taskIndex(id) >= 0)
        return id;
    }
    function committed(goalsChanged: bool): void {
        ++_revision;
        if (goalsChanged)
            ++_goalsRevision;
        ++_tasksRevision;
        Qt.callLater(flush);
    }
    function addGoal(name: string, start: string, duration: int, color: string): string {
        if (!ready || !validGoal(name, start, duration, color))
            return "";
        const id = newId();
        goalsModel.append({
                              goalId: id,
                              name: name.trim(),
                              startDate: start,
                              duration: duration,
                              goalColor: color
                          });
        committed(true);
        return id;
    }
    function affectedTasks(id: string, start: string, duration: int): var {
        return taskData.filter(t => t.goalId === id && !Dates.contains(start, duration,
                                                                       t.date)).sort((a, b)
                                                                                     => a.date.localeCompare(
                                                                                            b.date)
                                                                                        || a.id.localeCompare(
                                                                                            b.id));
    }
    function updateGoal(id: string, name: string, start: string, duration: int, color: string,
                        confirmedRemoval: string): bool {
        const index = goalIndex(id);
        if (!ready || index < 0 || !validGoal(name, start, duration, color))
            return false;
        const affected = affectedTasks(id, start, duration);
        // Confirmation names the exact tasks/dates/content reviewed by the user.
        // A stale confirmation can never discard newly added or changed tasks.
        if (affected.length && confirmedRemoval !== JSON.stringify(affected))
            return false;
        for (const task of affected)
            tasksModel.remove(taskIndex(task.id));
        goalsModel.set(index, {
                           goalId: id,
                           name: name.trim(),
                           startDate: start,
                           duration: duration,
                           goalColor: color
                       });
        committed(true);
        return true;
    }
    function deleteGoal(id: string): void {
        const index = goalIndex(id);
        if (!ready || index < 0)
            return;
        for (let i = tasksModel.count - 1; i >= 0; --i)
            if (tasksModel.get(i).goalId === id)
                tasksModel.remove(i);
        goalsModel.remove(index);
        committed(true);
    }
    function addTask(goalId: string, date: string, text: string): bool {
        const g = goal(goalId);
        if (!ready || !g || !text.trim() || !Dates.contains(g.startDate, g.duration, date))
            return false;
        tasksModel.append({
                              taskId: newId(),
                              goalId: goalId,
                              date: date,
                              taskText: text.trim(),
                              completed: false
                          });
        committed(false);
        return true;
    }
    function renameTask(id: string, text: string): bool {
        const index = taskIndex(id);
        if (!ready || index < 0 || !text.trim())
            return false;
        if (tasksModel.get(index).taskText !== text.trim()) {
            tasksModel.setProperty(index, "taskText", text.trim());
            committed(false);
        }
        return true;
    }
    function toggleTask(id: string): void {
        const index = taskIndex(id);
        if (!ready || index < 0)
            return;
        tasksModel.setProperty(index, "completed", !tasksModel.get(index).completed);
        committed(false);
    }
    function deleteTask(id: string): void {
        const index = taskIndex(id);
        if (!ready || index < 0)
            return;
        tasksModel.remove(index);
        committed(false);
    }
    function agenda(date: string): var {
        const entries = [];
        const allTasks = taskData;
        for (const g of Dates.lanes(goalData).filter(g => Dates.contains(g.startDate, g.duration,
                                                                         date))) {
            const dayTasks = allTasks.filter(t => t.goalId === g.id && t.date === date);
            entries.push({
                             kind: "goal",
                             goalId: g.id,
                             name: g.name,
                             color: g.color,
                             day: Dates.dayNumber(g.startDate, date),
                             duration: g.duration,
                             done: dayTasks.filter(t => t.completed).length,
                             total: dayTasks.length
                         });
            for (const task of dayTasks)
                entries.push(Object.assign({
                                               kind: "task"
                                           }, task));
            entries.push({
                             kind: "add",
                             goalId: g.id
                         });
        }
        return entries;
    }
    function flush(): void {
        if (!ready || _saving || _retryingSave || _saveError || _revision === _savedRevision)
            return;
        const text = JSON.stringify(snapshot(), null, 2) + "\n";
        // FileView skips identical text without emitting saved().
        if (text === file.text()) {
            _savedRevision = _revision;
            return;
        }
        _writingRevision = _revision;
        _saving = true;
        file.setText(text);
    }

    function retry(): void {
        if (_loading || _saving || _retryingSave)
            return;
        if (_loadError) {
            _loading = true;
            _loadError = "";
            file.reload();
        } else {
            _saveError = "";
            // A failed FileView write caches its attempted text too. Reread
            // disk before retrying, retaining our in-memory calendar throughout.
            _retryingSave = true;
            file.reload();
        }
    }

    FileView {
        id: file
        path: root.storagePath
        preload: true
        blockLoading: false
        blockWrites: false
        atomicWrites: true
        // Expected missing files and actionable failures are presented by the store.
        printErrors: false
        onLoaded: {
            if (root._retryingSave) {
                root._retryingSave = false;
                Qt.callLater(root.flush);
            } else {
                root.load(text());
            }
        }
        onLoadFailed: error => {
            if (root._retryingSave) {
                root._retryingSave = false;
                if (error === FileViewError.FileNotFound)
                    Qt.callLater(root.flush);
                else
                    root._saveError = "Cannot retry save: " + FileViewError.toString(error)
                            + ". Changes kept in memory.";
                return;
            }
            if (!root._loading)
                return;
            root._loading = false;
            if (error !== FileViewError.FileNotFound)
                root._loadError = "Cannot read calendar: " + FileViewError.toString(error)
                        + ". Retry to reload.";
        }
        onSaved: {
            root._saving = false;
            root._savedRevision = root._writingRevision;
            Qt.callLater(root.flush);
        }
        onSaveFailed: error => {
            root._saving = false;
            root._saveError = "Calendar not saved: " + FileViewError.toString(error)
                    + ". Changes kept in memory; retry.";
        }
    }
}
