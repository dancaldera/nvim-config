-- ============================================================================
-- Enhanced Diagnostics Configuration
-- ============================================================================

return {
	-- Enhanced diagnostics display with Trouble.nvim (already configured but enhanced)
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		cmd = "Trouble",
		opts = {
			use_diagnostic_signs = true,
			-- Enhanced configuration for better diagnostics display
			preview = {
				type = "split",
				relative = "win",
				position = "right",
				size = 0.3,
			},
			-- Better diagnostics grouping
			mode = "diagnostics",
			severity = vim.diagnostic.severity.HINT
				.. vim.diagnostic.severity.INFO
				.. vim.diagnostic.severity.WARN
				.. vim.diagnostic.severity.ERROR,
			focus = false,
			follow = true,
			restore = true,
			win = { size = { height = 0.3 } },
			pinned = false,
		},
		keys = {
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
			{ "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
			{ "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
			{
				"<leader>xl",
				"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
				desc = "LSP Definitions / references / ... (Trouble)",
			},
			{ "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
			{ "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
			-- Enhanced diagnostic navigation
			{ "<leader>de", "<cmd>Trouble diagnostics toggle filter.severity=ERROR<cr>", desc = "Errors only" },
			{ "<leader>dw", "<cmd>Trouble diagnostics toggle filter.severity=WARN<cr>", desc = "Warnings only" },
			{ "<leader>di", "<cmd>Trouble diagnostics toggle filter.severity=INFO<cr>", desc = "Info only" },
			{ "<leader>dh", "<cmd>Trouble diagnostics toggle filter.severity=HINT<cr>", desc = "Hints only" },
		},
		config = function(_, opts)
			require("trouble").setup(opts)

			-- Enhanced diagnostic keymaps
			local diagnostic_goto = function(next, severity)
				local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
				local severity_map = {
					ERROR = vim.diagnostic.severity.ERROR,
					WARN = vim.diagnostic.severity.WARN,
					INFO = vim.diagnostic.severity.INFO,
					HINT = vim.diagnostic.severity.HINT,
				}
				local severity_int = severity_map[severity] or nil
				go({ severity = severity_int })
			end

			-- Enhanced diagnostic navigation with severity filtering
			vim.keymap.set("n", "]e", function()
				diagnostic_goto(true, "ERROR")
			end, { desc = "Next Error" })
			vim.keymap.set("n", "[e", function()
				diagnostic_goto(false, "ERROR")
			end, { desc = "Prev Error" })
			vim.keymap.set("n", "]w", function()
				diagnostic_goto(true, "WARN")
			end, { desc = "Next Warning" })
			vim.keymap.set("n", "[w", function()
				diagnostic_goto(false, "WARN")
			end, { desc = "Prev Warning" })

			-- Enhanced diagnostic float with more context
			vim.keymap.set("n", "<leader>d", function()
				local winid = vim.diagnostic.open_float(nil, {
					scope = "line",
					border = "rounded",
					focusable = true,
					source = "always",
					header = "",
					prefix = "",
					format = function(diagnostic)
						local code = diagnostic.code and (" [%s]"):format(diagnostic.code) or ""
						local user_data = diagnostic.user_data or {}
						local lsp = user_data.lsp or {}
						local message = diagnostic.message

						-- Add file and line info
						local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(diagnostic.bufnr), ":t")
						local line_info = string.format("%s:%d", filename, diagnostic.lnum + 1)

						return string.format("%s%s\n%s", message, code, line_info)
					end,
				})

				-- Add keymaps for diagnostic float window
				if winid then
					vim.api.nvim_win_set_option(winid, "wrap", true)
					vim.api.nvim_buf_set_keymap(
						vim.api.nvim_win_get_buf(winid),
						"n",
						"q",
						"<cmd>close<cr>",
						{ noremap = true, silent = true }
					)
					vim.api.nvim_buf_set_keymap(
						vim.api.nvim_win_get_buf(winid),
						"n",
						"<Esc>",
						"<cmd>close<cr>",
						{ noremap = true, silent = true }
					)
				end
			end, { desc = "Show line diagnostics (enhanced)" })
		end,
	},

	-- Enhanced diagnostics configuration
	{
		"neovim/nvim-lspconfig",
		opts = function(_, opts)
			-- Enhanced diagnostic configuration
			vim.diagnostic.config({
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = "",
						[vim.diagnostic.severity.WARN] = "",
						[vim.diagnostic.severity.HINT] = "",
						[vim.diagnostic.severity.INFO] = "",
					},
					linehl = {
						[vim.diagnostic.severity.ERROR] = "DiagnosticLineError",
						[vim.diagnostic.severity.WARN] = "DiagnosticLineWarn",
						[vim.diagnostic.severity.HINT] = "DiagnosticLineHint",
						[vim.diagnostic.severity.INFO] = "DiagnosticLineInfo",
					},
					numhl = {
						[vim.diagnostic.severity.ERROR] = "DiagnosticNumError",
						[vim.diagnostic.severity.WARN] = "DiagnosticNumWarn",
						[vim.diagnostic.severity.HINT] = "DiagnosticNumHint",
						[vim.diagnostic.severity.INFO] = "DiagnosticNumInfo",
					},
				},
				virtual_text = {
					spacing = 4,
					source = "always",
					prefix = "●",
					format = function(diagnostic)
						local code = diagnostic.code and (" [%s]"):format(diagnostic.code) or ""
						return diagnostic.message .. code
					end,
				},
				float = {
					focusable = true,
					style = "minimal",
					border = "rounded",
					source = "always",
					header = "",
					prefix = "",
					width = 80,
					max_width = 80,
					height = nil,
					max_height = 20,
				},
				severity_sort = true,
				update_in_insert = false,
				underline = true,
			})

			-- Custom diagnostic highlights
			vim.api.nvim_set_hl(0, "DiagnosticLineError", { bg = "#3d1e1e", sp = "#f38ba8", undercurl = true })
			vim.api.nvim_set_hl(0, "DiagnosticLineWarn", { bg = "#3d2e1e", sp = "#fab387", undercurl = true })
			vim.api.nvim_set_hl(0, "DiagnosticLineInfo", { bg = "#1e2e3d", sp = "#89b4fa", undercurl = true })
			vim.api.nvim_set_hl(0, "DiagnosticLineHint", { bg = "#1e3d2e", sp = "#a6e3a1", undercurl = true })

			return opts
		end,
	},
}
