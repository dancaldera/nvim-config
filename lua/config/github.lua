local M = {}

local account_cache = nil
local cache_timestamp = 0
local CACHE_TTL = 60

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

-- Show status via notification
M.show_status = function()
	local data = M.get_accounts()
	if not data or #data.usernames == 0 then
		vim.notify("No GitHub accounts configured", vim.log.levels.WARN)
		return
	end

	local lines = { "GitHub Accounts" }
	for _, username in ipairs(data.usernames) do
		local acc = data.accounts[username]
		local icon = acc.active and "✓" or "○"
		local badge = acc.active and " (active)" or ""
		local parts = { string.format("  %s  @%s%s", icon, username, badge) }
		if acc.protocol then
			table.insert(parts, "protocol: " .. acc.protocol)
		end
		if #acc.scopes > 0 then
			table.insert(parts, "scopes: " .. table.concat(acc.scopes, ", "))
		end
		table.insert(lines, table.concat(parts, "  ·  "))
	end

	vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
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

	local max_len = 0
	for _, username in ipairs(data.usernames) do
		if #username > max_len then
			max_len = #username
		end
	end

	local options = {}
	for _, username in ipairs(data.usernames) do
		local account = data.accounts[username]
		local icon = account.active and "✓" or "○"
		local badge = account.active and "  (current)" or ""
		local padded = username .. string.rep(" ", max_len - #username)
		table.insert(options, string.format("%s  %s%s", icon, padded, badge))
	end

	vim.ui.select(options, {
		prompt = "Switch GitHub Account",
		snacks = { layout = "select" },
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
			return
		end

		account_cache = nil
		vim.notify(
			string.format("Switched GitHub account: @%s → @%s", data.current or "none", selected_username),
			vim.log.levels.INFO
		)
		pcall(vim.cmd, "LualineRefresh")
	end)
end

return M
