# Zsh environment file
# This file is sourced by zsh for all shells (login and interactive)

# XDG Base Directory
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Point zsh config to XDG location
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
