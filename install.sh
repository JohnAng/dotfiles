#!/usr/bin/env bash
# @docstring
# Cross-platform installer — Linux/WSL2 side.
# Fault-tolerant, idempotent, with version checks + user-confirmed upgrades.
# For Windows-native side, run install.ps1 from PowerShell.

# We DO NOT `set -e` here — each step is wrapped in its own try/record path,
# so one failure doesn't abort the whole install. But we do want strict pipefail.
set -uo pipefail

# ============================================================
# 0) OS check — fail-fast if not on Linux
# ============================================================
if [ "$(uname)" != "Linux" ]; then
    printf 'x install.sh only runs on Linux (WSL2 Ubuntu, Ubuntu native).\n' >&2
    printf '  For Windows, run: install.ps1 from PowerShell.\n' >&2
    exit 1
fi
if ! command -v apt-get >/dev/null; then
    printf 'x apt-get not found. This script is for Debian/Ubuntu.\n' >&2
    exit 1
fi

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_SRC="$DOTFILES_DIR/home"

# ============================================================
# 1) Reporting + prompt helpers
# ============================================================
# ANSI colors
C_R='\033[1;31m'   # red
C_G='\033[1;32m'   # green
C_Y='\033[1;33m'   # yellow
C_B='\033[1;34m'   # blue
C_M='\033[1;35m'   # magenta
C_D='\033[0;90m'   # dim gray
C_0='\033[0m'      # reset

# Global report arrays (parallel)
REPORT_STEP=()
REPORT_STATUS=()
REPORT_DETAIL=()

# Global update policy: ASK | ALL | NONE
UPDATE_POLICY='ASK'

record() {
    local name="$1" status="$2" detail="${3:-}"
    REPORT_STEP+=("$name")
    REPORT_STATUS+=("$status")
    REPORT_DETAIL+=("$detail")

    local col sym
    case "$status" in
        OK)     col="$C_G"; sym='v' ;;
        SKIP)   col="$C_D"; sym='~' ;;
        UPDATE) col="$C_Y"; sym='^' ;;
        WARN)   col="$C_Y"; sym='!' ;;
        FAIL)   col="$C_R"; sym='x' ;;
        *)      col="$C_0"; sym='?' ;;
    esac
    if [ -n "$detail" ]; then
        printf "  ${col}[$sym] %s${C_0} ${C_D}— %s${C_0}\n" "$name" "$detail"
    else
        printf "  ${col}[$sym] %s${C_0}\n" "$name"
    fi
}

log()     { printf "${C_B}>${C_0} %s\n" "$*"; }
section() { printf "\n${C_M}=== %s ===${C_0}\n" "$*"; }

# Ask the user whether to apply an available update.
# Args: name from_ver to_ver
# Returns: 0 if yes, 1 if no.
confirm_update() {
    local name="$1" from_ver="${2:-}" to_ver="${3:-}"
    if [ "$UPDATE_POLICY" = "ALL"  ]; then return 0; fi
    if [ "$UPDATE_POLICY" = "NONE" ]; then return 1; fi

    local ver=''
    if [ -n "$from_ver" ] && [ -n "$to_ver" ]; then
        ver=" ($from_ver -> $to_ver)"
    elif [ -n "$to_ver" ]; then
        ver=" (-> $to_ver)"
    fi
    printf "\n${C_Y}^ Update available for %s%s${C_0}\n" "$name" "$ver"
    local ans
    while :; do
        read -r -p "  Update? [Y]es / [N]o / [A]ll / [S]kip all: " ans || ans=''
        [ -z "$ans" ] && ans='Y'
        case "$ans" in
            [Yy]) return 0 ;;
            [Nn]) return 1 ;;
            [Aa]) UPDATE_POLICY='ALL';  return 0 ;;
            [Ss]) UPDATE_POLICY='NONE'; return 1 ;;
        esac
    done
}

# Compare two semver-like versions. Returns 0 if $1 == $2, 1 if $1 > $2, 2 if $1 < $2.
ver_cmp() {
    if [ "$1" = "$2" ]; then return 0; fi
    local higher
    higher=$(printf '%s\n%s\n' "$1" "$2" | sort -V | tail -1)
    [ "$higher" = "$1" ] && return 1
    return 2
}

# Fetch the latest release tag from a github repo. Prints tag WITHOUT leading 'v'.
gh_latest_tag() {
    local repo="$1"
    curl -fsSL --max-time 10 "https://api.github.com/repos/$repo/releases/latest" 2>/dev/null \
        | grep -Po '"tag_name":\s*"\K[^"]+' \
        | sed 's/^v//'
}

# ============================================================
# 2) APT packages (batch install; idempotent by design)
# ============================================================
section "APT packages"

apt_pkgs=(
    zsh tmux git curl wget unzip build-essential
    fzf ripgrep fd-find
    xclip
    python3 python3-pip python3-venv
    ca-certificates
)

# Which ones are missing?
missing_pkgs=()
for p in "${apt_pkgs[@]}"; do
    if ! dpkg -s "$p" >/dev/null 2>&1; then missing_pkgs+=("$p"); fi
done

if [ ${#missing_pkgs[@]} -eq 0 ]; then
    record "apt packages" SKIP "all ${#apt_pkgs[@]} already installed"
else
    log "Missing: ${missing_pkgs[*]}"
    if sudo apt-get update -qq && sudo apt-get install -y --no-install-recommends "${missing_pkgs[@]}" >/dev/null 2>&1; then
        record "apt packages" OK "installed ${#missing_pkgs[@]} of ${#apt_pkgs[@]}"
    else
        record "apt packages" FAIL "apt-get install failed for: ${missing_pkgs[*]}"
    fi
fi

# fd -> fdfind symlink (debian/ubuntu quirk)
mkdir -p "$HOME/.local/bin"
if [ -x "$HOME/.local/bin/fd" ]; then
    record "fd symlink" SKIP "already present"
else
    if ln -sf "$(which fdfind 2>/dev/null || true)" "$HOME/.local/bin/fd" 2>/dev/null; then
        record "fd symlink" OK "-> $(which fdfind)"
    else
        record "fd symlink" WARN "fdfind not found; skipping"
    fi
fi

# ============================================================
# 3) Neovim (from official release)
# ============================================================
section "Neovim"

nvim_latest="$(gh_latest_tag neovim/neovim)"
if command -v nvim >/dev/null; then
    nvim_current="$(nvim --version 2>/dev/null | head -1 | grep -Po 'v?\K[0-9.]+' | head -1)"
    if [ -z "$nvim_latest" ]; then
        record "Neovim" SKIP "installed $nvim_current; latest unknown (offline)"
    else
        ver_cmp "$nvim_current" "$nvim_latest"; c=$?
        if [ $c -eq 0 ] || [ $c -eq 1 ]; then
            record "Neovim" SKIP "already at $nvim_current"
        else
            if confirm_update "Neovim" "$nvim_current" "$nvim_latest"; then
                log "Upgrading Neovim..."
                if curl --progress-bar -fSLo /tmp/nvim.tar.gz \
                    "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz" \
                    && sudo tar -C /opt -xzf /tmp/nvim.tar.gz \
                    && sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim; then
                    rm -f /tmp/nvim.tar.gz
                    record "Neovim" UPDATE "$nvim_current -> $nvim_latest"
                else
                    record "Neovim" FAIL "download/install failed"
                fi
            else
                record "Neovim" SKIP "update declined ($nvim_current -> $nvim_latest available)"
            fi
        fi
    fi
else
    log "Installing Neovim ${nvim_latest:-latest}..."
    if curl --progress-bar -fSLo /tmp/nvim.tar.gz \
        "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz" \
        && sudo tar -C /opt -xzf /tmp/nvim.tar.gz \
        && sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim; then
        rm -f /tmp/nvim.tar.gz
        record "Neovim" OK "installed ${nvim_latest:-latest}"
    else
        record "Neovim" FAIL "download/install failed"
    fi
fi

# ============================================================
# 4) Starship
# ============================================================
section "Starship"

if command -v starship >/dev/null; then
    ss_current="$(starship --version 2>/dev/null | head -1 | awk '{print $2}')"
    ss_latest="$(gh_latest_tag starship/starship)"
    if [ -z "$ss_latest" ]; then
        record "Starship" SKIP "installed $ss_current; latest unknown (offline)"
    else
        ver_cmp "$ss_current" "$ss_latest"; c=$?
        if [ $c -eq 0 ] || [ $c -eq 1 ]; then
            record "Starship" SKIP "already at $ss_current"
        else
            if confirm_update "Starship" "$ss_current" "$ss_latest"; then
                if curl -sS https://starship.rs/install.sh | sh -s -- --yes >/dev/null 2>&1; then
                    record "Starship" UPDATE "$ss_current -> $ss_latest"
                else
                    record "Starship" FAIL "installer failed"
                fi
            else
                record "Starship" SKIP "update declined ($ss_current -> $ss_latest available)"
            fi
        fi
    fi
else
    log "Installing Starship..."
    if curl -sS https://starship.rs/install.sh | sh -s -- --yes >/dev/null 2>&1; then
        record "Starship" OK "installed"
    else
        record "Starship" FAIL "installer failed"
    fi
fi

# ============================================================
# 5) Zoxide
# ============================================================
section "zoxide"

if command -v zoxide >/dev/null; then
    zo_current="$(zoxide --version 2>/dev/null | awk '{print $2}')"
    zo_latest="$(gh_latest_tag ajeetdsouza/zoxide)"
    if [ -z "$zo_latest" ]; then
        record "zoxide" SKIP "installed $zo_current; latest unknown (offline)"
    else
        ver_cmp "$zo_current" "$zo_latest"; c=$?
        if [ $c -eq 0 ] || [ $c -eq 1 ]; then
            record "zoxide" SKIP "already at $zo_current"
        else
            if confirm_update "zoxide" "$zo_current" "$zo_latest"; then
                if curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh >/dev/null 2>&1; then
                    record "zoxide" UPDATE "$zo_current -> $zo_latest"
                else
                    record "zoxide" FAIL "installer failed"
                fi
            else
                record "zoxide" SKIP "update declined ($zo_current -> $zo_latest available)"
            fi
        fi
    fi
else
    if curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh >/dev/null 2>&1; then
        record "zoxide" OK "installed"
    else
        record "zoxide" FAIL "installer failed"
    fi
fi

# ============================================================
# 6) Eza (via apt repo)
# ============================================================
section "eza"

if command -v eza >/dev/null; then
    record "eza" SKIP "already installed ($(eza --version | head -1))"
else
    log "Setting up eza apt repository..."
    if sudo mkdir -p /etc/apt/keyrings \
        && wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
            | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg \
        && echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
            | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null \
        && sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list \
        && sudo apt-get update -qq \
        && sudo apt-get install -y eza >/dev/null 2>&1; then
        record "eza" OK "installed"
    else
        record "eza" FAIL "repo setup or install failed"
    fi
fi

# ============================================================
# 7) Lazygit
# ============================================================
section "lazygit"

if command -v lazygit >/dev/null; then
    lg_current="$(lazygit --version 2>/dev/null | grep -Po 'version=\K[0-9.]+' | head -1)"
    lg_latest="$(gh_latest_tag jesseduffield/lazygit)"
    if [ -z "$lg_latest" ]; then
        record "lazygit" SKIP "installed $lg_current; latest unknown (offline)"
    else
        ver_cmp "$lg_current" "$lg_latest"; c=$?
        if [ $c -eq 0 ] || [ $c -eq 1 ]; then
            record "lazygit" SKIP "already at $lg_current"
        else
            if confirm_update "lazygit" "$lg_current" "$lg_latest"; then
                if curl --progress-bar -fSLo /tmp/lazygit.tar.gz \
                    "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${lg_latest}_Linux_x86_64.tar.gz" \
                    && tar -C /tmp -xzf /tmp/lazygit.tar.gz lazygit \
                    && sudo install /tmp/lazygit /usr/local/bin; then
                    rm -f /tmp/lazygit /tmp/lazygit.tar.gz
                    record "lazygit" UPDATE "$lg_current -> $lg_latest"
                else
                    record "lazygit" FAIL "download/install failed"
                fi
            else
                record "lazygit" SKIP "update declined ($lg_current -> $lg_latest available)"
            fi
        fi
    fi
else
    log "Installing lazygit ${lg_latest:-latest}..."
    lg_latest="$(gh_latest_tag jesseduffield/lazygit)"
    if [ -z "$lg_latest" ]; then
        record "lazygit" FAIL "GitHub API unreachable"
    elif curl --progress-bar -fSLo /tmp/lazygit.tar.gz \
        "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${lg_latest}_Linux_x86_64.tar.gz" \
        && tar -C /tmp -xzf /tmp/lazygit.tar.gz lazygit \
        && sudo install /tmp/lazygit /usr/local/bin; then
        rm -f /tmp/lazygit /tmp/lazygit.tar.gz
        record "lazygit" OK "installed $lg_latest"
    else
        record "lazygit" FAIL "download/install failed"
    fi
fi

# ============================================================
# 8) zsh plugins (autosuggestions + syntax-highlighting)
# ============================================================
section "zsh plugins"

mkdir -p "$HOME/.local/share"

for pair in \
    "zsh-autosuggestions:https://github.com/zsh-users/zsh-autosuggestions" \
    "zsh-syntax-highlighting:https://github.com/zsh-users/zsh-syntax-highlighting"
do
    name="${pair%%:*}"
    url="${pair#*:}"
    dst="$HOME/.local/share/$name"
    if [ -d "$dst/.git" ]; then
        # Check if remote has new commits
        current="$(git -C "$dst" rev-parse HEAD 2>/dev/null)"
        remote="$(git -C "$dst" ls-remote origin HEAD 2>/dev/null | awk '{print $1}')"
        if [ -n "$remote" ] && [ "$current" != "$remote" ]; then
            if confirm_update "$name" "$(git -C "$dst" rev-parse --short HEAD)" "${remote:0:7}"; then
                if git -C "$dst" pull --ff-only >/dev/null 2>&1; then
                    record "$name" UPDATE "pulled latest"
                else
                    record "$name" WARN "pull failed"
                fi
            else
                record "$name" SKIP "update available - declined"
            fi
        else
            record "$name" SKIP "up-to-date"
        fi
    else
        if git clone --quiet "$url" "$dst"; then
            record "$name" OK "cloned"
        else
            record "$name" FAIL "clone failed"
        fi
    fi
done

# ============================================================
# 8b) win32yank — bidirectional WSL <-> Windows clipboard bridge for Neovim
# ============================================================
is_wsl() {
    [ -n "${WSL_DISTRO_NAME:-}" ] || grep -qi microsoft /proc/version 2>/dev/null
}

if is_wsl; then
    section "win32yank (WSL clipboard)"

    if command -v win32yank.exe >/dev/null 2>&1; then
        w32_current="$(win32yank.exe --version 2>/dev/null | head -1)"
        record "win32yank" SKIP "already present ($w32_current)"
    else
        log "Downloading win32yank..."
        w32_tag="$(gh_latest_tag equalsraf/win32yank)"
        w32_tag="${w32_tag:-0.1.1}"
        if curl --progress-bar -fSLo /tmp/win32yank.zip \
            "https://github.com/equalsraf/win32yank/releases/download/v${w32_tag}/win32yank-x64.zip" \
            && unzip -o -q /tmp/win32yank.zip -d /tmp/win32yank \
            && install -m 755 /tmp/win32yank/win32yank.exe "$HOME/.local/bin/win32yank.exe"; then
            rm -rf /tmp/win32yank /tmp/win32yank.zip
            record "win32yank" OK "installed $w32_tag to ~/.local/bin"
        else
            record "win32yank" FAIL "download/install failed"
        fi
    fi
fi

# ============================================================
# 9) TPM (tmux plugin manager)
# ============================================================
section "TPM"

if [ -d "$HOME/.tmux/plugins/tpm/.git" ]; then
    current="$(git -C "$HOME/.tmux/plugins/tpm" rev-parse HEAD 2>/dev/null)"
    remote="$(git -C "$HOME/.tmux/plugins/tpm" ls-remote origin HEAD 2>/dev/null | awk '{print $1}')"
    if [ -n "$remote" ] && [ "$current" != "$remote" ]; then
        if confirm_update "TPM" "$(git -C "$HOME/.tmux/plugins/tpm" rev-parse --short HEAD)" "${remote:0:7}"; then
            if git -C "$HOME/.tmux/plugins/tpm" pull --ff-only >/dev/null 2>&1; then
                record "TPM" UPDATE "pulled latest"
            else
                record "TPM" WARN "pull failed"
            fi
        else
            record "TPM" SKIP "update available - declined"
        fi
    else
        record "TPM" SKIP "up-to-date"
    fi
else
    if git clone --quiet https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"; then
        record "TPM" OK "cloned"
    else
        record "TPM" FAIL "clone failed"
    fi
fi

# ============================================================
# 10) Symlink configs
# ============================================================
section "config symlinks"

link_config() {
    local src="$1" dst="$2" name="$3"
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        record "$name" SKIP "already linked correctly"
        return
    fi
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        local backup="${dst}.pre-dotfiles.$(date +%s)"
        if mv "$dst" "$backup"; then
            record "  backup existing $name" WARN "-> $backup"
        else
            record "$name" FAIL "could not back up existing file"
            return
        fi
    fi
    mkdir -p "$(dirname "$dst")"
    if ln -sfn "$src" "$dst"; then
        record "$name" OK "-> $src"
    else
        record "$name" FAIL "symlink failed"
    fi
}

link_config "$HOME_SRC/.zshrc"                "$HOME/.zshrc"                ".zshrc"
link_config "$HOME_SRC/.tmux.conf"            "$HOME/.tmux.conf"            ".tmux.conf"
link_config "$HOME_SRC/.config/starship.toml" "$HOME/.config/starship.toml" "starship.toml"
link_config "$HOME_SRC/.config/nvim"          "$HOME/.config/nvim"          "nvim/"

# ============================================================
# 11) Default login shell -> zsh
# ============================================================
section "default shell"

if [ "$SHELL" = "$(which zsh 2>/dev/null)" ]; then
    record "chsh" SKIP "already zsh"
else
    log "Setting zsh as default shell (may prompt for password)..."
    if chsh -s "$(which zsh)" 2>/dev/null; then
        record "chsh" OK "-> $(which zsh)"
    else
        record "chsh" WARN "chsh failed; run 'chsh -s $(which zsh)' manually"
    fi
fi

# ============================================================
# 12) Neovim first-run: install lazy plugins
# ============================================================
section "Neovim plugins (Lazy)"

log "Running nvim +Lazy sync (headless)..."
if nvim --headless "+Lazy! sync" +qa 2>/dev/null; then
    record "Lazy sync" OK "plugins installed/updated"
else
    record "Lazy sync" WARN "headless sync had errors (check on first launch)"
fi

# ============================================================
# 13) SUMMARY
# ============================================================
printf '\n'
printf "${C_M}=====================  SUMMARY  =====================${C_0}\n\n"

# Column widths
w1=32; w2=8

printf "  %-${w1}s %-${w2}s %s\n" "Step" "Status" "Detail"
printf "  %-${w1}s %-${w2}s %s\n" "----" "------" "------"

ok=0; skip=0; up=0; warn=0; fail=0
for i in "${!REPORT_STEP[@]}"; do
    step="${REPORT_STEP[$i]}"
    status="${REPORT_STATUS[$i]}"
    detail="${REPORT_DETAIL[$i]}"
    case "$status" in
        OK)     col="$C_G"; ok=$((ok+1)) ;;
        SKIP)   col="$C_D"; skip=$((skip+1)) ;;
        UPDATE) col="$C_Y"; up=$((up+1)) ;;
        WARN)   col="$C_Y"; warn=$((warn+1)) ;;
        FAIL)   col="$C_R"; fail=$((fail+1)) ;;
        *)      col="$C_0" ;;
    esac
    printf "  ${col}%-${w1}s %-${w2}s${C_0} ${C_D}%s${C_0}\n" "$step" "$status" "$detail"
done

printf '\n'
printf "  ${C_G}installed : %d${C_0}\n" "$ok"
printf "  ${C_Y}upgraded  : %d${C_0}\n" "$up"
printf "  ${C_D}skipped   : %d${C_0}\n" "$skip"
printf "  ${C_Y}warnings  : %d${C_0}\n" "$warn"
printf "  ${C_R}failed    : %d${C_0}\n" "$fail"
printf '\n'

printf "Next steps (manual):\n"
printf "  1. Open a new tab so zsh is picked up as default\n"
printf "  2. Inside tmux, press Prefix+I (Ctrl+A I) for TPM plugin install\n"
printf "  3. On the Windows side, run: install.ps1\n"

# Exit non-zero if anything failed
[ "$fail" -eq 0 ] || exit 1
exit 0
