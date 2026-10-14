pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property int total: 0
    property int remaining: 0
    property bool running: false
    readonly property bool active: total > 0

    // wall-clock deadline, so suspend or a busy shell can't drift the timer
    property real deadline: 0

    function format(s) {
        const h = Math.floor(s / 3600), m = Math.floor(s % 3600 / 60), sec = s % 60;
        const mm = String(m).padStart(h ? 2 : 1, "0"), ss = String(sec).padStart(2, "0");
        return h ? `${h}:${mm}:${ss}` : `${mm}:${ss}`;
    }

    function start(seconds) {
        total = seconds;
        remaining = seconds;
        resume();
    }

    function resume() {
        if (remaining <= 0) return;
        deadline = Date.now() + remaining * 1000;
        running = true;
    }

    function pause() {
        running = false;
    }

    function add(seconds) {
        if (!active) return start(seconds);
        total += seconds;
        remaining += seconds;
        if (running) deadline += seconds * 1000;
    }

    function reset() {
        running = false;
        total = 0;
        remaining = 0;
    }

    Timer {
        interval: 250
        repeat: true
        running: root.running
        onTriggered: {
            root.remaining = Math.max(0, Math.ceil((root.deadline - Date.now()) / 1000));
            if (root.remaining === 0) {
                const mins = Math.round(root.total / 60);
                root.reset();
                Quickshell.execDetached(["notify-send", "Timer finished", `${mins} min timer is up`]);
                Quickshell.execDetached(["pw-play", "/usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga"]);
            }
        }
    }

    IpcHandler {
        target: "timer"
        function start(seconds: int): void { root.start(seconds); }
        function toggle(): void { root.running ? root.pause() : root.resume(); }
        function reset(): void { root.reset(); }
    }
}
