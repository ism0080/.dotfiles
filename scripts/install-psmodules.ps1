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

# Read modules list, skip blanks and comments
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

# Ensure NuGet provider is available
if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
    Write-Host "Installing NuGet package provider..." -ForegroundColor Cyan
    try {
        Install-PackageProvider -Name NuGet -Force -Scope CurrentUser -ErrorAction Stop
        Write-Host "  ✓ NuGet provider installed" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ Failed to install NuGet provider: $_" -ForegroundColor Red
        exit 1
    }
}

# Helper function for module install/update
function Ensure-Module {
    param(
        [string]$ModuleName,
        [switch]$Force,
        [bool]$IsAdmin
    )

    $scope = if ($IsAdmin) { "AllUsers" } else { "CurrentUser" }

    if (Get-Module -ListAvailable -Name $ModuleName) {
        if ($Force) {
            Write-Host "  Updating $ModuleName..." -ForegroundColor Yellow
            Update-Module -Name $ModuleName -Force -ErrorAction Stop
        } else {
            Write-Host "  ✓ $ModuleName already installed (use -Force to update)" -ForegroundColor Green
        }
    } else {
        Write-Host "  Installing $ModuleName..." -ForegroundColor Yellow
        Install-Module -Name $ModuleName -Scope $scope -Force -AllowClobber -ErrorAction Stop
    }
}

# Install/update each module
foreach ($Module in $Modules) {
    Write-Host "Processing $Module..." -ForegroundColor Cyan
    try {
        Ensure-Module -ModuleName $Module -Force:$Force -IsAdmin:$IsAdmin
        Write-Host "  ✓ $Module installed/updated" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ Failed to install/update ${Module}: $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "PowerShell modules installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Reload your PowerShell profile: . `$PROFILE"
Write-Host "  2. Or restart PowerShell"
Write-Host ""
