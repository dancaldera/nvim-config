-- ============================================================================
-- Development Tools (snacks)
-- ============================================================================

return {
	-- Snacks.nvim (dashboard, notifier, picker, lazygit)
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			notifier = { enabled = true },
			picker = { enabled = true, ui_select = true },
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
						{ icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.picker.files()" },
						{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
						{ icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.picker.recent()" },
						{ icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.picker.grep()" },
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

			-- Ensure Snacks owns vim.ui.select
			if snacks.picker and snacks.picker.select then
				vim.ui.select = snacks.picker.select
			end

			-- Reload files changed by external tools
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
							vim.cmd.enew()
							vim.cmd.terminal(cmd)
							local bufnr = vim.api.nvim_get_current_buf()
							pcall(vim.api.nvim_buf_set_name, bufnr, "terminal://" .. cmd)
							vim.bo[bufnr].buflisted = true
							vim.cmd.startinsert()
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

			-- Picker keymaps
			{
				"<leader>ff",
				function()
					Snacks.picker.files()
				end,
				desc = "Fuzzy find files in cwd",
			},
			{
				"<leader>fr",
				function()
					Snacks.picker.recent()
				end,
				desc = "Fuzzy find recent files",
			},
			{
				"<leader>fs",
				function()
					Snacks.picker.grep()
				end,
				desc = "Find string in cwd",
			},
			{
				"<leader>fc",
				function()
					Snacks.picker.grep_word()
				end,
				desc = "Find string under cursor in cwd",
			},
			{
				"<leader>fb",
				function()
					Snacks.picker.buffers()
				end,
				desc = "Find open buffers",
			},
			{
				"<leader>fp",
				function()
					Snacks.picker.projects()
				end,
				desc = "Find projects",
			},
			{
				"<leader>fh",
				function()
					Snacks.picker.help()
				end,
				desc = "Find help",
			},
			{
				"<leader>fk",
				function()
					Snacks.picker.keymaps()
				end,
				desc = "Find keymaps",
			},
		},
	},
}
