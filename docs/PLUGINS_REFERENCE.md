# Plugins Reference

Complete reference for all 42 plugins used in this Neovim configuration, organized by category.

> **Neovim Version**: 0.10+ required, 0.11+ recommended

---

## Table of Contents

- [LSP & Language Intelligence](#lsp--language-intelligence)
- [Completion & Snippets](#completion--snippets)
- [Editor Enhancements](#editor-enhancements)
- [UI & Visual](#ui--visual)
- [Git Integration](#git-integration)
- [Developer Tools](#developer-tools)
- [Diagnostics](#diagnostics)
- [Treesitter](#treesitter)
- [Navigation & Search](#navigation--search)
- [File Management](#file-management)
- [Formatting & Linting](#formatting--linting)
- [Language-Specific](#language-specific)
- [Custom Modules](#custom-modules)
- [Quick Reference Table](#quick-reference-table)

---

## LSP & Language Intelligence

**Config file**: `lua/plugins/lsp.lua`

### williamboman/mason.nvim
Package manager for LSP servers, formatters, linters, and DAP adapters. Provides a UI (`:Mason`) for browsing and installing tools.

### williamboman/mason-lspconfig.nvim
Bridges mason.nvim and nvim-lspconfig, ensuring installed servers are automatically configured and started.

### WhoIsSethDaniel/mason-tool-installer.nvim
Declarative auto-installation of formatters and linters via Mason. Tools listed in `ensure_installed` are installed on startup without manual intervention.

### neovim/nvim-lspconfig
Core LSP client configuration. Provides default configs for dozens of language servers. Servers configured include: `ts_ls`, `lua_ls`, `pyright`, `gopls`, `clangd`, `rust_analyzer`, and others.

| Keybinding | Action |
|---|---|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | Go to references |
| `gi` | Go to implementation |
| `K` | Hover documentation |
| `<leader>ca` | Code actions |
| `<leader>rn` | Rename symbol |
| `<leader>D` | Type definition |
| `]d` / `[d` | Next/previous diagnostic |

### hrsh7th/cmp-nvim-lsp
Extends nvim-cmp with LSP completion capabilities. Advertises additional completion features to language servers. Shared between `lsp.lua` and `completion.lua`.

### antosha417/nvim-lsp-file-operations
LSP-aware file operations. When files are renamed or moved (e.g., via nvim-tree), import paths are automatically updated through the language server.

### folke/lazydev.nvim
Development support for Neovim Lua configuration and plugin authoring. Provides type annotations, completion, and documentation for the Neovim API, `vim.uv`, and plugin APIs.

### Bilal2453/luvit-meta
Type definitions for `vim.uv` (libuv bindings). Used by lazydev.nvim to provide accurate completions for async I/O operations.

---

## Completion & Snippets

**Config file**: `lua/plugins/completion.lua`

### zbirenbaum/copilot.lua
GitHub Copilot integration providing inline ghost text suggestions.

| Keybinding | Action |
|---|---|
| `C-g` | Accept suggestion |
| `C-;` | Next suggestion |
| `C-x` | Dismiss suggestion |

### hrsh7th/nvim-cmp
Main completion engine. Aggregates completions from multiple sources (LSP, buffer, path, snippets) into a single popup menu with fuzzy matching and sorting.

| Keybinding | Action |
|---|---|
| `Tab` | Next item / expand snippet |
| `S-Tab` | Previous item |
| `CR` | Confirm selection |
| `C-Space` | Trigger completion |
| `C-e` | Abort completion |

### hrsh7th/cmp-buffer
Completion source that suggests words from open buffers.

### hrsh7th/cmp-path
Completion source for filesystem paths. Supports both absolute and relative paths.

### L3MON4D3/LuaSnip
Snippet engine with support for VS Code snippet format, variable transforms, and choice nodes. Loads snippets from friendly-snippets.

### rafamadriz/friendly-snippets
Collection of pre-built snippets in VS Code format covering most popular languages and frameworks.

### saadparwaiz1/cmp_luasnip
Bridge between LuaSnip and nvim-cmp, exposing snippets as a completion source.

### onsails/lspkind.nvim
Adds VS Code-like pictograms (icons) to completion menu items, indicating the kind of each completion (function, variable, class, etc.).

---

## Editor Enhancements

**Config file**: `lua/plugins/editor.lua`

### windwp/nvim-autopairs
Automatically inserts matching brackets, quotes, and parentheses. Integrates with nvim-cmp to insert pairs after selecting a function completion.

### kylechui/nvim-surround
Manipulate surrounding characters (brackets, quotes, tags, etc.).

| Keybinding | Action |
|---|---|
| `ys{motion}{char}` | Add surrounding |
| `ds{char}` | Delete surrounding |
| `cs{old}{new}` | Change surrounding |

### numToStr/Comment.nvim
Toggle comments with motions and visual selections.

| Keybinding | Action |
|---|---|
| `gcc` | Toggle line comment |
| `gc{motion}` | Toggle comment over motion |
| `gbc` | Toggle block comment |

### JoosepAlviste/nvim-ts-context-commentstring
Provides context-aware comment strings using Treesitter. Ensures correct comment syntax in embedded languages (e.g., JSX inside JavaScript, CSS inside HTML).

### folke/which-key.nvim
Displays a popup of available keybindings as you type a leader key sequence. Groups keybindings by namespace with descriptions.

### ThePrimeagen/refactoring.nvim
Code refactoring operations powered by Treesitter.

| Keybinding | Action |
|---|---|
| `<leader>re` | Extract function (visual) |
| `<leader>rv` | Extract variable (visual) |
| `<leader>ri` | Inline variable |

### echasnovski/mini.ai
Enhanced text objects for function arguments, function bodies, class bodies, and more. Extends `a`/`i` text objects beyond Vim defaults.

---

## UI & Visual

**Config file**: `lua/plugins/ui.lua`

### nvim-lualine/lualine.nvim
Fully customizable status line. Configured with sections showing mode, branch, diff, diagnostics, filename, LSP server, filetype, progress, location, and GitHub account indicator (` @username`).

### nvim-tree/nvim-web-devicons
Provides file-type-specific icons (requires a Nerd Font). Used by lualine, bufferline, nvim-tree, telescope, and other UI plugins.

### SmiteshP/nvim-navic
Displays LSP breadcrumb navigation (e.g., `class > method > block`) in the status line or winbar, showing the current code context.

### akinsho/bufferline.nvim
Renders open buffers as a tab line at the top of the editor. Shows diagnostics indicators and supports buffer ordering.

| Keybinding | Action |
|---|---|
| `S-h` | Previous buffer |
| `S-l` | Next buffer |
| `S-x` | Close current buffer (quit if last) |

### echasnovski/mini.bufremove
Provides buffer deletion commands that preserve window layout. When you close a buffer, the window stays open with another buffer rather than closing. Includes a smart close helper (`_G._smart_buf_close`) that quits Neovim when closing the last listed buffer, avoiding empty `[No Name]` buffers. The bufferline auto-hides when only one buffer is open.

### echasnovski/mini.indentscope
Draws an animated vertical line showing the current indent scope. Helps visualize code blocks and nesting levels.

### RRethy/vim-illuminate
Automatically highlights other occurrences of the symbol under the cursor throughout the visible buffer. Uses LSP, Treesitter, or regex depending on availability.

### kevinhwang91/nvim-ufo
Advanced code folding using Treesitter and LSP as fold providers. Supports fold previewing and customizable fold text.

### kevinhwang91/promise-async
Async/await library required by nvim-ufo for non-blocking fold computation.

---

## Git Integration

**Config file**: `lua/plugins/git.lua`

### lewis6991/gitsigns.nvim
Git integration showing added/changed/deleted lines in the sign column. Supports hunk-level staging, unstaging, and inline blame.

| Keybinding | Action |
|---|---|
| `]c` / `[c` | Next/previous hunk |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hp` | Preview hunk |
| `<leader>hS` | Stage buffer |
| `<leader>hu` | Undo stage hunk |
| `<leader>hd` | Diff this |
| `<leader>hD` | Diff this (cached) |
| `<leader>gb` | Toggle line blame |
| `<leader>gd` | Toggle deleted lines |

### tpope/vim-fugitive
Git command wrapper (`:Git`, `:Gread`, `:Gwrite`, etc.). Also serves as the foundation for the AI-powered commit workflow.

| Keybinding | Action |
|---|---|
| `<leader>gc` | Commit with AI-generated message |
| `<leader>gA` | Auto-commit all & push |
| `<leader>gP` | Push to remote |

The AI commit workflow uses OpenAI GPT-4o to generate commit messages from staged diffs. Messages can be edited before committing. Falls back to `[timestamp] Auto-commit` if the API is unavailable.

---

## Developer Tools

**Config file**: `lua/plugins/dev-tools.lua`

### folke/todo-comments.nvim
Highlights and indexes comment annotations: `TODO`, `FIXME`, `HACK`, `WARN`, `PERF`, `NOTE`. Searchable via Telescope and Trouble.

### nvim-lua/plenary.nvim
Common Lua utility library providing async primitives, path handling, testing, and HTTP utilities. Required by Telescope, gitsigns, and other plugins.

### folke/snacks.nvim
Multi-purpose plugin providing:
- **Dashboard**: Startup screen with recent files, projects, and shortcuts
- **Terminal**: Toggle-able terminal windows
- **Notifications**: Sole notification backend (`vim.notify` override)
- **Lazygit**: Integrated lazygit interface

| Keybinding | Action |
|---|---|
| `C-\` | Toggle terminal |
| `<leader>tt` | Toggle terminal |
| `<leader>tf` | Float terminal |
| `<leader>th` | Horizontal terminal |
| `<leader>tv` | Vertical terminal |

### ahmedkhalf/project.nvim
Automatic project root detection using LSP, patterns (`.git`, `Makefile`, `package.json`), etc. Integrates with Telescope for project switching (`<leader>fp`).

---

## Diagnostics

**Config file**: `lua/plugins/diagnostics.lua`

### folke/trouble.nvim
Pretty list for diagnostics, references, quickfix, and location lists. Provides structured views of workspace problems.

| Keybinding | Action |
|---|---|
| `<leader>xx` | Toggle diagnostics |
| `<leader>xc` | Copy all diagnostics to clipboard |

---

## Treesitter

**Config file**: `lua/plugins/treesitter.lua`

### nvim-treesitter/nvim-treesitter
Incremental syntax parsing and highlighting. Provides accurate, language-aware syntax highlighting, code folding, and powers other plugins (refactoring, text objects, comment strings).

Run `:TSUpdate` to update parsers, `:TSInstall <language>` to add new ones.

### windwp/nvim-ts-autotag
Automatically closes and renames HTML, JSX, TSX, Vue, and Svelte tags using Treesitter for accurate tag matching.

---

## Navigation & Search

**Config file**: `lua/plugins/telescope.lua`

### nvim-telescope/telescope.nvim
Extensible fuzzy finder over files, buffers, LSP symbols, git history, and more. Core navigation tool for the configuration.

| Keybinding | Action |
|---|---|
| `<leader>ff` | Find files |
| `<leader>fs` | Live grep (search text) |
| `<leader>fb` | Find buffers |
| `<leader>fh` | Help tags |
| `<leader>fp` | Find projects |
| `<leader>fr` | Recent files |

### nvim-telescope/telescope-fzf-native.nvim
Native C implementation of FZF's sorting algorithm for Telescope. Provides significantly faster fuzzy matching compared to the Lua implementation.

---

## File Management

**Config file**: `lua/plugins/nvim-tree.lua`

### nvim-tree/nvim-tree.lua
File explorer sidebar with git status indicators, file operations (create, rename, delete, copy, move), and LSP-aware file renaming via nvim-lsp-file-operations.

| Keybinding | Action |
|---|---|
| `<leader>e` | Toggle file explorer |

---

## Formatting & Linting

**Config file**: `lua/plugins/formatting.lua`

### stevearc/conform.nvim
Code formatter supporting multiple formatters per filetype with fallback chains. Formats on save by default.

| Language | Formatter(s) |
|---|---|
| JavaScript/TypeScript | prettier, biome |
| Lua | stylua |
| Python | black |
| Go | gofmt |
| Rust | rustfmt |
| C/C++ | clang-format |
| Shell | shfmt |

| Keybinding | Action |
|---|---|
| `<leader>mp` | Format file/selection |

### mfussenegger/nvim-lint
Asynchronous linter engine. Runs linters on file events and populates the diagnostics list.

---

## Language-Specific

**Config file**: `lua/plugins/python.lua`

### AckslD/swenv.nvim
Python virtual environment switcher. Detects and switches between venvs, updating the LSP server (pyright) to use the selected environment.

| Keybinding | Action |
|---|---|
| `<leader>pe` | Select Python venv |

---

## Custom Modules

These are not plugins but custom Lua modules in `lua/config/`:

### openai.lua
OpenAI API integration providing GPT-4o access for AI-generated commit messages. Handles API key loading from environment variables (checks `OPENAI_API_KEY` in env, `.zshrc`, `.bashrc`, `.zprofile`). Includes response caching.

### github.lua
Multi-account GitHub CLI management. Cycles through authenticated GitHub accounts with caching (60s TTL) to minimize `gh` CLI calls.

| Keybinding | Action |
|---|---|
| `<leader>ga` | Toggle GitHub account |
| `<leader>gas` | Show GitHub auth status |

---

## Quick Reference Table

| # | Plugin | Category | Config File | Primary Keybinding |
|---|---|---|---|---|
| 1 | mason.nvim | LSP | lsp.lua | `:Mason` |
| 2 | mason-lspconfig.nvim | LSP | lsp.lua | (auto) |
| 3 | mason-tool-installer.nvim | LSP | lsp.lua | (auto) |
| 4 | nvim-lspconfig | LSP | lsp.lua | `gd`, `K`, `<leader>ca` |
| 5 | cmp-nvim-lsp | LSP | lsp.lua | (auto) |
| 6 | nvim-lsp-file-operations | LSP | lsp.lua | (auto) |
| 7 | lazydev.nvim | LSP | lsp.lua | (auto) |
| 8 | luvit-meta | LSP | lsp.lua | (auto) |
| 9 | copilot.lua | Completion | completion.lua | `C-g` |
| 10 | nvim-cmp | Completion | completion.lua | `Tab`, `CR` |
| 11 | cmp-buffer | Completion | completion.lua | (auto) |
| 12 | cmp-path | Completion | completion.lua | (auto) |
| 13 | LuaSnip | Completion | completion.lua | `Tab` |
| 14 | friendly-snippets | Completion | completion.lua | (auto) |
| 15 | cmp_luasnip | Completion | completion.lua | (auto) |
| 16 | lspkind.nvim | Completion | completion.lua | (auto) |
| 17 | nvim-autopairs | Editor | editor.lua | (auto) |
| 18 | nvim-surround | Editor | editor.lua | `ys`, `ds`, `cs` |
| 19 | Comment.nvim | Editor | editor.lua | `gcc`, `gc` |
| 20 | nvim-ts-context-commentstring | Editor | editor.lua | (auto) |
| 21 | which-key.nvim | Editor | editor.lua | `<Space>` (wait) |
| 22 | refactoring.nvim | Editor | editor.lua | `<leader>re` |
| 23 | mini.ai | Editor | editor.lua | `a`/`i` text objects |
| 24 | lualine.nvim | UI | ui.lua | (statusline) |
| 25 | nvim-web-devicons | UI | ui.lua | (auto) |
| 26 | nvim-navic | UI | ui.lua | (breadcrumbs) |
| 27 | bufferline.nvim | UI | ui.lua | `S-h`, `S-l` |
| 28 | mini.bufremove | UI | ui.lua | `S-x` |
| 29 | mini.indentscope | UI | ui.lua | (auto) |
| 30 | vim-illuminate | UI | ui.lua | (auto) |
| 31 | nvim-ufo | UI | ui.lua | `zR`, `zM` |
| 32 | promise-async | UI | ui.lua | (auto) |
| 33 | gitsigns.nvim | Git | git.lua | `]c`, `<leader>hs` |
| 34 | vim-fugitive | Git | git.lua | `<leader>gc` |
| 35 | todo-comments.nvim | Dev Tools | dev-tools.lua | `<leader>ft`, `]t` |
| 36 | plenary.nvim | Dev Tools | dev-tools.lua | (library) |
| 37 | snacks.nvim | Dev Tools | dev-tools.lua | `C-\`, `<leader>tt` |
| 38 | project.nvim | Dev Tools | dev-tools.lua | `<leader>fp` |
| 39 | trouble.nvim | Diagnostics | diagnostics.lua | `<leader>xx` |
| 40 | nvim-treesitter | Treesitter | treesitter.lua | (auto) |
| 41 | nvim-ts-autotag | Treesitter | treesitter.lua | (auto) |
| 42 | telescope.nvim | Navigation | telescope.lua | `<leader>ff` |
| 43 | telescope-fzf-native.nvim | Navigation | telescope.lua | (auto) |
| 44 | nvim-tree.lua | File Mgmt | nvim-tree.lua | `<leader>e` |
| 45 | conform.nvim | Formatting | formatting.lua | `<leader>mp` |
| 46 | nvim-lint | Linting | formatting.lua | (auto) |
| 47 | swenv.nvim | Language | python.lua | `<leader>pe` |

> **Note**: Some plugins (cmp-nvim-lsp, plenary, nvim-web-devicons) appear as dependencies in multiple files but are counted once. The table shows 48 rows to indicate per-file placement; unique plugin count is **42**.

---

## Troubleshooting

| Issue | Command | Fix |
|-------|---------|-----|
| Plugin not loading | `:Lazy sync` | Reinstall plugins |
| LSP not working | `:Mason` | Check server installation |
| Treesitter errors | `:TSUpdate` | Update parsers |
| Formatter missing | `:Mason` | Install formatter |
| Slow startup | `:Lazy profile` | Identify slow plugin |
| Keybinding conflict | `:verbose map <key>` | Find conflicting map |

---

**See also:**
- `KEYBINDINGS.md` - Complete keybinding reference
- `LSP_GUIDE.md` - Language-specific LSP setup
- `ARCHITECTURE.md` - Plugin architecture deep dive
- `PERFORMANCE.md` - Startup optimization guide
