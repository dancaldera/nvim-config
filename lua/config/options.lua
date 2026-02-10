-- ============================================================================
-- Basic Neovim Options
-- ============================================================================

local opt = vim.opt

-- Line numbers
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
opt.undodir = vim.fn.stdpath("data") .. "/undo"

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
opt.cmdheight = 0
opt.showcmd = true
opt.laststatus = 3 -- Global statusline
opt.wildmode = "noselect,full" -- Don't auto-select first wildmenu match
opt.wildoptions = "pum,fuzzy" -- Popup menu with fuzzy matching

-- Scrolling
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.smoothscroll = true

-- Performance
opt.lazyredraw = false
opt.ttyfast = true

-- Folding (using nvim-ufo)
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
opt.conceallevel = 0 -- show all characters by default (toggle render with <leader>jm)
opt.concealcursor = ""

-- Formatting
opt.formatoptions = "jcroqlnt"

-- Session options
opt.sessionoptions = { "buffers", "curdir", "winsize", "help", "globals", "skiprtp", "folds" }
