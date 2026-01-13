# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Recent Changes (2025)

### January 2025 - Configuration Optimization
- **File organization**: Split large plugin files for better maintainability
  - `lsp.lua` (383 lines) → `lsp-core.lua` + `lsp-servers.lua`
  - `dev-tools.lua` (388 lines) → `dev-tools.lua` + `productivity.lua`
  - `ui-enhancements.lua` (427 lines) → 4 focused UI files
- **Removed redundancies**: Eliminated duplicate LSP signature help keybinding
- **Fixed namespace conflicts**: Git toggles moved from `<leader>t` to `<leader>g`
  - `<leader>gb` - Toggle git blame (was `<leader>tb`)
  - `<leader>gd` - Toggle deleted lines (was `<leader>td`)
- **Version requirements updated**: Neovim 0.10+ required, 0.11+ recommended
  - Native LSP features (`vim.lsp.config()`) work best on 0.11+
  - Compatibility checks and health checks updated accordingly

### Performance & UX Improvements
- Removed auto-update checks and backup plugins for better performance
- Silent LSP initialization (no verbose startup notifications)
- Manual-only health checks via `<leader>hc` or `:checkhealth`

### Modern Plugins
- **flash.nvim**: Modern motion/navigation
- **aerial.nvim**: Code outline sidebar (`<leader>a`)
- **lsp_signature.nvim**: Auto-trigger function signature help
- **actions-preview.nvim**: Code action preview with diff
- **refactoring.nvim**: Extract function, inline variable (`<leader>r`)
- **GitHub Copilot**: AI-powered completions (replaced Codeium)

### Colorscheme
- **Custom Gruvbox Dark**: Science-based theme optimized for reduced eye strain
- Located in `lua/colors/gruvbox-custom.lua`

## Development Commands

### Plugin Management
- `:Lazy` - Plugin manager interface
- `:Lazy update` - Update all plugins
- `:Lazy sync` - Clean and update
- `:Lazy profile` - Profile loading times

### LSP & Language Servers
- `:Mason` - Manage LSP servers/formatters/linters
- `:LspInfo` - Show LSP status
- `:LspRestart` - Restart LSP servers

### Treesitter
- `:TSUpdate` - Update all parsers
- `:TSInstall <language>` - Install parser

### Code Formatting
- Auto-format on save via conform.nvim
- Manual: `<leader>mp` in normal/visual mode
- Supported: prettier, stylua, black, gofmt, rustfmt, clang-format

## Architecture Overview

### Configuration Structure
```
.
├── init.lua                    # Entry point
├── lua/
│   ├── config/                 # Core configuration
│   │   ├── lazy.lua           # Plugin manager setup
│   │   ├── options.lua        # Neovim settings
│   │   ├── keymaps.lua        # General keybindings
│   │   ├── autocmds.lua       # Auto commands
│   │   └── compatibility.lua  # Version checks
│   ├── colors/
│   │   └── gruvbox-custom.lua # Custom colorscheme
│   └── plugins/               # Plugin configurations
│       ├── lsp-core.lua       # LSP setup & keymaps
│       ├── lsp-servers.lua    # Server configurations
│       ├── productivity.lua   # Projects, sessions, markdown
│       ├── ui-statusline.lua  # Lualine
│       ├── ui-notifications.lua # Notify, noice, dressing
│       ├── ui-indicators.lua  # Indent, illuminate, folding
│       ├── ui-bufferline.lua  # Cokeline, buffer management
│       └── ...                # Other plugin configs
```

### Plugin System
- **lazy.nvim**: Event-based loading for performance
- **Auto-installation**: Plugins install automatically
- **Disabled builtins**: gzip, netrw, etc. for performance

### Language Support (3-Layer)

1. **LSP Layer** (`lsp-core.lua`, `lsp-servers.lua`):
   - Mason for automatic server management
   - Servers: ts_ls, lua_ls, pyright, gopls, clangd, rust_analyzer, etc.
   - Unified keybindings across languages
   - Telescope integration

2. **Completion Layer** (`autocompletion.lua`):
   - **AI**: GitHub Copilot inline suggestions
   - **LSP**: nvim-cmp with LSP/buffer/path/snippets
   - **Snippets**: LuaSnip with VS Code snippets
   - **Signature**: lsp_signature.nvim auto-trigger

3. **Formatting Layer** (`formatting.lua`):
   - Conform.nvim with language-specific formatters
   - Format-on-save enabled

### Key Plugin Responsibilities

**Core**: nvim-tree (file explorer), Telescope (fuzzy finder), Treesitter (syntax)
**Git**: Gitsigns (hunks, staging, blame)
**Editing**: nvim-ufo (folding), nvim-surround, mini.pairs, Comment.nvim
**UI**: lualine, noice, notify, dressing, cokeline, which-key
**Dev Tools**: Trouble, todo-comments, snacks (terminal/dashboard), aerial, refactoring
**Navigation**: flash, nvim-spectre, persistence, mini.ai

## Working with This Configuration

### Adding Language Support
1. Add server to `ensure_installed` in `lua/plugins/lsp-servers.lua`
2. Add parser to `ensure_installed` in `lua/plugins/treesitter.lua`
3. Add formatter in `lua/plugins/formatting.lua`
4. Auto-installed via Mason on startup

### Modifying Keybindings
- **General**: `lua/config/keymaps.lua`
- **LSP**: `lua/plugins/lsp-core.lua` (LspAttach autocmd)
- **Plugin-specific**: Within respective plugin files

### Common Workflows

**File Navigation**
`<leader>ff` → `<leader>fs` → `<leader>fp`

**Code Exploration**
`gd` (definition) → `K` (hover) → `<leader>ca` (code actions) → `<leader>a` (outline)

**Git** (Updated keybindings)
- Hunks: `]c`/`[c` (navigate) → `<leader>hp` (preview) → `<leader>hs` (stage)
- Toggles: `<leader>gb` (blame) → `<leader>gd` (deleted lines)
- Diff: `<leader>hd` (diff this) → `<leader>hD` (diff cached)

**Window Management**
`<leader>sv` (split) → `<C-h/j/k/l>` (navigate) → `<M-h/j/k/l>` (resize)

**Diagnostics**
`<leader>xx` (Trouble) → `]d`/`[d` (navigate) → `<leader>ca` (fix)

**Refactoring**
Select → `<leader>re` (extract function) → `<leader>rv` (variable) → `<leader>ri` (inline)

**Terminal**
`<C-\>` (toggle) → `<leader>tt` (toggle) → `<leader>tf/th/tv` (float/horizontal/vertical)

**Sessions**
`<leader>qs` (restore) → `<leader>qd` (stop saving)

**Clipboard**
`<leader>y` (yank) → `<leader>P` (paste) → `<leader>dd` (delete without yank)

### Keybinding Namespaces

- `<leader>a` - Aerial (code outline)
- `<leader>b` - Buffer operations
- `<leader>c` - Code actions
- `<leader>d` - Diagnostics
- `<leader>e` - File explorer
- `<leader>f` - Find/Search
- `<leader>g` - **Git toggles** (blame, deleted)
- `<leader>h` - Git hunks
- `<leader>j` - Format/Lint
- `<leader>p` - Python
- `<leader>q` - Session
- `<leader>r` - Rename/Refactor/Restart
- `<leader>s` - Split/Search
- `<leader>t` - **Terminal/Toggle** (terminal commands)
- `<leader>x` - Trouble/Diagnostics

### Error Recovery
- **LSP**: `:LspRestart` or check `:Mason`
- **Plugins**: `:Lazy sync`
- **Treesitter**: `:TSUpdate`
- **Full reset**: Remove `~/.local/share/nvim` and restart

## Documentation Structure

All documentation in `docs/` directory:
- `KEYBINDINGS.md` - Complete keybinding reference
- `SETUP_FORMATTERS.md` - Formatter installation guide
- `PLUGINS_REFERENCE.md` - Complete listing of all 69 plugins by category
- `ARCHITECTURE.md` - Configuration architecture and plugin dependency graph
- `LSP_GUIDE.md` - Language-specific LSP setup and troubleshooting
- `TROUBLESHOOTING.md` - Advanced troubleshooting beyond README
- `PERFORMANCE.md` - Startup optimization and profiling techniques
- Use UPPERCASE for doc filenames
