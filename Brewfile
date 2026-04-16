# Brewfile — install everything with: brew bundle
# Run via deploy-dotfiles-local or manually: brew bundle --file=~/.dotfiles/Brewfile

# ── Shell ─────────────────────────────────────────────────────────────────────
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"
brew "fzf"
brew "starship"
brew "zoxide"           # smarter cd (z foo jumps to frequent dirs)

# ── Git ───────────────────────────────────────────────────────────────────────
brew "git"
brew "git-delta"        # syntax-highlighted diffs
brew "lazygit"          # TUI git client
brew "gh"               # GitHub CLI

# ── Editors / IDE ─────────────────────────────────────────────────────────────
brew "neovim"
brew "tmux"

# ── Modern CLI replacements ───────────────────────────────────────────────────
brew "bat"              # better cat (syntax highlighting)
brew "eza"              # better ls (icons, git status)
brew "fd"               # better find
brew "ripgrep"          # better grep
brew "sd"               # better sed (intuitive syntax)

# ── Utils ─────────────────────────────────────────────────────────────────────
brew "jq"               # JSON processor
brew "yq"               # YAML processor
brew "bc"               # calculator (used by Claude statusline)
brew "tree"
brew "wget"
brew "curl"
brew "tldr"             # concise man pages
brew "htop"
brew "watch"

# ── SSH ───────────────────────────────────────────────────────────────────────
brew "mosh"             # better SSH: survives sleep/wake and network roaming

# ── Docker ────────────────────────────────────────────────────────────────────
brew "colima"           # lightweight Docker daemon (replaces Docker Desktop)
brew "docker"           # docker CLI
brew "docker-compose"   # multi-container apps
brew "lazydocker"       # TUI for Docker (containers, images, volumes)
brew "dive"             # inspect Docker image layers

# ── Kubernetes ────────────────────────────────────────────────────────────────
brew "kubectl"          # K8s CLI
brew "k9s"              # TUI for Kubernetes
brew "kubectx"          # kubectx + kubens: switch contexts and namespaces fast

# ── Java ──────────────────────────────────────────────────────────────────────
brew "jenv"             # Java version manager (per-directory via .java-version)
brew "maven"            # build tool

tap "homebrew/cask-versions"
cask "temurin@21"       # Eclipse Temurin JDK 21 (current LTS)
cask "temurin@17"       # Eclipse Temurin JDK 17 (previous LTS)

# ── Fonts ─────────────────────────────────────────────────────────────────────
cask "font-jetbrains-mono-nerd-font"

# ── Apps ──────────────────────────────────────────────────────────────────────
cask "ghostty"
