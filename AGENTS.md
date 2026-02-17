# DOTFILES

wsl/windows dev env

## CONVENTIONS

- Scoop for windows. Hombrew for WSL

## ANTI-PATTERNS

- Edit `~/.config/*` directly (changes lost on stow)
- Casks in `bundle.work` (use base bundle)
- Hardcode paths (use `$DOTFILES_DIR`, `$HOME`)
- Nested git repos in stowed dirs (creates symlink issues)
- node_modules in stowed dirs (opencode exception)

## NOTES

- dot for wsl and dot.ps1 for windows
- want similar packages installed between wsl and windows. GUI apps will be installed on windows.
