-- ============================================================================
-- Basic Neovim Options
-- ============================================================================

local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = false

-- Tabs and indentation
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
opt.timeoutlen = 300

-- Completion
opt.completeopt = "menu,menuone,noselect"
opt.pumheight = 10
opt.pumblend = 10 -- Popup transparency

-- File encoding
opt.fileencoding = "utf-8"

-- Command line
opt.cmdheight = 1
opt.showcmd = true
opt.laststatus = 3 -- Global statusline

-- Scrolling
opt.scrolloff = 8
opt.sidescrolloff = 8

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
opt.conceallevel = 0 -- show all characters by default (toggle render with <leader>tm)
opt.concealcursor = ""

-- Formatting
opt.formatoptions = "jcroqlnt"

-- Session options
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
