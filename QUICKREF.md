# Quick Reference Guide

## Daily Commands

### Dotfiles Management
```bash
./dot doctor          # Check system health
./dot update          # Update dotfiles and packages
./dot stow            # Refresh symlinks
```

### Git Shortcuts (Zsh/PowerShell)
```bash
# Works in both Zsh (WSL) and PowerShell (Windows)
gs                    # git status
ga .                  # git add .
gc -m "message"       # git commit
gp                    # git push
gl                    # git pull
glog                  # pretty git log
```

### Navigation
```bash
z project             # Jump to frequently used directory (zoxide)
..                    # cd ..
...                   # cd ../..
dots                  # cd ~/.dotfiles
```

## Configuration Files Quick Access

### Git
```bash
vim ~/.dotfiles/home/.config/git/config        # Personal git config
vim ~/.dotfiles/home/.config/git/work_config   # Work git config
```

### Neovim
```bash
vim ~/.dotfiles/home/.config/nvim/init.lua     # Main neovim config
# Add plugins in: ~/.dotfiles/home/.config/nvim/lua/plugins/
```

### Shell
```bash
# WSL (Zsh)
vim ~/.dotfiles/home/.config/zsh/.zshrc           # Zsh config

# Windows (PowerShell)  
vim ~/.dotfiles/home/.config/powershell/profile.ps1  # PowerShell profile

# Both
vim ~/.dotfiles/home/.config/starship.toml        # Prompt config
```

### Tmux
```bash
vim ~/.dotfiles/home/.config/tmux/tmux.conf    # Tmux config
```

## Tmux Keybindings

### Session/Window Management
- `Ctrl-a c` - New window
- `Ctrl-a ,` - Rename window
- `Ctrl-a n` - Next window
- `Ctrl-a p` - Previous window
- `Ctrl-a d` - Detach session

### Pane Management
- `Ctrl-a |` - Split horizontal
- `Ctrl-a -` - Split vertical
- `Ctrl-a h/j/k/l` - Navigate panes (vim-style)
- `Ctrl-a H/J/K/L` - Resize panes (hold Ctrl-a)
- `Ctrl-a x` - Close pane

### Copy Mode
- `Ctrl-a [` - Enter copy mode
- `v` - Start selection (in copy mode)
- `y` - Copy selection
- `q` - Exit copy mode

### Other
- `Ctrl-a r` - Reload config

## Package Management

### WSL (Homebrew)
```bash
# Add package to Brewfile
echo 'brew "package-name"' >> ~/.dotfiles/packages/bundle

# Install
brew bundle --file=~/.dotfiles/packages/bundle

# Update all
brew update && brew upgrade
```

### Windows (Scoop)
```powershell
# Install package
scoop install package-name

# Update all
scoop update *

# Search for package
scoop search package-name
```

## Troubleshooting

### Symlinks Not Working
```bash
# Check symlink status
ls -la ~/.config/git/config

# Re-create symlinks
cd ~/.dotfiles
./dot stow

# Manual stow
stow -R -v -d ~/.dotfiles -t ~ home
```

### Git Config Not Applied
```bash
# Check which config is active
git config --list --show-origin

# Test work directory detection
cd ~/work/some-repo
git config user.email  # Should show work email
```

### Windows Symlinks
```powershell
# Run PowerShell as Administrator
cd C:\dev\projects\dotfiles
.\scripts\setup-windows-links.ps1

# Or enable Developer Mode in Windows Settings
```

### Neovim Issues
```bash
# Check neovim config location
nvim --version
echo $MYVIMRC

# Check if plugins loaded
nvim -c "Lazy"

# Clear plugin cache
rm -rf ~/.local/share/nvim
```

## SSH Setup

### Generate Key
```bash
ssh-keygen -t ed25519 -C "your.email@example.com"
```

### Add to Agent
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

### Copy to GitHub
```bash
cat ~/.ssh/id_ed25519.pub
# Copy output and add to GitHub: Settings → SSH and GPG keys
```

## Zsh Shell Tips

### Add Aliases
```zsh
# Edit zsh config
vim ~/.config/zsh/.zshrc

# Add alias
alias myalias="command to run"
```

### Add Functions
```zsh
# Create function in ~/.config/zsh/.zshrc
function myfunction() {
    echo "Hello"
}
```

### Reload Config
```zsh
source ~/.zshrc
```

## PowerShell Tips (Windows)

### Edit and Reload Profile
```powershell
ep          # Edit profile (opens in nvim)
rp          # Reload profile
```

### WSL Integration
```powershell
wsl-home    # Jump to WSL home directory
wsl         # Run WSL commands
```

### Aliases Work Same as Zsh
```powershell
# All git aliases work the same
gs          # git status
ga .        # git add .
gc -m "msg" # git commit

# Navigation
..          # cd ..
dots        # cd ~/.dotfiles
```

### File Hashes
```powershell
md5 file.txt     # MD5 hash
sha256 file.txt  # SHA256 hash
```

## Environment Variables

### WSL
```zsh
# Edit zsh config
vim ~/.dotfiles/home/.config/zsh/.zshrc

# Add variable
export VAR_NAME=value
```

### Windows
```powershell
# Temporary (current session)
$env:VAR_NAME = "value"

# Permanent (user)
[System.Environment]::SetEnvironmentVariable("VAR_NAME", "value", "User")
```

## Updating This Setup

### Pull Latest Changes
```bash
cd ~/.dotfiles
git pull
./dot update
```

### Add New Config File
```bash
# 1. Add to home/.config/
# 2. Commit to git
# 3. Run ./dot stow
```

### Share Config Change
```bash
cd ~/.dotfiles
git add .
git commit -m "Update config"
git push
```
