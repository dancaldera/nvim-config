-- -------------------------------------------------------------------------------=
-- Telescope (Fuzzy Finder) Configuration
-- -------------------------------------------------------------------------------=

return {
	"nvim-telescope/telescope.nvim",
	cmd = "Telescope",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
	},
	keys = {
		{ "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Fuzzy find files in cwd" },
		{ "<leader>fr", "<cmd>Telescope oldfiles<CR>", desc = "Fuzzy find recent files" },
		{ "<leader>fs", "<cmd>Telescope live_grep<CR>", desc = "Find string in cwd" },
		{ "<leader>fc", "<cmd>Telescope grep_string<CR>", desc = "Find string under cursor in cwd" },
		{ "<leader>fb", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<CR>", desc = "Find open buffers" },
		{ "<leader>bb", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<CR>", desc = "Find open buffers" },
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")

		telescope.setup({
			defaults = {
				prompt_prefix = " ",
				selection_caret = "░",
				path_display = { "truncate" },
				sorting_strategy = "ascending",
				layout_config = {
					horizontal = {
						prompt_position = "top",
						preview_width = 0.55,
						results_width = 0.8,
						width = 0.87,
						height = 0.80,
						preview_cutoff = 120,
					},
					vertical = {
						mirror = false,
					},
					width = 0.87,
					height = 0.80,
					preview_cutoff = 120,
				},
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous,
						["<C-j>"] = actions.move_selection_next,
						["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
						["<C-n>"] = actions.cycle_history_next,
						["<C-p>"] = actions.cycle_history_prev,
						["<C-u>"] = false,
						["<C-d>"] = actions.preview_scrolling_down,
						["<C-f>"] = actions.preview_scrolling_up,
					},
					n = {
						["q"] = actions.close,
					},
				},
				vimgrep_arguments = {
					"rg",
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
					"--hidden",
					"--glob=!.git/",
				},
			},
			pickers = {
				find_files = {
					hidden = true,
					find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
				},
			},
		})

		telescope.load_extension("fzf")
	end,
}
