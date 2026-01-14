-- ============================================================================
-- Colorscheme Configuration - Kanagawa
-- ============================================================================

return {
	{
		"rebelot/kanagawa.nvim",
		priority = 1000,
		config = function()
			require("kanagawa").setup({
				compile = false,
				undercurl = true,
				commentStyle = { italic = true },
				keywordStyle = { italic = true },
				statementStyle = { bold = true },
				transparent = false,
				dimInactive = false,
				terminalColors = true,
				theme = "wave",
			})
			vim.cmd("colorscheme kanagawa")
		end,
	},
}
