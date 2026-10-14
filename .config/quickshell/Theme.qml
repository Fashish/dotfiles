pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    readonly property color bg: Qt.rgba(40 / 255, 40 / 255, 40 / 255, 0.45)
    readonly property color pill: Qt.rgba(60 / 255, 56 / 255, 54 / 255, 0.55)
    readonly property color pillHover: Qt.rgba(80 / 255, 73 / 255, 69 / 255, 0.85)
    readonly property color border: Qt.rgba(accent.r, accent.g, accent.b, 0.15)
    readonly property color fg: "#ebdbb2"
    readonly property color muted: "#665c54"
    readonly property color dark: "#282828"
    readonly property color surface: "#282828"
    readonly property color surfaceHigh: "#3c3836"

    // written by ~/.config/hypr/bin/wallpaper.sh
    readonly property color accent: state.accent
    readonly property color highlight: state.highlight
    readonly property string wallpaper: state.wallpaper

    readonly property string font: "DM Sans"
    readonly property string iconFont: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 14
    readonly property int barHeight: 36

    FileView {
        id: file
        path: Quickshell.env("HOME") + "/.local/state/desktop/theme.json"
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            id: state
            property string wallpaper: ""
            property string accent: "#d65d0e"
            property string highlight: "#fe8019"
        }
    }

    IpcHandler {
        target: "theme"
        function reload(): void { file.reload(); }
    }
}
