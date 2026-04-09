-- ============================================================================
-- Treesitter Configuration (New API - Post-Rewrite)
-- ============================================================================

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "master",
		lazy = false, -- Plugin must not be lazy-loaded
		build = ":TSUpdate",
		dependencies = {
			"windwp/nvim-ts-autotag",
		},
		config = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "markdown",
				callback = function(args)
					pcall(vim.treesitter.stop, args.buf)
				end,
			})

			require("nvim-treesitter.configs").setup({
				-- List of parsers to install
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
					"dockerfile",
					"gitignore",
					"query",
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

				-- Install parsers synchronously (only applied to `ensure_installed`)
				sync_install = false,

				-- Automatically install missing parsers when entering buffer
				auto_install = true,

				-- Enable syntax highlighting
				highlight = {
					enable = true,
					disable = { "markdown", "markdown_inline" },
					additional_vim_regex_highlighting = false,
				},

				-- Enable indentation
				indent = {
					enable = true,
					disable = { "markdown" },
				},

				-- Enable incremental selection
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<C-space>",
						node_incremental = "<C-space>",
						scope_incremental = false,
						node_decremental = "<bs>",
					},
				},
			})

			-- Configure nvim-ts-autotag
			require("nvim-ts-autotag").setup({
				opts = {
					enable_close = true,
					enable_rename = true,
					enable_close_on_slash = false,
				},
			})
		end,
	},
}
