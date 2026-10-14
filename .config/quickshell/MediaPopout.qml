import QtQuick
import Quickshell.Services.Mpris

Popout {
    id: root
    name: "media"
    cardWidth: 380

    required property MprisPlayer player

    function time(s) {
        s = Math.max(0, Math.floor(s));
        return `${Math.floor(s / 60)}:${String(s % 60).padStart(2, "0")}`;
    }

    // MPRIS doesn't push position updates; poll while visible
    Timer {
        running: root.open && (root.player?.isPlaying ?? false)
        interval: 1000
        repeat: true
        onTriggered: root.player.positionChanged()
    }

    Row {
        width: parent.width
        spacing: 14

        Rectangle {
            width: 96; height: 96; radius: 12
            color: Theme.surfaceHigh
            clip: true

            Image {
                anchors.fill: parent
                source: root.player?.trackArtUrl ?? ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                sourceSize.width: 192
            }
            Label {
                visible: !root.player?.trackArtUrl
                anchors.centerIn: parent
                text: "\u{f075a}"
                font.family: Theme.iconFont
                font.pixelSize: 36
                color: Theme.muted
            }
        }

        Column {
            width: parent.width - 110
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            Label {
                width: parent.width
                text: root.player?.trackTitle ?? ""
                font.pixelSize: 17
                font.weight: Font.Bold
                maximumLineCount: 2
                elide: Text.ElideRight
            }
            Label {
                width: parent.width
                text: root.player?.trackArtist ?? ""
                color: Theme.highlight
                elide: Text.ElideRight
                wrapMode: Text.NoWrap
            }
            Label {
                width: parent.width
                visible: text !== ""
                text: root.player?.trackAlbum ?? ""
                color: Theme.muted
                font.pixelSize: 12
                elide: Text.ElideRight
                wrapMode: Text.NoWrap
            }
        }
    }

    Column {
        width: parent.width
        spacing: 6
        visible: root.player?.lengthSupported ?? false

        Rectangle {
            id: track
            width: parent.width
            height: 6
            radius: 3
            color: Theme.surfaceHigh

            Rectangle {
                height: parent.height
                radius: 3
                color: Theme.accent
                width: root.player && root.player.length > 0
                    ? parent.width * Math.min(1, root.player.position / root.player.length) : 0
            }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -6
                enabled: root.player?.canSeek ?? false
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: event => root.player.position = root.player.length * Math.max(0, Math.min(1, event.x / track.width))
            }
        }

        Item {
            width: parent.width
            height: 16
            Label { text: root.time(root.player?.position ?? 0); color: Theme.muted; font.pixelSize: 12 }
            Label { anchors.right: parent.right; text: root.time(root.player?.length ?? 0); color: Theme.muted; font.pixelSize: 12 }
        }
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 18

        IconButton { size: 40; text: "\u{f04ae}"; onClicked: root.player.previous() }
        IconButton {
            size: 48
            active: true
            text: root.player?.isPlaying ? "\u{f03e4}" : "\u{f040a}"
            onClicked: root.player.togglePlaying()
        }
        IconButton { size: 40; text: "\u{f04ad}"; onClicked: root.player.next() }
    }

    Label {
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        text: root.player?.identity ?? ""
        color: Theme.muted
        font.pixelSize: 11
    }
}
