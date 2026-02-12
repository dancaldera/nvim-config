-- ============================================================================
-- Development Tools (snacks, todo-comments, projects, terminals)
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

	-- Snacks.nvim (dashboard, terminal, notifier)
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			notifier = { enabled = false },
			indent = { enabled = false },
			image = { enabled = false },
			terminal = {
				win = { style = "terminal", position = "float" },
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
						{ icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
						{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
					},
				},
				sections = {
					{ section = "header" },
					{ section = "keys", gap = 1, padding = 1 },
				},
			},
		},
		config = function(_, opts)
			local snacks = require("snacks")
			snacks.setup(opts)

			-- Auto-close non-persistent terminals
			vim.api.nvim_create_autocmd("TermClose", {
				group = vim.api.nvim_create_augroup("snacks_terminal_autoclose", { clear = true }),
				callback = function(event)
					local buf = event.buf
					if vim.b[buf].snacks_terminal_persist then
						return
					end
					if vim.bo[buf].buftype == "terminal" then
						vim.schedule(function()
							if vim.api.nvim_buf_is_valid(buf) then
								vim.api.nvim_buf_delete(buf, { force = true })
							end
						end)
					end
				end,
			})
		end,

		-- Terminal instance tracking for CLI tools
		init = function()
			_G.cli_terminals = {}

			_G.toggle_cli_terminal = function(name, cmd, opts)
				opts = opts or {}
				opts.win = opts.win
					or {
						position = "float",
						width = 0.9,
						height = 0.85,
						border = "rounded",
					}

				local term_id = "cli_tool_" .. name

				if _G.cli_terminals[term_id] then
					local term = _G.cli_terminals[term_id]
					if term.buf and vim.api.nvim_buf_is_valid(term.buf) then
						term:toggle()
						return term
					else
						_G.cli_terminals[term_id] = nil
					end
				end

				local term = require("snacks").terminal(cmd, opts)
				if term and term.buf then
					vim.api.nvim_buf_set_var(term.buf, "snacks_terminal_persist", true)
					_G.cli_terminals[term_id] = term
				end
				return term
			end
		end,

		keys = {
			-- Terminal toggles
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
			{
				"<leader>tk",
				function()
					local buf = vim.api.nvim_get_current_buf()
					if vim.bo[buf].buftype == "terminal" then
						local job_id = vim.b[buf].terminal_job_id
						if job_id then
							vim.fn.jobstop(job_id)
						end
						local win = vim.api.nvim_get_current_win()
						if vim.api.nvim_win_is_valid(win) then
							vim.api.nvim_win_close(win, true)
						end
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

			-- AI & CLI tool terminals
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

			-- GitHub account management
			{
				"<leader>ga",
				function()
					require("config.github").switch_account()
				end,
				desc = "Select GitHub account",
			},
			{
				"<leader>gS",
				function()
					require("config.github").quick_status()
				end,
				desc = "Quick GitHub status",
			},
			{
				"<leader>gt",
				function()
					require("config.openai").test_api_key()
				end,
				desc = "Test OpenAI API key",
			},
		},
	},

	-- Project management
	{
		"ahmedkhalf/project.nvim",
		event = "VeryLazy",
		opts = {
			detection_methods = { "pattern" },
			patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json", "go.mod" },
			silent_chdir = true,
			scope_chdir = "global",
		},
		config = function(_, opts)
			require("project_nvim").setup(opts)
			require("telescope").load_extension("projects")
		end,
		keys = {
			{ "<leader>fp", "<cmd>Telescope projects<cr>", desc = "Find projects" },
		},
	},
}
