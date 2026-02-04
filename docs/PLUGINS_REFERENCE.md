# Plugin Reference

Complete listing of all plugins in this Neovim configuration, organized by category.

**Total Plugins:** 70 | **Lazy-loaded:** Yes | **Auto-installed:** Via lazy.nvim

---

## Core Infrastructure (7 plugins)

### lazy.nvim
- **Purpose:** Plugin manager with event-based lazy loading
- **Location:** `lua/config/lazy.lua`
- **Commands:** `:Lazy`, `:Lazy sync`, `:Lazy update`, `:Lazy profile`
- **Why:** Modern, async plugin manager with minimal startup overhead

### plenary.nvim
- **Purpose:** Common Lua utilities library (dependency for many plugins)
- **Used by:** telescope, gitsigns, neogit, refactoring, and more
- **Why:** Provides async, job control, and functional programming utilities

### nvim-web-devicons
- **Purpose:** File type icons for UI elements
- **Used by:** nvim-tree, telescope, lualine, cokeline
- **Why:** Visual file type identification across all UI components

### nui.nvim
- **Purpose:** UI component library for building popups, splits, inputs
- **Used by:** noice, telescope, neo-tree alternatives
- **Why:** Consistent UI components across plugins

### promise-async
- **Purpose:** Async/await utilities for Lua
- **Used by:** nvim-ufo (folding)
- **Why:** Better async code organization

### which-key.nvim
- **Purpose:** Interactive keybinding discovery UI
- **Location:** `lua/plugins/utilities.lua`
- **Keybinding:** Press `<Space>` and wait
- **Why:** Discover available keybindings without memorization

### nvim-lsp-file-operations
- **Purpose:** LSP-aware file operations (rename, move files updates imports)
- **Location:** `lua/plugins/lsp-core.lua`
- **Why:** Keep imports in sync when refactoring

---

## Language Server Protocol (8 plugins)

### mason.nvim
- **Purpose:** LSP server, formatter, and linter installer
- **Location:** `lua/plugins/lsp-servers.lua`
- **Commands:** `:Mason`, `:MasonUpdate`, `:MasonInstall <tool>`
- **Why:** One-stop shop for all language tooling installation

### mason-lspconfig.nvim
- **Purpose:** Bridge between mason and nvim-lspconfig
- **Location:** `lua/plugins/lsp-servers.lua`
- **Why:** Auto-install LSP servers for detected languages

### mason-tool-installer.nvim
- **Purpose:** Auto-install formatters and linters defined in config
- **Location:** `lua/plugins/lsp-servers.lua`
- **Why:** Ensures all tools are available without manual installation

### nvim-lspconfig
- **Purpose:** LSP server configurations (13+ languages)
- **Location:** `lua/plugins/lsp-servers.lua`
- **Servers:** ts_ls, lua_ls, pyright, gopls, rust_analyzer, clangd, html, cssls, jsonls, yamlls, tailwindcss, bashls, dockerls
- **Why:** Official LSP configuration collection

### lazydev.nvim
- **Purpose:** Lua development with Neovim API completion
- **Location:** `lua/plugins/lsp-core.lua`
- **Why:** Better completion when writing Neovim configs

### luvit-meta
- **Purpose:** Type definitions for Neovim Lua API
- **Used by:** lazydev.nvim
- **Why:** Accurate type information for vim.* APIs

### cmp-nvim-lsp
- **Purpose:** LSP completion source for nvim-cmp
- **Location:** `lua/plugins/autocompletion.lua`
- **Why:** Connects LSP to completion engine

### lspkind.nvim
- **Purpose:** VS Code-like pictograms in completion menu
- **Location:** `lua/plugins/autocompletion.lua`
- **Why:** Visual indicators for completion item types

---

## Completion & AI (9 plugins)

### copilot.lua
- **Purpose:** GitHub Copilot integration (AI code completion)
- **Location:** `lua/plugins/autocompletion.lua`
- **Commands:** `:Copilot auth`, `:Copilot status`
- **Keybindings:** `<C-g>` (accept), `<C-;>` (next), `<C-x>` (dismiss)
- **Why:** AI-powered inline code suggestions

### copilot-cmp
- **Purpose:** GitHub Copilot as nvim-cmp source
- **Location:** `lua/plugins/autocompletion.lua`
- **Why:** Show Copilot suggestions in completion menu

### nvim-cmp
- **Purpose:** Completion engine (main)
- **Location:** `lua/plugins/autocompletion.lua`
- **Keybindings:** `<Tab>` (next), `<S-Tab>` (prev), `<CR>` (confirm)
- **Why:** Fast, extensible completion framework

### LuaSnip
- **Purpose:** Snippet engine with VS Code snippet support
- **Location:** `lua/plugins/autocompletion.lua`
- **Keybindings:** `<Tab>` (expand/jump), `<S-Tab>` (jump back)
- **Why:** Powerful snippet system with lots of available snippets

### friendly-snippets
- **Purpose:** Collection of VS Code-style snippets for many languages
- **Used by:** LuaSnip
- **Why:** Pre-built snippets for common code patterns

### cmp_luasnip
- **Purpose:** LuaSnip completion source for nvim-cmp
- **Location:** `lua/plugins/autocompletion.lua`
- **Why:** Show snippets in completion menu

### cmp-buffer
- **Purpose:** Buffer text completion source
- **Location:** `lua/plugins/autocompletion.lua`
- **Why:** Autocomplete from words in current buffer

### cmp-path
- **Purpose:** File path completion source
- **Location:** `lua/plugins/autocompletion.lua`
- **Why:** Autocomplete file/directory paths

### lsp_signature.nvim
- **Purpose:** Function signature help popup
- **Location:** `lua/plugins/lsp-core.lua`
- **Auto-trigger:** Shows when typing function calls
- **Why:** See function parameters without invoking hover

---

## Syntax & Parsing (3 plugins)

### nvim-treesitter
- **Purpose:** Modern syntax highlighting and code parsing
- **Location:** `lua/plugins/treesitter.lua`
- **Commands:** `:TSUpdate`, `:TSInstall <language>`, `:TSModuleInfo`
- **Languages:** 40+ parsers auto-installed
- **Why:** Accurate syntax highlighting, faster than regex

### nvim-ts-autotag
- **Purpose:** Auto-close and rename HTML/JSX tags
- **Location:** `lua/plugins/treesitter.lua`
- **Languages:** HTML, JSX, TSX, XML
- **Why:** Saves time writing markup

### nvim-ts-context-commentstring
- **Purpose:** Smart comment detection (e.g., `//` in JSX, `{/* */}` in JS)
- **Location:** `lua/plugins/treesitter.lua`
- **Used by:** Comment.nvim
- **Why:** Context-aware commenting in mixed-language files

---

## Navigation & Search (7 plugins)

### telescope.nvim
- **Purpose:** Fuzzy finder with live grep, LSP integration
- **Location:** `lua/plugins/telescope.lua`
- **Keybindings:** `<leader>ff` (files), `<leader>fs` (search), `<leader>fb` (buffers)
- **Why:** Fast, extensible search for everything

### telescope-fzf-native.nvim
- **Purpose:** Native FZF sorting algorithm (compiled)
- **Location:** `lua/plugins/telescope.lua`
- **Build:** Requires C compiler (auto-compiled on install)
- **Why:** 10x faster fuzzy matching than Lua implementation

### flash.nvim
- **Purpose:** Modern f/F motion commands with labels
- **Location:** `lua/plugins/modern-enhancements.lua`
- **Keybindings:** `s` (search), `S` (Treesitter search), `r` (remote)
- **Why:** Jump anywhere in visible area with 2-3 keystrokes

### nvim-tree.lua
- **Purpose:** File tree explorer
- **Location:** `lua/plugins/nvim-tree.lua`
- **Keybindings:** `<leader>e` (toggle), `<leader>ef` (find file)
- **Why:** Visual file system navigation

### nvim-spectre
- **Purpose:** Find and replace across files
- **Location:** `lua/plugins/modern-enhancements.lua`
- **Keybindings:** `<leader>sr` (open), `<leader>sw` (search word)
- **Why:** Powerful project-wide search and replace

### project.nvim
- **Purpose:** Project detection and management
- **Location:** `lua/plugins/productivity.lua`
- **Keybindings:** `<leader>fp` (find projects)
- **Why:** Auto-detect project root, switch projects quickly

### buffer_manager.nvim
- **Purpose:** Buffer management UI
- **Location:** `lua/plugins/utilities.lua`
- **Keybindings:** `<leader>bm` (open manager)
- **Why:** Visual buffer organization

---

## Git Integration (6 plugins)

### gitsigns.nvim
- **Purpose:** Git hunks, staging, blame in sign column
- **Location:** `lua/plugins/git-enhancements.lua`
- **Keybindings:**
  - `]c` / `[c` (next/prev hunk)
  - `<leader>hp` (preview hunk), `<leader>hs` (stage hunk)
  - `<leader>gb` (toggle blame), `<leader>gd` (toggle deleted)
- **Why:** See git changes inline without leaving editor

### neogit
- **Purpose:** Magit-style git interface
- **Location:** `lua/plugins/git-enhancements.lua`
- **Commands:** `:Neogit`
- **Keybindings:** `<leader>gg` (open)
- **Why:** Full-featured git UI for complex workflows

### git-conflict.nvim
- **Purpose:** Git conflict resolution helpers
- **Location:** `lua/plugins/git-enhancements.lua`
- **Keybindings:** `co` (ours), `ct` (theirs), `cb` (both), `cn` (none)
- **Why:** Resolve merge conflicts visually

### diffview.nvim
- **Purpose:** Git diff viewer with file history
- **Location:** `lua/plugins/git-enhancements.lua`
- **Commands:** `:DiffviewOpen`, `:DiffviewFileHistory`
- **Keybindings:** `<leader>hd` (diff this), `<leader>hD` (diff cached)
- **Why:** Better than `git diff` in terminal

### vim-fugitive
- **Purpose:** Git commands integration in Neovim
- **Location:** `lua/plugins/git-workflow.lua`
- **Commands:** `:Git`
- **Why:** Seamless git command execution

### git-workflow (AI-powered)
- **Purpose:** AI-generated commit messages with OpenAI, auto-commit & push
- **Location:** `lua/plugins/git-workflow.lua`
- **Dependencies:** `lua/config/openai.lua`, `lua/config/github.lua`
- **Keybindings:**
  - `<leader>gc` (smart commit with AI message, stages current file if needed)
  - `<leader>gP` (push to remote)
  - `<leader>gC` (auto-commit all changes with AI message, no push)
  - `<leader>gA` (auto-commit all & push in one command)
- **Environment:** Requires `OPENAI_API_KEY` in shell or `.zshrc`/`.bashrc`
- **Why:** Streamline git workflow with intelligent commit messages

---

## Configuration Modules

### openai.lua
- **Purpose:** OpenAI API integration for AI-powered features
- **Location:** `lua/config/openai.lua`
- **Functions:**
  - `get_api_key()` - Load `OPENAI_API_KEY` from environment or shell configs (`.zshrc`, `.bashrc`, `.zprofile`)
  - `generate_commit_message(diff, fallback)` - Generate commit messages using GPT-4o
- **Used by:** `lua/plugins/git-workflow.lua`
- **Environment:** Requires `OPENAI_API_KEY` environment variable
- **Why:** Centralized OpenAI integration with caching and fallbacks

### github.lua
- **Purpose:** GitHub account management and detection
- **Location:** `lua/config/github.lua`
- **Functions:**
  - `get_current_account()` - Get active GitHub username
  - `get_all_accounts()` - Get list of all configured accounts
  - `switch_account()` - Toggle to next non-active GitHub account
  - `show_status()` - Display full GitHub auth status in floating terminal
- **Used by:** `lua/plugins/dev-tools.lua`, `lua/plugins/ui-statusline.lua`
- **Display:** Shows in lualine as ` @username` when in git repo
- **Why:** Manage multiple GitHub accounts seamlessly

---

## Code Editing (8 plugins)

### nvim-surround
- **Purpose:** Manipulate surrounding brackets, quotes, tags
- **Location:** `lua/plugins/enhanced-editing.lua`
- **Keybindings:** `ys` (add), `ds` (delete), `cs` (change)
- **Example:** `ysiw"` surrounds word with quotes
- **Why:** Fast bracket/quote manipulation

### mini.pairs
- **Purpose:** Auto-pair insertion and deletion
- **Location:** `lua/plugins/enhanced-editing.lua`
- **Auto-pairs:** `()`, `[]`, `{}`, `""`, `''`, ````
- **Why:** Balanced brackets automatically

### mini.ai
- **Purpose:** Extended text objects (function args, etc.)
- **Location:** `lua/plugins/enhanced-editing.lua`
- **Text objects:** `a/i` + `f` (function), `c` (class), `a` (argument)
- **Example:** `daa` deletes an argument
- **Why:** More granular selection than default vim

### mini.bufremove
- **Purpose:** Better buffer deletion (preserves window layout)
- **Location:** `lua/plugins/enhanced-editing.lua`
- **Keybindings:** `<leader>bd` (delete buffer)
- **Why:** Close buffer without closing window

### mini.indentscope
- **Purpose:** Visual indent level indicators
- **Location:** `lua/plugins/ui-indicators.lua`
- **Display:** Animated indent guide for current scope
- **Why:** See current code block boundaries

### Comment.nvim
- **Purpose:** Toggle comments with `gcc`
- **Location:** `lua/plugins/enhanced-editing.lua`
- **Keybindings:** `gcc` (line), `gc` (visual), `gbc` (block)
- **Why:** Smart context-aware commenting

### refactoring.nvim
- **Purpose:** Code refactoring operations (extract, inline, etc.)
- **Location:** `lua/plugins/modern-enhancements.lua`
- **Keybindings:**
  - `<leader>re` (extract function), `<leader>rf` (extract block)
  - `<leader>ri` (inline variable), `<leader>rv` (extract variable)
- **Why:** Safe, automated refactorings

### nvim-ufo
- **Purpose:** Better code folding with Treesitter
- **Location:** `lua/plugins/enhanced-editing.lua`
- **Keybindings:** `zR` (open all), `zM` (close all), `za` (toggle)
- **Why:** Treesitter-aware folding, faster than default

---

## UI Enhancement (13 plugins)

### lualine.nvim
- **Purpose:** Status line with git, LSP, diagnostics
- **Location:** `lua/plugins/ui-statusline.lua`
- **Sections:** mode, git branch, filename, diagnostics, LSP, encoding, progress
- **Why:** Beautiful, informative status line

### nvim-cokeline
- **Purpose:** Buffer line (tabs for buffers)
- **Location:** `lua/plugins/ui-bufferline.lua`
- **Keybindings:** `<S-h>` / `<S-l>` (navigate), `<A-<>` / `<A->>` (reorder)
- **Why:** Visual buffer management with mouse support

### noice.nvim
- **Purpose:** Better UI for messages, cmdline, popups
- **Location:** `lua/plugins/ui-notifications.lua`
- **Features:** Cmdline popup, message notifications, LSP progress
- **Why:** Modern, non-intrusive UI messaging

### nvim-notify
- **Purpose:** Notification manager with animations
- **Location:** `lua/plugins/ui-notifications.lua`
- **Used by:** noice, LSP, plugins
- **Why:** Beautiful, dismissible notifications

### dressing.nvim
- **Purpose:** Styled input/select UI (uses Telescope)
- **Location:** `lua/plugins/ui-notifications.lua`
- **Enhanced:** `vim.ui.select`, `vim.ui.input`
- **Why:** Better looking prompts and selectors

### fidget.nvim
- **Purpose:** LSP progress indicator (bottom-right corner)
- **Location:** `lua/plugins/ui-notifications.lua`
- **Display:** Shows LSP server activity
- **Why:** Know when LSP is working

### vim-illuminate
- **Purpose:** Highlight symbol references under cursor
- **Location:** `lua/plugins/ui-indicators.lua`
- **Auto-trigger:** Highlights same symbol across buffer
- **Why:** See where variable/function is used

### nvim-colorizer.lua
- **Purpose:** Highlight color codes (#ff0000, rgb(255,0,0))
- **Location:** `lua/plugins/ui-indicators.lua`
- **Languages:** CSS, HTML, JavaScript, Lua
- **Why:** Visual color preview in code

### nvim-bqf
- **Purpose:** Better quickfix list UI
- **Location:** `lua/plugins/utilities.lua`
- **Features:** Preview, search, filter
- **Why:** Enhanced quickfix window

### neoscroll.nvim
- **Purpose:** Smooth scrolling animations
- **Location:** `lua/plugins/utilities.lua`
- **Why:** Easier to track cursor during scrolls

### render-markdown.nvim
- **Purpose:** Render markdown in-buffer (headings, lists, code blocks)
- **Location:** `lua/plugins/productivity.lua`
- **Languages:** Markdown
- **Why:** WYSIWYG markdown editing experience

### snacks.nvim (multi-feature)
- **Purpose:** Dashboard, terminal, scrollbar, git, indent animations
- **Location:** `lua/plugins/dev-tools.lua`
- **Components:**
  - **Dashboard:** Startup screen with recent files
  - **Terminal:** Floating terminal (`<C-\>`, `<leader>tt`)
  - **Git:** Blame/browse lines
  - **Indent:** Animated indent guides
- **Why:** Multiple small utilities in one plugin

### actions-preview.nvim
- **Purpose:** Code action preview with diff
- **Location:** `lua/plugins/lsp-core.lua`
- **Keybindings:** `<leader>ca` (code actions)
- **Why:** See code action changes before applying

---

## Development Tools (6 plugins)

### trouble.nvim
- **Purpose:** Diagnostics, references, quickfix list UI
- **Location:** `lua/plugins/enhanced-diagnostics.lua`
- **Keybindings:**
  - `<leader>xx` (diagnostics), `<leader>xX` (buffer diagnostics)
  - `<leader>xq` (quickfix), `<leader>xl` (location list)
- **Why:** Better diagnostics navigation

### todo-comments.nvim
- **Purpose:** Highlight and search TODO/FIXME/NOTE comments
- **Location:** `lua/plugins/dev-tools.lua`
- **Keybindings:** `<leader>ft` (search todos), `]t` / `[t` (next/prev)
- **Keywords:** TODO, HACK, WARN, PERF, NOTE, FIX
- **Why:** Track TODOs across project

### aerial.nvim
- **Purpose:** Code outline sidebar (functions, classes, etc.)
- **Location:** `lua/plugins/modern-enhancements.lua`
- **Keybindings:** `<leader>a` (toggle outline)
- **Why:** Navigate large files by structure

### nvim-lint
- **Purpose:** Linting framework (runs linters async)
- **Location:** `lua/plugins/formatting.lua`
- **Linters:** eslint, ruff, shellcheck, yamllint
- **Why:** Catch errors beyond LSP

### conform.nvim
- **Purpose:** Code formatting with project-aware formatter selection
- **Location:** `lua/plugins/formatting.lua`
- **Keybindings:** `<leader>mp` (format), auto-format on save
- **Formatters:** prettier, biome, stylua, black, gofmt, rustfmt, clang-format, shfmt
- **Why:** Consistent code formatting

### markdown-preview.nvim
- **Purpose:** Live markdown preview in browser
- **Location:** `lua/plugins/productivity.lua`
- **Commands:** `:MarkdownPreview`, `:MarkdownPreviewToggle`
- **Why:** WYSIWYG markdown preview

---

## Session & Productivity (2 plugins)

### persistence.nvim
- **Purpose:** Session auto-save and restore
- **Location:** `lua/plugins/productivity.lua`
- **Keybindings:** `<leader>qs` (restore), `<leader>ql` (last), `<leader>qd` (stop)
- **Why:** Resume work exactly where you left off

### swenv.nvim
- **Purpose:** Python virtual environment switcher
- **Location:** `lua/plugins/python.lua`
- **Keybindings:** `<leader>pe` (select venv)
- **Why:** Switch Python venv without restarting Neovim

---

## Colorscheme (1 plugin)

### Custom Gruvbox Dark
- **Purpose:** Science-based colorscheme optimized for eye strain reduction
- **Location:** `lua/colors/gruvbox-custom.lua`, loaded in `lua/plugins/colorscheme.lua`
- **Features:** Reduced contrast, warm colors, low blue light
- **Why:** Comfortable for long coding sessions

---

## Quick Reference Table

| Plugin | Category | Config File | Primary Keybinding |
|--------|----------|-------------|-------------------|
| telescope.nvim | Search | telescope.lua | `<leader>ff` |
| nvim-tree.lua | Navigation | nvim-tree.lua | `<leader>e` |
| nvim-cmp | Completion | autocompletion.lua | `<Tab>` |
| copilot.lua | AI | autocompletion.lua | `<C-g>` |
| gitsigns.nvim | Git | git-enhancements.lua | `]c`, `<leader>hp` |
| lualine.nvim | UI | ui-statusline.lua | (statusline) |
| nvim-treesitter | Syntax | treesitter.lua | (auto) |
| mason.nvim | LSP | lsp-servers.lua | `:Mason` |
| trouble.nvim | Diagnostics | enhanced-diagnostics.lua | `<leader>xx` |
| flash.nvim | Motion | modern-enhancements.lua | `s` |
| aerial.nvim | Outline | modern-enhancements.lua | `<leader>a` |
| refactoring.nvim | Refactoring | modern-enhancements.lua | `<leader>re` |
| conform.nvim | Formatting | formatting.lua | `<leader>mp` |
| snacks.nvim | Multi | dev-tools.lua | `<C-\>` (terminal) |
| noice.nvim | UI | ui-notifications.lua | (auto) |

---

## Plugin Dependencies Graph

```
lazy.nvim (root)
├── Core
│   ├── plenary.nvim (many plugins)
│   ├── nvim-web-devicons (UI plugins)
│   ├── nui.nvim (noice, telescope)
│   └── which-key.nvim (standalone)
│
├── LSP Layer
│   ├── mason.nvim
│   │   ├── mason-lspconfig.nvim
│   │   │   └── nvim-lspconfig (13+ servers)
│   │   └── mason-tool-installer.nvim
│   ├── lazydev.nvim → luvit-meta
│   └── nvim-lsp-file-operations
│
├── Completion Layer
│   ├── nvim-cmp (engine)
│   │   ├── cmp-nvim-lsp (LSP source)
│   │   ├── cmp-buffer (buffer source)
│   │   ├── cmp-path (path source)
│   │   ├── cmp_luasnip (snippet source)
│   │   └── copilot-cmp (AI source)
│   ├── LuaSnip → friendly-snippets
│   ├── copilot.lua (standalone + cmp source)
│   ├── lspkind.nvim (pictograms)
│   └── lsp_signature.nvim (signatures)
│
├── Syntax & Parsing
│   └── nvim-treesitter
│       ├── nvim-ts-autotag
│       └── nvim-ts-context-commentstring → Comment.nvim
│
├── Navigation
│   ├── telescope.nvim → telescope-fzf-native.nvim
│   ├── flash.nvim
│   ├── nvim-tree.lua
│   ├── nvim-spectre → plenary.nvim
│   ├── project.nvim → telescope
│   └── buffer_manager.nvim
│
├── Git
│   ├── gitsigns.nvim
│   ├── neogit → plenary.nvim
│   ├── git-conflict.nvim
│   ├── diffview.nvim
│   └── nvim-navic → lualine
│
├── Editing
│   ├── nvim-surround
│   ├── mini.pairs
│   ├── mini.ai
│   ├── mini.bufremove
│   ├── mini.indentscope
│   ├── Comment.nvim
│   ├── refactoring.nvim → plenary.nvim
│   └── nvim-ufo → promise-async
│
├── UI
│   ├── lualine.nvim → nvim-web-devicons
│   ├── nvim-cokeline → nvim-web-devicons
│   ├── noice.nvim → nui.nvim, nvim-notify
│   ├── nvim-notify
│   ├── dressing.nvim → telescope
│   ├── fidget.nvim
│   ├── vim-illuminate
│   ├── nvim-colorizer.lua
│   ├── nvim-bqf
│   ├── neoscroll.nvim
│   ├── render-markdown.nvim
│   ├── snacks.nvim (multi-component)
│   └── actions-preview.nvim → telescope
│
├── Dev Tools
│   ├── trouble.nvim
│   ├── todo-comments.nvim → plenary.nvim
│   ├── aerial.nvim
│   ├── nvim-lint
│   ├── conform.nvim
│   └── markdown-preview.nvim
│
└── Session/Language-Specific
    ├── persistence.nvim
    └── swenv.nvim (Python)
```

---

## Installation Notes

- **All plugins auto-install** on first Neovim launch via lazy.nvim
- **Compiled plugins** (telescope-fzf-native) build automatically
- **LSP servers** auto-install when you open a file of that type
- **Formatters/linters** auto-install via mason-tool-installer
- **Manual installation not required** for any plugin

## Performance Notes

- **Startup time:** ~76ms (69 plugins)
- **Lazy loading:** Event-based (VeryLazy, BufReadPre, InsertEnter, cmd)
- **Memory:** 150-200MB (idle with LSP)
- **Optimization:** Disabled builtins (gzip, netrw, etc.)

## Troubleshooting Plugins

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
