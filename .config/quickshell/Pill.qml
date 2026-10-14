import QtQuick

Rectangle {
    id: root

    default property alias content: row.data
    property bool interactive: true
    readonly property bool hovered: mouse.containsMouse
    signal clicked(int button)
    signal scrolled(int delta)

    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
    implicitWidth: row.implicitWidth + 30
    implicitHeight: 28
    radius: 18
    color: interactive && mouse.containsMouse ? Theme.pillHover : Theme.pill
    Behavior on color { ColorAnimation { duration: 150 } }

    Row {
        id: row
        anchors.centerIn: parent
        height: parent.height
        spacing: 8
    }

    MouseArea {
        id: mouse
        z: -1  // below the content, so buttons inside a pill get their own clicks
        anchors.fill: parent
        enabled: root.interactive
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: event => root.clicked(event.button)
        onWheel: event => root.scrolled(event.angleDelta.y)
    }
}
