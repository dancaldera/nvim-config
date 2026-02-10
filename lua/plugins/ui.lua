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

			-- Cache git-repo detection per buffer (avoids synchronous shell on every statusline refresh)
			local git_cache_group = vim.api.nvim_create_augroup("lualine_git_cache", { clear = true })
			vim.api.nvim_create_autocmd({ "BufEnter", "DirChanged" }, {
				group = git_cache_group,
				callback = function()
					local result = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null")
					vim.b.is_git_repo = (vim.v.shell_error == 0 and vim.trim(result) ~= "")
				end,
			})

			require("lualine").setup({
				options = {
					theme = "kanagawa",
					component_separators = { left = "|", right = "|" },
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
						{ lazy_status.updates, cond = lazy_status.has_updates },
					{
						function()
							local github = require("config.github")
							local account = github.get_current_account()
							return account and string.format(" @%s", account) or ""
						end,
						cond = function()
							return vim.b.is_git_repo and package.loaded["config.github"]
						end,
						color = { fg = "#7C3AED", gui = "bold" },
					},
						{
							function()
								local ok, swenv = pcall(require, "swenv.api")
								if ok then
									local venv = swenv.get_current_venv()
									if venv then return venv.name end
								end
								local venv_path = vim.fn.getenv("VIRTUAL_ENV")
								if venv_path and venv_path ~= vim.NIL then
									return vim.fn.fnamemodify(venv_path, ":t")
								end
								return ""
							end,
							cond = function() return vim.bo.filetype == "python" end,
						},
						{ "encoding" },
						{ "fileformat" },
						{ "filetype" },
					},
				},
			})
		end,
	},

	-- Code navigation breadcrumbs
	{
		"SmiteshP/nvim-navic",
		dependencies = "neovim/nvim-lspconfig",
		event = "LspAttach",
		opts = {
			lsp = { auto_attach = true },
			highlight = true,
			separator = " > ",
			depth_limit = 0,
			depth_limit_indicator = "..",
			safe_output = true,
		},
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
					mode = "buffers",
					separator_style = "slant",
					themable = true,
					close_command = function(bufnum)
						require("mini.bufremove").delete(bufnum, false)
					end,
					right_mouse_command = function(bufnum)
						require("mini.bufremove").delete(bufnum, false)
					end,
					indicator = { icon = "▎", style = "icon" },
					buffer_close_icon = "󰅖",
					modified_icon = "●",
					diagnostics = "nvim_lsp",
					diagnostics_indicator = function(count, level)
						local icon = level:match("error") and " " or " "
						return " " .. icon .. count
					end,
					offsets = {
						{
							filetype = "NvimTree",
							text = "File Explorer",
							text_align = "center",
							separator = true,
						},
					},
					color_icons = true,
					show_buffer_close_icons = true,
					hover = { enabled = true, delay = 200, reveal = { "close" } },
				always_show_bufferline = false,
				},
				highlights = {
					modified_selected = { fg = "#fabd2f" },
					modified = { fg = "#fabd2f" },
					modified_visible = { fg = "#fabd2f" },
				},
			})
		end,
	},

	-- Better buffer closing
	{
		"echasnovski/mini.bufremove",
		version = false,
		init = function()
			-- Shared helper: close buffer or quit if last
			_G._smart_buf_close = function(force)
				local bd = require("mini.bufremove").delete
				local listed = vim.tbl_filter(function(b)
					return vim.bo[b].buflisted
				end, vim.api.nvim_list_bufs())
				if #listed <= 1 then
					vim.cmd(force and "qa!" or "qa")
				elseif vim.bo.modified and not force then
					local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
					if choice == 1 then vim.cmd.write(); bd(0)
					elseif choice == 2 then bd(0, true) end
				else
					bd(0, force or false)
				end
			end
		end,
		keys = {
			{ "<leader>bd", function() _G._smart_buf_close(false) end, desc = "Delete Buffer" },
			{ "<leader>bD", function() _G._smart_buf_close(true) end, desc = "Delete Buffer (Force)" },
		},
	},

	-- Indentation scope indicator
	{
		"echasnovski/mini.indentscope",
		version = false,
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			symbol = "│",
			options = { try_as_border = true },
			draw = { animation = function() return 0 end },
		},
		init = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "help", "dashboard", "nvim-tree", "Trouble", "trouble", "lazy", "mason", "notify", "toggleterm" },
				callback = function() vim.b.miniindentscope_disable = true end,
			})
		end,
	},

	-- Highlight word under cursor
	{
		"RRethy/vim-illuminate",
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			delay = 300,
			large_file_cutoff = 2000,
			large_file_overrides = { providers = { "lsp" } },
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

	-- Code folding (nvim-ufo)
	{
		"kevinhwang91/nvim-ufo",
		dependencies = { "kevinhwang91/promise-async" },
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
}
