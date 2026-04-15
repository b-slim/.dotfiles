# Dotfiles

Personal configs for Neovim, tmux, zsh, git, Ghostty, and Claude Code — with deploy scripts for local macOS and remote Linux VMs.

## Contents

| File | Deploys to | Description |
|------|-----------|-------------|
| `zshrc` | `~/.zshrc` | Zsh: history, completion, autosuggestions, fzf, zoxide, aliases, functions |
| `starship.toml` | `~/.config/starship.toml` | Starship prompt: directory, git status, language versions |
| `ghostty.conf` | `~/.config/ghostty/config` | Ghostty: font, catppuccin-mocha theme, zsh integration, Option-as-Alt |
| `gitconfig` | `~/.gitconfig` | Git: delta diff pager, aliases, sensible defaults |
| `gitconfig.local` | `~/.gitconfig.local` | Default identity (LinkedIn) + `includeIf` for `~/perso/` |
| `gitconfig.personal` | `~/.gitconfig.personal` | Personal identity (Apache) for `~/perso/` repos |
| `gitignore_global` | `~/.gitignore_global` | Global gitignore: macOS, editors, secrets, build artifacts |
| `ssh_config.custom` | `~/.ssh/config.custom` | SSH: route `git@github.com` to personal key for `~/perso/` |
| `nvim_init.lua` | `~/.config/nvim/init.lua` | Neovim: markdown editing, folding, TOC sidebar, render-markdown |
| `tmux.conf` | `~/.tmux.conf` | Tmux: Ctrl+Space prefix, mouse, vim navigation, 50k scrollback |
| `statusline-command.sh` | `~/.claude/statusline-command.sh` | Claude Code statusline: git branch, token usage, cost, model |
| `claude-settings.json` | `~/.claude/settings.json` | Claude Code: statusline config + allow/deny permissions |
| `Brewfile` | — | All Homebrew packages, installed via `brew bundle` |
| `macos-defaults.sh` | — | macOS system settings: keyboard, trackpad, Finder, Dock, screenshots |
| `deploy-dotfiles-local` | `~/bin/deploy-dotfiles-local` | Deploy all configs to local macOS |
| `deploy-dotfiles` | `~/bin/deploy-dotfiles` | Deploy configs to remote Linux VMs via SSH |

---

## Setup

### First-time install (macOS)

```bash
git clone git@github.com:b-slim/.dotfiles.git ~/.dotfiles && ~/.dotfiles/deploy-dotfiles-local
```

This clones the repo and immediately deploys everything: installs all packages via Homebrew, symlinks all configs, installs Neovim plugins.

Or step by step:

```bash
git clone git@github.com:b-slim/.dotfiles.git ~/.dotfiles

# Preview what will happen without touching anything
~/.dotfiles/deploy-dotfiles-local --dry-run

# Deploy (symlinks configs, installs packages via Brewfile)
~/.dotfiles/deploy-dotfiles-local

# Also apply macOS system settings (keyboard, Dock, Finder)
~/.dotfiles/deploy-dotfiles-local --macos-defaults
```

> Configs are symlinked by default — `git pull` in `~/.dotfiles` keeps everything up to date automatically.

---

## deploy-dotfiles-local

### Options

| Flag | Description |
|------|-------------|
| _(none)_ | Symlink all configs — stays in sync with `git pull` |
| `--copy` | Copy files instead of symlinking |
| `--dry-run` | Preview all actions without making any changes |
| `--macos-defaults` | Also run `macos-defaults.sh` (keyboard, Dock, Finder, screenshots) |
| `--help` | Show usage |

### What it deploys

1. Homebrew — installs if missing
2. `Brewfile` — `brew bundle --no-upgrade` (all packages at once)
3. `zshrc` → `~/.zshrc`
4. `starship.toml` → `~/.config/starship.toml`
5. `ghostty.conf` → `~/.config/ghostty/config`
6. `gitconfig` → `~/.gitconfig`
7. `gitignore_global` → `~/.gitignore_global`
8. `gitconfig.local` → `~/.gitconfig.local` (LinkedIn default + `includeIf ~/perso/`)
9. `gitconfig.personal` → `~/.gitconfig.personal` (bslim@apache.org)
10. `ssh_config.custom` → `~/.ssh/config.custom` (chmod 600)
11. `nvim_init.lua` → `~/.config/nvim/init.lua`
12. `tmux.conf` → `~/.tmux.conf` + reload if tmux is running
13. `statusline-command.sh` → `~/.claude/statusline-command.sh` (chmod +x)
14. `claude-settings.json` → merged into `~/.claude/settings.json` via jq
15. Headless Neovim — `nvim --headless "+Lazy! sync" +qa`
16. `~/bin/` — symlinks for both deploy scripts

Existing regular files are backed up as `.bak` before being replaced.

### After deploying

```bash
source ~/.zshrc                             # load zsh config in current session
deploy-dotfiles-local --macos-defaults      # optional: apply system settings
```

---

## Zsh

### Features

| Feature | Details |
|---------|---------|
| History | 100k entries, deduplication, shared across sessions, timestamps |
| Completion | Case-insensitive, colored, cached, interactive menu |
| autosuggestions | Fish-like inline suggestions — `→` to accept |
| syntax-highlighting | Command coloring as you type (must be sourced last) |
| fzf | `Ctrl+R` history, `Ctrl+T` files, `Alt+C` dirs — with bat previews |
| zoxide | `z <partial>` jumps to frequent dirs, replaces `cd` |
| Starship | Single-line prompt: dir + git branch/status + language versions |
| eza | Better `ls` with icons, git status, tree view |
| bat | Better `cat` with syntax highlighting, used as fzf preview |

### Aliases

| Alias | Expands to |
|-------|-----------|
| `v` / `vi` / `vim` | `nvim` |
| `ll` | `eza -lah --icons --git` |
| `lt` | `eza --tree --icons -L 2` |
| `cat` | `bat --paging=never` |
| `gs` | `git status -s` |
| `ga` / `gaa` | `git add` / `git add --all` |
| `gc` / `gcm` | `git commit` / `git commit -m` |
| `gp` / `gpl` | `git push` / `git pull` |
| `gd` / `gds` | `git diff` / `git diff --staged` |
| `glog` | `git lg` (pretty graph log) |
| `lg` | `lazygit` |
| `j <dir>` | `zoxide` jump |
| `..` / `...` / `....` | cd up 1 / 2 / 3 levels |
| `brewup` | `brew update && brew upgrade && brew cleanup` |
| `path` | Print `$PATH` one entry per line |
| `cleanup` | Remove `.DS_Store` and `._*` files recursively |
| `flushdns` | Flush macOS DNS cache |

### Functions

| Function | Description |
|----------|-------------|
| `fv` | fzf → pick file → open in nvim (with bat preview) |
| `fcd` | fzf → pick directory → cd into it (with eza tree preview) |
| `fgl` | fzf → browse git log → show diff for selected commit |
| `mkcd <dir>` | `mkdir -p` + `cd` in one step |
| `extract <file>` | Extract any archive (tar.gz, zip, bz2, 7z, …) |
| `serve [port]` | Start a Python HTTP server in the current dir (default: 8000) |
| `topcmds` | Show the 10 most used shell commands |

### Local overrides

Machine-specific config (work proxies, private env vars, etc.) goes in `~/.zshrc.local` — sourced at the end of `.zshrc`, not tracked in this repo.

### Building muscle memory

`zshrc.local.example` contains nag wrappers that print a hint when you reach for an old command, then run it anyway so nothing breaks:

```bash
cp ~/.dotfiles/zshrc.local.example ~/.zshrc.local
source ~/.zshrc
```

| Old habit | Nag fires | New habit |
|-----------|-----------|-----------|
| `cd <path>` | yes | `z <partial>` |
| `find` | yes | `fd` |
| `grep` | yes | `rg` |
| `man <tool>` | yes | `tldr <tool>` |

Remove each wrapper once it feels automatic. Delete `~/.zshrc.local` when done.

---

## Git

### Config highlights

| Setting | Value |
|---------|-------|
| Diff pager | `delta` — syntax-highlighted, side-by-side, line numbers |
| Editor | `nvim` |
| Default branch | `main` |
| Push default | `current` + auto setup remote |
| Fetch | Prune deleted remote branches automatically |
| Rebase | Auto-stash before rebase |
| Rerere | Remember and reuse conflict resolutions |
| Branch sort | Most recently active first |
| Diff algorithm | `histogram` (better than default Myers) |

### Aliases

| Alias | Command |
|-------|---------|
| `git lg` | Pretty graph log (all branches) |
| `git lgs` | Pretty graph log (current branch) |
| `git st` | `git status -s` |
| `git aa` | `git add --all` |
| `git cm` | `git commit -m` |
| `git amend` | `git commit --amend --no-edit` |
| `git undo` | Reset last commit, keep changes staged |
| `git new` | `git checkout -b` |
| `git brd` | `git branch -d` |
| `git sa` | Stash including untracked files |
| `git sp` | `git stash pop` |
| `git changed` | Files changed in last commit |
| `git file-log` | Full log for a specific file (`git file-log -- path`) |
| `git aliases` | List all configured aliases |

### Identities

Two identities switch automatically based on directory:

| Directory | Name | Email |
|-----------|------|-------|
| Everywhere (default) | Slim Bouguerra | `sbouguerra@linkedin.com` |
| `~/perso/**` | Slim Bouguerra | `bslim@apache.org` |

Wired up via `includeIf "gitdir:~/perso/"` in `~/.gitconfig.local`. Verify the active identity in any repo:

```bash
git config user.email
```

---

## SSH

`~/.ssh/config` is managed by LinkedIn and cannot be modified directly. Personal SSH config lives in `~/.ssh/config.custom` (included by the managed config).

`ssh_config.custom` configures:

```
Match host github.com user git
    IdentityFile ~/.ssh/personal_github_b-slim
    IdentitiesOnly yes
    IdentityAgent none
```

This routes `git@github.com` connections to the personal SSH key when working in `~/perso/`, keeping it separate from LinkedIn's SSH agent.

---

## Ghostty

| Setting | Value |
|---------|-------|
| Font | JetBrainsMono Nerd Font Mono, size 14, thickened |
| Theme | catppuccin-mocha |
| Shell integration | zsh — cursor shape per mode, prompt marks, title updates |
| Option as Alt | Enabled — required for zsh word nav (`Alt+.`) and fzf (`Alt+C`) |
| Scrollback | 100,000 lines |
| Window padding | 10px horizontal, 8px vertical |
| Titlebar style | Tabs |
| Cursor | Block, no blink |
| Copy on select | Disabled |
| Mouse hide | While typing |

---

## macOS Defaults

Run via `deploy-dotfiles-local --macos-defaults` or directly:

```bash
~/.dotfiles/macos-defaults.sh
```

### Keyboard

| Setting | Value | Default |
|---------|-------|---------|
| Key repeat rate | 2 | 6 |
| Initial repeat delay | 15 | 25 |
| Press-and-hold accent menu | Disabled | Enabled |
| Auto-correct | Disabled | Enabled |
| Smart quotes / dashes | Disabled | Enabled |
| Auto-capitalize | Disabled | Enabled |
| Auto-period on double-space | Disabled | Enabled |
| Full keyboard access (Tab in dialogs) | All controls | Text fields only |

### Trackpad

| Setting | Value |
|---------|-------|
| Tap to click | Enabled |

### Finder

| Setting | Value |
|---------|-------|
| Show hidden files | Yes |
| Show all file extensions | Yes |
| Show path bar | Yes |
| Show status bar | Yes |
| Default view | List |
| New window target | Home folder |
| Folders on top when sorting | Yes |
| Warn on extension change | No |
| `.DS_Store` on network volumes | Disabled |
| `.DS_Store` on USB volumes | Disabled |
| Disk image verification | Disabled (faster mounting) |

### Dock

| Setting | Value |
|---------|-------|
| Auto-hide | Enabled |
| Auto-hide delay | 0s |
| Auto-hide animation | 0.2s |
| Show recent apps | No |
| Icon size | 48px |
| Minimize into app icon | Yes |
| Mission Control animation | 0.1s |

### Screenshots

| Setting | Value |
|---------|-------|
| Save location | `~/Desktop/Screenshots/` |
| Format | PNG |
| Drop shadow | Disabled |

### Other

| App | Setting |
|-----|---------|
| Activity Monitor | Show all processes, sort by CPU |
| TextEdit | Default to plain text, UTF-8 |

> Some settings (keyboard, trackpad) require a logout/restart to take full effect.

---

## Homebrew Packages

All packages are defined in `Brewfile`. Install everything:

```bash
brew bundle --file=~/.dotfiles/Brewfile
```

| Package | Description |
|---------|-------------|
| `zsh-autosuggestions` | Fish-like inline suggestions |
| `zsh-syntax-highlighting` | Command coloring as you type |
| `fzf` | Fuzzy finder |
| `starship` | Shell prompt |
| `zoxide` | Smarter `cd` |
| `git` | Version control |
| `git-delta` | Syntax-highlighted diffs |
| `lazygit` | TUI git client |
| `gh` | GitHub CLI |
| `neovim` | Text editor |
| `tmux` | Terminal multiplexer |
| `bat` | Better `cat` |
| `eza` | Better `ls` |
| `fd` | Better `find` |
| `ripgrep` | Better `grep` |
| `sd` | Better `sed` |
| `jq` / `yq` | JSON / YAML processors |
| `bc` | Calculator (Claude statusline) |
| `tldr` | Concise man pages |
| `htop` | Process monitor |
| `watch` | Run command repeatedly |
| `font-jetbrains-mono-nerd-font` | Terminal font with icons |
| `ghostty` | Terminal emulator |

---

## Neovim

Markdown-focused configuration with lazy.nvim plugin manager.

### Plugins

| Plugin | Purpose |
|--------|---------|
| `vim-markdown` | Folding, syntax |
| `render-markdown` | Rich in-buffer rendering |
| `outline.nvim` | TOC sidebar panel |
| `nvim-treesitter` | Syntax parsing |

### Keymaps

Leader key is `Space`.

| Key | Action |
|-----|--------|
| `<Space>t` | TOC in quickfix |
| `<Space>o` | TOC sidebar panel |
| `<Space>ff` | Toggle fold under cursor |
| `<Space>fu` | Open one fold under cursor |
| `<Space>fU` | Open all nested folds under cursor |
| `<Space>fa` | Fold all |
| `<Space>fo` | Unfold all |
| `<Space>f1` / `f2` / `f3` | Fold to level 1 / 2 / 3 |
| `]]` | Jump to next heading |
| `[[` | Jump to previous heading |
| `gx` | Open URL under cursor in browser |
| `<Space>mr` | Toggle render-markdown |

---

## Tmux

| Setting | Value |
|---------|-------|
| Prefix | `Ctrl+Space` |
| Mouse support | Enabled |
| Scrollback | 50,000 lines |
| Pane navigation | `Prefix + h/j/k/l` (vim-style) |
| Alt navigation | `Alt+h/j/k/l` (no prefix needed) |
| Color | 24-bit (true color) |

---

## Claude Code Statusline

Displays in Claude Code's terminal:

- Directory (robbyrussell-style green arrow)
- Git branch with dirty indicator
- Token usage — color-coded: green `<50%`, yellow `50–79%`, red `≥80%`
- Estimated session cost (based on per-model pricing)
- Active model name
- Agent name (when running a subagent)
- Keyboard shortcuts reference line

Installed to `~/.claude/statusline-command.sh`. Settings in `~/.claude/settings.json`.

---

## Claude Code Permissions

### Allowed

- File operations: `Read`, `Edit`, `Write`
- Shell utilities: `ls`, `cat`, `grep`, `find`, `head`, `tail`, `diff`, `sort`, `awk`, `sed`, `cut`, `tr`, `xargs`, `tree`, etc.
- Git: all git commands
- Build tools: `gradle`, `./gradlew`, `npm`
- Languages: `python`, `python3`, `java`
- GitHub CLI: `gh pr`, `gh api`, `gh issue`, `gh search`, `gh auth`
- Kubernetes: `kubectl get`, `kubectl describe`, `kubectl logs`
- MCP tools: `mcp__captain__*`, `mcp__glean_default__*`

### Denied

- Sensitive files: `.env`, `.pem`, `.key`, `.p12`, `.pfx`, `.keystore`, `.netrc`, `.pgpass`
- Credential dirs: `~/.datavault`, `~/.azure`, `~/.azure-devops`, `~/dev.src`
- Destructive git: `git push --force`, `git reset --hard`, `git clean -f`
- Destructive shell: `rm -rf /`
- Network tools: `ssh`, `scp`, `nc`, `netcat`, `telnet`
- `WebSearch`

---

## Deploy to Remote VMs

```bash
# Single host
deploy-dotfiles user@vm1

# Multiple hosts
deploy-dotfiles user@vm1 user@vm2 user@vm3
```

### What it does per host

1. Installs/updates Neovim if missing or below v0.8.0 (user-local to `~/.local/`, no sudo)
2. Deploys `nvim_init.lua` → `~/.config/nvim/init.lua`
3. Deploys `tmux.conf` → `~/.tmux.conf` + reloads if running
4. Deploys `statusline-command.sh` → `~/.claude/` (chmod +x)
5. Merges `claude-settings.json` → `~/.claude/settings.json` via jq
6. Installs Ghostty terminfo (`xterm-ghostty`) from local machine if available
7. Runs headless Neovim to auto-install plugins via lazy.nvim

### Prerequisites on remote VMs

- `git`, `curl` (Neovim install), `jq` (settings merge), `bc` (statusline cost calc)
- A Nerd Font in your terminal (for icons)
