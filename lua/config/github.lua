local M = {}

local account_cache = nil
local cache_timestamp = 0
local CACHE_TTL = 60
local DEFAULT_HOST = "github.com"

local function normalize_accounts(decoded)
	local hosts = decoded and decoded.hosts or {}
	local host_accounts = hosts[DEFAULT_HOST]
	if type(host_accounts) ~= "table" then
		return {
			accounts = {},
			current = nil,
		}
	end

	local accounts = {}
	for _, account in ipairs(host_accounts) do
		accounts[#accounts + 1] = {
			login = account.login,
			host = account.host or DEFAULT_HOST,
			active = account.active == true,
			state = account.state or "unknown",
			error = account.error,
			git_protocol = account.gitProtocol,
			token_source = account.tokenSource,
		}
	end

	table.sort(accounts, function(a, b)
		if a.active ~= b.active then
			return a.active
		end
		return a.login < b.login
	end)

	local current = nil
	for _, account in ipairs(accounts) do
		if account.active then
			current = account.login
			break
		end
	end

	return {
		accounts = accounts,
		current = current,
	}
end

local function get_status_suffix(account)
	local labels = {}
	if account.active then
		table.insert(labels, "current")
	end
	if account.state ~= "logged_in" then
		table.insert(labels, "needs login")
	end
	if #labels == 0 then
		return ""
	end
	return " " .. table.concat(labels, " · ")
end

local function parse_auth_status(output)
	local ok, decoded = pcall(vim.json.decode, output)
	if not ok or type(decoded) ~= "table" then
		return nil
	end
	return normalize_accounts(decoded)
end

local function clear_cache()
	account_cache = nil
	cache_timestamp = 0
end

local function read_accounts()
	local output = vim.fn.system("gh auth status --json hosts 2>&1")
	if vim.v.shell_error ~= 0 and output:match("unknown flag") then
		vim.notify("Installed GitHub CLI is too old for JSON auth status", vim.log.levels.WARN)
		return nil
	end

	local data = parse_auth_status(output)
	if data then
		return data
	end

	if output:match("command not found") or output:match("not installed") then
		vim.notify("GitHub CLI not configured or not installed", vim.log.levels.WARN)
		return nil
	end

	vim.notify("Failed to read GitHub account status", vim.log.levels.WARN)
	return nil
end

M.get_accounts = function(force_refresh)
	local current_time = os.time()

	if not force_refresh and account_cache and (current_time - cache_timestamp) < CACHE_TTL then
		return account_cache
	end

	local data = read_accounts()
	if not data then
		return nil
	end

	account_cache = data
	cache_timestamp = current_time
	return account_cache
end

M.get_current_account = function()
	local data = M.get_accounts()
	return data and data.current or nil
end

M.get_all_accounts = function()
	local data = M.get_accounts()
	if not data then
		return {}
	end
	return vim.tbl_map(function(account)
		return account.login
	end, data.accounts)
end

M.show_status = function()
	local data = M.get_accounts()
	if not data or #data.accounts == 0 then
		vim.notify("No GitHub accounts configured", vim.log.levels.WARN)
		return
	end

	local lines = { "GitHub Accounts" }
	for _, account in ipairs(data.accounts) do
		local parts = { string.format("  @%s%s", account.login, get_status_suffix(account)) }
		if account.state ~= "logged_in" and account.error then
			table.insert(parts, account.error)
		end
		if account.git_protocol then
			table.insert(parts, "protocol: " .. account.git_protocol)
		end
		table.insert(lines, table.concat(parts, "  ·  "))
	end

	vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end

M.switch_account = function()
	local data = M.get_accounts(true)
	if not data or #data.accounts == 0 then
		vim.notify("No GitHub accounts configured", vim.log.levels.WARN)
		return false
	end

	if #data.accounts < 2 then
		vim.notify("Need at least 2 GitHub accounts to switch", vim.log.levels.WARN)
		return false
	end

	vim.ui.select(data.accounts, {
		prompt = "GitHub account",
		snacks = { layout = "select" },
		format_item = function(account)
			return string.format("@%s%s", account.login, get_status_suffix(account))
		end,
	}, function(selected_account)
		if not selected_account then
			return
		end

		if selected_account.active then
			vim.notify(string.format("Already using @%s", selected_account.login), vim.log.levels.INFO)
			return
		end

		local cmd = string.format("gh auth switch --user %s", vim.fn.shellescape(selected_account.login))
		local output = vim.fn.system(cmd)
		if vim.v.shell_error ~= 0 then
			vim.notify("Failed to switch GitHub account: " .. vim.trim(output), vim.log.levels.ERROR)
			return
		end

		clear_cache()
		local refreshed = M.get_accounts(true)
		local current = refreshed and refreshed.current or selected_account.login

		vim.notify(
			string.format("Switched GitHub account: @%s → @%s", data.current or "none", current),
			vim.log.levels.INFO
		)
		pcall(vim.cmd, "LualineRefresh")
	end)
end

return M
