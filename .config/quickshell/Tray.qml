import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

// Tray icons slide out to the left of the chevron. Left click activates, right click opens the menu.
Row {
    id: root
    property bool open: false
    readonly property var items: SystemTray.items.values
    signal menuRequested(SystemTrayItem item, Item anchor)

    visible: items.length > 0
    height: parent.height
    spacing: 4

    Item {
        height: parent.height
        width: root.open ? icons.implicitWidth : 0
        clip: true
        Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

        Pill {
            id: icons
            anchors.right: parent.right
            interactive: false

            Repeater {
                model: root.items
                delegate: MouseArea {
                    id: entry
                    required property SystemTrayItem modelData

                    anchors.verticalCenter: parent.verticalCenter
                    width: 18
                    height: 18
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                    onClicked: event => {
                        if (event.button === Qt.MiddleButton) modelData.secondaryActivate();
                        else if (event.button === Qt.RightButton || modelData.onlyMenu) {
                            if (modelData.hasMenu) root.menuRequested(modelData, entry);
                        } else modelData.activate();
                    }
                    onWheel: event => modelData.scroll(event.angleDelta.y, false)

                    IconImage {
                        anchors.fill: parent
                        opacity: entry.containsMouse ? 1 : 0.85
                        // some apps (Steam) send "name?path=dir", which the icon provider can't resolve
                        source: {
                            const icon = entry.modelData.icon;
                            if (!icon.includes("?path=")) return icon;
                            const [name, path] = icon.split("?path=");
                            return `file://${path}/${name.slice(name.lastIndexOf("/") + 1)}`;
                        }
                    }
                }
            }
        }
    }

    Pill {
        onClicked: root.open = !root.open
        Icon { text: root.open ? "\u{f0142}" : "\u{f0141}" }
    }
}
