# LSP Setup Guide

Language-specific LSP configuration, formatter installation, and troubleshooting for all supported languages.

---

## Table of Contents

1. [Overview](#overview)
2. [General LSP Configuration](#general-lsp-configuration)
3. [Per-Language Setup](#per-language-setup)
4. [Formatter Installation](#formatter-installation)
5. [Linter Installation](#linter-installation)
6. [Troubleshooting LSP](#troubleshooting-lsp)
7. [Adding New Languages](#adding-new-languages)

---

## Overview

This configuration supports **13 LSP servers** with automatic installation via Mason.

### Automatic Installation

**All LSP servers auto-install** when you open a file of that language for the first time.

**No manual setup required** for most languages - just open a file and start coding!

### Supported Languages

| Language | LSP Server | Status | Formatter | Linter |
|----------|-----------|--------|-----------|--------|
| Lua | lua_ls | Required | stylua | (LSP) |
| JavaScript/TypeScript | ts_ls | Required | prettier/biome | eslint |
| HTML | html | Required | prettier | (LSP) |
| CSS | cssls | Required | prettier | (LSP) |
| JSON | jsonls | Required | prettier | (LSP) |
| YAML | yamlls | Required | prettier | yamllint |
| Python | pyright | Optional | black/ruff | ruff |
| Go | gopls | Optional | gofmt/goimports | (LSP) |
| C/C++ | clangd | Optional | clang-format | (LSP) |
| Rust | rust_analyzer | Optional | rustfmt | (LSP) |
| Tailwind CSS | tailwindcss | Optional | prettier | (LSP) |
| Bash | bashls | Optional | shfmt | shellcheck |
| Emmet | emmet_ls | Optional | - | - |

**Required:** Auto-installed for all users
**Optional:** Auto-installed on first use
**(LSP):** Diagnostics provided by language server

---

## General LSP Configuration

### Common Keybindings (All Languages)

These keybindings work for any language with LSP support:

| Keybinding | Action | Description |
|------------|--------|-------------|
| `gd` | Go to Definition | Jump to where symbol is defined (Telescope) |
| `gD` | Go to Declaration | Jump to symbol declaration |
| `gr` | Find References | Show all references (Telescope) |
| `gi` | Go to Implementation | Jump to implementation |
| `gt` | Go to Type Definition | Jump to type definition |
| `K` | Hover Documentation | Show documentation for symbol under cursor |
| `<C-k>` | Signature Help | Show function signature (insert mode) |
| `<leader>ca` | Code Actions | Show available code actions |
| `<leader>rn` | Rename Symbol | Rename symbol across project |
| `<leader>cs` | Document Symbols | List symbols in current file (Telescope) |
| `[d` / `]d` | Prev/Next Diagnostic | Navigate diagnostics |
| `<leader>d` | Show Diagnostic | Show diagnostic under cursor |
| `<leader>mp` | Format | Format current file/selection |

### LSP Commands

| Command | Purpose |
|---------|---------|
| `:LspInfo` | Show attached LSP servers |
| `:LspRestart` | Restart LSP servers |
| `:LspLog` | View LSP logs |
| `:Mason` | Manage LSP servers/formatters |
| `:MasonUpdate` | Update Mason registry |
| `:MasonInstall <tool>` | Manually install tool |

### Auto-Format on Save

Format on save is **enabled by default** via conform.nvim. To disable temporarily:

```vim
:let b:disable_autoformat = 1  " Current buffer
:let g:disable_autoformat = 1  " All buffers
```

---

## Per-Language Setup

### JavaScript / TypeScript

**LSP Server:** `ts_ls` (TypeScript Language Server)
**Formatter:** `prettier` (primary) or `biome` (if configured)
**Linter:** `eslint` (via nvim-lint)

#### Setup
1. **No setup needed** - just open a `.js`/`.ts`/`.jsx`/`.tsx` file
2. LSP server auto-installs via Mason
3. Prettier auto-detects project config (`.prettierrc`, `.prettierrc.json`)

#### Project Detection
```bash
# Prettier project (auto-detected)
.prettierrc
.prettierrc.json
.prettierrc.js
prettier.config.js

# Biome project (takes precedence)
biome.json
biome.jsonc
```

#### Install Formatters/Linters
```bash
# Prettier (global)
npm install -g prettier

# Biome (project-local recommended)
npm install --save-dev @biomejs/biome

# ESLint (project-local)
npm install --save-dev eslint
```

#### Inlay Hints
TypeScript inlay hints are **disabled by default** for cleaner UI. To enable:
```lua
-- In lua/plugins/lsp-servers.lua, ts_ls settings
includeInlayParameterNameHints = "all"  -- Change from "literals"
```

---

### Python

**LSP Server:** `pyright`
**Formatter:** `black` (primary) or `ruff format`
**Linter:** `ruff`

#### Setup
1. Open a `.py` file → Pyright auto-installs
2. **Install formatters manually:**
```bash
# Global installation
pip install black ruff

# Or in virtual environment
python -m venv venv
source venv/bin/activate  # or `venv\Scripts\activate` on Windows
pip install black ruff
```

#### Virtual Environment Switching
Use `<leader>pe` to switch Python venv:
```vim
<leader>pe  " Opens venv picker
```

Pyright will automatically use the selected venv for imports and type checking.

#### Project Config
```bash
# pyproject.toml (recommended)
[tool.black]
line-length = 88

[tool.ruff]
line-length = 88
select = ["E", "F", "I"]

# Or .ruff.toml
line-length = 88
```

---

### Lua

**LSP Server:** `lua_ls` (Lua Language Server)
**Formatter:** `stylua`

#### Setup
1. Lua files get LSP automatically (you're reading Neovim config!)
2. `vim` global is pre-configured (no "undefined vim" warnings)

#### Install Formatter
```bash
# macOS
brew install stylua

# Or via cargo
cargo install stylua

# Or via Mason
:MasonInstall stylua
```

#### Project Config
```lua
-- stylua.toml
column_width = 120
indent_type = "Tabs"
```

---

### Go

**LSP Server:** `gopls`
**Formatter:** `gofmt` (default) or `goimports`

#### Setup
1. Install Go: `brew install go` (or from https://go.dev)
2. Open a `.go` file → gopls auto-installs

#### Install Formatters
```bash
# goimports (recommended - also organizes imports)
go install golang.org/x/tools/cmd/goimports@latest

# Ensure $GOPATH/bin is in $PATH
export PATH=$PATH:$(go env GOPATH)/bin
```

#### Project Config
```bash
# No config needed - uses Go standard formatting
```

---

### Rust

**LSP Server:** `rust_analyzer`
**Formatter:** `rustfmt`

#### Setup
1. Install Rust: `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
2. Open a `.rs` file → rust_analyzer auto-installs

#### Install Formatter
```bash
# rustfmt comes with Rust installation
rustup component add rustfmt

# If missing:
rustup update
```

#### Project Config
```toml
# rustfmt.toml
max_width = 100
edition = "2021"
```

---

### C / C++

**LSP Server:** `clangd`
**Formatter:** `clang-format`

#### Setup
1. Install LLVM: `brew install llvm` (macOS) or `apt install clang-tools` (Linux)
2. Open a `.c`/`.cpp`/`.h` file → clangd auto-installs

#### Install Formatter
```bash
# macOS
brew install clang-format

# Linux
apt install clang-format

# Or via Mason
:MasonInstall clang-format
```

#### Project Config
```yaml
# .clang-format
BasedOnStyle: LLVM
IndentWidth: 4
ColumnLimit: 100
```

---

### HTML

**LSP Server:** `html`
**Formatter:** `prettier`

#### Setup
1. Open a `.html` file → LSP auto-installs
2. Emmet support via `emmet_ls` for abbreviations

#### Emmet Abbreviations
Type abbreviation + `<Tab>`:
```html
div.container>ul>li*3  <Tab>
```
Expands to:
```html
<div class="container">
  <ul>
    <li></li>
    <li></li>
    <li></li>
  </ul>
</div>
```

#### Auto-Tag Closing
Powered by `nvim-ts-autotag` - tags auto-close and rename in pairs:
```html
<div|       →  <div>|</div>
<h1>test</|  →  <h1>test</h1>
```

---

### CSS / SCSS

**LSP Server:** `cssls` (CSS Language Server)
**Formatter:** `prettier`

#### Setup
1. Open a `.css`/`.scss` file → LSP auto-installs
2. Tailwind CSS support via `tailwindcss` LSP (if `tailwind.config.js` present)

#### Tailwind IntelliSense
Auto-activated in projects with `tailwind.config.js`:
- Class name completion
- Color preview
- Documentation on hover

---

### JSON

**LSP Server:** `jsonls`
**Formatter:** `prettier`

#### Setup
1. Open a `.json` file → LSP auto-installs
2. Schema validation for common files (`package.json`, `tsconfig.json`, etc.)

#### Schema Support
jsonls provides validation and completion for:
- `package.json` (npm)
- `tsconfig.json` (TypeScript)
- `jsconfig.json` (JavaScript)
- `.eslintrc.json` (ESLint)
- Many more via SchemaStore

---

### YAML

**LSP Server:** `yamlls`
**Formatter:** `prettier`
**Linter:** `yamllint`

#### Setup
1. Open a `.yaml`/`.yml` file → LSP auto-installs

#### Install Linter
```bash
# Python required
pip install yamllint

# Or via Mason
:MasonInstall yamllint
```

#### Project Config
```yaml
# .yamllint
rules:
  line-length:
    max: 120
  indentation:
    spaces: 2
```

---

### Bash / Shell Scripts

**LSP Server:** `bashls`
**Formatter:** `shfmt`
**Linter:** `shellcheck`

#### Setup
1. Open a `.sh` file → bashls auto-installs

#### Install Tools
```bash
# macOS
brew install shfmt shellcheck

# Linux
apt install shfmt shellcheck

# Or via Mason
:MasonInstall shfmt shellcheck
```

---

## Formatter Installation

### Via Mason (Recommended)

```vim
:Mason
```
Navigate to **Formatters** section and press `i` to install:
- `prettier` (JS/TS/HTML/CSS/JSON/YAML/Markdown)
- `biome` (JS/TS alternative)
- `stylua` (Lua)
- `black` (Python)
- `ruff` (Python alternative)
- `gofmt`/`goimports` (Go)
- `rustfmt` (Rust)
- `clang-format` (C/C++)
- `shfmt` (Bash)

### Manual Installation

See per-language sections above for language-specific installation.

### Project-Aware Formatter Selection

This config uses **intelligent formatter detection** in `lua/plugins/formatting.lua`:

```
Priority:
1. Biome (if biome.json exists)
2. Prettier (if .prettierrc exists)
3. Language-specific formatter (black, gofmt, etc.)
4. LSP formatting (fallback)
```

**Override per-project:** Create formatter config file in project root.

---

## Linter Installation

### Via Mason

```vim
:Mason
```
Navigate to **Linters** section:
- `eslint` (JavaScript/TypeScript)
- `ruff` (Python)
- `shellcheck` (Bash)
- `yamllint` (YAML)

### Auto-Linting

Linters run **on save and text change** via `nvim-lint`. Diagnostics appear inline.

### Disable Linting

```vim
" Per-buffer
:let b:disable_linting = 1

" Edit lua/plugins/formatting.lua to remove linter
```

---

## Troubleshooting LSP

### LSP Not Starting

**Check 1: Is the server installed?**
```vim
:Mason
```
Look for checkmarks next to server names. If missing, press `i` to install.

**Check 2: Is LSP attached?**
```vim
:LspInfo
```
Should show active clients. If empty, LSP didn't start.

**Check 3: Check LSP logs**
```vim
:LspLog
```
Look for error messages.

**Fix: Restart LSP**
```vim
:LspRestart
```

### Completion Not Working

**Check 1: Is nvim-cmp loaded?**
Try typing in insert mode - completion menu should appear.

**Check 2: Is Copilot blocking?**
```vim
:Copilot status
```
If Copilot has errors, LSP completion may be affected.

**Fix: Restart Neovim**
```bash
:qa
nvim
```

### Formatter Not Running

**Check 1: Is formatter installed?**
```bash
which prettier  # or black, stylua, etc.
```

**Check 2: Check conform.nvim**
```vim
:lua print(vim.inspect(require('conform').list_formatters(0)))
```
Should show configured formatters for current filetype.

**Fix: Install formatter**
```vim
:Mason
# Press 'i' on formatter name
```

### Python Virtual Environment Issues

**Problem:** Imports not found, wrong Python version

**Fix 1: Switch venv**
```vim
<leader>pe  " Select correct venv
```

**Fix 2: Verify Python path**
```vim
:lua print(vim.fn.exepath('python'))
```
Should point to venv Python.

**Fix 3: Restart LSP after venv switch**
```vim
:LspRestart
```

### TypeScript "Cannot find module" Errors

**Problem:** Imports not resolving

**Fix 1: Ensure node_modules installed**
```bash
npm install
```

**Fix 2: Check tsconfig.json**
```json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": { ... }
  }
}
```

**Fix 3: Restart LSP**
```vim
:LspRestart
```

### Rust Analyzer Slow / High CPU

**Problem:** rust_analyzer using 100% CPU

**Fix 1: Wait for initial index**
First-time indexing can take 1-5 minutes on large projects.

**Fix 2: Exclude target/ directory**
```toml
# Cargo.toml
[package.metadata.rust-analyzer]
check.workspace = false
```

**Fix 3: Reduce check frequency**
```vim
" In lsp-servers.lua (rust_analyzer settings)
checkOnSave = { enable = false }
```

---

## Adding New Languages

### 1. Add LSP Server

Edit `lua/plugins/lsp-servers.lua`:

```lua
-- Add server config
vim.lsp.config("new_language_ls", {
  capabilities = capabilities,
  on_init = function(_, _)
    -- Silent initialization
  end,
  settings = {
    -- Server-specific settings
  },
})

-- Add to ensure_installed
ensure_installed = {
  ...,
  "new_language_ls",
}
```

### 2. Add Treesitter Parser

Edit `lua/plugins/treesitter.lua`:

```lua
ensure_installed = {
  ...,
  "new_language",
}
```

### 3. Add Formatter (Optional)

Edit `lua/plugins/formatting.lua`:

```lua
formatters_by_ft = {
  new_language = { "formatter_name" },
}
```

### 4. Add Linter (Optional)

Edit `lua/plugins/formatting.lua`:

```lua
linters_by_ft = {
  new_language = { "linter_name" },
}
```

### 5. Restart Neovim

```bash
:qa
nvim
```

Mason will auto-install the new server/formatter/linter.

---

## LSP Features by Language

| Feature | JS/TS | Python | Lua | Go | Rust | C/C++ | HTML | CSS |
|---------|-------|--------|-----|-----|------|-------|------|-----|
| Completion | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Go to Definition | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Hover Docs | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Rename | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| Code Actions | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Diagnostics | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Formatting | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Inlay Hints | ✅ | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ |
| Auto-Import | ✅ | ✅ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ |
| Refactoring | ✅ | ✅ | ❌ | ✅ | ✅ | ✅ | ❌ | ❌ |

---

## Quick Reference

### Essential Keybindings
```
gd         → Go to definition
K          → Hover documentation
<leader>ca → Code actions
<leader>rn → Rename
<leader>mp → Format file
]d / [d    → Next/prev diagnostic
```

### Essential Commands
```
:LspInfo    → Check LSP status
:LspRestart → Restart LSP
:Mason      → Manage tools
:LspLog     → View logs
```

### Verify Setup
```bash
# Check Neovim version (requires 0.10+, recommend 0.11+)
nvim --version

# Check if tools are installed
which prettier black stylua

# Inside Neovim
:checkhealth        # Full health check
:LspInfo           # LSP status
:Mason             # Installed tools
```

---

**See also:**
- `PLUGINS_REFERENCE.md` - Complete plugin listing
- `TROUBLESHOOTING.md` - Advanced troubleshooting
- `SETUP_FORMATTERS.md` - Detailed formatter installation
- `ARCHITECTURE.md` - LSP architecture deep dive
