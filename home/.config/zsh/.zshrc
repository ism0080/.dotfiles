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
compinit

# Enable colors
autoload -U colors && colors

# Homebrew environment (WSL)
if [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Starship prompt (if installed)
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# Zoxide (if installed)
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi

# Mise - Modern runtime version manager (if installed)
if command -v mise &> /dev/null; then
    eval "$(mise activate zsh)"
fi

# fnox - Secrets manager
if command -v fnox &> /dev/null; then
    eval "$(fnox activate zsh)"
fi

# Aliases
# Git
alias g="git"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"
alias gco="git checkout"
alias gd="git diff"
alias glog="git log --oneline --graph --decorate"

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# Neovim
alias v="nvim"
alias vim="nvim"

# Dotfiles
alias dots="cd ~/.dotfiles"

# Modern replacements (if installed)
if command -v lsd &> /dev/null; then
    alias ls="lsd"
    alias l="lsd -la"
    alias la="lsd -la"
    alias ll="lsd -l"
    alias tree="lsd --tree"
elif command -v eza &> /dev/null; then
    alias ls="eza"
    alias l="eza -la"
    alias la="eza -la"
    alias ll="eza -l"
    alias tree="eza --tree"
else
    alias l="ls -lah"
    alias la="ls -lAh"
    alias ll="ls -lh"
fi

# Better defaults
alias grep="grep --color=auto"
alias mkdir="mkdir -pv"

# Key bindings
bindkey -e  # Emacs mode (or use -v for vi mode)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# Load local customizations if they exist
[[ -f "$ZDOTDIR/.zshrc.local" ]] && source "$ZDOTDIR/.zshrc.local"
