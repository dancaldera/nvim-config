-- ============================================================================
-- Editor Plugins (mini.pairs, mini.surround, mini.comment, which-key)
-- ============================================================================

return {
	-- Autopairs (Treesitter-aware)
	{
		"echasnovski/mini.pairs",
		version = false,
		event = "InsertEnter",
		opts = {
			modes = { insert = true, command = false, terminal = false },
		},
	},

	-- Surround
	{
		"echasnovski/mini.surround",
		version = false,
		event = "VeryLazy",
		opts = {
			silent = true,
		},
	},

	-- Comment (Treesitter-aware via built-in hooks)
	{
		"echasnovski/mini.comment",
		version = false,
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"JoosepAlviste/nvim-ts-context-commentstring",
		},
		opts = {
			hooks = {
				pre = function()
					local ok, ts_comment = pcall(require, "ts_context_commentstring.internal")
					if ok then
						return ts_comment.calculate_commentstring() or vim.bo.commentstring
					end
					return vim.bo.commentstring
				end,
			},
		},
	},

	-- Which-key
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = { delay = 300 },
		config = function(_, opts)
			local wk = require("which-key")
			wk.setup(opts)
			wk.add({
				{ "<leader>b", group = "Buffer" },
				{ "<leader>c", group = "Code Actions" },
				{ "<leader>d", group = "Diagnostics" },
				{ "<leader>e", group = "File Explorer" },
				{ "<leader>f", group = "Find/Search" },
				{ "<leader>g", group = "Git" },
				{ "<leader>h", group = "Git Hunks" },
				{ "<leader>r", group = "Rename/Restart" },
				{ "<leader>s", group = "Split/Search" },
				{ "<leader>t", group = "Terminal/Toggle" },
				{ "<leader>x", group = "Trouble/Diagnostics" },
			})
		end,
	},

	-- Enhanced text objects (function, class, block)
	{
		"echasnovski/mini.ai",
		event = "VeryLazy",
		version = false,
		opts = function()
			local ai = require("mini.ai")
			return {
				n_lines = 500,
				custom_textobjects = {
					o = ai.gen_spec.treesitter({
						a = { "@block.outer", "@conditional.outer", "@loop.outer" },
						i = { "@block.inner", "@conditional.inner", "@loop.inner" },
					}, {}),
					f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
					c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
					t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
				},
			}
		end,
	},
}
