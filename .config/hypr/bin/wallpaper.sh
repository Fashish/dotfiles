#!/usr/bin/env bash
# wallpaper.sh set <image> | restore
# Sets the wallpaper and derives the accent: the image's main colour snapped
# to the nearest Gruvbox accent, so everything stays on-palette.
set -euo pipefail

STATE="${XDG_STATE_HOME:-$HOME/.local/state}/desktop"
DEFAULT="$HOME/Pictures/wallpapers/wallhaven-gruvbox.png"
mkdir -p "$STATE"

accent_for() {
    local src
    src=$(matugen image "$1" --dry-run -j hex -m dark --prefer saturation 2>/dev/null \
        | jq -r '.colors.source_color.default.color' 2>/dev/null) || src=""
    python3 -I - "${src:-#d65d0e}" <<'PY'
import colorsys, sys

PAIRS = {  # (dark, bright)
    "red": ("cc241d", "fb4934"),
    "orange": ("d65d0e", "fe8019"),
    "yellow": ("d79921", "fabd2f"),
    "green": ("98971a", "b8bb26"),
    "aqua": ("689d6a", "8ec07c"),
    "blue": ("458588", "83a598"),
    "purple": ("b16286", "d3869b"),
}

def hls(h):
    h = h.lstrip("#")
    return colorsys.rgb_to_hls(*(int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)))

hue, _, sat = hls(sys.argv[1])
if sat < 0.18:  # greyscale image: keep the default
    name = "orange"
else:
    def dist(n):
        d = abs(hue - hls(PAIRS[n][1])[0])
        return min(d, 1 - d)
    name = min(PAIRS, key=dist)
print(name, *PAIRS[name])
PY
}

apply() {
    local img=$1 transition=$2 name dark bright
    [[ -f "$img" ]] || { echo "no such image: $img" >&2; exit 1; }
    img=$(realpath "$img")

    awww img "$img" --transition-type "$transition" --transition-duration 1.2 --transition-fps 175
    read -r name dark bright < <(accent_for "$img")

    ln -sfn "$img" "$STATE/wallpaper"
    printf '{"wallpaper":"%s","accentName":"%s","accent":"#%s","highlight":"#%s"}\n' \
        "$img" "$name" "$dark" "$bright" > "$STATE/theme.json.tmp"
    mv "$STATE/theme.json.tmp" "$STATE/theme.json"
    printf 'return { accent = "%s", highlight = "%s" }\n' "$dark" "$bright" > "$STATE/accent.lua"

    hyprctl eval "SetAccent(\"$dark\", \"$bright\")" >/dev/null 2>&1 || true
    qs ipc call theme reload >/dev/null 2>&1 || true
}

case "${1:-}" in
    set) apply "${2:?image path}" grow ;;
    restore)
        img=$(readlink -f "$STATE/wallpaper" 2>/dev/null || true)
        [[ -f "$img" ]] || img=$DEFAULT
        apply "$img" none ;;
    *) echo "usage: $0 set <image> | restore" >&2; exit 2 ;;
esac
