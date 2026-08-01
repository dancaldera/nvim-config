-- ============================================================================
-- UI Configuration (statusline, bufferline, indicators, folding)
-- ============================================================================

return {
	-- Statusline (lualine)
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-mini/mini.nvim" },
		event = "VeryLazy",
		config = function()
			local lazy_status = require("lazy.status")
			local disabled_statusline_filetypes = {
				help = true,
				lazy = true,
				mason = true,
				qf = true,
				snacks_dashboard = true,
				snacks_notif_history = true,
				snacks_picker_input = true,
				snacks_picker_list = true,
			}

			local function is_normal_file_buffer(buf)
				buf = buf or 0
				return vim.bo[buf].buftype == "" and not disabled_statusline_filetypes[vim.bo[buf].filetype]
			end

			require("lualine").setup({
				options = {
					theme = "auto",
					component_separators = { left = "|", right = "|" },
					section_separators = { left = "", right = "" },
					globalstatus = true,
					disabled_filetypes = {
						statusline = vim.tbl_keys(disabled_statusline_filetypes),
					},
					ignore_focus = function()
						return not is_normal_file_buffer()
					end,
				},
				sections = {
					lualine_c = {
						{ "filename" },
					},
					lualine_x = {
						{ lazy_status.updates, cond = lazy_status.has_updates },
						{ "encoding" },
						{ "fileformat" },
						{ "filetype" },
					},
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = { "filename" },
					lualine_x = { "location" },
					lualine_y = {},
					lualine_z = {},
				},
			})
		end,
	},

	-- Buffer line (tabs)
	{
		"akinsho/bufferline.nvim",
		version = "*",
		event = { "BufAdd", "BufNewFile" },
		dependencies = { "nvim-mini/mini.nvim" },
		config = function()
			require("bufferline").setup()
		end,
	},
}
