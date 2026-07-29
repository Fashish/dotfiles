-- Keybinds. See https://wiki.hypr.land/Configuring/Basics/Binds/
-- Required from hyprland.lua. require() gives this file its own error scope,
-- so a mistake here won't take the rest of the config down with it.
---@module 'hl'

-- Programs
local browser     = "zen-browser"
local terminal    = "ghostty"
local filemanager = "dolphin"
local menu        = "walker"

local ss = "SUPER + SHIFT"

-- ----------
-- Keybindings
-- ----------

hl.bind("SUPER + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + Q",      hl.dsp.window.close())
hl.bind("SUPER + space",  hl.dsp.exec_cmd(menu))
hl.bind("SUPER + F",      hl.dsp.window.fullscreen())
hl.bind("SUPER + B",      hl.dsp.exec_cmd(browser))
hl.bind("SUPER + V",      hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + E",      hl.dsp.exec_cmd(filemanager))
hl.bind("SUPER + Y",      hl.dsp.exec_cmd("ghostty -e yazi"))
hl.bind("SUPER + X",      hl.dsp.exec_cmd("~/.config/hypr/bin/session-menu.sh"))
hl.bind("SUPER + ESCAPE", hl.dsp.exec_cmd('loginctl terminate-session "$XDG_SESSION_ID"'))
hl.bind("SUPER + S",      hl.dsp.exec_cmd("steam"))
hl.bind("SUPER + L",      hl.dsp.exec_cmd("hyprlock"))

-- Move focus
hl.bind("SUPER + left",  hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + up",    hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + down",  hl.dsp.focus({ direction = "down" }))

-- Switch to workspace 1-10, and move the focused window to a workspace.
-- SUPER + 0 maps to workspace 10. follow = false is the old
-- "movetoworkspacesilent" — the window moves but the focus does not follow.
for i = 1, 10 do
    local key = i % 10
    hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(ss .. " + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
end

-- Scroll through existing workspaces with SUPER + scroll
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with SUPER + LMB/RMB and dragging
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Screenshots — saves to ~/Pictures/Screenshots/ AND copies to clipboard
-- SUPER+SHIFT+W: full monitor
-- SUPER+SHIFT+S: region
hl.bind(ss .. " + W", hl.dsp.exec_cmd("~/.config/hypr/bin/screenshot.sh output"))
hl.bind(ss .. " + S", hl.dsp.exec_cmd("~/.config/hypr/bin/screenshot.sh region"))

-- HDR toggle
hl.bind(ss .. " + H", hl.dsp.exec_cmd("~/.config/hypr/bin/hdr-toggle.sh"))

-- Volume up / down / mute
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%"))
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"))

-- Media keys — Super-prefixed (avoids F7/F8/F9 conflicts with apps)
-- Signal 15 refreshes waybar's custom/musiccontroller widget
hl.bind("SUPER + F7", hl.dsp.exec_cmd("playerctl -a previous ; pkill -RTMIN+15 waybar"))
hl.bind("SUPER + F8", hl.dsp.exec_cmd("playerctl -a play-pause ; pkill -RTMIN+15 waybar"))
hl.bind("SUPER + F9", hl.dsp.exec_cmd("playerctl -a next ; pkill -RTMIN+15 waybar"))
