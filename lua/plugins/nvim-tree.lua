-- ============================================================================
-- File Explorer (nvim-tree) Configuration
-- ============================================================================

return {
	"nvim-tree/nvim-tree.lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local nvimtree = require("nvim-tree")

		-- Disable netrw
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1

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
			update_focused_file = {
				enable = true,
				update_root = true,
			},
			on_attach = function(bufnr)
				local function opts(desc)
					return { desc = desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
				end

				api.config.mappings.default_on_attach(bufnr)
				vim.keymap.set("n", "-", api.tree.change_root_to_parent, opts("Up"))
				vim.keymap.set("n", "<C-]>", api.tree.change_root_to_node, opts("CD"))
				vim.keymap.set("n", "a", api.fs.create, opts("Create"))
				vim.keymap.set("n", "d", api.fs.remove, opts("Delete"))
				vim.keymap.set("n", "r", api.fs.rename, opts("Rename"))
				vim.keymap.set("n", "x", api.fs.cut, opts("Cut"))
				vim.keymap.set("n", "c", api.fs.copy.node, opts("Copy"))
				vim.keymap.set("n", "p", api.fs.paste, opts("Paste"))
			end,
		})

		-- Keymaps
		local keymap = vim.keymap

		keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
		keymap.set(
			"n",
			"<leader>ef",
			"<cmd>NvimTreeFindFileToggle<CR>",
			{ desc = "Toggle file explorer on current file" }
		)
		keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" })
		keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" })
		keymap.set("n", "<leader>eo", "<cmd>NvimTreeFocus<CR>", { desc = "Focus file explorer" })

		-- Toggle between file explorer and current buffer
		keymap.set("n", "<C-e>", function()
			if vim.bo.filetype == "NvimTree" then
				vim.cmd("wincmd p") -- Go to previous window (your file buffer)
			else
				vim.cmd("NvimTreeFocus") -- Focus the file explorer
			end
		end, { desc = "Toggle focus between file explorer and buffer" })
	end,
}
