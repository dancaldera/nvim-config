-- ============================================================================
-- Compatibility Check for Neovim 0.9.x
-- ============================================================================

-- Check Neovim version compatibility
local version = vim.version()
if version.major == 0 and version.minor < 9 then
	vim.notify("This configuration requires Neovim 0.9+. Please upgrade.", vim.log.levels.ERROR)
	return
end

-- Set compatibility options for 0.9.x
if version.major == 0 and version.minor == 9 then
	-- Disable some features that require 0.10+
	vim.g.nvim_version_compat = "0.9"
end
