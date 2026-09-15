-- ============================================================================
-- LSP (nvim-lspconfig via LazyVim; servers enabled through Mason)
-- ============================================================================

return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			-- Inlay hints on by default (toggle with <leader>uh)
			inlay_hints = { enabled = true },
			servers = {
				lua_ls = {
					settings = {
						Lua = {
							diagnostics = { globals = { "vim" } },
							completion = { callSnippet = "Replace" },
						},
					},
				},

				-- TypeScript/JavaScript (parameter-name inlay hints for literals only)
				ts_ls = {
					settings = {
						typescript = {
							inlayHints = {
								includeInlayParameterNameHints = "literals",
								includeInlayParameterNameHintsWhenArgumentMatchesName = false,
								includeInlayFunctionParameterTypeHints = false,
								includeInlayVariableTypeHints = false,
								includeInlayVariableTypeHintsWhenTypeMatchesName = false,
								includeInlayPropertyDeclarationTypeHints = false,
								includeInlayFunctionLikeReturnTypeHints = false,
								includeInlayEnumMemberValueHints = false,
							},
						},
						javascript = {
							inlayHints = {
								includeInlayParameterNameHints = "literals",
								includeInlayParameterNameHintsWhenArgumentMatchesName = false,
								includeInlayFunctionParameterTypeHints = false,
								includeInlayVariableTypeHints = false,
								includeInlayVariableTypeHintsWhenTypeMatchesName = false,
								includeInlayPropertyDeclarationTypeHints = false,
								includeInlayFunctionLikeReturnTypeHints = false,
								includeInlayEnumMemberValueHints = false,
							},
						},
					},
				},

				pyright = {
					settings = {
						python = {
							analysis = {
								autoSearchPaths = true,
								useLibraryCodeForTypes = true,
							},
						},
					},
				},

				html = {},
				cssls = {},
				jsonls = {},
				yamlls = {},
				clangd = {},
				rust_analyzer = {},
				tailwindcss = {},
				bashls = {},
				emmet_ls = {},
				gopls = {},
			},
		},
	},
}
