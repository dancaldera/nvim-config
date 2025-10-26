# Neovim Key Bindings Reference

This document provides a comprehensive guide to all key bindings in this Neovim configuration.

## 🔧 Leader Key

The leader key is set to **Space** (`<Space>`). All leader-based shortcuts are prefixed with `<leader>`.

## 📚 General Navigation & Editing

### Basic Operations
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `jk` | Insert | `<ESC>` | Exit insert mode |
| `<leader>w` | Normal | `:w<CR>` | Save file |
| `<leader>q` | Normal | `:q<CR>` | Quit |
| `<leader>x` | Normal | `:wq<CR>` | Save and quit |
| `<leader>nh` | Normal | `:nohl<CR>` | Clear search highlights |

### Number Operations
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>+` | Normal | `<C-a>` | Increment number under cursor |
| `<leader>-` | Normal | `<C-x>` | Decrement number under cursor |

### Text Movement (Visual Mode)
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<Alt-j>` | Visual | `:m .+1<CR>==` | Move selected text down |
| `<Alt-k>` | Visual | `:m .-2<CR>==` | Move selected text up |
| `<` | Visual | `<gv` | Indent left and reselect |
| `>` | Visual | `>gv` | Indent right and reselect |
| `p` | Visual | `"_dP` | Paste without overwriting register |

### Enhanced Navigation
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<C-d>` | Normal | `<C-d>zz` | Scroll down and center cursor |
| `<C-u>` | Normal | `<C-u>zz` | Scroll up and center cursor |
| `n` | Normal | `nzzzv` | Next search result and center |
| `N` | Normal | `Nzzzv` | Previous search result and center |

## 🪟 Window Management

### Window Splits
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>sv` | Normal | `<C-w>v` | Split window vertically |
| `<leader>sh` | Normal | `<C-w>s` | Split window horizontally |
| `<leader>se` | Normal | `<C-w>=` | Make splits equal size |
| `<leader>sx` | Normal | `:close<CR>` | Close current split |

### Window Navigation
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<C-h>` | Normal | `<C-w>h` | Navigate to left window |
| `<C-j>` | Normal | `<C-w>j` | Navigate to bottom window |
| `<C-k>` | Normal | `<C-w>k` | Navigate to top window |
| `<C-l>` | Normal | `<C-w>l` | Navigate to right window |

### Window Resizing
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<C-Up>` | Normal | `:resize +2<CR>` | Increase window height |
| `<C-Down>` | Normal | `:resize -2<CR>` | Decrease window height |
| `<C-Left>` | Normal | `:vertical resize -2<CR>` | Decrease window width |
| `<C-Right>` | Normal | `:vertical resize +2<CR>` | Increase window width |

## 📑 Tab Management

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>to` | Normal | `:tabnew<CR>` | Open new tab |
| `<leader>tx` | Normal | `:tabclose<CR>` | Close current tab |
| `<leader>tn` | Normal | `:tabn<CR>` | Go to next tab |
| `<leader>tp` | Normal | `:tabp<CR>` | Go to previous tab |
| `<leader>tf` | Normal | `:tabnew %<CR>` | Open current buffer in new tab |

## 📄 Buffer Management

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<S-l>` | Normal | `:bnext<CR>` | Next buffer |
| `<S-h>` | Normal | `:bprevious<CR>` | Previous buffer |
| `<leader>bd` | Normal | `:bdelete<CR>` | Delete current buffer |

## 📁 File Explorer (nvim-tree)

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>ee` | Normal | `:NvimTreeToggle<CR>` | Toggle file explorer |
| `<leader>ef` | Normal | `:NvimTreeFindFileToggle<CR>` | Toggle file explorer on current file |
| `<leader>ec` | Normal | `:NvimTreeCollapse<CR>` | Collapse file explorer |
| `<leader>er` | Normal | `:NvimTreeRefresh<CR>` | Refresh file explorer |

### Within nvim-tree
| Key | Action | Description |
|-----|--------|-------------|
| `a` | Create file/folder | Add new file or folder |
| `d` | Delete | Delete file/folder |
| `r` | Rename | Rename file/folder |
| `x` | Cut | Cut file/folder |
| `c` | Copy | Copy file/folder |
| `p` | Paste | Paste file/folder |
| `<CR>` | Open | Open file or toggle folder |
| `o` | Open | Open file in current window |
| `<C-v>` | Open vertical | Open file in vertical split |
| `<C-x>` | Open horizontal | Open file in horizontal split |
| `<C-t>` | Open tab | Open file in new tab |
| `R` | Refresh | Refresh tree |
| `H` | Toggle hidden | Show/hide hidden files |
| `I` | Toggle gitignore | Show/hide gitignored files |

## 🔍 Fuzzy Finding (Telescope)

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>ff` | Normal | `Telescope find_files` | Find files in current directory |
| `<leader>fr` | Normal | `Telescope oldfiles` | Find recent files |
| `<leader>fs` | Normal | `Telescope live_grep` | Search text in current directory |
| `<leader>fc` | Normal | `Telescope grep_string` | Find word under cursor |

### Within Telescope
| Key | Action | Description |
|-----|--------|-------------|
| `<C-k>` | Previous | Move to previous result |
| `<C-j>` | Next | Move to next result |
| `<C-q>` | Quick fix | Send selected to quickfix list |
| `<CR>` | Open | Open selected file |
| `<C-v>` | Vertical split | Open in vertical split |
| `<C-x>` | Horizontal split | Open in horizontal split |
| `<C-t>` | Tab | Open in new tab |

## 🧠 LSP (Language Server Protocol)

### Code Navigation
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `gR` | Normal | `Telescope lsp_references` | Show LSP references |
| `gD` | Normal | `vim.lsp.buf.declaration` | Go to declaration |
| `gd` | Normal | `Telescope lsp_definitions` | Show LSP definitions |
| `gi` | Normal | `Telescope lsp_implementations` | Show LSP implementations |
| `gt` | Normal | `Telescope lsp_type_definitions` | Show LSP type definitions |
| `K` | Normal | `vim.lsp.buf.hover` | Show documentation for cursor |

### Code Actions
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>ca` | Normal/Visual | `vim.lsp.buf.code_action` | See available code actions |
| `<leader>rn` | Normal | `vim.lsp.buf.rename` | Smart rename |
| `<leader>rs` | Normal | `:LspRestart<CR>` | Restart LSP |

### Diagnostics
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>D` | Normal | `Telescope diagnostics` | Show buffer diagnostics |
| `<leader>d` | Normal | `vim.diagnostic.open_float` | Show line diagnostics |
| `[d` | Normal | `vim.diagnostic.goto_prev` | Go to previous diagnostic |
| `]d` | Normal | `vim.diagnostic.goto_next` | Go to next diagnostic |

## ✏️ Autocompletion

### In Insert Mode
| Key | Action | Description |
|-----|--------|-------------|
| `<C-k>` | Previous suggestion | Move to previous completion item |
| `<C-j>` | Next suggestion | Move to next completion item |
| `<C-b>` | Scroll docs up | Scroll documentation up |
| `<C-f>` | Scroll docs down | Scroll documentation down |
| `<C-Space>` | Show completions | Trigger completion menu |
| `<C-e>` | Abort | Close completion window |
| `<CR>` | Accept | Accept selected completion |

## 🎨 Code Formatting

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>mp` | Normal/Visual | Format code | Format file or selected range |

**Note:** Code formatting also happens automatically on save for supported file types.

## 🔄 Git Integration (Gitsigns)

### Hunk Navigation
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `]c` | Normal | Next hunk | Go to next git hunk |
| `[c` | Normal | Previous hunk | Go to previous git hunk |

### Hunk Actions
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>hs` | Normal/Visual | Stage hunk | Stage current/selected hunk |
| `<leader>hr` | Normal/Visual | Reset hunk | Reset current/selected hunk |
| `<leader>hS` | Normal | Stage buffer | Stage entire buffer |
| `<leader>hu` | Normal | Undo stage hunk | Undo last staged hunk |
| `<leader>hR` | Normal | Reset buffer | Reset entire buffer |
| `<leader>hp` | Normal | Preview hunk | Preview hunk changes |
| `<leader>hb` | Normal | Blame line | Show git blame for line |
| `<leader>hd` | Normal | Diff this | Show diff for current file |
| `<leader>hD` | Normal | Diff this ~ | Show diff against HEAD~ |

### Toggles
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>tb` | Normal | Toggle line blame | Toggle current line blame |
| `<leader>td` | Normal | Toggle deleted | Toggle showing deleted lines |

## 💬 Comments

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `gcc` | Normal | Comment line | Toggle comment on current line |
| `gc` | Visual | Comment selection | Toggle comment on selection |
| `gbc` | Normal | Block comment | Toggle block comment |
| `gb` | Visual | Block comment | Toggle block comment on selection |

## 🔄 Surround Operations

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `ys{motion}{char}` | Normal | Add surround | Surround motion with character |
| `yss{char}` | Normal | Surround line | Surround entire line |
| `ds{char}` | Normal | Delete surround | Delete surrounding character |
| `cs{old}{new}` | Normal | Change surround | Change surrounding character |

### Examples:
- `ysiw"` - Surround word with quotes
- `yss(` - Surround line with parentheses
- `ds"` - Delete surrounding quotes
- `cs"'` - Change double quotes to single quotes

## 🎯 Text Objects (with treesitter)

### Incremental Selection
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<C-space>` | Normal | Init selection | Start incremental selection |
| `<C-space>` | Visual | Expand selection | Expand selection to next node |
| `<BS>` | Visual | Shrink selection | Shrink selection to previous node |

### Git Text Objects
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `ih` | Operator/Visual | Select hunk | Select current git hunk |

## ⚡ Quick Tips

### Useful Combinations
1. **Quick file navigation**: `<leader>ff` → type filename → `<CR>`
2. **Find and replace**: `<leader>fs` → type search term → `<C-q>` → `:cdo s/old/new/g`
3. **Code formatting**: `<leader>mp` (auto-formats on save too!)
4. **Git workflow**: `]c` → `<leader>hp` → `<leader>hs` (next hunk → preview → stage)
5. **LSP workflow**: `gd` → `K` → `<leader>ca` (definition → docs → actions)
6. **Quick save and exit**: `<leader>w` → `<leader>x` (save → save and quit)
7. **Split and navigate**: `<leader>sv` → `<C-l>` (split vertically → move to right pane)

### Pro Tips
- Use `<C-o>` and `<C-i>` to navigate through jump history
- `:q` closes current window, `:qa` closes all windows
- `<leader>` followed by waiting will show available commands (which-key)
- Most plugins support both mouse and keyboard navigation
- Use `:checkhealth` to diagnose configuration issues
- Use `:Mason` to install additional language servers and formatters
- Press `?` in most plugin windows to see help and available keybindings
- Use `:Lazy` to manage and update plugins
- Format on save is enabled - your code will be automatically formatted!

### Key Sequence Examples
- **Open file explorer and create new file**: `<leader>ee` → `a` → type filename → `<CR>`
- **Search for text and replace globally**: `<leader>fs` → type search → `<C-q>` → `:cdo s/old/new/gc`
- **Navigate to definition and back**: `gd` → `<C-o>` (go to definition → jump back)
- **Stage git changes**: `]c` → `<leader>hs` → `]c` → `<leader>hs` (next hunk → stage → repeat)

---

Remember: This configuration is designed to be discoverable. When in doubt, press `<leader>` and wait to see available options, or use `:help <command>` for detailed help on any Neovim feature.