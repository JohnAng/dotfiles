# @docstring
# Zsh Configuration File
# Architecture: XDG compliant, UX Augmented (Autosuggestions, Highlighting, Fuzzy Finding).

# @docstring
# History configuration (Time & Space Optimization).
HISTFILE="$HOME/.local/state/zsh/history"
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS

# @docstring
# Core Zsh ergonomics.
setopt AUTO_CD
setopt BEEP
setopt NOMATCH

# @docstring
# XDG Base Directory configurations and environment variables.
if [ -f "$HOME/.local/bin/env" ]; then
    . "$HOME/.local/bin/env"
fi

# @docstring
# Load basic aliases.
if [ -f "$HOME/.bash_aliases" ]; then
    . "$HOME/.bash_aliases"
fi

# @docstring
# Eza integration (Modern ls replacement).
alias ls='eza --group-directories-first --icons=auto'
alias ll='eza -l --group-directories-first --icons=auto'
alias la='eza -a --group-directories-first --icons=auto'
alias lla='eza -la --group-directories-first --icons=auto'
alias lt='eza -l --sort=modified --reverse --icons=auto'

# @docstring
# Initialize Node Version Manager (NVM).
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# @docstring
# Initialize Zoxide (Smart CD algorithm).
eval "$(zoxide init zsh)"
alias cd='z'

# @docstring
# Load UX Plugins: Autosuggestions and Syntax Highlighting.
source "$HOME/.local/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$HOME/.local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# @docstring
# FZF integration for history and path completion.
[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
[ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh

# @docstring
# Initialize Starship prompt (Must be evaluated last).
eval "$(starship init zsh)"
alias ltree='eza --tree --level=3 --icons=auto --group-directories-first'

# opencode (loaded only if present on this machine)
[ -d "$HOME/.opencode/bin" ] && export PATH="$HOME/.opencode/bin:$PATH"

 # ============================================================
  # Terminal key bindings — word editing & navigation
  # Cooperates with Windows Terminal sendInput actions
  # ============================================================
  bindkey -e                                     # Emacs keymap (explicit)

  # Word deletion
  bindkey '^[^?'    backward-kill-word           # Alt+Backspace (and Ctrl+Backspace via WT remap)
  bindkey '^H'      backward-kill-word           # Fallback if terminal sends ^H
  bindkey '^W'      backward-kill-word           # Ctrl+W (now free in WT)
  bindkey '^[d'     kill-word                    # Alt+d (and Ctrl+Delete via WT remap)
  bindkey '^[[3;5~' kill-word                    # Ctrl+Delete fallback

  # Word / line navigation
  bindkey '^[[1;5D' backward-word                # Ctrl+Left
  bindkey '^[[1;5C' forward-word                 # Ctrl+Right
  bindkey '^[[H'    beginning-of-line            # Home
  bindkey '^[[F'    end-of-line                  # End
  bindkey '^[[3~'   delete-char                  # Delete

  # Autosuggestions accept via Ctrl+Space (more ergonomic than Right arrow)
  bindkey '^ '      autosuggest-accept
