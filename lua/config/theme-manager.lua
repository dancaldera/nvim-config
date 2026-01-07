-- ============================================================================
-- Theme Manager
-- Centralized theme switching and persistence for custom colorschemes
-- ============================================================================

local M = {}

-- Theme registry with metadata
M.themes = {
	["gruvbox-custom"] = {
		name = "Gruvbox Dark",
		file = "gruvbox-custom",
		description = "Warm, eye-comfort optimized (default)",
	},
	["solarized-dark"] = {
		name = "Solarized Dark",
		file = "solarized-dark",
		description = "Precision colors, low contrast",
	},
	["nord-dark"] = {
		name = "Nord Dark",
		file = "nord-dark",
		description = "Arctic, bluish palette",
	},
}

-- Get preference file path
function M.get_preference_path()
	return vim.fn.stdpath("data") .. "/theme-preference.txt"
end

-- Load saved theme preference
function M.load_preference()
	local pref_file = M.get_preference_path()

	-- Try to read preference file
	local file = io.open(pref_file, "r")
	if file then
		local theme_name = file:read("*line")
		file:close()

		-- Validate theme exists
		if theme_name and M.themes[theme_name] then
			return theme_name
		end
	end

	-- Default to gruvbox-custom
	return "gruvbox-custom"
end

-- Save theme preference
function M.save_preference(theme_name)
	local pref_file = M.get_preference_path()

	-- Write theme name to file
	local file = io.open(pref_file, "w")
	if file then
		file:write(theme_name)
		file:close()
		return true
	else
		vim.notify("Failed to save theme preference", vim.log.levels.WARN)
		return false
	end
end

-- Load theme by name
function M.load_theme(theme_name)
	-- Validate theme exists
	if not M.themes[theme_name] then
		vim.notify(string.format("Theme '%s' not found. Using gruvbox-custom.", theme_name), vim.log.levels.WARN)
		theme_name = "gruvbox-custom"
	end

	local theme_info = M.themes[theme_name]

	-- Load theme file
	local theme_path = vim.fn.stdpath("config") .. "/lua/colors/" .. theme_info.file .. ".lua"
	local success, err = pcall(dofile, theme_path)

	if not success then
		vim.notify(string.format("Failed to load theme '%s': %s", theme_info.name, err), vim.log.levels.ERROR)
		return false
	end

	-- Save preference
	M.save_preference(theme_name)

	-- Trigger ColorScheme autocmd for plugin integrations
	vim.cmd("doautocmd ColorScheme")

	-- Show notification
	vim.notify(string.format("Theme: %s", theme_info.name), vim.log.levels.INFO)

	return true
end

-- Get current theme
function M.get_current_theme()
	return vim.g.colors_name or "gruvbox-custom"
end

-- List available themes
function M.list_themes()
	local current = M.get_current_theme()
	local lines = { "Available Themes:", "" }

	for theme_id, theme_info in pairs(M.themes) do
		local marker = (theme_id == current) and "● " or "  "
		local line = string.format("%s%s - %s", marker, theme_info.name, theme_info.description)
		table.insert(lines, line)
	end

	table.insert(lines, "")
	table.insert(lines, "Keybindings:")
	table.insert(lines, "  <leader>t1 - Gruvbox Dark")
	table.insert(lines, "  <leader>t2 - Solarized Dark")
	table.insert(lines, "  <leader>t3 - Nord Dark")

	-- Display in floating window
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	local width = 60
	local height = #lines
	local opts = {
		relative = "editor",
		width = width,
		height = height,
		col = (vim.o.columns - width) / 2,
		row = (vim.o.lines - height) / 2 - 2,
		style = "minimal",
		border = "rounded",
	}

	local win = vim.api.nvim_open_win(buf, true, opts)
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
	vim.api.nvim_win_set_option(win, "cursorline", true)

	-- Close on any key
	vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", { buffer = buf, nowait = true })
	vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, nowait = true })
	vim.keymap.set("n", "<CR>", "<cmd>close<CR>", { buffer = buf, nowait = true })
end

return M
