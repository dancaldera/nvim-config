# Neovim Keybindings Reference

Comprehensive keybinding reference for this Neovim configuration.
Leader key: `<Space>`

## Table of Contents
- [General Navigation](#general-navigation)
- [Window Management](#window-management)
- [Tab Management](#tab-management)
- [Buffer Management](#buffer-management)
- [File Operations](#file-operations)
- [Search & Find (Telescope)](#search--find-telescope)
- [LSP & Code Actions](#lsp--code-actions)
- [Diagnostics](#diagnostics)
- [Refactoring](#refactoring)
- [Git Operations](#git-operations)
- [Completion & AI](#completion--ai)
- [Terminal](#terminal)
- [Folding](#folding)
- [Miscellaneous](#miscellaneous)

---

## General Navigation

| Key | Mode | Description |
|-----|------|-------------|
| `<C-h/j/k/l>` | Normal | Navigate between windows |
| `<C-u>` | Normal | Scroll half page up (with smooth scroll) |
| `<C-d>` | Normal | Scroll half page down (with smooth scroll) |
| `<C-b>` | Normal | Scroll full page up (with smooth scroll) |
| `<C-f>` | Normal | Scroll full page down (with smooth scroll) |
| `s` | Normal/Visual/Operator | Flash jump (modern motion) |
| `S` | Normal/Visual/Operator | Flash treesitter jump |
| `<C-a>` | Normal | Select all text |

---

## Window Management

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>sv` | Normal | Split window vertically |
| `<leader>sh` | Normal | Split window horizontally |
| `<leader>se` | Normal | Make splits equal size |
| `<leader>sx` | Normal | Close current split |
| `<C-Up>` | Normal | Increase window height |
| `<C-Down>` | Normal | Decrease window height |
| `<C-Left>` | Normal | Decrease window width |
| `<C-Right>` | Normal | Increase window width |
| `<M-h>` | Normal | Decrease window width (Alt+h) |
| `<M-l>` | Normal | Increase window width (Alt+l) |
| `<M-j>` | Normal | Increase window height (Alt+j) |
| `<M-k>` | Normal | Decrease window height (Alt+k) |

---

## Buffer Management

**Note:** This configuration uses **nvim-cokeline** for buffer management.

| Key | Mode | Description |
|-----|------|-------------|
| `<S-h>` | Normal | Previous buffer |
| `<S-l>` | Normal | Next buffer |
| `<leader>bd` | Normal | Delete buffer (with mini.bufremove) |

---

## File Operations

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>e` | Normal | Toggle nvim-tree file explorer |
| `<C-e>` | Normal | Toggle focus between file explorer and buffer |
| `<leader>w` | Normal | Write/save file |
| `<leader>q` | Normal | Quit window |
| `<leader>Q` | Normal | Quit all windows |

---

## Search & Find (Telescope)

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>ff` | Normal | Find files (fuzzy finder) |
| `<leader>fr` | Normal | Find recent files |
| `<leader>fs` | Normal | Find string in current working directory |
| `<leader>fc` | Normal | Find string under cursor |
| `<leader>fb` | Normal | Find buffers |
| `<leader>fh` | Normal | Find help tags |
| `<leader>fk` | Normal | Find keymaps |
| `<leader>fp` | Normal | Find projects |
| `<leader>ft` | Normal | Find TODO comments |
| `<leader>sr` | Normal | Search and replace (Spectre) |

---

## LSP & Code Actions

| Key | Mode | Description |
|-----|------|-------------|
| `gD` | Normal | Go to declaration |
| `gd` | Normal | Go to definition (Telescope) |
| `gi` | Normal | Go to implementation (Telescope) |
| `gy` | Normal | Go to type definition (Telescope) |
| `gR` | Normal | Show LSP references (Telescope) |
| `K` | Normal | Show hover documentation |
| `<C-s>` | Insert | Show signature help |
| `<leader>ca` | Normal/Visual | Code actions (with preview) |
| `<leader>rn` | Normal | Rename symbol |
| `<leader>rs` | Normal | Restart LSP |
| `<leader>ti` | Normal | Toggle/cycle inlay hints |
| `<leader>a` | Normal | Toggle Aerial (code outline) |

---

## Diagnostics

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>d` | Normal | Show line diagnostics (float) |
| `<leader>D` | Normal | Show buffer diagnostics (Telescope) |
| `[d` | Normal | Go to previous diagnostic |
| `]d` | Normal | Go to next diagnostic |
| `[e` | Normal | Go to previous error |
| `]e` | Normal | Go to next error |
| `[w` | Normal | Go to previous warning |
| `]w` | Normal | Go to next warning |
| `<leader>xx` | Normal | Toggle Trouble diagnostics |
| `<leader>xX` | Normal | Toggle Trouble buffer diagnostics |
| `<leader>cs` | Normal | Toggle Trouble symbols |
| `<leader>cl` | Normal | Toggle Trouble LSP definitions/references |
| `<leader>xL` | Normal | Toggle Trouble location list |
| `<leader>xQ` | Normal | Toggle Trouble quickfix list |

---

## Refactoring

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>re` | Visual | Extract function |
| `<leader>rf` | Visual | Extract function to file |
| `<leader>rv` | Visual | Extract variable |
| `<leader>ri` | Normal/Visual | Inline variable |
| `<leader>rr` | Visual | Show refactor menu (Telescope) |

---

## Git Operations

### Git Hunks (Gitsigns)

**Note:** This configuration uses **Gitsigns** for git integration.

| Key | Mode | Description |
|-----|------|-------------|
| `]c` | Normal | Next git hunk |
| `[c` | Normal | Previous git hunk |
| `<leader>hs` | Normal/Visual | Stage hunk |
| `<leader>hr` | Normal/Visual | Reset hunk |
| `<leader>hS` | Normal | Stage buffer |
| `<leader>hu` | Normal | Undo stage hunk |
| `<leader>hR` | Normal | Reset buffer |
| `<leader>hp` | Normal | Preview hunk |
| `<leader>hb` | Normal | Blame line |
| `<leader>hd` | Normal | Diff this |
| `<leader>hD` | Normal | Diff this (cached) |
| `<leader>gb` | Normal | Toggle inline line blame |
| `<leader>gd` | Normal | Toggle deleted lines |

---

## Completion & AI

### AI Completion (GitHub Copilot)
| Key | Mode | Description |
|-----|------|-------------|
| `<C-g>` | Insert | Accept AI suggestion |
| `<C-;>` | Insert | Next AI suggestion |
| `<C-,>` | Insert | Previous AI suggestion |
| `<C-x>` | Insert | Dismiss AI suggestion |
| `<M-CR>` | Insert | Open Copilot panel with alternatives |

### LSP Completion (nvim-cmp)
| Key | Mode | Description |
|-----|------|-------------|
| `<C-Space>` | Insert | Trigger completion |
| `<C-k>` | Insert | Previous completion item |
| `<C-j>` | Insert | Next completion item |
| `<Tab>` | Insert | Next item / expand snippet |
| `<S-Tab>` | Insert | Previous item / jump back in snippet |
| `<CR>` | Insert | Confirm selection |
| `<C-e>` | Insert | Abort completion |
| `<C-b>` | Insert | Scroll docs up |
| `<C-f>` | Insert | Scroll docs down |

---

## Terminal

| Key | Mode | Description |
|-----|------|-------------|
| `<C-\>` | Normal | Toggle terminal |
| `<leader>tf` | Normal | Toggle floating terminal |
| `<leader>th` | Normal | Toggle horizontal terminal |
| `<leader>tv` | Normal | Toggle vertical terminal |
| `<Esc><Esc>` | Terminal | Exit terminal mode |

---

## Folding

| Key | Mode | Description |
|-----|------|-------------|
| `zR` | Normal | Open all folds |
| `zM` | Normal | Close all folds |
| `zr` | Normal | Open one fold level |
| `zm` | Normal | Close one fold level |
| `zo` | Normal | Open fold under cursor |
| `zc` | Normal | Close fold under cursor |
| `za` | Normal | Toggle fold under cursor |

---

## Miscellaneous

### Editing
| Key | Mode | Description |
|-----|------|-------------|
| `<leader>p` | Visual | Paste without yanking |
| `<leader>dd` | Normal/Visual | Delete without yanking |
| `<leader>y` | Normal/Visual | Yank to system clipboard |
| `<leader>Y` | Normal/Visual | Yank line to system clipboard |
| `<leader>P` | Normal/Visual | Paste from system clipboard |
| `<` | Visual | Indent left (repeatable) |
| `>` | Visual | Indent right (repeatable) |
| `J` | Visual | Move selected lines down |
| `K` | Visual | Move selected lines up |
| `gc` | Normal/Visual | Toggle comment (Comment.nvim) |
| `gcc` | Normal | Comment current line |

### TODO Comments
| Key | Mode | Description |
|-----|------|-------------|
| `]t` | Normal | Next TODO comment |
| `[t` | Normal | Previous TODO comment |
| `<leader>ft` | Normal | Find TODO comments (Telescope) |

### Sessions
| Key | Mode | Description |
|-----|------|-------------|
| `<leader>qs` | Normal | Restore session |
| `<leader>ql` | Normal | Restore last session |
| `<leader>qd` | Normal | Stop session saving |

### Formatting & Linting
| Key | Mode | Description |
|-----|------|-------------|
| `<leader>jf` | Normal/Visual | Format buffer (conform.nvim) |
| `<leader>jl` | Normal | Toggle auto-linting |
| `<leader>mp` | Normal/Visual | Format buffer (alias) |

### Health & Diagnostics
| Key | Mode | Description |
|-----|------|-------------|
| `<leader>hc` | Normal | Run health check |
| `<leader>hs` | Normal | Run health summary |

### Notifications
| Key | Mode | Description |
|-----|------|-------------|
| `<leader>snd` | Normal | Dismiss all notifications (Noice) |

---

## Keybinding Namespaces

This configuration uses logical namespaces for leader keybindings:

- `<leader>f` - **Find/Search** (Telescope)
- `<leader>g` - **Git** operations (Gitsigns)
- `<leader>h` - **Git Hunks** (Gitsigns staging/reset)
- `<leader>s` - **Search/Splits** (Spectre, window splits)
- `<leader>t` - **Toggle/Terminal** ⚠️ **OVERLOADED NAMESPACE**
  - `tb/td` - Git toggles (blame, deleted)
  - `ti` - LSP inlay hints toggle
  - `tf/th/tv/tc/tt` - Terminal commands
- `<leader>j` - **Just** (quick actions: format, lint)
- `<leader>r` - **Refactoring/Rename**
- `<leader>d` - **Diagnostics**
- `<leader>x` - **Trouble** (diagnostics/quickfix)
- `<leader>c` - **Code** (LSP actions)
- `<leader>q` - **Quit/Sessions**
- `<leader>m` - **Markdown/Format**
- `<leader>a` - **Aerial** (code outline)
- `<leader>y/Y/P` - **Clipboard** operations

**Note:** The `<leader>t` namespace is currently overloaded with multiple purposes. Use `:WhichKey <leader>t` to see all available options.

---

*Last updated: 2025-01-13*
*This configuration uses Neovim 0.10+ with lazy.nvim plugin manager*
