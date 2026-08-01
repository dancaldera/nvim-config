-- ============================================================================
-- Development Tools (Snacks dashboard, explorer, diagnostics, picker, terminal)
-- ============================================================================

local function active_explorer()
	return Snacks.picker.get({ source = "explorer" })[1]
end

local function snacks_picker(source, opts)
	return function()
		Snacks.picker[source](opts)
	end
end

local function toggle_explorer()
	Snacks.explorer()
end

local function reveal_current_file()
	local path = vim.api.nvim_buf_get_name(0)
	if path ~= "" and vim.fn.filereadable(path) == 1 then
		Snacks.explorer.reveal({ file = path })
	else
		Snacks.explorer()
	end
end

local function close_explorer()
	for _, picker in ipairs(Snacks.picker.get({ source = "explorer" })) do
		picker:close()
	end
end

local function refresh_explorer()
	local picker = active_explorer()
	if picker then
		picker:refresh()
	else
		Snacks.explorer()
	end
end

local function focus_explorer()
	local picker = active_explorer()
	local win = picker and picker.list.win.win
	if win and vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_set_current_win(win)
	else
		reveal_current_file()
	end
end

local function toggle_explorer_focus()
	local picker = active_explorer()
	if not picker then
		reveal_current_file()
		return
	end

	local explorer_win = picker.list.win.win
	if vim.api.nvim_get_current_win() == explorer_win and vim.api.nvim_win_is_valid(picker.main) then
		vim.api.nvim_set_current_win(picker.main)
	elseif vim.api.nvim_win_is_valid(explorer_win) then
		vim.api.nvim_set_current_win(explorer_win)
	end
end

local function copy_diagnostics()
	local diagnostics = vim.diagnostic.get()
	if #diagnostics == 0 then
		vim.notify("No diagnostics found", vim.log.levels.INFO)
		return
	end

	local severity_names = {
		[vim.diagnostic.severity.ERROR] = "ERROR",
		[vim.diagnostic.severity.WARN] = "WARN",
		[vim.diagnostic.severity.INFO] = "INFO",
		[vim.diagnostic.severity.HINT] = "HINT",
	}
	local formatted = {}
	for _, diagnostic in ipairs(diagnostics) do
		local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(diagnostic.bufnr), ":~:.")
		formatted[#formatted + 1] = string.format(
			"%s:%d:%d [%s] %s",
			filename,
			diagnostic.lnum + 1,
			diagnostic.col + 1,
			severity_names[diagnostic.severity] or "UNKNOWN",
			diagnostic.message:gsub("\n", " ")
		)
	end

	vim.fn.setreg("+", table.concat(formatted, "\n"))
	vim.notify(string.format("Copied %d diagnostics to clipboard", #diagnostics), vim.log.levels.INFO)
end

local function jump_diagnostic(count, severity)
	return function()
		vim.diagnostic.jump({ count = count, severity = severity })
	end
end

local function show_line_diagnostics()
	vim.diagnostic.open_float(nil, {
		scope = "line",
		border = "rounded",
		focusable = true,
		source = true,
		header = "",
		prefix = "",
	})
end

local function toggle_terminal()
	Snacks.terminal.toggle()
end

local function open_command_terminal()
	vim.ui.input({ prompt = "Command: " }, function(command)
		if command and command ~= "" then
			Snacks.terminal.open(command)
		end
	end)
end

local function kill_terminal()
	local buf = vim.api.nvim_get_current_buf()
	if vim.bo[buf].buftype ~= "terminal" then
		return
	end

	local job_id = vim.b[buf].terminal_job_id
	if job_id then
		vim.fn.jobstop(job_id)
	end
	Snacks.bufdelete({ buf = buf, force = true })
end

local function open_lazygit()
	Snacks.lazygit()
end

return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			notifier = { enabled = true },
			explorer = {
				enabled = true,
				replace_netrw = true,
				trash = true,
			},
			picker = {
				enabled = true,
				ui_select = true,
				sources = {
					explorer = {
						layout = {
							preset = "sidebar",
							preview = false,
							layout = { width = 32, min_width = 28 },
						},
					},
				},
			},
			indent = {
				enabled = true,
				indent = { enabled = false },
				animate = { enabled = false },
				scope = { enabled = true, char = "│" },
			},
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
			require("snacks").setup(opts)

			vim.api.nvim_create_autocmd("FocusGained", {
				group = vim.api.nvim_create_augroup("auto_checktime", { clear = true }),
				callback = function()
					if vim.bo.buftype ~= "terminal" then
						vim.cmd("silent! checktime")
					end
				end,
			})
		end,
		keys = {
			-- File explorer
			{ "\\", toggle_explorer, desc = "Toggle file explorer" },
			{ "<leader>ee", toggle_explorer, desc = "Toggle file explorer" },
			{ "<leader>ef", reveal_current_file, desc = "Reveal current file in explorer" },
			{ "<leader>ec", close_explorer, desc = "Close file explorer" },
			{ "<leader>er", refresh_explorer, desc = "Refresh file explorer" },
			{ "<leader>eo", focus_explorer, desc = "Focus file explorer" },
			{ "<C-e>", toggle_explorer_focus, desc = "Toggle focus between explorer and buffer" },

			-- Diagnostics and lists
			{ "<leader>xx", snacks_picker("diagnostics"), desc = "Workspace diagnostics" },
			{ "<leader>xX", snacks_picker("diagnostics_buffer"), desc = "Buffer diagnostics" },
			{ "<leader>xs", snacks_picker("lsp_symbols"), desc = "Document symbols" },
			{ "<leader>xl", snacks_picker("lsp_references"), desc = "LSP references" },
			{ "<leader>xL", snacks_picker("loclist"), desc = "Location list" },
			{ "<leader>xQ", snacks_picker("qflist"), desc = "Quickfix list" },
			{ "<leader>xc", copy_diagnostics, desc = "Copy diagnostics to clipboard" },
			{
				"<leader>de",
				snacks_picker("diagnostics", { severity = vim.diagnostic.severity.ERROR }),
				desc = "Errors only",
			},
			{
				"<leader>dw",
				snacks_picker("diagnostics", { severity = vim.diagnostic.severity.WARN }),
				desc = "Warnings only",
			},
			{ "]e", jump_diagnostic(1, vim.diagnostic.severity.ERROR), desc = "Next error" },
			{ "[e", jump_diagnostic(-1, vim.diagnostic.severity.ERROR), desc = "Previous error" },
			{ "]w", jump_diagnostic(1, vim.diagnostic.severity.WARN), desc = "Next warning" },
			{ "[w", jump_diagnostic(-1, vim.diagnostic.severity.WARN), desc = "Previous warning" },
			{ "<leader>dd", show_line_diagnostics, desc = "Show line diagnostics" },

			-- Terminal
			{ "<leader>tt", toggle_terminal, desc = "Toggle terminal", mode = { "n", "t" } },
			{ "<C-\\>", toggle_terminal, desc = "Toggle terminal" },
			{ "<leader>tc", open_command_terminal, desc = "Terminal (custom command)" },
			{ "<leader>tk", kill_terminal, desc = "Kill terminal", mode = { "n", "t" } },

			-- Git and picker
			{ "<leader>gl", open_lazygit, desc = "Lazygit" },
			{ "<leader>ff", snacks_picker("files"), desc = "Fuzzy find files in cwd" },
			{ "<leader>fr", snacks_picker("recent"), desc = "Fuzzy find recent files" },
			{ "<leader>fs", snacks_picker("grep"), desc = "Find string in cwd" },
			{ "<leader>fc", snacks_picker("grep_word"), desc = "Find string under cursor in cwd" },
			{ "<leader>fb", snacks_picker("buffers"), desc = "Find open buffers" },
			{ "<leader>fp", snacks_picker("projects"), desc = "Find projects" },
			{ "<leader>fh", snacks_picker("help"), desc = "Find help" },
			{ "<leader>fk", snacks_picker("keymaps"), desc = "Find keymaps" },
		},
	},
}
