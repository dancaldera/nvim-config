-- ============================================================================
-- Diagnostics Configuration (Trouble.nvim)
-- ============================================================================

return {
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		cmd = "Trouble",
		opts = {
			use_diagnostic_signs = true,
			preview = {
				type = "split",
				relative = "win",
				position = "right",
				size = 0.3,
			},
			mode = "diagnostics",
			focus = false,
			follow = true,
			restore = true,
			win = { size = { height = 0.3 } },
		},
		keys = {
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
			{ "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics" },
			{ "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
			{
				"<leader>xl",
				"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
				desc = "LSP Definitions/References",
			},
			{ "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List" },
			{ "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List" },
			{
				"<leader>xc",
				function()
					local diagnostics = vim.diagnostic.get(nil, {
						severity = {
							vim.diagnostic.severity.ERROR,
							vim.diagnostic.severity.WARN,
							vim.diagnostic.severity.INFO,
							vim.diagnostic.severity.HINT,
						},
					})

					if #diagnostics == 0 then
						vim.notify("No diagnostics found", vim.log.levels.INFO)
						return
					end

					local severity_map = {
						[vim.diagnostic.severity.ERROR] = "ERROR",
						[vim.diagnostic.severity.WARN] = "WARN",
						[vim.diagnostic.severity.INFO] = "INFO",
						[vim.diagnostic.severity.HINT] = "HINT",
					}

					local formatted = {}
					for _, diag in ipairs(diagnostics) do
						local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(diag.bufnr), ":~:.")
						local line = diag.lnum + 1
						local col = diag.col + 1
						local severity = severity_map[diag.severity] or "UNKNOWN"
						local message = diag.message:gsub("\n", " ")
						table.insert(
							formatted,
							string.format("%s:%d:%d [%s] %s", filename, line, col, severity, message)
						)
					end

					vim.fn.setreg("+", table.concat(formatted, "\n"))
					vim.notify(string.format("Copied %d diagnostics to clipboard", #diagnostics), vim.log.levels.INFO)
				end,
				desc = "Copy diagnostics to clipboard",
			},
			{ "<leader>de", "<cmd>Trouble diagnostics toggle filter.severity=ERROR<cr>", desc = "Errors only" },
			{ "<leader>dw", "<cmd>Trouble diagnostics toggle filter.severity=WARN<cr>", desc = "Warnings only" },
		},
		config = function(_, opts)
			require("trouble").setup(opts)

			-- Diagnostic navigation with severity filtering
			local function diagnostic_goto(next, severity)
				local severity_map = {
					ERROR = vim.diagnostic.severity.ERROR,
					WARN = vim.diagnostic.severity.WARN,
				}
				local count = next and 1 or -1
				vim.diagnostic.jump({ count = count, severity = severity_map[severity] })
			end

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

			-- Enhanced diagnostic float
			vim.keymap.set("n", "<leader>d", function()
				vim.diagnostic.open_float(nil, {
					scope = "line",
					border = "rounded",
					focusable = true,
					source = true,
					header = "",
					prefix = "",
				})
			end, { desc = "Show line diagnostics" })
		end,
	},
}
