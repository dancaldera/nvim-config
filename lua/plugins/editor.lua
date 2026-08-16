-- ============================================================================
-- Editor Plugins (mini.nvim, which-key)
-- ============================================================================

return {
	-- Small editing primitives, statusline, tabline, and icons in one dependency
	{
		"nvim-mini/mini.nvim",
		version = false,
		event = "VeryLazy",
		config = function()
			require("mini.pairs").setup({
				modes = { insert = true, command = false, terminal = false },
			})
			require("mini.surround").setup({ silent = true })

			local ai = require("mini.ai")
			ai.setup({
				n_lines = 500,
				custom_textobjects = {
					o = ai.gen_spec.treesitter({
						a = { "@block.outer", "@conditional.outer", "@loop.outer" },
						i = { "@block.inner", "@conditional.inner", "@loop.inner" },
					}, {}),
					f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
					c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
					t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
				},
			})

			require("mini.icons").setup()
			MiniIcons.mock_nvim_web_devicons()

			-- Statusline (replaces lualine; global via laststatus = 3 in options.lua)
			local statusline = require("mini.statusline")
			local lazy_status = require("lazy.status")
			local hidden_statusline_filetypes = {
				help = true,
				lazy = true,
				qf = true,
				snacks_dashboard = true,
				snacks_notif_history = true,
				snacks_picker_input = true,
				snacks_picker_list = true,
			}

			statusline.setup({
				use_icons = true,
				content = {
					active = function()
						if vim.bo.buftype ~= "" or hidden_statusline_filetypes[vim.bo.filetype] then
							return ""
						end
						local lazy_updates = lazy_status.has_updates() and lazy_status.updates() or ""
						return statusline.combine_groups({
							{ hl = "MiniStatuslineMode", strings = { statusline.section_mode({ trunc_width = 120 }) } },
							{
								hl = "MiniStatuslineModeExtra",
								strings = {
									statusline.section_git({ trunc_width = 40 }),
									statusline.section_diagnostics({ trunc_width = 75 }),
								},
							},
							"%<",
							{
								hl = "MiniStatuslineFilename",
								strings = { statusline.section_filename({ trunc_width = 140 }) },
							},
							"%=",
							{ strings = { lazy_updates } },
							{ strings = { statusline.section_fileinfo({ trunc_width = 999 }) } },
							{
								hl = "MiniStatuslineLocation",
								strings = { statusline.section_location({ trunc_width = 999 }) },
							},
						})
					end,
				},
			})

			-- Buffer tabline (replaces bufferline.nvim)
			require("mini.tabline").setup({
				show_icons = true,
			})
		end,
	},

	-- Which-key
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = { delay = 300 },
		config = function(_, opts)
			local wk = require("which-key")
			wk.setup(opts)
			wk.add({
				{ "<leader>b", group = "Buffer" },
				{ "<leader>c", group = "Code Actions" },
				{ "<leader>d", group = "Diagnostics" },
				{ "<leader>e", group = "File Explorer" },
				{ "<leader>f", group = "Find/Search" },
				{ "<leader>g", group = "Git" },
				{ "<leader>h", group = "Git Hunks" },
				{ "<leader>r", group = "Rename/Restart" },
				{ "<leader>s", group = "Split/Search" },
				{ "<leader>t", group = "Terminal/Toggle" },
				{ "<leader>x", group = "Diagnostics/Lists" },
			})
		end,
	},
}
