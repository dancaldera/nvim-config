-- ============================================================================
-- Colorscheme Configuration - Tokyo Night
-- ============================================================================

return {
	{
		"folke/tokyonight.nvim",
		priority = 1000,
		lazy = false,
		config = function()
			require("tokyonight").setup({
				style = "night",
				transparent = false,
			})
			vim.cmd("colorscheme tokyonight")
		end,
	},
}
