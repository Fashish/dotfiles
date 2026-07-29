#!/usr/bin/env bash
set -euo pipefail

MONITOR="DP-2"

# U+F111 (nf-fa-circle), same glyph as the workspace dots. Written as hex escapes
# rather than a literal so it survives editing.
DOT=$(printf '\xef\x84\x91')

# Hyprland reports `cm` as null, so sdrBrightness is the proxy: hyprland.lua's
# HDR profile sets it to 1.1 and SDR to 1.0.
state=$(hyprctl monitors -j 2>/dev/null \
  | jq -r --arg m "$MONITOR" \
      'first(.[] | select(.name == $m) | if .sdrBrightness > 1.05 then "on" else "off" end) // "off"' \
  2>/dev/null || echo off)

if [[ "$state" == "on" ]]; then
  printf '{"text":"%s","class":"on","tooltip":"HDR on"}\n' "$DOT"
else
  printf '{"text":"%s","class":"off","tooltip":"HDR off"}\n' "$DOT"
fi
