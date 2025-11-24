-- ============================================================================
-- Auto Commands Configuration
-- ============================================================================

-- Auto-save on focus lost or buffer leave
vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave" }, {
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
			and vim.fn.expand("%") ~= ""
			and vim.bo.buftype == ""
			and vim.fn.filereadable(vim.fn.expand("%")) == 1
		then
			vim.cmd("silent! write")
		end
	end,
})
