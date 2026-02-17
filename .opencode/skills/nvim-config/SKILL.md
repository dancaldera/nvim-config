---
name: nvim-config
description: Comprehensive guide for working with this Neovim lazy.nvim configuration - architecture, keybindings, language support, and plugin management
license: MIT
compatibility: opencode
metadata:
  editor: neovim
  plugin-manager: lazy.nvim
  scope: full-config
---

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
│   │   ├── compatibility.lua  # Version checks
│   │   ├── health.lua         # Health checks
│   │   ├── openai.lua         # OpenAI API integration
│   │   └── github.lua         # GitHub account management
│   └── plugins/               # Plugin configurations
│       ├── lsp-core.lua       # LSP setup & keymaps
│       ├── lsp-servers.lua    # Server configurations
│       ├── productivity.lua   # Projects, sessions, markdown
│       ├── ui-statusline.lua  # Lualine
│       ├── ui-notifications.lua # Notify, noice, dressing
│       ├── ui-indicators.lua  # Indent, illuminate, folding
│       ├── ui-bufferline.lua  # Cokeline, buffer management
│       ├── formatting.lua     # Code formatting
│       ├── completion.lua     # AI/LSP completion
│       ├── treesitter.lua     # Syntax highlighting
│       ├── telescope.lua      # Fuzzy finder
│       ├── git.lua            # Git integration
│       ├── diagnostics.lua    # Diagnostics management
│       ├── editor.lua          # Editor enhancements
│       ├── python.lua          # Python-specific configs
│       ├── markdown.lua        # Markdown support
│       ├── dev-tools.lua       # Development tools
│       └── nvim-tree.lua       # File explorer
```

### Initialization Flow
1. `init.lua` loads `lua/config/lazy.lua` to set up lazy.nvim
2. Lazy loads all plugin configurations from `lua/plugins/`
3. Core configs in `lua/config/` are loaded
4. Plugins auto-install on first run

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

2. **Completion Layer** (`completion.lua`):
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
**Dev Tools**: Trouble, todo-comments, snacks (terminal/dashboard), refactoring
**Navigation**: flash, nvim-spectre, persistence, mini.ai

## Keybindings & Namespaces

### Namespaces Overview
- `<leader>b` - Buffer operations
- `<leader>c` - Code actions
- `<leader>d` - Diagnostics
- `<leader>e` - File explorer
- `<leader>f` - Find/Search
- `<leader>g` - **Git operations** (workflow, accounts, toggles)
- `<leader>h` - Git hunks
- `<leader>j` - Format/Lint
- `<leader>p` - Python
- `<leader>q` - Session
- `<leader>r` - Rename/Refactor/Restart
- `<leader>s` - Split/Search
- `<leader>t` - **Terminal/Toggle** (terminal commands)
- `<leader>x` - Trouble/Diagnostics

### Common Workflows

**File Navigation**
`<leader>ff` → `<leader>fs` → `<leader>fp`
- `<leader>ff` - Find files (Telescope)
- `<leader>fs` - Search in files (live grep)
- `<leader>fp` - Search project (recent files)

**Code Exploration**
`gd` (definition) → `K` (hover) → `<leader>ca` (code actions)
- `gd` - Go to definition
- `K` - Show hover documentation
- `<leader>ca` - Show code actions

**Git Hunks**
`]c`/`[c` (navigate) → `<leader>hp` (preview) → `<leader>hs` (stage)
- `]c` - Next hunk
- `[c` - Previous hunk
- `<leader>hp` - Preview hunk
- `<leader>hs` - Stage hunk
- `<leader>hu` - Undo stage hunk

**Git Toggles**
- `<leader>gb` - Toggle git blame
- `<leader>gd` - Toggle deleted lines

**Git Diff**
`<leader>hd` (diff this) → `<leader>hD` (diff cached)
- `<leader>hd` - Diff this hunk/file
- `<leader>hD` - Diff against staged

**Window Management**
`<leader>sv` (split) → `<C-h/j/k/l>` (navigate) → `<M-h/j/k/l>` (resize)
- `<leader>sv` - Split vertically
- `<leader>sh` - Split horizontally
- `<C-h/j/k/l>` - Navigate between windows
- `<M-h/j/k/l>` - Resize windows

**Diagnostics**
`<leader>xx` (Trouble) → `<leader>xc` (copy to clipboard) → `]d`/`[d` (navigate) → `<leader>ca` (fix)
- `<leader>xx` - Open Trouble list
- `<leader>xc` - Copy all diagnostics to clipboard
- `]d` - Next diagnostic
- `[d` - Previous diagnostic
- `<leader>ca` - Fix diagnostic with code action

**Git Workflow (AI-powered)**
`<leader>gc` (commit with AI) → `<leader>gC` (auto-commit all) → `<leader>gA` (auto-commit & push) → `<leader>gP` (push only)
- `<leader>gc` - Commit with AI message (stages current file if nothing staged)
- `<leader>gC` - Auto-commit all changes with AI
- `<leader>gA` - Auto-commit all & push (one-shot command)
- `<leader>gP` - Push to remote

**GitHub Accounts**
`<leader>ga` (toggle account) → `<leader>gas` (show status)
- `<leader>ga` - Toggle between GitHub accounts
- `<leader>gas` - Show full GitHub auth status

**Refactoring**
Select → `<leader>re` (extract function) → `<leader>rv` (variable) → `<leader>ri` (inline)
- Select code in visual mode
- `<leader>re` - Extract function
- `<leader>rv` - Extract variable
- `<leader>ri` - Inline variable/function

**Terminal**
`<C-\>` (toggle) → `<leader>tt` (toggle) → `<leader>tf/th/tv` (float/horizontal/vertical)
- `<C-\>` - Toggle terminal
- `<leader>tt` - Toggle terminal
- `<leader>tf` - Toggle floating terminal
- `<leader>th` - Toggle horizontal terminal
- `<leader>tv` - Toggle vertical terminal

**Sessions**
`<leader>qs` (restore) → `<leader>qd` (stop saving)
- `<leader>qs` - Restore session
- `<leader>qd` - Stop saving session

**Clipboard**
`<leader>y` (yank) → `<leader>P` (paste) → `<leader>dd` (delete without yank)
- `<leader>y` - Yank to system clipboard
- `<leader>P` - Paste from system clipboard
- `<leader>dd` - Delete without yanking

## Adding Language Support

### Step-by-Step
1. Add server to `ensure_installed` in `lua/plugins/lsp-servers.lua`
2. Add parser to `ensure_installed` in `lua/plugins/treesitter.lua`
3. Add formatter in `lua/plugins/formatting.lua`
4. Auto-installed via Mason on startup

### Example: Adding Rust Support

**1. Add LSP server in `lua/plugins/lsp-servers.lua`:**
```lua
mason_tool_installer.setup({
  ensure_installed = {
    -- ... existing servers ...
    "rust-analyzer",
  },
})

-- Add server configuration
vim.lsp.config("rust_analyzer", {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  settings = {
    ["rust-analyzer"] = {
      cargo = { allFeatures = true },
      checkOnSave = { command = "clippy" },
    },
  },
})
```

**2. Add parser in `lua/plugins/treesitter.lua`:**
```lua
vim.g.ts_enable_language = function(lang)
  return lang ~= "zig" and lang ~= "rust"
end
```

**3. Add formatter in `lua/plugins/formatting.lua`:**
```lua
conform.formatters_by_ft = {
  -- ... existing formatters ...
  rust = { "rustfmt" },
}
```

### Currently Supported Languages
- **TypeScript/JavaScript**: ts_ls, prettier
- **Lua**: lua_ls, stylua
- **Python**: pyright, ruff, black
- **Go**: gopls, gofmt
- **C/C++**: clangd, clang-format
- **Rust**: rust_analyzer, rustfmt
- **HTML/CSS**: emmet_ls, prettier
- **YAML/JSON**: yamlls, prettier
- **Bash**: bashls

## Plugin Management

### Configuration Patterns
1. **Use lazy.nvim spec**: All plugins in `lua/plugins/` directory
2. **Follow event-based loading**: Use `event`, `cmd`, `ft`, `keys` for lazy loading
3. **Keep it modular**: One plugin configuration per file when possible
4. **No comments**: Don't add code comments unless explicitly requested
5. **Follow existing style**: Match indentation, naming, and patterns

### Adding a New Plugin
1. Create or edit appropriate file in `lua/plugins/`
2. Add plugin using lazy.nvim spec:
```lua
return {
  "plugin-author/plugin-name",
  event = "VeryLazy", -- or "BufReadPre", "BufEnter", etc.
  opts = {
    -- plugin options
  },
}
```
3. Neovim will auto-install the plugin on next startup

### Removing a Plugin
1. Find the plugin in `lua/plugins/` directory
2. Remove the plugin spec
3. Run `:Lazy clean` to remove the plugin

### Updating Plugins
- `:Lazy update` - Update all plugins
- `:Lazy sync` - Clean and update
- `:Lazy profile` - Profile loading times

## Important Commands

### Plugin Management
- `:Lazy` - Plugin manager interface
- `:Lazy update` - Update all plugins
- `:Lazy sync` - Clean and update
- `:Lazy profile` - Profile loading times

### LSP & Language Servers
- `:Mason` - Manage LSP servers/formatters/linters
- `:LspInfo` - Show LSP status
- `:LspRestart` - Restart LSP servers
- `:LspStop` - Stop LSP servers

### Treesitter
- `:TSUpdate` - Update all parsers
- `:TSInstall <language>` - Install parser
- `:TSUninstall <language>` - Uninstall parser

### Code Formatting
- Auto-format on save via conform.nvim
- Manual: `<leader>mp` in normal/visual mode
- Supported: prettier, stylua, black, gofmt, rustfmt, clang-format

### Health Checks
- `:checkhealth` - Run Neovim health checks
- `<leader>hc` - Run health checks
- Check compatibility.lua for version requirements

## Troubleshooting

### LSP Issues
- `:LspRestart` - Restart LSP servers
- `:Mason` - Check if server is installed
- Check `lua/plugins/lsp-servers.lua` for configuration errors

### Plugin Issues
- `:Lazy sync` - Sync and reinstall plugins
- Check `lua/plugins/` directory for configuration errors
- Remove `~/.local/share/nvim` for full reset

### Treesitter Issues
- `:TSUpdate` - Update all parsers
- Check if parser is installed in `lua/plugins/treesitter.lua`
- Verify file extension matches parser name

### Formatting Issues
- Check `lua/plugins/formatting.lua` for formatter configuration
- Ensure formatter is installed via Mason or system package
- Try manual format with `<leader>mp`

### Full Reset
If everything is broken:
1. Quit Neovim
2. Remove `~/.local/share/nvim`
3. Remove `~/.cache/nvim`
4. Restart Neovim
5. Plugins will auto-install

## Recent Changes

### February 2025 - AI-Powered Git Workflow & Enhanced Diagnostics

**AI-Powered Git Workflow**
- **git-workflow.lua**: Smart commit with AI-generated messages using OpenAI GPT-4o
  - `<leader>gc` - Commit with AI message (stages current file if nothing staged)
  - `<leader>gP` - Push to remote
  - `<leader>gA` - Auto-commit all & push (one-shot command)
  - All commits allow editing AI-generated message before committing
  - Fallback: `[timestamp] Auto-commit` if OpenAI API unavailable
  - Requires `OPENAI_API_KEY` in environment or `.zshrc`/`.bashrc`/`.zprofile`

**GitHub Account Management**
- **github.lua**: Multi-account GitHub CLI support
  - `<leader>ga` - Toggle between GitHub accounts (cycles through all accounts)
  - `<leader>gas` - Show full GitHub auth status (floating terminal)
  - Account caching (60s TTL) to minimize CLI calls
  - Status line display: ` @username` when in git repository

**Enhanced Diagnostics**
- **diagnostics copy**: Export all diagnostics to clipboard
  - `<leader>xc` - Copy all diagnostics to system clipboard
  - Format: `file:line:col [severity] message`
  - Notifications show count of copied diagnostics

**New Configuration Modules**
- **openai.lua**: OpenAI API integration with caching and environment loading
- **github.lua**: GitHub account management and status detection

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
- **lsp_signature.nvim**: Auto-trigger function signature help
- **actions-preview.nvim**: Code action preview with diff
- **refactoring.nvim**: Extract function, inline variable (`<leader>r`)
- **GitHub Copilot**: AI-powered completions (replaced Codeium)

## Code Style Guidelines

### File Conventions
- Lua files: lowercase with underscores (`my_file.lua`)
- Configuration files: lowercase with underscores
- No unnecessary comments
- Follow existing indentation (2 spaces)
- Use lazy.nvim spec format for plugins

### Keybinding Conventions
- Use `<leader>` prefix for custom keybindings
- Group related keybindings by namespace
- Use descriptive mnemonic prefixes
- Document keybindings in AGENTS.md

### Plugin Configuration
- Use lazy loading when possible (event, cmd, ft, keys)
- Keep configuration modular (one file per plugin or related group)
- Use opts table for plugin options
- Check plugin documentation for best practices

## Documentation Structure

All documentation in `docs/` directory:
- `KEYBINDINGS.md` - Complete keybinding reference
- `SETUP_FORMATTERS.md` - Formatter installation guide
- `PLUGINS_REFERENCE.md` - Complete listing of all 68 plugins by category
- `ARCHITECTURE.md` - Configuration architecture and plugin dependency graph
- `LSP_GUIDE.md` - Language-specific LSP setup and troubleshooting
- `TROUBLESHOOTING.md` - Advanced troubleshooting beyond README
- `PERFORMANCE.md` - Startup optimization and profiling techniques
- Use UPPERCASE for doc filenames

## Quick Reference

### Modifying Keybindings
- **General**: `lua/config/keymaps.lua`
- **LSP**: `lua/plugins/lsp-core.lua` (LspAttach autocmd)
- **Plugin-specific**: Within respective plugin files

### Common Issues
- LSP not working? → Check `:LspInfo` and `:Mason`
- Plugin not loading? → Check `:Lazy` status
- Formatting not working? → Check `lua/plugins/formatting.lua` and run `<leader>mp`
- Slow startup? → Run `:Lazy profile` to identify slow plugins

### Best Practices
1. Always use lazy loading for plugins
2. Keep configuration modular
3. Test changes in a clean Neovim instance
4. Commit AGENTS.md to Git for better context
5. Use `<leader>hc` for health checks
6. Use `:Lazy sync` to sync plugins after changes

## Environment Requirements

- **Neovim**: 0.10+ required, 0.11+ recommended
- **Node.js**: Required for some LSP servers (ts_ls, etc.)
- **Python**: Required for some formatters (black, etc.)
- **Rust**: Required for some formatters (rustfmt)
- **Git**: Required for git integration
- **OpenAI API Key**: Optional, for AI-powered git workflow features

## Integration with OpenCode

This skill should be loaded when working with this Neovim configuration. It provides:
- Complete architecture overview
- Keybinding references
- Language support patterns
- Plugin management workflows
- Troubleshooting steps

Use this skill when:
- Adding new language support
- Modifying keybindings
- Adding/removing plugins
- Troubleshooting LSP or formatting issues
- Understanding the configuration structure
