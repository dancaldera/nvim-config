-- ============================================================================
-- LSP Configuration (native vim.lsp API + blink.cmp capabilities)
-- ============================================================================

-- Servers enabled when their executable is found on PATH (see README for the
-- brew/npm install list). Missing servers are skipped silently.
local servers = {
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
	"gopls",
}

return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"saghen/blink.cmp",
			{
				"folke/lazydev.nvim",
				ft = "lua",
				opts = {
					library = {
						{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
					},
				},
			},
		},
		config = function()
			local keymap = vim.keymap

			-- Keymaps on LSP attach
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
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

					opts.desc = "Toggle inlay hints"
					keymap.set("n", "<leader>ti", function()
						local bufnr = ev.buf
						vim.lsp.inlay_hint.enable(
							not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }),
							{ bufnr = bufnr }
						)
					end, opts)

					opts.desc = "Restart LSP"
					keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
				end,
			})

			local capabilities = require("blink.cmp").get_lsp_capabilities()
			vim.lsp.config("*", { capabilities = capabilities })

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

			-- TypeScript/JavaScript (parameter-name inlay hints for literals only)
			local ts_inlay_hints = {
				includeInlayParameterNameHints = "literals",
				includeInlayParameterNameHintsWhenArgumentMatchesName = false,
				includeInlayFunctionParameterTypeHints = false,
				includeInlayVariableTypeHints = false,
				includeInlayVariableTypeHintsWhenTypeMatchesName = false,
				includeInlayPropertyDeclarationTypeHints = false,
				includeInlayFunctionLikeReturnTypeHints = false,
				includeInlayEnumMemberValueHints = false,
			}
			vim.lsp.config("ts_ls", {
				capabilities = capabilities,
				settings = {
					typescript = { inlayHints = ts_inlay_hints },
					javascript = { inlayHints = ts_inlay_hints },
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

			-- Enable the servers that are actually installed
			for _, server in ipairs(servers) do
				local cmd = vim.lsp.config[server].cmd
				if type(cmd) == "table" and vim.fn.executable(cmd[1]) == 1 then
					vim.lsp.enable(server)
				end
			end
		end,
	},
}
