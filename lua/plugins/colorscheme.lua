-- ============================================================================
-- Colorscheme Configuration
-- ============================================================================

return {
	{
		"loctvl842/monokai-pro.nvim",
		priority = 1000,
		config = function()
			require("monokai-pro").setup({
				filter = "pro",
				transparent_background = true,
				background_clear = {
					"toggleterm",
					"telescope",
					"which-key",
					"float_win",
				},
				styles = {
					comment = { italic = true },
				},
			})
			vim.cmd.colorscheme("monokai-pro")
		end,
	},
}
