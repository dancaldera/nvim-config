-- ============================================================================
-- Configuration Health Checks
-- ============================================================================

local M = {}

-- Check if required external tools are available
local function check_external_tools()
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
	local missing_optional = {}

	for _, tool in ipairs(tools) do
		local handle = io.popen(tool.cmd .. " 2>/dev/null")
		local result = handle:read("*a")
		local success = handle:close()

		if success and result and result ~= "" then
			vim.notify(string.format("✓ %s found: %s", tool.name, result:gsub("\n", "")), vim.log.levels.DEBUG)
		else
			local message = string.format("✗ %s not found", tool.name)
			if tool.required then
				table.insert(missing_required, message)
				vim.notify(message, vim.log.levels.ERROR)
			else
				table.insert(missing_optional, message)
				vim.notify(message .. " (optional)", vim.log.levels.WARN)
			end
		end
	end

	if #missing_required > 0 then
		vim.notify("Missing required tools: " .. table.concat(missing_required, ", "), vim.log.levels.ERROR)
		return false
	end

	if #missing_optional > 0 then
		vim.notify("Missing optional tools: " .. table.concat(missing_optional, ", "), vim.log.levels.WARN)
	end

	return true
end

-- Check Neovim version
local function check_neovim_version()
	local version = vim.version()
	local required_version = { 0, 9, 0 }

	if version.major < required_version[1] or
	   (version.major == required_version[1] and version.minor < required_version[2]) then
		vim.notify(
			string.format("Neovim version %d.%d.%d is too old. Required: %d.%d.0+",
				version.major, version.minor, version.patch,
				required_version[1], required_version[2]),
			vim.log.levels.ERROR
		)
		return false
	end

	vim.notify(
		string.format("✓ Neovim version %d.%d.%d is compatible",
			version.major, version.minor, version.patch),
		vim.log.levels.INFO
	)
	return true
end

-- Check plugin manager
local function check_lazy_nvim()
	local lazy_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
	if vim.fn.isdirectory(lazy_path) == 0 then
		vim.notify("lazy.nvim not found. Please run :Lazy sync", vim.log.levels.ERROR)
		return false
	end

	local ok, lazy = pcall(require, "lazy")
	if not ok then
		vim.notify("Failed to load lazy.nvim", vim.log.levels.ERROR)
		return false
	end

	local stats = lazy.stats()
	vim.notify(
		string.format("✓ lazy.nvim loaded %d/%d plugins in %.2fms",
			stats.loaded, stats.count, stats.startuptime * 1000),
		vim.log.levels.INFO
	)
	return true
end

-- Check LSP servers
local function check_lsp_servers()
	local lspconfig = require("lspconfig")
	local required_servers = {
		"lua_ls", "ts_ls", "html", "cssls", "jsonls", "yamlls"
	}
	local optional_servers = {
		"pyright", "gopls", "clangd", "rust_analyzer", "tailwindcss"
	}

	local available_servers = {}
	for _, server in ipairs(required_servers) do
		if lspconfig[server] and lspconfig[server].setup then
			table.insert(available_servers, server)
		else
			vim.notify(string.format("LSP server '%s' not available", server), vim.log.levels.WARN)
		end
	end

	vim.notify(
		string.format("✓ Found %d required LSP servers", #available_servers),
		vim.log.levels.INFO
	)

	-- Check Mason
	local mason_ok, mason = pcall(require, "mason")
	if mason_ok then
		local registry = require("mason-registry")
		local installed_count = 0
		local total_count = 0

		for _, name in ipairs(vim.list_extend(required_servers, optional_servers)) do
			if registry.is_installed(name) then
				installed_count = installed_count + 1
			end
			total_count = total_count + 1
		end

		vim.notify(
			string.format("✓ Mason: %d/%d tools installed", installed_count, total_count),
			vim.log.levels.INFO
		)
	else
		vim.notify("Mason not available", vim.log.levels.WARN)
	end
end

-- Check formatters
local function check_formatters()
	local conform = require("conform")
	local formatters_by_ft = conform.list_all_formatters()
	local formatter_count = 0

	for _, formatters in pairs(formatters_by_ft) do
		formatter_count = formatter_count + #formatters
	end

	vim.notify(
		string.format("✓ Found %d formatters for %d file types",
			formatter_count, vim.tbl_count(formatters_by_ft)),
		vim.log.levels.INFO
	)
end

-- Check Treesitter parsers
local function check_treesitter()
	local ok, treesitter = pcall(require, "nvim-treesitter")
	if not ok then
		vim.notify("nvim-treesitter not available", vim.log.levels.ERROR)
		return false
	end

	local configs = require("nvim-treesitter.configs")
	local parsers = require("nvim-treesitter.parsers")
	local installed_parsers = parsers.get_parser_configs()
	local installed_count = 0

	for lang, config in pairs(installed_parsers) do
		if parsers.has_parser(lang) then
			installed_count = installed_count + 1
		end
	end

	vim.notify(
		string.format("✓ Treesitter: %d parsers installed", installed_count),
		vim.log.levels.INFO
	)

	return true
end

-- Main health check function
function M.check_health()
	vim.notify("=== Neovim Configuration Health Check ===", vim.log.levels.INFO)

	local all_good = true

	-- Check Neovim version
	if not check_neovim_version() then
		all_good = false
	end

	-- Check external tools
	if not check_external_tools() then
		all_good = false
	end

	-- Check plugin manager
	if not check_lazy_nvim() then
		all_good = false
	end

	-- Check LSP servers
	check_lsp_servers()

	-- Check formatters
	check_formatters()

	-- Check Treesitter
	check_treesitter()

	if all_good then
		vim.notify("✓ All critical checks passed!", vim.log.levels.INFO)
	else
		vim.notify("✗ Some critical checks failed. Please address the issues above.", vim.log.levels.ERROR)
	end

	return all_good
end

-- Check configuration consistency
function M.check_config_consistency()
	local issues = {}

	-- Check for deprecated settings
	if vim.opt.guicursor:get() == "" then
		table.insert(issues, "guicursor is empty - may cause cursor display issues")
	end

	-- Check for conflicting options
	if vim.opt.number:get() and vim.opt.relativenumber:get() then
		-- This is actually fine, just informational
	end

	-- Check for missing color scheme
	local colorscheme = vim.g.colors_name
	if not colorscheme then
		table.insert(issues, "No colorscheme set")
	end

	-- Check for invalid filetypes
	local invalid_fts = { "javascript.jsx", "typescript.tsx" }
	for _, ft in ipairs(invalid_fts) do
		if vim.tbl_contains(vim.api.nvim_get_runtime_file("", true), ft) then
			table.insert(issues, string.format("Invalid filetype detected: %s", ft))
		end
	end

	if #issues > 0 then
		vim.notify("Configuration issues found:", vim.log.levels.WARN)
		for _, issue in ipairs(issues) do
			vim.notify("  - " .. issue, vim.log.levels.WARN)
		end
	else
		vim.notify("✓ No configuration consistency issues found", vim.log.levels.INFO)
	end
end

-- Auto-run health check on startup (with delay)
vim.defer_fn(function()
	M.check_health()
	M.check_config_consistency()
end, 3000)

-- Export module
return M