# ============================================================================
# ZINIT-OPTIMIZED ZSHRC - Fast startup configuration
# ============================================================================

# Enable Powerlevel10k instant prompt (must stay at top)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ============================================================================
# ZINIT INSTALLATION & SETUP
# ============================================================================

# Install zinit if not present
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

# ============================================================================
# ZINIT ANNEXES (optional optimizations)
# ============================================================================
zinit light-mode for \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl

# ============================================================================
# THEME - Powerlevel10k with Turbo Mode
# ============================================================================
zinit ice depth=1
zinit light romkatv/powerlevel10k

# Load p10k configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ============================================================================
# PLUGINS - Optimized with Turbo Mode
# ============================================================================

# Autosuggestions (loaded with small delay - turbo mode)
zinit ice wait lucid atload'_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions

# Completions (loaded in turbo mode)
zinit ice wait lucid blockf atpull'zinit creinstall -q .'
zinit light zsh-users/zsh-completions

# Git aliases and functions (turbo mode)
zinit ice wait lucid
zinit snippet OMZ::lib/git.zsh

zinit ice wait lucid
zinit snippet OMZ::plugins/git/git.plugin.zsh

# History substring search (turbo mode)
zinit ice wait lucid
zinit light zsh-users/zsh-history-substring-search

# ============================================================================
# COMPLETION SYSTEM - Optimized
# ============================================================================
autoload -Uz compinit

# Only regenerate compdump once per day
setopt EXTENDEDGLOB
for dump in ~/.zcompdump(N.mh+24); do
  compinit
done
compinit -C

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ============================================================================
# HISTORY CONFIGURATION
# ============================================================================
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY
setopt APPEND_HISTORY

# ============================================================================
# ENVIRONMENT VARIABLES
# ============================================================================

# PATH additions
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.dotnet:$PATH"
export PATH="/home/warre/.opencode/bin:$PATH"

# ============================================================================
# LAZY-LOADED TOOLS
# ============================================================================

# --- NVM Lazy Loading (saves ~340ms) ---
export NVM_DIR="$HOME/.nvm"
# Add current node version to PATH immediately without loading NVM
if [[ -d "$NVM_DIR/versions/node" ]]; then
  NODE_LATEST=$(command ls -1 "$NVM_DIR/versions/node" 2>/dev/null | tail -1)
  if [[ -n "$NODE_LATEST" ]]; then
    export PATH="$NVM_DIR/versions/node/$NODE_LATEST/bin:$PATH"
  fi
fi

# Lazy load NVM only when needed
_nvm_lazy_load() {
  unset -f nvm node npm npx yarn
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}

nvm() { _nvm_lazy_load; nvm "$@"; }
node() { _nvm_lazy_load; node "$@"; }
npm() { _nvm_lazy_load; npm "$@"; }
npx() { _nvm_lazy_load; npx "$@"; }
yarn() { _nvm_lazy_load; yarn "$@"; }

# --- Conda Lazy Loading ---
if [[ $- == *i* ]]; then
  _conda_lazy_load() {
    unalias conda 2>/dev/null
    unset -f _conda_lazy_load
    if [ -f "/home/warre/anaconda3/etc/profile.d/conda.sh" ]; then
      source "/home/warre/anaconda3/etc/profile.d/conda.sh" &>/dev/null
    else
      export PATH="/home/warre/anaconda3/bin:$PATH"
    fi
    command conda "$@"
  }
  alias conda='_conda_lazy_load'
fi

# --- Thefuck Lazy Loading (cached) ---
THEFUCK_CACHE="$HOME/.cache/thefuck_alias.zsh"
if command -v thefuck &>/dev/null; then
  if [[ ! -f "$THEFUCK_CACHE" ]] || [[ $(command -v thefuck) -nt "$THEFUCK_CACHE" ]]; then
    mkdir -p "$(dirname "$THEFUCK_CACHE")"
    thefuck --alias > "$THEFUCK_CACHE" 2>/dev/null
  fi
  source "$THEFUCK_CACHE"
fi

# --- Zoxide (lazy loaded in background) ---
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

# --- Bun completions (lazy loaded) ---
[ -s "/home/warre/.bun/_bun" ] && source "/home/warre/.bun/_bun"

# --- Cargo environment (lazy loaded) ---
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# ============================================================================
# PYWAL THEME - Colors loaded directly by terminal (alacritty)
# ============================================================================
# No need to load sequences - alacritty imports colors from ~/.cache/wal/alacritty.toml

# ============================================================================
# ALIASES
# ============================================================================
alias c="clear"
alias ff="fastfetch"
alias off="poweroff"
alias kys="poweroff"
alias houjekankerbek="poweroff"
alias yay="paru"
alias cd="z"
alias :q="exit"
# ============================================================================
# FUNCTIONS
# ============================================================================

# Create directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Open new terminal in current directory
n() {
  if command -v ghostty &>/dev/null; then
    ghostty --working-directory="$(pwd)" &>/dev/null &!
  else
    echo "No supported terminal emulator found"
  fi
}

# ============================================================================
# KEY BINDINGS
# ============================================================================
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^T' n

# ============================================================================
# ZSH OPTIONS
# ============================================================================
setopt AUTO_CD              # Change directory without cd
setopt INTERACTIVE_COMMENTS # Allow comments in interactive mode
setopt MAGIC_EQUAL_SUBST    # Enable completion after =
setopt NOTIFY               # Report status of background jobs immediately
setopt PROMPT_SUBST         # Enable parameter expansion in prompt

# Disable beep
unsetopt BEEP

# ============================================================================
# PERFORMANCE OPTIMIZATIONS
# ============================================================================

# Reduce escape key delay (useful for vi mode)
export KEYTIMEOUT=1

# Skip global compinit (we handle it ourselves)
skip_global_compinit=1
