import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: root
    readonly property string folder: Quickshell.env("HOME") + "/Pictures/wallpapers"
    readonly property string script: Quickshell.env("HOME") + "/.config/hypr/bin/wallpaper.sh"

    function open() {
        visible = true;
        const i = files.indexOf("file://" + Theme.wallpaper);
        grid.currentIndex = i >= 0 ? i : 0;
        grid.positionViewAtIndex(grid.currentIndex, GridView.Center);
        grid.forceActiveFocus();
    }

    function choose(path) {
        Quickshell.execDetached([script, "set", path]);
        visible = false;
    }

    visible: false
    anchors { top: true; bottom: true; left: true; right: true }
    color: Qt.rgba(0, 0, 0, 0.45)
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "wallpaper-picker"

    IpcHandler {
        target: "wallpaper"
        function toggle(): void { root.visible ? root.visible = false : root.open(); }
        function close(): void { root.visible = false; }
    }

    FolderListModel {
        id: files
        folder: "file://" + root.folder
        nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp"]
        showDirs: false
        sortField: FolderListModel.Name
    }

    // click outside the panel to close
    MouseArea {
        anchors.fill: parent
        onClicked: root.visible = false
    }

    Rectangle {
        id: panel
        anchors.centerIn: parent
        width: Math.min(parent.width - 160, grid.cellWidth * 4 + 48)
        height: Math.min(parent.height - 200, header.height + grid.cellHeight * 3 + 64)
        radius: 18
        color: Theme.surface
        border.width: 1
        border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.35)

        MouseArea { anchors.fill: parent }  // swallow clicks inside

        Row {
            id: header
            x: 24
            y: 20
            spacing: 12

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 10; height: 10; radius: 5
                color: Theme.accent
            }
            Text {
                text: "Wallpapers"
                color: Theme.fg
                font.family: Theme.font
                font.pixelSize: 20
                font.weight: Font.Bold
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: `${files.count} in ~/Pictures/wallpapers · arrows + Enter · Esc to close`
                color: Theme.muted
                font.family: Theme.font
                font.pixelSize: 13
            }
        }

        GridView {
            id: grid
            anchors.fill: parent
            anchors.topMargin: header.y + header.height + 16
            anchors.margins: 24
            cellWidth: 300
            cellHeight: 150
            clip: true
            model: files
            keyNavigationEnabled: true
            highlightMoveDuration: 120
            boundsBehavior: Flickable.StopAtBounds

            Keys.onReturnPressed: root.choose(files.get(currentIndex, "filePath"))
            Keys.onEnterPressed: root.choose(files.get(currentIndex, "filePath"))
            Keys.onEscapePressed: root.visible = false

            delegate: Item {
                id: cell
                required property int index
                required property string filePath
                required property string fileName
                readonly property bool current: GridView.isCurrentItem
                readonly property bool active: filePath === Theme.wallpaper

                width: grid.cellWidth
                height: grid.cellHeight

                Rectangle {
                    id: frame
                    anchors.fill: parent
                    anchors.margins: 6
                    radius: 12
                    color: Theme.surfaceHigh
                    border.width: cell.current ? 3 : cell.active ? 2 : 0
                    border.color: cell.current ? Theme.highlight : Theme.accent
                    scale: cell.current ? 1.0 : 0.96
                    Behavior on scale { NumberAnimation { duration: 120 } }

                    Image {
                        anchors.fill: parent
                        anchors.margins: frame.border.width
                        source: "file://" + cell.filePath
                        sourceSize.width: 576
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                        smooth: true
                        opacity: status === Image.Ready ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }

                    Rectangle {
                        visible: cell.active
                        anchors { top: parent.top; right: parent.right; margins: 10 }
                        width: label.implicitWidth + 16; height: 22; radius: 11
                        color: Theme.accent
                        Text {
                            id: label
                            anchors.centerIn: parent
                            text: "Current"
                            color: Theme.dark
                            font.family: Theme.font
                            font.pixelSize: 11
                            font.weight: Font.Bold
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: grid.currentIndex = cell.index
                    onClicked: root.choose(cell.filePath)
                }
            }
        }
    }
}
