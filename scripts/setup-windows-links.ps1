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
    @{Name="Git Config"; Source=".config/git/config"; Target="~/.gitconfig"},
    @{Name="Neovim"; Source=".config/nvim"; Target="AppData/Local/nvim"},
    @{Name="Opencode"; Source=".config/opencode"; Target="~/.config/opencode"},
    @{Name="PowerShell"; Source=".config/powershell/profile.ps1"; Target="Documents/PowerShell/Microsoft.PowerShell_profile.ps1"}
)

# Create backup directory
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupDir = Join-Path (Split-Path $PSScriptRoot -Parent) "backups\windows_$timestamp"
$filesToBackup = @()

# First pass: check for conflicts
foreach ($config in $configsToLink) {
    $targetPath = Join-Path $windowsHome $config.Target
    
    if (Test-Path $targetPath) {
        $item = Get-Item $targetPath
        if ($item.LinkType -ne "SymbolicLink") {
            $filesToBackup += @{
                Config = $config
                TargetPath = $targetPath
            }
        }
    }
}

# If there are files to backup, prompt user
if ($filesToBackup.Count -gt 0) {
    Write-Host ""
    Write-Host "⚠ The following files will be replaced:" -ForegroundColor Yellow
    foreach ($item in $filesToBackup) {
        Write-Host "  $($item.TargetPath)" -ForegroundColor Gray
    }
    Write-Host ""
    
    $response = Read-Host "Create backups of existing files? [Y/n]"
    if ($response -eq "" -or $response -match "^[Yy]") {
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
        
        foreach ($item in $filesToBackup) {
            $relativePath = $item.Config.Target -replace "^~/", ""
            $backupPath = Join-Path $backupDir $relativePath
            $backupParent = Split-Path $backupPath -Parent
            
            if ($backupParent -and -not (Test-Path $backupParent)) {
                New-Item -ItemType Directory -Path $backupParent -Force | Out-Null
            }
            
            try {
                Copy-Item -Path $item.TargetPath -Destination $backupPath -Recurse -Force
                Write-Host "  ✓ Backed up: $($item.Config.Name)" -ForegroundColor Green
            } catch {
                Write-Host "  ✗ Failed to backup $($item.Config.Name): $($_.Exception.Message)" -ForegroundColor Red
                exit 1
            }
        }
        
        Write-Host ""
        Write-Host "✓ Backups created in: $backupDir" -ForegroundColor Green
    }
}

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
            continue
        } else {
            # Remove existing file/directory to replace with symlink
            Remove-Item -Path $targetPath -Recurse -Force
            Write-Host "  ✓ Removed existing file/directory" -ForegroundColor Green
        }
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
