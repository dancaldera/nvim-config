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

-- Check compatibility
require("config.compatibility")

-- Basic settings
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- Plugin management
require("config.lazy")

-- Health check commands (manual only - auto-check disabled for performance)
require("config.health")

-- Project-local config support
local project_config = vim.fn.getcwd() .. "/.nvim.lua"
if vim.fn.filereadable(project_config) == 1 then
	vim.cmd.source(project_config)
end
