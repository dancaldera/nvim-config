-- ============================================================================
-- Formatting (conform.nvim via LazyVim)
--
-- Autoformat is disabled globally (vim.g.autoformat = false in options.lua).
-- Format manually with <leader>cf (LazyVim default), toggle with <leader>uf.
-- ============================================================================

return {
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				vue = { "prettier" },
				svelte = { "prettier" },
				css = { "prettier" },
				scss = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				["markdown.mdx"] = { "prettier" },
				graphql = { "prettier" },
				liquid = { "prettier" },
				lua = { "stylua" },
				python = { "ruff_format" },
				rust = { "rustfmt" },
				go = { "goimports", "gofmt" },
				sh = { "shfmt" },
				c = { "clang_format" },
				cpp = { "clang_format" },
			},
		},
	},
}
