-- ============================================================================
-- Colorscheme Configuration
-- ============================================================================

return {
	{
		name = "gruvbox-custom",
		dir = vim.fn.stdpath("config"),
		priority = 1000,
		config = function()
			-- Load Gruvbox Custom theme
			dofile(vim.fn.stdpath("config") .. "/lua/colors/gruvbox-custom.lua")
		end,
	},
}
