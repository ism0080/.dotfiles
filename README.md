# Dotfiles for WSL/Windows

A comprehensive dotfiles management system for hybrid WSL/Windows development environments. Features shared configurations for Git and Neovim, with platform-specific package management via Homebrew (WSL) and Scoop (Windows).

## Overview

This repository manages dotfiles optimized for:
- **Primary development in WSL** with Linux tools via Homebrew
- **Windows-side tooling** via Scoop for native apps and utilities  
- **Shared configuration files** for Git and Neovim accessible from both environments
- **Work/personal separation** via Git's conditional includes

Inspired by [dmmulroy's dotfiles](https://github.com/dmmulroy/.dotfiles) but adapted for WSL/Windows workflows.

## Features

- 🚀 **One-command setup** - Automated WSL environment setup
- 🔄 **Shared configs** - Git and Neovim work seamlessly in both WSL and Windows
- 📦 **Dual package managers** - Homebrew for WSL, Scoop for Windows
- 🛠️ **Work configuration** - Automatic work email/settings for specific directories
- 🎯 **Minimal dependencies** - Uses GNU Stow for symlink management

## Quick Start

### WSL Setup (Primary)

```bash
# 1. Clone the repository
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# 2. Run initialization
./dot init

# 3. Configure your personal info
# Edit home/.config/git/config with your name and email
# Edit home/.config/git/work_config if you need work-specific settings
```

### Windows Setup (Secondary)

```powershell
# 1. Install Scoop (in PowerShell)
irm get.scoop.sh | iex

# 2. Run automated setup (installs packages and modules)
cd C:\dev\projects\dotfiles
.\scripts\setup-windows.ps1

# This will:
# - Install Scoop packages from scoopfile.json
# - Install PowerShell modules (PSReadLine, PSFzf, posh-git, Terminal-Icons)
# - Create symlinks (requires Administrator)

# Or, install components individually:

# Install Scoop packages only
.\scripts\setup-windows.ps1 -SkipModules -SkipSymlinks

# Install PowerShell modules only
.\scripts\install-psmodules.ps1

# Create symlinks only (run as Administrator)
.\scripts\setup-windows-links.ps1
```

## Repository Structure

```
~/.dotfiles/
├── dot                    # Main CLI management tool
├── home/                  # Config files (stowed to ~)
│   └── .config/
│       ├── git/           # Git configuration
│       │   ├── config     # Main git config
│       │   ├── work_config # Work-specific overrides
│       │   └── ignore     # Global gitignore
│       ├── nvim/          # Neovim configuration
│       │   ├── init.lua   # Main config (WSL/Windows compatible)
│       │   └── lua/plugins/ # Plugin configurations
│       ├── powershell/    # PowerShell profile (Windows)
│       ├── zsh/           # Zsh shell config (WSL)
│       ├── tmux/          # Tmux config
│       └── starship.toml  # Cross-platform prompt
├── packages/
│   ├── bundle             # Homebrew packages (WSL)
│   ├── bundle.work        # Work-specific Homebrew packages
│   ├── scoopfile.json     # Scoop packages manifest (Windows)
│   └── psmodules.txt      # PowerShell modules list (Windows)
└── scripts/
    ├── setup-windows.ps1        # Automated Windows setup
    ├── setup-windows-links.ps1  # Windows symlink helper
    └── install-psmodules.ps1    # PowerShell module installer

```

### How GNU Stow Works

This repository uses [GNU Stow](https://www.gnu.org/software/stow/) for symlink management. Understanding how it works helps you add new configs:

**Directory Structure:**
```
dotfiles/
└── home/              # Stow package directory (named "home")
    └── .config/       # Mirrors target structure
        ├── git/       # Will be symlinked to ~/.config/git/
        └── nvim/      # Will be symlinked to ~/.config/nvim/
```

**How Stowing Works:**
1. Stow looks at the `home/` directory as a "package"
2. For each file/directory inside `home/`, it creates a symlink in `$HOME`
3. Example: `home/.config/git/config` → `$HOME/.config/git/config`

**Adding a New Config:**
```bash
# 1. Create the directory in home/
mkdir -p home/.config/new-tool

# 2. Add your config files
cp ~/.config/new-tool/config.toml home/.config/new-tool/

# 3. Re-stow to create symlinks
./dot stow
```

**Stow Command Used:**
```bash
stow -R -v -d "$DOTFILES_DIR" -t "$HOME" home
# -R = Restow (remove and recreate)
# -v = Verbose
# -d = Set stow directory (where packages live)
# -t = Set target directory (where symlinks go)
```

**Important Notes:**
- Existing files are backed up before stowing (you'll be prompted)
- Never edit files in `~/.config/*` directly - they're symlinks to the dotfiles repo
- Edit files in `home/.config/*` instead, then re-stow

## The `dot` Command

The `dot` command manages your dotfiles installation and updates.

### Installation Commands

#### `dot init` - WSL Setup
Complete environment setup for WSL.

```bash
dot init
```

**What it does:**
1. Installs Homebrew (if not present)
2. Installs packages from Brewfile
3. Creates symlinks with GNU Stow
4. Sets up Zsh shell
5. Configures Git

#### `dot init-windows` - Windows Setup Instructions
Shows instructions for Windows-side configuration.

```bash
dot init-windows
```

### Maintenance Commands

#### `dot update` - Update Everything
```bash
dot update
```
- Pulls latest dotfiles changes
- Updates Homebrew packages (WSL)
- Re-stows configuration files

#### `dot doctor` - Health Check
```bash
dot doctor
```
Comprehensive diagnostics including:
- ✅ Homebrew installation (WSL)
- ✅ Essential tools (git, nvim, tmux, zsh, etc.)
- ✅ Symlink status
- ✅ Configuration files

#### `dot stow` - Update Symlinks
```bash
dot stow
```
Re-creates symlinks from `home/` directory to your home directory (`~`).

#### `dot validate` - Check Package Sync
```bash
dot validate
```
Validates that common tools are available in both WSL and Windows package manifests.

#### `dot backup` - Backup Configs
```bash
dot backup
```
Creates a timestamped backup of current configuration files in `backups/`.

#### `dot edit` - Quick Config Editing
```bash
dot edit git      # Edit git config
dot edit nvim     # Edit neovim config
dot edit zsh      # Edit zsh config
dot edit aliases  # Edit zsh aliases
dot edit starship # Edit starship prompt
dot edit tmux     # Edit tmux config
dot edit mise     # Edit mise config
```
Opens the specified config file in your editor ($EDITOR or nvim).

## Configuration

### Package Management

**WSL (Homebrew):**
Edit `packages/bundle` to add/remove packages:
```ruby
brew "ripgrep"
brew "fd"
```

**Windows (Scoop):**
Edit `packages/scoopfile.json` to add packages, then run:
```powershell
.\scripts\setup-windows.ps1
# Or install individual package:
scoop install ripgrep
```

### Git Configuration

**Personal settings** - Edit `home/.config/git/config`:
```ini
[user]
    name = Your Name
    email = your.email@example.com
```

**Work settings** - Edit `home/.config/git/work_config`:
```ini
[user]
    name = Your Name
    email = work.email@company.com
```

The work config automatically applies to repositories in `~/work/` directory (configurable via `includeIf` in main config).

#### Git Aliases

Built-in git aliases (use as `git <alias>`):

| Alias | Command | Description |
|-------|---------|-------------|
| `st` | `status` | Show working tree status |
| `co` | `checkout` | Switch branches |
| `br` | `branch` | List/create branches |
| `ci` | `commit` | Commit changes |
| `d` | `diff` | Show differences |
| `ds` | `diff --staged` | Show staged differences |
| `lg` | (custom log) | Pretty graph log |
| `lol` | `log --oneline --graph --decorate` | Compact log |
| `last` | `log -1 HEAD` | Show last commit |
| `amend` | `commit --amend --no-edit` | Amend without editing message |
| `unstage` | `reset HEAD --` | Unstage files |
| `undo` | `reset --soft HEAD~1` | Undo last commit (keep changes) |
| `redo` | `reset 'HEAD@{1}'` | Redo undone commit |
| `wip` | (custom) | Commit all changes as "WIP" |
| `nowip` | (custom) | Undo WIP commit |

Shell convenience aliases (zsh/PowerShell):
- `g` → `git`
- `gs` → `git status`
- `ga` → `git add`
- `gc` → `git commit`
- `gp` → `git push`
- `gl` → `git pull`
- `gco` → `git checkout`
- `gd` → `git diff`
- `glog` → `git log --oneline --graph --decorate`
- `lg` → `lazygit` (if installed)

### Neovim Configuration

The Neovim config in `home/.config/nvim/init.lua` works on both WSL and Windows:
- Automatically detects WSL and configures clipboard integration
- Uses lazy.nvim for plugin management
- Sensible defaults for cross-platform development

Add plugins by creating files in `home/.config/nvim/lua/plugins/`:
```lua
-- home/.config/nvim/lua/plugins/example.lua
return {
  "plugin/name",
  config = function()
    -- plugin configuration
  end,
}

node = "lts"  # Use Node.js LTS by default
```


### Shared Configs Between WSL and Windows

Git and Neovim configs live in WSL and are accessible from Windows via symlinks:

**From PowerShell (as Administrator):**
```powershell
# Run the setup script
.\scripts\setup-windows-links.ps1
```

This creates:
- `~/.gitconfig` → Points to WSL git config file
- `~/AppData/Local/nvim` → Points to WSL neovim config directory
- `~/Documents/PowerShell/Microsoft.PowerShell_profile.ps1` → Points to WSL PowerShell profile

### PowerShell Configuration

The PowerShell profile in `home/.config/powershell/profile.ps1` includes:
- Git aliases matching the Zsh configuration
- Starship prompt integration
- PSReadLine with history search
- Zoxide and FNM integration
- Navigation shortcuts and functions
- WSL integration helpers

**Features:**
- Same aliases as Zsh (gs, ga, gc, gp, etc.)
- `wsl-home` function to quickly jump to WSL home
- `ep` (Edit-Profile) and `rp` (Reload-Profile) shortcuts
- Color-coded output and better defaults

## Troubleshooting

### Common Issues

**Command not found: `dot`**
```bash
# Add to PATH
export PATH="$HOME/.dotfiles:$PATH"

# Or source your shell config
source ~/.zshrc
```

**Symlink permission denied (Windows)**
- Run PowerShell as Administrator
- Or enable Developer Mode: Settings → Update & Security → For developers

**WSL clipboard not working with Neovim**
- The config automatically handles this with clip.exe/powershell.exe
- Ensure Windows paths are accessible from WSL

**Git config not applying**
```bash
# Check if symlink exists
ls -la ~/.config/git/config

# Re-run stow
cd ~/.dotfiles
./dot stow
```

## Platform-Specific Notes

### WSL
- Configs live in WSL filesystem (`~/.dotfiles`)
- Use Homebrew for package management
- Zsh shell recommended for best experience
- GNU Stow required for symlink management

### Windows
- Accesses configs via `\\wsl$\Ubuntu\home\user\.dotfiles`
- Use Scoop for package management
- Neovim looks for config in `AppData/Local/nvim`
- Git looks for config in `~/.config/git`
- Requires Administrator for symlink creation

## Development

### Adding New Packages

**WSL:**
```bash
# Edit packages/bundle
echo 'brew "new-package"' >> packages/bundle

# Install
brew bundle --file=packages/bundle
```

**Windows:**
```powershell
# Install directly with Scoop
scoop install new-package

# Add to packages/scoopfile.json for tracking
# Then run: .\scripts\setup-windows.ps1
```

### Testing Changes

```bash
# Make modifications
vim home/.config/git/config

# Check status
./dot doctor

# Re-stow if needed
./dot stow
```

## Advanced Usage

### Selective Installation

```bash
# Install only core packages
brew bundle --file=./packages/bundle

# Add work packages later
brew bundle --file=./packages/bundle.work
```

### SSH Key Setup

```bash
# Generate SSH key for GitHub
ssh-keygen -t ed25519 -C "your.email@example.com"

# Add to ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Copy public key
cat ~/.ssh/id_ed25519.pub
# Add to GitHub: Settings → SSH and GPG keys
```

### Multiple Work Environments

Edit `home/.config/git/config` to add multiple includeIf sections:
```ini
[includeIf "gitdir:~/work/"]
    path = ~/.config/git/work_config

[includeIf "gitdir:~/client-a/"]
    path = ~/.config/git/client_a_config
```

## Contributing

This is a personal dotfiles repository, but feel free to:
- Fork and adapt for your own setup
- Open issues for questions or suggestions
- Submit PRs for improvements

## Acknowledgments

- Inspired by [dmmulroy's dotfiles](https://github.com/dmmulroy/.dotfiles)
- [GNU Stow](https://www.gnu.org/software/stow/) for symlink management
- [Homebrew](https://brew.sh/) for WSL package management  
- [Scoop](https://scoop.sh/) for Windows package management

## License

MIT - Feel free to use and adapt for your own needs.

---

## Next Steps After Setup

1. **Personalize Git config:**
   ```bash
   vim ~/.dotfiles/home/.config/git/config
   ```

2. **Add your favorite tools:**
   - Edit `packages/bundle` (WSL)
   - Install via Scoop (Windows)

3. **Customize Neovim:**
   - Add plugins in `home/.config/nvim/lua/plugins/`
   - Configure keybindings and settings

4. **Configure work directory:**
   - Create `~/work/` directory
   - Edit `home/.config/git/work_config` with work email

---

**Happy coding!** 🚀
