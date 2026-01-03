-- ============================================================================
-- UI Enhancement Plugins
-- ============================================================================

return {
	-- Clean indentation scope (only shows line for active code block)
	{
		"echasnovski/mini.indentscope",
		version = false,
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			symbol = "│",
			options = { try_as_border = true },
		},
		init = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = {
					"help",
					"alpha",
					"dashboard",
					"nvim-tree",
					"Trouble",
					"trouble",
					"lazy",
					"mason",
					"notify",
					"toggleterm",
					"lazyterm",
				},
				callback = function()
					vim.b.miniindentscope_disable = true
				end,
			})
		end,
	},

	-- Better folding with nvim-ufo
	{
		"kevinhwang91/nvim-ufo",
		dependencies = {
			"kevinhwang91/promise-async",
		},
		event = "BufReadPost",
		opts = {
			provider_selector = function()
				return { "treesitter", "indent" }
			end,
		},
		config = function(_, opts)
			require("ufo").setup(opts)

			vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
			vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
			vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds, { desc = "Open folds except kinds" })
			vim.keymap.set("n", "zm", require("ufo").closeFoldsWith, { desc = "Close folds with" })
		end,
	},

	-- Notification manager
	{
		"rcarriga/nvim-notify",
		event = "VeryLazy",
		opts = {
			timeout = 3000,
			max_height = function()
				return math.floor(vim.o.lines * 0.75)
			end,
			max_width = function()
				return math.floor(vim.o.columns * 0.75)
			end,
			render = "compact",
			stages = "fade_in_slide_out",
		},
		config = function(_, opts)
			require("notify").setup(opts)
			vim.notify = require("notify")
		end,
	},

	-- Better UI for inputs and selects
	{
		"stevearc/dressing.nvim",
		event = "VeryLazy",
		opts = {
			input = {
				enabled = true,
				default_prompt = "Input:",
				prompt_align = "left",
				insert_only = true,
				start_in_insert = true,
				border = "rounded",
				relative = "cursor",
				prefer_width = 40,
				width = nil,
				max_width = { 140, 0.9 },
				min_width = { 20, 0.2 },
			},
			select = {
				enabled = true,
				backend = { "telescope", "fzf_lua", "fzf", "builtin", "nui" },
				trim_prompt = true,
				telescope = require("telescope.themes").get_dropdown(),
			},
		},
	},

	-- Note: Dashboard now handled by snacks.nvim in lua/plugins/dev-tools.lua
	-- Smooth scrolling is now handled by native Neovim 0.10+ features

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
							return buffer.unique_prefix .. buffer.filename
						end,
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
							return buffer.is_modified and " ●" or ""
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
								return "  " .. errors
							elseif warnings > 0 then
								return "  " .. warnings
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

	-- Better highlighting of word under cursor
	{
		"RRethy/vim-illuminate",
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			delay = 200,
			large_file_cutoff = 2000,
			large_file_overrides = {
				providers = { "lsp" },
			},
		},
		config = function(_, opts)
			require("illuminate").configure(opts)

			local function map(key, dir, buffer)
				vim.keymap.set("n", key, function()
					require("illuminate")["goto_" .. dir .. "_reference"](false)
				end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference", buffer = buffer })
			end

			map("]]", "next")
			map("[[", "prev")

			vim.api.nvim_create_autocmd("FileType", {
				callback = function()
					local buffer = vim.api.nvim_get_current_buf()
					map("]]", "next", buffer)
					map("[[", "prev", buffer)
				end,
			})
		end,
		keys = {
			{ "]]", desc = "Next Reference" },
			{ "[[", desc = "Prev Reference" },
		},
	},

	-- Noice - Better UI for messages, cmdline and popupmenu
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		opts = {
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			routes = {
				{
					filter = {
						event = "msg_show",
						any = {
							{ find = "%d+L, %d+B" },
							{ find = "; after #%d+" },
							{ find = "; before #%d+" },
						},
					},
					view = "mini",
				},
				-- Suppress annoying LSP "Content Modified" errors
				{
					filter = {
						event = "notify",
						find = "ContentModified",
					},
					opts = { skip = true },
				},
			},
			presets = {
				bottom_search = true,
				command_palette = true,
				long_message_to_split = true,
				inc_rename = false,
				lsp_doc_border = true,
			},
		},
		keys = {
			{
				"<S-Enter>",
				function()
					require("noice").redirect(vim.fn.getcmdline())
				end,
				mode = "c",
				desc = "Redirect Cmdline",
			},
			{
				"<leader>snl",
				function()
					require("noice").cmd("last")
				end,
				desc = "Noice Last Message",
			},
			{
				"<leader>snh",
				function()
					require("noice").cmd("history")
				end,
				desc = "Noice History",
			},
			{
				"<leader>sna",
				function()
					require("noice").cmd("all")
				end,
				desc = "Noice All",
			},
			{
				"<leader>snd",
				function()
					require("noice").cmd("dismiss")
				end,
				desc = "Dismiss All",
			},
			-- Note: Scroll bindings removed to avoid potential conflicts with cmp and telescope
		},
	},
}
