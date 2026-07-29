-- Autocomplete: point lua_ls at /usr/share/hypr/stubs/hl.meta.lua
---@module 'hl'

-- ----------
-- Monitor + HDR toggle
-- ----------

local monitor = "DP-2"
local mode    = "3440x1440@175"

-- Boots SDR; SUPER+SHIFT+H flips it. Hyprland reads `cm` back as null, so this
-- flag is the source of truth. It resets to SDR on a config reload.
local hdrEnabled = false

local function applyMonitor()
    hl.monitor({
        output   = monitor,
        mode     = mode,
        position = "auto",
        scale    = 1.0,
        bitdepth = 10,
        -- Explicit, not nil: at runtime an omitted key means "leave unchanged".
        cm            = hdrEnabled and "hdr" or "srgb",
        sdrbrightness = hdrEnabled and 1.1 or 1.0,
        sdrsaturation = hdrEnabled and 1.1 or 1.0,
    })
end

applyMonitor()

hl.bind("SUPER + SHIFT + H", function()
    hdrEnabled = not hdrEnabled
    applyMonitor()
    -- Delayed so the toast lands after the mode switch settles, as the old
    -- script's `sleep 3` did — the display blanks during renegotiation.
    hl.timer(function()
        hl.notification.create({
            text    = hdrEnabled and "HDR enabled" or "HDR disabled",
            timeout = 4000,
        })
    end, { timeout = 3000, type = "oneshot" })
end)

-- ----------
-- Environment variables
-- ----------

-- Wayland app compatibility
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_STYLE_OVERRIDE", "kvantum")
hl.env("GDK_BACKEND", "wayland,x11")

-- XDG base directories — unset by default in a bare Hyprland session.
-- Most apps assume the spec fallbacks anyway, but KDE/KIO does not, which is
-- what left ksycoca indexing zero applications and broke file associations.
-- Deliberately NOT setting XDG_MENU_PREFIX: KDE would then look for
-- "<prefix>applications.menu" and miss ~/.config/menus/applications.menu.
hl.env("XDG_DATA_HOME", "/home/fador/.local/share")
hl.env("XDG_CONFIG_HOME", "/home/fador/.config")
hl.env("XDG_DATA_DIRS", "/usr/local/share:/usr/share")
hl.env("XDG_CONFIG_DIRS", "/etc/xdg")

-- Cursor — Bibata Gruvbox (XCursor + Hyprcursor native)
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic-Gruvbox")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic-Gruvbox")
hl.env("HYPRCURSOR_SIZE", "24")

-- ----------
-- Autostart
-- ----------

-- hl.exec_cmd spawns async; no trailing "&" needed.
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("sleep 1 && awww img ~/Pictures/Wallpapers/wallhaven-gruvbox.png")
    hl.exec_cmd("elephant")
    hl.exec_cmd("walker --gapplication-service")
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Classic-Gruvbox 24")
    hl.exec_cmd("wl-paste --type text  --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("udiskie --no-automount --smart-tray")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("easyeffects --gapplication-service")
end)

-- ----------
-- Window rules
-- ----------

-- Everything on workspace 3 floats. SUPER+SHIFT+T toggles it.
local floatOnWorkspace3 = hl.window_rule({
    name  = "float-on-workspace-3",
    match = { workspace = "3" },
    float = true,
})

local ws3Floating = true
hl.bind("SUPER + SHIFT + T", function()
    ws3Floating = not ws3Floating
    floatOnWorkspace3:set_enabled(ws3Floating)
    -- The rule alone only applies at window-open, so bring existing ones along.
    for _, w in ipairs(hl.get_windows({ workspace = 3 })) do
        hl.dispatch(hl.dsp.window.float({ action = ws3Floating and "set" or "unset", window = w }))
    end
    hl.notification.create({
        text    = ws3Floating and "Workspace 3: floating" or "Workspace 3: tiling",
        timeout = 2000,
    })
end)

-- Steam — covered by the all-floating rule above, so no float rule of its own
hl.window_rule({
    name      = "steam-to-workspace-3",
    match     = { class = "^(steam)$" },
    workspace = "3 silent",
})
hl.workspace_rule({ workspace = "3", layout = "floating" })

-- Steam games
hl.window_rule({
    name       = "steam-games",
    match      = { class = [[^steam_app_\d+$]] },
    fullscreen = true,
    workspace  = "10",
    immediate  = true,
})
hl.workspace_rule({ workspace = "10", no_border = true, no_rounding = true })

-- hl.window_rule({ name = "steam-games-monitor", match = { class = [[^steam_app_\d+$]] }, monitor = monitor })

-- ----------
-- Look and feel
-- ----------

hl.config({
    input = {
        kb_layout = "gb",

        follow_mouse  = 1,
        mouse_refocus = false,
        sensitivity   = -0.25,
        accel_profile = "flat",

        touchpad = {
            natural_scroll = false,
        },
    },

    cursor = {
        no_hardware_cursors = true,
        enable_hyprcursor   = true,
    },

    general = {
        gaps_in     = 5,
        gaps_out    = 10,
        border_size = 2,

        col = {
            active_border   = { colors = { "rgba(d65d0e80)", "rgba(fe801980)" }, angle = 45 },
            inactive_border = "rgba(3c383680)",
        },

        layout = "dwindle",
    },

    decoration = {
        rounding         = 10,
        active_opacity   = 1.0,
        inactive_opacity = 0.98,

        blur = {
            enabled           = true,
            size              = 8,
            xray              = true,
            new_optimizations = true,
            brightness        = 0.8,
            contrast          = 0.9,
            noise             = 0.01,
            passes            = 2,
            ignore_opacity    = false,
        },

        shadow = {
            enabled      = true,
            range        = 20,
            offset       = { 5, 5 },
            render_power = 3,
            scale        = 0.97,
            color        = "rgba(00000080)",
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        vrr                     = 0,     -- disabled: caused screen jittering on AW3423DW
        mouse_move_enables_dpms = true,  -- wake screen on mouse movement
        key_press_enables_dpms  = true,  -- wake screen on keypress
        focus_on_activate       = false, -- prevent apps stealing focus
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,
    },

    render = {
        direct_scanout = true, -- fullscreen apps bypass compositor
    },
})

-- ----------
-- Performance mode
-- ----------

-- Runtime hl.config overrides only the keys named here; the rest is untouched.
local effectsOn = true
hl.bind("SUPER + SHIFT + G", function()
    effectsOn = not effectsOn
    hl.config({
        decoration = {
            blur   = { enabled = effectsOn },
            shadow = { enabled = effectsOn },
        },
        animations = { enabled = effectsOn },
    })
    hl.notification.create({
        text    = effectsOn and "Effects on" or "Performance mode",
        timeout = 2000,
    })
end)

-- ----------
-- Animations
-- ----------

hl.curve("myCurve", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })

hl.animation({ leaf = "windows",    enabled = true, speed = 7,  bezier = "myCurve" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7,  bezier = "myCurve" })
hl.animation({ leaf = "border",     enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "fade",       enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6,  bezier = "default" })

-- ----------
-- Keybinds
-- ----------

require("conf/keybinds")
