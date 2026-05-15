# Performance Optimization

Comprehensive guide to Neovim startup optimization, profiling techniques, and performance best practices.

---

## Table of Contents

1. [Current Performance](#current-performance)
2. [Measurement Tools](#measurement-tools)
3. [Optimization Techniques](#optimization-techniques)
4. [Lazy Loading Strategies](#lazy-loading-strategies)
5. [Plugin-Specific Optimizations](#plugin-specific-optimizations)
6. [Runtime Performance](#runtime-performance)
7. [Profiling Guide](#profiling-guide)
8. [Benchmarking](#benchmarking)
9. [Performance Regression Detection](#performance-regression-detection)

---

## Current Performance

### Target Metrics

The repository currently documents targets, not enforced benchmark results. Re-measure locally before treating any number as current.

| Metric | Target |
|--------|--------|
| Startup Time | <100ms |
| Memory (Idle) | <200MB |
| Memory (LSP Active) | <300MB |
| LSP Attach Time | <500ms |
| First Paint | <50ms |

### Comparison

Keep comparisons qualitative unless they are backed by a reproducible benchmark run from the current machine and plugin lockfile.

---

## Measurement Tools

### 1. Startup Time Profiling

**Method 1: Built-in Profiler**
```bash
nvim --startuptime startup.log
cat startup.log
```

Output format:
```
times in msec
 clock   self+sourced   self:  sourced script
 000.005  000.005: --- NVIM STARTING ---
 000.123  000.118: event init
 000.456  000.333: sourcing init.lua
 ...
```

**Method 2: Lazy.nvim Profiler**
```vim
:Lazy profile
```

Shows per-plugin loading times in interactive UI.

**Method 3: Manual Timing**
```lua
-- Add to init.lua
local uv = vim.uv or vim.loop
local start = uv.hrtime()
-- ... code to measure ...
print(string.format("Took: %.2fms", (uv.hrtime() - start) / 1e6))
```

### 2. Memory Profiling

**Current Memory Usage**
```vim
:lua print(string.format("%.2f MB", collectgarbage("count") / 1024))
```

**System Memory (macOS)**
```bash
ps aux | grep nvim
# Column: RSS = Resident Set Size (KB)
```

**Memory Over Time**
```vim
" Add to config - prints memory every 5 seconds
:autocmd CursorHold * lua print(string.format("Mem: %.2f MB", collectgarbage("count") / 1024))
:set updatetime=5000
```

### 3. Runtime Performance

**CPU Profiling (LuaJIT)**
```bash
# Requires profiler plugin
:profile start profile.log
:profile func *
:profile file *
# Perform actions
:profile dump
:quit
```

---

## Optimization Techniques

### 1. Disabled Builtins (~20ms savings)

**Location:** `init.lua`

```lua
-- Disable unused Neovim builtins
vim.g.loaded_gzip = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_netrw = 1           -- Using nvim-tree instead
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_matchit = 1         -- Using Treesitter instead
vim.g.loaded_matchparen = 1      -- Using vim-illuminate instead
vim.g.loaded_logiPat = 1
vim.g.loaded_rrhelper = 1
vim.g.loaded_getscript = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1
```

**Why:**
- `netrw`: Replaced by nvim-tree (cleaner startup and file explorer UX)
- `matchparen`: Replaced by vim-illuminate (LSP-aware)
- Others: Rarely used, bloat startup

The current config now applies these disables during early init, before runtime plugins load.

### 2. Lazy Loading (~400ms savings)

**Event-Based Loading**

Most plugins use lazy loading triggers:

```lua
-- Load after UI renders
{ "plugin", event = "VeryLazy" }

-- Load before opening file
{ "plugin", event = "BufReadPre" }

-- Load after file opened
{ "plugin", event = "BufReadPost" }

-- Load when entering insert mode
{ "plugin", event = "InsertEnter" }

-- Load on command
{ "plugin", cmd = "PluginCommand" }

-- Load on filetype
{ "plugin", ft = "python" }

-- Load on keybinding
{ "plugin", keys = { "s", "S" } }
```

**Best Practices:**

| Plugin Type | Recommended Event |
|-------------|-------------------|
| UI Enhancement | `VeryLazy` |
| LSP/Treesitter | `BufReadPre` |
| Completion | `InsertEnter` |
| Git | `BufReadPre` |
| File Explorer | `cmd = "..."` or `keys` |
| Language-Specific | `ft = "..."` |

### 3. Compiled Parsers

**Treesitter Parsers**
```bash
# Pre-compiled grammars
~/.local/share/nvim/lazy/nvim-treesitter/parser/
```

**Why:** Native parsers are much faster than pure-Lua parsing for syntax-heavy workloads.

### 4. Caching Strategies

**Lazy.nvim Module Cache**
```lua
-- Cached require() calls - reused across startups
~/.cache/nvim/lazy/
```

**Treesitter Query Cache**
```lua
-- lua/plugins/treesitter.lua
highlight = {
  enable = true,
  additional_vim_regex_highlighting = false,  -- Don't duplicate work
}
```

**LSP Workspace Cache**
```lua
-- Workspace symbols cached by LSP servers
~/.local/state/nvim/lsp.log
```

### 5. Async Operations

**Mason Downloads**
```lua
-- Non-blocking LSP server installation
require("mason-tool-installer").setup({
  auto_update = true,
  run_on_start = false,  -- Don't block startup
})
```

For lean startup, keep Mason as an on-demand maintenance tool (`:Mason`, `:MasonInstall`, `:MasonUpdate`) instead of a startup dependency.

**Copilot**
```lua
-- Async AI suggestions (doesn't block typing)
github/copilot.vim runs in background
```

**Gitsigns**
```lua
-- Async git status checks
gitsigns.nvim updates sign column asynchronously
```

---

## Lazy Loading Strategies

### Event Hierarchy

```
Startup (0ms)
├── init.lua loads
├── lazy.nvim bootstraps
└── Core config loads (options, keymaps)
    ↓
VimEnter (30ms)
└── snacks.nvim dashboard shows
    ↓
VeryLazy (200ms)
├── which-key.nvim
├── mini.* plugins
└── persistence.nvim
    ↓
BufReadPre (when opening file)
├── nvim-treesitter
├── gitsigns.nvim
└── lsp.lua
    ↓
BufReadPost (after file loaded)
└── nvim-ufo (folding)
    ↓
InsertEnter (when typing)
├── completion.lua
└── blink.cmp
    ↓
LspAttach (LSP ready)
├── nvim-navic
└── LSP keybindings
```

### Lazy Loading Patterns

**Pattern 1: Commands**
```lua
-- Load plugin only when command invoked
{
  "williamboman/mason.nvim",
  cmd = { "Mason", "MasonUpdate", "MasonInstall" },
}
```

**Pattern 2: Keybindings**
```lua
-- Load on first keypress
{
  "folke/flash.nvim",
  keys = {
    { "s", mode = { "n", "x", "o" } },
    { "S", mode = { "n", "x", "o" } },
  },
}
```

**Pattern 3: File Types**
```lua
-- Load only for Python files
{
  "AckslD/swenv.nvim",
  ft = "python",
}
```

**Pattern 4: Dependencies**
```lua
-- Load supporting plugins with their parent plugin
{
  "saghen/blink.cmp",
  event = "InsertEnter",
  dependencies = { "rafamadriz/friendly-snippets" },
}
```

---

## Plugin-Specific Optimizations

### Snacks Picker

`Snacks.picker` is enabled as part of `snacks.nvim` and uses fast external tools when available.

```lua
{
  "folke/snacks.nvim",
  opts = {
    picker = { enabled = true, ui_select = true },
  },
}
```

Keep `rg` and `fd` installed for fast file and grep pickers.

### Treesitter

**Incremental Parsing**
```lua
-- Only reparse changed lines
highlight = {
  enable = true,
  disable = {},  -- Disable for slow languages if needed
}
```

**Disable for Large Files**
```lua
-- In autocmd
vim.api.nvim_create_autocmd("BufReadPre", {
  callback = function()
    if vim.api.nvim_buf_line_count(0) > 10000 then
      vim.cmd("TSBufDisable highlight")
    end
  end,
})
```

### LSP

**Silent Initialization**
```lua
-- No "LSP started" notifications
on_init = function(_, _)
  -- Silent
end
```

**Debounced Diagnostics**
```lua
vim.diagnostic.config({
  update_in_insert = false,  -- Don't update while typing
  virtual_text = { prefix = "●" },
})
```

### blink.cmp

Completion loads on `InsertEnter` and uses LSP, path, snippet, and buffer sources.

```lua
sources = {
  default = { "lsp", "path", "snippets", "buffer" },
}
```

For very large files, omit the buffer source or add a file-size guard.

---

## Runtime Performance

### Reduce UI Redraws

**Lazy Redraw**
```lua
vim.opt.lazyredraw = true  -- Don't redraw during macros
```

**Fast TTY**
```lua
vim.opt.ttyfast = true  -- Faster terminal rendering
```

### Reduce Disk I/O

**Swap File Location**
```lua
vim.opt.swapfile = false  -- Disable swap (SSD era)
-- Or: vim.opt.directory = "/tmp"  -- Tmpfs is faster
```

**Undo File Location**
```lua
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"
```

### Limit History

```lua
vim.opt.history = 500  -- Default is 10000
vim.opt.undolevels = 500  -- Default is 1000
```

---

## Profiling Guide

### Step 1: Baseline Measurement

```bash
# Measure 10 times, take average
for i in {1..10}; do
  nvim --startuptime /tmp/startup-$i.log +quit
done

# Average startup time
awk '/^[0-9]/ {sum+=$1; count++} END {print "Avg:", sum/count, "ms"}' /tmp/startup-*.log
```

### Step 2: Identify Slow Plugins

```vim
:Lazy profile
```

Sort by "Time" column. Plugins taking >10ms are candidates for optimization.

### Step 3: Optimize Slow Plugin

**Option 1: Add lazy loading**
```lua
event = "VeryLazy"  -- or more specific trigger
```

**Option 2: Defer setup**
```lua
config = function()
  vim.defer_fn(function()
    require("plugin").setup()
  end, 100)  -- Delay 100ms
end
```

**Option 3: Remove if unused**
```lua
-- Delete plugin spec or:
enabled = false,
```

### Step 4: Re-measure

Repeat Step 1. Compare before/after.

---

## Benchmarking

### Startup Time by Plugin Count

Plugin count alone is not a reliable performance measure because lazy-loading strategy, plugin setup work, and machine speed dominate results. Re-measure locally against the current `lazy-lock.json` before citing exact numbers.

**Insight:** Lazy loading scales well; track startup time with reproducible benchmarks rather than hand-maintained plugin-count tables.

### CPU Usage

**Idle:** 0-1% (dashboard showing)
**Typing:** 2-5% (completion + LSP)
**LSP Indexing:** 20-50% (first-time project open)
**Treesitter Parsing:** 5-10% (large file)

### Memory Growth Over Time

| Time | Memory | Activity |
|------|--------|----------|
| 0s | 150MB | Startup (dashboard) |
| 10s | 160MB | Opened file.ts |
| 30s | 200MB | LSP attached |
| 5min | 210MB | Editing, completion |
| 1hr | 220MB | Multiple files, git operations |
| 8hr | 250MB | Full workday |

**Memory leak check:** Restart if >400MB.

---

## Performance Regression Detection

### Automated Benchmarking

**Script:** `benchmark.sh`
```bash
#!/bin/bash
# Run before and after config changes

echo "Running 10 startup benchmarks..."
total=0
for i in {1..10}; do
  time=$(nvim --startuptime /tmp/bench.log +quit 2>&1 | \
    awk '/^[0-9]/ {print $1}' | tail -1)
  total=$(echo "$total + $time" | bc)
done
avg=$(echo "scale=2; $total / 10" | bc)
echo "Average startup: ${avg}ms"
```

**Usage:**
```bash
./benchmark.sh > before.txt
# Make config changes
./benchmark.sh > after.txt
diff before.txt after.txt
```

### Thresholds for Action

| Change | Action |
|--------|--------|
| +0-10ms | ✅ Acceptable |
| +10-30ms | ⚠️  Review plugin - is it worth it? |
| +30-50ms | ❌ Optimize or remove plugin |
| +50ms+ | 🚨 Unacceptable - remove or defer |

---

## Performance Best Practices

### DO

✅ Use `event = "VeryLazy"` for UI plugins
✅ Use `cmd` for rarely-used commands
✅ Use `ft` for language-specific plugins
✅ Disable builtins you're replacing
✅ Profile after adding plugins
✅ Use compiled plugins when available (FZF, Treesitter)
✅ Cache aggressively
✅ Run async where possible

### DON'T

❌ Load all plugins on startup
❌ Use `event = "BufEnter"` (too eager)
❌ Duplicate functionality (multiple file explorers)
❌ Enable auto-update checks (network latency)
❌ Run synchronous network calls
❌ Parse large files without limits
❌ Keep unused plugins "just in case"

---

## Quick Performance Checklist

```
□ Startup time <100ms (:Lazy profile)
□ Only intentional plugins load on startup
□ `rg` and `fd` are installed for Snacks picker
□ Treesitter incremental parsing enabled
□ LSP initialization quiet
□ Completion loads on InsertEnter
□ Builtins disabled (netrw, matchparen)
□ Memory <300MB after 1 hour
□ No network calls on startup
□ Profiling shows no >20ms plugins
```

---

## Advanced Optimization

### Defer Non-Critical Setup

```lua
-- Delay which-key registration until first <leader> press
{
  "which-key.nvim",
  event = "VeryLazy",
  config = function()
    vim.defer_fn(function()
      require("which-key").setup()
    end, 500)  -- Delay 500ms
  end,
}
```

### Conditional Loading

```lua
-- Load plugin only on macOS
{
  "plugin",
  cond = vim.fn.has("mac") == 1,
}

-- Load only if executable exists
{
  "plugin",
  cond = vim.fn.executable("git") == 1,
}
```

### Module Memoization

```lua
-- Cache expensive computations
local cached_result = nil
local function expensive_function()
  if cached_result then return cached_result end
  -- Expensive computation
  cached_result = result
  return result
end
```

---

**See also:**
- `ARCHITECTURE.md` - Loading strategy details
- `PLUGINS_REFERENCE.md` - Per-plugin loading configuration
- `TROUBLESHOOTING.md` - Performance problem diagnosis
- `:Lazy profile` - Interactive profiler
