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

## Install

```bash
git clone git@github.com:Fashish/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

The install script will:
- Symlink all config files to the right locations (handles macOS vs Linux paths)
- Install Oh My Zsh (if missing)
- Clone zsh-autosuggestions and zsh-syntax-highlighting plugins
- Install Starship prompt (if missing)
- Install fnm - Fast Node Manager (if missing)

## Prerequisites

- `git` and `curl` must be available
- A [Nerd Font](https://www.nerdfonts.com/) installed (JetBrains Mono Nerd Font recommended)
- [Ghostty](https://ghostty.org/) terminal

## Post-install

Update `.gitconfig` with your name/email if needed:

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```
