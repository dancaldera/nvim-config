-- ============================================================================
-- Modern LSP Configuration for Neovim 0.12.x
-- ============================================================================

return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
		},
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"ts_ls", -- TypeScript/JavaScript (updated name)
					"html", -- HTML
					"cssls", -- CSS
					"tailwindcss", -- Tailwind CSS
					"lua_ls", -- Lua
					"emmet_ls", -- Emmet
					"pyright", -- Python
					"gopls", -- Go
					"clangd", -- C/C++
					"rust_analyzer", -- Rust
					"jsonls", -- JSON
					"yamlls", -- YAML
					"bashls", -- Bash
				},
				automatic_installation = true,
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			{ "antosha417/nvim-lsp-file-operations", config = true },
			{ "folke/neodev.nvim", opts = {} }, -- Better Lua LSP for Neovim config
		},
		config = function()
			local cmp_nvim_lsp = require("cmp_nvim_lsp")
			local keymap = vim.keymap

			-- Defer diagnostic configuration to avoid buffer issues
			vim.schedule(function()
				vim.diagnostic.config({
					signs = {
						text = {
							[vim.diagnostic.severity.ERROR] = " ",
							[vim.diagnostic.severity.WARN] = " ",
							[vim.diagnostic.severity.HINT] = "󰠠 ",
							[vim.diagnostic.severity.INFO] = " ",
						},
					},
					virtual_text = {
						spacing = 4,
						source = "if_many",
						prefix = "●",
					},
					float = {
						focusable = false,
						style = "minimal",
						border = "rounded",
						source = "always",
						header = "",
						prefix = "",
					},
					severity_sort = true,
					update_in_insert = false,
				})
			end)

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					local opts = { buffer = ev.buf, silent = true }
					local client = vim.lsp.get_client_by_id(ev.data.client_id)

					-- Enable inlay hints if supported (using new API)
					if client and client:supports_method("textDocument/inlayHint") then
						vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
					end

					opts.desc = "Show LSP references"
					keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

					opts.desc = "Go to declaration"
					keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

					opts.desc = "Show LSP definitions"
					keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

					opts.desc = "Show LSP implementations"
					keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

					opts.desc = "Show LSP type definitions"
					keymap.set("n", "gy", "<cmd>Telescope lsp_type_definitions<CR>", opts)

					opts.desc = "See available code actions"
					keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

					opts.desc = "Smart rename"
					keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

					opts.desc = "Show buffer diagnostics"
					keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

					opts.desc = "Show line diagnostics"
					keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

					opts.desc = "Go to previous diagnostic"
					keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

					opts.desc = "Go to next diagnostic"
					keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

					opts.desc = "Show documentation for what is under cursor"
					keymap.set("n", "K", vim.lsp.buf.hover, opts)

					opts.desc = "Toggle inlay hints"
					keymap.set("n", "<leader>th", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
					end, opts)

					opts.desc = "Restart LSP"
					keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
				end,
			})

			local capabilities = cmp_nvim_lsp.default_capabilities()

			-- Enable folding capability for nvim-ufo
			capabilities.textDocument.foldingRange = {
				dynamicRegistration = false,
				lineFoldingOnly = true,
			}

			-- Suppress deprecation warning (will migrate when lspconfig v3.0.0 is released)
			local notify = vim.notify
			vim.notify = function(msg, ...)
				if msg:match("lspconfig.*deprecated") then
					return
				end
				notify(msg, ...)
			end

			-- Configure individual servers
			local lspconfig = require("lspconfig")

			local servers = {
				ts_ls = {},
				html = {},
				cssls = {},
				tailwindcss = {},
				emmet_ls = {},
				pyright = {},
				gopls = {},
				clangd = {},
				rust_analyzer = {},
				jsonls = {},
				yamlls = {},
				bashls = {},
				lua_ls = {
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
				},
			}

			for server, config in pairs(servers) do
				local final_config = vim.tbl_deep_extend("force", {
					capabilities = capabilities,
				}, config)
				lspconfig[server].setup(final_config)
			end

			-- Restore original notify
			vim.notify = notify
		end,
	},
}
