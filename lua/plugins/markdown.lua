-- ============================================================================
-- Markdown Support (render-markdown: in-buffer live preview, pure Lua)
-- ============================================================================

return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		ft = { "markdown" },
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {
			enabled = true,
			render_modes = { "n", "c" },
			heading = {
				enabled = true,
				sign = false,
				icons = { "# ", "## ", "### ", "#### ", "##### ", "###### " },
			},
			code = {
				enabled = true,
				sign = false,
				style = "full",
				width = "block",
			},
			bullet = {
				enabled = true,
				icons = { "●", "○", "◆", "◇" },
			},
			checkbox = {
				enabled = true,
				unchecked = { icon = "󰄱 " },
				checked = { icon = "󰱒 " },
			},
			link = { enabled = true },
			pipe_table = { enabled = true, style = "full" },
			anti_conceal = { enabled = true },
		},
		config = function(_, opts)
			require("render-markdown").setup(opts)

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("MarkdownSettings", { clear = true }),
				pattern = { "markdown" },
				callback = function()
					vim.opt_local.wrap = true
					vim.opt_local.linebreak = true
					vim.opt_local.conceallevel = 2
					vim.opt_local.concealcursor = "nc"
					vim.opt_local.spell = true
					vim.opt_local.spelllang = "en_us"
				end,
			})
		end,
		keys = {
			{
				"<leader>mt",
				function()
					require("render-markdown").toggle()
				end,
				ft = "markdown",
				desc = "Toggle render",
			},
			{
				"<leader>me",
				function()
					require("render-markdown").enable()
				end,
				ft = "markdown",
				desc = "Enable render",
			},
			{
				"<leader>md",
				function()
					require("render-markdown").disable()
				end,
				ft = "markdown",
				desc = "Disable render",
			},
		},
	},
}
