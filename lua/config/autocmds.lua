-- ============================================================================
-- Auto Commands Configuration
-- ============================================================================

-- Clean stale startup buffers restored from old sessions or directory launches.
vim.api.nvim_create_autocmd("VimEnter", {
	group = vim.api.nvim_create_augroup("StartupBufferCleanup", { clear = true }),
	callback = function()
		local current = vim.api.nvim_get_current_buf()
		local name = vim.api.nvim_buf_get_name(current)

		-- If current buffer is an empty [No Name] and there's a real file, switch to it
		if name == "" and vim.bo[current].buftype == "" and vim.api.nvim_buf_line_count(current) == 1 then
			local first_line = vim.api.nvim_buf_get_lines(current, 0, 1, false)[1] or ""
			if first_line == "" then
				for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
					if info.bufnr ~= current then
						local other_name = vim.api.nvim_buf_get_name(info.bufnr)
						if other_name ~= "" and vim.fn.filereadable(other_name) == 1 then
							vim.api.nvim_win_set_buf(0, info.bufnr)
							vim.bo[current].buflisted = false
							break
						end
					end
				end
			end
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
