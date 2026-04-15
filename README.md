# Dotfiles

Personal dotfiles for macOS and Linux. Gruvbox Dark themed throughout.

## What's included

| Config | Path |
|--------|------|
| zsh | `.zshrc` |
| Starship | `.config/starship/starship.toml` |
| Ghostty | `.config/ghostty/config` |
| Hyprland | `.config/hypr/` |
| Waybar | `.config/waybar/` |
| Wofi | `.config/wofi/` |
| Wlogout | `.config/wlogout/` |
| Waypaper | `.config/waypaper/` |
| htop | `.config/htop/` |
| Gruvbox zsh theme | `oh-my-zsh-custom/themes/` |

## Setup with Claude Code (recommended)

```bash
git clone git@github.com:Fashish/dotfiles.git ~/dotfiles
cd ~/dotfiles
claude
# then run: /setup
```

The `/setup` command walks you through an interactive setup:
1. Detects your OS, distro, and package manager
2. Audits which tools are already installed
3. Symlinks configs to their correct locations
4. Installs missing tools with the right commands for your platform

Works on macOS (Homebrew), Debian/Ubuntu (apt), Arch (pacman), and Fedora (dnf).

## Quick install (non-interactive)

For CI, Docker, or when Claude Code isn't available:

```bash
git clone git@github.com:Fashish/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

## Prerequisites

- `git` and `curl`
- A [Nerd Font](https://www.nerdfonts.com/) (FiraCode Nerd Font recommended)
- [Ghostty](https://ghostty.org/) terminal
- [Claude Code](https://claude.ai/code) (for `/setup`)
