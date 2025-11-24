-- ============================================================================
-- Compatibility Check for Neovim 0.9.x
-- ============================================================================

-- Check Neovim version compatibility
local version = vim.version()
if version.major == 0 and version.minor < 9 then
	vim.notify("This configuration requires Neovim 0.9+. Please upgrade.", vim.log.levels.ERROR)
	return
end

if version.major == 0 and version.minor == 9 then
	-- Disable some features that require 0.10+
	vim.g.nvim_version_compat = "0.9"
end

-- ============================================================================
-- Backwards compatibility shims for deprecated Neovim APIs
-- ============================================================================

-- Avoid vim.lsp.get_active_clients() deprecation noise while keeping behavior identical.
if vim.lsp and vim.lsp.get_clients and vim.lsp.get_active_clients then
	local get_clients = vim.lsp.get_clients
	vim.lsp.get_active_clients = function(opts)
		return get_clients(opts)
	end
end

-- Allow plugins still using the table-form vim.validate() signature without spamming warnings.
if vim.validate then
	local original_validate = vim.validate
	vim.validate = function(name, value, validator, optional, message)
		if validator == nil and type(name) == "table" then
			local original_deprecate = vim.deprecate
			vim.deprecate = function() end
			local ok, err = pcall(original_validate, name, value, validator, optional, message)
			vim.deprecate = original_deprecate
			if not ok then
				error(err, 2)
			end
			return
		end
		return original_validate(name, value, validator, optional, message)
	end
end
