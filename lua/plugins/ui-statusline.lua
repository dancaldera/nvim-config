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
