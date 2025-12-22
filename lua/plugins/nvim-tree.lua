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
		})

		-- ============================================================================
		-- Folder Colors - Aligned with Gruvbox Custom Colorscheme
		-- ============================================================================
		-- Define colors matching gruvbox-custom.lua palette
		local colors = {
			blue = "#7daea3", -- Muted seafoam blue (for default folders)
			yellow = "#d8a657", -- Warm golden yellow (for opened folders)
			aqua = "#89b482", -- Sage green (for folder icons)
			orange = "#e78a4e", -- Warm terracotta (for special folders)
			green = "#a9b665", -- Olive green (for git added folders)
			red = "#ea6962", -- Soft coral red (for empty folders)
			purple = "#d3869b", -- Muted raspberry (for symlink folders)
			grey = "#a89984", -- Comments color (for collapsed folders)
		}

		-- Helper function for setting highlights
		local function hl(group, settings)
			vim.api.nvim_set_hl(0, group, settings)
		end

		-- Folder icon colors
		hl("NvimTreeFolderIcon", { fg = colors.blue }) -- Default folder icon
		hl("NvimTreeOpenedFolderIcon", { fg = colors.yellow }) -- Opened folder icon

		-- Folder name colors
		hl("NvimTreeFolderName", { fg = colors.blue }) -- Closed folder name
		hl("NvimTreeOpenedFolderName", { fg = colors.yellow, bold = true }) -- Opened folder name
		hl("NvimTreeEmptyFolderName", { fg = colors.grey, italic = true }) -- Empty folder name

		-- Special folder types
		hl("NvimTreeSymlinkFolderName", { fg = colors.purple, italic = true }) -- Symlinked folders
		hl("NvimTreeRootFolder", { fg = colors.orange, bold = true }) -- Root folder

		-- File colors (for consistency)
		hl("NvimTreeNormal", { fg = colors.grey }) -- Default file color
		hl("NvimTreeExecFile", { fg = colors.green, bold = true }) -- Executable files
		hl("NvimTreeSpecialFile", { fg = colors.orange, underline = true }) -- Special files
		hl("NvimTreeSymlink", { fg = colors.purple, italic = true }) -- Symlinked files
		hl("NvimTreeImageFile", { fg = colors.aqua }) -- Image files

		-- Git integration colors (matching gruvbox-custom.lua git signs)
		hl("NvimTreeGitNew", { fg = colors.green }) -- New files
		hl("NvimTreeGitDirty", { fg = colors.yellow }) -- Modified files
		hl("NvimTreeGitDeleted", { fg = colors.red }) -- Deleted files
		hl("NvimTreeGitStaged", { fg = colors.aqua }) -- Staged files
		hl("NvimTreeGitMerge", { fg = colors.orange }) -- Merge conflicts
		hl("NvimTreeGitRenamed", { fg = colors.purple }) -- Renamed files

		-- Indent markers and UI elements
		hl("NvimTreeIndentMarker", { fg = colors.grey }) -- Indent guide lines
		hl("NvimTreeVertSplit", { fg = colors.grey }) -- Vertical split border

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
