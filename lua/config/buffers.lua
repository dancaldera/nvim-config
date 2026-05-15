-- ============================================================================
-- Buffer Utilities
-- ============================================================================

local M = {}

function M.is_valid(bufnr)
	return bufnr and vim.api.nvim_buf_is_valid(bufnr)
end

local function is_empty_normal_buffer(bufnr)
	if not M.is_valid(bufnr) then
		return false
	end

	if vim.bo[bufnr].buftype ~= "" or vim.bo[bufnr].modified then
		return false
	end

	if vim.api.nvim_buf_line_count(bufnr) > 1 then
		return false
	end

	local first_line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ""
	return first_line == ""
end

function M.is_blank(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()

	return is_empty_normal_buffer(bufnr) and vim.api.nvim_buf_get_name(bufnr) == ""
end

function M.is_empty_directory_buffer(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()

	local name = M.is_valid(bufnr) and vim.api.nvim_buf_get_name(bufnr) or ""
	return is_empty_normal_buffer(bufnr) and name ~= "" and vim.fn.isdirectory(name) == 1
end

function M.is_disposable_empty_buffer(bufnr)
	return M.is_blank(bufnr) or M.is_empty_directory_buffer(bufnr)
end

function M.is_file_explorer(bufnr)
	if not M.is_valid(bufnr) then
		return false
	end

	return vim.bo[bufnr].filetype == "NvimTree"
end

function M.is_real_file_buffer(bufnr)
	if not M.is_valid(bufnr) then
		return false
	end

	local name = vim.api.nvim_buf_get_name(bufnr)

	return vim.bo[bufnr].buflisted
		and vim.bo[bufnr].buftype == ""
		and not M.is_file_explorer(bufnr)
		and (vim.bo[bufnr].modified or (name ~= "" and vim.fn.filereadable(name) == 1))
end

function M.first_real_file_buffer(exclude)
	for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
		if info.bufnr ~= exclude and M.is_real_file_buffer(info.bufnr) then
			return info.bufnr
		end
	end
end

function M.has_real_file_buffers(exclude)
	return M.first_real_file_buffer(exclude) ~= nil
end

function M.hide_blank_buffers(exclude)
	local hidden = false

	for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
		if info.bufnr ~= exclude and M.is_disposable_empty_buffer(info.bufnr) then
			vim.bo[info.bufnr].buflisted = false
			hidden = true
		end
	end

	return hidden
end

function M.hide_blank_if_no_real_buffers(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()

	if M.is_disposable_empty_buffer(bufnr) and not M.has_real_file_buffers(bufnr) then
		vim.bo[bufnr].buflisted = false
		return true
	end

	return false
end

function M.switch_current_blank_to_real_buffer()
	local current = vim.api.nvim_get_current_buf()

	if not M.is_disposable_empty_buffer(current) then
		return false
	end

	local target = M.first_real_file_buffer(current)
	if not target then
		return false
	end

	vim.api.nvim_win_set_buf(0, target)
	vim.bo[current].buflisted = false
	return true
end

function M.create_unlisted_empty_buffer()
	return vim.api.nvim_create_buf(false, false)
end

function M.find_file_explorer_window()
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.api.nvim_win_is_valid(win) then
			local bufnr = vim.api.nvim_win_get_buf(win)
			if M.is_file_explorer(bufnr) then
				return win
			end
		end
	end
end

function M.focus_file_explorer_if_no_file_buffers()
	if M.has_real_file_buffers() then
		return false
	end

	local win = M.find_file_explorer_window()
	if win and vim.api.nvim_get_current_win() ~= win then
		vim.api.nvim_set_current_win(win)
		return true
	end

	return false
end

return M
