#!/usr/bin/env bash
# Toggle HDR on the AW3423DW (DP-2).
# Hyprland's hyprctl doesn't expose runtime HDR state reliably (`cm` is null),
# so we track it in a state file. hyprland.lua boots the monitor in SDR, and the
# state file lives in XDG_RUNTIME_DIR so it is cleared on logout — an absent file
# therefore means "off", and the first press after boot enables HDR.
#
# Under a Lua config `hyprctl keyword` is rejected outright ("keyword can't work
# with non-legacy parsers. Use eval.") — and it still exits 0, so the failure is
# invisible unless the output is checked. Hence `hyprctl eval` plus the check below.

STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/hdr-state"
MONITOR="DP-2"
RES="3440x1440@175"

apply_monitor() {
    local out
    out=$(hyprctl eval "hl.monitor({ output = \"$MONITOR\", mode = \"$RES\", position = \"auto\", scale = 1.0, $1 })" 2>&1)
    if [[ "$out" != "ok" ]]; then
        notify-send -u critical "HDR toggle failed" "$out"
        exit 1
    fi
}

if [[ "$(cat "$STATE_FILE" 2>/dev/null || echo off)" != "on" ]]; then
    apply_monitor 'bitdepth = 10, cm = "hdr", sdrbrightness = 1.1, sdrsaturation = 1.1'
    echo on > "$STATE_FILE"
    sleep 3
    notify-send "HDR Enabled"
else
    apply_monitor 'bitdepth = 10'
    echo off > "$STATE_FILE"
    sleep 3
    notify-send "HDR Disabled"
fi

# !  notify-send "$(date +%T)" "wayle popup test"