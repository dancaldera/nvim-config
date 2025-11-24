-- ============================================================================
-- Utility Plugins Configuration
-- ============================================================================

return {
	-- Autopairs - Using mini.pairs (lighter, part of mini.nvim ecosystem)
	{
		"echasnovski/mini.pairs",
		event = "InsertEnter",
		opts = {
			-- Treesitter integration for better context awareness
			modes = { insert = true, command = false, terminal = false },
		},
	},

	-- Surround
	{
		"kylechui/nvim-surround",
		version = "*",
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({})
		end,
	},

	-- Comment
	{
		"numToStr/Comment.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"JoosepAlviste/nvim-ts-context-commentstring",
		},
		config = function()
			local comment = require("Comment")
			local ts_context_commentstring = require("ts_context_commentstring.integrations.comment_nvim")

			comment.setup({
				padding = true,
				sticky = true,
				ignore = "^$",
				toggler = {
					line = "gcc",
					block = "gbc",
				},
				opleader = {
					line = "gc",
					block = "gb",
				},
				extra = {
					above = "gcO",
					below = "gco",
					eol = "gcA",
				},
				mappings = {
					basic = true,
					extra = true,
				},
				pre_hook = ts_context_commentstring.create_pre_hook(),
				---@diagnostic disable-next-line: missing-parameter
				post_hook = function(_) end,
			})
		end,
	},

	-- Status line
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local lualine = require("lualine")
			local lazy_status = require("lazy.status")

			-- Custom theme with Monokai Pro Spectrum colors
			local custom_theme = require("lualine.themes.monokai-pro")
			local bg = "#222222" -- spectrum background
			custom_theme.normal.a.bg = "#7bd88f" -- spectrum green
			custom_theme.insert.a.bg = "#5ad4e6" -- spectrum cyan
			custom_theme.visual.a.bg = "#948ae3" -- spectrum purple
			custom_theme.replace.a.bg = "#fc618d" -- spectrum pink
			custom_theme.command.a.bg = "#fce566" -- spectrum yellow
			custom_theme.terminal = { a = { bg = "#fd9353", fg = bg, gui = "bold" } } -- spectrum orange

			lualine.setup({
				options = {
					theme = custom_theme,
				},
				sections = {
					lualine_x = {
						{
							lazy_status.updates,
							cond = lazy_status.has_updates,
							color = { fg = "#ff9e64" },
						},
						{
							function()
								-- Try swenv first, fallback to $VIRTUAL_ENV
								local ok, swenv = pcall(require, "swenv.api")
								if ok then
									local venv = swenv.get_current_venv()
									if venv then
										return venv.name
									end
								end
								-- Fallback: check $VIRTUAL_ENV
								local venv_path = vim.fn.getenv("VIRTUAL_ENV")
								if venv_path and venv_path ~= vim.NIL then
									return vim.fn.fnamemodify(venv_path, ":t")
								end
								return ""
							end,
							cond = function()
								return vim.bo.filetype == "python"
							end,
							color = { fg = "#fce566" },
						},
						{ "encoding" },
						{ "fileformat" },
						{ "filetype" },
					},
				},
			})
		end,
	},

	-- Which-key
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			timeout = true,
			timeoutlen = 500,
		},
		config = function(_, opts)
			local wk = require("which-key")
			wk.setup(opts)

			-- Add key group descriptions using modern spec
			wk.add({
				{ "<leader>b", group = "Buffer" },
				{ "<leader>c", group = "Code Actions" },
				{ "<leader>d", group = "Diagnostics" },
				{ "<leader>e", group = "File Explorer" },
				{ "<leader>f", group = "Find/Search" },
				{ "<leader>h", group = "Git Hunks" },
				{ "<leader>m", group = "Format" },
				{ "<leader>p", group = "Python" },
				{ "<leader>q", group = "Session" },
				{ "<leader>r", group = "Rename/Restart" },
				{ "<leader>s", group = "Split Windows/Search" },
				{ "<leader>t", group = "Toggle/Terminal" },
				{ "<leader>T", group = "Tabs" },
				{ "<leader>x", group = "Trouble/Diagnostics" },
			})
		end,
	},
}
