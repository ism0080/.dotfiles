# Install PowerShell Modules for dotfiles
# Run this script to install PowerShell modules required by the profile
# Usage: .\scripts\install-psmodules.ps1

[CmdletBinding()]
param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

Write-Host "Installing PowerShell modules for dotfiles..." -ForegroundColor Cyan
Write-Host ""

# Path to modules list
$ModulesFile = Join-Path (Split-Path $PSScriptRoot -Parent) "packages\psmodules.txt"

if (-not (Test-Path $ModulesFile)) {
    Write-Host "Error: Could not find $ModulesFile" -ForegroundColor Red
    exit 1
}

# Read modules list
$Modules = Get-Content $ModulesFile | Where-Object { 
    $_.Trim() -ne "" -and -not $_.StartsWith("#") 
}

Write-Host "Modules to install:" -ForegroundColor Green
$Modules | ForEach-Object { Write-Host "  - $_" }
Write-Host ""

# Check if running as admin (recommended but not required)
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $IsAdmin) {
    Write-Host "Note: Not running as administrator. Modules will be installed for current user only." -ForegroundColor Yellow
    Write-Host ""
}

# Install each module
foreach ($Module in $Modules) {
    Write-Host "Checking $Module..." -ForegroundColor Cyan
    
    if (Get-Module -ListAvailable -Name $Module) {
        if ($Force) {
            Write-Host "  Updating $Module..." -ForegroundColor Yellow
            try {
                Update-Module -Name $Module -Force -ErrorAction Stop
                Write-Host "  ✓ Updated $Module" -ForegroundColor Green
            } catch {
                Write-Host "  ⚠ Could not update $Module: $_" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  ✓ $Module already installed (use -Force to update)" -ForegroundColor Green
        }
    } else {
        Write-Host "  Installing $Module..." -ForegroundColor Yellow
        try {
            if ($IsAdmin) {
                Install-Module -Name $Module -Scope AllUsers -Force -AllowClobber
            } else {
                Install-Module -Name $Module -Scope CurrentUser -Force -AllowClobber
            }
            Write-Host "  ✓ Installed $Module" -ForegroundColor Green
        } catch {
            Write-Host "  ✗ Failed to install $Module: $_" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "PowerShell modules installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Reload your PowerShell profile: . `$PROFILE"
Write-Host "  2. Or restart PowerShell"
Write-Host ""
