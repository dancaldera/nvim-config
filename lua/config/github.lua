local M = {}

local account_cache = nil
local cache_timestamp = 0
local CACHE_TTL = 60
local DEFAULT_HOST = "github.com"
local switch_in_progress = false

local function is_network_error(message)
	if not message or message == "" then
		return false
	end

	local lowered = message:lower()
	return lowered:match("no such host") ~= nil
		or lowered:match("dial tcp") ~= nil
		or lowered:match("timeout") ~= nil
		or lowered:match("temporary failure") ~= nil
		or lowered:match("connection refused") ~= nil
		or lowered:match("network is unreachable") ~= nil
end

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
		local state = select(1, account_state_label(account))
		table.insert(labels, state:lower())
	end
	if #labels == 0 then
		return ""
	end
	return " " .. table.concat(labels, " · ")
end

local function normalize_label(value)
	if not value or value == "" then
		return "Unknown"
	end

	local words = {}
	for part in tostring(value):gmatch("[^_%-]+") do
		words[#words + 1] = part:sub(1, 1):upper() .. part:sub(2)
	end

	return #words > 0 and table.concat(words, " ") or tostring(value)
end

local function account_state_label(account)
	if account.active and account.state == "logged_in" then
		return "Active", "DiagnosticOk"
	end
	if account.state == "logged_in" then
		return "Ready", "DiagnosticHint"
	end
	if account.state == "error" and is_network_error(account.error) then
		if account.active then
			return "Active (Offline)", "DiagnosticWarn"
		end
		return "Offline", "DiagnosticWarn"
	end
	if account.state == "error" then
		return "Auth Error", "DiagnosticError"
	end
	return "Needs Login", "DiagnosticWarn"
end

local function build_account_preview(account)
	local status = select(1, account_state_label(account))
	local lines = {
		string.format("# @%s", account.login),
		"",
		string.format("- Status: **%s**", status),
		string.format("- Host: `%s`", account.host or DEFAULT_HOST),
		string.format("- Git Protocol: `%s`", normalize_label(account.git_protocol)),
		string.format("- Token Source: `%s`", normalize_label(account.token_source)),
	}

	if account.active then
		lines[#lines + 1] = "- Session: current GitHub CLI account"
	else
		lines[#lines + 1] = "- Action: press `<Enter>` to switch to this account"
	end

	if account.state == "error" and is_network_error(account.error) and account.token_source then
		lines[#lines + 1] =
			"- Note: a token is configured, but GitHub CLI could not verify it because the network lookup failed"
	end

	if account.error and vim.trim(account.error) ~= "" then
		lines[#lines + 1] = ""
		lines[#lines + 1] = "## Attention"
		lines[#lines + 1] = account.error
	end

	return table.concat(lines, "\n")
end

local function format_account_item(account, supports_chunks)
	local status, status_hl = account_state_label(account)
	local host = account.host or DEFAULT_HOST
	local protocol = normalize_label(account.git_protocol)
	local current = account.active and "●" or "○"

	if not supports_chunks then
		return string.format("%s @%s  %s  %s  %s", current, account.login, status, host, protocol)
	end

	return {
		{ current .. " ", account.active and "DiagnosticOk" or "Comment" },
		{ "@" .. account.login, account.active and "Identifier" or "Function" },
		{ "  " },
		{ status, status_hl },
		{ "  " },
		{ host, "Comment" },
		{ "  " },
		{ protocol, "Special" },
	}
end

local function build_picker_items(accounts)
	local items = {}

	for idx, account in ipairs(accounts) do
		items[idx] = {
			idx = idx,
			account = account,
			text = table.concat({
				account.login,
				account.host or DEFAULT_HOST,
				account.state or "unknown",
				account.git_protocol or "",
				account.token_source or "",
				account.active and "current" or "",
			}, " "),
			preview = {
				text = build_account_preview(account),
				ft = "markdown",
			},
		}
	end

	return items
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

local function join_output(stdout, stderr)
	local parts = {}
	if stdout and vim.trim(stdout) ~= "" then
		parts[#parts + 1] = vim.trim(stdout)
	end
	if stderr and vim.trim(stderr) ~= "" then
		parts[#parts + 1] = vim.trim(stderr)
	end
	return table.concat(parts, "\n")
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

local function switch_account_async(login, callback)
	if vim.system then
		vim.system(
			{ "gh", "auth", "switch", "--user", login },
			{ text = true },
			vim.schedule_wrap(function(result)
				callback(result.code, join_output(result.stdout, result.stderr))
			end)
		)
		return
	end

	local cmd = string.format("gh auth switch --user %s", vim.fn.shellescape(login))
	local output = vim.fn.system(cmd)
	callback(vim.v.shell_error, vim.trim(output))
end

local function open_account_picker(data, on_choice)
	local ok, Snacks = pcall(require, "snacks")
	if ok and Snacks.picker then
		Snacks.picker.pick({
			source = "github_accounts",
			title = "GitHub Accounts",
			items = build_picker_items(data.accounts),
			format = function(item)
				return format_account_item(item.account, true)
			end,
			preview = "preview",
			focus = "list",
			layout = { preset = vim.o.columns >= 140 and "default" or "vertical" },
			win = {
				preview = {
					wo = {
						number = false,
						relativenumber = false,
						signcolumn = "no",
						wrap = true,
					},
				},
			},
			confirm = function(picker, item)
				picker:close()
				vim.schedule(function()
					on_choice(item and item.account)
				end)
			end,
		})
		return
	end

	vim.ui.select(data.accounts, {
		prompt = "GitHub account",
		format_item = function(account)
			return format_account_item(account, false)
		end,
	}, function(selected_account)
		on_choice(selected_account)
	end)
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
	if switch_in_progress then
		vim.notify("GitHub account switch already in progress", vim.log.levels.WARN, { title = "GitHub" })
		return false
	end

	local data = M.get_accounts(true)
	if not data or #data.accounts == 0 then
		vim.notify("No GitHub accounts configured", vim.log.levels.WARN, { title = "GitHub" })
		return false
	end

	if #data.accounts < 2 then
		vim.notify("Need at least 2 GitHub accounts to switch", vim.log.levels.WARN, { title = "GitHub" })
		return false
	end

	open_account_picker(data, function(selected_account)
		if not selected_account then
			return
		end

		if selected_account.active then
			vim.notify(string.format("Already using @%s", selected_account.login), vim.log.levels.INFO, {
				title = "GitHub",
			})
			return
		end

		vim.notify(
			string.format("Switching GitHub account to @%s...", selected_account.login),
			vim.log.levels.INFO,
			{ title = "GitHub" }
		)

		switch_in_progress = true
		switch_account_async(selected_account.login, function(code, output)
			switch_in_progress = false

			if code ~= 0 then
				local details = vim.trim(output or "")
				if details == "" then
					details = "Unknown error"
				end
				vim.notify("Failed to switch GitHub account: " .. details, vim.log.levels.ERROR, { title = "GitHub" })
				return
			end

			clear_cache()
			local refreshed = M.get_accounts(true)
			local current = refreshed and refreshed.current or selected_account.login

			vim.notify(
				string.format("Switched GitHub account: @%s → @%s", data.current or "none", current),
				vim.log.levels.INFO,
				{ title = "GitHub" }
			)
			pcall(vim.cmd, "LualineRefresh")
		end)
	end)
end

return M
