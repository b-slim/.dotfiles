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

## Setup

Clone the repo and optionally symlink the deploy script:

```bash
git clone git@github.com:b-slim/.dotfiles.git ~/.dotfiles

# Optional: make deploy-dotfiles available globally
mkdir -p ~/bin
ln -sf ~/.dotfiles/deploy-dotfiles ~/bin/deploy-dotfiles
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

1. Copies `nvim_init.lua` to `~/.config/nvim/init.lua` on the remote host
2. Copies `tmux.conf` to `~/.tmux.conf` and reloads tmux if running
3. Copies `statusline-command.sh` to `~/.claude/` and makes it executable
4. Merges `claude-settings.json` into `~/.claude/settings.json` (statusline + permissions, preserves existing settings)
5. Runs headless Neovim to auto-install plugins via lazy.nvim

### Prerequisites on remote VMs

- Neovim 0.9+
- git
- jq (for Claude statusline)
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
