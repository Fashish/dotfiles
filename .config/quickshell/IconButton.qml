import QtQuick

Rectangle {
    id: root
    property alias text: glyph.text
    property int size: 28
    property bool active: false
    property color tint: Theme.fg
    signal clicked()

    width: size
    height: size
    radius: size / 2
    color: active ? Theme.accent : mouse.containsMouse ? Theme.pillHover : "transparent"
    Behavior on color { ColorAnimation { duration: 120 } }

    Text {
        id: glyph
        anchors.centerIn: parent
        color: root.active ? Theme.dark : root.tint
        font.family: Theme.iconFont
        font.pixelSize: Math.round(root.size * 0.5)
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
