import QtQuick
import Quickshell.Services.Mpris

Pill {
    id: root
    readonly property var players: Mpris.players.values
    readonly property MprisPlayer player: players.find(p => p.isPlaying) ?? players[0] ?? null

    visible: player !== null && player.trackTitle !== ""

    Row {
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0
        IconButton { size: 24; text: "\u{f04ae}"; onClicked: root.player.previous() }
        IconButton { size: 24; text: root.player?.isPlaying ? "\u{f03e4}" : "\u{f040a}"; onClicked: root.player.togglePlaying() }
        IconButton { size: 24; text: "\u{f04ad}"; onClicked: root.player.next() }
    }
    BarText {
        width: Math.min(implicitWidth, 320)
        elide: Text.ElideRight
        text: {
            const p = root.player;
            if (!p) return "";
            return p.trackArtist ? `${p.trackArtist} – ${p.trackTitle}` : p.trackTitle;
        }
    }
}
