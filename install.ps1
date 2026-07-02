# @docstring
# Cross-platform installer — Windows side.
# Fault-tolerant, idempotent, with progress reporting and version checks.
# Offers 3 options: Windows-native only / WSL2 only / Both.

# We handle errors per-step. Don't halt the whole run on one failure.
$ErrorActionPreference = 'Continue'
$ProgressPreference    = 'Continue'

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

# ============================================================
# 1) Reporting helpers
# ============================================================
$script:Report = [System.Collections.ArrayList]::new()

function Add-Step {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][ValidateSet('OK','SKIP','UPDATE','FAIL','WARN')][string]$Status,
        [string]$Detail = ''
    )
    $null = $script:Report.Add([PSCustomObject]@{
        Step   = $Name
        Status = $Status
        Detail = $Detail
    })
    $color = switch ($Status) {
        'OK'     { 'Green' }
        'SKIP'   { 'DarkGray' }
        'UPDATE' { 'Yellow' }
        'WARN'   { 'Yellow' }
        'FAIL'   { 'Red' }
    }
    $sym = switch ($Status) {
        'OK'     { 'v' }
        'SKIP'   { '~' }
        'UPDATE' { '^' }
        'WARN'   { '!' }
        'FAIL'   { 'x' }
    }
    $line = "  [$sym] $Name"
    if ($Detail) { $line += " — $Detail" }
    Write-Host $line -ForegroundColor $color
}

function Invoke-Step {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][scriptblock]$Body
    )
    try {
        $result = & $Body
        if ($result -is [hashtable] -and $result.ContainsKey('Status')) {
            Add-Step -Name $Name -Status $result.Status -Detail ($result.Detail ?? '')
        } elseif ($result -is [string] -and $result -in 'OK','SKIP','UPDATE','FAIL','WARN') {
            Add-Step -Name $Name -Status $result
        } else {
            Add-Step -Name $Name -Status 'OK'
        }
    } catch {
        Add-Step -Name $Name -Status 'FAIL' -Detail $_.Exception.Message
    }
}

function Log($msg)     { Write-Host "> $msg" -ForegroundColor Cyan }
function Section($msg) {
    Write-Host ""
    Write-Host "=== $msg ===" -ForegroundColor Magenta
}

# Interactive prompt: ask before applying an available update.
# Supports [Y]es / [N]o / [A]ll (yes to all remaining) / [S]kip all remaining.
$script:UpdatePolicy = 'ASK'   # ASK | ALL | NONE

function Confirm-Update {
    param(
        [string]$Name,
        [string]$FromVer = '',
        [string]$ToVer   = ''
    )
    if ($script:UpdatePolicy -eq 'ALL')  { return $true  }
    if ($script:UpdatePolicy -eq 'NONE') { return $false }

    $ver = if ($FromVer -and $ToVer) { " ($FromVer -> $ToVer)" } elseif ($ToVer) { " (-> $ToVer)" } else { '' }
    Write-Host ""
    Write-Host "^ Update available for $Name$ver" -ForegroundColor Yellow
    do {
        $ans = Read-Host "  Update? [Y]es / [N]o / [A]ll / [S]kip all"
    } while ($ans -notmatch '^[YyNnAaSs]$' -and $ans -ne '')
    if ($ans -eq '') { $ans = 'Y' }
    switch ($ans.ToUpper()) {
        'Y' { return $true  }
        'N' { return $false }
        'A' { $script:UpdatePolicy = 'ALL';  return $true  }
        'S' { $script:UpdatePolicy = 'NONE'; return $false }
    }
}

# ============================================================
# 2) Menu
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
# 3) WINDOWS NATIVE INSTALL
# ============================================================
if ($installWindows) {
    Section "WINDOWS NATIVE"

    # 3a) winget presence
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Add-Step -Name "winget" -Status 'FAIL' -Detail 'winget not found. Install App Installer from Microsoft Store first.'
    } else {

        # 3b) winget packages with per-package version check
        # zig = C compiler used by Neovim treesitter to build parsers on the fly
        #       (without it: "no C compiler found: cc gcc clang cl zig")
        $packages = @(
            @{ Id = 'Neovim.Neovim';              Name = 'Neovim' },
            @{ Id = 'Starship.Starship';          Name = 'Starship' },
            @{ Id = 'BurntSushi.ripgrep.MSVC';    Name = 'ripgrep' },
            @{ Id = 'sharkdp.fd';                 Name = 'fd' },
            @{ Id = 'junegunn.fzf';               Name = 'fzf' },
            @{ Id = 'ajeetdsouza.zoxide';         Name = 'zoxide' },
            @{ Id = 'JesseDuffield.lazygit';      Name = 'lazygit' },
            @{ Id = 'eza-community.eza';          Name = 'eza' },
            @{ Id = 'Git.Git';                    Name = 'Git' },
            @{ Id = 'zig.zig';                    Name = 'zig (treesitter compiler)' }
        )

        $total = $packages.Count
        for ($i = 0; $i -lt $total; $i++) {
            $pkg  = $packages[$i]
            $pct  = [int](($i / $total) * 100)
            Write-Progress -Activity "winget packages" -Status "$($i+1)/$total - $($pkg.Name)" -PercentComplete $pct

            Invoke-Step -Name "winget: $($pkg.Name)" -Body {
                # Is it installed?
                $listOut = winget list --id $pkg.Id --exact --accept-source-agreements 2>&1 | Out-String
                $isInstalled = $listOut -match [regex]::Escape($pkg.Id)

                if ($isInstalled) {
                    # Check if an upgrade is available.
                    $upOut = winget upgrade --id $pkg.Id --exact --accept-source-agreements 2>&1 | Out-String
                    if ($upOut -match [regex]::Escape($pkg.Id) -and $upOut -notmatch 'No applicable') {
                        # Try to extract version numbers "Name  Id  Version  Available  Source"
                        $verMatch = [regex]::Match($upOut, "$([regex]::Escape($pkg.Id))\s+(\S+)\s+(\S+)")
                        $fromV = if ($verMatch.Success) { $verMatch.Groups[1].Value } else { '' }
                        $toV   = if ($verMatch.Success) { $verMatch.Groups[2].Value } else { '' }

                        if (Confirm-Update -Name $pkg.Name -FromVer $fromV -ToVer $toV) {
                            $r = winget upgrade --id $pkg.Id --silent --accept-source-agreements --accept-package-agreements 2>&1 | Out-String
                            if ($LASTEXITCODE -eq 0) { return @{ Status = 'UPDATE'; Detail = "$fromV -> $toV" } }
                            return @{ Status = 'WARN'; Detail = 'upgrade available but winget refused' }
                        }
                        return @{ Status = 'SKIP'; Detail = "update available ($fromV -> $toV) - declined" }
                    }
                    return @{ Status = 'SKIP'; Detail = 'already at latest' }
                }
                # Fresh install.
                $r = winget install --id $pkg.Id --silent --accept-source-agreements --accept-package-agreements 2>&1 | Out-String
                if ($LASTEXITCODE -eq 0) { return @{ Status = 'OK'; Detail = 'installed' } }
                throw "winget install failed (exit $LASTEXITCODE)"
            }
        }
        Write-Progress -Activity "winget packages" -Completed
    }

    # 3c) JetBrainsMono Nerd Font — version check via GitHub API
    Invoke-Step -Name "JetBrainsMono Nerd Font" -Body {
        $fontsPath  = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
        $installed  = Get-ChildItem $fontsPath -Filter "JetBrainsMonoNerdFont-*" -ErrorAction SilentlyContinue

        # Get latest release tag from GitHub
        $latestTag = try {
            (Invoke-RestMethod -Uri 'https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest' -UseBasicParsing).tag_name
        } catch { $null }

        if ($installed -and -not $latestTag) {
            return @{ Status = 'SKIP'; Detail = 'installed; GitHub API unreachable, cannot verify version' }
        }
        if ($installed) {
            # We don't track version metadata locally; assume up-to-date if already installed.
            return @{ Status = 'SKIP'; Detail = "installed (latest github release: $latestTag)" }
        }

        $tag = $latestTag ?? 'latest'
        $url = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
        $tmp = "$env:TEMP\JetBrainsMono.zip"
        $ext = "$env:TEMP\JetBrainsMono"

        Log "Downloading JetBrainsMono Nerd Font ($tag)..."
        Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing
        Expand-Archive -Path $tmp -DestinationPath $ext -Force

        $ttfs = Get-ChildItem $ext -Filter "*.ttf"
        $shell = New-Object -ComObject Shell.Application
        $fCount = $ttfs.Count
        for ($j = 0; $j -lt $fCount; $j++) {
            Write-Progress -Activity "Installing font files" -Status "$($j+1)/$fCount - $($ttfs[$j].Name)" -PercentComplete ([int](($j / $fCount) * 100))
            $shell.Namespace(0x14).CopyHere($ttfs[$j].FullName, 0x10)
        }
        Write-Progress -Activity "Installing font files" -Completed

        Remove-Item $tmp, $ext -Recurse -Force -ErrorAction SilentlyContinue
        return @{ Status = 'OK'; Detail = "installed $tag ($fCount files)" }
    }

    # 3d) Neovim config — Junction to dotfiles
    Invoke-Step -Name "nvim junction" -Body {
        $nvimTarget = "$env:LOCALAPPDATA\nvim"
        $nvimSrc    = Join-Path $HomeDir '.config\nvim'

        if (Test-Path $nvimTarget) {
            $item = Get-Item $nvimTarget -Force
            $isReparse = $item.Attributes -band [System.IO.FileAttributes]::ReparsePoint
            if ($isReparse) {
                # Already a junction; check if it points to the right place.
                $currentTarget = (Get-Item $nvimTarget).Target
                if ($currentTarget -eq $nvimSrc) {
                    return @{ Status = 'SKIP'; Detail = "already linked to $nvimSrc" }
                }
                (Get-Item $nvimTarget).Delete()
            } else {
                $backup = "$nvimTarget.pre-dotfiles.$(Get-Date -Format 'yyyyMMddHHmmss')"
                Move-Item $nvimTarget $backup
                Add-Step -Name "  backup existing nvim" -Status 'WARN' -Detail "-> $backup"
            }
        }
        New-Item -ItemType Junction -Path $nvimTarget -Target $nvimSrc | Out-Null
        return @{ Status = 'OK'; Detail = "$nvimTarget -> $nvimSrc" }
    }

    # 3e) Starship config
    Invoke-Step -Name "starship.toml" -Body {
        $starshipDir = "$env:USERPROFILE\.config"
        if (-not (Test-Path $starshipDir)) { New-Item -ItemType Directory -Path $starshipDir | Out-Null }
        $dst = "$starshipDir\starship.toml"
        $src = Join-Path $HomeDir '.config\starship.toml'

        if (Test-Path $dst) {
            $srcHash = (Get-FileHash $src -Algorithm SHA256).Hash
            $dstHash = (Get-FileHash $dst -Algorithm SHA256).Hash
            if ($srcHash -eq $dstHash) {
                return @{ Status = 'SKIP'; Detail = 'already up-to-date' }
            }
            Copy-Item $dst "$dst.pre-dotfiles.$(Get-Date -Format 'yyyyMMddHHmmss')"
        }
        Copy-Item $src $dst -Force
        return @{ Status = 'OK'; Detail = "-> $dst" }
    }

    # 3f) PowerShell profile
    Invoke-Step -Name "PowerShell profile" -Body {
        $profileTarget = $PROFILE.CurrentUserCurrentHost
        $profileSrc    = Join-Path $WindowsDir 'Microsoft.PowerShell_profile.ps1'
        $profileParent = Split-Path -Parent $profileTarget
        if (-not (Test-Path $profileParent)) { New-Item -ItemType Directory -Path $profileParent -Force | Out-Null }

        if (Test-Path $profileTarget) {
            $srcHash = (Get-FileHash $profileSrc -Algorithm SHA256).Hash
            $dstHash = (Get-FileHash $profileTarget -Algorithm SHA256).Hash
            if ($srcHash -eq $dstHash) {
                return @{ Status = 'SKIP'; Detail = 'already up-to-date' }
            }
            Copy-Item $profileTarget "$profileTarget.pre-dotfiles.$(Get-Date -Format 'yyyyMMddHHmmss')"
        }
        Copy-Item $profileSrc $profileTarget -Force
        return @{ Status = 'OK'; Detail = "-> $profileTarget" }
    }

    # 3g) Windows Terminal settings
    Invoke-Step -Name "Windows Terminal settings" -Body {
        $wtSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
        if (-not (Test-Path (Split-Path -Parent $wtSettings))) {
            return @{ Status = 'SKIP'; Detail = 'Windows Terminal not installed' }
        }
        $src = Join-Path $WindowsDir 'windows-terminal-settings.json'
        if (Test-Path $wtSettings) {
            $srcHash = (Get-FileHash $src -Algorithm SHA256).Hash
            $dstHash = (Get-FileHash $wtSettings -Algorithm SHA256).Hash
            if ($srcHash -eq $dstHash) {
                return @{ Status = 'SKIP'; Detail = 'already up-to-date' }
            }
            Copy-Item $wtSettings "$wtSettings.pre-dotfiles.$(Get-Date -Format 'yyyyMMddHHmmss')"
        }
        Copy-Item $src $wtSettings -Force
        return @{ Status = 'OK'; Detail = 'installed' }
    }

    # 3h) PSFzf module
    Invoke-Step -Name "PSFzf module" -Body {
        $installed = Get-Module -ListAvailable -Name PSFzf
        if ($installed) {
            # Check for newer version via PSGallery
            $latest = try { Find-Module -Name PSFzf -ErrorAction Stop } catch { $null }
            if ($latest -and ([version]$latest.Version -gt [version]($installed[0].Version))) {
                if (Confirm-Update -Name 'PSFzf' -FromVer $installed[0].Version -ToVer $latest.Version) {
                    Update-Module -Name PSFzf -Force -ErrorAction Stop
                    return @{ Status = 'UPDATE'; Detail = "$($installed[0].Version) -> $($latest.Version)" }
                }
                return @{ Status = 'SKIP'; Detail = "update available ($($installed[0].Version) -> $($latest.Version)) - declined" }
            }
            return @{ Status = 'SKIP'; Detail = "already at $($installed[0].Version)" }
        }
        Install-Module -Name PSFzf -Scope CurrentUser -Force -AcceptLicense -ErrorAction Stop
        return @{ Status = 'OK'; Detail = 'installed' }
    }
}

# ============================================================
# 4) WSL2 INSTALL
# ============================================================
if ($installWSL) {
    Section "WSL2"

    Invoke-Step -Name "WSL2 Ubuntu-24.04" -Body {
        $hasUbuntu = $false
        try {
            $wslOut = (wsl --list --quiet 2>&1) -replace "`0",''
            if ($wslOut -match 'Ubuntu-24\.04') { $hasUbuntu = $true }
        } catch {}

        if (-not $hasUbuntu) {
            Write-Host ""
            Write-Host "! Ubuntu-24.04 is not installed in WSL." -ForegroundColor Yellow
            $confirm = Read-Host "Run 'wsl --install -d Ubuntu-24.04'? [Y/n]"
            if ($confirm -eq '' -or $confirm -match '^[Yy]') {
                wsl --install -d Ubuntu-24.04
                Write-Host ""
                Write-Host "  A REBOOT may be required. After reboot:" -ForegroundColor Yellow
                Write-Host "     1. Open the 'Ubuntu' app, set UNIX username + password"
                Write-Host "     2. Then inside Ubuntu:"
                $wslPath = ($DotfilesDir -replace '\\','/' -replace '^([A-Za-z]):','/mnt/$1'.ToLower())
                Write-Host "        cd '$wslPath' && ./install.sh" -ForegroundColor Cyan
                Write-Host ""
                return @{ Status = 'WARN'; Detail = 'installation prompted; user action required after reboot' }
            }
            return @{ Status = 'SKIP'; Detail = 'user declined WSL install' }
        }
        # Ubuntu present -> run install.sh inside it
        $wslPath = ($DotfilesDir -replace '\\','/' -replace '^C:','/mnt/c' -replace '^D:','/mnt/d')
        Log "Running install.sh inside WSL Ubuntu-24.04..."
        Log "  path (WSL): $wslPath"
        wsl -d Ubuntu-24.04 -- bash -lc "cd '$wslPath' && ./install.sh"
        if ($LASTEXITCODE -eq 0) {
            return @{ Status = 'OK'; Detail = 'install.sh completed inside WSL' }
        }
        return @{ Status = 'FAIL'; Detail = "install.sh exited $LASTEXITCODE" }
    }
}

# ============================================================
# 5) SUMMARY
# ============================================================
Write-Host ""
Write-Host "=====================  SUMMARY  =====================" -ForegroundColor Cyan
Write-Host ""

$counts = @{ OK = 0; SKIP = 0; UPDATE = 0; WARN = 0; FAIL = 0 }
foreach ($s in $script:Report) { $counts[$s.Status]++ }

$script:Report | Format-Table -AutoSize -Property Step, Status, Detail | Out-Host

Write-Host ""
Write-Host ("  installed : {0}" -f $counts.OK)     -ForegroundColor Green
Write-Host ("  upgraded  : {0}" -f $counts.UPDATE)  -ForegroundColor Yellow
Write-Host ("  skipped   : {0}" -f $counts.SKIP)    -ForegroundColor DarkGray
Write-Host ("  warnings  : {0}" -f $counts.WARN)    -ForegroundColor Yellow
Write-Host ("  failed    : {0}" -f $counts.FAIL)    -ForegroundColor Red
Write-Host ""

# Post-install hints
Write-Host "Next steps:"
Write-Host "  - Fully close Windows Terminal and reopen (for font + settings + actions)"
if ($installWindows) {
    Write-Host "  - Open a new PowerShell tab -> Starship prompt + eza + zoxide + PSFzf"
    Write-Host "  - 'nvim' works natively in PowerShell (same config as WSL)"
}
if ($installWSL) {
    Write-Host "  - Ubuntu tab: zsh + tmux + nvim ready"
    Write-Host "  - Inside tmux: Prefix+I (Ctrl+A I) for TPM plugin install"
}

# Exit code reflects whether anything failed
if ($counts.FAIL -gt 0) { exit 1 } else { exit 0 }
