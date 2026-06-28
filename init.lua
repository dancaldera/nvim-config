-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable unused providers (silences warnings on macOS)
vim.g.loaded_python3_provider = 0

-- Disable built-in runtime plugins not covered by lazy.nvim's disabled_plugins list
vim.g.loaded_logiPat = 1
vim.g.loaded_rrhelper = 1
vim.g.loaded_getscript = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1

-- Basic settings
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- Plugin management
require("config.lazy")

-- Project-local config support (secure: .nvim.lua / exrc files run only after
-- a one-time `:trust` per directory; see :h exrc)
vim.o.exrc = true
