-- ============================================================================
-- Office Document Preview
-- ============================================================================

local M = {}

local group = vim.api.nvim_create_augroup("OfficePreview", { clear = true })
local office_patterns = { "*.doc", "*.docx", "*.odt", "*.rtf", "*.xlsx" }
local google_sheets_url = "https://docs.google.com/spreadsheets/"
local xlsx_script = vim.fn.stdpath("config") .. "/scripts/office_xlsx_preview.py"

local function notify(message, level)
	vim.notify(message, level or vim.log.levels.INFO, { title = "Office View" })
end

local function split_lines(text)
	if not text or text == "" then
		return { "" }
	end

	local normalized = text:gsub("\r\n", "\n"):gsub("\r", "\n")
	local lines = vim.split(normalized, "\n", { plain = true })
	if lines[#lines] == "" then
		table.remove(lines, #lines)
	end

	return #lines > 0 and lines or { "" }
end

local function run_command(cmd)
	local result = vim.system(cmd, { text = true }):wait()
	return {
		code = result.code or 1,
		stdout = result.stdout or "",
		stderr = result.stderr or "",
	}
end

local function parse_metadata(stderr)
	local metadata = {}
	for line in stderr:gmatch("[^\r\n]+") do
		local key, value = line:match("^([%w_]+)=(.*)$")
		if key and value then
			metadata[key] = value
		end
	end
	return metadata
end

local function apply_preview_buffer(bufnr, lines, opts)
	opts = opts or {}

	vim.bo[bufnr].modifiable = true
	vim.bo[bufnr].readonly = false
	vim.bo[bufnr].swapfile = false
	vim.bo[bufnr].bufhidden = "hide"

	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

	if opts.filetype then
		vim.bo[bufnr].filetype = opts.filetype
	end

	vim.bo[bufnr].modified = false
	vim.bo[bufnr].modifiable = false
	vim.bo[bufnr].readonly = true

	vim.b[bufnr].office_view = opts.state or nil
end

local function browser_command(target)
	local override = vim.g.office_view_browser_command
	if type(override) == "string" and override ~= "" then
		return { override, target }
	end

	if type(override) == "table" and #override > 0 then
		local cmd = vim.deepcopy(override)
		table.insert(cmd, target)
		return cmd
	end

	return { "open", target }
end

local function current_source_path(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local state = vim.b[bufnr].office_view
	local path = state and state.source or vim.api.nvim_buf_get_name(bufnr)

	if path == "" then
		return nil
	end

	return vim.fn.fnamemodify(path, ":p")
end

local function show_info(bufnr)
	local state = vim.b[bufnr].office_view
	if not state then
		notify("Current buffer is not an Office preview.", vim.log.levels.WARN)
		return
	end

	local lines = {
		string.format("Source: %s", state.source),
		string.format("Kind: %s", state.kind),
		string.format("Converter: %s", state.converter),
	}

	if state.sheet and state.sheet ~= "" then
		table.insert(lines, string.format("Sheet: %s", state.sheet))
	end

	if state.backend and state.backend ~= "" then
		table.insert(lines, string.format("Backend: %s", state.backend))
	end

	notify(table.concat(lines, "\n"))
end

local function enable_csvview(bufnr)
	vim.schedule(function()
		if not vim.api.nvim_buf_is_valid(bufnr) then
			return
		end

		vim.api.nvim_buf_call(bufnr, function()
			pcall(vim.cmd, "silent CsvViewEnable display_mode=border")
		end)
	end)
end

local function preview_doc(path, bufnr)
	local extension = vim.fn.fnamemodify(path, ":e"):lower()
	local converters = {}

	if extension == "docx" or extension == "odt" or extension == "rtf" then
		table.insert(converters, {
			label = "pandoc",
			filetype = "markdown",
			cmd = { "pandoc", "--from", extension, "--to", "gfm", path },
		})
	end

	table.insert(converters, {
		label = "textutil",
		filetype = "text",
		cmd = { "textutil", "-convert", "txt", "-stdout", path },
	})

	for _, converter in ipairs(converters) do
		local result = run_command(converter.cmd)
		if result.code == 0 and result.stdout ~= "" then
			apply_preview_buffer(bufnr, split_lines(result.stdout), {
				filetype = converter.filetype,
				state = {
					source = path,
					kind = extension,
					converter = converter.label,
				},
			})
			return true
		end
	end

	notify(
		string.format("Unable to preview %s with pandoc/textutil.", vim.fn.fnamemodify(path, ":t")),
		vim.log.levels.ERROR
	)
	return false
end

local function preview_xlsx(path, bufnr)
	local result = run_command({ "python3", xlsx_script, path })
	if result.code ~= 0 then
		local details = result.stderr ~= "" and result.stderr or "Missing or failed xlsx converter."
		notify(details, vim.log.levels.ERROR)
		return false
	end

	local metadata = parse_metadata(result.stderr)
	local converter = metadata.backend == "openpyxl" and "python3 + openpyxl" or "python3 stdlib"

	apply_preview_buffer(bufnr, split_lines(result.stdout), {
		filetype = "tsv",
		state = {
			source = path,
			kind = "xlsx",
			converter = converter,
			sheet = metadata.sheet or "",
			backend = metadata.backend or "stdlib",
		},
	})
	enable_csvview(bufnr)
	return true
end

function M.open_in_browser(path)
	if not path or path == "" then
		notify("No file path available for browser open.", vim.log.levels.WARN)
		return false
	end

	local full_path = vim.fn.fnamemodify(path, ":p")
	local extension = vim.fn.fnamemodify(full_path, ":e"):lower()
	local target = extension == "xlsx" and google_sheets_url or vim.uri_from_fname(full_path)
	local result = run_command(browser_command(target))

	if result.code ~= 0 then
		local details = result.stderr ~= "" and result.stderr or "Unable to open the default browser."
		notify(details, vim.log.levels.ERROR)
		return false
	end

	if extension == "xlsx" then
		notify(string.format("Opened Google Sheets. Import this file: %s", full_path))
	else
		notify(string.format("Opened in default browser: %s", full_path))
	end

	return true
end

function M.open_current_in_browser(bufnr)
	local path = current_source_path(bufnr)
	if not path then
		notify("Current buffer does not have a source path.", vim.log.levels.WARN)
		return false
	end

	return M.open_in_browser(path)
end

function M.preview(path, bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local extension = vim.fn.fnamemodify(path, ":e"):lower()

	if extension == "xlsx" then
		return preview_xlsx(path, bufnr)
	end

	return preview_doc(path, bufnr)
end

function M.refresh(bufnr)
	local path = current_source_path(bufnr)
	if not path then
		notify("Current buffer does not have a source path.", vim.log.levels.WARN)
		return
	end

	M.preview(path, bufnr)
end

function M.setup()
	vim.api.nvim_create_autocmd("BufReadCmd", {
		group = group,
		pattern = office_patterns,
		callback = function(args)
			M.preview(args.file, args.buf)
		end,
	})

	vim.api.nvim_create_user_command("OfficeViewRefresh", function()
		M.refresh()
	end, { desc = "Refresh Office preview" })

	vim.api.nvim_create_user_command("OfficeViewInfo", function()
		show_info(0)
	end, { desc = "Show Office preview details" })

	vim.api.nvim_create_user_command("OfficeOpenBrowser", function()
		M.open_current_in_browser()
	end, { desc = "Open Office file in default browser" })
end

return M
