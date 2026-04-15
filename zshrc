# ~/.zshrc — deployed by deploy-dotfiles-local
# Local overrides go in ~/.zshrc.local (sourced at the bottom)

# ── Homebrew ──────────────────────────────────────────────────────────────────
if [ -f /opt/homebrew/bin/brew ]; then           # Apple Silicon
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f /usr/local/bin/brew ]; then            # Intel
  eval "$(/usr/local/bin/brew shellenv)"
fi
BREW_PREFIX="$(brew --prefix 2>/dev/null)"

# ── PATH ──────────────────────────────────────────────────────────────────────
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# ── History ───────────────────────────────────────────────────────────────────
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt HIST_IGNORE_DUPS        # don't record duplicate consecutive commands
setopt HIST_IGNORE_SPACE       # don't record commands starting with a space
setopt HIST_VERIFY             # show command before executing from history expansion
setopt HIST_REDUCE_BLANKS      # remove extra blanks from history
setopt SHARE_HISTORY           # share history across all sessions
setopt EXTENDED_HISTORY        # record timestamp with each command

# ── Options ───────────────────────────────────────────────────────────────────
setopt AUTO_CD                 # cd by typing directory name
setopt AUTO_PUSHD              # push dirs onto stack on cd
setopt PUSHD_IGNORE_DUPS       # no duplicate dirs in stack
setopt PUSHD_SILENT            # don't print dir stack
setopt CORRECT                 # suggest corrections for typos
setopt NO_BEEP                 # silence
setopt GLOB_DOTS               # include dotfiles in globs
setopt EXTENDED_GLOB           # extended glob patterns

# ── Completion ────────────────────────────────────────────────────────────────
autoload -Uz compinit
# Only regenerate compdump once a day
if [ "$(find ~/.zcompdump -mtime +1 2>/dev/null)" ]; then
  compinit
else
  compinit -C
fi

zstyle ':completion:*' menu select                      # interactive menu
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'    # case-insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" # colored completions
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "$HOME/.zcompcache"

# ── Plugins ───────────────────────────────────────────────────────────────────

# zsh-autosuggestions — fish-like inline suggestions
if [ -n "$BREW_PREFIX" ] && [ -f "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#6c7086"  # subtle grey
fi

# fzf — fuzzy finder (Ctrl+R history, Ctrl+T files, Alt+C dirs)
if [ -n "$BREW_PREFIX" ] && [ -d "$BREW_PREFIX/opt/fzf" ]; then
  source "$BREW_PREFIX/opt/fzf/shell/completion.zsh" 2>/dev/null
  source "$BREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
fi

# fzf config
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='
  --height 40% --layout=reverse --border
  --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
  --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
  --preview "bat --color=always --style=numbers --line-range=:100 {} 2>/dev/null || cat {}"
  --preview-window=right:50%:wrap
'

# zoxide — smarter cd (replaces cd with z)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# ── Aliases: Navigation ───────────────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'          # go to previous dir

# ── Aliases: Files ────────────────────────────────────────────────────────────
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -lah --icons --git --group-directories-first'
  alias lt='eza --tree --icons -L 2 --group-directories-first'
  alias ltt='eza --tree --icons -L 3 --group-directories-first'
else
  alias ls='ls -G'
  alias ll='ls -lahG'
fi

command -v bat >/dev/null && alias cat='bat --paging=never'

# ── Aliases: Git ──────────────────────────────────────────────────────────────
alias g='git'
alias gs='git status -s'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gd='git diff'
alias gds='git diff --staged'
alias glog='git lg'
alias gco='git checkout'
alias gbr='git branch -v'
alias gst='git stash'
alias gstp='git stash pop'

# ── Aliases: Editor ───────────────────────────────────────────────────────────
alias v='nvim'
alias vi='nvim'
alias vim='nvim'

# ── Aliases: Tools ────────────────────────────────────────────────────────────
command -v fd >/dev/null      && alias find='fd'
command -v ripgrep >/dev/null && alias grep='rg'
command -v lazygit >/dev/null && alias lg='lazygit'
alias j='z'                   # zoxide shorthand

# ── Aliases: macOS ────────────────────────────────────────────────────────────
alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES && killall Finder'
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO && killall Finder'
alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
alias cleanup='find . -name "*.DS_Store" -delete && find . -name "._*" -delete'
alias brewup='brew update && brew upgrade && brew cleanup'
alias path='echo $PATH | tr ":" "\n"'

# ── Functions ─────────────────────────────────────────────────────────────────

# Create directory and cd into it
mkcd() { mkdir -p "$1" && cd "$1"; }

# fzf + cd into selected directory
fcd() {
  local dir
  dir=$(fd --type d --hidden --follow --exclude .git 2>/dev/null | fzf --preview 'eza --tree --icons -L 2 {} 2>/dev/null || ls {}') && cd "$dir"
}

# fzf + open file in nvim
fv() {
  local file
  file=$(fzf --preview 'bat --color=always --style=numbers {}') && nvim "$file"
}

# fzf + search git log and show diff
fgl() {
  git log --oneline --color=always | fzf --ansi --preview 'git show --color=always {1}' | awk '{print $1}' | xargs -I{} git show {}
}

# Extract any archive
extract() {
  case "$1" in
    *.tar.gz|*.tgz)   tar xzf "$1" ;;
    *.tar.bz2|*.tbz2) tar xjf "$1" ;;
    *.tar.xz)          tar xJf "$1" ;;
    *.tar)             tar xf "$1"  ;;
    *.zip)             unzip "$1"   ;;
    *.gz)              gunzip "$1"  ;;
    *.bz2)             bunzip2 "$1" ;;
    *.7z)              7z x "$1"    ;;
    *) echo "Unknown archive format: $1" ;;
  esac
}

# Quick HTTP server in current dir
serve() { python3 -m http.server "${1:-8000}"; }

# Show top 10 most used shell commands
topcmds() { history | awk '{print $2}' | sort | uniq -c | sort -rn | head -10; }

# ── Prompt: Starship ──────────────────────────────────────────────────────────
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# ── zsh-syntax-highlighting (must be sourced last) ────────────────────────────
if [ -n "$BREW_PREFIX" ] && [ -f "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# ── Local overrides ───────────────────────────────────────────────────────────
# Put machine-specific config (work proxies, private env vars, etc.) in ~/.zshrc.local
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
