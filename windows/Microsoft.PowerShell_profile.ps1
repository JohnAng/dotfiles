# $PROFILE — Predawn cross-platform (Windows parity with WSL zsh)
# Provides: PSReadLine bindings + eza/zoxide aliases + Starship prompt.

# ============================================================
# 1) Terminal-Icons (if available)
# ============================================================
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Try { Import-Module Terminal-Icons -ErrorAction Stop } Catch { Write-Verbose "Terminal-Icons failed: $_" }
}

# ============================================================
# 2) PSReadLine key bindings — compatible with WT sendInput remap
#    WT sends: Ctrl+Backspace -> Ctrl+W byte · Ctrl+Delete -> Alt+d escape
# ============================================================
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine
    Set-PSReadLineKeyHandler -Chord 'Alt+d'          -Function KillWord
    Set-PSReadLineKeyHandler -Chord 'Alt+Backspace'  -Function BackwardKillWord
    Set-PSReadLineKeyHandler -Chord 'Ctrl+Backspace' -Function BackwardKillWord
    Set-PSReadLineKeyHandler -Chord 'Ctrl+Delete'    -Function KillWord
    Set-PSReadLineKeyHandler -Chord 'Ctrl+w'         -Function BackwardKillWord
    Set-PSReadLineKeyHandler -Chord 'Ctrl+LeftArrow'  -Function BackwardWord
    Set-PSReadLineKeyHandler -Chord 'Ctrl+RightArrow' -Function ForwardWord
    Set-PSReadLineKeyHandler -Chord 'UpArrow'   -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Chord 'DownArrow' -Function HistorySearchForward
    Set-PSReadLineOption -PredictionSource History -PredictionViewStyle ListView -EditMode Windows
}

# ============================================================
# 3) Eza aliases (parity with zsh side)
# ============================================================
if (Get-Command eza -ErrorAction SilentlyContinue) {
    Set-Alias -Name ls -Value eza -Force -Option AllScope
    function ll    { eza -l  --group-directories-first --icons=auto @args }
    function la    { eza -a  --group-directories-first --icons=auto @args }
    function lla   { eza -la --group-directories-first --icons=auto @args }
    function lt    { eza -l  --sort=modified --reverse --icons=auto @args }
    function ltree { eza --tree --level=3 --icons=auto --group-directories-first @args }
}

# ============================================================
# 4) Zoxide (smart cd) — parity with zsh side
# ============================================================
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
    Set-Alias -Name cd -Value z -Force -Option AllScope
}

# ============================================================
# 5) PSFzf — Ctrl+T files · Ctrl+R history (fzf keybindings)
# ============================================================
if (Get-Module -ListAvailable -Name PSFzf) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}

# ============================================================
# 6) Starship prompt — prefers local Windows config, falls back to WSL, then defaults.
#    If starship is missing entirely, falls back to oh-my-posh (safety net).
# ============================================================
if (Get-Command starship -ErrorAction SilentlyContinue) {
    $localConfig = "$env:USERPROFILE\.config\starship.toml"
    $wslConfig   = "\\wsl.localhost\Ubuntu-24.04\home\$env:USERNAME\.config\starship.toml"
    if     (Test-Path $localConfig) { $env:STARSHIP_CONFIG = $localConfig }
    elseif (Test-Path $wslConfig)   { $env:STARSHIP_CONFIG = $wslConfig }
    Invoke-Expression (&starship init powershell)
}
elseif (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    oh-my-posh init pwsh --config "$env:USERPROFILE\myconfig.omp.json" | Invoke-Expression
}
