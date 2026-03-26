-- ============================================================================
-- Neovim Configuration with AI Superpowers
-- ============================================================================
--
-- 🚀 QUICK START:
--   1. Run :Copilot auth (first time only) - Setup AI completion
--   2. Press <Ctrl-g> in INSERT mode to accept AI suggestions
--   3. See COPILOT_SETUP.md for full guide
--
-- 📝 AI COMPLETION KEYS (Insert Mode):
--   <Ctrl-g> = Accept AI suggestion  👈 MOST IMPORTANT!
--   <Ctrl-;> = Next AI suggestion
--   <M-CR> = Open Copilot panel
--   <Ctrl-x> = Clear AI suggestion
--
-- 💻 LSP COMPLETION (Insert Mode):
--   <Ctrl-Space> = Show completions
--   <Tab> = Next item
--   <Enter> = Accept
--
-- ============================================================================

-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable unused providers (silences warnings on macOS)
vim.g.loaded_python3_provider = 0

-- Disable built-in runtime plugins replaced by external plugins or not used here.
vim.g.loaded_gzip = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_matchparen = 1
vim.g.loaded_logiPat = 1
vim.g.loaded_rrhelper = 1
vim.g.loaded_getscript = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1

-- Check compatibility
require("config.compatibility")

-- Basic settings
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.audio").setup()

-- Plugin management
require("config.lazy")

-- Health check commands (manual only - auto-check disabled for performance)
require("config.health")

-- Project-local config support
local project_config = vim.fn.getcwd() .. "/.nvim.lua"
if vim.fn.filereadable(project_config) == 1 then
	vim.cmd.source(project_config)
end
