-- ============================================================================
-- Auto Commands Configuration
-- ============================================================================

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
