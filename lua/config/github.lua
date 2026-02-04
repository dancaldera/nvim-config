local M = {}

local account_cache = nil
local cache_timestamp = 0
local CACHE_TTL = 60
local status_buf = nil
local status_win = nil

local gruvbox_colors = {
	green = "#98971a",
	red = "#cc241d",
	yellow = "#d79921",
	blue = "#458588",
	magenta = "#b16286",
	cyan = "#689d6a",
	orange = "#d65d0e",
	gray = "#928374",
	bg_dark = "#282828",
	fg_light = "#ebdbb2",
}

local function close_status_window()
	if status_win and vim.api.nvim_win_is_valid(status_win) then
		vim.api.nvim_win_close(status_win, true)
	end
	if status_buf and vim.api.nvim_buf_is_valid(status_buf) then
		vim.api.nvim_buf_delete(status_buf, { force = true })
	end
	status_win = nil
	status_buf = nil
end

local function parse_scopes(line)
	local scopes_str = line:match("Token scopes: '(.+)'")
	if not scopes_str then
		return {}
	end
	return vim.split(scopes_str, "', '")
end

M.parse_auth_status = function(output)
	local accounts = {}
	local current_account = nil
	local lines = vim.split(output, "\n")
	local last_username = nil

	for _, line in ipairs(lines) do
		local username = line:match("Logged in to github%.com account (%S+)")
		if username then
			last_username = username
			if not accounts[username] then
				accounts[username] = {
					username = username,
					active = false,
					scopes = {},
					protocol = nil,
				}
			end
		elseif last_username then
			if line:match("Active account: true") then
				accounts[last_username].active = true
				current_account = last_username
			end

			local protocol = line:match("Git operations protocol: (%S+)")
			if protocol then
				accounts[last_username].protocol = protocol
			end

			local scopes = parse_scopes(line)
			if #scopes > 0 then
				accounts[last_username].scopes = scopes
			end
		end
	end

	return {
		accounts = accounts,
		current = current_account,
		usernames = vim.tbl_keys(accounts),
	}
end

M.get_accounts = function(force_refresh)
	local current_time = os.time()

	if not force_refresh and account_cache and (current_time - cache_timestamp) < CACHE_TTL then
		return account_cache
	end

	local output = vim.fn.system("gh auth status 2>&1")
	if vim.v.shell_error ~= 0 then
		vim.notify("GitHub CLI not configured or not installed", vim.log.levels.WARN)
		return nil
	end

	account_cache = M.parse_auth_status(output)
	cache_timestamp = current_time
	return account_cache
end

M.get_current_account = function()
	local data = M.get_accounts()
	return data and data.current or nil
end

M.get_all_accounts = function()
	local data = M.get_accounts()
	return data and data.usernames or {}
end

M.quick_status = function()
	local data = M.get_accounts()
	if not data or #data.usernames == 0 then
		vim.notify("No GitHub accounts configured", vim.log.levels.WARN)
		return
	end

	local lines = {}
	table.insert(lines, "─ GitHub Accounts ─")

	for _, username in ipairs(data.usernames) do
		local account = data.accounts[username]
		local icon = account.active and "🟢" or "⚪"
		local suffix = account.active and " (active)" or ""
		table.insert(lines, string.format("  %s @%s%s", icon, username, suffix))
	end

	table.insert(lines, "─ Press q or Esc to close ─")

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
	vim.api.nvim_buf_set_option(buf, "buflisted", false)

	local width = 0
	for _, line in ipairs(lines) do
		width = math.max(width, #line)
	end
	width = width + 4

	local height = #lines + 2

	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		row = row,
		col = col,
		width = width,
		height = height,
		style = "minimal",
		border = "rounded",
	})

	vim.api.nvim_win_set_option(win, "winhl", "Normal:Normal")
	vim.api.nvim_buf_set_keymap(buf, "n", "q", ":q<CR>", { silent = true })
	vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", ":q<CR>", { silent = true })
end

M.show_status = function()
	local data = M.get_accounts()
	if not data or #data.usernames == 0 then
		vim.notify("No GitHub accounts configured", vim.log.levels.WARN)
		return
	end

	close_status_window()

	local lines = {}
	table.insert(lines, "")

	if data.current then
		table.insert(lines, string.format("  Current GitHub Account: @%s ✓", data.current))
	else
		table.insert(lines, "  Current GitHub Account: None")
	end

	table.insert(lines, "  " .. string.rep("─", 50))
	table.insert(lines, "")

	for _, username in ipairs(data.usernames) do
		local account = data.accounts[username]
		local status_icon = account.active and "🟢" or "⚪"
		local status_text = account.active and "ACTIVE" or "inactive"
		local status_color = account.active and "GruvboxGreen" or "GruvboxGray"

		table.insert(lines, string.format("  %s @%s", status_icon, username))
		table.insert(lines, string.format("  Status: %s", status_text))

		if account.protocol then
			table.insert(lines, string.format("  Protocol: %s", account.protocol))
		end

		if #account.scopes > 0 then
			local scopes_str = table.concat(account.scopes, ", ")
			table.insert(lines, string.format("  Scopes: %s", scopes_str))
		end

		table.insert(lines, "")
	end

	table.insert(lines, "  Press <q> or <Esc> to close")
	table.insert(lines, "")

	status_buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(status_buf, 0, -1, false, lines)
	vim.api.nvim_buf_set_option(status_buf, "modifiable", false)
	vim.api.nvim_buf_set_option(status_buf, "buflisted", false)
	vim.api.nvim_buf_set_option(status_buf, "filetype", "markdown")

	local width = 54
	local height = #lines + 2

	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	status_win = vim.api.nvim_open_win(status_buf, true, {
		relative = "editor",
		row = row,
		col = col,
		width = width,
		height = height,
		style = "minimal",
		border = "rounded",
	})

	vim.api.nvim_win_set_option(status_win, "winhl", "Normal:Normal")
	vim.api.nvim_win_set_option(status_win, "cursorline", false)
	vim.api.nvim_buf_set_keymap(status_buf, "n", "q", "", {
		callback = close_status_window,
		silent = true,
	})
	vim.api.nvim_buf_set_keymap(status_buf, "n", "<Esc>", "", {
		callback = close_status_window,
		silent = true,
	})
end

M.switch_account = function()
	local data = M.get_accounts(true)
	if not data or #data.usernames == 0 then
		vim.notify("No GitHub accounts configured", vim.log.levels.WARN)
		return false
	end

	if #data.usernames < 2 then
		vim.notify("Need at least 2 GitHub accounts to switch", vim.log.levels.WARN)
		return false
	end

	local current_idx = nil
	for i, username in ipairs(data.usernames) do
		if username == data.current then
			current_idx = i
			break
		end
	end

	local options = {}
	for i, username in ipairs(data.usernames) do
		local account = data.accounts[username]
		local icon = account.active and "🟢" or "⚪"
		local suffix = account.active and " (current)" or ""
		table.insert(options, string.format("%s @%s%s", icon, username, suffix))
	end

	vim.ui.select(options, {
		prompt = "Select GitHub account:",
		format_item = function(item)
			return item
		end,
	}, function(choice, idx)
		if not choice or not idx then
			return
		end

		local selected_username = data.usernames[idx]
		if selected_username == data.current then
			vim.notify(string.format("Already using @%s", selected_username), vim.log.levels.INFO)
			return
		end

		local cmd = string.format("gh auth switch --user %s", selected_username)
		local output = vim.fn.system(cmd)

		if vim.v.shell_error ~= 0 then
			vim.notify("Failed to switch GitHub account: " .. output, vim.log.levels.ERROR)
			return false
		end

		account_cache = nil

		local msg = string.format("Switched GitHub account: @%s → @%s", data.current or "none", selected_username)
		vim.notify(msg, vim.log.levels.INFO)

		pcall(vim.cmd, "LualineRefresh")

		return true
	end)
end

vim.api.nvim_create_autocmd("BufWinLeave", {
	pattern = "*",
	callback = function()
		if status_win and not vim.api.nvim_win_is_valid(status_win) then
			status_win = nil
			status_buf = nil
		end
	end,
})

return M
