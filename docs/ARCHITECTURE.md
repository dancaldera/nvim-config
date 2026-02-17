# Configuration Architecture

Deep dive into the consolidated Neovim configuration structure, loading strategy, and plugin communication patterns.

---

## Table of Contents

1. [Directory Structure](#directory-structure)
2. [Loading Strategy](#loading-strategy)
3. [Configuration Layers](#configuration-layers)
4. [Plugin Dependency Graph](#plugin-dependency-graph)
5. [Plugin Communication Patterns](#plugin-communication-patterns)
6. [Startup Sequence](#startup-sequence)
7. [Performance Optimizations](#performance-optimizations)
8. [Extension Patterns](#extension-patterns)

---

## Directory Structure

```
~/.config/nvim/
├── init.lua                          # Entry point (49 lines)
├── lazy-lock.json                    # Plugin version lock file
├── AGENTS.md                         # AI assistant instructions
├── README.md                         # User guide
│
├── lua/
│   ├── config/                       # Core configuration (8 files)
│   │   ├── lazy.lua                  # Plugin manager bootstrap
│   │   ├── options.lua               # Neovim settings (vim.opt)
│   │   ├── keymaps.lua               # General keybindings (non-plugin)
│   │   ├── autocmds.lua              # Auto commands
│   │   ├── compatibility.lua         # Version checks (0.10+ required, 0.11+ recommended)
│   │   ├── health.lua                # Health check framework
│   │   ├── openai.lua                # OpenAI GPT-4o API integration (AI commit messages)
│   │   └── github.lua                # Multi-account GitHub CLI management
│   │
│   └── plugins/                      # Plugin configurations (13 files, ~43 plugins)
│       ├── lsp.lua                   # Mason + lspconfig + mason-lspconfig + lazydev (8 plugins)
│       ├── completion.lua            # nvim-cmp + Copilot inline + LuaSnip (9 plugins)
│       ├── editor.lua                # autopairs, surround, Comment, which-key, refactoring, mini.ai (7 plugins)
│       ├── ui.lua                    # lualine, navic, bufferline, mini.bufremove, mini.indentscope, vim-illuminate, nvim-ufo (9 plugins)
│       ├── git.lua                   # gitsigns + fugitive + AI commit workflow (2 plugins)
│       ├── dev-tools.lua             # snacks (dashboard/terminal/notifier), todo-comments, project.nvim, markdown-preview (5 plugins)
│       ├── diagnostics.lua           # trouble.nvim (1 plugin)
│       ├── treesitter.lua            # nvim-treesitter + autotag (2 plugins)
│       ├── telescope.lua             # Telescope + fzf-native (2 plugins)
│       ├── nvim-tree.lua             # File explorer (1 plugin)
│       ├── formatting.lua            # conform.nvim + nvim-lint (2 plugins)
│       └── python.lua                # swenv.nvim (1 plugin)
│
└── docs/                             # Documentation (UPPERCASE filenames)
    ├── KEYBINDINGS.md
    ├── SETUP_FORMATTERS.md
    ├── PLUGINS_REFERENCE.md
    ├── ARCHITECTURE.md               # This file
    ├── LSP_GUIDE.md
    ├── TROUBLESHOOTING.md
    └── PERFORMANCE.md
```

**Design Principles:**

- **13 plugin files** (consolidated from a previous 21-file layout)
- **~43 plugins** (reduced from ~65 by removing redundancies)
- **Separation of concerns:** `config/` handles Neovim-native behavior; `plugins/` handles plugin-specific specs
- **Logical grouping:** Related plugins live in the same file (e.g., all UI indicators in `ui.lua`)
- **No file exceeds ~300 lines** for maintainability
- **Naming is direct:** `lsp.lua`, `git.lua`, `editor.lua` -- not `lsp-core.lua` + `lsp-servers.lua`

---

## Loading Strategy

### 1. Bootstrap Phase (init.lua)

```lua
-- init.lua execution order:
1. Set leader key (space)
2. Disable unused providers (python3)
3. require("config.compatibility")   -- Version checks + API shims
4. require("config.options")         -- Core vim.opt settings
5. require("config.keymaps")         -- Non-plugin keybindings
6. require("config.autocmds")        -- Auto commands
7. require("config.lazy")            -- Bootstrap lazy.nvim, discover plugins
8. require("config.health")          -- Health check commands (manual only)
9. Source .nvim.lua                   -- Project-local config (if exists)
```

**Why this order?**
- Compatibility first: fail fast on Neovim < 0.10
- Options/keymaps before lazy.nvim: core settings available before plugins load
- Lazy.nvim auto-discovers all `lua/plugins/*.lua` files via `{ import = "plugins" }`
- Health checks are manual-only (no auto-check on startup)

### 2. Lazy Loading Events

~43 plugins use various loading triggers:

| Event | When Triggered | Example Plugins |
|-------|----------------|-----------------|
| `lazy = false` | Immediately on startup | snacks.nvim, treesitter |
| `priority = 1000` | High-priority startup | snacks.nvim |
| `VeryLazy` | After UI renders | which-key, nvim-surround, mini.ai, refactoring, project.nvim |
| `BufReadPre` | Before opening any file | gitsigns, conform, nvim-lint, mini.indentscope |
| `BufReadPost` | After file loaded | nvim-ufo (folding), vim-illuminate, todo-comments |
| `BufAdd` | When a buffer is added | bufferline |
| `InsertEnter` | Entering insert mode | nvim-cmp, copilot.lua, nvim-autopairs |
| `LspAttach` | LSP server attaches | nvim-navic |
| `ft = {...}` | File type detection | python.lua (ft=python), markdown-preview (ft=markdown) |
| `cmd = "..."` | Command invocation | Mason (`:Mason`), Trouble (`:Trouble`), Fugitive (`:Git`) |
| `keys = {...}` | First keypress | refactoring (`<leader>re`), mini.bufremove (`<leader>bd`) |

### 3. LSP Loading Sequence

LSP is the most complex loading chain:

```
1. Neovim 0.11+ check in mason-lspconfig config
2. mason.nvim sets up server/tool manager
3. mason-tool-installer ensures formatters/linters are installed
4. mason-lspconfig ensures LSP servers are installed
5. vim.lsp.config() registers server configurations (0.11+ native API)
   - Simple servers: loop sets capabilities only
   - Complex servers (lua_ls, ts_ls, pyright): custom settings
6. BufReadPre triggers LSP server start
7. LspAttach autocmd runs:
   - LSP keybindings (gd, K, <leader>ca, etc.)
   - Inlay hints enabled (if supported)
   - Inlay hint cycling (<leader>ti)
8. cmp-nvim-lsp provides enhanced capabilities to servers
9. Copilot starts in parallel (async, InsertEnter)
```

---

## Configuration Layers

### Layer 1: Core Settings (`lua/config/`)

Neovim behavior independent of any plugins.

| File | Purpose |
|------|---------|
| `options.lua` | `vim.opt.*` settings: line numbers, tabs, clipboard, scrolling, folding |
| `keymaps.lua` | Non-plugin keybindings: window splits, clipboard operations, navigation |
| `autocmds.lua` | Auto commands: highlight on yank, resize splits |
| `compatibility.lua` | Version checks (0.10+ required, 0.11+ recommended), API shims for deprecated functions |
| `health.lua` | `:checkhealth` framework for validating setup |
| `openai.lua` | OpenAI GPT-4o API client: commit message generation, API key management |
| `github.lua` | Multi-account GitHub CLI: account parsing, switching, caching (60s TTL) |

### Layer 2: LSP Infrastructure (`lsp.lua`, `formatting.lua`)

Language intelligence and code formatting.

- **`lsp.lua`:** Mason (package manager) + nvim-lspconfig (server configs) + mason-lspconfig (bridge) + lazydev (Lua development)
  - Simple servers configured via loop: `html`, `cssls`, `jsonls`, `yamlls`, `gopls`, `clangd`, `rust_analyzer`, `tailwindcss`, `bashls`, `emmet_ls`
  - Custom configs: `lua_ls` (globals), `ts_ls` (inlay hints), `pyright` (venv detection)
  - LSP keybindings set in `LspAttach` autocmd
- **`formatting.lua`:** conform.nvim (formatting) + nvim-lint (linting)
  - Project-aware formatter selection: detects biome/deno/prettier/ruff/black configs
  - Dynamic linter selection: biome vs eslint_d based on project
  - Format-on-save disabled by default, manual via `<leader>cf`

### Layer 3: Completion (`completion.lua`)

Two independent completion systems running in parallel.

- **Copilot** (inline ghost text only): auto-trigger, `<C-g>` to accept, `<C-;>` for next suggestion
  - No cmp integration -- Copilot operates as standalone ghost text
  - `ghost_text = false` in cmp to avoid visual conflict
- **nvim-cmp** (menu completion): LSP, snippets, buffer, path sources
  - Priority: LSP (900) > LuaSnip (750) > buffer (500) > path (250)
  - lspkind.nvim for pictograms in the completion menu
  - Autopairs integration: auto-close on confirm

### Layer 4: Syntax (`treesitter.lua`)

Treesitter parsers and extensions.

- 25+ language parsers (JS/TS/Python/Go/Rust/Lua/C/C++ and more)
- Extensions: nvim-ts-autotag (HTML/JSX auto-close)
- Incremental selection: `<C-space>` to expand, `<BS>` to shrink
- Used by: nvim-ufo (folding), Comment.nvim (context-aware comments), refactoring.nvim, mini.ai (text objects)

### Layer 5: UI (`ui.lua`)

Visual presentation layer.

- **lualine:** Global statusline with auto theme, navic breadcrumbs, GitHub account display, Python venv indicator
- **bufferline:** Tab-style buffer line with LSP diagnostics, slant separators, nvim-tree offset
- **mini.bufremove:** Safe buffer closing with unsaved changes prompt
- **mini.indentscope:** Animated scope indicator (`|`)
- **vim-illuminate:** Highlight word under cursor, `]]`/`[[` to navigate references
- **nvim-ufo:** Code folding via Treesitter (fallback: indent)

### Layer 6: Navigation (`telescope.lua`, `nvim-tree.lua`)

File and code search.

- **Telescope:** Fuzzy finder with fzf-native (C-compiled for speed), ripgrep integration, hidden files enabled
- **nvim-tree:** File explorer with git status, auto-focus current file, custom keybindings

### Layer 7: Editing (`editor.lua`)

Text manipulation and code intelligence.

- **nvim-autopairs:** Treesitter-aware bracket/quote completion with fast-wrap (`<M-e>`)
- **nvim-surround:** Add/change/delete surrounding pairs
- **Comment.nvim:** Context-aware commenting via ts-context-commentstring
- **which-key:** Keybinding discovery with group labels
- **refactoring.nvim:** Extract function/variable, inline variable, Telescope refactor menu
- **mini.ai:** Enhanced text objects (function `af`/`if`, class `ac`/`ic`, block `ao`/`io`, HTML tag `at`/`it`)

### Layer 8: Git (`git.lua`)

Git integration with AI-powered workflow.

- **gitsigns:** Inline hunks, staging, blame, diff, deleted line toggle
- **vim-fugitive:** Git commands via `:Git`
- **AI commit workflow** (uses `config/openai.lua`):
  - `<leader>gc` -- Commit current/staged with AI-generated message
  - `<leader>gC` -- Stage all + commit with AI message
  - `<leader>gA` -- Stage all + commit + push (one-shot)
  - `<leader>gP` -- Push to remote
  - All commits show editable prompt; fallback: `[timestamp] Auto-commit`

### Layer 9: Dev Tools (`dev-tools.lua`)

Terminal, dashboard, notifications, and project management.

- **snacks.nvim** (unified system):
  - **Notifier:** Sole notification backend (`vim.notify` override), replaces noice/nvim-notify/dressing/fidget
  - **Dashboard:** ASCII art header with quick-access keys (find files, recent, grep, lazy)
  - **Terminal:** Float/horizontal/vertical terminals, CLI tool management (Claude, Gemini, Codex, Copilot CLI, Opencode)
  - **Lazygit:** `<leader>lg` to open
- **todo-comments:** Highlight and search TODO/FIXME/HACK/NOTE comments
- **project.nvim:** Auto-detect project root, Telescope project picker (`<leader>fp`)
- **markdown-preview:** Live browser preview for markdown files
- **GitHub accounts:** `<leader>ga` (switch), `<leader>gS` (quick status)

### Layer 10: Diagnostics (`diagnostics.lua`)

- **trouble.nvim:** Enhanced diagnostics list with preview split
  - Workspace/buffer diagnostics, symbols, LSP definitions/references
  - Copy all diagnostics to clipboard (`<leader>xc`)
  - Severity-filtered navigation (`]e`/`[e` for errors, `]w`/`[w` for warnings)
  - Severity-filtered views (`<leader>de` errors only, `<leader>dw` warnings only)

### Layer 11: Language-Specific (`python.lua`)

- **swenv.nvim:** Python virtual environment switching
  - Auto-detects: local venvs, Poetry, UV, Pipenv
  - Auto-selects project venv on Python file open
  - `<leader>pv` to manually pick venv
  - Restarts LSP on venv change

---

## Plugin Dependency Graph

### Core Dependencies

```
plenary.nvim (shared by multiple plugins)
├── telescope.nvim
├── gitsigns.nvim
├── refactoring.nvim
├── todo-comments.nvim
├── project.nvim
└── swenv.nvim

nvim-web-devicons (shared by UI plugins)
├── lualine.nvim
├── bufferline.nvim
├── nvim-tree.lua
├── telescope.nvim
└── trouble.nvim
```

### LSP Layer

```
mason.nvim
├── mason-tool-installer.nvim
│   └── Ensures: prettier, stylua, eslint_d, shfmt, ruff, isort, black, golangci-lint
│
└── mason-lspconfig.nvim
    └── nvim-lspconfig
        ├── Simple servers (via loop): html, cssls, jsonls, yamlls, gopls,
        │   clangd, rust_analyzer, tailwindcss, bashls, emmet_ls
        └── Custom configs: lua_ls, ts_ls, pyright

lazydev.nvim (Lua development, ft=lua)
└── luvit-meta (type definitions for vim.uv)

nvim-lsp-file-operations (file rename → LSP)

cmp-nvim-lsp (enhanced capabilities → all servers)
```

### Completion Layer

```
nvim-cmp (menu completion engine)
├── Sources:
│   ├── cmp-nvim-lsp ← nvim-lspconfig
│   ├── cmp_luasnip ← LuaSnip ← friendly-snippets
│   ├── cmp-buffer (buffer text)
│   └── cmp-path (file paths)
├── UI:
│   └── lspkind.nvim (pictograms)
└── Integration:
    └── nvim-autopairs (auto-close on confirm)

copilot.lua (standalone inline ghost text)
└── Runs in parallel to nvim-cmp
└── No cmp source — ghost text only
```

### Treesitter Layer

```
nvim-treesitter
├── Used by:
│   ├── nvim-ufo (fold providers: treesitter → indent)
│   ├── nvim-ts-context-commentstring → Comment.nvim
│   ├── nvim-autopairs (Treesitter-aware bracket matching)
│   ├── refactoring.nvim (AST-based refactoring)
│   └── mini.ai (Treesitter text objects)
│
└── Extensions:
    └── nvim-ts-autotag (HTML/JSX tag auto-close/rename)
```

### Notification System

```
snacks.nvim (sole notification backend)
└── vim.notify = snacks.notifier.notify
└── No other notification plugins needed
```

---

## Plugin Communication Patterns

### 1. LSP <-> Telescope Integration

```
LSP provides:                    Telescope wraps:
- textDocument/definition    →   :Telescope lsp_definitions      (gd)
- textDocument/references    →   :Telescope lsp_references       (gR)
- textDocument/implementation →  :Telescope lsp_implementations  (gi)
- textDocument/typeDefinition →  :Telescope lsp_type_definitions (gy)
```

Keybindings are set in the `LspAttach` autocmd in `lsp.lua`. Telescope provides a richer UI than the default LSP pickers.

### 2. Treesitter <-> nvim-ufo Folding

```
nvim-treesitter parses code → AST
nvim-ufo uses provider_selector:
  1. Try "treesitter" provider (AST-based folds)
  2. Fallback to "indent" provider
```

Fold settings in `options.lua`: `foldlevel=99`, `foldlevelstart=99`, `foldenable=true` -- all folds open by default. `zR`/`zM` mapped to ufo's open/close all.

### 3. conform.nvim <-> LSP Formatting

```
formatting.lua priority logic:

For JS/TS files:
  1. Check for biome.json → use biome
  2. Check for deno.json → use deno_fmt
  3. Fallback → use prettier

For Python files:
  1. Check for ruff config → use ruff_format
  2. Check for [tool.black] in pyproject.toml → use isort + black
  3. No config → skip (no formatter)

Manual format (<leader>cf):
  conform.format({ lsp_format = "fallback" })
  → Tries conform formatters first, falls back to LSP
```

### 4. Comment.nvim <-> ts-context-commentstring

```
Comment.nvim registers a pre_hook:
  → Calls ts_context_commentstring to inspect Treesitter node at cursor
  → Returns correct comment style for mixed-language files:
    - // in JavaScript
    - {/* */} in JSX
    - <!-- --> in HTML within JSX
    - -- in Lua
```

### 5. Copilot Inline Mode (No cmp Integration)

```
copilot.lua:
  - suggestion.enabled = true (ghost text)
  - auto_trigger = true
  - <C-g> to accept, <C-;> for next, <C-x> to dismiss

nvim-cmp:
  - ghost_text = false (prevents visual conflict)
  - No copilot-cmp source

Result: Two independent systems
  - Tab/Enter → nvim-cmp menu items
  - <C-g> → Copilot ghost text
```

### 6. Snacks.nvim as Unified Backend

```
snacks.nvim provides:
  1. Notification: vim.notify override → snacks.notifier
  2. Terminal: floating/split terminals with persistent CLI tool tracking
  3. Dashboard: startup screen with quick actions
  4. Lazygit: integrated git UI

All other plugins that call vim.notify() route through snacks automatically.
Terminal exit code errors are suppressed via notifier wrapper.
Non-persistent terminals auto-close via TermClose autocmd.
```

### 7. Lualine <-> Config Modules

```
lualine sections use:
  - config.github → Display " @username" in statusline (git repos only)
  - swenv.api → Display Python venv name (Python files only)
  - lazy.status → Display plugin update count
  - nvim-navic → Display code breadcrumbs (LSP-attached buffers)
```

---

## Startup Sequence

```
Time  | Event
------|----------------------------------------------
  0ms | Neovim starts
  2ms | init.lua loads, sets leader key
  5ms | compatibility.lua: version check, API shims
  8ms | options.lua: vim.opt settings
 10ms | keymaps.lua: general keybindings
 12ms | autocmds.lua: auto commands
 15ms | lazy.lua: bootstrap lazy.nvim, discover 13 plugin files
      |
  20ms | Immediate plugins load (lazy = false, priority = 1000):
       |   ├── snacks.nvim (dashboard, notifier, terminal)
       |   └── nvim-treesitter (parser loading)
      |
 30ms | health.lua: register health check commands
      | .nvim.lua: project-local config (if exists)
      |
 ~40ms| UI renders — dashboard visible
      | User sees Neovim!
------|----------------------------------------------
200ms | VeryLazy event triggers:
      |   ├── which-key.nvim
      |   ├── nvim-surround
      |   ├── refactoring.nvim
      |   ├── mini.ai
      |   └── project.nvim
------|----------------------------------------------
      | User opens a file:
      |   ├── BufReadPre triggers:
      |   │   ├── gitsigns.nvim (git status)
      |   │   ├── conform.nvim (formatter setup)
      |   │   ├── nvim-lint (linter setup)
      |   │   └── mini.indentscope
      |   ├── BufReadPost triggers:
      |   │   ├── nvim-ufo (folding)
      |   │   ├── vim-illuminate (word highlighting)
      |   │   └── todo-comments
      |   └── BufAdd triggers:
      |       └── bufferline.nvim
------|----------------------------------------------
      | LSP server starts, attaches:
      |   └── LspAttach triggers:
      |       ├── LSP keybindings (gd, K, <leader>ca)
      |       ├── Inlay hints enabled
      |       └── nvim-navic (breadcrumbs)
------|----------------------------------------------
      | User types 'i' (insert mode):
      |   └── InsertEnter triggers:
      |       ├── nvim-cmp (completion engine)
      |       ├── copilot.lua (AI ghost text)
      |       └── nvim-autopairs
------|----------------------------------------------
 ~1s  | Full environment ready
```

**Key insight:** User can start editing at ~40ms. Full LSP + completion at ~1s.

---

## Performance Optimizations

### 1. Disabled Builtins (lazy.lua)

```lua
-- In lazy.nvim performance.rtp.disabled_plugins:
"gzip", "matchit", "netrwPlugin", "tarPlugin", "tohtml",
"tutor", "zipPlugin", "rplugin", "builtins", "compiler",
"optwin", "spellfile", "shada_plugin"
```

Also in `nvim-tree.lua`: `vim.g.loaded_netrw = 1`, `vim.g.loaded_netrwPlugin = 1`

### 2. Plugin Reduction

| Before | After | Savings |
|--------|-------|---------|
| ~65 plugins | ~43 plugins | 22 plugins removed |
| 21 plugin files | 13 plugin files | 8 fewer files |
| 4 notification plugins | 1 (snacks.nvim) | 3 removed |
| copilot + copilot-cmp | copilot inline only | 1 removed |

### 3. Lazy Loading Strategies

| Strategy | Example | Benefit |
|----------|---------|---------|
| `lazy = false` + `priority = 1000` | snacks | Loads first, no delay |
| Event-based | `event = "VeryLazy"` | Loads after UI render |
| Command-based | `cmd = "Mason"` | Loads only when invoked |
| Filetype | `ft = "python"` | Loads only for Python files |
| Keybinding | `keys = { "<leader>re" }` | Loads on first keypress |
| Dependency | `dependencies = { ... }` | Loads with parent |

### 4. Compiled/Native Components

- **telescope-fzf-native.nvim:** C-compiled fuzzy matcher (10x faster than Lua)
- **Treesitter parsers:** Pre-compiled grammar parsers
- **lazy.nvim cache:** Cached plugin metadata and module resolution

### 5. Async Operations

- **Mason:** Non-blocking LSP server installation
- **Copilot:** Async AI suggestions
- **Treesitter:** Async incremental parsing
- **Gitsigns:** Async git status checks
- **nvim-lint:** Triggered on events, non-blocking

### 6. Caching

- **lazy.nvim module cache:** Faster `require()` resolution
- **Treesitter query cache:** Reuse parsed queries
- **GitHub account cache:** 60s TTL to minimize CLI calls
- **OpenAI API key cache:** Loaded once per session
- **Python venv cache:** Per-cwd detection, reset on `DirChanged`

---

## Extension Patterns

### Adding a New Language

1. **Add LSP server** in `lsp.lua`:
```lua
-- For simple servers (capabilities only), add to the loop:
local simple_servers = {
  "html", "cssls", ..., "new_language_ls",
}

-- For servers needing custom settings, add a vim.lsp.config() block:
vim.lsp.config("new_language_ls", {
  capabilities = capabilities,
  settings = { ... },
})

-- Add to mason-lspconfig ensure_installed:
ensure_installed = { ..., "new_language_ls" }
```

2. **Add Treesitter parser** in `treesitter.lua`:
```lua
ensure_installed = { ..., "new_language" }
```

3. **Add formatter** in `formatting.lua`:
```lua
formatters_by_ft = {
  new_language = { "formatter_name" },
}
```

4. **Add tools to Mason** in `lsp.lua`:
```lua
-- In mason-tool-installer ensure_installed:
ensure_installed = { ..., "new_formatter", "new_linter" }
```

5. **Restart Neovim** -- Mason auto-installs everything.

### Adding a New Plugin

Add the lazy.nvim spec to the most appropriate existing file in `lua/plugins/`:

```lua
-- In the relevant plugins/*.lua file, add to the returned table:
{
  "author/plugin-name",
  event = "VeryLazy",  -- or cmd, ft, keys, etc.
  dependencies = { ... },
  opts = { ... },
  -- or config = function() ... end
}
```

**File selection guide:**

| Plugin Category | Add to |
|----------------|--------|
| LSP-related | `lsp.lua` |
| Completion source | `completion.lua` |
| Text editing | `editor.lua` |
| Visual/UI | `ui.lua` |
| Git-related | `git.lua` |
| Terminal/project tools | `dev-tools.lua` |
| Diagnostic views | `diagnostics.lua` |
| Syntax/parsing | `treesitter.lua` |
| Search/navigation | `telescope.lua` or `nvim-tree.lua` |
| Formatting/linting | `formatting.lua` |
| Language-specific | `python.lua` or new `<language>.lua` |

### Adding AI Commit Support

The AI commit workflow in `git.lua` uses `config/openai.lua`. To modify:

1. **Change model:** Edit `model` field in `openai.lua` JSON body
2. **Change prompt:** Edit the prompt string in `generate_commit_message()`
3. **Add new commit shortcuts:** Add key specs to the fugitive plugin entry in `git.lua`

### Adding a GitHub Integration

The `config/github.lua` module provides:
- `M.get_current_account()` -- returns active username (cached)
- `M.get_all_accounts()` -- returns list of usernames
- `M.switch_account()` -- interactive account switcher
- `M.quick_status()` -- floating window with account info

Used by lualine (statusline display) and dev-tools (keybindings).

---

## Configuration Philosophy

1. **Consolidated:** Fewer files, fewer plugins, less to maintain
2. **Lazy by default:** Every plugin has a loading trigger
3. **Performance first:** Startup target < 100ms, ~43 plugins total
4. **LSP-centric:** LSP as foundation, plugins enhance it
5. **AI-assisted:** Copilot for code, GPT-4o for commits
6. **Snacks-unified:** One plugin for notifications, terminals, and dashboard
7. **Project-aware:** Formatter/linter selection adapts to project config files
8. **Keyboard-first:** Every action has a keybinding, which-key for discovery
9. **Simple servers:** Loop-based LSP config instead of per-server boilerplate

---

**See also:**
- `PLUGINS_REFERENCE.md` -- Complete plugin listing with descriptions
- `KEYBINDINGS.md` -- Full keybinding reference
- `LSP_GUIDE.md` -- Language-specific LSP setup and troubleshooting
- `PERFORMANCE.md` -- Startup profiling and optimization techniques
- `TROUBLESHOOTING.md` -- Common issues and fixes
