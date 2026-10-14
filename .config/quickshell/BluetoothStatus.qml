import QtQuick
import Quickshell
import Quickshell.Bluetooth

Pill {
    id: root
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var device: adapter?.devices.values.find(d => d.connected) ?? null

    onClicked: Quickshell.execDetached(["blueman-manager"])

    Icon {
        text: !root.adapter?.enabled ? "\u{f00b2}" : root.device ? "\u{f00b1}" : "\u{f00b2}"
    }
    BarText {
        text: !root.adapter?.enabled ? "Disabled"
            : !root.device ? "Disconnected"
            : root.device.batteryAvailable ? `${root.device.name} ${Math.round(root.device.battery * 100)}%`
            : root.device.name
    }
}
