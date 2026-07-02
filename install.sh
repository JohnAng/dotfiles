#!/usr/bin/env bash
# @docstring
# Cross-platform installer — Linux/WSL2 side.
# Installs deps + symlinks configs into $HOME. Idempotent.
# For Windows, run install.ps1 from PowerShell.
set -euo pipefail

# ============================================================
# 0) OS check — fail-fast if not on Linux
# ============================================================
if [ "$(uname)" != "Linux" ]; then
    echo "x install.sh only runs on Linux (WSL2 Ubuntu, Ubuntu native)." >&2
    echo "  For Windows, run: install.ps1 from PowerShell." >&2
    exit 1
fi
if ! command -v apt-get >/dev/null; then
    echo "x apt-get not found. This script is for Debian/Ubuntu." >&2
    exit 1
fi

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_SRC="$DOTFILES_DIR/home"

log()  { printf '\033[1;34m>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32mv\033[0m %s\n' "$*"; }

# ============================================================
# 1) APT packages
# ============================================================
log "Installing apt packages..."
sudo apt-get update -qq
sudo apt-get install -y --no-install-recommends \
    zsh tmux git curl wget unzip build-essential \
    fzf ripgrep fd-find \
    xclip \
    python3 python3-pip python3-venv \
    ca-certificates

# fd binary is called fdfind on debian/ubuntu — add symlink
mkdir -p ~/.local/bin
[ -x ~/.local/bin/fd ] || ln -sf "$(which fdfind)" ~/.local/bin/fd

# ============================================================
# 2) Neovim (latest stable from official release)
# ============================================================
if ! command -v nvim >/dev/null; then
    log "Installing Neovim (latest stable release)..."
    curl -fsSLo /tmp/nvim-linux-x86_64.tar.gz \
        https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
    sudo tar -C /opt -xzf /tmp/nvim-linux-x86_64.tar.gz
    sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
    rm /tmp/nvim-linux-x86_64.tar.gz
    ok "Neovim installed: $(nvim --version | head -1)"
else
    ok "Neovim already installed"
fi

# ============================================================
# 3) Starship prompt
# ============================================================
if ! command -v starship >/dev/null; then
    log "Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
fi
ok "Starship: $(starship --version | head -1)"

# ============================================================
# 4) Zoxide (smart cd)
# ============================================================
if ! command -v zoxide >/dev/null; then
    log "Installing zoxide..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi
ok "zoxide installed"

# ============================================================
# 5) Eza (modern ls)
# ============================================================
if ! command -v eza >/dev/null; then
    log "Installing eza..."
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
        | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
        | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt-get update -qq && sudo apt-get install -y eza
fi
ok "eza installed"

# ============================================================
# 6) Lazygit
# ============================================================
if ! command -v lazygit >/dev/null; then
    log "Installing lazygit..."
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
        | grep -Po '"tag_name": "v\K[^"]*')
    curl -fsSLo /tmp/lazygit.tar.gz \
        "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar -C /tmp -xzf /tmp/lazygit.tar.gz lazygit
    sudo install /tmp/lazygit /usr/local/bin
    rm /tmp/lazygit /tmp/lazygit.tar.gz
fi
ok "lazygit installed"

# ============================================================
# 7) zsh plugins (autosuggestions + syntax highlighting)
# ============================================================
mkdir -p ~/.local/share
[ -d ~/.local/share/zsh-autosuggestions ] || \
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.local/share/zsh-autosuggestions
[ -d ~/.local/share/zsh-syntax-highlighting ] || \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.local/share/zsh-syntax-highlighting
ok "zsh plugins ready"

# ============================================================
# 8) TPM (tmux plugin manager)
# ============================================================
[ -d ~/.tmux/plugins/tpm ] || \
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
ok "TPM installed"

# ============================================================
# 9) Symlink configs (backup any existing -> .pre-dotfiles)
# ============================================================
link() {
    local src="$1" dst="$2"
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        mv "$dst" "${dst}.pre-dotfiles.$(date +%s)"
        warn "Backed up existing $dst"
    fi
    mkdir -p "$(dirname "$dst")"
    ln -sfn "$src" "$dst"
    ok "linked $dst -> $src"
}

link "$HOME_SRC/.zshrc"                 "$HOME/.zshrc"
link "$HOME_SRC/.tmux.conf"             "$HOME/.tmux.conf"
link "$HOME_SRC/.config/starship.toml"  "$HOME/.config/starship.toml"
link "$HOME_SRC/.config/nvim"           "$HOME/.config/nvim"

# ============================================================
# 10) Set zsh as default login shell
# ============================================================
if [ "$SHELL" != "$(which zsh)" ]; then
    log "Setting zsh as default shell (will prompt for password)..."
    chsh -s "$(which zsh)"
fi

# ============================================================
# 11) Neovim first-run: install lazy plugins
# ============================================================
log "Installing Neovim plugins (nvim +Lazy sync)..."
nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
ok "Neovim plugins installed"

echo ""
echo "==================================================="
ok "WSL bootstrap complete."
echo ""
echo "Next steps (manual):"
echo "  1. Open a new tab so zsh is picked up as default"
echo "  2. Inside tmux, press Prefix+I (Ctrl+A I) for TPM plugin install"
echo "  3. On the Windows side, run: install.ps1"
