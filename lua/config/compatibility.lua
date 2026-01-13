-- ============================================================================
-- Compatibility Check for Neovim 0.10+
-- ============================================================================

-- Check Neovim version compatibility
local version = vim.version()
if version.major == 0 and version.minor < 10 then
	vim.notify("This configuration requires Neovim 0.10+. Please upgrade.", vim.log.levels.ERROR)
	return
end

-- Recommend 0.11+ for native LSP features
if version.major == 0 and version.minor == 10 then
	vim.notify(
		"Neovim 0.10 detected. For best experience with native LSP features (vim.lsp.config), upgrade to 0.11+.",
		vim.log.levels.WARN
	)
	vim.g.nvim_version_compat = "0.10"
end

-- ============================================================================
-- Backwards compatibility shims for deprecated Neovim APIs
-- ============================================================================

-- Avoid vim.lsp.get_active_clients() deprecation noise while keeping behavior identical.
if vim.lsp and vim.lsp.get_clients and vim.lsp.get_active_clients then
	local get_clients = vim.lsp.get_clients
	---@diagnostic disable-next-line: duplicate-set-field
	vim.lsp.get_active_clients = function(opts)
		return get_clients(opts)
	end
end

-- Allow plugins still using the table-form vim.validate() signature without spamming warnings.
if vim.validate then
	local original_validate = vim.validate
	---@diagnostic disable-next-line: duplicate-set-field
	vim.validate = function(name, value, validator, optional)
		if validator == nil and type(name) == "table" then
			local original_deprecate = vim.deprecate
			---@diagnostic disable-next-line: duplicate-set-field
			vim.deprecate = function() end
			local ok, err = pcall(original_validate, name)
			vim.deprecate = original_deprecate
			if not ok then
				error(err, 2)
			end
			return
		end
		return original_validate(name, value, validator, optional)
	end
end
