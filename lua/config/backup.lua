-- ============================================================================
-- Configuration Backup System
-- ============================================================================

local M = {}

-- Backup configuration
local backup_config = {
	backup_dir = vim.fn.stdpath("data") .. "/backups",
	max_backups = 10,
	exclude_patterns = {
		"*.log",
		"*.tmp",
		"*.swp",
		"*.swo",
		".git/",
		"__pycache__/",
		"node_modules/",
		".DS_Store",
	},
	include_patterns = {
		"*.lua",
		"*.vim",
		"*.md",
		".gitignore",
		".gitmodules",
	},
}

-- Ensure backup directory exists
local function ensure_backup_dir()
	local backup_dir = backup_config.backup_dir
	if vim.fn.isdirectory(backup_dir) == 0 then
		vim.fn.mkdir(backup_dir, "p")
		vim.notify("Created backup directory: " .. backup_dir, vim.log.levels.INFO)
	end
	return backup_dir
end

-- Create timestamp for backup
local function get_timestamp()
	return os.date("%Y%m%d_%H%M%S")
end

-- Get list of files to backup
local function get_backup_files()
	local config_dir = vim.fn.stdpath("config")
	local files = {}

	-- Find files matching include patterns
	for _, pattern in ipairs(backup_config.include_patterns) do
		local cmd = string.format("find '%s' -name '%s' -type f", config_dir, pattern)
		local handle = io.popen(cmd)
		if handle then
			for line in handle:lines() do
				table.insert(files, line)
			end
			handle:close()
		end
	end

	-- Filter out excluded patterns
	local filtered_files = {}
	for _, file in ipairs(files) do
		local should_include = true
		for _, exclude_pattern in ipairs(backup_config.exclude_patterns) do
			if file:match(exclude_pattern:gsub("%*", ".*")) then
				should_include = false
				break
			end
		end
		if should_include then
			table.insert(filtered_files, file)
		end
	end

	return filtered_files
end

-- Create backup
local function create_backup()
	local backup_dir = ensure_backup_dir()
	local timestamp = get_timestamp()
	local backup_path = backup_dir .. "/config_backup_" .. timestamp
	local config_dir = vim.fn.stdpath("config")

	-- Create backup directory
	vim.fn.mkdir(backup_path, "p")

	local files = get_backup_files()
	local backed_up = 0
	local failed = 0

	for _, file in ipairs(files) do
		local relative_path = file:gsub("^" .. config_dir .. "/", "")
		local target_dir = backup_path .. "/" .. vim.fn.fnamemodify(relative_path, ":h")

		-- Ensure target directory exists
		vim.fn.mkdir(target_dir, "p")

		-- Copy file
		local copy_cmd = string.format("cp '%s' '%s'", file, target_dir .. "/" .. vim.fn.fnamemodify(relative_path, ":t"))
		local result = os.execute(copy_cmd)

		if result == 0 then
			backed_up = backed_up + 1
		else
			failed = failed + 1
			vim.notify("Failed to backup: " .. relative_path, vim.log.levels.WARN)
		end
	end

	-- Create backup metadata
	local metadata = {
		timestamp = timestamp,
		files_count = backed_up,
		failed_count = failed,
		nvim_version = vim.version().string,
		lazy_plugins = nil,
	}

	-- Get plugin info
	local ok, lazy = pcall(require, "lazy")
	if ok then
		local stats = lazy.stats()
		metadata.lazy_plugins = {
			loaded = stats.loaded,
			count = stats.count,
			startuptime = stats.startuptime,
		}
	end

	-- Write metadata file
	local metadata_file = io.open(backup_path .. "/metadata.json", "w")
	if metadata_file then
		metadata_file:write(vim.json.encode(metadata))
		metadata_file:close()
	end

	vim.notify(
		string.format("✓ Backup created: %s (%d files backed up, %d failed)", timestamp, backed_up, failed),
		failed > 0 and vim.log.levels.WARN or vim.log.levels.INFO
	)

	return timestamp
end

-- Clean old backups
local function clean_old_backups()
	local backup_dir = ensure_backup_dir()
	local cmd = string.format("find '%s' -maxdepth 1 -type d -name 'config_backup_*' | sort -r", backup_dir)
	local handle = io.popen(cmd)

	if not handle then
		return
	end

	local backups = {}
	for line in handle:lines() do
		table.insert(backups, line)
	end
	handle:close()

	-- Remove excess backups
	if #backups > backup_config.max_backups then
		for i = backup_config.max_backups + 1, #backups do
			local remove_cmd = string.format("rm -rf '%s'", backups[i])
			os.execute(remove_cmd)
			vim.notify("Removed old backup: " .. vim.fn.fnamemodify(backups[i], ":t"), vim.log.levels.DEBUG)
		end
	end
end

-- List available backups
function M.list_backups()
	local backup_dir = ensure_backup_dir()
	local cmd = string.format("find '%s' -maxdepth 1 -type d -name 'config_backup_*' | sort -r", backup_dir)
	local handle = io.popen(cmd)

	if not handle then
		return {}
	end

	local backups = {}
	for line in handle:lines() do
		local backup_name = vim.fn.fnamemodify(line, ":t")
		local metadata_file = line .. "/metadata.json"

		local metadata = {}
		local file = io.open(metadata_file, "r")
		if file then
			local content = file:read("*a")
			if content and content ~= "" then
				metadata = vim.json.decode(content)
			end
			file:close()
		end

		table.insert(backups, {
			name = backup_name,
			path = line,
			metadata = metadata,
		})
	end
	handle:close()

	return backups
end

-- Restore from backup
function M.restore_backup(backup_name)
	local backup_dir = ensure_backup_dir()
	local backup_path = backup_dir .. "/" .. backup_name
	local config_dir = vim.fn.stdpath("config")

	if vim.fn.isdirectory(backup_path) == 0 then
		vim.notify("Backup not found: " .. backup_name, vim.log.levels.ERROR)
		return false
	end

	-- Confirm restoration
	local choice = vim.fn.confirm(
		string.format("Restore configuration from backup '%s'? This will overwrite your current configuration.", backup_name),
		"&Yes\n&No",
		2
	)

	if choice ~= 1 then
		vim.notify("Restoration cancelled", vim.log.levels.INFO)
		return false
	end

	-- Create backup of current config before restoring
	vim.notify("Creating backup of current configuration...", vim.log.levels.INFO)
	create_backup()

	-- Remove current config files (excluding .git and other important files)
	local cmd = string.format("find '%s' -name '*.lua' -delete", config_dir)
	os.execute(cmd)

	-- Restore from backup
	local restore_cmd = string.format("cp -r '%s'/* '%s'/", backup_path, config_dir)
	local result = os.execute(restore_cmd)

	if result == 0 then
		vim.notify("✓ Configuration restored from backup: " .. backup_name, vim.log.levels.INFO)
		vim.notify("Please restart Neovim to complete the restoration", vim.log.levels.WARN)
		return true
	else
		vim.notify("✗ Failed to restore configuration from backup: " .. backup_name, vim.log.levels.ERROR)
		return false
	end
end

-- Auto backup function
function M.auto_backup()
	local should_backup = false

	-- Check if significant changes have been made
	local last_backup_file = backup_config.backup_dir .. "/last_backup.txt"
	local last_backup_time = 0

	if vim.fn.filereadable(last_backup_file) == 1 then
		local file = io.open(last_backup_file, "r")
		if file then
			last_backup_time = tonumber(file:read("*a")) or 0
			file:close()
		end
	end

	local current_time = os.time()
	local hours_since_last_backup = (current_time - last_backup_time) / 3600

	-- Auto backup if it's been more than 24 hours
	if hours_since_last_backup >= 24 then
		should_backup = true
	end

	-- Also check if configuration files have been modified recently
	if not should_backup then
		local config_dir = vim.fn.stdpath("config")
		local cmd = string.format("find '%s' -name '*.lua' -newer '%s' 2>/dev/null | head -1",
			config_dir, os.date("%Y-%m-%d %H:%M:%S", last_backup_time))
		local handle = io.popen(cmd)
		local result = handle:read("*a")
		handle:close()

		if result and result ~= "" then
			should_backup = true
		end
	end

	if should_backup then
		local timestamp = create_backup()

		-- Update last backup time
		local file = io.open(last_backup_file, "w")
		if file then
			file:write(tostring(current_time))
			file:close()
		end

		-- Clean old backups
		clean_old_backups()
	end
end

-- Manual backup command
function M.manual_backup()
	local timestamp = create_backup()
	clean_old_backups()
	return timestamp
end

-- Setup auto backup on startup
vim.defer_fn(function()
	M.auto_backup()
end, 10000) -- Run 10 seconds after startup

-- Create user commands
vim.api.nvim_create_user_command("ConfigBackup", function()
	M.manual_backup()
end, { desc = "Create configuration backup" })

vim.api.nvim_create_user_command("ConfigRestore", function(opts)
	local backup_name = opts.args
	if backup_name == "" then
		local backups = M.list_backups()
		if #backups == 0 then
			vim.notify("No backups found", vim.log.levels.WARN)
			return
		end

		-- Show recent backups
		vim.notify("Recent backups:", vim.log.levels.INFO)
		for i = 1, math.min(5, #backups) do
			local backup = backups[i]
			local info = string.format("  %s (%d files)", backup.name, backup.metadata.files_count or 0)
			vim.notify(info, vim.log.levels.INFO)
		end
		vim.notify("Use ':ConfigRestore <backup_name>' to restore", vim.log.levels.INFO)
	else
		M.restore_backup(backup_name)
	end
end, {
	nargs = "?",
	complete = function()
		local backups = M.list_backups()
		return vim.tbl_map(function(b) return b.name end, backups)
	end,
	desc = "Restore configuration from backup",
})

vim.api.nvim_create_user_command("ConfigListBackups", function()
	local backups = M.list_backups()
	if #backups == 0 then
		vim.notify("No backups found", vim.log.levels.INFO)
		return
	end

	vim.notify("Available backups:", vim.log.levels.INFO)
	for _, backup in ipairs(backups) do
		local info = string.format("  %s (%d files, %s)",
			backup.name,
			backup.metadata.files_count or 0,
			backup.metadata.timestamp or "unknown"
		)
		vim.notify(info, vim.log.levels.INFO)
	end
end, { desc = "List configuration backups" })

return M