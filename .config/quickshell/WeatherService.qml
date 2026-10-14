pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Open-Meteo, no API key. London; change the coordinates to move.
Singleton {
    id: root
    readonly property real latitude: 51.5074
    readonly property real longitude: -0.1278
    readonly property string place: "London"

    property var current: null
    property var daily: null
    property date updated

    readonly property bool ready: current !== null

    function icon(code, day) {
        if (code === 0) return day === false ? "\u{f0594}" : "\u{f0599}";
        if (code <= 2) return day === false ? "\u{f0f31}" : "\u{f0595}";
        if (code === 3) return "\u{f0590}";
        if (code <= 48) return "\u{f0591}";
        if (code <= 57) return "\u{f0597}";
        if (code <= 64) return "\u{f0597}";
        if (code <= 67) return "\u{f0596}";
        if (code <= 77) return "\u{f0598}";
        if (code <= 82) return "\u{f0596}";
        if (code <= 86) return "\u{f0598}";
        return "\u{f0593}";
    }

    function describe(code) {
        const names = {
            0: "Clear", 1: "Mostly clear", 2: "Partly cloudy", 3: "Overcast",
            45: "Fog", 48: "Freezing fog",
            51: "Light drizzle", 53: "Drizzle", 55: "Heavy drizzle", 56: "Freezing drizzle", 57: "Freezing drizzle",
            61: "Light rain", 63: "Rain", 65: "Heavy rain", 66: "Freezing rain", 67: "Freezing rain",
            71: "Light snow", 73: "Snow", 75: "Heavy snow", 77: "Snow grains",
            80: "Light showers", 81: "Showers", 82: "Heavy showers", 85: "Snow showers", 86: "Snow showers",
            95: "Thunderstorm", 96: "Thunderstorm, hail", 99: "Thunderstorm, hail"
        };
        return names[code] ?? "Unknown";
    }

    Process {
        id: fetch
        command: ["curl", "-sf", "-m", "20",
            `https://api.open-meteo.com/v1/forecast?latitude=${root.latitude}&longitude=${root.longitude}`
            + "&current=temperature_2m,apparent_temperature,relative_humidity_2m,weather_code,wind_speed_10m,is_day"
            + "&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max"
            + "&wind_speed_unit=mph&timezone=Europe%2FLondon&forecast_days=5"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const j = JSON.parse(text);
                    root.current = j.current;
                    root.daily = j.daily;
                    root.updated = new Date();
                } catch (e) {
                    console.warn("weather: bad response", e);
                }
            }
        }
    }

    Timer {
        interval: 30 * 60 * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: fetch.running = true
    }

    IpcHandler {
        target: "weather"
        function refresh(): void { fetch.running = true; }
    }
}
