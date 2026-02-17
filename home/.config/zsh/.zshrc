# Zsh configuration

# Add dotfiles bin to PATH
export PATH="$HOME/.dotfiles:$PATH"

# Environment variables
export EDITOR="nvim"
export VISUAL="nvim"

# XDG Base Directory
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# Zsh config location
export ZDOTDIR="$HOME/.config/zsh"

# History configuration
export HISTFILE="$ZDOTDIR/.zsh_history"
export HISTSIZE=10000
export SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY

# Completion
autoload -Uz compinit
compinit -C

# Enable colors
autoload -U colors && colors

# Homebrew environment (WSL)
export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"
export MANPATH="$HOMEBREW_PREFIX/share/man:$MANPATH"
export INFOPATH="$HOMEBREW_PREFIX/share/info:$INFOPATH"

# Starship prompt (if installed)
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# # Zoxide (if installed)
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi

# # Mise - Modern runtime version manager (if installed)
if command -v mise &> /dev/null; then
    eval "$(mise hook-env -s zsh)"
fi

# # fnox - Secrets manager
if command -v fnox &> /dev/null; then
    eval "$(fnox activate zsh)"
fi

# Key bindings
bindkey -e  # Emacs mode (or use -v for vi mode)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# Extend
[[ -f "$ZDOTDIR/aliases.zsh" ]] && source "$ZDOTDIR/aliases.zsh"
[[ -f "$ZDOTDIR/functions.zsh" ]] && source "$ZDOTDIR/functions.zsh"