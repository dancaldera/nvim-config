-- ============================================================================
-- Development Tools
-- TODO comments and terminal integration
-- ============================================================================

return {
	-- TODO comments highlighting
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			signs = true,
			sign_priority = 8,
			keywords = {
				FIX = {
					icon = " ",
					color = "error",
					alt = { "FIXME", "BUG", "FIXIT", "ISSUE" },
				},
				TODO = { icon = " ", color = "info" },
				HACK = { icon = " ", color = "warning" },
				WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
				PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
				NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
				TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
			},
			merge_keywords = true,
			highlight = {
				multiline = true,
				multiline_pattern = "^.",
				multiline_context = 10,
				before = "",
				keyword = "wide",
				after = "fg",
				pattern = [[.*<(KEYWORDS)\s*:]],
				comments_only = true,
				max_line_len = 400,
				exclude = {},
			},
			colors = {
				error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
				warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
				info = { "DiagnosticInfo", "#2563EB" },
				hint = { "DiagnosticHint", "#10B981" },
				default = { "Identifier", "#7C3AED" },
				test = { "Identifier", "#FF00FF" },
			},
			search = {
				command = "rg",
				args = {
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
				},
				pattern = [[\b(KEYWORDS):]],
			},
		},
		keys = {
			{
				"]t",
				function()
					require("todo-comments").jump_next()
				end,
				desc = "Next todo comment",
			},
			{
				"[t",
				function()
					require("todo-comments").jump_prev()
				end,
				desc = "Previous todo comment",
			},
			{ "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Find todos" },
		},
	},

	-- Modern terminal with natural keybindings
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			-- Enable notifier (required for terminal error messages)
			notifier = {
				enabled = true,
			},
			-- Disable indent guides
			indent = {
				enabled = false,
			},
			terminal = {
				win = {
					style = "terminal",
					position = "float",
				},
			},
			dashboard = {
				enabled = true,
				preset = {
					header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
					keys = {
						{ icon = " ", key = "f", desc = "Find File", action = ":Telescope find_files" },
						{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
						{ icon = " ", key = "r", desc = "Recent Files", action = ":Telescope oldfiles" },
						{ icon = " ", key = "g", desc = "Find Text", action = ":Telescope live_grep" },
						{
							icon = " ",
							key = "s",
							desc = "Restore Session",
							action = ':lua require("persistence").load()',
						},
						{ icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
						{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
					},
				},
				sections = {
					{ section = "header" },
					{ section = "keys", gap = 1, padding = 1 },
					{
						section = "terminal",
						cmd = "echo '⚡ Neovim loaded plugins'; sleep 0.1",
						height = 1,
						padding = 1,
					},
				},
			},
			-- Explicitly disable image module (basic features only via external tools)
			image = {
				enabled = false,
			},
		},
		config = function(_, opts)
			require("snacks").setup(opts)

			-- Suppress terminal exit code error notifications
			local snacks_notify = require("snacks.notifier").notify
			require("snacks.notifier").notify = function(msg, level, notify_opts)
				-- Suppress terminal exit errors
				if type(msg) == "string" and msg:match("Terminal exited with code") then
					return
				end
				return snacks_notify(msg, level, notify_opts)
			end

			-- Auto-close terminal on any exit (including non-zero codes)
			-- But skip persistent terminals (marked with buffer-local flag)
			vim.api.nvim_create_autocmd("TermClose", {
				group = vim.api.nvim_create_augroup("snacks_terminal_autoclose", { clear = true }),
				callback = function(event)
					local buf = event.buf

					-- Check if terminal should persist
					local persist = vim.b[buf].snacks_terminal_persist
					if persist then
						return -- Don't delete persistent terminals
					end

					-- Auto-close ephemeral terminals
					if vim.bo[buf].filetype == "snacks_terminal" or vim.bo[buf].buftype == "terminal" then
						vim.schedule(function()
							if vim.api.nvim_buf_is_valid(buf) then
								vim.api.nvim_buf_delete(buf, { force = true })
							end
						end)
					end
				end,
			})
		end,

		-- ========================================================================
		-- Terminal Instance Tracking for CLI Tools
		-- ========================================================================
		init = function()
			-- Terminal instance tracking table
			_G.cli_terminals = {}

			-- Helper function to toggle named terminal with persistence
			_G.toggle_cli_terminal = function(name, cmd, opts)
				opts = opts or {}
				opts.win = opts.win or {
					position = "float",
					width = 0.9,
					height = 0.85,
					border = "rounded",
				}

				-- Create unique ID for this terminal
				local term_id = "cli_tool_" .. name

				-- Check if terminal already exists and is valid
				if _G.cli_terminals[term_id] then
					local term = _G.cli_terminals[term_id]
					if term.buf and vim.api.nvim_buf_is_valid(term.buf) then
						-- Terminal exists, toggle its window
						term:toggle()
						return term
					else
						-- Buffer was deleted, clean up reference
						_G.cli_terminals[term_id] = nil
					end
				end

				-- Create new terminal
				local term = require("snacks").terminal(cmd, opts)

				-- Mark buffer as persistent
				if term and term.buf then
					vim.api.nvim_buf_set_var(term.buf, "snacks_terminal_persist", true)
					_G.cli_terminals[term_id] = term
				end

				return term
			end
		end,

		keys = {
			-- Main toggle (count-aware: 1<leader>tt, 2<leader>tt, etc.)
			{
				"<leader>tt",
				function()
					require("snacks").terminal.toggle()
				end,
				desc = "Toggle Terminal",
				mode = { "n", "t" },
			},
			{
				"<C-\\>",
				function()
					require("snacks").terminal.toggle()
				end,
				desc = "Toggle Terminal",
				mode = { "n", "t" },
			},
			-- Different positions
			{
				"<leader>tf",
				function()
					require("snacks").terminal.toggle(nil, { win = { position = "float" } })
				end,
				desc = "Terminal (float)",
			},
			{
				"<leader>th",
				function()
					require("snacks").terminal.toggle(nil, { win = { position = "bottom", height = 0.4 } })
				end,
				desc = "Terminal (horizontal)",
			},
			{
				"<leader>tv",
				function()
					require("snacks").terminal.toggle(nil, { win = { position = "right", width = 0.4 } })
				end,
				desc = "Terminal (vertical)",
			},
			-- Run custom commands
			{
				"<leader>tc",
				function()
					vim.ui.input({ prompt = "Command: " }, function(cmd)
						if cmd then
							require("snacks").terminal(cmd, { win = { position = "float" } })
						end
					end)
				end,
				desc = "Terminal (custom command)",
			},
			-- Kill current terminal (don't reopen)
			{
				"<leader>tk",
				function()
					local buf = vim.api.nvim_get_current_buf()
					if vim.bo[buf].buftype == "terminal" then
						-- Get the terminal job ID and stop it properly
						local job_id = vim.b[buf].terminal_job_id
						if job_id then
							vim.fn.jobstop(job_id) -- Sends SIGTERM, then SIGKILL if needed
						end

						-- Close window
						local win = vim.api.nvim_get_current_win()
						if vim.api.nvim_win_is_valid(win) then
							vim.api.nvim_win_close(win, true)
						end

						-- Buffer will auto-delete via TermClose autocmd
					end
				end,
				desc = "Kill terminal",
				mode = { "n", "t" },
			},
			-- Lazygit
			{
				"<leader>lg",
				function()
					require("snacks").lazygit()
				end,
				desc = "Lazygit",
			},
			-- AI & Tools Openers (Persistent Toggles)
			{
				"<leader>lc",
				function()
					toggle_cli_terminal("claude", "claude")
				end,
				desc = "Toggle Claude",
			},
			{
				"<leader>lG",
				function()
					toggle_cli_terminal("gemini", "gemini")
				end,
				desc = "Toggle Gemini",
			},
			{
				"<leader>lx",
				function()
					toggle_cli_terminal("codex", "codex")
				end,
				desc = "Toggle Codex",
			},
			{
				"<leader>lo",
				function()
					toggle_cli_terminal("opencode", "opencode")
				end,
				desc = "Toggle Opencode",
			},
			{
				"<leader>la",
				function()
					toggle_cli_terminal("copilot", "copilot")
				end,
				desc = "Toggle Copilot CLI",
			},
			-- Terminal Management
			{
				"<leader>lK",
				function()
					local count = 0
					for name, term in pairs(_G.cli_terminals) do
						if term and term.buf and vim.api.nvim_buf_is_valid(term.buf) then
							vim.api.nvim_buf_delete(term.buf, { force = true })
							count = count + 1
						end
						_G.cli_terminals[name] = nil
					end
					vim.notify(
						string.format("Closed %d CLI tool terminal%s", count, count ~= 1 and "s" or ""),
						vim.log.levels.INFO
					)
				end,
				desc = "Kill all CLI tools",
			},
			{
				"<leader>ll",
				function()
					local active = {}
					for name, term in pairs(_G.cli_terminals) do
						if term and term.buf and vim.api.nvim_buf_is_valid(term.buf) then
							table.insert(active, name:gsub("^cli_tool_", ""))
						end
					end

					if #active > 0 then
						vim.notify("Active CLI tools: " .. table.concat(active, ", "), vim.log.levels.INFO)
					else
						vim.notify("No active CLI tool terminals", vim.log.levels.INFO)
					end
				end,
				desc = "List active CLI tools",
			},
		},
	},

	-- Note: Trouble.nvim is configured in lua/plugins/enhanced-diagnostics.lua
}
