-- ============================================================================
-- UI - Buffer Line
-- Buffer line display and buffer management
-- ============================================================================

return {
	-- Better buffer closing (keeps window open and selects nearest buffer)
	{
		"echasnovski/mini.bufremove",
		version = false,
		keys = {
			{
				"<leader>bd",
				function()
					local bd = require("mini.bufremove").delete
					if vim.bo.modified then
						local choice =
							vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
						if choice == 1 then -- Yes
							vim.cmd.write()
							bd(0)
						elseif choice == 2 then -- No
							bd(0, true)
						end
					else
						bd(0)
					end
				end,
				desc = "Delete Buffer",
			},
			{
				"<leader>bD",
				function()
					require("mini.bufremove").delete(0, true)
				end,
				desc = "Delete Buffer (Force)",
			},
		},
	},

	-- Buffer line (bufferline.nvim for VS Code-like tabs)
	{
		"akinsho/bufferline.nvim",
		version = "*",
		event = { "BufAdd", "BufNewFile" },
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local bufferline = require("bufferline")
			bufferline.setup({
				options = {
					mode = "buffers",
					separator_style = "slant", -- VS Code-like angled tabs
					themable = true,

					-- Integrate with mini.bufremove
					close_command = function(bufnum)
						require("mini.bufremove").delete(bufnum, false)
					end,
					right_mouse_command = function(bufnum)
						require("mini.bufremove").delete(bufnum, false)
					end,

					-- Visual styling
					indicator = { icon = "▎", style = "icon" },
					buffer_close_icon = "󰅖",
					modified_icon = "●",

					-- Diagnostics
					diagnostics = "nvim_lsp",
					diagnostics_indicator = function(count, level)
						local icon = level:match("error") and " " or " "
						return " " .. icon .. count
					end,

					-- NvimTree offset
					offsets = {
						{
							filetype = "NvimTree",
							text = "File Explorer",
							text_align = "center",
							separator = true,
						},
					},

					-- Features
					color_icons = true,
					show_buffer_close_icons = true,
					hover = { enabled = true, delay = 200, reveal = { "close" } },

					-- Buffer picking
					pick = { alphabet = "asdfjkl;ghnmxcvbziowerutyqpASDFJKLGHNMXCVBZIOWERUTYQP" },
				},
				highlights = {
					modified_selected = { fg = "#fabd2f" },
					modified = { fg = "#fabd2f" },
					modified_visible = { fg = "#fabd2f" },
				},
			})
		end,
	},
}
