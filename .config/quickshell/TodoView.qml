import QtQuick

Column {
    id: root
    width: parent ? parent.width : 0
    spacing: 10

    signal closeRequested()
    function focusInput() { entry.forceActiveFocus(); }

    Rectangle {
        width: parent.width
        height: 38
        radius: 10
        color: Theme.surfaceHigh
        border.width: entry.activeFocus ? 1 : 0
        border.color: Theme.accent

        TextInput {
            id: entry
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            verticalAlignment: TextInput.AlignVCenter
            color: Theme.fg
            selectionColor: Theme.accent
            font.family: Theme.font
            font.pixelSize: 14
            clip: true
            onAccepted: { NotesStore.add(text); text = ""; }
            Keys.onEscapePressed: root.closeRequested()

            Label {
                visible: !entry.text
                anchors.verticalCenter: parent.verticalCenter
                text: "Add a task and press Enter"
                color: Theme.muted
            }
        }
    }

    Flickable {
        width: parent.width
        height: Math.min(list.implicitHeight, 300)
        contentHeight: list.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: list
            width: parent.width
            spacing: 2

            Repeater {
                model: NotesStore.todos
                delegate: Rectangle {
                    id: row
                    required property int index
                    required property var modelData
                    width: list.width
                    height: Math.max(34, text.implicitHeight + 14)
                    radius: 8
                    color: hover.hovered ? Theme.surfaceHigh : "transparent"

                    HoverHandler { id: hover }

                    Rectangle {
                        id: box
                        x: 8
                        anchors.verticalCenter: parent.verticalCenter
                        width: 18; height: 18; radius: 9
                        color: row.modelData.done ? Theme.accent : "transparent"
                        border.width: 2
                        border.color: row.modelData.done ? Theme.accent : Theme.muted
                        Text {
                            anchors.centerIn: parent
                            visible: row.modelData.done
                            text: "\u{f012c}"
                            color: Theme.dark
                            font.family: Theme.iconFont
                            font.pixelSize: 12
                        }
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -6
                            cursorShape: Qt.PointingHandCursor
                            onClicked: NotesStore.toggle(row.index)
                        }
                    }

                    Label {
                        id: text
                        anchors.left: box.right
                        anchors.leftMargin: 12
                        anchors.right: del.left
                        anchors.rightMargin: 6
                        anchors.verticalCenter: parent.verticalCenter
                        text: row.modelData.text
                        font.strikeout: row.modelData.done
                        color: row.modelData.done ? Theme.muted : Theme.fg
                    }

                    IconButton {
                        id: del
                        anchors.right: parent.right
                        anchors.rightMargin: 4
                        anchors.verticalCenter: parent.verticalCenter
                        size: 24
                        opacity: hover.hovered ? 1 : 0
                        text: "\u{f0156}"
                        tint: Theme.muted
                        onClicked: NotesStore.remove(row.index)
                    }
                }
            }
        }
    }

    Item {
        width: parent.width
        height: 30
        Label {
            anchors.verticalCenter: parent.verticalCenter
            visible: NotesStore.todos.length === 0
            text: "Nothing to do."
            color: Theme.muted
        }
        TextButton {
            anchors.right: parent.right
            visible: NotesStore.todos.some(t => t.done)
            text: "Clear done"
            onClicked: NotesStore.clearDone()
        }
    }
}
