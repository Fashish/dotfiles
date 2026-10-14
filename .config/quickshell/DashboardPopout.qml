import QtQuick

// Opened from the clock pill: calendar, weather, to-do, notes and timer as tabs.
Popout {
    id: root
    name: "dashboard"
    // wide enough for every tab, including the timer's countdown, plus side padding
    cardWidth: Math.max(400, tabsRow.implicitWidth + 36 + 24)

    property string tab: "calendar"
    readonly property var tabs: [
        { id: "calendar", icon: "\u{f00ed}", label: "Calendar" },
        { id: "weather", icon: "\u{f0595}", label: "Weather" },
        { id: "todo", icon: "\u{f0756}", label: "To-do" },
        { id: "notes", icon: "\u{f09ed}", label: "Notes" },
        { id: "timer", icon: "\u{f13ab}", label: "Timer" }
    ]

    function show(t) {
        tab = t;
        focusTab();
    }

    function focusTab() {
        if (tab === "todo") todo.focusInput();
        else if (tab === "notes") notes.focusInput();
        else if (tab === "timer") timer.focusInput();
    }

    onOpenChanged: if (open) {
        calendar.reset();
        focusTab();
    }

    Row {
        id: tabsRow
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 4

        Repeater {
            model: root.tabs
            delegate: Rectangle {
                id: tabButton
                required property var modelData
                readonly property bool selected: root.tab === modelData.id
                readonly property string badge: modelData.id === "todo" && NotesStore.openCount > 0 ? ` ${NotesStore.openCount}`
                    : modelData.id === "timer" && Countdown.active ? ` ${Countdown.format(Countdown.remaining)}` : ""

                width: content.implicitWidth + 24
                height: 30
                clip: true
                Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                radius: 15
                color: selected ? Theme.accent : mouse.containsMouse ? Theme.pillHover : "transparent"
                Behavior on color { ColorAnimation { duration: 120 } }

                Row {
                    id: content
                    anchors.centerIn: parent
                    spacing: 6
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: tabButton.modelData.icon
                        color: tabButton.selected ? Theme.dark : Theme.fg
                        font.family: Theme.iconFont
                        font.pixelSize: 14
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: tabButton.modelData.label + tabButton.badge
                        color: tabButton.selected ? Theme.dark : Theme.fg
                        font.family: Theme.font
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        font.features: { "tnum": 1 }
                    }
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.show(tabButton.modelData.id)
                }
            }
        }
    }

    Rectangle { width: parent.width; height: 1; color: Theme.surfaceHigh }

    CalendarView { id: calendar; visible: root.tab === "calendar" }
    WeatherView { visible: root.tab === "weather" }
    TodoView { id: todo; visible: root.tab === "todo"; onCloseRequested: root.close() }
    NotesView { id: notes; visible: root.tab === "notes"; onCloseRequested: root.close() }
    TimerView { id: timer; visible: root.tab === "timer"; onCloseRequested: root.close() }
}
