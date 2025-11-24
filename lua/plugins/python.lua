-- ============================================================================
-- Python Environment Configuration
-- ============================================================================

return {
	{
		"AckslD/swenv.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		event = { "BufReadPre *.py", "BufNewFile *.py" },
		keys = {
			{
				"<leader>pv",
				function()
					require("swenv.api").pick_venv()
				end,
				desc = "Pick Python venv",
			},
		},
		config = function()
			require("swenv").setup({
				-- Get venvs from these locations
				venvs_path = vim.fn.expand("~/.virtualenvs"),
				-- Search both global and project-local venvs
				get_venvs = function(venvs_path)
					local venvs = require("swenv.api").get_venvs(venvs_path)
					-- Add project-local venvs
					local cwd = vim.fn.getcwd()
					local local_venv_names = { ".venv", "venv", ".env", "env" }
					for _, name in ipairs(local_venv_names) do
						local path = cwd .. "/" .. name
						if vim.fn.isdirectory(path) == 1 then
							table.insert(venvs, 1, { name = name .. " (local)", path = path })
						end
					end
					return venvs
				end,
				-- Notify LSP when venv changes
				post_set_venv = function()
					vim.cmd("LspRestart")
				end,
			})
		end,
	},
}
