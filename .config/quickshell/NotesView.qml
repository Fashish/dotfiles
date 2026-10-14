import QtQuick

Rectangle {
    id: root
    width: parent ? parent.width : 0
    height: 300
    radius: 10
    color: Theme.surfaceHigh

    signal closeRequested()
    function focusInput() { edit.forceActiveFocus(); }

    Flickable {
        id: flick
        anchors.fill: parent
        anchors.margins: 12
        contentHeight: edit.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        TextEdit {
            id: edit
            width: flick.width
            text: NotesStore.notes
            color: Theme.fg
            selectionColor: Theme.accent
            font.family: Theme.font
            font.pixelSize: 14
            wrapMode: TextEdit.Wrap
            onTextChanged: if (text !== NotesStore.notes) NotesStore.setNotes(text)
            onCursorRectangleChanged: {
                if (cursorRectangle.y < flick.contentY) flick.contentY = cursorRectangle.y;
                else if (cursorRectangle.y + cursorRectangle.height > flick.contentY + flick.height)
                    flick.contentY = cursorRectangle.y + cursorRectangle.height - flick.height;
            }
            Keys.onEscapePressed: root.closeRequested()
        }

        Label {
            visible: !edit.text
            text: "Notes save as you type"
            color: Theme.muted
        }
    }
}
