-- ============================================================================
-- Treesitter (LazyVim defaults + extra parsers + autotag)
-- ============================================================================

return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = {
				"json",
				"javascript",
				"typescript",
				"tsx",
				"yaml",
				"html",
				"css",
				"prisma",
				"svelte",
				"graphql",
				"bash",
				"lua",
				"vim",
				"vimdoc",
				"dockerfile",
				"gitignore",
				"query",
				"markdown",
				"markdown_inline",
				"python",
				"go",
				"c",
				"cpp",
				"rust",
				"toml",
				"scss",
				"typst",
				"vue",
			},
		},
		keys = {
			-- Native 0.12 incremental selection
			{
				"<C-space>",
				function()
					vim.treesitter.select("parent")
				end,
				mode = { "n", "x" },
				desc = "Increment treesitter selection",
			},
			{
				"<BS>",
				function()
					vim.treesitter.select("child")
				end,
				mode = "x",
				desc = "Decrement treesitter selection",
			},
		},
	},

	-- Auto close/rename HTML/JSX/Vue/Svelte tags
	{
		"windwp/nvim-ts-autotag",
		event = "LazyFile",
		opts = {
			opts = {
				enable_close = true,
				enable_rename = true,
				enable_close_on_slash = false,
			},
			per_filetype = {
				-- nvim-ts-autotag aliases markdown to html by default, which
				-- causes InsertLeave to re-enter markdown injection parsing.
				markdown = {
					enable_close = false,
					enable_rename = false,
					enable_close_on_slash = false,
				},
			},
		},
	},
}
