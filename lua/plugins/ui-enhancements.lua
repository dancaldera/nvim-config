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

	-- Smooth scrolling
	{
		"karb94/neoscroll.nvim",
		event = "VeryLazy",
		opts = {
			mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
			hide_cursor = true,
			stop_eof = true,
			respect_scrolloff = false,
			cursor_scrolls_alone = true,
			easing_function = "quadratic",
			pre_hook = nil,
			post_hook = nil,
		},
	},

	-- Note: Dashboard now handled by snacks.nvim in lua/plugins/dev-tools.lua

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

	-- Buffer Manager (Reorder and manage buffers visually)
	{
		"j-morano/buffer_manager.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{
				"<leader>bm",
				function()
					require("buffer_manager.ui").toggle_quick_menu()
				end,
				desc = "Buffer Manager Menu",
			},
		},
		config = function()
			require("buffer_manager").setup({
				select_menu_item_commands = {
					v = {
						key = "<C-v>",
						command = "vsplit",
					},
					h = {
						key = "<C-h>",
						command = "split",
					},
				},
				short_file_names = true,
				short_term_names = true,
			})
		end,
	},

	-- Better buffer line
	{
		"romgrk/barbar.nvim",
		event = { "BufAdd", "BufNewFile", "TabNewEntered" },
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"lewis6991/gitsigns.nvim", -- Optional: git status icons
		},
		opts = {
			animation = true,
			auto_hide = 1, -- Hide when only 1 buffer
			tabpages = true,
			clickable = true, -- CRITICAL: Enable mouse clicks

			-- Close buffer with middle-click or close button
			-- Left-click switches buffers (built-in)

			-- Icons
			icons = {
				button = "×",
				buffer_index = false,
				buffer_number = false,
				diagnostics = {
					[vim.diagnostic.severity.ERROR] = { enabled = true, icon = " " },
					[vim.diagnostic.severity.WARN] = { enabled = true, icon = " " },
				},
				gitsigns = {
					added = { enabled = true, icon = "+" },
					changed = { enabled = true, icon = "~" },
					deleted = { enabled = true, icon = "-" },
				},
				filetype = {
					enabled = true,
				},
				separator = { left = "▎", right = "" },
				modified = { button = "●" },
				pinned = { button = "車", filename = true },
			},

			-- Sidebar offsets (keep NvimTree offset)
			sidebar_filetypes = {
				NvimTree = { text = "File Explorer", align = "left" },
			},

			-- Sorting (keep insert_after_current behavior)
			insert_at_end = false,
			insert_at_start = false,
		},
		config = function(_, opts)
			require("barbar").setup(opts)

			-- Keep session restoration fix
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
