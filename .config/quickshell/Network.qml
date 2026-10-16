import QtQuick
import Quickshell
import Quickshell.Networking

Pill {
    id: root
    readonly property var devices: Networking.devices.values
    readonly property var wifi: devices.find(d => d.type === DeviceType.Wifi && d.connected) ?? null
    readonly property var wired: devices.find(d => d.type === DeviceType.Wired && d.connected) ?? null
    readonly property var network: wifi?.networks.values.find(n => n.connected) ?? null
    readonly property real strength: network?.signalStrength ?? 0
    readonly property var bars: ["\u{f092f}", "\u{f091f}", "\u{f0922}", "\u{f0925}", "\u{f0928}"]

    onClicked: Quickshell.execDetached(["ghostty", "-e", Quickshell.env("HOME") + "/.config/waybar/scripts/nmtui.sh"])

    BarText {
        visible: root.hovered || !root.network && !root.wired
        text: root.network ? `${Math.round(root.strength * 100)}%` : root.wired ? "Wired" : "Disconnected"
    }
    Icon {
        text: root.network ? root.bars[Math.min(4, Math.floor(root.strength * 5))]
            : root.wired ? "\u{f0200}" : "\u{f092d}"
    }
}
