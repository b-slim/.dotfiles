# Dotfiles

Personal Neovim and tmux configurations with a deploy script for remote Linux VMs.

## Contents

| File | Description |
|------|-------------|
| `nvim_init.lua` | Neovim config with markdown editing support (folding, TOC sidebar, render-markdown, header navigation, URL opening) |
| `tmux.conf` | Tmux configuration |

## Deploy to Remote VMs

The `deploy-dotfiles` script (installed at `~/bin/deploy-dotfiles`) copies both configs to remote hosts and auto-installs Neovim plugins.

```bash
# Single host
deploy-dotfiles user@vm1

# Multiple hosts
deploy-dotfiles user@vm1 user@vm2 user@vm3
```

### What it does per host

1. Rsyncs `~/.config/nvim/` (Neovim config)
2. Copies `~/.tmux.conf` and reloads tmux if running
3. Runs headless Neovim to auto-install plugins via lazy.nvim

### Prerequisites on remote VMs

- Neovim 0.9+
- git
- A Nerd Font in your terminal (for icons)

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
