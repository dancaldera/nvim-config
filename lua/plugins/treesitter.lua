-- ============================================================================
-- Treesitter Configuration (New API - Post-Rewrite)
-- ============================================================================

return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false, -- Plugin must not be lazy-loaded
		build = ":TSUpdate",
		dependencies = {
			"windwp/nvim-ts-autotag",
		},
		config = function()
			-- Install parsers on first load
			local parsers = {
				"json",
				"javascript",
				"typescript",
				"tsx",
				"yaml",
				"html",
				"css",
				"prisma",
				"markdown",
				"markdown_inline",
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
				"latex",
				"scss",
				"typst",
				"vue",
			}

			-- Install all parsers asynchronously
			require("nvim-treesitter").install(parsers)

			-- Enable treesitter highlighting for common filetypes
			vim.api.nvim_create_autocmd("FileType", {
				pattern = {
					"javascript",
					"typescript",
					"tsx",
					"jsx",
					"lua",
					"python",
					"go",
					"rust",
					"c",
					"cpp",
					"html",
					"css",
					"scss",
					"json",
					"yaml",
					"markdown",
					"bash",
					"sh",
					"vim",
					"toml",
					"graphql",
					"svelte",
					"vue",
					"prisma",
				},
				callback = function()
					vim.treesitter.start()
				end,
			})

			-- Enable treesitter-based indentation
			vim.api.nvim_create_autocmd("FileType", {
				pattern = {
					"javascript",
					"typescript",
					"tsx",
					"jsx",
					"lua",
					"python",
					"go",
					"rust",
					"c",
					"cpp",
					"html",
					"css",
					"json",
					"yaml",
				},
				callback = function()
					vim.bo.indentexpr = "v:lua.vim.treesitter.indentexpr()"
				end,
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
