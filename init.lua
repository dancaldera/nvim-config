-- ============================================================================
-- Neovim Configuration with AI Superpowers
-- ============================================================================
--
-- 🚀 QUICK START:
--   1. Run :Codeium Auth (first time only) - Setup AI completion
--   2. Press <Ctrl-g> in INSERT mode to accept AI suggestions
--   3. See CODEIUM_SETUP.md for full guide
--
-- 📝 AI COMPLETION KEYS (Insert Mode):
--   <Ctrl-g> = Accept AI suggestion  👈 MOST IMPORTANT!
--   <Ctrl-;> = Next AI suggestion
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

-- Check compatibility
require("config.compatibility")

-- Basic settings
require("config.options")
require("config.keymaps")

-- Plugin management
require("config.lazy")

