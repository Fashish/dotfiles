import QtQuick
import Quickshell.Io

// Before/after preview of `wallpaper.sh gruvify` with its options. Previews render
// a small copy of the image; Save renders full size into outDir.
FocusScope {
    id: root
    required property string source
    required property string script
    required property string runtime
    required property string outDir
    signal back()
    signal saved(string path, bool applied)

    property int strength: 60
    property int margin: 10
    property bool darken: true
    property bool orange: true

    readonly property string small: runtime + "/gruvify-src.png"
    readonly property string previewSize: "1146x480"
    property int frame: 0
    property string preview: ""
    property bool dirty: false
    property string status: ""

    function options() {
        const o = [String(strength), "--margin=" + margin];
        if (!darken) o.push("--keep-bg");
        if (!orange) o.push("--keep-hues");
        return o;
    }

    function render() {
        if (renderer.running || prep.running) { dirty = true; return; }
        dirty = false;
        renderer.target = `${runtime}/gruvify-preview-${frame % 2}.png`;
        renderer.command = [script, "gruvify", small, ...options(), "--size=" + previewSize, "--out=" + renderer.target];
        renderer.running = true;
        status = "Rendering preview…";
    }

    function save(apply) {
        if (saver.running) return;
        saver.applied = apply;
        const name = source.split("/").pop().replace(/\.[^.]+$/, "");
        saver.command = [script, "gruvify", source, ...options(), `--out=${outDir}/${name}_gruvbox_${strength}.png`,
            ...(apply ? ["--set"] : [])];
        saver.running = true;
        status = "Saving full size…";
    }

    onSourceChanged: if (source) {
        preview = "";
        prep.command = ["magick", source, "-resize", previewSize + "^", small];
        prep.running = true;
        status = "Preparing…";
    }

    Keys.onEscapePressed: back()

    Timer {
        id: debounce
        interval: 150
        onTriggered: root.render()
    }

    Process {
        id: prep
        onExited: root.render()
    }

    Process {
        id: renderer
        property string target
        onExited: code => {
            if (code === 0) {
                root.preview = "file://" + target;
                root.frame++;
                root.status = "";
            } else root.status = "Preview failed";
            if (root.dirty) root.render();
        }
    }

    Process {
        id: saver
        property bool applied
        stdout: StdioCollector { id: savedPath }
        onExited: code => {
            root.status = code === 0 ? "" : "Save failed";
            if (code === 0) root.saved(savedPath.text.split("\n")[0], applied);
        }
    }

    Column {
        anchors.fill: parent
        spacing: 16

        Row {
            id: previews
            width: parent.width
            spacing: 16
            readonly property real cardWidth: (width - spacing) / 2

            Repeater {
                model: [
                    { title: "Original", url: root.source ? "file://" + root.source : "" },
                    { title: "Gruvified", url: root.preview }
                ]
                delegate: Column {
                    required property var modelData
                    spacing: 6

                    Label { text: modelData.title; font.pixelSize: 13; color: Theme.muted }
                    Rectangle {
                        width: previews.cardWidth
                        height: width * 1440 / 3440
                        radius: 12
                        color: Theme.surfaceHigh
                        border.width: 1
                        border.color: Theme.surfaceHigh
                        clip: true

                        Image {
                            anchors.fill: parent
                            anchors.margins: 1
                            source: modelData.url
                            sourceSize.width: 1146
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                            cache: false
                            smooth: true
                        }
                    }
                }
            }
        }

        Row {
            width: parent.width
            spacing: 32

            ValueSlider {
                width: 260
                label: "Gruvbox strength"
                value: root.strength
                onMoved: v => { root.strength = v; debounce.restart(); }
            }
            ValueSlider {
                width: 260
                label: "Top/bottom margin"
                to: 30
                step: 1
                value: root.margin
                onMoved: v => { root.margin = v; debounce.restart(); }
            }
            Column {
                spacing: 6
                Label { text: "Steps"; font.pixelSize: 13 }
                Row {
                    spacing: 8
                    TextButton {
                        text: "Dark background"
                        primary: root.darken
                        onClicked: { root.darken = !root.darken; root.render(); }
                    }
                    TextButton {
                        text: "Orange"
                        primary: root.orange
                        onClicked: { root.orange = !root.orange; root.render(); }
                    }
                }
            }
        }

        Row {
            width: parent.width
            spacing: 8

            TextButton { id: backButton; text: "Back"; onClicked: root.back() }
            Label {
                width: parent.width - 3 * parent.spacing - backButton.width - saveButton.width - setButton.width
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignRight
                text: root.status
                color: Theme.muted
                font.pixelSize: 13
            }
            TextButton { id: saveButton; text: "Save"; onClicked: root.save(false) }
            TextButton { id: setButton; text: "Save & set"; primary: true; onClicked: root.save(true) }
        }
    }
}
