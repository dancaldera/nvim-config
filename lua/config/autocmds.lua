-- ============================================================================
-- Autocmds (additions on top of LazyVim defaults)
-- ============================================================================

-- Drop startup directory buffers (`nvim <dir>` with netrw disabled leaves the
-- directory itself as a buffer). Left in place, focusing its window arms
-- neo-tree's netrw hijack, whose debounced callback then swaps the next file
-- opened from the tree for a fresh empty buffer. Plain `nvim` is untouched
-- (no directory buffers), so the dashboard still claims buffer 1.
vim.api.nvim_create_autocmd("VimEnter", {
	group = vim.api.nvim_create_augroup("StartupBufferCleanup", { clear = true }),
	callback = function()
		for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
			if vim.fn.isdirectory(vim.api.nvim_buf_get_name(info.bufnr)) == 1 then
				pcall(vim.api.nvim_buf_delete, info.bufnr, { force = true })
			end
		end
	end,
})

-- Reload files changed outside of Neovim when the window regains focus
vim.api.nvim_create_autocmd("FocusGained", {
	group = vim.api.nvim_create_augroup("AutoChecktime", { clear = true }),
	callback = function()
		if vim.bo.buftype ~= "terminal" then
			vim.cmd("silent! checktime")
		end
	end,
})

-- Auto-save on focus lost
vim.api.nvim_create_autocmd({ "FocusLost" }, {
	group = vim.api.nvim_create_augroup("AutoSave", { clear = true }),
	pattern = "*",
	callback = function()
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
