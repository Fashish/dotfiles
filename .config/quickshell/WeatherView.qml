import QtQuick

Column {
    id: root
    width: parent ? parent.width : 0
    spacing: 12

    readonly property var now: WeatherService.current
    readonly property var days: WeatherService.daily

    Label {
        visible: root.now === null
        text: "Waiting for Open-Meteo…"
        color: Theme.muted
    }

    Row {
        width: parent.width
        spacing: 16
        visible: root.now !== null

        Label {
            anchors.verticalCenter: parent.verticalCenter
            text: root.now ? WeatherService.icon(root.now.weather_code, root.now.is_day === 1) : ""
            font.family: Theme.iconFont
            font.pixelSize: 54
            color: Theme.highlight
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            Label {
                text: root.now ? `${Math.round(root.now.temperature_2m)}°C` : ""
                font.pixelSize: 34
                font.weight: Font.Bold
            }
            Label {
                text: root.now ? WeatherService.describe(root.now.weather_code) : ""
                color: Theme.highlight
            }
        }
    }

    Label {
        width: parent.width
        visible: root.now !== null
        color: Theme.muted
        font.pixelSize: 13
        text: root.now
            ? `${WeatherService.place} · feels like ${Math.round(root.now.apparent_temperature)}° · humidity ${root.now.relative_humidity_2m}% · wind ${Math.round(root.now.wind_speed_10m)} mph`
            : ""
    }

    Rectangle { width: parent.width; height: 1; color: Theme.surfaceHigh; visible: root.days !== null }

    Column {
        width: parent.width
        spacing: 6
        visible: root.days !== null

        Repeater {
            model: root.days ? root.days.time.length : 0
            delegate: Item {
                required property int index
                width: parent.width
                height: 26

                Label {
                    width: 90
                    anchors.verticalCenter: parent.verticalCenter
                    text: index === 0 ? "Today" : Qt.formatDate(new Date(root.days.time[index]), "dddd")
                    font.weight: Font.DemiBold
                }
                Label {
                    x: 96
                    anchors.verticalCenter: parent.verticalCenter
                    text: WeatherService.icon(root.days.weather_code[index], true)
                    font.family: Theme.iconFont
                    font.pixelSize: 18
                    color: Theme.highlight
                }
                Label {
                    x: 130
                    anchors.verticalCenter: parent.verticalCenter
                    text: `\u{f058c} ${root.days.precipitation_probability_max[index]}%`
                    font.family: Theme.iconFont
                    font.pixelSize: 12
                    color: root.days.precipitation_probability_max[index] >= 50 ? "#83a598" : Theme.muted
                }
                Label {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: `${Math.round(root.days.temperature_2m_max[index])}°  <font color="${Theme.muted}">${Math.round(root.days.temperature_2m_min[index])}°</font>`
                    textFormat: Text.StyledText
                    font.weight: Font.DemiBold
                }
            }
        }
    }

    Label {
        width: parent.width
        horizontalAlignment: Text.AlignRight
        visible: root.now !== null
        text: `Open-Meteo · updated ${Qt.formatTime(WeatherService.updated, "HH:mm")}`
        color: Theme.muted
        font.pixelSize: 11
    }
}
