# Dotfiles — Claude Code Context

Personal dotfiles repo for macOS and Linux. Gruvbox Dark themed throughout.

## Repo structure

```
.zshrc                          → ~/.zshrc
.gitconfig                      → ~/.gitconfig
.config/starship/starship.toml  → ~/.config/starship/starship.toml
.config/ghostty/config          → macOS: ~/Library/Application Support/com.mitchellh.ghostty/config
                                  Linux: ~/.config/ghostty/config
oh-my-zsh-custom/themes/        → ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/
install.sh                      — Non-interactive fallback installer (CI, Docker, quick setup)
```

## Tools managed

- **Shell:** zsh + Oh My Zsh
- **Plugins:** zsh-autosuggestions (git clone), zsh-syntax-highlighting (git clone)
- **Prompt:** Starship with Gruvbox Dark palette
- **Terminal:** Ghostty (JetBrains Mono Nerd Font, size 13)
- **Node:** fnm (Fast Node Manager)
- **Packages:** pnpm

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
