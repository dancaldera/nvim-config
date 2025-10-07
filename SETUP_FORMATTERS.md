# Installing Missing Formatters & Tools

Your Neovim configuration is working great! However, some optional formatters are missing. Here's how to install them.

## 📊 Current Status

✅ **Working:**
- LSP servers (all installed via Mason)
- Treesitter parsers (all installed)
- Core functionality (100% working)

⚠️ **Optional (Install if you use these languages):**
- Formatters for specific languages
- Some external tools

## 🔧 Install Formatters

### JavaScript/TypeScript/Web (Prettier)
```bash
# Install prettier globally
npm install -g prettier

# Or install per project
npm install --save-dev prettier
```

### Lua (Stylua)
```bash
# Using cargo (Rust)
cargo install stylua

# Or using Homebrew
brew install stylua

# Or using Mason
:MasonInstall stylua
```

### Python (Black & Isort)
```bash
# Install black
pip install black

# Install isort
pip install isort

# Or using pipx (recommended)
pipx install black
pipx install isort
```

### Go (Goimports)
```bash
# Install goimports
go install golang.org/x/tools/cmd/goimports@latest
```

### C/C++ (Clang-format)
```bash
# Using Homebrew
brew install clang-format

# Or it might already be installed with Xcode tools
clang-format --version
```

### Shell Scripts (Shfmt)
```bash
# Using Homebrew
brew install shfmt

# Using Go
go install mvdan.cc/sh/v3/cmd/shfmt@latest
```

## 🚀 Quick Install All (macOS)

```bash
# Install all formatters at once
npm install -g prettier
brew install stylua shfmt clang-format
pip install black isort
go install golang.org/x/tools/cmd/goimports@latest
```

## 📝 Optional Tools

### FD (Better file finding - Optional but recommended)
```bash
brew install fd
```
**Benefit:** Faster Telescope file search

### Tree-sitter CLI (Optional)
```bash
npm install -g tree-sitter-cli
```
**Benefit:** Only needed for `:TSInstallFromGrammar`

### Regex Parser for Noice (Optional)
```vim
:TSInstall regex
```
**Benefit:** Better cmdline highlighting

## 🔍 Verify Installation

After installing, verify in Neovim:

```vim
:checkhealth conform
```

All formatters should show ✅ OK

## ⚡ Which Formatters Do You Need?

**Only install formatters for languages you actually use!**

| Language | Formatter | Install Command |
|----------|-----------|----------------|
| JavaScript/TypeScript/React | prettier | `npm install -g prettier` |
| Lua | stylua | `brew install stylua` |
| Python | black, isort | `pip install black isort` |
| Go | goimports | `go install golang.org/x/tools/cmd/goimports@latest` |
| C/C++ | clang-format | `brew install clang-format` |
| Shell | shfmt | `brew install shfmt` |

## 🎯 Recommended: Install Only What You Use

**For Web Development:**
```bash
npm install -g prettier
```

**For Python Development:**
```bash
pip install black isort
```

**For Go Development:**
```bash
go install golang.org/x/tools/cmd/goimports@latest
```

**For Lua/Neovim Config:**
```bash
brew install stylua
```

## ⚠️ Provider Warnings (Can Ignore)

The following warnings are **safe to ignore** unless you specifically need them:

### Node.js Provider
```vim
" Add to init.lua if you don't need Node.js provider
vim.g.loaded_node_provider = 0
```

### Python Provider
```vim
" Add to init.lua if you don't need Python provider
vim.g.loaded_python3_provider = 0
```

### Perl/Ruby Providers
```vim
" Add to init.lua if you don't need these
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
```

## 🔧 Disable Provider Warnings

If you don't use these providers, add this to your `init.lua`:

```lua
-- Disable unused providers (optional)
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
```

## ✅ Everything Else is Perfect!

- ✅ LSP working perfectly
- ✅ Treesitter working perfectly
- ✅ AI completion working
- ✅ Git integration working
- ✅ All plugins loaded correctly

**Your setup is production-ready even without the formatters!** Formatters are only needed if you want automatic code formatting for specific languages.

## 🎯 Minimal Setup (Recommended)

For most users, just install prettier for web development:

```bash
npm install -g prettier
```

That's it! Everything else is optional based on your needs.

## 📊 Summary

**Required:** ❌ None - Everything is optional!

**Recommended:**
- `prettier` - If you do web development
- `stylua` - If you edit Neovim configs
- Language-specific formatters - Only for languages you use

**Optional:**
- `fd` - Faster file finding
- `tree-sitter-cli` - Advanced parser features
- Provider packages - Only if you use remote plugins

Your Neovim is already **fully functional and optimized** without any of these! 🚀
