pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    readonly property var todos: data.todos
    readonly property string notes: data.notes
    readonly property int openCount: todos.filter(t => !t.done).length

    function setTodos(list) {
        data.todos = list;
        file.writeAdapter();
    }

    function add(text) {
        text = text.trim();
        if (text) setTodos([...todos, { text: text, done: false }]);
    }

    function toggle(i) {
        setTodos(todos.map((t, j) => j === i ? { text: t.text, done: !t.done } : t));
    }

    function remove(i) {
        setTodos(todos.filter((_, j) => j !== i));
    }

    function clearDone() {
        setTodos(todos.filter(t => !t.done));
    }

    function setNotes(text) {
        data.notes = text;
        saveNotes.restart();
    }

    Timer {
        id: saveNotes
        interval: 800
        onTriggered: file.writeAdapter()
    }

    FileView {
        id: file
        path: Quickshell.env("HOME") + "/.local/state/desktop/notes.json"
        atomicWrites: true

        JsonAdapter {
            id: data
            property var todos: []
            property string notes: ""
        }
    }
}
