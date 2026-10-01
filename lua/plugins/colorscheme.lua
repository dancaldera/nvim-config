-- ============================================================================
-- Colorscheme: tokyonight, following the OS / terminal light-vs-dark setting
-- ============================================================================
-- Dark  -> tokyonight-night (with transparency)
-- Light -> tokyonight-day   (with opaque backgrounds)

local theme_detect = require("config.theme_detect")

return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = function()
			return theme_detect.tokyonight_options()
		end,
	},
	{ "LazyVim/LazyVim", opts = { colorscheme = theme_detect.colorscheme() } },
}
