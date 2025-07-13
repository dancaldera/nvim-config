# Neovim Configuration

A modern, well-documented Neovim configuration optimized for full-stack development with support for JavaScript, TypeScript, Python, Go, C++, and web technologies.

## ✨ Features

- **🚀 Modern Plugin Manager**: Uses [lazy.nvim](https://github.com/folke/lazy.nvim) for fast startup and plugin management
- **🔍 File Explorer**: [nvim-tree](https://github.com/nvim-tree/nvim-tree.lua) for intuitive file navigation
- **🔎 Fuzzy Finding**: [Telescope](https://github.com/nvim-telescope/telescope.nvim) for blazing-fast file and text search
- **💻 LSP Support**: Full Language Server Protocol support for multiple languages
- **🎨 Syntax Highlighting**: [Treesitter](https://github.com/nvim-treesitter/nvim-treesitter) for advanced syntax highlighting
- **⚡ Autocompletion**: Intelligent code completion with snippets
- **🎯 Code Formatting**: Automatic code formatting on save
- **🔧 Git Integration**: Built-in git signs and commands
- **📚 Which-Key**: Discover and learn keybindings
- **🌙 Beautiful Theme**: Catppuccin colorscheme
- **🔧 Modern Formatting**: Conform.nvim for code formatting
- **🔍 Enhanced Diagnostics**: Better error and warning display

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

5. **Install LSP servers:** Open Neovim and the language servers will be automatically installed via Mason. You can also manually install additional servers by running:
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
├── init.lua                 # Main configuration entry point
├── lua/
│   ├── config/
│   │   ├── lazy.lua        # Plugin manager setup
│   │   ├── options.lua     # Neovim options
│   │   └── keymaps.lua     # Key mappings
│   └── plugins/
│       ├── colorscheme.lua    # Theme configuration
│       ├── nvim-tree.lua      # File explorer
│       ├── telescope.lua      # Fuzzy finder
│       ├── lsp.lua           # Language server setup
│       ├── treesitter.lua    # Syntax highlighting
│       ├── autocompletion.lua # Completion engine
│       ├── formatting.lua    # Code formatting
│       └── utilities.lua     # Additional utilities
├── README.md
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


## 📖 Learning Resources

- **Neovim Documentation**: `:help` or `https://neovim.io/doc/`
- **Lua Guide**: `:help lua-guide`
- **Plugin Documentation**: Use `:help <plugin-name>` for specific plugins
- **Key Bindings**: See `KEYBINDINGS.md` for detailed shortcut explanations

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📄 License

This configuration is open source and available under the MIT License.

---

Happy coding! 🎉
