-- ============================================================================
-- Colorscheme Configuration
-- ============================================================================

return {
	{
		name = "custom-themes",
		dir = vim.fn.stdpath("config"),
		priority = 1000,
		config = function()
			-- Load Gruvbox Dark theme
			dofile(vim.fn.stdpath("config") .. "/lua/colors/gruvbox-custom.lua")
		end,
	},
}
