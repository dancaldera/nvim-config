-- ============================================================================
-- UI - Statusline
-- Lualine configuration with custom Gruvbox theme
-- ============================================================================

return {
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		event = "VeryLazy",
		config = function()
			local lualine = require("lualine")
			local lazy_status = require("lazy.status")

			-- Custom Gruvbox theme
			local colors = {
				bg = "#1d2021",
				fg = "#ebdbb2",
				green = "#b8bb26",
				blue = "#83a598",
				purple = "#d3869b",
				red = "#fb4934",
				yellow = "#fabd2f",
				orange = "#fe8019",
			}

			local custom_theme = {
				normal = { a = { bg = colors.green, fg = colors.bg, gui = "bold" } },
				insert = { a = { bg = colors.blue, fg = colors.bg, gui = "bold" } },
				visual = { a = { bg = colors.purple, fg = colors.bg, gui = "bold" } },
				replace = { a = { bg = colors.red, fg = colors.bg, gui = "bold" } },
				command = { a = { bg = colors.yellow, fg = colors.bg, gui = "bold" } },
				terminal = { a = { bg = colors.orange, fg = colors.bg, gui = "bold" } },
			}

			lualine.setup({
				options = {
					theme = custom_theme,
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
							color = { fg = "#a89984" }, -- Grey for context
						},
					},
					lualine_x = {
						{
							lazy_status.updates,
							cond = lazy_status.has_updates,
							color = { fg = "#ff9e64" },
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
							color = { fg = "#fce566" },
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
