-- ============================================================================
-- Development Tools and Productivity Plugins
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
			vim.api.nvim_create_autocmd("TermClose", {
				group = vim.api.nvim_create_augroup("snacks_terminal_autoclose", { clear = true }),
				callback = function(event)
					-- Only auto-close if it's a snacks terminal
					local buf = event.buf
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
			-- AI & Tools Openers
			{
				"<leader>lc",
				function()
					require("snacks").terminal("claude")
				end,
				desc = "Open Claude",
			},
			{
				"<leader>lG",
				function()
					require("snacks").terminal("gemini")
				end,
				desc = "Open Gemini",
			},
			{
				"<leader>lx",
				function()
					require("snacks").terminal("codex")
				end,
				desc = "Open Codex",
			},
			{
				"<leader>lo",
				function()
					require("snacks").terminal("opencode")
				end,
				desc = "Open Opencode",
			},
			{
				"<leader>la",
				function()
					require("snacks").terminal("copilot")
				end,
				desc = "Open Copilot CLI",
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

	-- Better code navigation
	{
		"SmiteshP/nvim-navic",
		dependencies = "neovim/nvim-lspconfig",
		event = "LspAttach",
		opts = {
			icons = {
				File = " ",
				Module = " ",
				Namespace = " ",
				Package = " ",
				Class = " ",
				Method = " ",
				Property = " ",
				Field = " ",
				Constructor = " ",
				Enum = " ",
				Interface = " ",
				Function = " ",
				Variable = " ",
				Constant = " ",
				String = " ",
				Number = " ",
				Boolean = " ",
				Array = " ",
				Object = " ",
				Key = " ",
				Null = " ",
				EnumMember = " ",
				Struct = " ",
				Event = " ",
				Operator = " ",
				TypeParameter = " ",
			},
			lsp = {
				auto_attach = true,
				preference = nil,
			},
			highlight = true,
			separator = " > ",
			depth_limit = 0,
			depth_limit_indicator = "..",
			safe_output = true,
			lazy_update_context = false,
			click = false,
		},
	},

	-- Markdown preview
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = function()
			vim.fn["mkdp#util#install"]()
		end,
		keys = {
			{ "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview", ft = "markdown" },
		},
	},

	-- Render markdown with visual effects (togglable)
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown" },
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("render-markdown").setup({
				enabled = false, -- start disabled (raw chars visible)
			})
		end,
		keys = {
			{ "<leader>tm", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle markdown render" },
		},
	},

	-- Note: Trouble.nvim is configured in lua/plugins/enhanced-diagnostics.lua
}
