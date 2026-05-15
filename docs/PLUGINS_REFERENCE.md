# Plugins Reference

Reference for the active plugin set, grouped by responsibility instead of hard-coded counts.

> Neovim `0.10+` is supported. `0.11+` is recommended for the native `vim.lsp.config` flow used here.

## LSP & Language Intelligence

Configured in `lua/plugins/lsp.lua`.

- `williamboman/mason.nvim`: external tool manager
- `WhoIsSethDaniel/mason-tool-installer.nvim`: Mason tool installer
- `williamboman/mason-lspconfig.nvim`: Mason to LSP bridge
- `neovim/nvim-lspconfig`: server setup and attach behavior
- `folke/lazydev.nvim`: improved Lua development UX
- `Bilal2453/luvit-meta`: `vim.uv` types for Lua development

Primary LSP mappings:

| Keybinding | Action |
|---|---|
| `gd` | Definition via `Snacks.picker` |
| `gD` | Declaration |
| `gi` | Implementation via `Snacks.picker` |
| `gy` | Type definition via `Snacks.picker` |
| `gR` | References via `Snacks.picker` |
| `K` | Hover |
| `<leader>ca` | Code actions |
| `<leader>rn` | Rename |
| `<leader>ti` | Cycle inlay hints |

## Completion & AI

Configured in `lua/plugins/completion.lua`.

- `github/copilot.vim`: inline Copilot suggestions
- `saghen/blink.cmp`: LSP, path, snippet, and buffer completion engine
- `rafamadriz/friendly-snippets`: snippet collection consumed by `blink.cmp`

Primary completion mappings:

| Keybinding | Action |
|---|---|
| `<C-g>` | Accept Copilot suggestion |
| `<C-x>` | Dismiss Copilot suggestion |
| `<C-Space>` | Trigger completion |
| `<C-k>` / `<C-j>` | Previous/next completion item |
| `<Tab>` / `<S-Tab>` | Navigate completion or snippets |
| `<CR>` | Accept completion or fallback |

## Editing & UI

Configured across `lua/plugins/editor.lua`, `lua/plugins/ui.lua`, and `lua/plugins/treesitter.lua`.

- `echasnovski/mini.pairs`
- `echasnovski/mini.surround`
- `echasnovski/mini.comment`
- `echasnovski/mini.ai`
- `nvim-treesitter/nvim-treesitter`
- `windwp/nvim-ts-autotag`
- `JoosepAlviste/nvim-ts-context-commentstring`
- `folke/which-key.nvim`
- `ThePrimeagen/refactoring.nvim`
- `nvim-lualine/lualine.nvim`
- `SmiteshP/nvim-navic`
- `akinsho/bufferline.nvim`
- `echasnovski/mini.bufremove`
- `echasnovski/mini.indentscope`
- `RRethy/vim-illuminate`
- `kevinhwang91/nvim-ufo`
- `kevinhwang91/promise-async`
- `nvim-tree/nvim-web-devicons`: icon provider

Representative mappings:

| Keybinding | Action |
|---|---|
| `<S-h>` / `<S-l>` | Previous/next buffer |
| `<leader>bd` | Delete buffer |
| `]]` / `[[` | Next/previous reference |
| `zR` / `zM` | Open/close all folds |
| `<leader>re` | Extract function |

## Search, Diagnostics, and File Management

Configured in `lua/plugins/picker.lua`, `lua/plugins/diagnostics.lua`, and `lua/plugins/explorer.lua`.

- `folke/snacks.nvim`: picker, dashboard, notifier, terminals, lazygit, `vim.ui.select`
- `folke/trouble.nvim`: diagnostics and symbol views
- `nvim-tree/nvim-tree.lua`: clean file explorer
- `nvim-tree/nvim-web-devicons`: file icons

Primary mappings:

| Keybinding | Action |
|---|---|
| `<leader>ff` | Find files |
| `<leader>fs` | Live grep |
| `<leader>fr` | Recent files |
| `<leader>fp` | Find projects |
| `<leader>ee` | Toggle file explorer |
| `<leader>ef` | Reveal current file in explorer |
| `<leader>xx` | Workspace diagnostics |
| `<leader>xX` | Buffer diagnostics |
| `<leader>xc` | Copy diagnostics |

## Git, Terminals, and Workflow Tools

Configured in `lua/plugins/git.lua` and `lua/plugins/dev-tools.lua`.

- `lewis6991/gitsigns.nvim`
- `tpope/vim-fugitive`
- `folke/todo-comments.nvim`
- `ahmedkhalf/project.nvim`

Primary mappings:

| Keybinding | Action |
|---|---|
| `<leader>gc` | Commit with AI-generated message |
| `<leader>gC` | Stage all and commit |
| `<leader>gy` | Copy AI-generated commit message |
| `<leader>gA` | Stage all, commit, and push |
| `<leader>gP` | Push |
| `<leader>tt` | Open terminal |
| `<leader>gl` | Open lazygit |
| `<leader>ft` | Find TODO comments |

## Formatting and Python

Configured in `lua/plugins/formatting.lua` and `lua/plugins/python.lua`.

- `stevearc/conform.nvim`
- `mfussenegger/nvim-lint`
- `AckslD/swenv.nvim`

Primary mappings:

| Keybinding | Action |
|---|---|
| `<leader>cf` / `<leader>jf` | Format file or selection |
| `<leader>jl` | Toggle auto-linting |
| `<leader>ml` | Lint current file |
| `<leader>pv` | Pick Python virtualenv |

## Custom Modules

These live under `lua/config/` and are maintained alongside the plugin specs.

- `openai.lua`: commit-message generation with OpenAI or OpenRouter
- `github.lua`: GitHub CLI account parsing and switching
- `health.lua`: health checks and documentation consistency checks

## Maintenance

- `lazy-lock.json` is tracked for reproducible plugin versions.
- Treat the Lua config as the source of truth for mappings and plugin ownership.
- Keep this document descriptive; plugin counts should come from the lockfile or generated output.
