-- ============================================================================
-- Colorscheme Configuration
-- ============================================================================

return {
	{
		name = "gruvbox-custom",
		dir = vim.fn.stdpath("config"),
		priority = 1000,
		config = function()
			dofile(vim.fn.stdpath("config") .. "/lua/colors/gruvbox-custom.lua")
		end,
	},
}
