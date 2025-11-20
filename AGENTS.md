# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Recent Changes (2025)

### Performance Optimizations
- **Removed auto-updates.lua**: Eliminated hourly auto-update checks for better performance
- **Removed backup.lua**: Simplified config management (use git for backups instead)
- **Disabled auto health check**: Health checks now manual-only via `<leader>hc` or `:checkhealth`

### Bug Fixes
- **Fixed duplicate Trouble.nvim**: Removed duplicate configuration from dev-tools.lua
- **Fixed bufferline bug**: Corrected undefined function call in session restoration
- **Consolidated diagnostics**: Removed duplicate diagnostic configuration from lsp.lua

### Keybinding Improvements
- **Fixed conflicts**:
  - Changed "delete without yank" from `<leader>D` to `<leader>dd`
  - Moved tab commands from `<leader>t` to `<leader>T` (uppercase)
  - Removed Noice scroll bindings to avoid conflicts
- **Added quality-of-life bindings**:
  - `<leader>y/Y/P` - System clipboard operations
  - `<M-h/j/k/l>` - Better window resizing with Alt/Option keys
  - `<C-s>` (insert mode) - LSP signature help
- **Reorganized namespaces**:
  - `<leader>t` - Toggle/Terminal
  - `<leader>T` - Tabs
  - Clearer separation of concerns

### Modern Plugin Additions
- **flash.nvim**: Modern motion/navigation (replaces vim-sneak style plugins)
- **aerial.nvim**: Code outline sidebar (`<leader>a`)
- **lsp_signature.nvim**: Function signature help as you type
- **actions-preview.nvim**: Better code action preview with diff
- **fidget.nvim**: LSP progress indicator
- **git-conflict.nvim**: Visual git conflict resolution
- **refactoring.nvim**: Extract function, inline variable, etc. (`<leader>r` namespace)
- **mini.ai**: Enhanced text objects for better code selection

### Plugin Migrations
- **Codeium**: Migrated from `codeium.vim` (Vim-script) to `codeium.nvim` (Lua) for better performance

### UX Improvements
- **Silent LSP initialization**: Removed verbose LSP startup notifications
- **Better diagnostics**: Enhanced configuration in enhanced-diagnostics.lua

## Development Commands

### Plugin Management
- `:Lazy` - Open lazy.nvim plugin manager interface
- `:Lazy update` - Update all plugins
- `:Lazy sync` - Clean unused plugins and update existing ones
- `:Lazy profile` - Profile plugin loading times

### LSP and Language Servers
- `:Mason` - Open Mason interface to manage LSP servers, formatters, and linters
- `:MasonUpdate` - Update all installed tools
- `:MasonInstall <tool>` - Install specific language server or tool
- `:LspInfo` - Show LSP server status for current buffer
- `:LspRestart` - Restart LSP servers

### Treesitter (Syntax Highlighting)
- `:TSUpdate` - Update all Treesitter parsers
- `:TSUpdate <language>` - Update specific language parser
- `:TSInstall <language>` - Install new language parser

### Code Formatting
- Files are automatically formatted on save using conform.nvim
- Manual formatting: `<leader>mp` in normal or visual mode
- Supported formatters: prettier (JS/TS/web), stylua (Lua), black/isort (Python), gofmt/goimports (Go), rustfmt (Rust), clang-format (C/C++)

### Diagnostics and Health
- `:checkhealth` - Run Neovim health checks
- `:checkhealth lazy` - Check plugin manager health
- `:checkhealth lsp` - Check LSP configuration health

## Architecture Overview

### Configuration Structure
This is a modern Neovim configuration using lazy.nvim as the plugin manager, organized as follows:

- **init.lua**: Entry point, sets leader key and loads core modules
- **lua/config/**: Core configuration modules
  - `lazy.lua`: Plugin manager setup with performance optimizations
  - `options.lua`: Neovim options and settings (tabs, search, appearance)
  - `keymaps.lua`: General key mappings for window/buffer/tab management
  - `compatibility.lua`: Version compatibility checks (requires Neovim 0.9+)
- **lua/plugins/**: Individual plugin configurations (auto-loaded by lazy.nvim)

### Plugin System
Uses lazy.nvim with:
- Event-based loading for performance
- Automatic plugin installation
- Plugin update checking enabled
- Disabled builtin plugins for performance (gzip, netrw, etc.)

### Language Support Architecture
Three-layer approach for language support:

1. **LSP Layer** (`lsp.lua`):
   - Mason for automatic LSP server management
   - Pre-configured servers: ts_ls, lua_ls, pyright, gopls, clangd, rust_analyzer, etc.
   - Unified keybindings across all languages
   - Telescope integration for definitions, references, diagnostics

2. **Completion Layer** (`autocompletion.lua`):
   - **AI Completion**: Codeium.nvim (Lua-native) for intelligent code suggestions (ghost text)
   - **LSP Completion**: nvim-cmp with multiple sources (LSP, buffer, path, snippets)
   - LuaSnip for snippet expansion
   - VS Code-style pictograms via lspkind
   - Dual completion system: AI suggestions + traditional completions work together
   - Function signature help via lsp_signature.nvim

3. **Formatting Layer** (`formatting.lua`):
   - Conform.nvim for code formatting
   - Language-specific formatters with fallback to LSP
   - Format-on-save enabled by default

### Key Plugin Responsibilities

#### Core Functionality
- **nvim-tree**: File explorer with git integration
- **Telescope**: Fuzzy finder for files, text, LSP symbols, diagnostics (enhanced with better UI)
- **Treesitter**: Syntax highlighting, text objects, auto-tagging
- **Monokai Pro**: Color scheme (Spectrum filter) with vibrant mode colors

#### Git Integration
- **Gitsigns**: Git integration with hunk management
- **Neogit**: Advanced Git UI with Telescope integration
- **Diffview**: Side-by-side diff view for files and commits
- **git-conflict.nvim**: Visual git conflict resolution with intuitive keybindings

#### Editor Enhancements
- **nvim-ufo**: Superior code folding with Treesitter support
- **nvim-surround**: Easy manipulation of surrounding characters
- **nvim-autopairs**: Intelligent auto-pairing of brackets
- **Comment.nvim**: Smart commenting with language detection
- **vim-illuminate**: Highlight word under cursor across buffer

#### UI/UX
- **noice.nvim**: Better UI for messages, cmdline, and popupmenu
- **nvim-notify**: Notification manager with animations
- **dressing.nvim**: Better UI for inputs and selects
- **neoscroll.nvim**: Smooth scrolling animations
- **dashboard-nvim**: Beautiful start screen
- **bufferline.nvim**: Enhanced buffer line with diagnostics
- **which-key**: Keybinding discovery and documentation
- **lualine**: Customizable statusline
- **fidget.nvim**: LSP progress indicator with elegant notifications

#### Development Tools
- **Trouble**: Advanced diagnostics and LSP symbol navigation
- **todo-comments**: Highlight and search TODO comments
- **snacks.nvim terminal**: Integrated terminal with float/split layouts
- **project.nvim**: Project management and switching
- **nvim-navic**: Breadcrumb-style code context
- **markdown-preview**: Live markdown preview
- **aerial.nvim**: Code outline sidebar showing functions, classes, etc.
- **lsp_signature.nvim**: Function signature help displayed as you type
- **actions-preview.nvim**: Code action preview with diff before applying
- **refactoring.nvim**: Advanced refactoring operations (extract, inline, etc.)

#### Search & Navigation
- **flash.nvim**: Modern motion plugin for quick jumps anywhere on screen
- **nvim-spectre**: Global search and replace functionality
- **nvim-bqf**: Enhanced quickfix window
- **persistence.nvim**: Session management and restoration
- **indent-blankline**: Visual indentation guides
- **nvim-colorizer**: Highlight color codes in files
- **mini.ai**: Enhanced text objects for better code selection

## Working with This Configuration

### Adding New Language Support
1. Add LSP server to `ensure_installed` in `lua/plugins/lsp.lua`
2. Add Treesitter parser to `ensure_installed` in `lua/plugins/treesitter.lua`
3. Add formatter configuration in `lua/plugins/formatting.lua`
4. Server will be auto-installed via Mason on next startup

### Modifying Keybindings
- General keymaps: `lua/config/keymaps.lua`
- Plugin-specific keymaps: within respective plugin files
- LSP keymaps: auto-configured in `lua/plugins/lsp.lua` via LspAttach autocmd

### Performance Considerations
- Plugins use event-based loading (BufReadPre, BufNewFile, InsertEnter, etc.)
- Builtin plugins are disabled in lazy.nvim config
- Treesitter folding is configured but starts fully expanded (foldlevel=99)

### Version Compatibility
- Requires Neovim 0.9+ (checked in compatibility.lua)
- Optimized for Neovim 0.10+ features
- Uses modern plugin versions and configuration patterns

### Common Workflow Patterns
- **File navigation**: `<leader>ff` (find files) → `<leader>fs` (search text) → `<leader>fp` (find projects)
- **Code exploration**:
  - Basic: `gd` (definition) → `K` (hover docs) → `<C-s>` (signature help in insert mode) → `<leader>ca` (code actions with preview)
  - Advanced: `<leader>a` (code outline) → `s` (flash jump) → `<leader>th` (toggle inlay hints)
- **Git workflow**:
  - Hunks: `]c` (next hunk) → `<leader>hp` (preview) → `<leader>hs` (stage)
  - Advanced: `<leader>gg` (Neogit) → `<leader>gd` (DiffView) → `<leader>gh` (file history)
  - Conflicts: `<leader>gcn` (next conflict) → `<leader>gco` (choose ours) → `<leader>gct` (choose theirs)
- **Window management**:
  - Navigation: `<leader>sv` (vertical split) → `<C-h/j/k/l>` (navigate) → `<leader>se` (equal size)
  - Resizing: `<M-h/j/k/l>` (resize with Alt/Option keys)
- **Tab management**: `<leader>To` (new tab) → `<leader>Tn/Tp` (next/prev) → `<leader>Tx` (close)
- **Diagnostics**: `<leader>xx` (Trouble diagnostics) → `]d`/`[d` (navigate) → `<leader>ca` (fix)
- **Refactoring**: Select code → `<leader>re` (extract function) → `<leader>rv` (extract variable) → `<leader>ri` (inline)
- **Search and replace**: `<leader>sr` (global search/replace) or `<leader>fs` + `<C-q>` (quickfix)
- **Session management**: `<leader>qs` (restore session) → `<leader>qd` (stop saving)
- **Terminal**: `<C-\>` (toggle) → `<leader>tf` (float) → `<leader>th` (horizontal) → `<leader>tv` (vertical)
- **TODO management**: `]t` (next todo) → `[t` (prev todo) → `<leader>ft` (find todos)
- **Folding**: `zR` (open all) → `zM` (close all) → `zr/zm` (open/close by level)
- **Clipboard**: `<leader>y` (yank to system) → `<leader>P` (paste from system) → `<leader>dd` (delete without yank)

### Error Recovery
- LSP issues: `:LspRestart` or check `:Mason` for server installation
- Plugin issues: `:Lazy sync` to clean and reinstall
- Treesitter issues: `:TSUpdate` to update parsers
- Full reset: Remove `~/.local/share/nvim` and restart

## Documentation Guidelines

### Documentation Files
- All documentation files should be created in the `docs/` folder
- Documentation filenames should be in UPPERCASE
- Use descriptive names like `KEYBINDINGS.md`, `SETUP_GUIDE.md`, etc.
- Documentation files are managed in the `docs/` directory for better organization
