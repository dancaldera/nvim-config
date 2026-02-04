local M = {}

local account_cache = nil
local cache_timestamp = 0
local CACHE_TTL = 60

M.parse_auth_status = function(output)
	local accounts = {}
	local current_account = nil
	local lines = vim.split(output, "\n")

	local current_account_line = nil

	for _, line in ipairs(lines) do
		local username = line:match("Logged in to github%.com account (%S+)")
		if username then
			local is_active = line:match("Active account: true")
			accounts[username] = {
				username = username,
				active = is_active ~= nil,
			}
			if is_active then
				current_account = username
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

M.switch_account = function()
	local data = M.get_accounts(true)
	if not data or #data.usernames < 2 then
		vim.notify("Need at least 2 GitHub accounts to switch", vim.log.levels.WARN)
		return false
	end

	local current = data.current
	local next_account = nil

	for i, username in ipairs(data.usernames) do
		if username == current then
			next_account = data.usernames[(i % #data.usernames) + 1]
			break
		end
	end

	if not next_account then
		next_account = data.usernames[1]
	end

	local cmd = string.format("gh auth switch --user %s", next_account)
	local output = vim.fn.system(cmd)

	if vim.v.shell_error ~= 0 then
		vim.notify("Failed to switch GitHub account: " .. output, vim.log.levels.ERROR)
		return false
	end

	account_cache = nil

	vim.notify("Switched to @" .. next_account, vim.log.levels.INFO)
	return true
end

M.show_status = function()
	local output = vim.fn.system("gh auth status")
	local snacks = require("snacks")

	snacks.terminal("gh auth status", {
		win = { position = "float", width = 0.8, height = 0.6, border = "rounded" },
	})
end

return M
