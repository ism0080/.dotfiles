# PowerShell Profile Configuration
# Works with both Windows PowerShell and PowerShell Core

# Environment variables
$env:EDITOR = "nvim"
$env:VISUAL = "nvim"
$env:GH_DASH_CONFIG = "$HOME\.gh\dash\config.yml"

Set-Alias grep findstr

# PSReadLine configuration for better command line editing
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine
    Set-PSReadLineOption -EditMode Windows
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

# Mise - Modern runtime version manager (if installed)
if (Get-Command mise -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (mise activate powershell | Out-String) })
}

# FZF Integration (if PSFzf module is available)
if (Get-Module -ListAvailable -Name PSFzf) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'
    Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
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
if (Get-Command lsd -ErrorAction SilentlyContinue) {
    Set-Alias ls lsd
    Set-Alias l lsd
    function ll { lsd -l @args }
    function la { lsd -la @args }
    function tree { lsd --tree @args }
} elseif (Get-Command eza -ErrorAction SilentlyContinue) {
    function ls { eza @args }
    function la { eza -la @args }
    function ll { eza -l @args }
    function tree { eza --tree @args }
} else {
    function la { Get-ChildItem -Force @args }
    function ll { Get-ChildItem @args }
}

# Neovim
Set-Alias n nvim
function vim { nvim @args }

# LazyGit and LazyDocker
if (Get-Command lazygit -ErrorAction SilentlyContinue) {
    Set-Alias lg lazygit
}
if (Get-Command lazydocker -ErrorAction SilentlyContinue) {
    Set-Alias ld lazydocker
}

# Dotfiles
function dots { Set-Location ~/.dotfiles }

# Common directories
function dev { Set-Location "C:\dev" }
function home { Set-Location $HOME }
function profile { nvim $PROFILE }

# WSL integration
function wsl-home { Set-Location \\wsl$\Ubuntu\home\$env:USERNAME }
function wsl { wsl.exe @args }

# Utility functions
function rmf { Remove-Item -Recurse -Force @args }
function reload { . $PROFILE }

# Network utilities
function myip { curl 'https://api.ipify.org' }
function weather { curl 'wttr.in' }

# Better directory listing
function which($command) {
    Get-Command -Name $command -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

# Yazi file manager integration
function yy {
    $tmp = [System.IO.Path]::GetTempFileName()
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        Set-Location -LiteralPath $cwd
    }
    Remove-Item -Path $tmp
}

# FZF helper functions (if FZF is available)
if (Get-Command fzf -ErrorAction SilentlyContinue) {
    # Interactive cd to directory
    function icd {
        Get-ChildItem . -Recurse -Attributes Directory -Depth 10 | Where-Object {
            $folder = $_
            $pathParts = $folder.FullName -split '\\'
            -not ($pathParts | Where-Object { $_ -eq 'node_modules' -or $_.StartsWith('.') })
        } | Invoke-Fzf | Set-Location
    }

    # Open directory in VS Code
    function icode {
        Get-ChildItem . -Recurse -Attributes Directory -Depth 10 |
            Where-Object { $_.FullName -notmatch "\\node_modules\\" } |
            Invoke-Fzf | ForEach-Object { code $_ }
    }

    # Open file in nvim
    function inv {
        Get-ChildItem . -Recurse -Attributes !Directory -Depth 10 |
            Where-Object { $_.FullName -notmatch "\\node_modules\\" } |
            Invoke-Fzf | ForEach-Object { nvim $_ }
    }
}

# Prune local git branches (keeps main, master, develop, and release branches)
function prune_branches {
    git branch |
    ForEach-Object { $_.Trim().Replace('* ', '') } |
    Where-Object { $_ -and ($_ -notin @('master','main','develop')) } |
    Where-Object { $_ -notmatch '^release' } |
    ForEach-Object { git branch -D $_ }
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
Set-Alias -Name reload -Value Reload-Profile

function vs {
	param (
		[Parameter(Mandatory = $true)]
		[ValidateSet('19', '22')]
		[string]$Version
	)
	$2022 = "C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\IDE\devenv.exe"
	$2019 = "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\Common7\IDE\devenv.exe"
	$slnPath = Get-ChildItem -Filter *.sln | Select-Object -ExpandProperty FullName
	if ($Version -eq '22') {
		& $2022 $slnPath
	} elseif ($Version -eq '19') {
		& $2019 $slnPath
	}
}

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
