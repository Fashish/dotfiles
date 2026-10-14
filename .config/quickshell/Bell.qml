import QtQuick
import Quickshell
import Quickshell.Io

// swaync stays the notification daemon; this mirrors waybar's custom/notification.
Pill {
    id: root
    property int count: 0
    property bool dnd: false

    onClicked: button => {
        if (button === Qt.LeftButton) Quickshell.execDetached(["swaync-client", "-t", "-sw"]);
        else if (button === Qt.RightButton) Quickshell.execDetached(["swaync-client", "-d", "-sw"]);
    }

    Process {
        id: proc
        running: true
        command: ["swaync-client", "-swb"]
        stdout: SplitParser {
            onRead: line => {
                try {
                    const j = JSON.parse(line);
                    root.count = parseInt(j.text) || 0;
                    root.dnd = String(j.alt).startsWith("dnd");
                } catch (e) {}
            }
        }
        // swaync may start after the shell; retry rather than give up
        onExited: restart.start()
    }

    Timer {
        id: restart
        interval: 3000
        onTriggered: proc.running = true
    }

    Item {
        anchors.verticalCenter: parent.verticalCenter
        width: bell.implicitWidth
        height: bell.implicitHeight

        Icon {
            id: bell
            anchors.verticalCenter: undefined
            text: root.dnd ? "\u{f009b}" : "\u{f009a}"
        }
        Rectangle {
            visible: root.count > 0
            anchors.right: bell.right
            anchors.top: bell.top
            anchors.rightMargin: -3
            width: 7; height: 7; radius: 3.5
            color: "#fb4934"
        }
    }
}
