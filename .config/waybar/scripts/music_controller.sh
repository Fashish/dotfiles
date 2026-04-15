#!/usr/bin/env bash

set -euo pipefail

pick_player() {
  # 1) If Spotify exists and is Playing/Paused, use it
  if playerctl -l 2>/dev/null | grep -qx "spotify"; then
    local s
    s="$(playerctl --player=spotify status 2>/dev/null || true)"
    if [[ "$s" == "Playing" || "$s" == "Paused" ]]; then
      echo "spotify"
      return 0
    fi
  fi

  # 2) Otherwise, pick the first player that is Playing
  while read -r p; do
    [[ -z "$p" ]] && continue
    local s
    s="$(playerctl --player="$p" status 2>/dev/null || true)"
    [[ "$s" == "Playing" ]] && { echo "$p"; return 0; }
  done < <(playerctl -l 2>/dev/null)

  # 3) Otherwise, pick the first player that is Paused
  while read -r p; do
    [[ -z "$p" ]] && continue
    local s
    s="$(playerctl --player="$p" status 2>/dev/null || true)"
    [[ "$s" == "Paused" ]] && { echo "$p"; return 0; }
  done < <(playerctl -l 2>/dev/null)

  return 1
}

player="$(pick_player || true)"
status="$(playerctl --player="$player" status 2>/dev/null || true)"

if [[ "$status" != "Playing" && "$status" != "Paused" ]]; then
  jq -cn '{text:"", tooltip:"", class:""}'
  exit 0
fi

icon_play=""
icon_pause=""
icon_prev=""
icon_next=""

if [[ "$status" == "Playing" ]]; then
  playpause="$icon_pause"
else
  playpause="$icon_play"
fi

title="$(playerctl --player="$player" metadata title 2>/dev/null || true)"
artist="$(playerctl --player="$player" metadata artist 2>/dev/null || true)"

tooltip="${title}  •  ${artist}"

jq -cn \
  --arg text "$icon_prev  $playpause  $icon_next" \
  --arg tooltip "$tooltip" \
  --arg class "$status" \
  '{text:$text, tooltip:$tooltip, class:$class}'
