-- ============================================================================
-- Picker Configuration (snacks.picker - replaces Telescope)
-- ============================================================================

return {
	-- snacks.picker keymaps (requires snacks.nvim with picker enabled)
	{
		"folke/snacks.nvim",
		opts = {
			picker = { enabled = true },
		},
		keys = {
			{
				"<leader>ff",
				function()
					Snacks.picker.files()
				end,
				desc = "Fuzzy find files in cwd",
			},
			{
				"<leader>fr",
				function()
					Snacks.picker.recent()
				end,
				desc = "Fuzzy find recent files",
			},
			{
				"<leader>fs",
				function()
					Snacks.picker.grep()
				end,
				desc = "Find string in cwd",
			},
			{
				"<leader>fc",
				function()
					Snacks.picker.grep_word()
				end,
				desc = "Find string under cursor in cwd",
			},
			{
				"<leader>fb",
				function()
					Snacks.picker.buffers()
				end,
				desc = "Find open buffers",
			},
			{
				"<leader>bb",
				function()
					Snacks.picker.buffers()
				end,
				desc = "Find open buffers",
			},
			{
				"<leader>fp",
				function()
					Snacks.picker.projects()
				end,
				desc = "Find projects",
			},
			{
				"<leader>ft",
				function()
					Snacks.picker.todo_comments()
				end,
				desc = "Find todos",
			},
			{
				"<leader>fh",
				function()
					Snacks.picker.help()
				end,
				desc = "Find help",
			},
			{
				"<leader>fk",
				function()
					Snacks.picker.keymaps()
				end,
				desc = "Find keymaps",
			},
		},
	},
}
