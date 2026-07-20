#!/usr/bin/env bash
# Toggle HDR on the AW3423DW (DP-2).
# Hyprland's hyprctl doesn't expose runtime HDR state reliably (`cm` is null),
# so we track it in a state file. Boot starts HDR-on per hyprland.conf, so
# absent state file → assume "on" and toggle off.

STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/hdr-state"
MONITOR="DP-2"
RES="3440x1440@175"

if [[ "$(cat "$STATE_FILE" 2>/dev/null)" == "off" ]]; then
    hyprctl keyword monitor "$MONITOR, $RES, auto, 1.0, bitdepth, 10, cm, hdr, sdrbrightness, 1.1, sdrsaturation, 1.1"
    echo on > "$STATE_FILE"
    sleep 3
    notify-send "HDR Enabled"
else
    hyprctl keyword monitor "$MONITOR, $RES, auto, 1.0, bitdepth, 10"
    echo off > "$STATE_FILE"
    sleep 3
    notify-send "HDR Disabled"
fi

# !  notify-send "$(date +%T)" "wayle popup test"