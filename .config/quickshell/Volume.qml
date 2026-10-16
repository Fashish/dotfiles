import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Pill {
    id: root
    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false

    onClicked: button => {
        if (button === Qt.LeftButton) Quickshell.execDetached(["pavucontrol"]);
        else if (button === Qt.RightButton && sink) sink.audio.muted = !muted;
    }
    onScrolled: delta => {
        if (sink) sink.audio.volume = Math.max(0, Math.min(1, volume + (delta > 0 ? 0.01 : -0.01)));
    }

    PwObjectTracker { objects: [root.sink] }

    BarText { text: root.muted ? "Muted" : `${Math.round(root.volume * 100)}%` }
    Icon { text: root.muted ? "\u{f0581}" : root.volume < 0.5 ? "\u{f0580}" : "\u{f057e}" }
}
