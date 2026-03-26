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

	-- Snacks.nvim (dashboard, notifier, lazygit only)
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			notifier = { enabled = true },
			indent = { enabled = false },
			image = { enabled = false },
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
			local term_counts = {}
			local function next_term_name(name)
				term_counts[name] = (term_counts[name] or 0) + 1
				return name .. "-" .. term_counts[name]
			end

			_G.toggle_main_terminal = function()
				vim.cmd.enew()
				vim.cmd.terminal()
				local bufnr = vim.api.nvim_get_current_buf()
				pcall(vim.api.nvim_buf_set_name, bufnr, "terminal://" .. next_term_name("terminal"))
				vim.bo[bufnr].buflisted = true
				vim.cmd.startinsert()
			end

			_G.open_cli_terminal = function(name, cmd)
				vim.cmd.enew()
				if cmd then
					vim.cmd.terminal(cmd)
				else
					vim.cmd.terminal()
				end
				local bufnr = vim.api.nvim_get_current_buf()
				pcall(vim.api.nvim_buf_set_name, bufnr, "terminal://" .. next_term_name(name))
				vim.bo[bufnr].buflisted = true
				vim.cmd.startinsert()
			end

			-- backward-compat alias
			_G.toggle_cli_terminal = _G.open_cli_terminal
		end,

		keys = {
			-- Main terminal
			{
				"<leader>tt",
				function()
					toggle_main_terminal()
				end,
				desc = "Open Terminal",
				mode = { "n", "t" },
			},
			{
				"<C-\\>",
				function()
					toggle_main_terminal()
				end,
				desc = "Open Terminal",
				mode = { "n", "t" },
			},
			-- Custom command terminal
			{
				"<leader>tc",
				function()
					vim.ui.input({ prompt = "Command: " }, function(cmd)
						if cmd and cmd ~= "" then
							open_cli_terminal(cmd, cmd)
						end
					end)
				end,
				desc = "Terminal (custom command)",
			},
			-- Kill current terminal buffer
			{
				"<leader>tk",
				function()
					local buf = vim.api.nvim_get_current_buf()
					if vim.bo[buf].buftype == "terminal" then
						local job_id = vim.b[buf].terminal_job_id
						if job_id then
							vim.fn.jobstop(job_id)
						end
						vim.api.nvim_buf_delete(buf, { force = true })
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
					open_cli_terminal("claude", "claude")
				end,
				desc = "Open Claude",
			},
			{
				"<leader>lC",
				function()
					open_cli_terminal("claude bypass", "claude --allow-dangerously-skip-permissions")
				end,
				desc = "Open Claude (bypass)",
			},
			{
				"<leader>lG",
				function()
					open_cli_terminal("gemini", "gemini")
				end,
				desc = "Open Gemini",
			},
			{
				"<leader>lx",
				function()
					open_cli_terminal("codex", "codex")
				end,
				desc = "Open Codex",
			},
			{
				"<leader>lo",
				function()
					open_cli_terminal("opencode", "opencode")
				end,
				desc = "Open Opencode",
			},
			{
				"<leader>la",
				function()
					open_cli_terminal("copilot", "copilot")
				end,
				desc = "Open Copilot CLI",
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
