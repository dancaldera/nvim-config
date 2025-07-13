-- ============================================================================
-- Basic Neovim Options
-- ============================================================================

local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Tabs and indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

-- Line wrapping
opt.wrap = false

-- Search settings
opt.ignorecase = true
opt.smartcase = true

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
opt.updatetime = 300

-- Completion
opt.completeopt = "menu,menuone,noselect"

-- File encoding
opt.fileencoding = "utf-8"

-- Command line
opt.cmdheight = 1

-- Pop up menu
opt.pumheight = 10

-- Time to wait for mapped sequence
opt.timeoutlen = 500

-- Folding
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldlevel = 99