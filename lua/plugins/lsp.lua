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
				on_init = function(client, _)
					vim.notify(string.format("✓ LSP server '%s' initialized", client.name), vim.log.levels.INFO)
				end,
			})

			-- TypeScript/JavaScript
			vim.lsp.config("ts_ls", {
				capabilities = capabilities,
				on_init = function(client, _)
					vim.notify(string.format("✓ LSP server '%s' initialized", client.name), vim.log.levels.INFO)
				end,
			})

			-- HTML
			vim.lsp.config("html", {
				capabilities = capabilities,
				on_init = function(client, _)
					vim.notify(string.format("✓ LSP server '%s' initialized", client.name), vim.log.levels.INFO)
				end,
			})

			-- CSS
			vim.lsp.config("cssls", {
				capabilities = capabilities,
				on_init = function(client, _)
					vim.notify(string.format("✓ LSP server '%s' initialized", client.name), vim.log.levels.INFO)
				end,
			})

			-- JSON
			vim.lsp.config("jsonls", {
				capabilities = capabilities,
				on_init = function(client, _)
					vim.notify(string.format("✓ LSP server '%s' initialized", client.name), vim.log.levels.INFO)
				end,
			})

			-- YAML
			vim.lsp.config("yamlls", {
				capabilities = capabilities,
				on_init = function(client, _)
					vim.notify(string.format("✓ LSP server '%s' initialized", client.name), vim.log.levels.INFO)
				end,
			})

			-- Python
			vim.lsp.config("pyright", {
				capabilities = capabilities,
				on_init = function(client, _)
					vim.notify(string.format("✓ LSP server '%s' initialized", client.name), vim.log.levels.INFO)
				end,
			})

			-- Go
			vim.lsp.config("gopls", {
				capabilities = capabilities,
				on_init = function(client, _)
					vim.notify(string.format("✓ LSP server '%s' initialized", client.name), vim.log.levels.INFO)
				end,
			})

			-- C/C++
			vim.lsp.config("clangd", {
				capabilities = capabilities,
				on_init = function(client, _)
					vim.notify(string.format("✓ LSP server '%s' initialized", client.name), vim.log.levels.INFO)
				end,
			})

			-- Rust
			vim.lsp.config("rust_analyzer", {
				capabilities = capabilities,
				on_init = function(client, _)
					vim.notify(string.format("✓ LSP server '%s' initialized", client.name), vim.log.levels.INFO)
				end,
			})

			-- Tailwind CSS
			vim.lsp.config("tailwindcss", {
				capabilities = capabilities,
				on_init = function(client, _)
					vim.notify(string.format("✓ LSP server '%s' initialized", client.name), vim.log.levels.INFO)
				end,
			})

			-- Bash
			vim.lsp.config("bashls", {
				capabilities = capabilities,
				on_init = function(client, _)
					vim.notify(string.format("✓ LSP server '%s' initialized", client.name), vim.log.levels.INFO)
				end,
			})

			-- Emmet
			vim.lsp.config("emmet_ls", {
				capabilities = capabilities,
				on_init = function(client, _)
					vim.notify(string.format("✓ LSP server '%s' initialized", client.name), vim.log.levels.INFO)
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
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			{ "antosha417/nvim-lsp-file-operations", config = true },
			{ "folke/neodev.nvim", opts = {} }, -- Better Lua LSP for Neovim config
		},
		config = function()
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

			-- Keymaps on LSP attach
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
		end,
	},
}
