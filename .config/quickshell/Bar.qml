import QtQuick
import Quickshell
import Quickshell.Io

PanelWindow {
    id: bar
    required property var modelData

    // name of the open popout, "" when none; one at a time
    property string openPopout: ""
    function toggle(name) {
        openPopout = openPopout === name ? "" : name;
    }

    IpcHandler {
        target: "bar"
        // dashboard or media
        function toggle(name: string): void { bar.toggle(name); }
        // dashboard tab: calendar, weather, todo, notes, timer
        function show(tab: string): void {
            bar.openPopout = "dashboard";
            dashboard.show(tab);
        }
    }

    screen: modelData
    anchors.top: true
    margins.top: 6
    // matches waybar's 800px side margins
    implicitWidth: Math.max(800, modelData.width - 1600)
    implicitHeight: Theme.barHeight
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: Theme.bg
        border.width: 1
        border.color: Theme.border

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 4
            height: parent.height
            spacing: 4
            Clock {
                id: clock
                onClicked: button => button === Qt.RightButton ? long = !long : bar.toggle("dashboard")
            }
            Media {
                id: media
                onClicked: bar.toggle("media")
            }
        }

        Workspaces {
            anchors.centerIn: parent
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 4
            height: parent.height
            spacing: 4
            Tray { onMenuRequested: (item, anchor) => trayMenu.show(item, anchor) }
            Hdr {}
            Volume {}
            Network {}
            Bell {}
        }
    }

    DashboardPopout { id: dashboard; bar: bar; anchorItem: clock }
    TrayMenu { id: trayMenu; bar: bar; anchorItem: clock }
    MediaPopout { bar: bar; anchorItem: media; player: media.player }
}
