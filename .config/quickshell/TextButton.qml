import QtQuick

Rectangle {
    id: root
    property alias text: label.text
    property bool primary: false
    signal clicked()

    implicitWidth: label.implicitWidth + 24
    implicitHeight: 30
    radius: 15
    color: primary ? Theme.accent : mouse.containsMouse ? Theme.pillHover : Theme.surfaceHigh
    Behavior on color { ColorAnimation { duration: 120 } }

    Text {
        id: label
        anchors.centerIn: parent
        color: root.primary ? Theme.dark : Theme.fg
        font.family: Theme.font
        font.pixelSize: 13
        font.weight: Font.DemiBold
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
