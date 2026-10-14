import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Pill {
    id: root
    property bool on: false

    color: on ? Theme.accent : Theme.pill
    onClicked: {
        Quickshell.execDetached(["hyprctl", "eval", "ToggleHDR()"]);
        settle.restart();
    }

    Component.onCompleted: probe.running = true

    // same test as waybar's hdr.sh: the HDR profile sets sdrBrightness to 1.1
    Process {
        id: probe
        command: ["sh", "-c", "hyprctl monitors -j | jq -r 'first(.[] | select(.name == \"DP-2\") | .sdrBrightness > 1.05) // false'"]
        stdout: StdioCollector {
            onStreamFinished: root.on = text.trim() === "true"
        }
    }

    Timer {
        id: settle
        interval: 1500
        onTriggered: probe.running = true
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name.startsWith("monitor") || event.name === "configreloaded")
                settle.restart();
        }
    }

    IpcHandler {
        target: "hdr"
        function refresh(): void { probe.running = true; }
    }

    BarText {
        text: "HDR"
        font.pixelSize: 12
        color: root.on ? Theme.dark : Theme.muted
    }
}
