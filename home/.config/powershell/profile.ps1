# PowerShell Profile Configuration
# Works with both Windows PowerShell and PowerShell Core

# Environment variables
$env:EDITOR = "nvim"
$env:VISUAL = "nvim"

# PSReadLine configuration for better command line editing
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine
    Set-PSReadLineOption -EditMode Emacs
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
}

# Starship prompt (if installed)
if (Get-Command starship -ErrorAction SilentlyContinue) {
    $ENV:STARSHIP_CONFIG = "$HOME\.config\starship.toml"
    Invoke-Expression (&starship init powershell)
}

# Zoxide (if installed)
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# FNM - Fast Node Manager (if installed)
if (Get-Command fnm -ErrorAction SilentlyContinue) {
    fnm env --use-on-cd | Out-String | Invoke-Expression
}

# Aliases
# Git
function g { git @args }
function gs { git status @args }
function ga { git add @args }
function gc { git commit @args }
function gp { git push @args }
function gl { git pull @args }
function gco { git checkout @args }
function gd { git diff @args }
function glog { git log --oneline --graph --decorate @args }

# Navigation
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }

# List with color (using modern tools if available)
if (Get-Command eza -ErrorAction SilentlyContinue) {
    function ls { eza @args }
    function la { eza -la @args }
    function ll { eza -l @args }
    function tree { eza --tree @args }
} else {
    function la { Get-ChildItem -Force @args }
    function ll { Get-ChildItem @args }
}

# Neovim
function n { nvim @args }
function vim { nvim @args }

# Dotfiles
function dots { Set-Location ~/.dotfiles }

# WSL integration
function wsl-home { Set-Location \\wsl$\Ubuntu\home\$env:USERNAME }
function wsl { wsl.exe @args }

# Better directory listing
function which($command) {
    Get-Command -Name $command -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

# Quick edit of profile
function Edit-Profile { nvim $PROFILE.CurrentUserAllHosts }
Set-Alias -Name ep -Value Edit-Profile

# Reload profile
function Reload-Profile {
    @(
        $PROFILE.AllUsersAllHosts,
        $PROFILE.AllUsersCurrentHost,
        $PROFILE.CurrentUserAllHosts,
        $PROFILE.CurrentUserCurrentHost
    ) | ForEach-Object {
        if (Test-Path $_) {
            Write-Verbose "Running $_"
            . $_
        }
    }
}
Set-Alias -Name rp -Value Reload-Profile

# Compute file hashes
function md5 { Get-FileHash -Algorithm MD5 $args }
function sha1 { Get-FileHash -Algorithm SHA1 $args }
function sha256 { Get-FileHash -Algorithm SHA256 $args }

# Better defaults
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['Export-Csv:NoTypeInformation'] = $true

# Color output
$PSStyle.FileInfo.Directory = "`e[34;1m"  # Blue and bold

# Load local customizations if they exist
$LocalProfile = Join-Path (Split-Path $PROFILE.CurrentUserAllHosts) "profile.local.ps1"
if (Test-Path $LocalProfile) {
    . $LocalProfile
}

# Welcome message
Write-Host "PowerShell $($PSVersionTable.PSVersion) on $($PSVersionTable.OS)" -ForegroundColor Cyan
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Write-Host "✓ Starship prompt loaded" -ForegroundColor Green
}
