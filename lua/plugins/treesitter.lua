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
			-- Neovim 0.12's runtime markdown injections query is safer than the
			-- older nvim-treesitter variant that uses #set-lang-from-info-string!.
			-- Force the runtime-style query to avoid bad injected-node metadata
			-- reaching vim.treesitter.get_node_text()/get_range().
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

			-- Neovim 0.12.1 can crash in the decoration provider when the bash
			-- parser hands invalid range data back to the highlighter. Keep shell
			-- syntax on the built-in regex highlighter until the runtime/parser
			-- combination is fixed upstream.
			local bash_ts_workaround = vim.fn.has("nvim-0.12") == 1 and { "bash" } or {}

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

				-- Automatically install missing parsers when entering buffer
				auto_install = true,

				-- Keep explicit defaults for LuaLS TSConfig compatibility.
				ignore_install = {},
				modules = {},

				-- Enable syntax highlighting
				highlight = {
					enable = true,
					disable = bash_ts_workaround,
					additional_vim_regex_highlighting = bash_ts_workaround,
				},

				-- Enable indentation
				indent = {
					enable = true,
					disable = bash_ts_workaround,
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
