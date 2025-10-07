# Neovim Configuration

A modern, well-documented Neovim configuration optimized for full-stack development with support for JavaScript, TypeScript, Python, Go, C++, and web technologies.

## ✨ Features

### Core Features
- **🚀 Modern Plugin Manager**: [lazy.nvim](https://github.com/folke/lazy.nvim) with optimized startup (< 50ms)
- **🔍 File Explorer**: [nvim-tree](https://github.com/nvim-tree/nvim-tree.lua) for intuitive file navigation
- **🔎 Fuzzy Finding**: [Telescope](https://github.com/nvim-telescope/telescope.nvim) with enhanced UI and hidden file support
- **💻 LSP Support**: Full Language Server Protocol with inlay hints and modern diagnostics
- **🎨 Syntax Highlighting**: [Treesitter](https://github.com/nvim-treesitter/nvim-treesitter) for advanced syntax highlighting
- **⚡ Autocompletion**: Dual completion system with AI suggestions (Codeium) + LSP/snippets (nvim-cmp)
- **🎯 Code Formatting**: Automatic code formatting on save with language-specific formatters

### Git & Version Control
- **🔧 Git Integration**: Advanced git features with Gitsigns, Neogit, and DiffView
- **📊 Diff Viewer**: Side-by-side diff view for commits and file history
- **🎯 Blame & Hunks**: Inline blame, hunk preview, staging, and navigation

### UI/UX Enhancements
- **🌙 Beautiful Theme**: Catppuccin with extensive plugin integrations
- **📚 Which-Key**: Discover and learn keybindings
- **🎨 Better UI**: Enhanced messages, notifications, inputs with Noice & Notify
- **📊 Dashboard**: Beautiful start screen with quick actions
- **🎯 Buffer Line**: Enhanced buffer tabs with diagnostics
- **🔄 Smooth Scrolling**: Animated smooth scrolling
- **📍 Code Context**: Breadcrumb navigation with nvim-navic

### Development Tools
- **🔍 Enhanced Diagnostics**: Trouble for better error navigation
- **📝 TODO Comments**: Highlight and search TODO, FIXME, NOTE comments
- **🖥️ Integrated Terminal**: ToggleTerm with float/split layouts
- **📁 Project Management**: Auto-detect and switch between projects
- **🔧 Better Folding**: Superior code folding with nvim-ufo
- **🔎 Global Search**: Find and replace across files with Spectre
- **📖 Markdown Preview**: Live preview for markdown files

## 🛠️ Supported Languages

### Programming Languages
- **JavaScript/TypeScript** - Full LSP support with tsserver
- **Python** - LSP with pyright, formatting with black and isort
- **Go** - LSP with gopls, formatting with gofumpt and goimports
- **C/C++** - LSP with clangd, formatting with clang-format
- **Rust** - LSP with rust-analyzer, formatting with rustfmt
- **Lua** - LSP with lua_ls, formatting with stylua

### Web Technologies
- **HTML** - LSP support and Emmet integration
- **CSS** - LSP support and Tailwind CSS integration
- **JSON/YAML** - Full LSP support
- **Markdown** - Enhanced editing experience

## 📋 Prerequisites

Before installing this configuration, ensure you have:

1. **Neovim >= 0.10.0** (This configuration is optimized for 0.12.x)
   ```bash
   # Check your Neovim version
   nvim --version
   ```
   
   **Note:** This configuration uses the latest plugin versions compatible with modern Neovim versions (0.10+).

2. **Git** (for plugin management)

3. **Node.js** (for LSP servers)

4. **Python 3** (for Python LSP)

5. **Go** (for Go LSP)

6. **Clang** (for C/C++ LSP)

7. **Rust** (for Rust LSP)

8. **ripgrep** (for Telescope live grep)
   ```bash
   # Ubuntu/Debian
   sudo apt install ripgrep
   
   # macOS
   brew install ripgrep
   
   # Arch Linux
   sudo pacman -S ripgrep
   ```


9. **fd** (optional, for better file finding)
   ```bash
   # Ubuntu/Debian
   sudo apt install fd-find
   
   # macOS
   brew install fd
   
   # Arch Linux
   sudo pacman -S fd
   ```

## 🚀 Installation

1. **Backup your existing Neovim configuration:**
   ```bash
   mv ~/.config/nvim ~/.config/nvim.backup
   mv ~/.local/share/nvim ~/.local/share/nvim.backup
   mv ~/.cache/nvim ~/.cache/nvim.backup
   ```

2. **Clone this configuration:**
   ```bash
   git clone <this-repo-url> ~/.config/nvim
   ```

3. **Start Neovim:**
   ```bash
   nvim
   ```

4. **Install plugins:** Lazy.nvim will automatically install all plugins on first launch.

5. **Setup AI Completion (Codeium):**
   ```vim
   :Codeium Auth
   ```
   - This will open your browser for authentication
   - Sign in (it's free for individual use!)
   - Copy the token and paste it in Neovim
   - Done! AI completion is now active 🎉

6. **Install LSP servers:** Open Neovim and the language servers will be automatically installed via Mason. You can also manually install additional servers by running:
   ```
   :Mason
   ```
   
   Pre-configured language servers:
   - `ts_ls` for JavaScript/TypeScript  
   - `lua_ls` for Lua
   - `pyright` for Python
   - `html` for HTML
   - `cssls` for CSS
   - `tailwindcss` for Tailwind CSS
   - `emmet_ls` for Emmet
   - `gopls` for Go
   - `clangd` for C/C++
   - `rust_analyzer` for Rust
   - `jsonls` for JSON
   - `yamlls` for YAML
   - `bashls` for Bash

## 📁 Configuration Structure

```
~/.config/nvim/
├── init.lua                     # Main configuration entry point
├── lua/
│   ├── config/
│   │   ├── lazy.lua            # Plugin manager setup (optimized)
│   │   ├── options.lua         # Neovim options (enhanced)
│   │   ├── keymaps.lua         # Key mappings (improved)
│   │   └── compatibility.lua   # Version checking
│   └── plugins/
│       ├── colorscheme.lua        # Catppuccin theme with integrations
│       ├── nvim-tree.lua          # File explorer
│       ├── telescope.lua          # Fuzzy finder (enhanced UI)
│       ├── lsp.lua               # LSP with inlay hints
│       ├── treesitter.lua        # Syntax highlighting
│       ├── autocompletion.lua    # Completion with Tab navigation
│       ├── formatting.lua        # Code formatting
│       ├── utilities.lua         # Core utilities
│       ├── enhanced-editing.lua  # Editor enhancements
│       ├── ui-enhancements.lua   # UI improvements (NEW)
│       ├── git-enhancements.lua  # Advanced git tools (NEW)
│       └── dev-tools.lua         # Development tools (NEW)
├── README.md
├── CLAUDE.md                    # Development guide
└── KEYBINDINGS.md
```

## ⚙️ Customization

### Changing the Colorscheme

To change the colorscheme, edit `lua/plugins/colorscheme.lua`:

```lua
-- Replace catppuccin with your preferred theme
return {
  "your-theme/repo",
  name = "your-theme",
  config = function()
    vim.cmd.colorscheme "your-theme"
  end,
}
```

### Adding New LSP Servers

To add support for new languages, edit `lua/plugins/lsp.lua`:

1. Add the server to the `ensure_installed` list in mason-lspconfig
2. Add the server configuration in the lspconfig setup section

### Modifying Key Bindings

Key bindings are centralized in:
- `lua/config/keymaps.lua` - General keymaps
- Individual plugin files - Plugin-specific keymaps

## 🔧 Troubleshooting

### Plugins Not Loading
```bash
# Clear plugin cache and restart
rm -rf ~/.local/share/nvim
nvim
```

### LSP Not Working
1. Check if the LSP server is installed: `:Mason`
2. Check LSP status: `:LspInfo`
3. Restart LSP: `:LspRestart`

### Mason LSP Server Missing Binary Symlinks
If you get errors like "language server is either not installed, missing from PATH, or not executable":

```bash
# Create missing symlink for lua-language-server
ln -sf ~/.local/share/nvim/mason/packages/lua-language-server/lua-language-server ~/.local/share/nvim/mason/bin/lua-language-server

# For other servers, find the executable and create symlink:
# Example for typescript-language-server:
ln -sf ~/.local/share/nvim/mason/packages/typescript-language-server/node_modules/.bin/typescript-language-server ~/.local/share/nvim/mason/bin/typescript-language-server
```

This issue occurs when Mason doesn't properly create symlinks in the bin directory.

### Treesitter Issues
```bash
# Update parsers
:TSUpdate
```

### Performance Issues
1. Check startup time: `nvim --startuptime startup.log`
2. Profile plugins: `:Lazy profile`

### Install Neovim latest version
```bash
sudo apt remove neovim
```

```bash
# Install from the offical repo
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt update
sudo apt install neovim
```


## 🔄 Package Management & Updates

### Updating Plugins

This configuration uses [lazy.nvim](https://github.com/folke/lazy.nvim) as the plugin manager. Here's how to manage your plugins:

#### Update All Plugins
```bash
# Open Neovim and run:
:Lazy update
```

#### Update Specific Plugin
```bash
# In Neovim:
:Lazy update <plugin-name>
```

#### Check Plugin Status
```bash
# View all plugins and their status:
:Lazy
```

#### Sync Plugins (Clean + Update)
```bash
# Remove unused plugins and update existing ones:
:Lazy sync
```

### Updating LSP Servers

LSP servers are managed by [Mason](https://github.com/williamboman/mason.nvim):

#### Update All LSP Servers
```bash
# In Neovim:
:MasonUpdate
```

#### Install/Update Specific Server
```bash
# Open Mason interface:
:Mason
# Navigate and press 'i' to install or 'u' to update
```

#### Update via Command Line
```bash
# Install specific server:
:MasonInstall typescript-language-server
```

### Updating Treesitter Parsers

Keep syntax highlighting parsers up to date:

```bash
# Update all parsers:
:TSUpdate

# Update specific parser:
:TSUpdate javascript

# Install new parser:
:TSInstall python
```

### Configuration Maintenance

#### Update This Configuration
```bash
# Navigate to your Neovim config directory
cd ~/.config/nvim

# Pull latest changes (if using git)
git pull origin main

# Restart Neovim to apply changes
```

#### Clean Up Old Data
```bash
# Remove plugin cache (will reinstall on next start):
rm -rf ~/.local/share/nvim/lazy

# Remove LSP cache:
rm -rf ~/.local/share/nvim/mason

# Remove all Neovim data (nuclear option):
rm -rf ~/.local/share/nvim ~/.cache/nvim
```

### Automated Updates

You can create a script to automate updates:

```bash
#!/bin/bash
# save as ~/bin/nvim-update.sh and make executable

echo "Updating Neovim configuration..."
cd ~/.config/nvim && git pull

echo "Starting Neovim to update plugins..."
nvim --headless "+Lazy! sync" +qa
nvim --headless "+MasonUpdate" +qa
nvim --headless "+TSUpdate" +qa

echo "Neovim configuration updated!"
```

## 📖 Learning Resources

- **Neovim Documentation**: `:help` or `https://neovim.io/doc/`
- **Lua Guide**: `:help lua-guide`
- **Plugin Documentation**: Use `:help <plugin-name>` for specific plugins
- **Key Bindings**: See `KEYBINDINGS.md` for detailed shortcut explanations

## ⚡ Quick Reference

### AI Completion (Must Read!)
```vim
:Codeium Auth         " First-time setup (authenticate)
<Ctrl-g>             " Accept AI suggestion (INSERT MODE)
<Ctrl-;>             " Next AI suggestion
<Ctrl-x>             " Clear AI suggestion
```
📚 **Full guide**: See `CODEIUM_SETUP.md`

### Essential Keybindings
```vim
<leader>ff           " Find files
<leader>fs           " Search in files
<leader>ee           " Toggle file explorer
<leader>gg           " Open Git UI (Neogit)
<leader>xx           " Show diagnostics
<Ctrl-g>            " Accept AI completion
<Ctrl-Space>        " Trigger LSP completion
```

### First Steps After Install
1. `:Codeium Auth` - Setup AI completion
2. `:Mason` - Verify LSP servers installed
3. `:checkhealth` - Check everything is working
4. `:Lazy` - See installed plugins
5. Read `CODEIUM_SETUP.md` - Learn AI completion

## 📚 Documentation Files

- **CODEIUM_SETUP.md** - AI completion quick start ⭐
- **AI_COMPLETION_GUIDE.md** - Detailed AI usage guide
- **CLAUDE.md** - Developer guide & architecture
- **KEYBINDINGS.md** - Complete keybinding reference
- **OPTIMIZATION_SUMMARY.md** - All optimizations made

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📄 License

This configuration is open source and available under the MIT License.

---

Happy coding with AI superpowers! 🎉🚀
