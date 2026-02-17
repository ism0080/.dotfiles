#!/usr/bin/env pwsh
# PowerShell script to create Windows symlinks to WSL configs
# Run as Administrator: .\setup-windows-links.ps1

param(
    [string]$WslDistro = "Ubuntu"
)

Write-Host "Setting up Windows symlinks to WSL configs..." -ForegroundColor Cyan
Write-Host ""

# Get WSL home directory
$wslHome = wsl -d $WslDistro -e bash -c "echo `$HOME" 2>$null
if (-not $wslHome) {
    Write-Host "Error: Could not detect WSL home directory" -ForegroundColor Red
    Write-Host "Make sure WSL is installed and $WslDistro distribution exists" -ForegroundColor Yellow
    exit 1
}

$wslHome = $wslHome.Trim()
$wslPath = "\\wsl$\$WslDistro$wslHome"
Write-Host "WSL Home: $wslPath" -ForegroundColor Green

$windowsHome = $env:USERPROFILE

# Configs to link
$configsToLink = @(
    @{Name="Git Config"; Source=".config/git/config"; Target=".gitconfig"},
    @{Name="Neovim"; Source=".config/nvim"; Target="AppData/Local/nvim"},
    @{Name="PowerShell"; Source=".config/powershell/profile.ps1"; Target="Documents/PowerShell/Microsoft.PowerShell_profile.ps1"}
)

foreach ($config in $configsToLink) {
    $sourcePath = Join-Path $wslPath $config.Source
    $targetPath = Join-Path $windowsHome $config.Target
    
    Write-Host ""
    Write-Host "Processing $($config.Name)..." -ForegroundColor Yellow
    Write-Host "  Source: $sourcePath"
    Write-Host "  Target: $targetPath"
    
    # Check if source exists
    if (-not (Test-Path $sourcePath)) {
        Write-Host "  ⚠ Source not found, skipping" -ForegroundColor Yellow
        continue
    }
    
    # Check if target already exists
    if (Test-Path $targetPath) {
        if ((Get-Item $targetPath).LinkType -eq "SymbolicLink") {
            Write-Host "  ✓ Symlink already exists" -ForegroundColor Green
        } else {
            Write-Host "  ⚠ Target exists but is not a symlink" -ForegroundColor Yellow
            Write-Host "    Please backup and remove: $targetPath"
        }
        continue
    }
    
    # Create parent directory if needed
    $targetParent = Split-Path $targetPath -Parent
    if (-not (Test-Path $targetParent)) {
        New-Item -ItemType Directory -Path $targetParent -Force | Out-Null
        Write-Host "  ✓ Created parent directory" -ForegroundColor Green
    }
    
    # Create symlink (requires admin)
    try {
        New-Item -ItemType SymbolicLink -Path $targetPath -Target $sourcePath -Force | Out-Null
        Write-Host "  ✓ Created symlink" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ Failed to create symlink: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "    Make sure you're running as Administrator" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Setup complete!" -ForegroundColor Cyan
Write-Host ""
Write-Host "Note: Shared configurations are now linked between WSL and Windows:" -ForegroundColor Yellow
Write-Host "  1. Git config (~/.gitconfig)" -ForegroundColor Gray
Write-Host "  2. Neovim config (~/AppData/Local/nvim/)" -ForegroundColor Gray
Write-Host "  3. PowerShell profile (~/Documents/PowerShell/Microsoft.PowerShell_profile.ps1)" -ForegroundColor Gray
Write-Host ""
Write-Host "Install required tools via Scoop if not already installed:" -ForegroundColor Yellow
Write-Host "  scoop install git neovim pwsh starship" -ForegroundColor Gray
Write-Host ""
