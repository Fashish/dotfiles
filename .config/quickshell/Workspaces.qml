import QtQuick
import Quickshell.Hyprland

Row {
    id: root
    readonly property var ids: Hyprland.workspaces.values.map(w => w.id)
    readonly property int count: Math.min(10, Math.max(5, ...ids))

    spacing: 4

    Repeater {
        model: root.count

        delegate: Rectangle {
            required property int index
            readonly property int wsId: index + 1
            readonly property bool active: Hyprland.focusedWorkspace?.id === wsId
            readonly property bool occupied: root.ids.includes(wsId)

            anchors.verticalCenter: parent.verticalCenter
            width: active ? 36 : 20
            height: 20
            radius: 10
            color: active || mouse.containsMouse ? Theme.accent : Theme.fg
            opacity: active || occupied ? 1 : 0.45

            Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation { duration: 150 } }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                // dispatch takes a Lua expression since the Lua config migration
                onClicked: Hyprland.dispatch(`hl.dsp.focus({ workspace = ${parent.wsId} })`)
            }
        }
    }
}
