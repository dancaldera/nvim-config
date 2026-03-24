# Configuration Architecture

Current architecture overview for this Neovim configuration.

## Directory Layout

```text
~/.config/nvim/
├── init.lua
├── README.md
├── lazy-lock.json
├── lua/
│   ├── config/
│   │   ├── autocmds.lua
│   │   ├── compatibility.lua
│   │   ├── github.lua
│   │   ├── health.lua
│   │   ├── keymaps.lua
│   │   ├── lazy.lua
│   │   ├── openai.lua
│   │   └── options.lua
│   └── plugins/
│       ├── colorscheme.lua
│       ├── completion.lua
│       ├── dev-tools.lua
│       ├── diagnostics.lua
│       ├── editor.lua
│       ├── formatting.lua
│       ├── git.lua
│       ├── lsp.lua
│       ├── nvim-tree.lua
│       ├── python.lua
│       ├── telescope.lua
│       ├── treesitter.lua
│       └── ui.lua
└── docs/
```

## Startup Flow

`init.lua` performs a small amount of eager setup, then hands plugin discovery to `lazy.nvim`.

1. Set leader keys and provider toggles.
2. Load core config from `lua/config/`.
3. Bootstrap and configure `lazy.nvim`.
4. Register health helpers.
5. Optionally source a project-local `.nvim.lua`.

The config keeps core editor behavior in `lua/config/` and groups plugin specs by concern in `lua/plugins/`.

## Core Modules

| Module | Responsibility |
|--------|----------------|
| `options.lua` | Native Neovim options like indentation, folds, clipboard, UI, and sessions |
| `keymaps.lua` | Global non-plugin keymaps |
| `autocmds.lua` | Editor autocommands |
| `compatibility.lua` | Version checks and small compatibility shims |
| `lazy.lua` | `lazy.nvim` bootstrap and runtime tuning |
| `health.lua` | Manual health checks and consistency checks |
| `openai.lua` | AI commit message generation |
| `github.lua` | GitHub CLI account inspection and switching |

## Plugin Grouping

| File | Responsibility |
|------|----------------|
| `lsp.lua` | Mason, LSP servers, attach-time LSP mappings, inlay hints |
| `completion.lua` | Copilot and `nvim-cmp` |
| `formatting.lua` | `conform.nvim` and `nvim-lint` |
| `treesitter.lua` | Treesitter parsers and autotagging |
| `ui.lua` | Statusline, bufferline, breadcrumbs, folds, reference highlighting |
| `nvim-tree.lua` | File explorer and explorer-specific mappings |
| `telescope.lua` | Search pickers and Telescope mappings |
| `editor.lua` | Autopairs, surround, commenting, which-key, refactoring, Noice, text objects |
| `git.lua` | Gitsigns, fugitive, and AI-assisted git workflows |
| `dev-tools.lua` | Snacks dashboard/terminal/lazygit, TODO comments, project switching |
| `diagnostics.lua` | Trouble views and severity-aware diagnostic navigation |
| `python.lua` | Python virtualenv detection and switching |

## Cross-Module Integration

- `nvim-lspconfig` and Telescope are connected through LSP attach mappings like `gd`, `gR`, `gi`, and `gy`.
- `nvim-tree` works with `nvim-lsp-file-operations` so file moves can notify language servers.
- `conform.nvim` and `nvim-lint` choose tools based on project files in the working tree.
- `lualine` reads from `config.github`, `lazy.status`, `nvim-navic`, and `swenv` to enrich the statusline.
- `snacks.nvim` provides the dashboard, terminal UX, and lazygit entrypoint.

## Maintenance Notes

- `lazy-lock.json` is the plugin source of truth; avoid hard-coding plugin counts in docs.
- Keybinding docs should track `vim.keymap.set(...)` calls and plugin `keys = {}` tables.
- `health.lua` includes a documentation consistency check for high-signal drift in the main docs.
