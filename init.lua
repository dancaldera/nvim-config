-- ============================================================================
-- Neovim Configuration
-- ============================================================================

-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Check compatibility
require("config.compatibility")

-- Basic settings
require("config.options")
require("config.keymaps")

-- Plugin management
require("config.lazy")