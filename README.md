# Neovim Configuration

Modern Neovim setup optimized for full-stack development with AI-powered completion, LSP support, and a git-focused workflow.

## ✨ Key Features

- **🤖 AI Completion**: GitHub Copilot with inline suggestions
- **💻 Full LSP**: 13+ language servers with auto-installation
- **🔍 Advanced Search**: Telescope fuzzy finder with live grep
- **🔧 Git Integration**: Gitsigns, AI-assisted commits, GitHub account switching
- **📦 Modular Plugin Layout**: Split by capability for easier maintenance

## 🛠️ Supported Languages

**Programming**: JavaScript/TypeScript, Python, Go, C/C++, Rust, Lua
**Web**: HTML, CSS, JSON, YAML, Markdown

All LSP servers auto-install via Mason.

## 📋 Prerequisites

**Required:**
- Neovim >= 0.10.0 (**0.11+ recommended** for native LSP features) (`nvim --version`)
- Git
- ripgrep (`brew install ripgrep`)

**Optional** (install for languages you use):
- Node.js, Python 3, Go, Rust

> **Note:** Neovim 0.11+ provides native LSP configuration via `vim.lsp.config()`. On 0.10, some features may have reduced functionality.

## 🚀 Quick Start

### 1. Install
```bash
# Backup existing config
mv ~/.config/nvim ~/.config/nvim.backup

# Clone this config
git clone <repo-url> ~/.config/nvim

# Launch Neovim (auto-installs plugins)
nvim
```

### 2. Setup AI Completion
```vim
:Copilot auth
```
Follow browser prompt to authenticate with GitHub.

### 3. Verify
```vim
:checkhealth    # System health
:Mason          # LSP servers
:Lazy           # Plugins
```

## 🎯 Essential Keybindings

**AI Completion:**
```
<Ctrl-g>     Accept AI suggestion
<Ctrl-x>     Dismiss
```

**File Navigation:**
```
<leader>ff   Find files
<leader>fs   Search in files
<leader>ee   Toggle file explorer
```

**Code:**
```
gd           Go to definition
K            Show documentation
<leader>ca   Code actions
<leader>xs   Symbols (Trouble)
```

**Git:**
```
]c / [c      Next/prev hunk
<leader>hp   Preview hunk
<leader>hs   Stage hunk
<leader>gb   Toggle blame
<leader>gd   Toggle deleted
```

**Pro Tip:** Press `<Space>` and wait - Which-Key shows all keybindings!

📖 **Full reference:** `docs/KEYBINDINGS.md`

## 🔧 Troubleshooting

**AI issues:**
```vim
:Copilot status
:Copilot auth
```

**LSP issues:**
```vim
:LspInfo
:LspRestart
:Mason
```

**Plugin issues:**
```vim
:Lazy sync
```

**Nuclear option:**
```bash
rm -rf ~/.local/share/nvim ~/.cache/nvim
nvim  # Reinstalls everything
```

## 🔄 Updates

```vim
:Lazy update      # Plugins
:MasonUpdate      # LSP servers
:TSUpdate         # Treesitter
```

## 📊 Performance

Performance guidance lives in [`docs/PERFORMANCE.md`](/Users/danielcaldera/.config/nvim/docs/PERFORMANCE.md). The previous hard-coded startup and memory numbers were removed because this repository does not benchmark them automatically.

## 📚 Documentation

- `CLAUDE.md` - Developer/AI guide
- `docs/KEYBINDINGS.md` - Complete keybinding reference
- `docs/SETUP_FORMATTERS.md` - Formatter installation

---

Happy coding! 🚀
