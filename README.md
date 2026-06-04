# Neovim Config

Modular, fast Neovim setup for full-stack development. LSP, fuzzy finder, file explorer, git integration, and sensible defaults.

## Requirements

- Neovim `>= 0.10` (`0.11+` recommended)
- `git`
- `rg` (ripgrep)

Optional, depending on your languages:

- `node`
- `go`
- `rust`
- `lazygit`

## Install

```bash
mv ~/.config/nvim ~/.config/nvim.backup
git clone <repo-url> ~/.config/nvim
nvim
```

Plugins and Mason-managed tools install on first launch.

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
<leader>fb   Find open buffers
<leader>fp   Find projects
<leader>fh   Find help
<leader>fk   Find keymaps
```

### File Explorer

```text
<leader>ee   Toggle explorer
<leader>ef   Reveal current file
<leader>ec   Close explorer
<leader>er   Refresh explorer
\\           Toggle explorer
```

### LSP & Code

```text
gd           Go to definition
gR           Show references
K            Hover docs
<leader>ca   Code actions
<leader>rn   Rename symbol
<leader>cf   Format file/selection
<leader>rs   Restart LSP
```

### Diagnostics

```text
<leader>xx   Workspace diagnostics
<leader>d    Line diagnostics
]e / [e      Prev/next error
]w / [w      Prev/next warning
```

### Buffers

```text
<S-h> / <S-l>   Prev/next buffer
<leader>bd      Close buffer
<leader>bp      Pin buffer
<leader>bo      Close other buffers
```

### Windows

```text
<leader>sv   Split vertical
<leader>sh   Split horizontal
<leader>sx   Close split
<leader>se   Equalize splits
<C-h/j/k/l>  Navigate windows
```

### Git

```text
]c / [c         Next/prev hunk
<leader>hs      Stage hunk
<leader>hp      Preview hunk
<leader>gb      Toggle inline blame
<leader>gl      Open lazygit
```

### Completion

```text
<C-Space>    Trigger completion
<CR>         Confirm selection
<Tab>        Next item / snippet jump
```

### Terminal

```text
<C-\>        Toggle terminal
<leader>tt   Open terminal
<leader>tc   Terminal (custom command)
<leader>tk   Kill terminal
```

### Editing

```text
jk           Exit insert mode
<leader>y    Yank to system clipboard
<leader>P    Paste from system clipboard
s / S        Flash jump / Treesitter jump
```

## LSP Servers

Auto-installed via Mason: `lua_ls`, `ts_ls`, `html`, `cssls`, `jsonls`, `yamlls`, `pyright`, `gopls`, `rust_analyzer`, `clangd`, `tailwindcss`, `bashls`, `emmet_ls`

Auto-installed formatters: `prettier`, `stylua`, `shfmt`, `ruff`

## Maintenance

```bash
./scripts/validate.sh
```

```vim
:Lazy update
:MasonUpdate
:TSUpdate
```
