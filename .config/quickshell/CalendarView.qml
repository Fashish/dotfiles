import QtQuick

Column {
    id: root
    width: parent ? parent.width : 0
    spacing: 12

    property date today: new Date()
    property int year: today.getFullYear()
    property int month: today.getMonth()

    function reset() {
        today = new Date();
        year = today.getFullYear();
        month = today.getMonth();
    }

    function shift(delta) {
        const d = new Date(year, month + delta, 1);
        year = d.getFullYear();
        month = d.getMonth();
    }

    Item {
        width: parent.width
        height: 30

        IconButton {
            anchors.left: parent.left
            text: "\u{f0141}"
            onClicked: root.shift(-1)
        }
        Label {
            anchors.centerIn: parent
            text: Qt.formatDate(new Date(root.year, root.month, 1), "MMMM yyyy")
            color: Theme.highlight
            font.pixelSize: 16
            font.weight: Font.Bold
        }
        IconButton {
            anchors.right: parent.right
            text: "\u{f0142}"
            onClicked: root.shift(1)
        }
    }

    Grid {
        id: grid
        columns: 7
        width: parent.width
        readonly property real cell: width / 7

        Repeater {
            model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
            delegate: Label {
                required property string modelData
                width: grid.cell
                height: 26
                horizontalAlignment: Text.AlignHCenter
                text: modelData
                color: Theme.muted
                font.pixelSize: 12
                font.weight: Font.Bold
            }
        }

        Repeater {
            model: 42
            delegate: Item {
                required property int index
                readonly property int offset: (new Date(root.year, root.month, 1).getDay() + 6) % 7
                readonly property date day: new Date(root.year, root.month, 1 - offset + index)
                readonly property bool inMonth: day.getMonth() === root.month
                readonly property bool isToday: day.toDateString() === root.today.toDateString()
                readonly property bool weekend: (index % 7) >= 5

                width: grid.cell
                height: 36

                Rectangle {
                    anchors.centerIn: parent
                    width: 32; height: 32; radius: 16
                    color: parent.isToday ? Theme.accent : "transparent"
                }
                Label {
                    anchors.centerIn: parent
                    text: parent.day.getDate()
                    font.weight: parent.isToday ? Font.Bold : Font.Normal
                    color: parent.isToday ? Theme.dark
                        : !parent.inMonth ? Theme.surfaceHigh
                        : parent.weekend ? Theme.highlight : Theme.fg
                }
            }
        }

        WheelHandler {
            onWheel: event => root.shift(event.angleDelta.y > 0 ? -1 : 1)
        }
    }
}
