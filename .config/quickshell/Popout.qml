import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

// A card that drops down from a bar pill. The bar keeps one open at a time.
PanelWindow {
    id: root

    required property var bar
    required property string name
    required property Item anchorItem
    property int cardWidth: 340
    property int padding: 18
    property int spacing: 12
    default property alias content: body.data

    readonly property bool open: bar.openPopout === name

    function close() {
        if (bar.openPopout === name) bar.openPopout = "";
    }

    function leftFor() {
        const p = anchorItem.mapToItem(null, anchorItem.width / 2, 0);
        const barLeft = (screen.width - bar.width) / 2;
        return Math.max(8, Math.min(screen.width - implicitWidth - 8, barLeft + p.x - implicitWidth / 2));
    }

    screen: bar.screen
    visible: open
    anchors.top: true
    anchors.left: true
    margins.top: 6 + Theme.barHeight + 8
    margins.left: open ? leftFor() : 0
    implicitWidth: cardWidth
    implicitHeight: card.height
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    WlrLayershell.namespace: "bar-popout"

    // clicking anywhere outside the card (bar excluded) closes it
    HyprlandFocusGrab {
        windows: [root, root.bar]
        active: root.open
        onCleared: root.close()
    }

    Rectangle {
        id: card
        width: root.cardWidth
        height: body.implicitHeight + 2 * root.padding
        Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
        radius: 16
        color: Theme.surface
        border.width: 1
        border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.35)
        opacity: root.open ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 140 } }

        focus: root.open
        Keys.onEscapePressed: root.close()

        Column {
            id: body
            x: root.padding
            y: root.padding
            width: parent.width - 2 * root.padding
            spacing: root.spacing
        }
    }
}
