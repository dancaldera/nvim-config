-- ============================================================================
-- Linting (nvim-lint via LazyVim)
-- ============================================================================

return {
	{
		"mfussenegger/nvim-lint",
		opts = {
			linters_by_ft = {
				javascript = { "eslint_d" },
				typescript = { "eslint_d" },
				javascriptreact = { "eslint_d" },
				typescriptreact = { "eslint_d" },
				vue = { "eslint_d" },
				svelte = { "eslint_d" },
				sh = { "shellcheck" },
			},
		},
	},
}
