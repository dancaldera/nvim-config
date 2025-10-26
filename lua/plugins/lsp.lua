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
	},
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
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

			-- Enhanced error handling for LSP
			local function setup_lsp_error_handling()
				vim.api.nvim_create_autocmd("LspDetach", {
					group = vim.api.nvim_create_augroup("LspDetach", { clear = true }),
					callback = function(ev)
						local client_name = ev.data.client_id and vim.lsp.get_client_by_id(ev.data.client_id).name
							or "Unknown"
						vim.notify(
							string.format("LSP client '%s' detached from buffer %d", client_name, ev.buf),
							vim.log.levels.WARN
						)
					end,
				})

				-- Handle LSP startup failures
				vim.api.nvim_create_autocmd("LspAttach", {
					group = vim.api.nvim_create_augroup("LspStartupCheck", { clear = true }),
					callback = function(ev)
						local client = vim.lsp.get_client_by_id(ev.data.client_id)
						if not client then
							vim.notify("Failed to attach LSP client", vim.log.levels.ERROR)
							return
						end

						-- Check if server is actually initialized
						vim.defer_fn(function()
							if not client.initialized then
								vim.notify(
									string.format("LSP server '%s' failed to initialize properly", client.name),
									vim.log.levels.ERROR
								)
							end
						end, 2000)
					end,
				})
			end

			-- Initialize error handling
			setup_lsp_error_handling()

			-- Suppress deprecation warning (will migrate when lspconfig v3.0.0 is released)
			local notify = vim.notify
			vim.notify = function(msg, ...)
				if msg:match("lspconfig.*deprecated") then
					return
				end
				notify(msg, ...)
			end

			-- Configure individual servers using new Neovim 0.11+ API
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
					on_init = function(client, _)
						vim.notify(string.format("✓ LSP server '%s' initialized", client.name), vim.log.levels.INFO)
					end,
					on_exit = function(code, signal, client_id)
						local client = vim.lsp.get_client_by_id(client_id)
						if client then
							vim.notify(
								string.format(
									"LSP server '%s' exited (code: %d, signal: %s)",
									client.name,
									code,
									signal or "none"
								),
								vim.log.levels.WARN
							)
						end
					end,
				}, config)

				-- Add error handling for server setup using new API
				local ok, err = pcall(function()
					vim.lsp.config(server, final_config)
					vim.lsp.enable(server)
				end)

				if not ok then
					vim.notify(string.format("Failed to setup LSP server '%s': %s", server, err), vim.log.levels.ERROR)
				end
			end

			-- Restore original notify
			vim.notify = notify
		end,
	},
}
