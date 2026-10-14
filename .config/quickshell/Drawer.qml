import QtQuick

// waybar's group/volwifibt: the head pill slides the others out to its left
Row {
    id: root
    property bool open: false

    height: parent.height
    spacing: 4

    Item {
        height: parent.height
        width: root.open ? items.implicitWidth : 0
        clip: true
        Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

        Row {
            id: items
            anchors.right: parent.right
            height: parent.height
            spacing: 4
            Volume {}
            BluetoothStatus {}
            Network {}
        }
    }

    Pill {
        onClicked: root.open = !root.open
        Icon { text: "\u{f057e}  \u{f0928}" }
    }
}
