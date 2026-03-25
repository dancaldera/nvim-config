# Neovim Config

Modular, fast Neovim setup for full-stack development. 82 plugins, <50ms startup, AI-first workflow with Copilot, multi-agent terminal (Claude, Gemini, Codex, Opencode), AI-assisted git commits, LSP across 13 languages, and DAP debugging.

## Requirements

- Neovim `>= 0.10` (`0.11+` recommended)
- `git`
- `rg`

Optional, depending on your languages and features:

- `node`
- `python3`
- `go`
- `rust`
- `lazygit`
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

Leader key: `<Space>`

### File & Search

```text
<leader>ff   Find files
<leader>fr   Recent files
<leader>fs   Live grep
<leader>fc   Find word under cursor
<leader>ft   Find TODOs
<leader>fp   Find projects
```

### File Explorer

```text
<leader>ee   Toggle explorer
<leader>ef   Reveal current file
<leader>ec   Collapse explorer
<leader>er   Refresh explorer
```

### LSP & Code

```text
gd           Go to definition
gR           Show references
K            Hover docs
<leader>ca   Code actions
<leader>rn   Rename symbol
<leader>cf   Format file/selection
<leader>ti   Cycle inlay hints
<leader>rs   Restart LSP
```

### Diagnostics

```text
<leader>xx   Workspace diagnostics
<leader>d    Line diagnostics
[e / ]e      Prev/next error
[w / ]w      Prev/next warning
```

### Buffers

```text
<S-h> / <S-l>   Prev/next buffer
<S-x>           Close buffer
<leader>bp       Pin buffer
<leader>bo       Close other buffers
```

### Windows

```text
<leader>sv   Split vertical
<leader>sh   Split horizontal
<leader>sx   Close split
<leader>se   Equalize splits
```

### Git

```text
]c / [c         Next/prev hunk
<leader>hs      Stage hunk
<leader>hp      Preview hunk
<leader>gb      Toggle inline blame
<leader>gc      Commit with AI message
<leader>gC      Stage all and commit with AI
<leader>gy      Copy AI commit message
<leader>gA      Stage all, commit, and push
<leader>gP      Push
<leader>gl      Open lazygit
```

### Completion & Copilot

```text
<C-g>        Accept Copilot suggestion
<C-x>        Dismiss Copilot suggestion
<C-Space>    Trigger completion
<CR>         Confirm selection
<Tab>        Next item / snippet jump
```

### Terminal

```text
<C-\>        Toggle terminal
<leader>lc   Toggle Claude
<leader>lx   Toggle Codex
<leader>lG   Toggle Gemini
<leader>lo   Toggle Opencode
<leader>la   Toggle Copilot CLI
```

### Editing

```text
s / S            Flash jump / Treesitter jump
jk               Exit insert mode
<leader>re       Extract function (visual)
<leader>rv       Extract variable (visual)
<leader>y        Yank to system clipboard
<leader>P        Paste from system clipboard
```

## LSP Servers

Auto-installed via Mason: `lua_ls`, `ts_ls`, `html`, `cssls`, `jsonls`, `yamlls`, `pyright`, `gopls`, `rust_analyzer`, `clangd`, `tailwindcss`, `bashls`, `emmet_ls`

Auto-installed formatters/linters: `prettier`, `stylua`, `eslint_d`, `ruff`, `black`, `isort`, `shfmt`, `golangci-lint`

## Maintenance

```vim
:Lazy update
:MasonUpdate
:TSUpdate
```

## Docs

- [`docs/KEYBINDINGS.md`](docs/KEYBINDINGS.md)
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)
- [`docs/PLUGINS_REFERENCE.md`](docs/PLUGINS_REFERENCE.md)
- [`docs/LSP_GUIDE.md`](docs/LSP_GUIDE.md)
- [`docs/SETUP_FORMATTERS.md`](docs/SETUP_FORMATTERS.md)
- [`docs/PERFORMANCE.md`](docs/PERFORMANCE.md)
- [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md)
