-- ============================================================================
-- Colorscheme: tokyonight-night with transparency
-- ============================================================================

return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			style = "night",
			transparent = true,
			terminal_colors = true,
			styles = {
				comments = { italic = true },
				keywords = { italic = true },
				functions = {},
				variables = {},
				sidebars = "transparent",
				floats = "transparent",
			},
			lualine_bold = true,
		},
	},
	{ "LazyVim/LazyVim", opts = { colorscheme = "tokyonight-night" } },
}
