-- ============================================================================
-- Modern Enhancement Plugins
-- Latest quality-of-life plugins for improved development experience
-- ============================================================================

return {
	-- Flash.nvim - Modern motion plugin for better navigation
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {
			labels = "asdfghjklqwertyuiopzxcvbnm",
			search = {
				multi_window = true,
				forward = true,
				wrap = true,
				incremental = false,
			},
			jump = {
				jumplist = true,
				pos = "start",
				history = false,
				register = false,
				nohlsearch = true,
				autojump = false,
			},
			label = {
				uppercase = false,
				rainbow = {
					enabled = false,
					shade = 5,
				},
			},
			modes = {
				char = {
					enabled = true,
					autohide = false,
					jump_labels = false,
					multi_line = true,
				},
			},
		},
		keys = {
			{
				"s",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash",
			},
			{
				"S",
				mode = { "n", "x", "o" },
				function()
					require("flash").treesitter()
				end,
				desc = "Flash Treesitter",
			},
			{
				"r",
				mode = "o",
				function()
					require("flash").remote()
				end,
				desc = "Remote Flash",
			},
			{
				"R",
				mode = { "o", "x" },
				function()
					require("flash").treesitter_search()
				end,
				desc = "Treesitter Search",
			},
			{
				"<c-s>",
				mode = { "c" },
				function()
					require("flash").toggle()
				end,
				desc = "Toggle Flash Search",
			},
		},
	},

	-- Aerial - Code outline sidebar
	{
		"stevearc/aerial.nvim",
		cmd = { "AerialToggle", "AerialOpen", "AerialInfo" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		opts = {
			backends = { "lsp", "treesitter", "markdown", "man" },
			layout = {
				max_width = { 40, 0.2 },
				width = nil,
				min_width = 20,
				default_direction = "prefer_right",
				placement = "window",
			},
			attach_mode = "window",
			close_automatic_events = {},
			keymaps = {
				["?"] = "actions.show_help",
				["g?"] = "actions.show_help",
				["<CR>"] = "actions.jump",
				["<2-LeftMouse>"] = "actions.jump",
				["<C-v>"] = "actions.jump_vsplit",
				["<C-s>"] = "actions.jump_split",
				["p"] = "actions.scroll",
				["<C-j>"] = "actions.down_and_scroll",
				["<C-k>"] = "actions.up_and_scroll",
				["{"] = "actions.prev",
				["}"] = "actions.next",
				["[["] = "actions.prev_up",
				["]]"] = "actions.next_up",
				["q"] = "actions.close",
				["o"] = "actions.tree_toggle",
				["za"] = "actions.tree_toggle",
				["O"] = "actions.tree_toggle_recursive",
				["zA"] = "actions.tree_toggle_recursive",
				["l"] = "actions.tree_open",
				["zo"] = "actions.tree_open",
				["L"] = "actions.tree_open_recursive",
				["zO"] = "actions.tree_open_recursive",
				["h"] = "actions.tree_close",
				["zc"] = "actions.tree_close",
				["H"] = "actions.tree_close_recursive",
				["zC"] = "actions.tree_close_recursive",
				["zR"] = "actions.tree_increase_fold_level",
				["zM"] = "actions.tree_decrease_fold_level",
			},
			lsp = {
				diagnostics_trigger_update = true,
				update_when_errors = true,
				update_delay = 300,
			},
			treesitter = {
				update_delay = 300,
			},
			markdown = {
				update_delay = 300,
			},
			man = {
				update_delay = 300,
			},
			show_guides = true,
			filter_kind = false,
			highlight_on_hover = true,
			autojump = false,
			link_folds_to_tree = false,
			link_tree_to_folds = true,
		},
		keys = {
			{ "<leader>a", "<cmd>AerialToggle<cr>", desc = "Toggle Aerial (Code Outline)" },
		},
	},

	-- LSP Signature - Function signature help as you type
	{
		"ray-x/lsp_signature.nvim",
		event = "LspAttach",
		opts = {
			bind = true,
			handler_opts = {
				border = "rounded",
			},
			floating_window = true,
			floating_window_above_cur_line = true,
			floating_window_off_x = 1,
			floating_window_off_y = 0,
			fix_pos = false,
			hint_enable = true,
			hint_prefix = " ",
			hint_scheme = "String",
			hi_parameter = "LspSignatureActiveParameter",
			max_height = 12,
			max_width = 80,
			transparency = nil,
			extra_trigger_chars = {},
			zindex = 200,
			debug = false,
			log_path = vim.fn.stdpath("cache") .. "/lsp_signature.log",
			verbose = false,
			toggle_key = nil,
			select_signature_key = nil,
			move_cursor_key = nil,
		},
	},

	-- Actions Preview - Better code action preview
	{
		"aznhe21/actions-preview.nvim",
		event = "LspAttach",
		config = function()
			require("actions-preview").setup({
				diff = {
					algorithm = "patience",
					ignore_whitespace = true,
				},
				telescope = require("telescope.themes").get_dropdown({ winblend = 10 }),
			})

			-- Replace default code action with preview
			vim.keymap.set({ "n", "v" }, "<leader>ca", function()
				require("actions-preview").code_actions()
			end, { desc = "Code actions (preview)" })
		end,
	},

	-- Fidget - LSP progress indicator
	{
		"j-hui/fidget.nvim",
		event = "LspAttach",
		opts = {
			progress = {
				display = {
					render_limit = 16,
					done_ttl = 3,
				},
			},
			notification = {
				window = {
					winblend = 0,
				},
			},
		},
	},

	-- Refactoring - Extract function, inline variable, etc.
	{
		"ThePrimeagen/refactoring.nvim",
		event = "VeryLazy",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {
			prompt_func_return_type = {
				go = false,
				java = false,
				cpp = false,
				c = false,
				h = false,
				hpp = false,
				cxx = false,
			},
			prompt_func_param_type = {
				go = false,
				java = false,
				cpp = false,
				c = false,
				h = false,
				hpp = false,
				cxx = false,
			},
			printf_statements = {},
			print_var_statements = {},
		},
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
					require("telescope").extensions.refactoring.refactors()
				end,
				mode = "v",
				desc = "Refactor menu",
			},
		},
	},

	-- Mini.ai - Enhanced text objects
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
		config = function(_, opts)
			require("mini.ai").setup(opts)
		end,
	},
}
