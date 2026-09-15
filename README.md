# Neovim Config

Modular, fast Neovim setup for full-stack development. LSP, fuzzy finder, file explorer, git integration, and sensible defaults.

## Requirements

- Neovim `>= 0.12`
- `git`
- `rg` (ripgrep)
- `tree-sitter` CLI (`brew install tree-sitter-cli`; needed to compile parsers)

Optional, depending on your languages:

- `node` (Copilot, emmet-ls)
- `go` (also provides `gofmt`/`goimports`)
- `rust` (provides `rustfmt`)
- `lazygit`

## Install

```bash
mv ~/.config/nvim ~/.config/nvim.backup
git clone <repo-url> ~/.config/nvim
```

Plugins install on first launch. LSP servers and formatters are regular CLI tools installed via Homebrew/npm (no Mason):

```bash
brew install lua-language-server typescript-language-server vscode-langservers-extracted \
  yaml-language-server pyright rust-analyzer tailwindcss-language-server \
  bash-language-server gopls prettier stylua shfmt ruff tree-sitter-cli
npm install -g emmet-ls
```

`clangd` and `clang_format` ship with the Xcode Command Line Tools. Servers that are not installed are skipped silently — only add the ones for languages you use.

## Layout

```text
init.lua                 entry point (leader, providers)
lua/config/options.lua   settings
lua/config/keymaps.lua   global keymaps
lua/config/autocmds.lua  autocommands (autosave, checktime, …)
lua/config/lazy.lua      lazy.nvim setup
lua/plugins/*.lua        one file per concern:
  editor.lua             mini.nvim (pairs/surround/ai/statusline/tabline/icons), which-key
  dev-tools.lua          snacks.nvim (picker, terminal, dashboard, notifier, indent)
  lsp.lua                LSP servers (native vim.lsp API) + keymaps on LspAttach
  completion.lua         blink.cmp + copilot.vim
  formatting.lua         conform.nvim
  git.lua                gitsigns.nvim
  treesitter.lua         nvim-treesitter (main) + nvim-ts-autotag
```

## Verify

```vim
:checkhealth
:Lazy
```

## Common Keys

Leader key: `<Space>`. Prefix groups are labeled by which-key; press the prefix and wait to see all bindings.

### File & Search

```text
<leader>ff   Find files
<leader>fr   Recent files
<leader>fs   Live grep
<leader>fc   Find word under cursor
<leader>fb   Find open buffers (also serves as buffer picker)
<leader>fp   Find projects
<leader>fh   Find help
<leader>fk   Find keymaps
```

### File Explorer

```text
\            Toggle explorer
<leader>ee   Toggle explorer
<leader>ef   Reveal current file
```

Neo-tree provides the sidebar explorer (filesystem, buffers, and git status sources); the sidebar opens automatically at startup and has focus. Dotfiles and gitignored files are hidden by default; press `H` in the tree to show hidden dotfiles. The tree follows the current file and auto-refreshes on file-system events. Files opened from the tree use the native buffer behavior (open in the last window, no forced splits), and the startup dashboard closes automatically so the opened file is visible. Close it with `q` and move focus with the normal window keys (`<C-h>/<C-l>`).

### LSP & Code

```text
gd           Go to definition
gD           Go to declaration
gy           Go to type definition
gi           Go to implementation
gR           Show references
K            Hover docs
<leader>ca   Code actions (normal + visual)
<leader>rn   Rename symbol
<leader>cf   Format file/selection
<leader>ti   Toggle inlay hints
<leader>rs   Restart LSP
```

### Diagnostics

```text
<leader>xx   Workspace diagnostics
<leader>xX   Current-buffer diagnostics
<leader>de   Errors only
<leader>dw   Warnings only
<leader>dd   Line diagnostics (float)
<leader>xc   Copy diagnostics to clipboard
<leader>xs   Document symbols
<leader>xl   LSP references
<leader>xL   Location list
<leader>xQ   Quickfix list
]e / [e      Next/prev error
]w / [w      Next/prev warning
```

### Buffers

```text
<S-h> / <S-l>   Prev/next buffer
<leader>bd      Close buffer
<leader>ba      Alternate buffer
<leader>bo      Close other buffers
<leader>bl      Close buffers to right
<leader>bh      Close buffers to left
```

### Windows & Splits

```text
<leader>sv   Split vertical
<leader>sh   Split horizontal
<leader>sx   Close split
<leader>se   Equalize splits
<C-h/j/k/l>  Navigate windows (works from terminal mode too; <C-n> exits terminal mode)
<C-Arrows>   Resize windows
```

### Git

```text
]c / [c         Next/prev hunk
<leader>hs      Stage hunk (normal + visual)
<leader>hr      Reset hunk (normal + visual)
<leader>hS      Stage buffer
<leader>hR      Reset buffer
<leader>hp      Preview hunk
<leader>hb      Blame line (full)
<leader>hd      Diff this / <leader>hD diff against HEAD~
<leader>gb      Toggle inline blame
<leader>gd      Preview hunk inline
                (<leader>hs unstages when on a staged hunk)
ih              Git hunk text object (operator/pending + visual)
<leader>gl      Open lazygit
```

### Completion & Copilot

```text
<C-Space>    Trigger completion
<CR>         Confirm selection
<Tab>        Next item / snippet jump
<C-j>/<C-k>  Next/prev item
<C-g>        Accept Copilot suggestion (insert mode)
<C-x>        Dismiss Copilot suggestion (insert mode)
```

### Treesitter

```text
<C-space>    Start/grow incremental selection
<BS>         Shrink incremental selection
```

### Terminal

```text
<C-\>        Toggle terminal
<leader>tt   Toggle terminal
<leader>tc   Terminal (custom command)
<leader>tk   Kill terminal
```

### Editing

```text
jk           Exit insert mode
<leader>w    Save file
<leader>q    Quit
<leader>y    Yank to system clipboard
<leader>Y    Yank line to system clipboard
<leader>P    Paste from system clipboard
<leader>p    Paste without yanking (visual)
<A-j>/<A-k>  Move selection down/up (visual)
<C-a>        Select all
n / N        Next/prev search match, centered
<C-d>/<C-u>  Half-page jump, centered
J            Join lines, cursor stays put
< / >        Indent selection and reselect (visual)
, . ;        Undo breakpoints in insert mode
gc / gcc     Comment selection/line (native Neovim)
```

## LSP Servers

Configured in `lua/plugins/lsp.lua` via the native `vim.lsp.config`/`vim.lsp.enable` API: `lua_ls`, `ts_ls`, `html`, `cssls`, `jsonls`, `yamlls`, `pyright`, `clangd`, `rust_analyzer`, `tailwindcss`, `bashls`, `emmet_ls`, `gopls`. Each is enabled only when its executable is on `PATH`, so missing tools never error.

## Formatters

`lua/plugins/formatting.lua` (conform.nvim) maps filetypes to: `prettier` (JS/TS/HTML/CSS/JSON/YAML/MD and friends), `stylua` (Lua), `ruff_format` (Python), `rustfmt`, `goimports`/`gofmt` (Go), `shfmt`, `clang_format` (C/C++). Formatting falls back to LSP when no formatter is configured; bound to `<leader>cf`.

## Maintenance

```bash
./scripts/validate.sh
```

```vim
:Lazy update
:TSUpdate
```
