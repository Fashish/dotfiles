# Dotfiles — Claude Code Context

Personal dotfiles repo for macOS and Linux. Gruvbox Dark themed throughout.

## Repo structure

```
.zshrc                          → ~/.zshrc
.config/starship/starship.toml  → ~/.config/starship/starship.toml
.config/ghostty/config          → macOS: ~/Library/Application Support/com.mitchellh.ghostty/config
                                  Linux: ~/.config/ghostty/config
.config/hypr/                   → ~/.config/hypr/          (Linux only)
  hyprland.lua, conf/keybinds.lua — the Hyprland config (Lua, 0.55+)
  hypridle.conf, hyprlock.conf   — still hyprlang; only Hyprland moved to Lua
  bin/                          — songdetail, session-menu, screenshot
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

The legacy `hyprland.conf` / `conf/keybinds.conf` pair has been deleted — 0.57
drops support for the format, so there was no future in keeping it. It is still
in git history if it is ever needed: `git show <commit>^:.config/hypr/hyprland.conf`.

**`hyprctl` no longer speaks hyprlang.** This is the migration's sharpest edge,
because it breaks *external* tools rather than the config, and both forms fail
quietly enough to miss:

```
$ hyprctl dispatch dpms off
error: [string "return hl.dispatch(dpms off)"]:1: ')' expected near 'on'
$ echo $?
7
$ hyprctl dispatch 'hl.dsp.dpms({ action = "off" })'
ok

$ hyprctl keyword monitor "DP-2, 3440x1440@175, auto, 1.0, bitdepth, 10"
keyword can't work with non-legacy parsers. Use eval.
$ echo $?
0                          # <- exits 0 on failure, so callers cannot detect it
$ hyprctl eval 'hl.monitor({ output = "DP-2", mode = "3440x1440@175", position = "auto", scale = 1.0, bitdepth = 10 })'
ok
```

So: `dispatch` takes a Lua expression, and `keyword` is replaced by `eval`.
Anything shelling out with the old syntax now no-ops — `dispatch` at least
returns exit 7, but `keyword` returns **0**, so a script cannot tell it failed.

Already hit:
- `hypridle.conf` — all three DPMS call sites. Fixed.
- `bin/hdr-toggle.sh` — both `hyprctl keyword monitor` calls were dead, so
  SUPER+SHIFT+H did nothing. The script has since been deleted outright: the
  toggle now lives in `hyprland.lua` as a bind closing over a Lua flag, so it
  calls `hl.monitor` in-process and cannot hit this class of bug at all.
- waybar's `hyprland/workspaces` click handler — upstream, fixed by Waybar
  PR #5013 but not in the installed 0.15.0. No action; waiting for the release.

Check any new script that shells out to `hyprctl` against this before trusting
it. Config-level validation cannot catch this class of bug: `--verify-config`
and nested-instance testing only exercise config parsing.

Editing tips:
- Type stubs live at `/usr/share/hypr/stubs/hl.meta.lua` (~1770 lines). Point
  `lua_ls` at them for autocomplete and typo-checking on every option name.
- The shipped reference config is `/usr/share/hypr/hyprland.lua`.
- Regex in match tables should use long-bracket strings (`[[^steam_app_\d+$]]`)
  — in a normal Lua string `\d` is an invalid escape and errors.
- `movetoworkspacesilent` is `hl.dsp.window.move({ workspace = n, follow = false })`;
  there is no `silent` flag on the dispatcher (only on window *rules*, as `"3 silent"`).
- Syntax-check with `luac -p hyprland.lua conf/keybinds.lua` before restarting.

### waybar persistent workspaces

`persistent-workspaces` must list workspaces explicitly (`{"1": [], "2": [], ...}`,
empty array = all outputs). The count form `{"*": 5}` does **not** mean workspaces
1-5 — waybar derives each ID as `monitorId * 5 + i`, so on a machine whose only
monitor has ID 1 it pins 6-10 instead, and the bar shows those *plus* whatever real
workspaces exist. Symptom is too many icons and a count that changes as you switch.
Monitor IDs are not stable across hotplugs, so the `"*"` form is wrong even when it
happens to look right.

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

Related: Hyprland sets no XDG base dirs by default. `hyprland.lua` now sets
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
