# Plugins Reference

Reference for the active plugin set, grouped by responsibility instead of hard-coded counts.

> Neovim `0.10+` is supported. `0.11+` is recommended for the native `vim.lsp.config` flow used here.

## LSP & Language Intelligence

Configured in `lua/plugins/lsp.lua`.

- `williamboman/mason.nvim`: external tool manager
- `WhoIsSethDaniel/mason-tool-installer.nvim`: startup tool installation
- `williamboman/mason-lspconfig.nvim`: Mason to LSP bridge
- `neovim/nvim-lspconfig`: server setup and attach behavior
- `hrsh7th/cmp-nvim-lsp`: LSP completion capabilities
- `antosha417/nvim-lsp-file-operations`: rename/move notifications for LSPs
- `folke/lazydev.nvim`: improved Lua development UX
- `Bilal2453/luvit-meta`: `vim.uv` types for Lua development

Primary LSP mappings:

| Keybinding | Action |
|---|---|
| `gd` | Definition |
| `gD` | Declaration |
| `gi` | Implementation |
| `gy` | Type definition |
| `gR` | References |
| `K` | Hover |
| `<leader>ca` | Code actions |
| `<leader>rn` | Rename |
| `<leader>ti` | Cycle inlay hints |

## Completion & Snippets

Configured in `lua/plugins/completion.lua`.

- `github/copilot.vim`: inline Copilot suggestions
- `hrsh7th/nvim-cmp`: completion engine
- `hrsh7th/cmp-buffer`: buffer completions
- `hrsh7th/cmp-path`: path completions
- `L3MON4D3/LuaSnip`: snippet engine
- `rafamadriz/friendly-snippets`: snippet collection
- `saadparwaiz1/cmp_luasnip`: snippet completion source
- `onsails/lspkind.nvim`: completion item icons

Primary completion mappings:

| Keybinding | Action |
|---|---|
| `<C-g>` | Accept Copilot suggestion |
| `<C-x>` | Dismiss Copilot suggestion |
| `<C-Space>` | Trigger completion |
| `<Tab>` / `<S-Tab>` | Navigate completion or snippets |
| `<CR>` | Confirm completion |

## Editing & UI

Configured across `lua/plugins/editor.lua`, `lua/plugins/ui.lua`, and `lua/plugins/treesitter.lua`.

- `windwp/nvim-autopairs`
- `kylechui/nvim-surround`
- `numToStr/Comment.nvim`
- `JoosepAlviste/nvim-ts-context-commentstring`
- `folke/which-key.nvim`
- `ThePrimeagen/refactoring.nvim`
- `folke/noice.nvim`
- `echasnovski/mini.ai`
- `nvim-lualine/lualine.nvim`
- `SmiteshP/nvim-navic`
- `akinsho/bufferline.nvim`
- `echasnovski/mini.bufremove`
- `echasnovski/mini.indentscope`
- `RRethy/vim-illuminate`
- `kevinhwang91/nvim-ufo`
- `kevinhwang91/promise-async`
- `nvim-treesitter/nvim-treesitter`
- `windwp/nvim-ts-autotag`
- `nvim-tree/nvim-web-devicons`

Representative mappings:

| Keybinding | Action |
|---|---|
| `<S-h>` / `<S-l>` | Previous/next buffer |
| `<leader>bd` | Delete buffer |
| `]]` / `[[` | Next/previous reference |
| `zR` / `zM` | Open/close all folds |
| `<leader>re` | Extract function |

## Search, Diagnostics, and File Management

Configured in `lua/plugins/telescope.lua`, `lua/plugins/diagnostics.lua`, and `lua/plugins/nvim-tree.lua`.

- `nvim-telescope/telescope.nvim`
- `nvim-telescope/telescope-fzf-native.nvim`
- `folke/trouble.nvim`
- `nvim-tree/nvim-tree.lua`

Primary mappings:

| Keybinding | Action |
|---|---|
| `<leader>ff` | Find files |
| `<leader>fs` | Live grep |
| `<leader>fr` | Recent files |
| `<leader>ee` | Toggle file explorer |
| `<leader>ef` | Reveal current file in explorer |
| `<leader>xx` | Workspace diagnostics |
| `<leader>xX` | Buffer diagnostics |
| `<leader>xc` | Copy diagnostics |

## Git, Terminals, and Workflow Tools

Configured in `lua/plugins/git.lua` and `lua/plugins/dev-tools.lua`.

- `lewis6991/gitsigns.nvim`
- `tpope/vim-fugitive`
- `folke/snacks.nvim`
- `folke/todo-comments.nvim`
- `ahmedkhalf/project.nvim`
- `nvim-lua/plenary.nvim`

Primary mappings:

| Keybinding | Action |
|---|---|
| `<leader>gc` | Commit with AI-generated message |
| `<leader>gC` | Stage all and commit |
| `<leader>gA` | Stage all, commit, and push |
| `<leader>gP` | Push |
| `<leader>tt` | Toggle terminal |
| `<leader>lg` | Open lazygit |
| `<leader>ft` | Find TODO comments |
| `<leader>fp` | Find projects |

## Formatting, Python, and Markdown

Configured in `lua/plugins/formatting.lua`, `lua/plugins/python.lua`, and `lua/plugins/markdown.lua`.

- `stevearc/conform.nvim`
- `mfussenegger/nvim-lint`
- `AckslD/swenv.nvim`
- `MeanderingProgrammer/render-markdown.nvim`

Primary mappings:

| Keybinding | Action |
|---|---|
| `<leader>cf` / `<leader>jf` | Format file or selection |
| `<leader>jl` | Toggle auto-linting |
| `<leader>ml` | Lint current file |
| `<leader>pv` | Pick Python virtualenv |
| `<leader>mp` | Toggle markdown rendering |

## Custom Modules

These live under `lua/config/` and are maintained alongside the plugin specs.

- `openai.lua`: commit-message generation with OpenAI or OpenRouter
- `github.lua`: GitHub CLI account parsing and switching
- `health.lua`: health checks and documentation consistency checks

## Maintenance

- Treat the Lua config as the source of truth for mappings and plugin ownership.
- Keep this document descriptive, not quantitative; plugin counts belong in code or generated output, not hand-maintained markdown.
