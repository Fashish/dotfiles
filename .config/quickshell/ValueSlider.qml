import QtQuick

// Labelled slider: drag, click or scroll. Emits moved() only on user input.
Column {
    id: root
    property string label
    property int from: 0
    property int to: 100
    property int step: 5
    property int value: 0
    property string unit: "%"
    signal moved(int value)

    spacing: 6

    function set(v) {
        v = Math.max(from, Math.min(to, Math.round(v / step) * step));
        if (v !== value) { value = v; moved(v); }
    }

    Row {
        width: parent.width
        Label { text: root.label; font.pixelSize: 13; width: parent.width - amount.width }
        Label { id: amount; text: root.value + root.unit; font.pixelSize: 13; color: Theme.muted; font.features: { "tnum": 1 } }
    }

    Item {
        width: parent.width
        height: 18

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: 6
            radius: 3
            color: Theme.surfaceHigh

            Rectangle {
                width: parent.width * (root.value - root.from) / (root.to - root.from)
                height: parent.height
                radius: 3
                color: Theme.accent
            }
        }

        Rectangle {
            x: (parent.width - width) * (root.value - root.from) / (root.to - root.from)
            anchors.verticalCenter: parent.verticalCenter
            width: 16
            height: 16
            radius: 8
            color: Theme.highlight
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            preventStealing: true
            function at(x) { root.set(root.from + (root.to - root.from) * x / width); }
            onPressed: event => at(event.x)
            onPositionChanged: event => at(event.x)
            onWheel: event => root.set(root.value + (event.angleDelta.y > 0 ? root.step : -root.step))
        }
    }
}
