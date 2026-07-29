# Dotfiles — Claude Code Context

Personal dotfiles repo for macOS and Linux. Gruvbox Dark themed throughout.

## Repo structure

```
.zshrc                          → ~/.zshrc
.config/starship/starship.toml  → ~/.config/starship/starship.toml
.config/ghostty/config          → macOS: ~/Library/Application Support/com.mitchellh.ghostty/config
                                  Linux: ~/.config/ghostty/config
.config/hypr/                   → ~/.config/hypr/          (Linux only)
  hyprland.lua, conf/keybinds.lua — live config (Lua, Hyprland 0.55+)
  hyprland.conf, conf/keybinds.conf — legacy hyprlang, kept as rollback only
  hypridle.conf, hyprlock.conf   — still hyprlang; only Hyprland moved to Lua
  bin/                          — songdetail, session-menu, hdr-toggle, screenshot
.config/menus/applications.menu → ~/.config/menus/          (Linux only)
.config/waybar/                 → ~/.config/waybar/        (Linux only; scripts/ is a dir symlink)
.config/walker/                 → ~/.config/walker/        (Linux only; themes/ is a dir symlink)
.config/htop/htoprc             → ~/.config/htop/htoprc
oh-my-zsh-custom/themes/        → ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/
install.sh                      — Non-interactive fallback installer (CI, Docker, quick setup)
```

Note: `.gitconfig` is **not** tracked here — git identity is set per-machine via
`git config --global`. The `/setup` command still offers it; treat that as optional.

## Tools managed

- **Shell:** zsh + Oh My Zsh
- **Plugins:** zsh-autosuggestions (git clone), zsh-syntax-highlighting (git clone)
- **Prompt:** Starship with Gruvbox Dark palette
- **Terminal:** Ghostty (FiraCode Nerd Font, size 11)
- **Node:** fnm (Fast Node Manager)
- **Packages:** pnpm
- **`ls`:** eza where installed, plain `ls` as fallback

### Linux desktop (Hyprland stack)

- **Compositor:** Hyprland — see the version note below
- **Bar:** waybar, with swaync for notifications and swayosd for volume/brightness OSD
- **Launcher / session menu:** walker (+ elephant backend), Gruvbox theme
- **Wallpaper:** awww (`awww-daemon`), replacing the older swww/waypaper pair
- **Cursor:** Bibata Modern Classic Gruvbox, via hyprcursor
- **Misc:** cliphist, udiskie, easyeffects, polkit-gnome agent

### Hyprland config format: Lua

Since 0.55 hyprlang is deprecated in favour of Lua. Hyprland 0.56.1 prints a
startup banner naming the removal version explicitly: "You are using the .conf
config format, support for which will be removed in Hyprland 0.57." The banner
only appears for `.conf`, so a working `hyprland.lua` silences it.

The live config is `hyprland.lua`,
which `require("conf/keybinds")` pulls the binds from — `require` paths are
relative to `hyprland.lua` and each one gets its own error scope, so a mistake in
the binds file does not take the rest of the config down.

Hyprland only reads `hyprland.conf` when no `hyprland.lua` exists, so deleting
`~/.config/hypr/hyprland.lua` rolls the whole thing back.

Editing tips:
- Type stubs live at `/usr/share/hypr/stubs/hl.meta.lua` (~1770 lines). Point
  `lua_ls` at them for autocomplete and typo-checking on every option name.
- The shipped reference config is `/usr/share/hypr/hyprland.lua`.
- Regex in match tables should use long-bracket strings (`[[^steam_app_\d+$]]`)
  — in a normal Lua string `\d` is an invalid escape and errors.
- `movetoworkspacesilent` is `hl.dsp.window.move({ workspace = n, follow = false })`;
  there is no `silent` flag on the dispatcher (only on window *rules*, as `"3 silent"`).
- Syntax-check with `luac -p hyprland.lua conf/keybinds.lua` before restarting.

### Hyprland version sensitivity

Hyprland is a rolling target and removes config keys without a deprecation window.
When a `Config error in file ...` banner appears after an update, check the changelog
before assuming the config is wrong. Already hit: `shadow:color` must use hex
`rgba(RRGGBBAA)` (the `rgba(r, g, b, a)` float form fails the gradient parser as of
0.56), and `ignore_window`, `pseudotile`, and `misc:vfr` were removed outright.

### KDE apps under a bare Hyprland session

KDE apps (Dolphin, Ark, Haruna) don't read `mimeapps.list` directly — they resolve
apps through `ksycoca`, and `kbuildsycoca6` enumerates applications by walking the
XDG **menu** definition. A bare Hyprland session has no `/etc/xdg/menus/` at all
(that file ships with Plasma, and no KDE app depends on it), so ksycoca indexes zero
applications and every file association silently fails — the symptom is an "Open With"
dialog with a completely empty application list. Fixed by the tracked
`.config/menus/applications.menu`.

Related: Hyprland sets no XDG base dirs by default. `hyprland.conf` now sets
`XDG_DATA_HOME`, `XDG_CONFIG_HOME`, `XDG_DATA_DIRS`, `XDG_CONFIG_DIRS` explicitly
(same values as the spec fallbacks, just no longer implicit). Do **not** set
`XDG_MENU_PREFIX` — KDE would then look for `<prefix>applications.menu` and miss the
file above. Note `env =` lines only apply at Hyprland startup, not on `hyprctl reload`.

## OS differences to be aware of

| Concern | macOS | Linux |
|---------|-------|-------|
| Ghostty config path | `~/Library/Application Support/com.mitchellh.ghostty/` | `~/.config/ghostty/` |
| PNPM_HOME | `~/Library/pnpm` | `~/.local/share/pnpm` |
| `ls` color flag | `-G` | `--color=auto` |
| Sublime Text alias | `/Applications/Sublime Text.app/...` | remove or adapt |
| VS Code integration | works via `code --locate-shell-integration-path zsh` | same, if VS Code installed |
| Package manager | `brew` | `apt` / `pacman` / `dnf` |
| Font install | `brew install --cask font-jetbrains-mono-nerd-font` | distro-specific or manual |

## Custom command

- `/setup` — Interactive setup wizard. Detects OS/distro, audits installed tools, lets user pick configs and tools, offers platform-specific optimizations.

## Conventions

- Symlink configs rather than copying (single source of truth)
- Back up existing files before overwriting (`<file>.backup.<date>`)
- Prefer platform conditionals in one file over maintaining separate OS-specific copies
