-- ============================================================================
-- Markdown Preview Plugin (render-markdown.nvim)
-- ============================================================================

return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown" },
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
		opts = {
			enabled = true,
			file_types = { "markdown" },
			render_modes = { "n", "c", "t" },
		},
		keys = {
			{
				"<leader>mp",
				function()
					require("render-markdown").toggle()
				end,
				desc = "Toggle markdown preview",
			},
		},
	},
}
