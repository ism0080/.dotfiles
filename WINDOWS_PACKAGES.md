# Windows Package Management - Complete Guide

This guide explains how Scoop packages and PowerShell modules are managed in the dotfiles setup.

## Overview

The dotfiles setup uses two package management systems on Windows:

1. **Scoop** - Command-line tools and applications
2. **PowerShell Gallery** - PowerShell modules

Both are automated through scripts for easy installation.

## Scoop Packages

### Package List

All Scoop packages are defined in `packages/scoopfile.json`:

- **CLI Tools**: lsd, fzf, ripgrep, fd, gh, jq, curl, etc.
- **Development Tools**: neovim, lazygit, lazydocker, gcc, etc.
- **File Managers**: yazi (terminal file manager)
- **Utilities**: 7zip, glow (markdown renderer), typos (spell checker)

### Installation

#### Automated (Recommended)
```powershell
# Install all Scoop packages
.\scripts\setup-windows.ps1
```

#### Manual
```powershell
# Install Scoop first
irm get.scoop.sh | iex

# Add buckets
scoop bucket add main
scoop bucket add extras
scoop bucket add java

# Install packages individually
scoop install lsd fzf ripgrep fd neovim lazygit
```

### Updating Packages
```powershell
# Update all Scoop packages
scoop update *

# Update specific package
scoop update neovim
```

## PowerShell Modules

### Module List

All PowerShell modules are defined in `packages/psmodules.txt`:

1. **PSReadLine** - Enhanced command-line editing
   - History search
   - Predictive IntelliSense
   - Tab completion improvements

2. **PSFzf** - Fuzzy finder integration
   - Ctrl+F for fuzzy file search
   - Ctrl+R for command history search
   - Tab completion with FZF
   - Provides `Invoke-Fzf` cmdlet

3. **posh-git** - Git status in prompt
   - Shows branch name
   - Shows uncommitted changes
   - Git tab completion

4. **Terminal-Icons** - File icons in terminal
   - Colorful icons for different file types
   - Works with ls/lsd commands

### Installation

#### Automated (Recommended)
```powershell
# Install all PowerShell modules
.\scripts\install-psmodules.ps1

# Or as part of full setup
.\scripts\setup-windows.ps1
```

#### Manual
```powershell
# Install for current user
Install-Module PSReadLine -Scope CurrentUser -Force
Install-Module PSFzf -Scope CurrentUser -Force
Install-Module posh-git -Scope CurrentUser -Force
Install-Module Terminal-Icons -Scope CurrentUser -Force

# Or install for all users (requires admin)
Install-Module PSReadLine -Scope AllUsers -Force
```

### Updating Modules
```powershell
# Update all modules
.\scripts\install-psmodules.ps1 -Force

# Or manually
Update-Module PSReadLine
Update-Module PSFzf
Update-Module posh-git
Update-Module Terminal-Icons
```

## Complete Windows Setup Workflow

### Option 1: Fully Automated

```powershell
# 1. Install Scoop
irm get.scoop.sh | iex

# 2. Run complete setup
cd C:\dev\projects\dotfiles
.\scripts\setup-windows.ps1

# 3. If not admin, run symlinks separately as admin
.\scripts\setup-windows-links.ps1

# 4. Reload profile
. $PROFILE
```

### Option 2: Step by Step

```powershell
# 1. Install Scoop
irm get.scoop.sh | iex

# 2. Install Scoop packages only
.\scripts\setup-windows.ps1 -SkipModules -SkipSymlinks

# 3. Install PowerShell modules only
.\scripts\install-psmodules.ps1

# 4. Create symlinks (as Administrator)
.\scripts\setup-windows-links.ps1

# 5. Reload profile
. $PROFILE
```

## Script Reference

### `setup-windows.ps1`

Main Windows setup script that orchestrates everything.

**Usage:**
```powershell
.\scripts\setup-windows.ps1 [options]

Options:
  -SkipScoop      Skip Scoop package installation
  -SkipModules    Skip PowerShell module installation
  -SkipSymlinks   Skip symlink creation
  -Force          Force reinstall/update packages
```

**Examples:**
```powershell
# Full setup
.\scripts\setup-windows.ps1

# Only install packages
.\scripts\setup-windows.ps1 -SkipModules -SkipSymlinks

# Force update everything
.\scripts\setup-windows.ps1 -Force
```

### `install-psmodules.ps1`

Installs PowerShell modules from `packages/psmodules.txt`.

**Usage:**
```powershell
.\scripts\install-psmodules.ps1 [options]

Options:
  -Force    Force update existing modules
```

**Examples:**
```powershell
# Install modules
.\scripts\install-psmodules.ps1

# Update existing modules
.\scripts\install-psmodules.ps1 -Force
```

### `setup-windows-links.ps1`

Creates symlinks from Windows to WSL configs (requires Administrator).

**Usage:**
```powershell
# Must run as Administrator
.\scripts\setup-windows-links.ps1
```

Creates:
- `~\.gitconfig` → WSL git config
- `~\AppData\Local\nvim` → WSL neovim config
- `~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1` → PowerShell profile

## Adding New Packages

### Adding Scoop Packages

Edit `packages/scoopfile.json`:

```json
{
  "apps": [
    {
      "name": "your-package",
      "source": "main",
      "comment": "Description of package"
    }
  ]
}
```

Then run:
```powershell
scoop install your-package
```

### Adding PowerShell Modules

Edit `packages/psmodules.txt`:

```
# Add module name (one per line)
YourModuleName
```

Then run:
```powershell
.\scripts\install-psmodules.ps1
```

## Troubleshooting

### Scoop Issues

**Scoop not found:**
```powershell
# Reinstall Scoop
irm get.scoop.sh | iex
```

**Package installation fails:**
```powershell
# Update Scoop
scoop update

# Try installing again
scoop install package-name
```

### PowerShell Module Issues

**Module import fails:**
```powershell
# Check if module is installed
Get-Module -ListAvailable ModuleName

# Reinstall module
Install-Module ModuleName -Force
```

**PSFzf not working:**
```powershell
# Make sure fzf is installed
scoop install fzf

# Reimport module
Import-Module PSFzf -Force
```

### Symlink Issues

**Permission denied:**
- Must run as Administrator
- Enable Developer Mode in Windows Settings

**Symlink already exists:**
```powershell
# Remove old symlink
Remove-Item ~\.gitconfig -Force

# Run setup again
.\scripts\setup-windows-links.ps1
```

## Files Reference

```
dotfiles/
├── packages/
│   ├── scoopfile.json      # Scoop packages definition
│   └── psmodules.txt       # PowerShell modules list
└── scripts/
    ├── setup-windows.ps1        # Main Windows setup script
    ├── install-psmodules.ps1    # PowerShell module installer
    └── setup-windows-links.ps1  # Symlink creator
```

## Benefits of This Approach

✅ **Declarative** - All packages defined in config files
✅ **Automated** - One command to install everything
✅ **Reproducible** - Easy to set up on new machines
✅ **Version Controlled** - Package lists tracked in git
✅ **Updateable** - Simple commands to update everything
✅ **Modular** - Install components independently

---

For more information, see:
- [README.md](README.md) - Main documentation
- [SETUP_CHECKLIST.md](SETUP_CHECKLIST.md) - Step-by-step setup guide
- [Scoop Documentation](https://scoop.sh/)
- [PowerShell Gallery](https://www.powershellgallery.com/)
