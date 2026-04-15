# Dotfiles

Personal configs for Neovim, tmux, zsh, git, and Ghostty — with deploy scripts for local macOS and remote Linux VMs.

## Contents

| File | Description |
|------|-------------|
| `nvim_init.lua` | Neovim config with markdown editing support (folding, TOC sidebar, render-markdown, header navigation, URL opening) |
| `tmux.conf` | Tmux configuration |
| `zshrc` | Zsh config: history, completion, plugins (autosuggestions, syntax-highlighting, fzf), aliases, functions |
| `starship.toml` | Starship prompt config (directory, git branch/status, language versions) |
| `ghostty.conf` | Ghostty terminal config: font, theme (catppuccin-mocha), shell integration, keybindings |
| `gitconfig` | Git config: delta diff pager, useful aliases, sensible defaults |
| `gitignore_global` | Global gitignore: macOS, editors, secrets, build artifacts |
| `Brewfile` | All Homebrew packages — install everything with `brew bundle` |
| `macos-defaults.sh` | macOS system settings: keyboard repeat, Dock, Finder, screenshots |
| `statusline-command.sh` | Claude Code statusline showing git branch, token usage, cost, and model info |
| `claude-settings.json` | Claude Code settings: statusline, permissions (allow + deny) |
| `deploy-dotfiles-local` | Deploy all configs to the local macOS machine |
| `deploy-dotfiles` | Deploy all configs to remote Linux VMs |

## Setup

### First-time install (macOS)

```bash
git clone git@github.com:b-slim/.dotfiles.git ~/.dotfiles && ~/.dotfiles/deploy-dotfiles-local
```

This clones the repo and immediately deploys everything: installs all packages via Homebrew, symlinks all configs, installs Neovim plugins.

Or step by step:

```bash
git clone git@github.com:b-slim/.dotfiles.git ~/.dotfiles

# Preview what will happen
~/.dotfiles/deploy-dotfiles-local --dry-run

# Deploy (symlinks configs, installs packages via Brewfile)
~/.dotfiles/deploy-dotfiles-local

# Also apply macOS system settings (keyboard, Dock, Finder)
~/.dotfiles/deploy-dotfiles-local --macos-defaults
```

> **Note:** Configs are symlinked by default, so `git pull` in `~/.dotfiles` keeps everything up to date automatically.

## Deploy to Local macOS

Run the local deploy script directly or via `~/bin`:

```bash
deploy-dotfiles-local
```

### Options

| Flag | Description |
|------|-------------|
| _(none)_ | Symlink all configs (default) — stays in sync with `git pull` |
| `--copy` | Copy files instead of symlinking |
| `--dry-run` | Preview all actions without making any changes |
| `--macos-defaults` | Also apply macOS system settings (keyboard, Dock, Finder, screenshots) |
| `--help` | Show usage |

### What it does

1. Checks for Homebrew and installs it if missing
2. Installs all packages from `Brewfile` via `brew bundle`
3. Deploys `zshrc` to `~/.zshrc`
4. Deploys `starship.toml` to `~/.config/starship.toml`
5. Deploys `ghostty.conf` to `~/.config/ghostty/config`
6. Deploys `gitconfig` to `~/.gitconfig` and `gitignore_global` to `~/.gitignore_global`
7. Creates `~/.gitconfig.local` (identity placeholder) if it doesn't exist
8. Deploys `nvim_init.lua` to `~/.config/nvim/init.lua`
9. Deploys `tmux.conf` to `~/.tmux.conf` and reloads tmux if running
10. Deploys `statusline-command.sh` to `~/.claude/` and makes it executable
11. Merges `claude-settings.json` into `~/.claude/settings.json`
12. Runs headless Neovim to auto-install plugins via lazy.nvim
13. Symlinks both deploy scripts into `~/bin`

### After deploying

```bash
source ~/.zshrc                      # load zsh config in current session
# Edit ~/.gitconfig.local            # set your git name and email
deploy-dotfiles-local --macos-defaults  # optional: apply system settings
```

### Dry run

Preview everything the script would do without touching any files:

```bash
deploy-dotfiles-local --dry-run
```

## Zsh

The `zshrc` includes:

| Feature | Details |
|---------|---------|
| History | 100k entries, deduplication, shared across sessions |
| Completion | Case-insensitive, colored, cached |
| autosuggestions | Fish-like inline suggestions (→ to accept) |
| syntax-highlighting | Command coloring as you type |
| fzf | `Ctrl+R` history, `Ctrl+T` files, `Alt+C` dirs |
| zoxide | `z <partial-dir>` jumps to frequent directories |
| Starship | Fast, informative prompt with git status |
| eza | Better `ls` with icons and git status |
| bat | Better `cat` with syntax highlighting |

Key aliases:

| Alias | Command |
|-------|---------|
| `v` / `vi` / `vim` | `nvim` |
| `ll` | `eza -lah --icons --git` |
| `lt` | `eza --tree --icons -L 2` |
| `cat` | `bat` |
| `gs` | `git status -s` |
| `glog` | `git lg` (pretty graph log) |
| `lg` | `lazygit` |
| `j <dir>` | `zoxide` jump |
| `fv` | fzf → open file in nvim |
| `fcd` | fzf → cd into directory |
| `fgl` | fzf → browse git log with diff preview |
| `brewup` | `brew update && brew upgrade && brew cleanup` |

## Git

The `gitconfig` uses [delta](https://github.com/dandavison/delta) as the diff pager: syntax-highlighted, side-by-side diffs with line numbers.

Key aliases:

| Alias | Command |
|-------|---------|
| `git lg` | Pretty graph log (all branches) |
| `git st` | `git status -s` |
| `git aa` | `git add --all` |
| `git cm` | `git commit -m` |
| `git amend` | `git commit --amend --no-edit` |
| `git undo` | Undo last commit, keep changes staged |
| `git new` | `git checkout -b` |
| `git sa` | Stash including untracked files |
| `git changed` | Show files changed in last commit |

Identity (name + email) is kept in `~/.gitconfig.local` — not tracked in this repo.

## Ghostty

The `ghostty.conf` configures:

- **Font:** JetBrainsMono Nerd Font Mono, size 14
- **Theme:** catppuccin-mocha
- **Shell integration:** zsh (proper cursor shape, prompt marks, title updates)
- **Option as Alt:** enabled (required for zsh word navigation and fzf bindings)
- **Scrollback:** 100k lines

## macOS Defaults

`macos-defaults.sh` applies the following settings:

| Category | Settings |
|----------|---------|
| Keyboard | Fast key repeat (rate 2, delay 15), disable press-and-hold, disable auto-correct/smart quotes |
| Trackpad | Tap to click |
| Finder | Show hidden files, show all extensions, path bar, list view, no extension-change warning |
| Dock | Auto-hide, no delay, no recent apps, size 48 |
| Screenshots | Save to `~/Desktop/Screenshots`, no shadow, PNG format |

## Deploy to Remote VMs

```bash
# Single host
~/.dotfiles/deploy-dotfiles user@vm1

# Multiple hosts
~/.dotfiles/deploy-dotfiles user@vm1 user@vm2 user@vm3
```

### What it does per host

1. Installs/updates Neovim to latest if missing or below 0.8.0 (user-local install to `~/.local/`, no sudo needed)
2. Copies `nvim_init.lua` to `~/.config/nvim/init.lua` on the remote host
3. Copies `tmux.conf` to `~/.tmux.conf` and reloads tmux if running
4. Copies `statusline-command.sh` to `~/.claude/` and makes it executable
5. Merges `claude-settings.json` into `~/.claude/settings.json` (statusline + permissions, preserves existing settings)
6. Installs Ghostty terminfo (`xterm-ghostty`) if available locally, fixing "missing or unsuitable terminal" errors
7. Runs headless Neovim to auto-install plugins via lazy.nvim

### Prerequisites on remote VMs

- git
- curl (for Neovim auto-install)
- jq (for Claude settings merge)
- bc (for Claude statusline cost calculation)
- A Nerd Font in your terminal (for icons)

## Claude Code Statusline

The statusline script displays the following in Claude Code's terminal:

- Green arrow + current directory (robbyrussell-inspired)
- Git branch with dirty indicator
- Token usage with color-coded percentage (green < 50%, yellow 50-79%, red 80%+)
- Estimated session cost based on model pricing
- Active model name
- Agent name (if running a subagent)
- Keyboard shortcuts reference line

Installed to `~/.claude/statusline-command.sh` with settings in `~/.claude/settings.json`.

## Claude Code Permissions

The `claude-settings.json` includes curated allow/deny permission rules.

### Allowed

- File operations: `Read`, `Edit`, `Write` on project files
- Shell utilities: `ls`, `cat`, `grep`, `find`, `head`, `tail`, `diff`, `sort`, `awk`, `sed`, `cut`, `tr`, `xargs`, `tree`, etc.
- Git: all git commands
- Build tools: `gradle`, `./gradlew`, `npm`
- Languages: `python`, `python3`, `java`
- GitHub CLI: `gh pr`, `gh api`, `gh issue`, `gh search`, `gh auth`
- Kubernetes: `kubectl get`, `kubectl describe`, `kubectl logs`
- MCP tools: `mcp__captain__*`, `mcp__glean_default__*`

### Denied (safety guards)

- Sensitive files: `.env`, `.pem`, `.key`, `.p12`, `.pfx`, certs, `.keystore`, `.netrc`, `.pgpass`
- Credential dirs: `~/.datavault`, `~/.azure`, `~/.azure-devops`, `~/dev.src`
- Destructive git: `git push --force`, `git reset --hard`, `git clean -f`
- Destructive shell: `rm -rf /`
- Network tools: `ssh`, `scp`, `nc`, `netcat`, `telnet`
- `WebSearch`

## Neovim Markdown Keymaps

Leader key is `<Space>`.

| Key | Action |
|-----|--------|
| `<Space>t` | TOC in quickfix |
| `<Space>o` | TOC sidebar panel |
| `<Space>ff` | Toggle fold under cursor |
| `<Space>fu` | Open one fold under cursor |
| `<Space>fU` | Open all nested folds under cursor |
| `<Space>fa` | Fold all |
| `<Space>fo` | Unfold all |
| `<Space>f1/f2/f3` | Fold to level 1/2/3 |
| `]]` | Jump to next heading |
| `[[` | Jump to previous heading |
| `gx` | Open URL under cursor in browser |
| `<Space>mr` | Toggle render-markdown |
