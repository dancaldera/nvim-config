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

	-- Smooth scrolling (VS Code-like feel)
	{
		"karb94/neoscroll.nvim",
		event = "VeryLazy",
		config = function()
			require("neoscroll").setup({
				mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "<C-y>", "<C-e>" },
				hide_cursor = true,
				stop_eof = true,
				respect_scrolloff = true,
				cursor_scrolls_alone = true,
				easing_function = "quadratic",
				pre_hook = nil,
				post_hook = nil,
			})
		end,
	},

	-- Note: Statusline (lualine) moved to lua/plugins/ui-statusline.lua

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
				{ "<leader>a", group = "Aerial (Code Outline)" },
				{ "<leader>b", group = "Buffer" },
				{ "<leader>c", group = "Code Actions" },
				{ "<leader>d", group = "Diagnostics" },
				{ "<leader>e", group = "File Explorer" },
				{ "<leader>f", group = "Find/Search" },
				{ "<leader>g", group = "Git Toggles" },
				{ "<leader>h", group = "Git Hunks" },
				{ "<leader>j", group = "Format/Lint" },
				{ "<leader>m", group = "Format" },
				{ "<leader>p", group = "Python" },
				{ "<leader>q", group = "Session" },
				{ "<leader>r", group = "Rename/Refactor/Restart" },
				{ "<leader>s", group = "Split Windows/Search" },
				{ "<leader>t", group = "Terminal/Toggle" },
				{ "<leader>x", group = "Trouble/Diagnostics" },
			})
		end,
	},
}
