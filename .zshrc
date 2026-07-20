export PATH="$HOME/.local/bin:$PATH"

# =============================================================================
# Oh My Zsh
# =============================================================================
export ZSH="$HOME/.oh-my-zsh"

plugins=(
  git
  sudo                       # double-tap ESC to prepend sudo
  copypath                   # copy current path to clipboard
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# =============================================================================
# Autosuggest
# =============================================================================
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=1

source $ZSH/oh-my-zsh.sh

# =============================================================================
# Prompt — Starship
# =============================================================================
export STARSHIP_CONFIG=~/.config/starship/starship.toml
eval "$(starship init zsh)"

# =============================================================================
# Gruvbox syntax highlighting
# =============================================================================
source ~/.oh-my-zsh/custom/themes/gruvbox-zsh-syntax-highlighting.zsh

# =============================================================================
# VS Code shell integration
# =============================================================================
if [[ "$TERM_PROGRAM" == "vscode" ]] && command -v code >/dev/null 2>&1; then
  shell_integration="$(code --locate-shell-integration-path zsh 2>/dev/null)"
  [[ -r "$shell_integration" ]] && source "$shell_integration"
  unset shell_integration
fi

# =============================================================================
# Node — fnm
# =============================================================================
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi

# =============================================================================
# Git aliases
# =============================================================================
alias gs='git status'
alias gaa='git add .'
alias ga='git add'
alias gcm='git commit -m'
alias gca='git commit --amend --no-edit'  # amend without changing message
alias gco='git checkout'
alias gb='git branch'
alias gcb='git checkout -b'
alias gd='git diff'
alias gds='git diff --staged'            # diff what's already staged
alias gp='git push'
alias gpf='git push --force-with-lease'  # safer force push
alias gpl='git pull'
alias gcl='git clone'
alias gl='git log --oneline --graph --decorate -20'  # pretty log
alias gst='git stash'
alias gstp='git stash pop'

# =============================================================================
# Playwright / testing aliases
# =============================================================================
alias pw='pnpm playwright'
alias pwt='pnpm playwright test'
alias pwth='pnpm playwright test --headed'
alias pwtu='pnpm playwright test --ui'
alias pwtd='pnpm playwright test --debug'
alias pws='pnpm playwright show-report'
alias pwc='pnpm playwright codegen'

# =============================================================================
# pnpm aliases
# =============================================================================
alias pi='pnpm install'
alias pa='pnpm add'
alias pad='pnpm add -D'
alias pr='pnpm remove'
alias prun='pnpm run'
alias pd='pnpm dev'
alias pb='pnpm build'
alias pt='pnpm test'

# =============================================================================
# General aliases
# =============================================================================
if [[ "$(uname)" == "Darwin" ]]; then
  alias subl='"/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl"'
  alias ls='ls -G'                      # coloured output on macOS
else
  alias ls='ls --color=auto'            # coloured output on Linux
fi

# eza overrides the plain ls aliases above, where it is installed
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons=auto --group-directories-first'
  alias la='eza -la --icons=auto --group-directories-first'
  alias ll='eza -l --icons=auto --group-directories-first'
else
  alias la='ls -lAh'
  alias ll='ls -lh'
fi
alias galias='alias | sort'             # list all aliases
alias zshrc='code ~/.zshrc'            # open zshrc in VS Code
alias reload='source ~/.zshrc'         # reload config
alias ..='cd ..'
alias ...='cd ../..'
