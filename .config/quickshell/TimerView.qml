import QtQuick

Column {
    id: root
    width: parent ? parent.width : 0
    spacing: 12

    signal closeRequested()
    function focusInput() { if (!Countdown.active) minutes.forceActiveFocus(); }

    Label {
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        text: Countdown.active ? Countdown.format(Countdown.remaining) : "0:00"
        font.pixelSize: 52
        font.weight: Font.Light
        font.features: { "tnum": 1 }
        color: Countdown.running ? Theme.highlight : Countdown.active ? Theme.fg : Theme.muted
    }

    Rectangle {
        width: parent.width
        height: 6
        radius: 3
        color: Theme.surfaceHigh

        Rectangle {
            height: parent.height
            radius: 3
            color: Theme.accent
            width: Countdown.total > 0 ? parent.width * Countdown.remaining / Countdown.total : 0
            Behavior on width { NumberAnimation { duration: 250 } }
        }
    }

    Flow {
        width: parent.width
        spacing: 6
        Repeater {
            model: [[5, "5 min"], [10, "10 min"], [15, "15 min"], [25, "Pomodoro 25"], [45, "45 min"], [60, "1 hour"]]
            delegate: TextButton {
                required property var modelData
                text: modelData[1]
                onClicked: Countdown.start(modelData[0] * 60)
            }
        }
    }

    Row {
        spacing: 8

        Rectangle {
            width: 120
            height: 30
            radius: 15
            color: Theme.surfaceHigh
            border.width: minutes.activeFocus ? 1 : 0
            border.color: Theme.accent

            TextInput {
                id: minutes
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                verticalAlignment: TextInput.AlignVCenter
                color: Theme.fg
                font.family: Theme.font
                font.pixelSize: 13
                validator: IntValidator { bottom: 1; top: 600 }
                onAccepted: if (text) { Countdown.start(parseInt(text) * 60); text = ""; }
                Keys.onEscapePressed: root.closeRequested()

                Label {
                    visible: !minutes.text
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Minutes ⏎"
                    color: Theme.muted
                    font.pixelSize: 13
                }
            }
        }

        TextButton { text: "+1 min"; onClicked: Countdown.add(60) }
        TextButton { text: "+5 min"; onClicked: Countdown.add(300) }
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 8
        visible: Countdown.active

        TextButton {
            primary: true
            text: Countdown.running ? "Pause" : "Resume"
            onClicked: Countdown.running ? Countdown.pause() : Countdown.resume()
        }
        TextButton { text: "Reset"; onClicked: Countdown.reset() }
    }
}
