import QtQuick
import Quickshell
import Quickshell.Widgets

// A tray app's menu in the bar's style. Submenus open in place, with a back row.
Popout {
    id: root
    name: "tray"
    padding: 6
    spacing: 0
    cardWidth: Math.max(180, rowWidth + 2 * padding)

    property var stack: []
    property real rowWidth: 0

    function show(item, anchor) {
        if (bar.openPopout === name && anchorItem === anchor) return close();
        anchorItem = anchor;
        rowWidth = 0;
        stack = [item.menu];
        bar.openPopout = name;
    }

    function push(entry) {
        rowWidth = 0;
        stack = stack.concat([entry]);
    }

    function pop() {
        rowWidth = 0;
        stack = stack.slice(0, -1);
    }

    QsMenuOpener {
        id: opener
        menu: root.stack.length ? root.stack[root.stack.length - 1] : null
    }

    MenuRow {
        visible: root.stack.length > 1
        label: "Back"
        leading: "\u{f0141}"
        onActivated: root.pop()
    }

    Repeater {
        model: opener.children
        onItemAdded: (index, item) => root.rowWidth = Math.max(root.rowWidth, item.implicitWidth)

        delegate: MenuRow {
            required property QsMenuEntry modelData

            separator: modelData.isSeparator
            enabled: modelData.enabled
            // DBus menus mark mnemonics with "_" and escape a literal one as "__"
            label: modelData.text.replace(/_(.)/g, "$1")
            icon: modelData.icon
            leading: modelData.buttonType === QsMenuButtonType.None ? ""
                : modelData.checkState === Qt.Checked ? "\u{f012c}" : " "
            trailing: modelData.hasChildren ? "\u{f0142}" : ""

            onActivated: {
                if (modelData.hasChildren) return root.push(modelData);
                modelData.triggered();
                root.close();
            }
        }
    }

    component MenuRow: Rectangle {
        id: row
        property bool separator: false
        property string label
        property string icon
        property string leading
        property string trailing
        signal activated()

        width: parent.width
        implicitWidth: content.implicitWidth + 24
        height: separator ? 9 : 30
        radius: 8
        color: !separator && enabled && mouse.containsMouse ? Theme.pillHover : "transparent"

        Rectangle {
            visible: row.separator
            anchors.centerIn: parent
            width: parent.width - 16
            height: 1
            color: Theme.surfaceHigh
        }

        Row {
            id: content
            visible: !row.separator
            x: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Text {
                visible: row.leading !== ""
                anchors.verticalCenter: parent.verticalCenter
                width: 14
                text: row.leading
                color: Theme.accent
                font.family: Theme.iconFont
                font.pixelSize: 14
            }
            IconImage {
                visible: row.icon !== ""
                anchors.verticalCenter: parent.verticalCenter
                implicitSize: 16
                source: row.icon
            }
            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: row.label
                wrapMode: Text.NoWrap
                font.pixelSize: 13
                color: row.enabled ? Theme.fg : Theme.muted
            }
            Text {
                visible: row.trailing !== ""
                anchors.verticalCenter: parent.verticalCenter
                text: row.trailing
                color: Theme.muted
                font.family: Theme.iconFont
                font.pixelSize: 14
            }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            enabled: !row.separator && row.enabled
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: row.activated()
        }
    }
}
