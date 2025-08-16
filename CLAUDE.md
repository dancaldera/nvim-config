# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

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
   - nvim-cmp with multiple sources (LSP, buffer, path, snippets)
   - LuaSnip for snippet expansion
   - VS Code-style pictograms via lspkind

3. **Formatting Layer** (`formatting.lua`):
   - Conform.nvim for code formatting
   - Language-specific formatters with fallback to LSP
   - Format-on-save enabled by default

### Key Plugin Responsibilities

- **nvim-tree**: File explorer with git integration
- **Telescope**: Fuzzy finder for files, text, LSP symbols, diagnostics
- **Treesitter**: Syntax highlighting, text objects, auto-tagging
- **Gitsigns**: Git integration with hunk management
- **Which-key**: Keybinding discovery and documentation
- **Catppuccin**: Color scheme with plugin integrations
- **Trouble**: Advanced diagnostics and LSP symbol navigation
- **nvim-spectre**: Global search and replace functionality
- **persistence.nvim**: Session management and restoration
- **indent-blankline**: Visual indentation guides
- **nvim-colorizer**: Highlight color codes in files

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
- File navigation: `<leader>ff` (find files) → `<leader>fs` (search text)
- Code exploration: `gd` (definition) → `K` (hover docs) → `<leader>ca` (code actions)
- Git workflow: `]c` (next hunk) → `<leader>hp` (preview) → `<leader>hs` (stage)
- Window management: `<leader>sv` (vertical split) → `<C-h/j/k/l>` (navigate)
- Diagnostics: `<leader>xx` (Trouble diagnostics) → `]d`/`[d` (navigate) → `<leader>ca` (fix)
- Search and replace: `<leader>sr` (global search/replace) or `<leader>fs` + `<C-q>` (quickfix)
- Session management: `<leader>qs` (restore session) → `<leader>qd` (stop saving)

### Error Recovery
- LSP issues: `:LspRestart` or check `:Mason` for server installation
- Plugin issues: `:Lazy sync` to clean and reinstall
- Treesitter issues: `:TSUpdate` to update parsers
- Full reset: Remove `~/.local/share/nvim` and restart