-- ============================================================================
-- Modern LSP Configuration for Neovim 0.12.x
-- ============================================================================

return {
	{
		"williamboman/mason.nvim",
		dependencies = {
			"WhoIsSethDaniel/mason-tool-installer.nvim",
		},
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

			require("mason-tool-installer").setup({
				ensure_installed = {
					-- Formatters & Linters
					"prettier", -- Multi-language formatter
					"stylua", -- Lua formatter
					"eslint_d", -- JS/TS linter (FIX: ensures this is installed)
					"shfmt", -- Shell formatter
					"ruff", -- Python linter/formatter
					"isort", -- Python import sorter
					"black", -- Python formatter
					"golangci-lint", -- Go linter
				},
				auto_update = true,
				run_on_start = true,
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
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			{ "antosha417/nvim-lsp-file-operations", config = true },
			{
				"folke/lazydev.nvim",
				ft = "lua",
				opts = {
					library = {
						{ path = "luvit-meta/library", words = { "vim%.uv" } },
					},
				},
			},
			{ "Bilal2453/luvit-meta", lazy = true },
		},
		config = function()
			local keymap = vim.keymap

			-- Note: Diagnostic configuration is in lua/plugins/enhanced-diagnostics.lua

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

					-- Note: Diagnostic keymaps are in lua/plugins/enhanced-diagnostics.lua

					opts.desc = "Show documentation for what is under cursor"
					keymap.set("n", "K", vim.lsp.buf.hover, opts)

					opts.desc = "Show signature help"
					keymap.set("i", "<C-s>", vim.lsp.buf.signature_help, opts)

					-- Inlay hints cycle: none -> minimal -> moderate -> complete
					local inlay_hint_levels = {
						{ name = "none", params = "none", types = false, vars = false, returns = false, enums = false },
						{
							name = "minimal",
							params = "literals",
							types = false,
							vars = false,
							returns = false,
							enums = false,
						},
						{
							name = "moderate",
							params = "all",
							types = false,
							vars = false,
							returns = true,
							enums = true,
						},
						{ name = "complete", params = "all", types = true, vars = true, returns = true, enums = true },
					}
					vim.b.inlay_hint_level = vim.b.inlay_hint_level or 2 -- default: minimal

					local function set_inlay_hints(level)
						local cfg = inlay_hint_levels[level]
						local clients = vim.lsp.get_clients({ bufnr = 0 })
						for _, c in ipairs(clients) do
							if c.name == "ts_ls" then
								---@diagnostic disable-next-line: inject-field
								c.settings = c.settings or {}
								for _, lang in ipairs({ "typescript", "javascript" }) do
									---@diagnostic disable-next-line: inject-field
									c.settings[lang] = c.settings[lang] or {}
									---@diagnostic disable-next-line: inject-field
									c.settings[lang].inlayHints = {
										includeInlayParameterNameHints = cfg.params,
										includeInlayParameterNameHintsWhenArgumentMatchesName = false,
										includeInlayFunctionParameterTypeHints = cfg.types,
										includeInlayVariableTypeHints = cfg.vars,
										includeInlayVariableTypeHintsWhenTypeMatchesName = false,
										includeInlayPropertyDeclarationTypeHints = cfg.vars,
										includeInlayFunctionLikeReturnTypeHints = cfg.returns,
										includeInlayEnumMemberValueHints = cfg.enums,
									}
								end
								c:notify("workspace/didChangeConfiguration", { settings = c.settings })
							end
						end
						if cfg.params == "none" then
							vim.lsp.inlay_hint.enable(false, { bufnr = 0 })
						else
							vim.lsp.inlay_hint.enable(true, { bufnr = 0 })
						end
						vim.notify("Inlay hints: " .. cfg.name, vim.log.levels.INFO)
					end

					opts.desc = "Cycle inlay hints (none/minimal/moderate/complete)"
					keymap.set("n", "<leader>ti", function()
						vim.b.inlay_hint_level = (vim.b.inlay_hint_level % 4) + 1
						set_inlay_hints(vim.b.inlay_hint_level)
					end, opts)

					opts.desc = "Restart LSP"
					keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
				end,
			})

			-- Enhanced error handling for LSP
			local function setup_lsp_error_handling()
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
