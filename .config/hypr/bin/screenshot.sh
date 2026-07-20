#!/usr/bin/env bash
# Screenshot wrapper: save to ~/Pictures/Screenshots AND copy to clipboard.
# Usage: screenshot.sh output | region
set -e

mode="${1:-output}"
dir="$HOME/Pictures/Screenshots"
mkdir -p "$dir"
file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"

case "$mode" in
    output)
        grim "$file"
        ;;
    region)
        grim -g "$(slurp)" "$file"
        ;;
    *)
        echo "Usage: $0 output|region" >&2
        exit 1
        ;;
esac

wl-copy --type image/png < "$file"
notify-send "Screenshot saved" "$(basename "$file")"
