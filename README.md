# AI Neovim Configuration

Personal Neovim configuration for full-stack development with LSP, Telescope, Treesitter, Copilot, and git tooling.

## Requirements

- Neovim `>= 0.10` (`0.11+` recommended)
- `git`
- `rg`

Optional, depending on your languages and features:

- `node`
- `python3`
- `go`
- `rust`
- `gh`
- `curl`

## Install

```bash
mv ~/.config/nvim ~/.config/nvim.backup
git clone <repo-url> ~/.config/nvim
nvim
```

Plugins and Mason-managed tools install on first launch.

## AI Setup

Copilot:

```vim
:Copilot auth
```

AI commit messages:

- `OPENAI_API_KEY`, or
- `OPENROUTER_API_KEY`

Keys can be set in the environment or in `~/.zshrc`, `~/.bashrc`, `~/.zprofile`, or `~/.env`.

## Verify

```vim
:checkhealth
:Lazy
:Mason
```

## Common Keys

```text
<leader>ff   Find files
<leader>fs   Live grep
<leader>ee   Toggle file explorer
gd           Go to definition
K            Hover
<leader>ca   Code actions
<leader>xx   Diagnostics list
<C-g>        Accept Copilot suggestion
<C-x>        Dismiss Copilot suggestion
<leader>gc   Commit with AI message
<leader>gy   Copy AI commit message
<leader>gA   Commit all and push
<leader>gP   Push
```

## AI Agent Terminals

```text
<leader>lc   Toggle Claude
<leader>lx   Toggle Codex
<leader>lG   Toggle Gemini
<leader>lo   Toggle Opencode
<leader>la   Toggle Copilot CLI
<leader>gl   Open lazygit
```

## Maintenance

```vim
:Lazy update
:MasonUpdate
:TSUpdate
```

## Docs

- [`docs/KEYBINDINGS.md`](/Users/danielcaldera/.config/nvim/docs/KEYBINDINGS.md)
- [`docs/ARCHITECTURE.md`](/Users/danielcaldera/.config/nvim/docs/ARCHITECTURE.md)
- [`docs/TROUBLESHOOTING.md`](/Users/danielcaldera/.config/nvim/docs/TROUBLESHOOTING.md)
