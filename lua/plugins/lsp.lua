-- ============================================================================
-- LSP Configuration (Mason + Servers + Keymaps)
-- ============================================================================

return {
	-- Mason - LSP/formatter/linter manager
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
					"prettier",
					"stylua",
					"eslint_d",
					"shfmt",
					"ruff",
					"isort",
					"black",
					"golangci-lint",
				},
				auto_update = false,
				run_on_start = false,
			})
		end,
	},

	-- LSP Configuration + Keymaps
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
					keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

					opts.desc = "Go to declaration"
					keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

					opts.desc = "Show LSP definitions"
					keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

					opts.desc = "Show LSP implementations"
					keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

					opts.desc = "Show LSP type definitions"
					keymap.set("n", "gy", "<cmd>Telescope lsp_type_definitions<CR>", opts)

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
						{ name = "minimal", params = "literals", types = false, vars = false, returns = false, enums = false },
						{ name = "moderate", params = "all", types = false, vars = false, returns = true, enums = true },
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
		dependencies = {
			"williamboman/mason.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			if not (vim.lsp and vim.lsp.config) then
				vim.notify(
					"Neovim 0.11+ is required for vim.lsp.config-based setup. Upgrade to enable LSP servers.",
					vim.log.levels.ERROR
				)
				return
			end

			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			capabilities.textDocument.foldingRange = {
				dynamicRegistration = false,
				lineFoldingOnly = true,
			}

			-- Servers with default config (capabilities only)
			local simple_servers = {
				"html", "cssls", "jsonls", "yamlls", "gopls",
				"clangd", "rust_analyzer", "tailwindcss", "bashls", "emmet_ls",
			}

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

			-- Python (with venv detection)
			vim.lsp.config("pyright", {
				capabilities = capabilities,
				before_init = function(_, config)
					local python_path = nil

					-- Try swenv first
					local ok, swenv_api = pcall(require, "swenv.api")
					if ok then
						local venv = swenv_api.get_current_venv()
						if venv and venv.path then
							local bin = venv.path .. "/bin/python"
							if vim.fn.executable(bin) == 1 then
								python_path = bin
							end
						end
					end

					-- Fallback: check common local venv paths
					if not python_path then
						local cwd = config.root_dir or vim.fn.getcwd()
						for _, name in ipairs({ ".venv", "venv", ".env" }) do
							local bin = cwd .. "/" .. name .. "/bin/python"
							if vim.fn.executable(bin) == 1 then
								python_path = bin
								break
							end
						end
					end

					if python_path then
						config.settings = config.settings or {}
						config.settings.python = config.settings.python or {}
						config.settings.python.pythonPath = python_path
					end
				end,
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
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls", "ts_ls", "html", "cssls", "jsonls", "yamlls",
					"pyright", "gopls", "clangd", "rust_analyzer",
					"tailwindcss", "bashls", "emmet_ls",
				},
				automatic_installation = true,
			})
		end,
	},
}
