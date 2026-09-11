#!/usr/bin/env bash
# hypridle condition_cmd hook: exit 0 lets the on-timeout run, non-zero blocks it.
# Keeps the lock/dpms/suspend listeners from firing while a game window is open.

if hyprctl clients | grep -qE 'class: (steam_app_|gamescope)'; then
    exit 1
fi
exit 0
