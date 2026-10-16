//@ pragma IconTheme Colloid-Orange-Gruvbox-Dark
import QtQuick
import Quickshell

ShellRoot {
    // false hides the Quickshell bar; re-enable waybar in hyprland.lua to go back
    readonly property bool showBar: true

    Variants {
        model: showBar ? Quickshell.screens : []
        Bar {}
    }

    WallpaperPicker {}
}
