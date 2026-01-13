# Configuration Architecture

Deep dive into the Neovim configuration structure, loading strategy, and plugin communication patterns.

---

## Table of Contents

1. [Directory Structure](#directory-structure)
2. [Loading Strategy](#loading-strategy)
3. [Plugin Dependency Graph](#plugin-dependency-graph)
4. [Plugin Communication Patterns](#plugin-communication-patterns)
5. [Configuration Layers](#configuration-layers)
6. [Startup Sequence](#startup-sequence)
7. [Performance Optimizations](#performance-optimizations)

---

## Directory Structure

```
~/.config/nvim/
├── init.lua                          # Entry point (49 lines)
├── lazy-lock.json                    # Plugin version lock file
├── README.md                         # User guide
├── CLAUDE.md (→ AGENTS.md)          # AI assistant instructions
│
├── lua/
│   ├── config/                       # Core configuration (742 lines)
│   │   ├── lazy.lua (70)            # Plugin manager bootstrap
│   │   ├── options.lua (105)        # Neovim settings
│   │   ├── keymaps.lua (112)        # General keybindings
│   │   ├── autocmds.lua (25)        # Auto commands
│   │   ├── compatibility.lua (48)   # Version checks & shims
│   │   └── health.lua (382)         # Health check framework
│   │
│   ├── plugins/                      # Plugin configurations (2,886 lines)
│   │   ├── Core LSP (3 files, 636 lines):
│   │   │   ├── lsp-core.lua (205)          # LSP setup, keymaps, on_attach
│   │   │   ├── lsp-servers.lua (191)       # 13 server configs, Mason
│   │   │   └── autocompletion.lua (160)    # nvim-cmp, Copilot, sources
│   │   │       └── formatting.lua (240)    # Formatters, linters, project detection
│   │   │
│   │   ├── Syntax (1 file, 85 lines):
│   │   │   └── treesitter.lua (85)         # Parsers, folding
│   │   │
│   │   ├── Navigation (2 files, ~350 lines):
│   │   │   ├── telescope.lua               # Fuzzy finder, live grep
│   │   │   └── nvim-tree.lua               # File explorer
│   │   │
│   │   ├── UI (4 files, 528 lines):
│   │   │   ├── ui-statusline.lua (92)      # Lualine
│   │   │   ├── ui-notifications.lua (140)  # Noice, notify, dressing
│   │   │   ├── ui-indicators.lua (96)      # Indent, illuminate, colorizer
│   │   │   └── ui-bufferline.lua (200)     # Cokeline, buffer management
│   │   │
│   │   ├── Editing (2 files, 190 lines):
│   │   │   ├── enhanced-editing.lua (79)   # Surround, pairs, comments, folding
│   │   │   └── enhanced-diagnostics.lua (111) # Trouble.nvim
│   │   │
│   │   ├── Dev Tools (3 files, 750 lines):
│   │   │   ├── dev-tools.lua (294)         # TODO, terminal (snacks)
│   │   │   ├── productivity.lua (135)      # Projects, markdown, sessions
│   │   │   └── modern-enhancements.lua (321) # Flash, aerial, refactoring, spectre
│   │   │
│   │   ├── Git (1 file, 105 lines):
│   │   │   └── git-enhancements.lua (105)  # Gitsigns, neogit, diffview, conflict
│   │   │
│   │   ├── Language-Specific (1 file, 111 lines):
│   │   │   └── python.lua (111)            # Virtual env switching
│   │   │
│   │   └── Utilities (2 files):
│   │       ├── colorscheme.lua (15)        # Custom Gruvbox loader
│   │       └── utilities.lua               # Which-key, bqf, buffer manager, neoscroll
│   │
│   └── colors/
│       └── gruvbox-custom.lua              # Custom colorscheme definition
│
└── docs/
    ├── KEYBINDINGS.md                      # Complete keymap reference
    ├── SETUP_FORMATTERS.md                 # Formatter installation
    ├── PLUGINS_REFERENCE.md                # All 69 plugins documented
    ├── ARCHITECTURE.md                     # This file
    ├── LSP_GUIDE.md                        # Language-specific LSP setup
    ├── TROUBLESHOOTING.md                  # Advanced troubleshooting
    └── PERFORMANCE.md                      # Optimization guide
```

**Key Principles:**
- **Separation of Concerns:** config/ vs plugins/
- **Logical Grouping:** UI files together, LSP files together
- **File Size:** No file >400 lines (split when too large)
- **Naming:** Descriptive names (lsp-core vs lsp-servers)

---

## Loading Strategy

### 1. Bootstrap Phase (init.lua)

```lua
-- init.lua execution order:
1. Load lua/config/compatibility.lua    -- Version checks
2. Load lua/config/lazy.lua             -- Bootstrap lazy.nvim
3. lazy.nvim discovers lua/plugins/*.lua
4. Load lua/config/options.lua          -- Core settings
5. Load lua/config/keymaps.lua          -- General keybindings
6. Load lua/config/autocmds.lua         -- Auto commands
```

**Why this order?**
- Compatibility first → fail fast on old Neovim
- Lazy.nvim before plugins → manages loading
- Options before keymaps → settings affect keybindings

### 2. Lazy Loading Events

69 plugins use various loading triggers:

| Event | When Triggered | Example Plugins |
|-------|----------------|-----------------|
| `VeryLazy` | After UI renders (~200ms) | which-key, mini.*, persistence |
| `BufReadPre` | Before opening any file | nvim-tree, treesitter, gitsigns |
| `BufReadPost` | After file loaded | nvim-ufo (folding) |
| `InsertEnter` | Entering insert mode | nvim-cmp, copilot, LuaSnip |
| `CmdlineEnter` | Opening cmdline | noice.nvim |
| `ft = {...}` | File type detection | python.lua (ft=python), markdown-preview |
| `cmd = "..."` | Command invocation | Mason (:Mason), Telescope (:Telescope) |
| `keys = {...}` | First keypress | flash.nvim (`s`), refactoring (`<leader>re`) |

**Lazy Loading Benefits:**
- Startup: ~76ms (vs ~500ms loading all plugins)
- Memory: 150MB idle (vs 300MB all plugins)
- Perceived speed: UI renders instantly

### 3. LSP Loading Sequence

LSP is the most complex loading chain:

```
1. BufReadPre triggers lsp-core.lua
2. mason.nvim checks if server installed
3. If missing: mason-tool-installer auto-installs
4. nvim-lspconfig sets up server
5. LspAttach autocmd runs (keybindings, formatting, signatures)
6. Server starts, attaches to buffer
7. nvim-cmp connects to LSP via cmp-nvim-lsp
8. Copilot starts in parallel (async)
```

**Why async?**
- User can start typing immediately
- LSP loads in background
- No blocking on network (Mason downloads)

---

## Plugin Dependency Graph

### Core Dependencies (used by many plugins)

```
plenary.nvim (22 dependents)
├── telescope.nvim
├── gitsigns.nvim
├── neogit
├── refactoring.nvim
├── nvim-spectre
├── todo-comments.nvim
└── ... (16 more)

nvim-web-devicons (15 dependents)
├── lualine.nvim
├── nvim-cokeline
├── nvim-tree.lua
├── telescope.nvim
└── ... (11 more)

nui.nvim (3 dependents)
├── noice.nvim
├── (neo-tree alternatives)
└── (telescope extensions)
```

### LSP Layer

```
mason.nvim (root)
├── mason-lspconfig.nvim
│   └── nvim-lspconfig
│       ├── ts_ls, lua_ls, pyright, gopls, clangd, rust_analyzer
│       ├── html, cssls, jsonls, yamlls, tailwindcss
│       └── bashls, dockerls
│
└── mason-tool-installer.nvim
    ├── Formatters: prettier, biome, stylua, black, gofmt, rustfmt, clang-format, shfmt
    └── Linters: eslint, ruff, shellcheck, yamllint

lazydev.nvim (Lua development)
└── luvit-meta (type definitions)

nvim-lsp-file-operations (file ops → LSP)
```

### Completion Layer

```
nvim-cmp (engine)
├── Sources:
│   ├── cmp-nvim-lsp ← nvim-lspconfig
│   ├── copilot-cmp ← copilot.lua
│   ├── cmp_luasnip ← LuaSnip ← friendly-snippets
│   ├── cmp-buffer (buffer text)
│   └── cmp-path (file paths)
│
├── UI:
│   ├── lspkind.nvim (pictograms)
│   └── lsp_signature.nvim (function signatures)
│
└── Parallel:
    └── copilot.lua (standalone AI suggestions)
```

### Treesitter Layer

```
nvim-treesitter (root)
├── Used by:
│   ├── nvim-ufo (folding)
│   ├── nvim-ts-context-commentstring → Comment.nvim
│   ├── aerial.nvim (code outline)
│   ├── refactoring.nvim
│   └── flash.nvim (Treesitter search)
│
└── Extensions:
    ├── nvim-ts-autotag (HTML/JSX tag close)
    └── nvim-ts-context-commentstring (comment awareness)
```

### Git Layer

```
gitsigns.nvim (standalone) ← plenary.nvim
neogit ← plenary.nvim, diffview.nvim
diffview.nvim ← plenary.nvim
git-conflict.nvim (standalone)
```

### UI Layer

```
noice.nvim (root)
├── nui.nvim (UI components)
└── nvim-notify (notifications)

lualine.nvim
├── nvim-web-devicons
└── nvim-navic (breadcrumbs)

nvim-cokeline
└── nvim-web-devicons

dressing.nvim
└── telescope.nvim (for select UI)
```

---

## Plugin Communication Patterns

### 1. LSP ↔ Telescope Integration

```
LSP provides:
- vim.lsp.buf.definition()
- vim.lsp.buf.references()
- vim.lsp.buf.document_symbol()

Telescope wraps:
- :Telescope lsp_definitions
- :Telescope lsp_references
- :Telescope lsp_document_symbols

Keybindings in lsp-core.lua:
- gd → telescope.lsp_definitions
- gr → telescope.lsp_references
- <leader>cs → telescope.lsp_document_symbols
```

**Why?** Telescope UI is better than default LSP pickers.

### 2. Treesitter ↔ nvim-ufo Folding

```
nvim-treesitter:
- Parses code into AST
- Provides syntax tree

nvim-ufo:
- Uses Treesitter AST for fold detection
- Falls back to LSP foldingRange
- Falls back to indent-based folding

Result:
- Accurate code folding (function, class, block)
- Faster than regex-based folding
```

### 3. conform.nvim ↔ LSP Formatting

```
Priority order in formatting.lua:
1. Check for project formatter (prettier, biome)
2. If found: use conform.nvim (respects config)
3. If not: use LSP formatting (vim.lsp.buf.format())

Auto-format on save:
- BufWritePre autocmd
- Runs conform.nvim formatters
- LSP as fallback
```

**Why?** Project configs (`.prettierrc`) take precedence.

### 4. Comment.nvim ↔ nvim-ts-context-commentstring

```
Comment.nvim:
- Provides `gcc` keybinding
- Asks: "What comment syntax?"

nvim-ts-context-commentstring:
- Inspects Treesitter node at cursor
- Returns correct comment style:
  - `//` in JavaScript
  - `{/* */}` in JSX
  - `<!-- -->` in HTML inside JSX

Result:
- Context-aware commenting in mixed files
```

### 5. Copilot Dual Integration

```
Copilot has 2 modes:

1. Inline suggestions (copilot.lua):
   - Shows ghosted text
   - <C-g> to accept
   - Runs in parallel to nvim-cmp

2. Completion menu (copilot-cmp):
   - Appears in nvim-cmp menu
   - Mixed with LSP suggestions
   - <Tab> to select

Both can run simultaneously!
```

---

## Configuration Layers

### Layer 1: Core Settings (lua/config/)

**Purpose:** Neovim behavior independent of plugins

- **options.lua:** `vim.opt.*` settings (line numbers, tabs, clipboard)
- **keymaps.lua:** Non-plugin keybindings (window splits, clipboard)
- **autocmds.lua:** Auto commands (highlight on yank, resize splits)
- **compatibility.lua:** Version checks, API shims
- **health.lua:** Health check framework

### Layer 2: LSP Infrastructure (lsp-*.lua, formatting.lua)

**Purpose:** Language server and tooling setup

- **lsp-core.lua:** Generic LSP setup (on_attach, capabilities, keybindings)
- **lsp-servers.lua:** Per-server configurations (ts_ls, pyright, etc.)
- **autocompletion.lua:** Completion engine (cmp, Copilot, sources)
- **formatting.lua:** Formatters, linters, project detection

**Pattern:** Language-agnostic in -core, language-specific in -servers

### Layer 3: UI/UX Enhancements (ui-*.lua)

**Purpose:** Visual improvements

- **ui-statusline.lua:** Lualine (bottom status bar)
- **ui-bufferline.lua:** Cokeline (top buffer tabs)
- **ui-notifications.lua:** Noice, notify, dressing (popups)
- **ui-indicators.lua:** Indent guides, symbol highlighting, colors

**Pattern:** Each UI component isolated in its own file

### Layer 4: Editing & Navigation (enhanced-*.lua, modern-*.lua)

**Purpose:** Code manipulation and movement

- **enhanced-editing.lua:** Surround, pairs, comments, folding
- **enhanced-diagnostics.lua:** Trouble.nvim (better diagnostics)
- **modern-enhancements.lua:** Flash, aerial, refactoring, spectre
- **telescope.lua, nvim-tree.lua:** Search and file navigation

### Layer 5: Language-Specific (python.lua, git-*.lua)

**Purpose:** Language or domain-specific tools

- **python.lua:** Virtual environment switching
- **git-enhancements.lua:** Git hunks, staging, blame, diff

### Layer 6: Utilities (utilities.lua, productivity.lua, dev-tools.lua)

**Purpose:** Miscellaneous tools

- **utilities.lua:** Which-key, quickfix, buffer manager, smooth scroll
- **productivity.lua:** Projects, markdown preview, sessions
- **dev-tools.lua:** TODO comments, terminal (snacks)

---

## Startup Sequence

```
Time  | Event
------|----------------------------------------------
  0ms | Neovim starts
  2ms | init.lua loads
  5ms | compatibility.lua checks version
 10ms | lazy.lua bootstraps plugin manager
 15ms | lazy.nvim discovers 69 plugins
 20ms | options.lua sets vim options
 25ms | keymaps.lua sets general keybindings
 30ms | autocmds.lua registers auto commands
 35ms | lazy.nvim loads "start" plugins (0 in this config)
 40ms | UI renders (dashboard from snacks.nvim)
      | User sees Neovim!
------|----------------------------------------------
200ms | VeryLazy event triggers
      | ├── which-key.nvim loads
      | ├── persistence.nvim loads
      | └── mini.* plugins load
------|----------------------------------------------
      | User opens file.txt
      | ├── BufReadPre triggers:
      | │   ├── nvim-tree.lua
      | │   ├── nvim-treesitter (parses syntax)
      | │   ├── gitsigns.nvim (git status)
      | │   └── lsp-core.lua (starts LSP)
      | └── BufReadPost triggers:
      |     └── nvim-ufo (folding)
------|----------------------------------------------
      | User types 'i' (insert mode)
      | └── InsertEnter triggers:
      |     ├── nvim-cmp (completion engine)
      |     ├── copilot.lua (AI suggestions)
      |     └── LuaSnip (snippets)
------|----------------------------------------------
      | LSP server finishes starting
      | └── LspAttach autocmd runs:
      |     ├── LSP keybindings (gd, K, <leader>ca)
      |     ├── lsp_signature.nvim (function signatures)
      |     └── Format on save setup
------|----------------------------------------------
 ~1s  | Full environment ready
```

**Key Insight:** User can start editing at 40ms, full features at ~1s.

---

## Performance Optimizations

### 1. Disabled Builtins (options.lua)

```lua
vim.g.loaded_gzip = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_netrw = 1           -- Using nvim-tree instead
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_matchit = 1         -- Using Treesitter instead
vim.g.loaded_matchparen = 1      -- Using vim-illuminate instead
```

**Savings:** ~20ms startup time

### 2. Lazy Loading Strategies

| Strategy | Example | Benefit |
|----------|---------|---------|
| Event-based | `event = "VeryLazy"` | Loads after UI render |
| Command-based | `cmd = "Mason"` | Loads only when invoked |
| Filetype | `ft = "python"` | Loads only for Python files |
| Keybinding | `keys = { "s", "S" }` | Loads on first keypress |
| Dependency | `dependencies = { ... }` | Loads with parent |

**Savings:** ~400ms startup time (vs loading all 69 plugins)

### 3. Compiled Plugins

- **telescope-fzf-native.nvim:** C-compiled fuzzy matcher (10x faster)
- **Treesitter parsers:** Pre-compiled grammar parsers
- **lazy.nvim cache:** Cached plugin metadata

### 4. Async Operations

- **Mason downloads:** Non-blocking LSP server installation
- **Copilot:** Async AI suggestions
- **Treesitter:** Async incremental parsing
- **Gitsigns:** Async git status checks

### 5. Caching

- **Treesitter query cache:** Reuse parsed queries
- **LSP workspace cache:** Persist workspace symbols
- **lazy.nvim module cache:** Faster `require()`

---

## Configuration Philosophy

1. **Modularity:** Each plugin in its own file or logical group
2. **Lazy by Default:** Every plugin has a loading trigger
3. **Performance First:** Startup time < 100ms target
4. **LSP-Centric:** LSP as foundation, plugins enhance it
5. **AI-Assisted:** Copilot integrated at completion layer
6. **Git-Aware:** Git status in UI, inline hunks
7. **Polyglot:** Support 15+ languages with consistent UX
8. **Keyboard-First:** Every action has a keybinding
9. **Discoverable:** which-key for keybinding help

---

## Extension Patterns

### Adding a New Language

1. **Add LSP server** in `lsp-servers.lua`:
```lua
ensure_installed = { ..., "new_language_ls" }
```

2. **Add Treesitter parser** in `treesitter.lua`:
```lua
ensure_installed = { ..., "new_language" }
```

3. **Add formatter** in `formatting.lua`:
```lua
formatters_by_ft = {
  new_language = { "formatter_name" }
}
```

4. **Restart Neovim** → Mason auto-installs everything

### Adding a New Plugin

1. **Create file** in `lua/plugins/` or add to existing file
2. **Define lazy spec**:
```lua
return {
  "author/plugin-name",
  event = "VeryLazy",  -- or cmd, ft, keys
  config = function()
    require("plugin-name").setup({})
  end,
}
```

3. **Restart Neovim** → lazy.nvim auto-installs

---

**See also:**
- `PLUGINS_REFERENCE.md` - Complete plugin listing
- `LSP_GUIDE.md` - Language-specific setup
- `PERFORMANCE.md` - Optimization techniques
- `CLAUDE.md` - Architecture decisions explained
