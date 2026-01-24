-- ============================================================================
-- Configuration Health Checks
-- ============================================================================

local M = {}

local function make_reporter(opts)
	opts = opts or {}

	local health_module
	if opts.use_health then
		health_module = vim.health
		if type(health_module) ~= "table" then
			local ok, mod = pcall(require, "vim.health")
			if ok then
				health_module = mod
			else
				health_module = nil
			end
		end
	end

	local notify_threshold = opts.notify_level or vim.log.levels.INFO

	local function notify(level, msg)
		if opts.use_notify and level >= notify_threshold then
			vim.notify(msg, level)
		end
	end

	local function call_health(methods, msg)
		if not health_module then
			return
		end
		for _, name in ipairs(methods) do
			local fn = health_module[name]
			if type(fn) == "function" then
				fn(msg)
				return
			end
		end
	end

	return {
		start = function(msg)
			call_health({ "start", "report_start" }, msg)
			notify(vim.log.levels.INFO, msg)
		end,
		ok = function(msg)
			call_health({ "ok", "report_ok", "info", "report_info" }, msg)
			notify(vim.log.levels.INFO, msg)
		end,
		info = function(msg)
			call_health({ "info", "report_info" }, msg)
			notify(vim.log.levels.INFO, msg)
		end,
		warn = function(msg)
			call_health({ "warn", "report_warn" }, msg)
			notify(vim.log.levels.WARN, msg)
		end,
		error = function(msg)
			call_health({ "error", "report_error" }, msg)
			notify(vim.log.levels.ERROR, msg)
		end,
	}
end

local function check_external_tools(report)
	report.start("External tools")

	local tools = {
		{ name = "git", required = true, cmd = "git --version" },
		{ name = "rg", required = true, cmd = "rg --version" },
		{ name = "fd", required = false, cmd = "fd --version" },
		{ name = "node", required = false, cmd = "node --version" },
		{ name = "npm", required = false, cmd = "npm --version" },
		{ name = "python", required = false, cmd = "python --version" },
		{ name = "python3", required = false, cmd = "python3 --version" },
	}

	local missing_required = {}

	for _, tool in ipairs(tools) do
		local handle = io.popen(tool.cmd .. " 2>/dev/null")
		local result = ""
		local success = false

		if handle then
			result = handle:read("*a") or ""
			local ok_close = handle:close()
			success = ok_close ~= nil and ok_close ~= false
		end

		result = result:gsub("%s+$", "")

		if success and result ~= "" then
			report.ok(string.format("%s: %s", tool.name, result))
		else
			if tool.required then
				report.error(string.format("Missing required tool: %s", tool.name))
				table.insert(missing_required, tool.name)
			else
				report.warn(string.format("Optional tool missing: %s", tool.name))
			end
		end
	end

	if #missing_required > 0 then
		report.error("Missing required tools: " .. table.concat(missing_required, ", "))
		return false
	end

	return true
end

local function check_neovim_version(report)
	report.start("Neovim version")

	local version = vim.version()
	local required_minor = 10
	local recommended_minor = 11

	if version.major == 0 and version.minor < required_minor then
		report.error(
			string.format(
				"Detected Neovim v%d.%d.%d; require v0.%d.0 or newer.",
				version.major,
				version.minor,
				version.patch,
				required_minor
			)
		)
		return false
	end

	if version.major == 0 and version.minor >= required_minor and version.minor < recommended_minor then
		report.ok(
			string.format(
				"Neovim v%d.%d.%d detected (meets minimum v0.%d.0)",
				version.major,
				version.minor,
				version.patch,
				required_minor
			)
		)
		report.warn(
			string.format("Recommend upgrading to v0.%d+ for native LSP features (vim.lsp.config)", recommended_minor)
		)
		return true
	end

	report.ok(
		string.format(
			"Neovim v%d.%d.%d detected (recommended v0.%d+)",
			version.major,
			version.minor,
			version.patch,
			recommended_minor
		)
	)
	return true
end

local function check_lazy_nvim(report)
	report.start("lazy.nvim plugin manager")

	local lazy_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
	if vim.fn.isdirectory(lazy_path) == 0 then
		report.error("lazy.nvim not found; run :Lazy sync to install.")
		return false
	end

	local ok, lazy = pcall(require, "lazy")
	if not ok then
		report.error("Failed to require lazy.nvim; verify installation.")
		return false
	end

	local stats = lazy.stats()
	if stats then
		report.ok(
			string.format(
				"lazy.nvim loaded %d/%d plugins in %.0fms",
				stats.loaded,
				stats.count,
				(stats.startuptime or 0) * 1000
			)
		)
	else
		report.info("lazy.nvim loaded (stats unavailable)")
	end

	return true
end

local function check_lsp_servers(report)
	report.start("LSP servers")

	if not (vim.lsp and vim.lsp.config) then
		report.error("vim.lsp.config API unavailable; requires Neovim 0.11+ with nvim-lspconfig.")
		return false
	end

	local required_servers = { "lua_ls", "ts_ls", "html", "cssls", "jsonls", "yamlls" }
	local optional_servers = { "pyright", "gopls", "clangd", "rust_analyzer", "tailwindcss" }

	local available = {}
	local missing_required = {}
	local missing_optional = {}

	local function has_server(name)
		-- Prefer checking for the new-style config shipped under runtime/lsp/<name>.lua.
		local runtime_paths = vim.api.nvim_get_runtime_file("lsp/" .. name .. ".lua", false)
		if runtime_paths and #runtime_paths > 0 then
			return true
		end
		-- Otherwise fall back to the legacy loader, which supports older nvim-lspconfig versions.
		return pcall(require, "lspconfig.server_configurations." .. name)
	end

	for _, server in ipairs(required_servers) do
		if has_server(server) then
			table.insert(available, server)
		else
			table.insert(missing_required, server)
		end
	end

	for _, server in ipairs(optional_servers) do
		if not has_server(server) then
			table.insert(missing_optional, server)
		end
	end

	if #available > 0 then
		report.ok("Available required servers: " .. table.concat(available, ", "))
	end

	if #missing_required > 0 then
		report.error("Missing required server configs: " .. table.concat(missing_required, ", "))
	end

	if #missing_optional > 0 then
		report.warn("Optional servers not configured: " .. table.concat(missing_optional, ", "))
	end

	local mason_ok, registry = pcall(require, "mason-registry")
	if mason_ok then
		local installed_packages = registry.get_installed_packages()
		report.info(string.format("Mason packages installed: %d", #installed_packages))
	else
		report.warn("Mason registry unavailable; LSP tool installation status unknown.")
	end

	return #missing_required == 0
end

local function check_formatters(report)
	report.start("Formatters (conform.nvim)")

	local ok, conform = pcall(require, "conform")
	if not ok then
		report.warn("conform.nvim not available; format-on-save disabled.")
		return false
	end

	local formatters_by_ft = conform.list_all_formatters()
	local filetype_count = vim.tbl_count(formatters_by_ft)
	local formatter_count = 0

	for _, formatters in pairs(formatters_by_ft) do
		formatter_count = formatter_count + #formatters
	end

	report.ok(string.format("Formatters configured: %d across %d filetypes", formatter_count, filetype_count))

	-- Check if formatters are available for current buffer's filetype
	local current_ft = vim.bo.filetype
	if current_ft and current_ft ~= "" then
		local available_formatters = conform.list_formatters(0)
		if available_formatters and #available_formatters > 0 then
			local formatter_names = {}
			for _, f in ipairs(available_formatters) do
				if f.available then
					table.insert(formatter_names, f.name)
				end
			end
			if #formatter_names > 0 then
				report.info(string.format("Current filetype (%s): %s", current_ft, table.concat(formatter_names, ", ")))
			else
				report.warn(string.format("Formatters configured for %s but none available", current_ft))
			end
		end
	end

	return true
end

local function check_copilot(report)
	report.start("GitHub Copilot")

	local ok, copilot = pcall(require, "copilot")
	if not ok then
		report.warn("Copilot not loaded; AI completions unavailable.")
		return false
	end

	-- Check if copilot auth exists
	local auth_file = vim.fn.expand("~/.config/github-copilot/hosts.json")
	if vim.fn.filereadable(auth_file) == 1 then
		report.ok("Copilot authentication file found")
	else
		report.warn("Copilot not authenticated; run :Copilot auth")
		return false
	end

	-- Check if copilot-cmp is available
	local cmp_ok, copilot_cmp = pcall(require, "copilot_cmp")
	if cmp_ok then
		report.info("Copilot integrated with nvim-cmp")
	else
		report.info("Copilot standalone mode (inline suggestions only)")
	end

	return true
end

local function check_treesitter(report)
	report.start("Treesitter")

	local ok_configs, configs = pcall(require, "nvim-treesitter.configs")
	if not ok_configs then
		report.warn("nvim-treesitter not available; syntax highlighting may be degraded.")
		return false
	end

	local ok_info, info = pcall(require, "nvim-treesitter.info")
	if ok_info then
		local installed_parsers = info.installed_parsers()
		report.ok(string.format("Treesitter parsers installed: %d", #installed_parsers))
	else
		report.warn("Unable to read Treesitter parser installation info.")
	end

	---@type boolean
	local folding_enabled = false
	if type(configs.is_enabled) == "function" then
		local ok, enabled = pcall(configs.is_enabled, "folding")
		folding_enabled = ok and enabled or false
	elseif type(configs.get_module) == "function" then
		local module = configs.get_module("folding")
		folding_enabled = (module and module.enable == true) and true or false
	end

	if folding_enabled then
		report.info("Treesitter folding enabled")
	end

	return true
end

local function check_config_consistency(report)
	report.start("Configuration consistency")

	local issues = {}

	local guicursor = vim.opt.guicursor:get()
	local empty_guicursor = false
	if type(guicursor) == "string" then
		empty_guicursor = guicursor == ""
	elseif type(guicursor) == "table" then
		empty_guicursor = vim.tbl_isempty(guicursor)
	end

	if empty_guicursor then
		table.insert(issues, "guicursor is unset; cursor appearance may be degraded.")
	end

	if not vim.g.colors_name then
		table.insert(issues, "No colorscheme set; consider loading one for consistent styling.")
	end

	if #issues == 0 then
		report.ok("No configuration consistency issues detected")
		return true
	end

	for _, issue in ipairs(issues) do
		report.warn(issue)
	end
	return false
end

local function run_all_checks(report)
	local all_good = true

	if not check_neovim_version(report) then
		all_good = false
	end

	if not check_external_tools(report) then
		all_good = false
	end

	if not check_lazy_nvim(report) then
		all_good = false
	end

	if not check_lsp_servers(report) then
		all_good = false
	end

	check_formatters(report)
	check_copilot(report)
	check_treesitter(report)

	if not check_config_consistency(report) then
		all_good = false
	end

	if all_good then
		report.ok("All critical checks passed!")
	else
		report.warn("Some critical checks failed. Address the issues above.")
	end

	return all_good
end

function M.check_health()
	local reporter = make_reporter({
		use_notify = true,
		use_health = false,
		notify_level = vim.log.levels.WARN,
	})
	return run_all_checks(reporter)
end

function M.check()
	local reporter = make_reporter({
		use_notify = false,
		use_health = true,
	})
	return run_all_checks(reporter)
end

-- Auto-check disabled for performance - use :checkhealth or <leader>hc manually

return M
