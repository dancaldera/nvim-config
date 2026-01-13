# Neovim Configuration

Modern Neovim setup optimized for full-stack development with AI-powered completion, LSP support, and science-based colorscheme.

## ✨ Key Features

- **⚡ Lightning Fast**: ~76ms startup time, 3-5x less memory than VSCode
- **🤖 AI Completion**: GitHub Copilot integration with inline suggestions
- **💻 Full LSP Support**: 13+ language servers with auto-installation
- **🎨 Eye-Friendly Theme**: Custom Gruvbox scientifically optimized to reduce eye strain
- **🔍 Advanced Search**: Telescope fuzzy finder with live grep
- **🔧 Git Integration**: Gitsigns for hunks, staging, and inline blame
- **📦 55+ Plugins**: Carefully curated, lazy-loaded for performance

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

**Required:**
- **Neovim >= 0.10.0** (optimized for 0.12.x) - Check with `nvim --version`
- **Git** - For plugin management
- **ripgrep** - For file search (`brew install ripgrep` on macOS)

**Optional (install only for languages you use):**
- **Node.js** - JavaScript/TypeScript LSP
- **Python 3** - Python LSP
- **Go** - Go LSP
- **Rust** - Rust LSP
- **fd** - Better file finding (`brew install fd`)

## 🚀 Quick Start

### 1. Install
```bash
# Backup existing config (if any)
mv ~/.config/nvim ~/.config/nvim.backup

# Clone this config
git clone <this-repo-url> ~/.config/nvim

# Launch Neovim (plugins auto-install)
nvim
```

### 2. Setup AI Completion (Required!) 🎯

**This is the most important step!**

```vim
:Copilot auth
```

**What happens:**
1. 🌐 Browser opens
2. 🔐 Sign in with GitHub
3. 📋 Enter the code from Neovim
4. ✅ Done! AI completion active

**Note:** GitHub Copilot is free for students, educators, and open source maintainers.

### 3. Test It Works

1. Create a test file: `:e test.js`
2. Enter insert mode: `i`
3. Type: `function add`
4. **Look for gray ghost text** - that's AI!
5. **Press `<Ctrl-g>` to accept** 🚀

### 4. Verify Everything

```vim
:checkhealth    " Check system health
:Mason          " View LSP servers
:Lazy           " View installed plugins
```

All LSP servers install automatically via Mason. Pre-configured servers: `ts_ls`, `lua_ls`, `pyright`, `html`, `cssls`, `tailwindcss`, `gopls`, `clangd`, `rust_analyzer`, `jsonls`, `yamlls`, `bashls`, `emmet_ls`.

## 🎯 Essential Keybindings

**AI Completion (Most Important!):**
```
<Ctrl-g>     Accept AI suggestion  👈 REMEMBER THIS!
<Ctrl-;>     Next AI suggestion
<Ctrl-x>     Dismiss suggestion
<M-CR>       Open Copilot panel
```

**File Navigation:**
```
<leader>ff   Find files          (Space + f + f)
<leader>fs   Search in files     (Space + f + s)
<leader>e    Toggle file tree    (Space + e)
<C-e>        Focus file tree
```

**Code Navigation:**
```
gd           Go to definition
K            Show documentation
<leader>ca   Code actions        (Space + c + a)
<leader>ti   Toggle inlay hints
```

**Git (Gitsigns):**
```
]c / [c      Next/prev git hunk
<leader>hp   Preview hunk        (Space + h + p)
<leader>hs   Stage hunk          (Space + h + s)
<leader>tb   Toggle blame        (Space + t + b)
```

**Format & Lint:**
```
<leader>jf   Format buffer       (Space + j + f)
<leader>jl   Toggle auto-lint    (Space + j + l)
```

**Diagnostics:**
```
<leader>xx   Show diagnostics    (Space + x + x)
]d / [d      Next/prev diagnostic
```

📖 **Full reference:** See `docs/KEYBINDINGS.md`

## 💡 Pro Tips

### 1. Use Which-Key
Press `<Space>` and wait - Which-Key shows all available keybindings!

### 2. AI + Comments
```javascript
// Function to validate email and check domain
// AI will suggest the entire function!
```

### 3. Quick File Search
- `<leader>ff` - Find files instantly
- `<leader>fs` - Search text in project
- `<leader>ft` - Find all TODOs

## 🔧 Troubleshooting

### AI Not Working?
```vim
:Copilot auth      " Re-authenticate
:Copilot status    " Check status
```

### LSP Not Working?
```vim
:LspInfo      " Check server status
:LspRestart   " Restart servers
:Mason        " View/install servers
```

### Plugins Not Loading?
```vim
:Lazy sync    " Sync all plugins
:Lazy clean   " Remove unused
```

### Start Fresh (Nuclear Option)
```bash
rm -rf ~/.local/share/nvim ~/.cache/nvim
nvim  # Reinstalls everything
```


## 🔄 Updates

### Update Everything
```vim
:Lazy update      " Update plugins
:MasonUpdate      " Update LSP servers
:TSUpdate         " Update Treesitter parsers
```

### Update Config (if using git)
```bash
cd ~/.config/nvim && git pull
```

## 📊 Performance

| Metric | This Config | VSCode |
|--------|-------------|--------|
| Startup | ~76ms ⚡ | 1-3 seconds |
| Memory | 150-200MB | 400-800MB |
| Plugins | 55 (32 lazy-loaded) | N/A |

## 📚 Documentation

- **KEYBINDINGS.md** - Complete keybinding reference
- **IMPLEMENTED_FEATURES.md** - All features and plugins
- **COPILOT_SETUP.md** - AI completion guide
- **AI_COMPLETION_GUIDE.md** - Advanced AI usage
- **SETUP_FORMATTERS.md** - Install formatters (optional)
- **COLORSCHEME.md** - Science-based theme details
- **AGENTS.md** - Developer/AI assistant guide

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📄 License

This configuration is open source and available under the MIT License.

---

Happy coding with AI superpowers! 🎉🚀
