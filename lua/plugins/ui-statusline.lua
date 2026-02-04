-- ============================================================================
-- UI - Statusline
-- Lualine configuration with Kanagawa theme
-- ============================================================================

return {
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		event = "VeryLazy",
		config = function()
			local lualine = require("lualine")
			local lazy_status = require("lazy.status")

			lualine.setup({
				options = {
					theme = "kanagawa",
					component_separators = { left = "│", right = "│" },
					section_separators = { left = "", right = "" },
					globalstatus = true,
				},
				sections = {
					lualine_c = {
						{ "filename" },
						{
							function()
								return require("nvim-navic").get_location()
							end,
							cond = function()
								return package.loaded["nvim-navic"] and require("nvim-navic").is_available()
							end,
						},
					},
					lualine_x = {
						{
							lazy_status.updates,
							cond = lazy_status.has_updates,
						},
						{
							function()
								local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null")
								if vim.v.shell_error ~= 0 or vim.trim(git_root) == "" then
									return ""
								end

								local github = require("config.github")
								local account = github.get_current_account()

								if account then
									return string.format(" @%s", account)
								end

								return ""
							end,
							cond = function()
								local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null")
								return vim.v.shell_error == 0 and vim.trim(git_root) ~= "" and package.loaded["config.github"]
							end,
							color = { fg = "#7C3AED", gui = "bold" },
						},
						{
							function()
								-- Try swenv first, fallback to $VIRTUAL_ENV
								local ok, swenv = pcall(require, "swenv.api")
								if ok then
									local venv = swenv.get_current_venv()
									if venv then
										return venv.name
									end
								end
								-- Fallback: check $VIRTUAL_ENV
								local venv_path = vim.fn.getenv("VIRTUAL_ENV")
								if venv_path and venv_path ~= vim.NIL then
									return vim.fn.fnamemodify(venv_path, ":t")
								end
								return ""
							end,
							cond = function()
								return vim.bo.filetype == "python"
							end,
						},
						{ "encoding" },
						{ "fileformat" },
						{ "filetype" },
					},
				},
			})
		end,
	},
}
