-- ============================================================================
-- Editor Plugins (mini.pairs, mini.surround, mini.comment, which-key, refactoring)
-- ============================================================================

return {
	-- Autopairs ( Treesitter-aware )
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

	-- Comment ( Treesitter-aware via built-in hooks )
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
				{ "<leader>h", group = "Git Hunks/Health" },
				{ "<leader>j", group = "Format/Lint" },
				{ "<leader>l", group = "Dev Tools" },
				{ "<leader>m", group = "Markdown" },
				{ "<leader>p", group = "Python" },
				{ "<leader>r", group = "Rename/Refactor/Restart" },
				{ "<leader>s", group = "Split/Search" },
				{ "<leader>t", group = "Terminal/Toggle" },
				{ "<leader>x", group = "Trouble/Diagnostics" },
			})
		end,
	},

	-- Refactoring (extract function, inline variable, etc.)
	{
		"ThePrimeagen/refactoring.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
		opts = {},
		keys = {
			{
				"<leader>re",
				function()
					require("refactoring").refactor("Extract Function")
				end,
				mode = "v",
				desc = "Extract function",
			},
			{
				"<leader>rf",
				function()
					require("refactoring").refactor("Extract Function To File")
				end,
				mode = "v",
				desc = "Extract function to file",
			},
			{
				"<leader>rv",
				function()
					require("refactoring").refactor("Extract Variable")
				end,
				mode = "v",
				desc = "Extract variable",
			},
			{
				"<leader>ri",
				function()
					require("refactoring").refactor("Inline Variable")
				end,
				mode = { "n", "v" },
				desc = "Inline variable",
			},
			{
				"<leader>rr",
				function()
					require("refactoring").select_refactor()
				end,
				mode = "v",
				desc = "Refactor menu",
			},
		},
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
