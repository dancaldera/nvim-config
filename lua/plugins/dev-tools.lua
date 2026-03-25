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
			notifier = { enabled = true },
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
			_G.default_terminal_layout = {
				win = { position = "bottom", height = 0.4 },
			}

			local function get_terminal_state(term)
				if not (term and term.buf and vim.api.nvim_buf_is_valid(term.buf)) then
					return {}
				end

				local ok, state = pcall(vim.api.nvim_buf_get_var, term.buf, "snacks_terminal")
				return ok and state or {}
			end

			local function close_terminal(term)
				if not term then
					return
				end

				if term.close then
					term:close()
				end

				if term.buf and vim.api.nvim_buf_is_valid(term.buf) then
					vim.api.nvim_buf_delete(term.buf, { force = true })
				end
			end

			_G.toggle_main_terminal = function(layout_opts)
				local terminal = require("snacks").terminal
				local resolved_opts =
					vim.tbl_deep_extend("force", vim.deepcopy(_G.default_terminal_layout), layout_opts or {})
				local term, created = terminal.get(nil, vim.tbl_extend("keep", { create = false }, resolved_opts))

				if created or not term then
					return terminal.toggle(nil, resolved_opts)
				end

				local current_position = term.opts and term.opts.position
				local requested_position = resolved_opts.win and resolved_opts.win.position

				if current_position == requested_position then
					return term:toggle()
				end

				local state = get_terminal_state(term)
				close_terminal(term)

				return terminal.toggle(state.cmd, {
					cwd = state.cwd,
					env = state.env,
					count = state.id,
					win = resolved_opts.win,
				})
			end

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
					toggle_main_terminal()
				end,
				desc = "Toggle Terminal",
				mode = { "n", "t" },
			},
			{
				"<C-\\>",
				function()
					toggle_main_terminal()
				end,
				desc = "Toggle Terminal",
				mode = { "n", "t" },
			},
			{
				"<leader>tf",
				function()
					toggle_main_terminal({
						win = { position = "float" },
					})
				end,
				desc = "Terminal (float)",
			},
			{
				"<leader>th",
				function()
					toggle_main_terminal({
						win = { position = "bottom", height = 0.4 },
					})
				end,
				desc = "Terminal (horizontal)",
			},
			{
				"<leader>tv",
				function()
					toggle_main_terminal({
						win = { position = "right", width = 0.4 },
					})
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
				"<leader>gl",
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
			-- GitHub account management
			{
				"<leader>ga",
				function()
					require("config.github").switch_account()
				end,
				desc = "Select GitHub account",
			},
			{
				"<leader>gas",
				function()
					require("config.github").show_status()
				end,
				desc = "Show GitHub status",
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
