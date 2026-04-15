# Dotfiles

Personal Neovim and tmux configurations with a deploy script for remote Linux VMs.

## Contents

| File | Description |
|------|-------------|
| `nvim_init.lua` | Neovim config with markdown editing support (folding, TOC sidebar, render-markdown, header navigation, URL opening) |
| `tmux.conf` | Tmux configuration |
| `statusline-command.sh` | Claude Code statusline showing git branch, token usage, cost, and model info |
| `claude-settings.json` | Claude Code settings: statusline, permissions (allow + deny) |
| `deploy-dotfiles` | Script to deploy all configs to remote Linux VMs |
| `deploy-dotfiles-local` | Script to deploy all configs to the local macOS machine |

## Setup

One-liner install (clone + deploy locally):

```bash
git clone git@github.com:b-slim/.dotfiles.git ~/.dotfiles && ~/.dotfiles/deploy-dotfiles-local
```

Or step by step:

```bash
git clone git@github.com:b-slim/.dotfiles.git ~/.dotfiles

# Preview what will happen
~/.dotfiles/deploy-dotfiles-local --dry-run

# Deploy (symlinks configs and installs missing deps via Homebrew)
~/.dotfiles/deploy-dotfiles-local
```

> **Note:** The local deploy script symlinks configs by default, so `git pull` in `~/.dotfiles` keeps everything up to date automatically.

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
| `--help` | Show usage |

### What it does

1. Checks for Homebrew and installs it if missing
2. Installs missing dependencies via Homebrew: `neovim`, `tmux`, `jq`, `bc`
3. Deploys `nvim_init.lua` to `~/.config/nvim/init.lua`
4. Deploys `tmux.conf` to `~/.tmux.conf` and reloads tmux if running
5. Deploys `statusline-command.sh` to `~/.claude/` and makes it executable
6. Merges `claude-settings.json` into `~/.claude/settings.json`
7. Runs headless Neovim to auto-install plugins via lazy.nvim
8. Symlinks both deploy scripts into `~/bin`

### Dry run

Preview everything the script would do without touching any files:

```bash
deploy-dotfiles-local --dry-run
```

## Deploy to Remote VMs

Run the script directly from the repo or via `~/bin` if symlinked:

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
