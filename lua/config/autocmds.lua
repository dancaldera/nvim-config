-- ============================================================================
-- Auto Commands Configuration
-- ============================================================================

-- Clean stale startup buffers restored from old sessions or directory launches.
vim.api.nvim_create_autocmd("VimEnter", {
	group = vim.api.nvim_create_augroup("StartupBufferCleanup", { clear = true }),
	callback = function()
		local ok, buffers = pcall(require, "config.buffers")
		if not ok then
			return
		end

		buffers.switch_current_blank_to_real_buffer()

		local current = vim.api.nvim_get_current_buf()
		if buffers.has_real_file_buffers(current) or buffers.is_empty_directory_buffer(current) then
			buffers.hide_blank_buffers(current)
			buffers.hide_blank_if_no_real_buffers(current)
		end

		vim.schedule(buffers.focus_file_explorer_if_no_file_buffers)
	end,
})

-- Auto-save on focus lost (predictable, avoids writes on buffer switches)
vim.api.nvim_create_autocmd({ "FocusLost" }, {
	group = vim.api.nvim_create_augroup("AutoSave", { clear = true }),
	pattern = "*",
	callback = function()
		-- Only save if:
		-- 1. Buffer is modified
		-- 2. Buffer is not readonly
		-- 3. Buffer has a valid filename
		-- 4. Buffer is a normal file (not special buffers like terminals, help, etc.)
		if
			vim.bo.modified
			and not vim.bo.readonly
			and vim.bo.modifiable
			and vim.fn.expand("%") ~= ""
			and vim.bo.buftype == ""
		then
			vim.cmd("silent! write")
		end
	end,
})
