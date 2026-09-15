-- ============================================================================
-- Editor (snacks.nvim picker/terminal, neo-tree explorer, which-key groups)
-- ============================================================================

local function snacks_picker(source, opts)
	return function()
		Snacks.picker[source](opts)
	end
end

local function explorer_toggle()
	require("neo-tree.command").execute({ toggle = true, source = "filesystem" })
end

local function explorer_reveal()
	require("neo-tree.command").execute({ action = "show", reveal = true, source = "filesystem" })
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

return {
	-- File explorer (neo-tree): sidebar tree with filesystem/buffers/git_status
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		cmd = "Neotree",
		init = function()
			-- Sidebar open + focused by default. Runs on UIEnter (scheduled, so
			-- the snacks dashboard handler on the same event opens first; it
			-- skips itself when more than one non-floating window exists). The
			-- deferred call covers headless launches where UIEnter never fires.
			local opened = false
			local function open_sidebar()
				if opened then
					return
				end
				opened = true
				vim.schedule(function()
					require("neo-tree.command").execute({ action = "focus" })
				end)
			end
			vim.api.nvim_create_autocmd("UIEnter", { once = true, callback = open_sidebar })
			vim.defer_fn(open_sidebar, 500)
			-- The snacks dashboard does not close itself when a file is opened
			-- externally (e.g. <CR> in the tree), leaving the float covering the
			-- new buffer. Close it whenever a real file buffer loads.
			vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
				group = vim.api.nvim_create_augroup("neotree_dash_close", { clear = true }),
				callback = function()
					for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
						local config = vim.api.nvim_win_get_config(win)
						if
							config.relative ~= ""
							and vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "snacks_dashboard"
						then
							pcall(vim.api.nvim_win_close, win, true)
						end
					end
				end,
			})
		end,
		keys = {
			{ "\\", explorer_toggle, desc = "Toggle file explorer" },
			{ "<leader>ee", explorer_toggle, desc = "Toggle file explorer" },
			{ "<leader>ef", explorer_reveal, desc = "Reveal current file in explorer" },
		},
		opts = {
			close_if_last_window = true,
			sources = { "filesystem", "buffers", "git_status" },
			open_files_do_not_replace_types = { "terminal", "qf", "trouble" },
			window = { width = 32 },
			filesystem = {
				bind_to_cwd = false,
				follow_current_file = { enabled = true },
				use_libuv_file_watcher = true, -- auto-refresh on file-system events
				filtered_items = {
					hide_dotfiles = true,
					hide_gitignored = true,
				},
				window = {
					mappings = { ["H"] = "toggle_hidden" },
				},
			},
			default_component_configs = {
				indent = { with_expanders = true },
			},
		},
	},

	{
		"folke/snacks.nvim",
		opts = {
			-- Animated scrolling off
			scroll = { enabled = false },
			image = { enabled = false },
			-- snacks.explorer off (neo-tree is the explorer); without this the
			-- module defaults to replace_netrw = true and would hijack BufEnter
			explorer = { enabled = false },
			picker = {
				enabled = true,
				ui_select = true,
				toggles = {
					hidden = "H:dot",
					ignored = "I:ignored",
				},
			},
			indent = {
				enabled = true,
				indent = { enabled = false },
				animate = { enabled = false },
				scope = { enabled = true, char = "│" },
			},
			dashboard = {
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
		keys = {

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
			{
				"<leader>tt",
				function()
					Snacks.terminal.toggle()
				end,
				desc = "Toggle terminal",
				mode = { "n", "t" },
			},
			{
				"<C-\\>",
				function()
					Snacks.terminal.toggle()
				end,
				desc = "Toggle terminal",
			},
			{ "<leader>tc", open_command_terminal, desc = "Terminal (custom command)" },
			{ "<leader>tk", kill_terminal, desc = "Kill terminal", mode = { "n", "t" } },

			-- Git and picker
			{
				"<leader>gl",
				function()
					Snacks.lazygit()
				end,
				desc = "Lazygit",
			},
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

	-- Which-key group labels for our custom prefixes
	{
		"folke/which-key.nvim",
		opts = {
			spec = {
				{ "<leader>b", group = "Buffer" },
				{ "<leader>c", group = "Code Actions" },
				{ "<leader>d", group = "Diagnostics" },
				{ "<leader>e", group = "File Explorer" },
				{ "<leader>f", group = "Find/Search" },
				{ "<leader>h", group = "Git Hunks" },
				{ "<leader>r", group = "Rename/Restart" },
				{ "<leader>s", group = "Split/Search" },
				{ "<leader>t", group = "Terminal/Toggle" },
				{ "<leader>x", group = "Diagnostics/Lists" },
			},
		},
	},
}
