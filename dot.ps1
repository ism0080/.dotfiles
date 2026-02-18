#!/usr/bin/env pwsh
<#
.SYNOPSIS
    PowerShell wrapper for the dot command - Dotfiles management for WSL/Windows

.DESCRIPTION
    This PowerShell script wraps the bash-based dot script, making it easy to run
    dotfiles management commands from PowerShell on Windows.

.PARAMETER Command
    The dot command to run (init, init, update, doctor, stow, help)

.PARAMETER Arguments
    Additional arguments to pass to the command

.EXAMPLE
    .\dot.ps1 doctor
    Run diagnostics on your dotfiles setup

.EXAMPLE
    .\dot.ps1 init
    Initialize Windows-side configuration

.EXAMPLE
    .\dot.ps1 update
    Update dotfiles and packages

.NOTES
    For best results with WSL commands, ensure Git Bash or WSL is installed
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Command = "help",
    
    [Parameter(Position = 1, ValueFromRemainingArguments = $true)]
    [string[]]$Arguments
)

$ErrorActionPreference = "Stop"

$DotfilesDir = $PSScriptRoot

function Get-WSLDistro {
    $distro = $env:WSL_DISTRO_NAME
    if (-not $distro -and (Get-Command wsl -ErrorAction SilentlyContinue)) {
        $distro = (wsl -l -q 2>$null | Select-Object -First 1).Trim()
    }
    return $distro
}

$WSLDistro = Get-WSLDistro
if (-not $WSLDistro) { $WSLDistro = "Ubuntu" }

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Write-Success {
    param([string]$Message)
    Write-ColorOutput "✓ $Message" -Color Green
}

function Write-Error-Custom {
    param([string]$Message)
    Write-ColorOutput "✗ $Message" -Color Red
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-ColorOutput "⚠ $Message" -Color Yellow
}

function Write-Info {
    param([string]$Message)
    Write-ColorOutput "ℹ $Message" -Color Cyan
}

function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-ColorOutput "==> $Message" -Color Blue
}

# Main execution
Write-Header "Dotfiles Management (PowerShell Wrapper)"

# Check if we're on Windows
if (-not $IsWindows -and -not $env:OS -match "Windows") {
    Write-Error-Custom "This PowerShell wrapper is designed for Windows"
    Write-Info "Run './dot $Command' directly from bash instead"
    exit 1
}

# Handle different commands
switch ($Command.ToLower()) {
    "init" {
        Write-Header "Initializing Windows-side configuration"
        
        # Check if Scoop is installed
        if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
            Write-Warning-Custom "Scoop is not installed"
            Write-Info "Install Scoop first with:"
            Write-Host "  irm get.scoop.sh | iex" -ForegroundColor White
            exit 1
        }
        
        Write-Success "Scoop is installed"
        
        # Run the Windows setup script safely
        $SetupScript = Join-Path $DotfilesDir "scripts\setup-windows.ps1"

        if (-not (Test-Path $SetupScript)) {
            Write-Error-Custom "Setup script not found: $SetupScript"
            exit 1
        }

        Write-Info "Running Windows setup script..."

        # Safely invoke the script in a new PowerShell process
        $ScriptFile = (Get-Item $SetupScript).FullName
        & $ScriptFile

        
        if ($LASTEXITCODE -eq 0) {
            Write-Header "Windows setup complete! 🎉"
            Write-Info "Packages, modules, and symlinks have been configured"
            
            # Display GUI applications recommendations
            Write-Host ""
            Write-Header "Recommended GUI Applications"
            
            $GuiAppsFile = Join-Path $DotfilesDir "packages\gui-apps.txt"
            if (Test-Path $GuiAppsFile) {
                Write-Info "Consider installing these GUI applications:"
                Write-Host ""
                
                Get-Content $GuiAppsFile | ForEach-Object {
                    $line = $_.Trim()
                    # Skip empty lines and comments
                    if ($line -and -not $line.StartsWith("#")) {
                        $parts = $line -split '\|'
                        if ($parts.Count -eq 3) {
                            $app = $parts[0].Trim()
                            $description = $parts[1].Trim()
                            $installCmd = $parts[2].Trim()
                            
                            Write-Host "  • " -NoNewline -ForegroundColor Cyan
                            Write-Host "$app" -NoNewline -ForegroundColor Yellow
                            Write-Host " - $description" -ForegroundColor White
                            Write-Host "    Install: " -NoNewline -ForegroundColor DarkGray
                            Write-Host "$installCmd" -ForegroundColor DarkGray
                        }
                    }
                }
                
                Write-Host ""
                Write-Info "To see this list again, run: dot gui-apps"
            } else {
                Write-Warning-Custom "GUI apps list not found at $GuiAppsFile"
            }
        } else {
            Write-Error-Custom "Windows setup failed"
            exit 1
        }
    }
    
    "update" {
        Write-Header "Updating dotfiles"
        
        # Pull latest changes
        Write-Info "Pulling latest changes..."
        Push-Location $DotfilesDir
        try {
            git pull
            Write-Success "Repository updated"
        } catch {
            Write-Error-Custom "Failed to update repository: $_"
            Pop-Location
            exit 1
        }
        Pop-Location
        
        # Update Scoop packages
        if (Get-Command scoop -ErrorAction SilentlyContinue) {
            $response = Read-Host "Update Scoop packages? (Y/n)"
            if ($response -eq "" -or $response -match "^[Yy]") {
                Write-Info "Updating Scoop packages..."
                scoop update
                scoop update *
                Write-Success "Scoop packages updated"
            }
        }
        
        # Update PowerShell modules
        $response = Read-Host "Update PowerShell modules? (Y/n)"
        if ($response -eq "" -or $response -match "^[Yy]") {
            Write-Info "Updating PowerShell modules..."
            try {
                Update-Module -AcceptLicense -Scope CurrentUser
                Write-Success "PowerShell modules updated"
            } catch {
                Write-Warning-Custom "Some modules failed to update: $_"
            }
        }
        
        # Update mise
        if (Get-Command mise -ErrorAction SilentlyContinue) {
            $response = Read-Host "Update mise and runtimes? (y/N)"
            if ($response -match "^[Yy]") {
                Write-Info "Updating mise..."
                if (Get-Command scoop -ErrorAction SilentlyContinue) {
                    scoop update mise
                }
                
                Write-Info "Upgrading mise-managed runtimes..."
                mise upgrade
                Write-Success "Mise updated"
            }
        }
        
        Write-Info "Note: Re-stowing dotfiles should be done from WSL"
        Write-Info "Run 'dot update' from WSL to update symlinks"
    }
    
    "doctor" {
        Write-Header "Running diagnostics"
        Write-Info "Environment: Windows"
        Write-Info "Dotfiles dir: $DotfilesDir"
        
        $issues = 0
        
        # Check Scoop
        if (Get-Command scoop -ErrorAction SilentlyContinue) {
            Write-Success "Scoop installed"
            $scoopVersion = scoop --version
            Write-Info "  Version: $scoopVersion"
        } else {
            Write-Error-Custom "Scoop not installed"
            Write-Info "  Install: irm get.scoop.sh | iex"
            $issues++
        }
        
        # Check key tools
        $tools = @("git", "nvim", "mise", "starship", "docker", "lazydocker", "lazygit", "yazi", "cascadia-code")
        foreach ($tool in $tools) {
            if (Get-Command $tool -ErrorAction SilentlyContinue) {
                Write-Success "$tool is available"
            } else {
                Write-Warning-Custom "$tool not installed (install via Scoop)"
            }
        }
        
        # Check PowerShell modules
        Write-Info "Checking PowerShell modules..."
        $modules = @("PSReadLine", "PSFzf", "Terminal-Icons")
        foreach ($module in $modules) {
            if (Get-Module -ListAvailable -Name $module) {
                Write-Success "$module module installed"
            } else {
                Write-Warning-Custom "$module module not installed"
            }
        }
        
        # Check mise installations
        Write-Info "Checking mise installations..."
        if (Get-Command mise -ErrorAction SilentlyContinue) {
            Write-Success "mise is available"
            $miseVersion = mise --version
            Write-Info "  Version: $miseVersion"
            
            $runtimes = mise list 2>$null
            if ($runtimes) {
                Write-Info "  Installed runtimes:"
                $runtimes | ForEach-Object {
                    if ($_.Trim()) {
                        Write-Info "    $_"
                    }
                }
            } else {
                Write-Info "  No runtimes installed yet (use 'mise install')"
            }
        } else {
            Write-Warning-Custom "mise not installed"
        }
        
        # Summary
        Write-Host ""
        if ($issues -eq 0) {
            Write-Header "All critical checks passed! ✨"
        } else {
            Write-Header "Found $issues critical issue(s)"
            Write-Info "Run 'dot.ps1 init' to fix"
        }
    }
    
    "init" {
        Write-Warning-Custom "The 'init' command should be run from WSL"
        Write-Info "For Windows setup, use: .\dot.ps1 init"
        Write-Info ""
        Write-Info "To run WSL init:"
        
        if (Get-Command wsl -ErrorAction SilentlyContinue) {
            Write-Info "  wsl -d $WSLDistro -e bash -c 'cd /mnt/c/dev/projects/dotfiles && ./dot init'"
        } else {
            Write-Info "  Run './dot init' from within WSL"
        }
    }
    
    "stow" {
        Write-Warning-Custom "The 'stow' command should be run from WSL"
        Write-Info "Stowing (creating symlinks) requires GNU Stow which runs in WSL"
        Write-Info ""
        Write-Info "To run stow:"
        
        if (Get-Command wsl -ErrorAction SilentlyContinue) {
            Write-Info "  wsl -d $WSLDistro -e bash -c 'cd /mnt/c/dev/projects/dotfiles && ./dot stow'"
        } else {
            Write-Info "  Run './dot stow' from within WSL"
        }
    }
    
    "gui-apps" {
        Write-Header "Recommended GUI Applications for Windows"
        
        $GuiAppsFile = Join-Path $DotfilesDir "packages\gui-apps.txt"
        if (-not (Test-Path $GuiAppsFile)) {
            Write-Error-Custom "GUI apps list not found at $GuiAppsFile"
            exit 1
        }
        
        Write-Info "These GUI applications are recommended for a complete setup:"
        Write-Host ""
        
        $currentCategory = ""
        Get-Content $GuiAppsFile | ForEach-Object {
            $line = $_.Trim()
            
            # Handle category headers (comments that start with "# " followed by non-empty text)
            if ($line -match "^# (.+)") {
                $category = $matches[1]
                if ($category -notmatch "^(Recommended|Format:)") {
                    Write-Host ""
                    Write-Host "  $category" -ForegroundColor Magenta -NoNewline
                    Write-Host ""
                    $currentCategory = $category
                }
            }
            # Skip empty lines and format comments
            elseif (-not $line -or $line.StartsWith("#")) {
                # Skip
            }
            # Handle app entries
            else {
                $parts = $line -split '\|'
                if ($parts.Count -eq 3) {
                    $app = $parts[0].Trim()
                    $description = $parts[1].Trim()
                    $installCmd = $parts[2].Trim()
                    
                    Write-Host "    • " -NoNewline -ForegroundColor Cyan
                    Write-Host "$app" -NoNewline -ForegroundColor Yellow
                    Write-Host " - $description" -ForegroundColor White
                    Write-Host "      " -NoNewline
                    Write-Host "$installCmd" -ForegroundColor DarkGray
                }
            }
        }
        
        Write-Host ""
        Write-Info "Install individual apps as needed using the commands above"
        Write-Info "Or install multiple at once: scoop install app1 app2 app3"
    }
    
    "validate" {
        Write-Header "Validating package sync between WSL and Windows"
        
        $ScoopFile = Join-Path $DotfilesDir "packages\scoopfile.json"
        $BundleFile = Join-Path $DotfilesDir "packages\bundle"
        
        $issues = 0
        
        if (Test-Path $ScoopFile) {
            $ScoopConfig = Get-Content $ScoopFile | ConvertFrom-Json
            $scoopApps = $ScoopConfig.apps | ForEach-Object { $_.name }
        } else {
            Write-Error-Custom "Scoopfile not found"
            $issues++
        }
        
        if (Test-Path $BundleFile) {
            $brewApps = @()
            Get-Content $BundleFile | ForEach-Object {
                if ($_ -match 'brew\s+"([^"]+)"') {
                    $brewApps += $matches[1]
                }
            }
        } else {
            Write-Error-Custom "Bundle file not found"
            $issues++
        }
        
        if ($issues -eq 0) {
            Write-Info "Comparing packages..."
            Write-Host ""
            
            $commonTools = @("git", "gh", "nvim", "fzf", "ripgrep", "fd", "jq", "zoxide", "mise", "lsd", "yazi", "starship", "lazygit", "lazydocker")
            
            Write-Info "Checking common tools availability:"
            foreach ($tool in $commonTools) {
                $inScoop = $scoopApps -contains $tool
                $inBrew = $brewApps -contains $tool
                $installed = Get-Command $tool -ErrorAction SilentlyContinue
                
                if ($inScoop -and $inBrew) {
                    $status = if ($installed) { "installed" } else { "NOT installed" }
                    Write-Success "$tool - in both manifests ($status)"
                } elseif ($inScoop -or $inBrew) {
                    $where = if ($inScoop) { "Scoop only" } else { "Brew only" }
                    Write-Warning-Custom "$tool - $where"
                }
            }
            
            Write-Host ""
            Write-Header "Validation complete"
        }
    }
    
    "backup" {
        Write-Header "Backing up current configurations"
        
        $backupDir = Join-Path $DotfilesDir "backups\$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        
        $configsToBackup = @(
            @{ Path = "$HOME\.gitconfig"; Name = "gitconfig" },
            @{ Path = "$HOME\.config\git\config"; Name = "git-config" },
            @{ Path = "$HOME\AppData\Local\nvim"; Name = "nvim" },
            @{ Path = "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"; Name = "powershell-profile" }
        )
        
        $backedUp = 0
        foreach ($config in $configsToBackup) {
            if (Test-Path $config.Path) {
                if (-not (Test-Path $backupDir)) {
                    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
                }
                
                $dest = Join-Path $backupDir $config.Name
                Write-Info "Backing up $($config.Name)..."
                
                try {
                    if (Test-Path -PathType Leaf $config.Path) {
                        Copy-Item $config.Path $dest -Force
                    } else {
                        Copy-Item $config.Path $dest -Recurse -Force
                    }
                    $backedUp++
                    Write-Success "Backed up $($config.Name)"
                } catch {
                    Write-Error-Custom "Failed to backup $($config.Name): $_"
                }
            }
        }
        
        if ($backedUp -gt 0) {
            Write-Header "Backup complete: $backedUp items saved to $backupDir"
        } else {
            Write-Info "No existing configs found to backup"
        }
    }
    
    "edit" {
        $configPath = if ($Arguments.Count -gt 0) {
            $config = $Arguments[0].ToLower()
            switch ($config) {
                "git" { Join-Path $DotfilesDir "home\.config\git\config" }
                "nvim" { Join-Path $DotfilesDir "home\.config\nvim\init.lua" }
                "zsh" { Join-Path $DotfilesDir "home\.config\zsh\.zshrc" }
                "ps" { Join-Path $DotfilesDir "home\.config\powershell\profile.ps1" }
                "starship" { Join-Path $DotfilesDir "home\.config\starship.toml" }
                "tmux" { Join-Path $DotfilesDir "home\.config\tmux\tmux.conf" }
                "mise" { Join-Path $DotfilesDir "home\.mise.toml" }
                "aliases" { Join-Path $DotfilesDir "home\.config\zsh\aliases.zsh" }
                default { 
                    Write-Error-Custom "Unknown config: $config"
                    Write-Info "Available: git, nvim, zsh, ps, starship, tmux, mise, aliases"
                    exit 1
                }
            }
        } else {
            Write-Info "Available configs to edit:"
            Write-Host "  git      - Git configuration"
            Write-Host "  nvim     - Neovim configuration"
            Write-Host "  zsh      - Zsh configuration"
            Write-Host "  ps       - PowerShell profile"
            Write-Host "  starship - Starship prompt"
            Write-Host "  tmux     - Tmux configuration"
            Write-Host "  mise     - Mise configuration"
            Write-Host "  aliases  - Zsh aliases"
            Write-Host ""
            Write-Info "Usage: .\dot.ps1 edit <config>"
            exit 0
        }
        
        if (Test-Path $configPath) {
            $editor = if (Get-Command nvim -ErrorAction SilentlyContinue) { "nvim" }
                      elseif (Get-Command code -ErrorAction SilentlyContinue) { "code" }
                      else { "notepad" }
            
            Write-Info "Opening $configPath with $editor..."
            & $editor $configPath
        } else {
            Write-Error-Custom "Config file not found: $configPath"
            exit 1
        }
    }
    
    "help" {
        Write-Host @"

DOTFILES MANAGEMENT (PowerShell Wrapper)

USAGE:
    .\dot.ps1 <command> [options]

COMMANDS:
    init              Initialize Windows-side configuration
    update            Update dotfiles and Windows packages
    doctor            Run diagnostics for Windows environment
    gui-apps          Show recommended GUI applications
    validate          Check package sync between WSL and Windows
    backup            Backup current configurations
    edit <config>     Open a config file for editing
    help              Show this help message
    
    init              WSL command (run from WSL instead)
    stow              WSL command (run from WSL instead)

WINDOWS COMMANDS:
    .\dot.ps1 init      # Setup Windows packages and configs
    .\dot.ps1 update    # Update Scoop packages and PowerShell modules
    .\dot.ps1 doctor    # Check Windows environment
    .\dot.ps1 validate  # Check WSL/Windows package sync
    .\dot.ps1 backup    # Backup current configs
    .\dot.ps1 edit git  # Edit git config

WSL COMMANDS (run from WSL):
    ./dot init          # Initialize WSL environment
    ./dot update        # Update Homebrew and re-stow configs
    ./dot stow          # Create/update symlinks

EXAMPLES:
    # Windows setup
    .\dot.ps1 init

    # Check everything is installed
    .\dot.ps1 doctor

    # Update packages
    .\dot.ps1 update

    # Edit a config file
    .\dot.ps1 edit nvim

    # Run WSL commands from PowerShell
    wsl -e bash -c 'cd /mnt/c/dev/projects/dotfiles && ./dot init'

For more information, see README.md

"@ -ForegroundColor White
    }
    
    default {
        Write-Error-Custom "Unknown command: $Command"
        Write-Info "Run '.\dot.ps1 help' for usage information"
        exit 1
    }
}
