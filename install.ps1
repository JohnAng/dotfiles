# @docstring
# Cross-platform installer — Windows side.
# Offers 3 options: Windows-native only / WSL2 only / Both.
# Auto-detects platform and gives sensible defaults.

$ErrorActionPreference = 'Stop'

# ============================================================
# 0) Platform sanity checks
# ============================================================
if ($env:WSL_DISTRO_NAME) {
    Write-Host "x You are inside WSL. Run install.sh here instead." -ForegroundColor Red
    exit 1
}
if ($PSVersionTable.PSVersion.Major -ge 6 -and -not $IsWindows) {
    Write-Host "x Not running on Windows (PowerShell Core on another OS)." -ForegroundColor Red
    exit 1
}

$DotfilesDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$WindowsDir  = Join-Path $DotfilesDir 'windows'
$HomeDir     = Join-Path $DotfilesDir 'home'

function Log($msg)  { Write-Host "> $msg" -ForegroundColor Blue }
function OK($msg)   { Write-Host "v $msg" -ForegroundColor Green }
function Warn($msg) { Write-Host "! $msg" -ForegroundColor Yellow }
function Err($msg)  { Write-Host "x $msg" -ForegroundColor Red }

# ============================================================
# 1) Menu
# ============================================================
Write-Host ""
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "  Dev Environment - Predawn Cross-Platform Installer  " -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "What do you want to install?"
Write-Host "  [1] Windows-native only (Neovim, Starship, CLI tools, WT, PS profile)"
Write-Host "  [2] WSL2 Ubuntu only (zsh, tmux, nvim inside WSL - via install.sh)"
Write-Host "  [3] Both - full parity (recommended)" -ForegroundColor Green
Write-Host ""

do { $choice = Read-Host "Choice [1/2/3]" } while ($choice -notin '1','2','3')

$installWindows = $choice -in '1','3'
$installWSL     = $choice -in '2','3'

# ============================================================
# 2) WINDOWS NATIVE INSTALL
# ============================================================
if ($installWindows) {
    Log "=== WINDOWS NATIVE ==="

    # 2a) winget packages
    $packages = @(
        'Neovim.Neovim',
        'Starship.Starship',
        'BurntSushi.ripgrep.MSVC',
        'sharkdp.fd',
        'junegunn.fzf',
        'ajeetdsouza.zoxide',
        'JesseDuffield.lazygit',
        'eza-community.eza',
        'Git.Git'
    )
    foreach ($pkg in $packages) {
        Log "winget install $pkg"
        winget install --id $pkg --silent --accept-source-agreements --accept-package-agreements 2>&1 |
            Where-Object { $_ -notmatch 'already installed|No available upgrade' } | Out-Host
    }

    # 2b) JetBrainsMono Nerd Font
    $fontsPath = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
    if (-not (Get-ChildItem $fontsPath -Filter "JetBrainsMonoNerdFont-*" -ErrorAction SilentlyContinue)) {
        Log "Downloading & installing JetBrainsMono Nerd Font..."
        $url = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
        $tmp = "$env:TEMP\JetBrainsMono.zip"
        $ext = "$env:TEMP\JetBrainsMono"
        Invoke-WebRequest -Uri $url -OutFile $tmp
        Expand-Archive -Path $tmp -DestinationPath $ext -Force
        $shell = New-Object -ComObject Shell.Application
        Get-ChildItem $ext -Filter "*.ttf" | ForEach-Object {
            $shell.Namespace(0x14).CopyHere($_.FullName, 0x10)
        }
        Remove-Item $tmp, $ext -Recurse -Force
        OK "Font installed (requires new tab/reboot for apps to see)"
    } else {
        OK "JetBrainsMono Nerd Font already installed"
    }

    # 2c) Neovim config — Junction to dotfiles (no admin required)
    $nvimTarget = "$env:LOCALAPPDATA\nvim"
    $nvimSrc    = Join-Path $HomeDir '.config\nvim'
    if (Test-Path $nvimTarget) {
        $item = Get-Item $nvimTarget -Force
        $isReparse = $item.Attributes -band [System.IO.FileAttributes]::ReparsePoint
        if (-not $isReparse) {
            $backup = "$nvimTarget.pre-dotfiles.$(Get-Date -Format 'yyyyMMddHHmmss')"
            Move-Item $nvimTarget $backup
            Warn "Backed up existing nvim -> $backup"
        } else {
            (Get-Item $nvimTarget).Delete()
        }
    }
    New-Item -ItemType Junction -Path $nvimTarget -Target $nvimSrc | Out-Null
    OK "nvim junction: $nvimTarget -> $nvimSrc"

    # 2d) Starship config — copy to local Windows path (~/.config/starship.toml)
    $starshipDir = "$env:USERPROFILE\.config"
    if (-not (Test-Path $starshipDir)) { New-Item -ItemType Directory -Path $starshipDir | Out-Null }
    Copy-Item (Join-Path $HomeDir '.config\starship.toml') "$starshipDir\starship.toml" -Force
    OK "starship.toml -> $starshipDir\starship.toml"

    # 2e) PowerShell profile
    $profileTarget = $PROFILE.CurrentUserCurrentHost
    $profileSrc    = Join-Path $WindowsDir 'Microsoft.PowerShell_profile.ps1'
    $profileParent = Split-Path -Parent $profileTarget
    if (-not (Test-Path $profileParent)) { New-Item -ItemType Directory -Path $profileParent -Force | Out-Null }
    if (Test-Path $profileTarget) {
        Copy-Item $profileTarget "$profileTarget.pre-dotfiles.$(Get-Date -Format 'yyyyMMddHHmmss')"
        Warn "Backed up existing PS profile"
    }
    Copy-Item $profileSrc $profileTarget -Force
    OK "PowerShell profile -> $profileTarget"

    # 2f) Windows Terminal settings
    $wtSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    if (Test-Path (Split-Path -Parent $wtSettings)) {
        if (Test-Path $wtSettings) {
            Copy-Item $wtSettings "$wtSettings.pre-dotfiles.$(Get-Date -Format 'yyyyMMddHHmmss')"
        }
        Copy-Item (Join-Path $WindowsDir 'windows-terminal-settings.json') $wtSettings -Force
        OK "Windows Terminal settings installed"
    } else {
        Warn "Windows Terminal does not appear to be installed - skipping settings"
    }

    # 2g) PSFzf module (fzf keybindings in PowerShell)
    if (-not (Get-Module -ListAvailable -Name PSFzf)) {
        Log "Installing PSFzf module for fzf keybindings..."
        Try {
            Install-Module -Name PSFzf -Scope CurrentUser -Force -AcceptLicense -ErrorAction Stop
            OK "PSFzf installed"
        } Catch {
            Warn "PSFzf install skipped: $_"
        }
    }

    OK "Windows install complete"
    Write-Host ""
}

# ============================================================
# 3) WSL2 INSTALL
# ============================================================
if ($installWSL) {
    Log "=== WSL2 ==="

    # 3a) Check if Ubuntu-24.04 is already installed
    $hasUbuntu = $false
    Try {
        $wslOut = (wsl --list --quiet 2>&1) -replace "`0",''  # strip nulls
        if ($wslOut -match 'Ubuntu-24\.04') { $hasUbuntu = $true }
    } Catch {}

    if (-not $hasUbuntu) {
        Warn "Ubuntu-24.04 not found in WSL. Will install now."
        $confirm = Read-Host "Run 'wsl --install -d Ubuntu-24.04'? [Y/n]"
        if ($confirm -eq '' -or $confirm -match '^[Yy]') {
            wsl --install -d Ubuntu-24.04
            Warn "A REBOOT may be required (WSL kernel download)."
            Write-Host ""
            Write-Host "  After reboot/Ubuntu user setup:" -ForegroundColor Yellow
            Write-Host "     1. Open the 'Ubuntu' app, set UNIX username + password"
            Write-Host "     2. In the Ubuntu terminal:"
            $wslPath = ($DotfilesDir -replace '\\','/' -replace '^([A-Za-z]):','/mnt/$1'.ToLower())
            Write-Host "        cd '$wslPath' && ./install.sh" -ForegroundColor Cyan
            Write-Host ""
            OK "WSL bootstrap prompted. Re-run install.ps1 choosing [1] afterwards if needed."
        } else {
            Warn "WSL install skipped"
        }
    } else {
        OK "Ubuntu-24.04 already present"
        # Ubuntu is installed - run install.sh inside it
        $wslPath = ($DotfilesDir -replace '\\','/' -replace '^C:','/mnt/c' -replace '^D:','/mnt/d')
        Log "Running install.sh inside WSL Ubuntu-24.04..."
        Log "  path (WSL): $wslPath"
        wsl -d Ubuntu-24.04 -- bash -lc "cd '$wslPath' && ./install.sh"
        OK "WSL install complete"
    }
    Write-Host ""
}

# ============================================================
# 4) Final message
# ============================================================
Write-Host "============================================================" -ForegroundColor DarkGray
OK "Installer done."
Write-Host ""
Write-Host "Next steps:"
Write-Host "  - Fully close Windows Terminal and reopen (for fonts + settings.json + actions)"
if ($installWindows) {
    Write-Host "  - New PowerShell tab -> Starship prompt + eza aliases + zoxide"
    Write-Host "  - 'nvim' works natively in PowerShell (same config as WSL)"
}
if ($installWSL) {
    Write-Host "  - In the Ubuntu tab, zsh/tmux/nvim are ready"
    Write-Host "  - Inside tmux, press Prefix+I (Ctrl+A I) for TPM plugin install"
}
