-- ============================================================================
-- Git (gitsigns tweaks on top of LazyVim defaults)
--
-- LazyVim already provides the hunk keymaps on attach:
--   ]h/[h navigate, <leader>hs stage, <leader>hr reset, <leader>hS stage buffer,
--   <leader>hR reset buffer, <leader>hp preview, <leader>hb blame,
--   <leader>hB full blame, <leader>hd diffthis, <leader>hD diffthis(~),
--   <leader>hu undo stage, ih selects hunk
-- ============================================================================

return {
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "│" },
				change = { text = "│" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "┆" },
			},
			signcolumn = true,
			current_line_blame = true,
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "eol",
				delay = 1000,
			},
		},
	},
}
