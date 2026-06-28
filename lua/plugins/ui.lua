-- ============================================================================
-- UI Configuration (statusline, bufferline, indicators, folding)
-- ============================================================================

return {
	-- Statusline (lualine)
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		event = "VeryLazy",
		config = function()
			local lazy_status = require("lazy.status")
			local disabled_statusline_filetypes = {
				NvimTree = true,
				Trouble = true,
				dashboard = true,
				help = true,
				lazy = true,
				mason = true,
				notify = true,
				qf = true,
				trouble = true,
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
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("bufferline").setup({
				options = {
					offsets = {
						{
							filetype = "NvimTree",
							text = "File Explorer",
							text_align = "center",
							separator = true,
						},
					},
				},
			})
		end,
	},

	-- Indentation scope indicator
	{
		"echasnovski/mini.indentscope",
		version = false,
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			symbol = "│",
			options = { try_as_border = true },
		},
		init = function()
			local function disable_indentscope(args)
				vim.b[args.buf].miniindentscope_disable = true
			end

			local group = vim.api.nvim_create_augroup("miniindentscope", { clear = true })

			vim.api.nvim_create_autocmd("FileType", {
				group = group,
				pattern = {
					"help",
					"dashboard",
					"NvimTree",
					"Trouble",
					"trouble",
					"lazy",
					"mason",
					"notify",
				},
				callback = disable_indentscope,
			})

			vim.api.nvim_create_autocmd("TermOpen", {
				group = group,
				callback = disable_indentscope,
			})
		end,
	},
}
