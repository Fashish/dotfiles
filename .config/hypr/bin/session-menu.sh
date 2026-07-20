#!/usr/bin/env bash
choice=$(printf 'Lock\nLogout\nSuspend\nReboot\nShutdown\n' | walker --dmenu)
case "$choice" in
  Lock)     exec hyprlock ;;
  Logout)   exec loginctl terminate-session "$XDG_SESSION_ID" ;;
  Suspend)  exec systemctl suspend ;;
  Reboot)   exec systemctl reboot ;;
  Shutdown) exec systemctl poweroff ;;
esac
