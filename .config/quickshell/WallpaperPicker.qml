import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: root
    readonly property string home: Quickshell.env("HOME")
    readonly property string script: home + "/.config/hypr/bin/wallpaper.sh"
    readonly property string runtime: Quickshell.env("XDG_RUNTIME_DIR") || "/tmp"

    // "set" picks a wallpaper, "convert" picks an image to gruvify; editing is that image
    property string tab: "set"
    property string editing: ""
    property string pending: ""  // file to select once the Set folder has (re)loaded

    function tilde(path) { return path.replace(home, "~"); }

    function open() {
        visible = true;
        showSet("file://" + Theme.wallpaper);
    }

    function close() {
        visible = false;
        editing = "";
    }

    function showSet(url) {
        tab = "set";
        editing = "";
        pending = url;
        Qt.callLater(selectPending);
        grid.forceActiveFocus();
    }

    function selectPending() {
        const i = setModel.indexOf(pending);
        grid.currentIndex = i >= 0 ? i : 0;
        grid.positionViewAtIndex(grid.currentIndex, GridView.Center);
        if (i >= 0) pending = "";
    }

    function showConvert() {
        tab = "convert";
        editing = "";
        grid.currentIndex = 0;
        grid.forceActiveFocus();
    }

    function pick(path) {
        if (tab === "convert") {
            editing = path;
            editor.forceActiveFocus();
        } else {
            Quickshell.execDetached([script, "set", path]);
            close();
        }
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
        function toggle(): void { root.visible ? root.close() : root.open(); }
        function close(): void { root.close(); }
        // open the gruvify editor on any image
        function edit(path: string): void {
            root.visible = true;
            root.tab = "convert";
            root.pick(path);
        }
    }

    // each tab's folder, remembered across sessions
    FileView {
        id: prefs
        path: root.home + "/.local/state/desktop/wallpaper-picker.json"
        atomicWrites: true
        onLoadFailed: writeAdapter()

        JsonAdapter {
            id: folders
            property string setDir: root.home + "/Pictures/wallpapers"
            property string convertDir: root.home + "/Downloads"
        }
    }

    // zenity can't take focus over an overlay layer, so the picker hides while it's open
    Process {
        id: chooser
        stdout: StdioCollector { id: chosen }
        onExited: code => {
            const dir = chosen.text.trim();
            if (code === 0 && dir) {
                folders[root.tab + "Dir"] = dir;
                prefs.writeAdapter();
            }
            root.visible = true;
            root.tab === "set" ? root.showSet("") : root.showConvert();
        }
    }

    function chooseFolder() {
        chooser.command = ["zenity", "--file-selection", "--directory",
            "--title=" + (tab === "set" ? "Wallpapers folder" : "Folder of images to convert"),
            "--filename=" + folders[tab + "Dir"] + "/"];
        visible = false;
        chooser.running = true;
    }

    FolderListModel {
        id: setModel
        folder: "file://" + folders.setDir
        nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp"]
        showDirs: false
        sortField: FolderListModel.Name
        onCountChanged: if (root.pending) root.selectPending()
    }

    FolderListModel {
        id: convertModel
        folder: "file://" + folders.convertDir
        nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp"]
        showDirs: false
        sortField: FolderListModel.Time
    }

    // click outside the panel to close
    MouseArea {
        anchors.fill: parent
        onClicked: root.close()
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
                text: root.editing ? "Gruvify" : "Wallpapers"
                color: Theme.fg
                font.family: Theme.font
                font.pixelSize: 20
                font.weight: Font.Bold
            }
            TextButton {
                visible: !root.editing
                anchors.verticalCenter: parent.verticalCenter
                text: "Set"
                primary: root.tab === "set"
                onClicked: root.showSet("")
            }
            TextButton {
                visible: !root.editing
                anchors.verticalCenter: parent.verticalCenter
                text: "Convert"
                primary: root.tab === "convert"
                onClicked: root.showConvert()
            }
            TextButton {
                visible: !root.editing
                anchors.verticalCenter: parent.verticalCenter
                text: root.tilde(folders[root.tab + "Dir"]) + " …"
                onClicked: root.chooseFolder()
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.editing ? root.editing.split("/").pop() + " · Esc to go back"
                    : root.tab === "set" ? `${setModel.count} wallpapers · arrows + Enter · Tab for Convert · Esc to close`
                    : `${convertModel.count} images, newest first · pick one to gruvify`
                color: Theme.muted
                font.family: Theme.font
                font.pixelSize: 13
            }
        }

        GridView {
            id: grid
            visible: !root.editing
            anchors.fill: parent
            anchors.topMargin: header.y + header.height + 16
            anchors.margins: 24
            cellWidth: 300
            cellHeight: 150
            clip: true
            model: root.tab === "set" ? setModel : convertModel
            keyNavigationEnabled: true
            highlightMoveDuration: 120
            boundsBehavior: Flickable.StopAtBounds

            Keys.onReturnPressed: root.pick(model.get(currentIndex, "filePath"))
            Keys.onEnterPressed: root.pick(model.get(currentIndex, "filePath"))
            Keys.onTabPressed: root.tab === "set" ? root.showConvert() : root.showSet("")
            Keys.onEscapePressed: root.close()

            delegate: Item {
                id: cell
                required property int index
                required property string filePath
                readonly property bool current: GridView.isCurrentItem
                readonly property bool active: root.tab === "set" && filePath === Theme.wallpaper

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
                    onClicked: root.pick(cell.filePath)
                }
            }
        }

        GruvifyEditor {
            id: editor
            visible: !!root.editing
            anchors.fill: parent
            anchors.topMargin: header.y + header.height + 16
            anchors.margins: 24
            source: root.editing
            script: root.script
            runtime: root.runtime
            outDir: folders.setDir
            onBack: root.showConvert()
            onSaved: (path, applied) => applied ? root.close() : root.showSet("file://" + path)
        }
    }
}
