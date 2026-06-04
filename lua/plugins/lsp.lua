-- ============================================================================
-- LSP Configuration (Mason + Servers + Keymaps)
-- ============================================================================

return {
	-- Mason - LSP/formatter/linter manager
	{
		"williamboman/mason.nvim",
		cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate", "MasonLog" },
		dependencies = {
			"WhoIsSethDaniel/mason-tool-installer.nvim",
		},
		config = function()
			local mason_tools = {
				"prettier",
				"stylua",
				"shfmt",
				"ruff",
			}

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
				ensure_installed = mason_tools,
				auto_update = false,
				run_on_start = false,
			})
		end,
	},

	-- LSP Configuration + Keymaps
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"saghen/blink.cmp",
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
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

			-- Keymaps on LSP attach
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					local opts = { buffer = ev.buf, silent = true }
					local client = vim.lsp.get_client_by_id(ev.data.client_id)

					-- Enable inlay hints if supported
					if client and client:supports_method("textDocument/inlayHint") then
						vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
					end

					-- LSP Navigation
					opts.desc = "Show LSP references"
					keymap.set("n", "gR", function()
						Snacks.picker.lsp_references()
					end, opts)

					opts.desc = "Go to declaration"
					keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

					opts.desc = "Show LSP definitions"
					keymap.set("n", "gd", function()
						Snacks.picker.lsp_definitions()
					end, opts)

					opts.desc = "Show LSP implementations"
					keymap.set("n", "gi", function()
						Snacks.picker.lsp_implementations()
					end, opts)

					opts.desc = "Show LSP type definitions"
					keymap.set("n", "gy", function()
						Snacks.picker.lsp_type_definitions()
					end, opts)

					-- LSP Actions
					opts.desc = "See available code actions"
					keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

					opts.desc = "Smart rename"
					keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

					-- LSP Documentation
					opts.desc = "Show documentation for what is under cursor"
					keymap.set("n", "K", vim.lsp.buf.hover, opts)

					-- Inlay Hints Toggle (cycles: none -> minimal -> moderate -> complete)
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
					vim.b.inlay_hint_level = vim.b.inlay_hint_level or 2

					local function set_inlay_hints(level)
						local cfg = inlay_hint_levels[level]
						local clients = vim.lsp.get_clients({ bufnr = 0 })
						for _, c in ipairs(clients) do
							if c.name == "ts_ls" then
								c.settings = c.settings or {}
								for _, lang in ipairs({ "typescript", "javascript" }) do
									c.settings[lang] = c.settings[lang] or {}
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
		end,
	},

	-- LSP Server Configurations (Neovim 0.11+ native API)
	{
		"williamboman/mason-lspconfig.nvim",
		event = { "BufReadPre", "BufNewFile" },
		cmd = { "LspInstall", "LspUninstall" },
		dependencies = {
			"williamboman/mason.nvim",
			"saghen/blink.cmp",
		},
		config = function()
			if not (vim.lsp and vim.lsp.config) then
				vim.notify(
					"Neovim 0.11+ is required for vim.lsp.config-based setup. Upgrade to enable LSP servers.",
					vim.log.levels.ERROR
				)
				return
			end

			local capabilities = require("blink.cmp").get_lsp_capabilities()
			local has_go = vim.fn.executable("go") == 1
			capabilities.textDocument.foldingRange = {
				dynamicRegistration = false,
				lineFoldingOnly = true,
			}

			-- Servers with default config (capabilities only)
			local simple_servers = {
				"html",
				"cssls",
				"jsonls",
				"yamlls",
				"clangd",
				"rust_analyzer",
				"tailwindcss",
				"bashls",
				"emmet_ls",
			}

			if has_go then
				table.insert(simple_servers, 5, "gopls")
			end

			for _, server in ipairs(simple_servers) do
				vim.lsp.config(server, { capabilities = capabilities })
			end

			-- Lua
			vim.lsp.config("lua_ls", {
				capabilities = capabilities,
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
						completion = { callSnippet = "Replace" },
					},
				},
			})

			-- TypeScript/JavaScript
			vim.lsp.config("ts_ls", {
				capabilities = capabilities,
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

			-- Python
			vim.lsp.config("pyright", {
				capabilities = capabilities,
				settings = {
					python = {
						analysis = {
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
						},
					},
				},
			})

			-- Setup mason-lspconfig (auto-enable configured servers)
			local ensure_servers = {
				"lua_ls",
				"ts_ls",
				"html",
				"cssls",
				"jsonls",
				"yamlls",
				"pyright",
				"clangd",
				"rust_analyzer",
				"tailwindcss",
				"bashls",
				"emmet_ls",
			}

			if has_go then
				table.insert(ensure_servers, 8, "gopls")
			end

			require("mason-lspconfig").setup({
				ensure_installed = ensure_servers,
				automatic_installation = true,
			})
		end,
	},
}
