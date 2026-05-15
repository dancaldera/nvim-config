-- ============================================================================
-- File Explorer Configuration (neo-tree.nvim)
-- ============================================================================

return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	cmd = "Neotree",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	keys = {
		{ "\\", "<cmd>Neotree toggle<CR>", desc = "Toggle file explorer" },
		{ "<leader>ee", "<cmd>Neotree toggle<CR>", desc = "Toggle file explorer" },
		{ "<leader>ef", "<cmd>Neotree reveal<CR>", desc = "Reveal current file in explorer" },
		{ "<leader>ec", "<cmd>Neotree close<CR>", desc = "Close file explorer" },
		{ "<leader>er", "<cmd>Neotree refresh<CR>", desc = "Refresh file explorer" },
		{ "<leader>eo", "<cmd>Neotree focus<CR>", desc = "Focus file explorer" },
		{
			"<C-e>",
			function()
				if vim.bo.filetype == "neo-tree" then
					vim.cmd.wincmd("p")
				else
					vim.cmd("Neotree focus")
				end
			end,
			desc = "Toggle focus between explorer and buffer",
		},
	},
	config = function()
		require("neo-tree").setup({})
	end,
}
