# Dotfiles

Personal dotfiles for macOS and Linux.

## What's included

| Config | Path | Description |
|--------|------|-------------|
| zsh | `.zshrc` | Oh My Zsh, plugins, aliases (git, playwright, pnpm) |
| git | `.gitconfig` | User identity |
| Starship | `.config/starship/starship.toml` | Gruvbox Dark prompt theme |
| Ghostty | `.config/ghostty/config` | Terminal font settings |
| Gruvbox syntax | `oh-my-zsh-custom/themes/` | Gruvbox colors for zsh-syntax-highlighting |

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
3. Lets you pick which configs to symlink
4. Offers to install missing tools with the right commands for your platform
5. Suggests optimizations (font rendering, GPU drivers, CLI power tools, zsh performance)

Works on macOS (Homebrew), Debian/Ubuntu (apt), Arch/CachyOS/Manjaro (pacman), and Fedora (dnf).

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
- A [Nerd Font](https://www.nerdfonts.com/) (JetBrains Mono Nerd Font recommended)
- [Ghostty](https://ghostty.org/) terminal
- [Claude Code](https://claude.ai/code) (for `/setup`)
