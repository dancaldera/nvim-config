-- ============================================================================
-- File Explorer (nvim-tree) Configuration
-- ============================================================================

return {
	"nvim-tree/nvim-tree.lua",
	init = function()
		local startup_group = vim.api.nvim_create_augroup("nvim_tree_startup", { clear = true })

		vim.api.nvim_create_autocmd("VimEnter", {
			group = startup_group,
			once = true,
			callback = function(data)
				if #vim.api.nvim_list_uis() == 0 then
					return
				end

				local ok_lazy, lazy = pcall(require, "lazy")
				if not ok_lazy then
					return
				end

				lazy.load({ plugins = { "nvim-tree.lua" } })

				local ok_api, api = pcall(require, "nvim-tree.api")
				if not ok_api then
					return
				end

				if vim.fn.argc() == 0 then
					vim.schedule(function()
						api.tree.open()
					end)
					return
				end

				local first_arg = vim.fn.argv(0)
				if first_arg ~= "" and vim.fn.isdirectory(first_arg) == 1 then
					vim.schedule(function()
						api.tree.open()
					end)
					return
				end

				if vim.fn.argc() == 1 and data.file ~= "" and vim.fn.filereadable(data.file) == 1 then
					vim.schedule(function()
						api.tree.find_file({ open = true, focus = false })
					end)
				end
			end,
		})
	end,
	cmd = {
		"NvimTreeToggle",
		"NvimTreeFindFileToggle",
		"NvimTreeCollapse",
		"NvimTreeRefresh",
		"NvimTreeFocus",
	},
	dependencies = { "nvim-tree/nvim-web-devicons" },
	keys = {
		{ "<leader>ee", "<cmd>NvimTreeToggle<CR>", desc = "Toggle file explorer" },
		{ "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", desc = "Toggle file explorer on current file" },
		{ "<leader>ec", "<cmd>NvimTreeCollapse<CR>", desc = "Collapse file explorer" },
		{ "<leader>er", "<cmd>NvimTreeRefresh<CR>", desc = "Refresh file explorer" },
		{ "<leader>eo", "<cmd>NvimTreeFocus<CR>", desc = "Focus file explorer" },
	},
	config = function()
		local nvimtree = require("nvim-tree")

		local api = require("nvim-tree.api")

		nvimtree.setup({
			view = {
				width = 35,
				relativenumber = false,
			},
			renderer = {
				indent_markers = {
					enable = true,
				},
				icons = {
					glyphs = {
						folder = {
							arrow_closed = "",
							arrow_open = "",
						},
					},
				},
			},
			actions = {
				open_file = {
					window_picker = {
						enable = false,
					},
				},
			},
			filters = {
				custom = { ".DS_Store" },
			},
			git = {
				ignore = false,
			},
			hijack_directories = {
				enable = true,
				auto_open = true,
			},
			update_focused_file = {
				enable = true,
				update_root = false,
			},
			on_attach = function(bufnr)
				local function opts(desc)
					return { desc = desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
				end

				api.config.mappings.default_on_attach(bufnr)
				-- Parent navigation disabled to enforce workspace boundary
				-- vim.keymap.set("n", "-", api.tree.change_root_to_parent, opts("Up"))
				vim.keymap.set("n", "<C-]>", api.tree.change_root_to_node, opts("CD"))
				vim.keymap.set("n", "a", api.fs.create, opts("Create"))
				vim.keymap.set("n", "d", api.fs.remove, opts("Delete"))
				vim.keymap.set("n", "r", api.fs.rename, opts("Rename"))
				vim.keymap.set("n", "x", api.fs.cut, opts("Cut"))
				vim.keymap.set("n", "c", api.fs.copy.node, opts("Copy"))
				vim.keymap.set("n", "p", api.fs.paste, opts("Paste"))
			end,
		})

		-- Toggle between file explorer and current buffer
		vim.keymap.set("n", "<C-e>", function()
			if vim.bo.filetype == "NvimTree" then
				vim.cmd("wincmd p") -- Go to previous window (your file buffer)
			else
				vim.cmd("NvimTreeFocus") -- Focus the file explorer
			end
		end, { desc = "Toggle focus between file explorer and buffer" })
	end,
}
