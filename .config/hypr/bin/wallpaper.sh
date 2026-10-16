#!/usr/bin/env bash
# wallpaper.sh set <image> | restore | gruvify <image>... [strength%] [--set] [--keep-bg] [--keep-hues]
#   [--margin=10] [--size=WxH] [--out=path]
# Sets the wallpaper and derives the accent: the image's main colour snapped
# to the nearest Gruvbox accent, so everything stays on-palette.
# gruvify fits an image to the screen and recolours it towards Gruvbox: flat
# backgrounds go dark with the subject framed, cool hues go orange.
set -euo pipefail

STATE="${XDG_STATE_HOME:-$HOME/.local/state}/desktop"
WALLS="$HOME/Pictures/wallpapers"
DEFAULT="$WALLS/wallhaven-gruvbox.png"
SIZE=3440x1440
LUT="${XDG_CACHE_HOME:-$HOME/.cache}/desktop/gruvbox-lut.png"
TONE="$(dirname "$(realpath "$0")")/wallpaper-tone.py"
DARK="#282828"
DARKEN=1 ORANGE=1 MARGIN=10 OUT=""
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

# -P keeps the image's lightness; -L < 1 prefers colourful palette matches over greys
make_lut() {
    mkdir -p "$(dirname "$LUT")"
    lutgen generate -p gruvbox-dark -P -L 0.5 -o "$LUT" >/dev/null 2>&1
}

# Flat-background image: the subject is centred within the margins on a canvas of
# the background colour, which (unless --keep-bg) first becomes Gruvbox dark,
# including pockets of it enclosed by the subject. Anything else is scaled and
# cropped to fill the screen.
frame() {
    local img=$1 out=$2 tmp=$3 bg w h bbox sw sh bx by th
    bg=$(python3 -I "$TONE" flatbg "$img")
    if [[ -z $bg ]]; then
        magick "$img" -resize "$SIZE^" -gravity center -extent "$SIZE" "$out"
        return
    fi
    read -r w h < <(magick identify -format '%w %h' "$img")
    if (( DARKEN )); then
        python3 -I "$TONE" bgmask "$img" "$tmp/mask.png"
        magick "$img" -alpha off \( +clone -fill "$DARK" -colorize 100 \) \
            \( "$tmp/mask.png" -morphology Dilate Disk:1 -blur 0x0.8 \) -composite "$tmp/dark.png"
        bg=$DARK
    else
        magick "$img" -alpha off "$tmp/dark.png"
    fi
    bbox=$(magick "$tmp/dark.png" -bordercolor "$bg" -border 1 -fuzz 4% -format '%@' info:)
    IFS='x+' read -r sw sh bx by <<< "$bbox"
    bbox="${sw}x${sh}+$((bx - 1))+$((by - 1))"
    # the subject's height once the image fills the screen, capped by the margin
    th=$(awk -v w="$w" -v h="$h" -v sw="$sw" -v sh="$sh" -v W="${SIZE%x*}" -v H="${SIZE#*x}" -v m="$MARGIN" 'BEGIN {
        f = W / w > H / h ? W / w : H / h; t = sh * f; k = 1 - 2 * m / 100
        if (t > k * H) t = k * H
        if (t * sw / sh > (k + 0.1) * W) t = (k + 0.1) * W * sh / sw
        printf "%d", t }')
    magick -size "$SIZE" "xc:$bg" \( "$tmp/dark.png" -crop "$bbox" +repage -resize "x$th" \) \
        -gravity center -composite "$out"
}

gruvify() {
    local img=$1 strength=$2 out tmp
    [[ -f "$img" ]] || { echo "no such image: $img" >&2; exit 1; }
    [[ -f "$LUT" ]] || make_lut
    out=${OUT:-"$WALLS/$(basename "${img%.*}")_gruvbox_$strength.png"}
    tmp=$(mktemp -d)
    frame "$img" "$tmp/framed.png" "$tmp"
    magick "$tmp/framed.png" \( +clone "$LUT" -hald-clut \) -define compose:args="$strength" \
        -compose blend -composite "$tmp/toned.png"
    if (( ORANGE )); then python3 -I "$TONE" orange "$tmp/toned.png" "$out"; else cp "$tmp/toned.png" "$out"; fi
    rm -rf "$tmp"
    printf "%s" "$out"
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
    gruvify)
        strength=60 set_it=0 imgs=() out=""
        for a in "${@:2}"; do
            if [[ $a == --set ]]; then set_it=1
            elif [[ $a == --keep-bg ]]; then DARKEN=0
            elif [[ $a == --keep-hues ]]; then ORANGE=0
            elif [[ $a == --margin=* ]]; then MARGIN=${a#*=}
            elif [[ $a == --size=* ]]; then SIZE=${a#*=}
            elif [[ $a == --out=* ]]; then OUT=${a#*=}
            elif [[ $a =~ ^[0-9]+$ ]]; then strength=$a
            else imgs+=("$a"); fi
        done
        (( ${#imgs[@]} )) || { echo "usage: $0 gruvify <image>... [strength%] [--set] [--keep-bg] [--keep-hues] [--margin=N] [--size=WxH] [--out=path]" >&2; exit 2; }
        for img in "${imgs[@]}"; do out=$(gruvify "$img" "$strength"); echo "$out"; done
        if (( set_it )); then apply "$out" grow; fi ;;
    *) echo "usage: $0 set <image> | restore | gruvify <image>... [strength%] [--set] [--keep-bg] [--keep-hues]" >&2; exit 2 ;;
esac
