alias reload="exec zsh"
alias cls="clear"

# Better defaults
alias grep="grep --color=auto"
alias mkdir="mkdir -pv"

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
alias home="cd ~"
alias dev="cd ~/dev"

## Modern replacements (if installed)
if command -v lsd &> /dev/null; then
    alias ls="lsd"
    alias l="lsd -la"
    alias la="lsd -la"
    alias ll="lsd -l"
    alias lt="lsd --tree"
else
    alias l="ls -lah"
    alias la="ls -lAh"
    alias ll="ls -lh"
fi

# Neovim
alias v="nvim"
alias vim="nvim"

# Dotfiles
alias dots="cd ~/.dotfiles"
alias dot="~/.dotfiles/dot"