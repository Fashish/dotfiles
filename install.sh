#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing dotfiles from $DOTFILES_DIR"

# --- Symlink dotfiles ---
ln -sfv "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
ln -sfv "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"

# --- Starship config ---
mkdir -p "$HOME/.config/starship"
ln -sfv "$DOTFILES_DIR/.config/starship/starship.toml" "$HOME/.config/starship/starship.toml"

# --- Ghostty config ---
# macOS uses ~/Library/Application Support/com.mitchellh.ghostty/
# Linux uses ~/.config/ghostty/
if [[ "$(uname)" == "Darwin" ]]; then
  GHOSTTY_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
else
  GHOSTTY_DIR="$HOME/.config/ghostty"
fi
mkdir -p "$GHOSTTY_DIR"
ln -sfv "$DOTFILES_DIR/.config/ghostty/config" "$GHOSTTY_DIR/config"

# --- Oh My Zsh ---
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# --- Custom zsh plugins ---
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
  echo "Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
  echo "Installing zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# --- Gruvbox syntax highlighting theme ---
mkdir -p "$ZSH_CUSTOM/themes"
ln -sfv "$DOTFILES_DIR/oh-my-zsh-custom/themes/gruvbox-zsh-syntax-highlighting.zsh" "$ZSH_CUSTOM/themes/gruvbox-zsh-syntax-highlighting.zsh"

# --- Starship prompt ---
if ! command -v starship &>/dev/null; then
  echo "Installing Starship prompt..."
  curl -sS https://starship.rs/install.sh | sh -s -- --yes
fi

# --- fnm (Fast Node Manager) ---
if ! command -v fnm &>/dev/null; then
  echo "Installing fnm..."
  curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
fi

echo ""
echo "Done! Restart your shell or run: source ~/.zshrc"
