-- ============================================================================
-- LSP Server Configurations
-- Individual language server setups using Neovim 0.11+ native API
-- ============================================================================

return {
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			local cmp_nvim_lsp = require("cmp_nvim_lsp")

			-- Get capabilities from nvim-cmp for all servers
			local capabilities = cmp_nvim_lsp.default_capabilities()
			capabilities.textDocument.foldingRange = {
				dynamicRegistration = false,
				lineFoldingOnly = true,
			}

			-- Configure servers using Neovim 0.11+ native API BEFORE mason-lspconfig setup
			-- This way mason-lspconfig will automatically enable them when installed

			-- Lua Language Server
			vim.lsp.config("lua_ls", {
				capabilities = capabilities,
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
						completion = {
							callSnippet = "Replace",
						},
					},
				},
				on_init = function(_, _)
					-- Silent initialization for better UX
				end,
			})

			-- TypeScript/JavaScript
			vim.lsp.config("ts_ls", {
				capabilities = capabilities,
				on_init = function(_, _)
					-- Silent initialization for better UX
				end,
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
			})

			-- HTML
			vim.lsp.config("html", {
				capabilities = capabilities,
				on_init = function(_, _)
					-- Silent initialization for better UX
				end,
			})

			-- CSS
			vim.lsp.config("cssls", {
				capabilities = capabilities,
				on_init = function(_, _)
					-- Silent initialization for better UX
				end,
			})

			-- JSON
			vim.lsp.config("jsonls", {
				capabilities = capabilities,
				on_init = function(_, _)
					-- Silent initialization for better UX
				end,
			})

			-- YAML
			vim.lsp.config("yamlls", {
				capabilities = capabilities,
				on_init = function(_, _)
					-- Silent initialization for better UX
				end,
			})

			-- Python
			vim.lsp.config("pyright", {
				capabilities = capabilities,
				on_init = function(_, _)
					-- Silent initialization for better UX
				end,
			})

			-- Go
			vim.lsp.config("gopls", {
				capabilities = capabilities,
				on_init = function(_, _)
					-- Silent initialization for better UX
				end,
			})

			-- C/C++
			vim.lsp.config("clangd", {
				capabilities = capabilities,
				on_init = function(_, _)
					-- Silent initialization for better UX
				end,
			})

			-- Rust
			vim.lsp.config("rust_analyzer", {
				capabilities = capabilities,
				on_init = function(_, _)
					-- Silent initialization for better UX
				end,
			})

			-- Tailwind CSS
			vim.lsp.config("tailwindcss", {
				capabilities = capabilities,
				on_init = function(_, _)
					-- Silent initialization for better UX
				end,
			})

			-- Bash
			vim.lsp.config("bashls", {
				capabilities = capabilities,
				on_init = function(_, _)
					-- Silent initialization for better UX
				end,
			})

			-- Emmet
			vim.lsp.config("emmet_ls", {
				capabilities = capabilities,
				on_init = function(_, _)
					-- Silent initialization for better UX
				end,
			})

			-- Now setup mason-lspconfig - it will automatically enable configured servers
			require("mason-lspconfig").setup({
				-- List of servers to automatically install
				ensure_installed = {
					-- Required servers
					"lua_ls",
					"ts_ls",
					"html",
					"cssls",
					"jsonls",
					"yamlls",
					-- Optional but recommended servers
					"pyright",
					"gopls",
					"clangd",
					"rust_analyzer",
					"tailwindcss",
					"bashls",
					"emmet_ls",
				},
				-- Automatically install servers that are configured but not installed
				automatic_installation = true,
			})
		end,
	},
}
