# dotfiles

Cross-platform dev environment with the **Predawn** color palette everywhere
(Neovim, tmux, zsh, Starship, Windows Terminal, PowerShell).

Works on:
- **WSL2 Ubuntu** (native Linux experience with zsh + tmux)
- **Windows PowerShell** (native Neovim + Starship + parity aliases)
- **Native Ubuntu / Debian** (same as WSL2)

## Reproduction on a new machine

The installer auto-detects the platform:

### If you are on **Windows**

Open PowerShell (**not Admin**) and run:

```powershell
git clone https://github.com/<username>/dotfiles.git $HOME\dotfiles
cd $HOME\dotfiles
.\install.ps1
```

It will ask what you want:

- `[1]` **Windows-native only** — Neovim, Starship, CLI tools (ripgrep/fd/fzf/eza/zoxide/lazygit), JetBrainsMono Nerd Font, Windows Terminal, PowerShell profile
- `[2]` **WSL2 only** — if you do not have WSL, it will install it (`wsl --install -d Ubuntu-24.04`); if you do, it will run `install.sh` inside WSL
- `[3]` **Both** (recommended for full parity) — full Windows-native install + WSL2 bootstrap

### If you are on **Linux / WSL2**

```bash
git clone https://github.com/<username>/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

## What the installer installs

### Linux/WSL side (`install.sh`)

| Category | Packages |
|----------|----------|
| **Shell** | zsh + zsh-autosuggestions + zsh-syntax-highlighting |
| **Terminal multiplexer** | tmux + TPM (plugin manager) |
| **Editor** | Neovim (latest stable, from official release) |
| **Prompt** | Starship |
| **CLI tools** | ripgrep, fd, fzf, eza, zoxide, lazygit, xclip |
| **Language runtimes** | python3 + venv |
| **Setup** | symlinks `home/` -> `$HOME`, `chsh` to zsh, `nvim +Lazy sync` |

### Windows side (`install.ps1`)

| Category | Packages (winget) |
|----------|-------------------|
| **Editor** | Neovim.Neovim |
| **Prompt** | Starship.Starship |
| **CLI tools** | ripgrep, sharkdp.fd, junegunn.fzf, ajeetdsouza.zoxide, JesseDuffield.lazygit, eza |
| **Font** | JetBrainsMono Nerd Font (from Nerd Fonts releases) |
| **Setup** | nvim junction (`%LOCALAPPDATA%\nvim`), starship.toml copy, WT settings, PS `$PROFILE`, PSFzf module |

## Structure

```
dotfiles/
├── README.md
├── install.sh                                  # Linux/WSL entry
├── install.ps1                                 # Windows entry (with menu)
├── home/                                       # -> symlinks to $HOME
│   ├── .zshrc
│   ├── .tmux.conf
│   └── .config/
│       ├── starship.toml                       # shared: WSL zsh + PowerShell
│       └── nvim/                               # shared: WSL + Windows nvim
│           ├── init.lua
│           ├── lazy-lock.json                  # pinned plugin versions
│           ├── lua/core/                       # options, keymaps, indent
│           ├── lua/plugins/                    # ~40 lazy specs
│           └── docs/CHEATSHEET.md
└── windows/                                    # -> copied to Windows locations
    ├── windows-terminal-settings.json          # -> %LOCALAPPDATA%\...\settings.json
    └── Microsoft.PowerShell_profile.ps1        # -> $PROFILE
```

## Post-install (manual)

1. **Fully close Windows Terminal** and reopen it.
   Without this, the font / settings / actions do not load.

2. Inside tmux, press `Prefix + I` (Ctrl+A I) for TPM install.

## Architecture

- **Configs**: the WSL side uses **symlinks** — every edit to `~/.zshrc` etc. shows up in the repo's `git status`.
- **Windows side**: `nvim/` is a directory junction (no admin), the rest are copies (WSL->NTFS symlinks are unreliable).
- **Starship config**: a single toml read by both shells. On Windows, `install.ps1` copies it to `~/.config/starship.toml` (local).

## Design overview

- **Palette**: Predawn (Jamie Wilson) — warm dark grays with muted syntax accents
- **Neovim**: lazy.nvim, blink.cmp, snacks, mini, treesitter, LSP + DAP
- **tmux**: custom rounded pill status bar with nerd font icons (git · cwd · date · time widgets)
- **Starship**: minimal, shows modules only when relevant (git, venv, node, cmd_duration)
- **Windows Terminal**: predawn scheme + Ctrl+Backspace/Delete remaps
- **PowerShell parity**: eza aliases, zoxide `cd`, PSFzf `Ctrl+T`/`Ctrl+R`, PSReadLine history search

## Daily use (updates)

Because `install.sh` creates **symlinks** (not copies), any change you make
directly to `~/.zshrc` / `~/.tmux.conf` / `~/.config/nvim/*` shows up in the repo:

```bash
cd ~/dotfiles
git status                # see what you changed
git add -A && git commit -m "tune X" && git push
```

For Windows-side changes (`settings.json`, `$PROFILE`) — you must copy them back into `windows/` manually.
