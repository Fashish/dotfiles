import QtQuick
import Quickshell

// Time │ weather │ running timer. Click opens the dashboard.
Pill {
    id: root
    property bool long: false

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Icon { text: "\u{f0954}" }
    BarText { text: Qt.formatDateTime(clock.date, root.long ? "ddd d MMM yyyy" : "HH:mm") }

    BarText { visible: WeatherService.ready; text: "│"; color: Theme.muted; font.weight: Font.Normal }
    Icon {
        visible: WeatherService.ready
        text: WeatherService.ready
            ? WeatherService.icon(WeatherService.current.weather_code, WeatherService.current.is_day === 1) : ""
    }
    BarText {
        visible: WeatherService.ready
        text: WeatherService.ready ? `${Math.round(WeatherService.current.temperature_2m)}°` : ""
    }

    BarText { visible: Countdown.active; text: "│"; color: Theme.muted; font.weight: Font.Normal }
    Icon { visible: Countdown.active; text: "\u{f13ab}"; color: Theme.highlight }
    BarText {
        visible: Countdown.active
        text: Countdown.format(Countdown.remaining)
        color: Countdown.running ? Theme.highlight : Theme.muted
        font.features: { "tnum": 1 }
    }
}
