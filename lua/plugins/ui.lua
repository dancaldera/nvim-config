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
			local function in_git_repo(path)
				local dir = path ~= "" and vim.fs.dirname(path) or vim.loop.cwd()
				return vim.fs.find(".git", {
					path = dir,
					upward = true,
					type = "directory",
					limit = 1,
				})[1] ~= nil
			end

			-- Cache git-repo detection per buffer without spawning git on buffer switches.
			local git_cache_group = vim.api.nvim_create_augroup("lualine_git_cache", { clear = true })
			vim.api.nvim_create_autocmd({ "BufEnter", "DirChanged" }, {
				group = git_cache_group,
				callback = function(args)
					local name = args.buf and vim.api.nvim_buf_get_name(args.buf) or ""
					vim.b[args.buf].is_git_repo = in_git_repo(name)
				end,
			})

			require("lualine").setup({
				options = {
					theme = "auto",
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
									if venv then
										return venv.name
									end
								end
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
					offsets = {
						{
							filetype = "NvimTree",
							text = "File Explorer",
							text_align = "center",
							separator = true,
						},
					},
					get_element_icon = function(element)
						local path = element.path or ""
						local ai_tools = { "claude", "codex", "opencode", "gemini", "copilot" }
						for _, tool in ipairs(ai_tools) do
							if path:match(tool) then
								return "󱙺", "Special"
							end
						end
						if path:match("terminal://terminal") then
							return "󰿘", "Special"
						end
					end,
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
					local choice =
						vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
					if choice == 1 then
						vim.cmd.write()
						bd(0)
					elseif choice == 2 then
						bd(0, true)
					end
				else
					bd(0, force or false)
				end
			end
		end,
		keys = {
			{
				"<leader>bd",
				function()
					_G._smart_buf_close(false)
				end,
				desc = "Delete Buffer",
			},
			{
				"<leader>bD",
				function()
					_G._smart_buf_close(true)
				end,
				desc = "Delete Buffer (Force)",
			},
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
			},
			init = function()
				local function disable_indentscope(args)
					if vim.bo[args.buf].buftype == "terminal" then
						vim.b[args.buf].miniindentscope_disable = true
						return
					end

					vim.b[args.buf].miniindentscope_disable = true
				end

				vim.api.nvim_create_autocmd("FileType", {
					pattern = {
						"help",
						"dashboard",
					"nvim-tree",
					"Trouble",
					"trouble",
					"lazy",
					"mason",
						"notify",
						"toggleterm",
					},
					callback = disable_indentscope,
				})

				vim.api.nvim_create_autocmd("TermOpen", {
					callback = disable_indentscope,
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
