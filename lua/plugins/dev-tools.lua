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
				win = {
					style = "terminal",
					position = "float",
					backdrop = false,
					border = "single",
					width = 0.92,
					height = 0.88,
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
			require("snacks").setup(opts)

			-- Reload files changed by AI agents (claude-code, codex, etc.)
			vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
				group = vim.api.nvim_create_augroup("auto_checktime", { clear = true }),
				callback = function()
					if vim.bo.buftype ~= "terminal" then
						vim.cmd("silent! checktime")
					end
				end,
			})
		end,

		init = function()
			-- Toggle the main general-purpose terminal (bottom/right/float)
			_G.toggle_main_terminal = function(layout_opts)
				local resolved = vim.tbl_deep_extend("force", {
					win = { position = "bottom", height = 0.4 },
				}, layout_opts or {})
				return require("snacks").terminal.toggle(nil, resolved)
			end

			-- Toggle a named persistent CLI tool terminal (claude, codex, gemini, etc.)
			_G.toggle_cli_terminal = function(name, cmd, opts)
				local win_opts = vim.tbl_deep_extend("force", {
					position = "float",
					width = 0.92,
					height = 0.88,
					border = "single",
					backdrop = false,
					title = " " .. name .. " ",
					title_pos = "center",
				}, (opts and opts.win) or {})

				require("snacks").terminal.toggle(cmd, {
					interactive = false,
					auto_insert = false,
					start_insert = true,
					win = win_opts,
				})
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
