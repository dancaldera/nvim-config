-- ============================================================================
-- Colorscheme: tokyonight, following the OS / terminal light-vs-dark setting
-- ============================================================================
-- Dark  -> tokyonight-night (with transparency)
-- Light -> tokyonight-day   (with transparency)

local theme_detect = require("config.theme_detect")

return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = function()
			return {
				style = theme_detect.tokyonight_style(),
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
			}
		end,
	},
	{ "LazyVim/LazyVim", opts = { colorscheme = theme_detect.colorscheme() } },
}
