# Neovim Keybindings Reference

Code-aligned keybinding reference for this configuration.
Leader key: `<Space>`

## General Navigation

| Key | Mode | Description |
|-----|------|-------------|
| `<C-h/j/k/l>` | Normal | Navigate between windows |
| `<C-u>` | Normal | Scroll up and center |
| `<C-d>` | Normal | Scroll down and center |
| `n` / `N` | Normal | Next/previous search result and center |
| `s` | Normal/Visual/Operator | Flash jump |
| `S` | Normal/Visual/Operator | Flash Treesitter jump |
| `<C-a>` | Normal | Select entire buffer |

## Window Management

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>sv` | Normal | Split window vertically |
| `<leader>sh` | Normal | Split window horizontally |
| `<leader>se` | Normal | Equalize split sizes |
| `<leader>sx` | Normal | Close current split |
| `<C-Up>` / `<C-Down>` | Normal | Resize window height |
| `<C-Left>` / `<C-Right>` | Normal | Resize window width |
| `<M-h/j/k/l>` | Normal | Resize window with Alt/Option |

## Buffer Management

This configuration uses `bufferline.nvim` for buffer navigation and `mini.bufremove` for safe closing.

| Key | Mode | Description |
|-----|------|-------------|
| `<S-h>` | Normal | Previous buffer |
| `<S-l>` | Normal | Next buffer |
| `<S-x>` | Normal | Close current buffer, or quit if last |
| `<leader>bd` | Normal | Delete buffer |
| `<leader>bD` | Normal | Force delete buffer |
| `<leader>bp` | Normal | Pin/unpin buffer |
| `<leader>bo` | Normal | Close other buffers |
| `<leader>bl` | Normal | Close buffers to the right |
| `<leader>bh` | Normal | Close buffers to the left |
| `<leader>1` | Normal | Pick buffer to focus |
| `<A-,>` / `<A-.>` | Normal | Move buffer left/right |

## File Explorer

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>ee` | Normal | Toggle file explorer |
| `<leader>ef` | Normal | Toggle file explorer on current file |
| `<leader>ec` | Normal | Collapse file explorer |
| `<leader>er` | Normal | Refresh file explorer |
| `<leader>eo` | Normal | Focus file explorer |
| `<C-e>` | Normal | Toggle focus between file explorer and buffer |

## Search & Find

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>ff` | Normal | Find files |
| `<leader>fr` | Normal | Find recent files |
| `<leader>fs` | Normal | Live grep |
| `<leader>fc` | Normal | Find string under cursor |
| `<leader>ft` | Normal | Find TODO comments |
| `<leader>fp` | Normal | Find projects |

## LSP & Code Actions

These mappings are available after an LSP attaches to the current buffer.

| Key | Mode | Description |
|-----|------|-------------|
| `gd` | Normal | Go to definition (Telescope) |
| `gD` | Normal | Go to declaration |
| `gi` | Normal | Go to implementation (Telescope) |
| `gy` | Normal | Go to type definition (Telescope) |
| `gR` | Normal | Show references (Telescope) |
| `K` | Normal | Hover documentation |
| `<leader>ca` | Normal/Visual | Code actions |
| `<leader>rn` | Normal | Rename symbol |
| `<leader>rs` | Normal | Restart LSP |
| `<leader>ti` | Normal | Cycle inlay hint detail |

## Diagnostics

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>d` | Normal | Show line diagnostics |
| `[e` / `]e` | Normal | Previous/next error |
| `[w` / `]w` | Normal | Previous/next warning |
| `<leader>xx` | Normal | Toggle workspace diagnostics |
| `<leader>xX` | Normal | Toggle buffer diagnostics |
| `<leader>xs` | Normal | Toggle symbols view |
| `<leader>xl` | Normal | Toggle LSP definitions/references |
| `<leader>xL` | Normal | Toggle location list |
| `<leader>xQ` | Normal | Toggle quickfix list |
| `<leader>xc` | Normal | Copy diagnostics to clipboard |
| `<leader>de` | Normal | Show errors only |
| `<leader>dw` | Normal | Show warnings only |

## Refactoring

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>re` | Visual | Extract function |
| `<leader>rf` | Visual | Extract function to file |
| `<leader>rv` | Visual | Extract variable |
| `<leader>ri` | Normal/Visual | Inline variable |
| `<leader>rr` | Visual | Refactor menu |

## Git

### Gitsigns

| Key | Mode | Description |
|-----|------|-------------|
| `]c` / `[c` | Normal | Next/previous hunk |
| `<leader>hs` | Normal/Visual | Stage hunk |
| `<leader>hr` | Normal/Visual | Reset hunk |
| `<leader>hS` | Normal | Stage buffer |
| `<leader>hu` | Normal | Undo stage hunk |
| `<leader>hR` | Normal | Reset buffer |
| `<leader>hp` | Normal | Preview hunk |
| `<leader>hb` | Normal | Blame line |
| `<leader>hd` | Normal | Diff this |
| `<leader>hD` | Normal | Diff this (cached) |
| `<leader>gb` | Normal | Toggle inline blame |
| `<leader>gd` | Normal | Toggle deleted lines |

### AI Commit Workflow

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>gc` | Normal | Commit current/staged changes with AI message |
| `<leader>gC` | Normal | Stage all and commit with AI message |
| `<leader>gy` | Normal | Generate AI commit message and copy to clipboard |
| `<leader>gA` | Normal | Stage all, commit, and push |
| `<leader>gP` | Normal | Push to remote |
| `<leader>ga` | Normal | Switch GitHub account |
| `<leader>gas` | Normal | Show GitHub auth status |

## Completion & AI

### Copilot

| Key | Mode | Description |
|-----|------|-------------|
| `<C-g>` | Insert | Accept suggestion |
| `<C-x>` | Insert | Dismiss suggestion |

### nvim-cmp

| Key | Mode | Description |
|-----|------|-------------|
| `<C-Space>` | Insert | Trigger completion |
| `<C-k>` / `<C-j>` | Insert | Previous/next completion item |
| `<Tab>` / `<S-Tab>` | Insert/Select | Next/previous item or snippet jump |
| `<CR>` | Insert | Confirm selection |
| `<C-e>` | Insert | Abort completion |
| `<C-b>` / `<C-f>` | Insert | Scroll completion docs |

## Terminal & Dev Tools

| Key | Mode | Description |
|-----|------|-------------|
| `<C-\\>` | Normal/Terminal | Toggle terminal |
| `<leader>tt` | Normal/Terminal | Toggle terminal |
| `<leader>tf` | Normal | Floating terminal |
| `<leader>th` | Normal | Horizontal terminal |
| `<leader>tv` | Normal | Vertical terminal |
| `<leader>tc` | Normal | Run custom terminal command |
| `<leader>tk` | Normal/Terminal | Kill terminal |
| `<leader>gl` | Normal | Open lazygit |
| `<leader>lc` | Normal | Toggle Claude terminal |
| `<leader>lG` | Normal | Toggle Gemini terminal |
| `<leader>lx` | Normal | Toggle Codex terminal |
| `<leader>lo` | Normal | Toggle Opencode terminal |
| `<leader>la` | Normal | Toggle Copilot CLI terminal |

## Formatting, Linting, Python, Markdown, Health

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>cf` | Normal/Visual | Format file or selection |
| `<leader>jf` | Normal/Visual | Format file or selection |
| `<leader>jl` | Normal | Toggle auto-linting |
| `<leader>ml` | Normal | Lint current file |
| `<leader>pv` | Normal | Pick Python virtualenv |
| `<leader>mp` | Normal | Toggle markdown rendering |
| `<leader>hc` | Normal | Run config health check |
| `<leader>hC` | Normal | Check config consistency |
| `<leader>hN` | Normal | Run `:checkhealth` |

## Editing Helpers

| Key | Mode | Description |
|-----|------|-------------|
| `jk` | Insert | Exit insert mode |
| `<leader>p` | Visual | Paste without yanking |
| `<leader>y` / `<leader>Y` | Normal/Visual | Yank to system clipboard |
| `<leader>P` | Normal/Visual | Paste from system clipboard |
| `J` | Normal | Join lines without moving cursor |
| `J` / `K` | Visual | Move selected lines down/up |
| `<` / `>` | Visual | Indent and keep selection |
| `gc` / `gcc` | Normal/Visual | Toggle comments |

## Namespaces

- `<leader>b`: Buffer management
- `<leader>c`: Code actions and formatting
- `<leader>d`: Diagnostics filters and floating diagnostics
- `<leader>e`: File explorer
- `<leader>f`: Search and find
- `<leader>g`: Git workflows
- `<leader>h`: Git hunks and health
- `<leader>j`: Formatting and lint toggles
- `<leader>l`: Dev tools and CLI terminals
- `<leader>m`: Markdown and manual lint
- `<leader>p`: Python tools
- `<leader>r`: Refactor, rename, restart
- `<leader>s`: Splits
- `<leader>t`: Terminals and toggles
- `<leader>x`: Trouble views
