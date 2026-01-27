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

# Syntax highlighting (loaded last, in turbo mode)
# zinit ice wait lucid atinit'zpcompinit; zpcdreplay'
# zinit light zsh-users/zsh-syntax-highlighting

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
zstyle ':completion:*' special-dirs true

# Enhanced completion styling
zstyle ':completion:*:*:*:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:default' list-prompt '%S%M matches%s'

# Better completion for specific commands
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# Case insensitive path completion
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'

# Partial completion suggestions
zstyle ':completion:*' list-suffixes
zstyle ':completion:*' expand prefix suffix

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

# Fix Belgian (AZERTY) keyboard layout
if command -v setxkbmap &>/dev/null; then
  setxkbmap be 2>/dev/null
fi

# LS_COLORS - Enhanced file type colors for ls and completion
# Generate with vivid or use a good default scheme
if command -v vivid &>/dev/null; then
  export LS_COLORS="$(vivid generate molokai)"
else
  # Fallback to a comprehensive LS_COLORS scheme
  export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=00:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.avif=01;35:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.webp=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:*~=00;90:*#=00;90:*.bak=00;90:*.old=00;90:*.orig=00;90:*.part=00;90:*.rej=00;90:*.swp=00;90:*.tmp=00;90:*.dpkg-dist=00;90:*.dpkg-old=00;90:*.ucf-dist=00;90:*.ucf-new=00;90:*.ucf-old=00;90:*.rpmnew=00;90:*.rpmorig=00;90:*.rpmsave=00;90:'
fi

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
alias update="paru -Syu"
alias oc="opencode"

# Eza (modern ls replacement) - colorful and feature-rich
if command -v eza &>/dev/null; then
  alias ls="eza --icons=always --group-directories-first"
  alias ll="eza --icons=always --group-directories-first -lh"
  alias la="eza --icons=always --group-directories-first -lha"
  alias lt="eza --icons=always --group-directories-first --tree --level=2"
  alias l="eza --icons=always --group-directories-first -1"
fi

# Docker engine management
alias dockerstart="sudo systemctl start docker.service"
alias dockerstop="sudo systemctl stop docker.service"
alias dockerstatus="systemctl is-active docker.service"
# Quick dot navigation (.. up to 9 dots => go up multiple directories)
for _dots in {2..9}; do
  _name=$(printf '%*s' "$_dots" '' | tr ' ' '.')
  _levels=$((_dots - 1))
  _path=$(printf '../%.0s' $(seq 1 "$_levels"))
  alias "$_name"="cd $_path"
done
unset _dots _name _levels _path
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
# Increased to 10 to avoid sudo password issues
export KEYTIMEOUT=10

# Skip global compinit (we handle it ourselves)
skip_global_compinit=1
