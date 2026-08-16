-- ============================================================================
-- Treesitter Configuration
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
			-- nvim-treesitter's markdown injections query is incompatible with
			-- the Neovim 0.12 runtime (node:range() nil crash in query_predicates /
			-- decoration providers; nvim-treesitter#8618). Force the runtime-style
			-- query until that is fixed upstream.
			vim.treesitter.query.set(
				"markdown",
				"injections",
				[[
(fenced_code_block
  (info_string
    (language) @injection.language)
  (code_fence_content) @injection.content)

((html_block) @injection.content
  (#set! injection.language "html")
  (#set! injection.combined)
  (#set! injection.include-children))

((minus_metadata) @injection.content
  (#set! injection.language "yaml")
  (#offset! @injection.content 1 0 -1 0)
  (#set! injection.include-children))

((plus_metadata) @injection.content
  (#set! injection.language "toml")
  (#offset! @injection.content 1 0 -1 0)
  (#set! injection.include-children))

([
  (inline)
  (pipe_table_cell)
] @injection.content
  (#set! injection.language "markdown_inline"))
]]
			)

			---@type TSConfig
			local opts = {
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

				-- Install parsers synchronously (only applied to `ensure_installed`)
				sync_install = false,

				-- Do not auto-install parsers for arbitrary filetypes (fetches +
				-- compiles from GitHub on open). ensure_installed above covers the stack.
				auto_install = false,

				-- Keep explicit defaults for LuaLS TSConfig compatibility.
				ignore_install = {},
				modules = {},

				-- Enable syntax highlighting
				highlight = {
					enable = true,
				},

				-- Enable indentation
				indent = {
					enable = true,
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
			}

			require("nvim-treesitter.configs").setup(opts)

			-- Configure nvim-ts-autotag
			require("nvim-ts-autotag").setup({
				opts = {
					enable_close = true,
					enable_rename = true,
					enable_close_on_slash = false,
				},
				per_filetype = {
					-- nvim-ts-autotag aliases markdown to html by default, which
					-- causes InsertLeave to re-enter markdown injection parsing.
					-- Keep autotag disabled there while leaving markdown
					-- Treesitter highlighting enabled.
					markdown = {
						enable_close = false,
						enable_rename = false,
						enable_close_on_slash = false,
					},
				},
			})
		end,
	},
}
