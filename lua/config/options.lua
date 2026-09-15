-- ============================================================================
-- Options (overrides on top of LazyVim defaults)
-- ============================================================================

-- Disable unused remote-plugin providers. Node-based tools such as Copilot and
-- language servers invoke Node directly and do not need Neovim's Node provider.
vim.g.loaded_python3_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Disable built-in runtime plugins not covered by lazy.nvim's disabled_plugins list
vim.g.loaded_logiPat = 1
vim.g.loaded_rrhelper = 1
vim.g.loaded_getscript = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1

local opt = vim.opt

-- Line numbers (relative numbers off)
opt.number = true
opt.relativenumber = false

-- Tabs and indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.softtabstop = 2
opt.autoindent = true
opt.smartindent = true

-- Line wrapping
opt.wrap = false
opt.breakindent = true

-- Search settings
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Cursor line
opt.cursorline = true

-- Cursor style (no blinking)
opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,a:blinkon0"

-- Appearance
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

-- Backspace
opt.backspace = "indent,eol,start"

-- Clipboard
opt.clipboard:append("unnamedplus")

-- Split windows
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen" -- Keep screen stable on splits

-- Consider string-string as whole word
opt.iskeyword:append("-")

-- Mouse
opt.mouse = "a"

-- Backup and swap
opt.backup = false
opt.writebackup = false
opt.swapfile = false

-- Undo
opt.undofile = true

-- Update time
opt.updatetime = 250
opt.timeoutlen = 1000

-- Completion
opt.completeopt = "menu,menuone,noselect"
opt.pumheight = 10
opt.pumblend = 0 -- No popup transparency (avoids compositing overhead)

-- File encoding
opt.fileencoding = "utf-8"

-- Command line
opt.cmdheight = 0 -- Hide the idle command line; it appears while typing a command
opt.showcmd = false -- Hide partial commands and Visual selection size
opt.showmode = false -- statusline already shows the current mode
opt.shortmess:append("W") -- Hide "written" messages after saving
opt.laststatus = 3 -- Global statusline
opt.wildmode = "noselect,full" -- Don't auto-select first wildmenu match
opt.wildoptions = "pum,fuzzy" -- Popup menu with fuzzy matching

-- Scrolling
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.smoothscroll = true

-- Performance
opt.lazyredraw = false

-- Folding
opt.foldcolumn = "0"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true

-- Better diffs
opt.diffopt:append("linematch:60")

-- Spellcheck
opt.spell = false
opt.spelllang = { "en_us" }

-- Concealing
opt.conceallevel = 0 -- show all characters by default
opt.concealcursor = ""

-- Formatting
opt.formatoptions = "jcroqlnt"

-- Autoformat is off by default; toggle per buffer with <leader>uf,
-- run manually with <leader>cf.
vim.g.autoformat = false

-- Session options
opt.sessionoptions = { "buffers", "curdir", "winsize", "help", "globals", "skiprtp", "folds" }

-- Project-local config support (secure: .nvim.lua / exrc files run only after
-- a one-time `:trust` per directory; see :h exrc)
vim.o.exrc = true
