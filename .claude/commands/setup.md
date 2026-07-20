---
description: Interactive dotfiles setup — detect environment, symlink configs, install tools, and offer platform optimizations
---

# /setup — Interactive Dotfiles Setup

You are helping the user set up their development environment from this dotfiles repo.
Work through each phase in order. Be conversational — report findings, ask before acting,
and never run `sudo` without explaining why first.

The dotfiles repo root is the current working directory.

---

## Phase 1: Environment Detection

Run these checks and present a summary table:

1. **OS**: `uname -s` (Darwin = macOS, Linux = Linux)
2. **Distro** (Linux only): read `ID` and `ID_LIKE` from `/etc/os-release`
3. **Package manager**: detect which is available — `brew`, `apt`, `pacman`, `dnf`, `zypper`
   - On Arch-based (Arch, CachyOS, Manjaro, EndeavourOS): also check for AUR helpers (`yay`, `paru`)
4. **Shell**: `echo $SHELL` — note if zsh is not the default
5. **Display server** (Linux only): check `$XDG_SESSION_TYPE` or `$WAYLAND_DISPLAY` for Wayland vs X11
6. **Init system** (Linux only): check for `systemctl` (systemd) vs other

Present results as a clean table before moving on.

---

## Phase 2: Tool Audit

Check each tool and present a status table (installed / missing, version where available):

| Tool | How to check |
|------|-------------|
| zsh | `command -v zsh` + whether it is `$SHELL` |
| Oh My Zsh | directory `$HOME/.oh-my-zsh` exists |
| zsh-autosuggestions | directory `${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions` |
| zsh-syntax-highlighting | directory `${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting` |
| Starship | `command -v starship` |
| fnm | `command -v fnm` |
| Ghostty | `command -v ghostty` or app bundle check on macOS |
| Nerd Fonts | search font dirs for `*FiraCode*Nerd*`: `~/.local/share/fonts`, `/usr/share/fonts` (Linux), `~/Library/Fonts` (macOS) |
| pnpm | `command -v pnpm` |
| git | `command -v git` |
| curl | `command -v curl` |

Flag any missing prerequisites (git, curl, zsh) as blockers.

---

## Phase 3: Config Selection & Symlinking

Present the available configs and let the user choose which to apply.
Use AskUserQuestion with multiSelect to let them pick.

### Available configs

| Config | Repo path | Target (macOS) | Target (Linux) |
|--------|-----------|-----------------|-----------------|
| zsh | `.zshrc` | `~/.zshrc` | `~/.zshrc` |
| Starship prompt | `.config/starship/starship.toml` | `~/.config/starship/starship.toml` | `~/.config/starship/starship.toml` |
| Ghostty | `.config/ghostty/config` | `~/Library/Application Support/com.mitchellh.ghostty/config` | `~/.config/ghostty/config` |
| Gruvbox syntax theme | `oh-my-zsh-custom/themes/gruvbox-zsh-syntax-highlighting.zsh` | `$ZSH_CUSTOM/themes/...` | `$ZSH_CUSTOM/themes/...` |
| htop | `.config/htop/htoprc` | `~/.config/htop/htoprc` | `~/.config/htop/htoprc` |
| Hyprland | `.config/hypr/` | — (Linux only) | `~/.config/hypr/` |
| Waybar | `.config/waybar/` | — (Linux only) | `~/.config/waybar/` |
| Walker | `.config/walker/` | — (Linux only) | `~/.config/walker/` |

The Linux-only desktop configs assume a Hyprland session. Don't offer them on macOS,
and on Linux check the user actually runs Hyprland before symlinking. `.config/waybar/scripts`
and `.config/walker/themes` are symlinked as whole directories — `install.sh` does this by
removing the target dir first, so mirror that behaviour rather than linking file by file.

Git identity is deliberately **not** tracked in this repo — there is no `.gitconfig`.
If the user wants git configured, set it per-machine with `git config --global`.

### Before symlinking each config:

1. Check if the target file already exists
2. If it does, show a diff between existing and repo version
3. Offer to back up the existing file (rename to `<file>.backup.<date>`)
4. Create parent directories as needed
5. Use `ln -sf` with absolute paths

### OS-specific adaptations for `.zshrc`

If the user is on Linux and chooses to symlink `.zshrc`, warn about macOS-specific lines and offer to create a platform-aware version. Specific lines to address:

- **PNPM_HOME**: `~/Library/pnpm` (macOS) vs `~/.local/share/pnpm` (Linux)
- **PNPM_HOME**: not currently exported by `.zshrc` at all, though the `p*` aliases assume `pnpm` is on `PATH` — add it if the user installs pnpm and it isn't resolving
- **`ls -G` / `subl`**: already guarded behind `if [[ "$(uname)" == "Darwin" ]]`, and `ls`/`la`/`ll` fall back to plain `ls` when `eza` is absent — no patching needed
- **VS Code shell integration**: already conditional on `code` being installed
- **fnm**: already conditional on `fnm` being installed

The `.zshrc` is platform-aware as written, so prefer extending its existing `uname` and
`command -v` guards over maintaining two files.

---

## Phase 4: Tool Installation

Based on the audit from Phase 2, present only the **missing** tools and let the user choose which to install. Skip this phase entirely if everything is already installed.

Use AskUserQuestion with multiSelect for selection.

### Install commands by platform

**Oh My Zsh:**
- All: `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended`

**zsh-autosuggestions:**
- All: `git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions`

**zsh-syntax-highlighting:**
- All: `git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting`

**Starship:**
- macOS: `brew install starship`
- Arch-based: `sudo pacman -S starship`
- Debian/Ubuntu: `curl -sS https://starship.rs/install.sh | sh`
- Fedora: `sudo dnf install starship`

**fnm:**
- macOS: `brew install fnm`
- Arch-based: `sudo pacman -S fnm`
- Debian/Ubuntu: `curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell`
- Fedora: `curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell`

**Ghostty:**
- macOS: `brew install --cask ghostty`
- Arch-based: check AUR (`yay -S ghostty` or `paru -S ghostty`), or official repos
- Other Linux: guide user to https://ghostty.org/download — may require building from source

**FiraCode Nerd Font** (Ghostty's font; the Hyprland stack also uses JetBrainsMono Nerd Font and DM Sans):
- macOS: `brew install --cask font-fira-code-nerd-font`
- Arch-based: `sudo pacman -S ttf-firacode-nerd`
- Debian/Ubuntu: download from https://github.com/ryanoasis/nerd-fonts/releases, extract to `~/.local/share/fonts/`, run `fc-cache -fv`
- Fedora: `sudo dnf install fira-code-fonts` (then Nerd Font variant from release)

**pnpm:**
- All: `curl -fsSL https://get.pnpm.io/install.sh | sh -`
- Or: `brew install pnpm` / `sudo pacman -S pnpm` / `npm install -g pnpm`

**zsh (if not default shell):**
- After installing, remind user to run `chsh -s $(which zsh)` and relog

---

## Phase 5: Optimizations & Recommendations

This phase is **advisory only** — present suggestions, explain why, and only act on explicit approval.

### Linux-specific

**Font rendering** (if on Linux):
- Check if `~/.config/fontconfig/fonts.conf` exists
- Suggest subpixel rendering and lcdfilter settings for sharper fonts
- Especially relevant on Arch/CachyOS where this isn't always configured by default

**GPU** (if on Linux):
- Check `lspci | grep -i vga` or `lspci | grep -i 3d` to identify GPU
- NVIDIA: suggest proprietary driver (`nvidia` on Arch, `nvidia-driver` on Debian)
- AMD: should work OOTB with `mesa`; suggest `vulkan-radeon` for Vulkan support
- Intel: should work OOTB; suggest `vulkan-intel` if doing GPU work

**Compositor / desktop** (if on Linux):
- If Wayland: note clipboard differences (`wl-copy`/`wl-paste` vs `xclip`)
- If Hyprland/Sway: suggest `wl-clipboard` package
- If X11: suggest `picom` for compositing if not present

**AUR helper** (if Arch-based and no AUR helper found):
- Suggest installing `paru` (Rust-based, actively maintained) or `yay`

### All platforms

**CLI power tools** — suggest these modern replacements if not installed:
| Tool | Replaces | Purpose |
|------|----------|---------|
| `bat` | `cat` | Syntax-highlighted file viewing |
| `eza` | `ls` | Modern ls with git integration |
| `fd` | `find` | Faster, friendlier find |
| `ripgrep` (`rg`) | `grep` | Faster grep |
| `fzf` | — | Fuzzy finder for everything |
| `delta` | — | Better git diffs |
| `lazygit` | — | Terminal UI for git |
| `jq` | — | JSON processing |
| `htop` / `btop` | `top` | Better process viewer |
| `tldr` | `man` | Simplified man pages |
| `zoxide` | `cd` | Smarter directory jumping (the `z` oh-my-zsh plugin has been removed from `.zshrc`) |
| `tmux` or `zellij` | — | Terminal multiplexer |

Present these grouped by category. Use the correct package names for the detected package manager (e.g., `fd-find` on Debian vs `fd` on Arch/Homebrew).

**Zsh performance** (offer to benchmark):
- Run `time zsh -i -c exit` to measure startup time
- If > 200ms, suggest lazy-loading strategies or `zsh-defer`
- Suggest `compinit` caching if not already done

### macOS-specific

**Homebrew** (if not installed): guide through install
**macOS defaults**: offer to apply common developer-friendly defaults:
- Fast key repeat: `defaults write NSGlobalDomain KeyRepeat -int 2`
- Show hidden files: `defaults write com.apple.finder AppleShowAllFiles -bool true`
- Disable press-and-hold for keys: `defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false`

---

## Phase 6: Summary

Print a clean summary:
- Configs symlinked (with paths)
- Tools installed
- Suggestions the user declined (for future reference)
- Any manual steps needed (like `chsh`, restarting shell, logging out)

End with: "Run `source ~/.zshrc` or restart your shell to apply changes."

---

## Ground Rules

- **Never overwrite without asking.** Always show what will change first.
- **Never run `sudo` silently.** Explain what needs elevated permissions and why.
- **Idempotent.** The user may run `/setup` again — always re-detect, never assume prior state.
- **One thing at a time.** Don't batch 10 installs silently. Run each, confirm success, move on.
- **If something fails, diagnose it.** Read the error, check the cause, suggest a fix — don't just skip.
- **Respect refusals.** If the user says no to something, move on without arguing.
