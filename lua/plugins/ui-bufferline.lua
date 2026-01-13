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

	-- Buffer line (nvim-cokeline handles buffer management)
	{
		"willothy/nvim-cokeline",
		event = { "BufAdd", "BufNewFile" },
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			local get_hex = require("cokeline.hlgroups").get_hl_attr

			require("cokeline").setup({
				-- Only show bufferline in editor windows (not spanning sidebars)
				show_if_buffers_are_at_least = 1,

				-- Enable buffer picking
				pick = {
					use_filename = true,
					letters = "asdfjkl;ghnmxcvbziowerutyqpASDFJKLGHNMXCVBZIOWERUTYQP",
				},

				default_hl = {
					fg = function(buffer)
						return buffer.is_focused and get_hex("Normal", "fg") or get_hex("Comment", "fg")
					end,
					bg = function(buffer)
						return buffer.is_focused and get_hex("ColorColumn", "bg") or get_hex("Normal", "bg")
					end,
				},

				-- Sidebar configuration (NvimTree offset)
				sidebar = {
					filetype = { "NvimTree", "neo-tree" },
					components = {
						{
							text = "  File Explorer",
							fg = get_hex("Comment", "fg"),
							bg = get_hex("Normal", "bg"),
							bold = true,
						},
					},
				},

				components = {
					{
						text = " ",
						bg = function(buffer)
							return buffer.is_focused and get_hex("ColorColumn", "bg") or get_hex("Normal", "bg")
						end,
					},
					-- File icon
					{
						text = function(buffer)
							return buffer.devicon.icon
						end,
						fg = function(buffer)
							return buffer.devicon.color
						end,
						bg = function(buffer)
							return buffer.is_focused and get_hex("ColorColumn", "bg") or get_hex("Normal", "bg")
						end,
					},
					{
						text = " ",
						bg = function(buffer)
							return buffer.is_focused and get_hex("ColorColumn", "bg") or get_hex("Normal", "bg")
						end,
					},
					-- Filename
					{
						text = function(buffer)
							return buffer.filename
						end,
						truncation = {
							tail = true,
							head = false,
							max_width = 30,
						},
						fg = function(buffer)
							return buffer.is_focused and get_hex("Normal", "fg") or get_hex("Comment", "fg")
						end,
						bg = function(buffer)
							return buffer.is_focused and get_hex("ColorColumn", "bg") or get_hex("Normal", "bg")
						end,
						bold = function(buffer)
							return buffer.is_focused
						end,
						italic = function(buffer)
							return not buffer.is_focused
						end,
					},
					-- Modified indicator
					{
						text = function(buffer)
							return buffer.is_modified and "●" or ""
						end,
						fg = function(buffer)
							return buffer.is_modified and get_hex("DiagnosticWarn", "fg") or nil
						end,
						bg = function(buffer)
							return buffer.is_focused and get_hex("ColorColumn", "bg") or get_hex("Normal", "bg")
						end,
					},
					-- Diagnostics
					{
						text = function(buffer)
							local errors = buffer.diagnostics.errors
							local warnings = buffer.diagnostics.warnings
							if errors > 0 then
								return errors
							elseif warnings > 0 then
								return warnings
							end
							return ""
						end,
						fg = function(buffer)
							if buffer.diagnostics.errors > 0 then
								return get_hex("DiagnosticError", "fg")
							elseif buffer.diagnostics.warnings > 0 then
								return get_hex("DiagnosticWarn", "fg")
							end
						end,
						bg = function(buffer)
							return buffer.is_focused and get_hex("ColorColumn", "bg") or get_hex("Normal", "bg")
						end,
					},
					{
						text = " ",
						bg = function(buffer)
							return buffer.is_focused and get_hex("ColorColumn", "bg") or get_hex("Normal", "bg")
						end,
					},
					-- Close button
					{
						text = "×",
						fg = get_hex("Comment", "fg"),
						bg = function(buffer)
							return buffer.is_focused and get_hex("ColorColumn", "bg") or get_hex("Normal", "bg")
						end,
						delete_buffer_on_left_click = true,
					},
					{
						text = " ",
						bg = function(buffer)
							return buffer.is_focused and get_hex("ColorColumn", "bg") or get_hex("Normal", "bg")
						end,
					},
				},
			})

			-- Session restoration fix
			vim.api.nvim_create_autocmd("BufAdd", {
				callback = function()
					vim.schedule(function()
						pcall(vim.cmd.redrawtabline)
					end)
				end,
			})
		end,
	},
}
