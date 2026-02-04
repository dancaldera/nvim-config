-- ============================================================================
-- Core LSP Configuration
-- Mason setup, LSP keymaps, inlay hints, and error handling
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
					-- Formatters & Linters
					"prettier", -- Multi-language formatter
					"stylua", -- Lua formatter
					"eslint_d", -- JS/TS linter
					"shfmt", -- Shell formatter
					"ruff", -- Python linter/formatter
					"isort", -- Python import sorter
					"black", -- Python formatter
					"golangci-lint", -- Go linter
				},
				auto_update = false,
				run_on_start = false,
			})
		end,
	},

	-- LSP Configuration
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

					-- Note: Signature help is provided by lsp_signature.nvim plugin
					-- Note: Diagnostic keymaps are in lua/plugins/enhanced-diagnostics.lua

					-- Inlay Hints Toggle
					-- Cycles through: none -> minimal -> moderate -> complete
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
