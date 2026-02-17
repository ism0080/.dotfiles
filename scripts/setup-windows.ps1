# Windows Setup Script for Dotfiles
# This script installs Scoop packages and PowerShell modules
# Run this from the dotfiles directory: .\scripts\setup-windows.ps1

[CmdletBinding()]
param(
    [switch]$SkipScoop,
    [switch]$SkipModules,
    [switch]$SkipSymlinks,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Dotfiles Windows Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running from dotfiles directory
$DotfilesRoot = Split-Path $PSScriptRoot -Parent
if (-not (Test-Path (Join-Path $DotfilesRoot "packages"))) {
    Write-Host "Error: Please run this script from the dotfiles directory" -ForegroundColor Red
    exit 1
}

# Check if Scoop is installed
$ScoopInstalled = Get-Command scoop -ErrorAction SilentlyContinue

# Step 1: Install Scoop packages
if (-not $SkipScoop) {
    Write-Host "[1/3] Installing Scoop packages..." -ForegroundColor Cyan
    Write-Host ""
    
    if (-not $ScoopInstalled) {
        Write-Host "Scoop is not installed. Install it first:" -ForegroundColor Yellow
        Write-Host "  irm get.scoop.sh | iex" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Then run this script again." -ForegroundColor Yellow
        exit 1
    }
    
    $ScoopFile = Join-Path $DotfilesRoot "packages\scoopfile.json"
    if (Test-Path $ScoopFile) {
        Write-Host "Installing packages from scoopfile.json..." -ForegroundColor Yellow
        
        # Read and parse scoopfile
        $ScoopConfig = Get-Content $ScoopFile | ConvertFrom-Json
        
        # Add buckets
        Write-Host "Adding buckets..." -ForegroundColor Cyan
        foreach ($bucket in $ScoopConfig.buckets) {
            try {
                scoop bucket add $bucket 2>&1 | Out-Null
                Write-Host "  ✓ Added bucket: $bucket" -ForegroundColor Green
            } catch {
                Write-Host "  ⚠ Bucket $bucket already added or error occurred" -ForegroundColor Yellow
            }
        }
        
        Write-Host ""
        Write-Host "Installing apps..." -ForegroundColor Cyan
        foreach ($app in $ScoopConfig.apps) {
            $appName = $app.name
            Write-Host "  Checking $appName..." -NoNewline
            
            $installed = scoop list $appName 2>&1 | Select-String -Pattern $appName -Quiet
            if ($installed -and -not $Force) {
                Write-Host " already installed" -ForegroundColor Green
            } else {
                try {
                    Write-Host ""
                    scoop install $appName
                    Write-Host "  ✓ Installed $appName" -ForegroundColor Green
                } catch {
                    Write-Host "  ✗ Failed to install $appName" -ForegroundColor Red
                }
            }
        }
    } else {
        Write-Host "Scoopfile not found at $ScoopFile" -ForegroundColor Red
    }
    
    Write-Host ""
} else {
    Write-Host "[1/3] Skipping Scoop packages (--SkipScoop)" -ForegroundColor Yellow
    Write-Host ""
}

# Step 2: Install PowerShell modules
if (-not $SkipModules) {
    Write-Host "[2/3] Installing PowerShell modules..." -ForegroundColor Cyan
    Write-Host ""
    
    $InstallModulesScript = Join-Path $DotfilesRoot "scripts\install-psmodules.ps1"
    if (Test-Path $InstallModulesScript) {
        if ($Force) {
            & $InstallModulesScript -Force
        } else {
            & $InstallModulesScript
        }
    } else {
        Write-Host "install-psmodules.ps1 not found" -ForegroundColor Red
    }
    
    Write-Host ""
} else {
    Write-Host "[2/3] Skipping PowerShell modules (--SkipModules)" -ForegroundColor Yellow
    Write-Host ""
}

# Step 3: Create symlinks
if (-not $SkipSymlinks) {
    Write-Host "[3/3] Creating symlinks..." -ForegroundColor Cyan
    Write-Host ""
    
    # Check if running as admin
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if (-not $IsAdmin) {
        Write-Host "Creating symlinks requires administrator privileges." -ForegroundColor Yellow
        Write-Host "Please run this command in an administrator PowerShell:" -ForegroundColor Yellow
        Write-Host "  .\scripts\setup-windows-links.ps1" -ForegroundColor Cyan
        Write-Host ""
    } else {
        $SymlinkScript = Join-Path $DotfilesRoot "scripts\setup-windows-links.ps1"
        if (Test-Path $SymlinkScript) {
            & $SymlinkScript
        } else {
            Write-Host "setup-windows-links.ps1 not found" -ForegroundColor Red
        }
    }
} else {
    Write-Host "[3/3] Skipping symlinks (--SkipSymlinks)" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Windows Setup Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Green
Write-Host "  1. If you skipped symlinks, run (as Administrator):" -ForegroundColor White
Write-Host "     .\scripts\setup-windows-links.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "  2. Reload your PowerShell profile:" -ForegroundColor White
Write-Host "     . `$PROFILE" -ForegroundColor Cyan
Write-Host ""
Write-Host "  3. Or restart PowerShell" -ForegroundColor White
Write-Host ""
