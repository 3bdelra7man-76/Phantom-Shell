pragma Singleton

import QtQuick
import QtQml.Models
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string storagePath: Quickshell.dataPath("tasks.json")
    readonly property alias model: tasksModel
    readonly property int activeCount: _activeCount
    readonly property bool ready: !_loading && _loadError === ""
    readonly property bool saving: _saving || _retryingSave || _revision !== _savedRevision
    readonly property string error: _loadError || _saveError
    property int _activeCount: 0
    property bool _loading: true
    property string _loadError: ""
    property string _saveError: ""
    property bool _saving: false
    property bool _retryingSave: false
    property int _revision: 0
    property int _savedRevision: 0
    property int _writingRevision: 0

    ListModel {
        id: tasksModel
    }

    function load(text: string): void {
        if (!_loading)
            return;
        try {
            const data = JSON.parse(text);
            if (data.version !== 1 || !Array.isArray(data.tasks))
                throw new Error("Unsupported task file");
            const ids = new Set();
            let active = 0;
            const tasks = data.tasks.map(task => {
                if (!task || typeof task.id !== "string" || task.id.length === 0 || ids.has(task.id)
                        || typeof task.text !== "string" || task.text.trim().length === 0
                        || typeof task.completed !== "boolean")
                    throw new Error("Invalid task");
                ids.add(task.id);
                if (!task.completed)
                    ++active;
                return {
                    taskId: task.id,
                    taskText: task.text.trim(),
                    completed: task.completed
                };
            });
            // Validate the entire file before publishing any rows.
            tasksModel.clear();
            tasksModel.append(tasks);
            _activeCount = active;
            _loadError = "";
        } catch (error) {
            _loadError = "Task file is invalid. Original data preserved; repair it, then retry.";
        }
        _loading = false;
    }

    function indexOf(id: string): int {
        for (let index = 0; index < tasksModel.count; ++index) {
            if (tasksModel.get(index).taskId === id)
                return index;
        }
        return -1;
    }

    function task(id: string): var {
        const index = indexOf(id);
        return index < 0 ? null : tasksModel.get(index);
    }

    function committed(): void {
        ++_revision;
        // Coalesce commits in this event turn; serialization never runs in a
        // checkbox/text-field handler, and only one async write runs at a time.
        Qt.callLater(flush);
    }

    function add(text: string): bool {
        const trimmed = text.trim();
        if (!ready || !trimmed)
            return false;
        let id;
        do {
            id = Date.now().toString(36) + "-" + Math.random().toString(36).slice(2);
        } while (indexOf(id) >= 0)
        tasksModel.append({
                              taskId: id,
                              taskText: trimmed,
                              completed: false
                          });
        ++_activeCount;
        committed();
        return true;
    }

    function rename(id: string, text: string): bool {
        const index = indexOf(id);
        const trimmed = text.trim();
        if (!ready || !trimmed || index < 0)
            return false;
        if (tasksModel.get(index).taskText !== trimmed) {
            tasksModel.setProperty(index, "taskText", trimmed);
            committed();
        }
        return true;
    }

    function toggle(id: string): void {
        const index = indexOf(id);
        if (!ready || index < 0)
            return;
        const completed = !tasksModel.get(index).completed;
        tasksModel.setProperty(index, "completed", completed);
        _activeCount += completed ? -1 : 1;
        committed();
    }

    function remove(id: string): void {
        const index = indexOf(id);
        if (!ready || index < 0)
            return;
        if (!tasksModel.get(index).completed)
            --_activeCount;
        tasksModel.remove(index);
        committed();
    }

    function snapshot(): var {
        // Plain JS objects avoid the expensive JSON traversal of a QML list<var>.
        const tasks = [];
        for (let index = 0; index < tasksModel.count; ++index) {
            const task = tasksModel.get(index);
            tasks.push({
                           id: task.taskId,
                           text: task.taskText,
                           completed: task.completed
                       });
        }
        return tasks;
    }

    function flush(): void {
        if (!ready || _saving || _retryingSave || _saveError || _revision === _savedRevision)
            return;
        const text = JSON.stringify({
                                        version: 1,
                                        tasks: snapshot()
                                    }, null, 2) + "\n";
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
            // disk before retrying, retaining our in-memory tasks throughout.
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
                root._loadError = "Cannot read tasks: " + FileViewError.toString(error)
                        + ". Retry to reload.";
        }
        onSaved: {
            root._saving = false;
            root._savedRevision = root._writingRevision;
            Qt.callLater(root.flush);
        }
        onSaveFailed: error => {
            root._saving = false;
            root._saveError = "Tasks not saved: " + FileViewError.toString(error)
                    + ". Changes kept in memory; retry.";
        }
    }
}
