-- ============================================================================
-- Key Mappings
-- ============================================================================

local keymap = vim.keymap

-- General keymaps
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

-- Window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

-- Better window navigation
keymap.set("n", "<C-h>", "<C-w>h", { desc = "Navigate to left window" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "Navigate to bottom window" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "Navigate to top window" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "Navigate to right window" })

-- Resize windows
keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- Move text up and down
keymap.set("v", "<A-j>", ":m .+1<CR>==", { desc = "Move text down" })
keymap.set("v", "<A-k>", ":m .-2<CR>==", { desc = "Move text up" })

-- Stay in indent mode
keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Copy file location context for AI agents (visual mode)
keymap.set("v", "<leader>cl", function()
	local start_line = vim.fn.line("v")
	local end_line = vim.fn.line(".")
	local relative_path = vim.fn.expand("%:~:.")

	-- Ensure start_line is the smaller number
	if start_line > end_line then
		start_line, end_line = end_line, start_line
	end

	-- Format for AI context: "file:path/to/file.lua:lines:start-end"
	local location_info = string.format("%s:lines:%d-%d", relative_path, start_line, end_line)

	-- Copy to system clipboard
	vim.fn.setreg("+", location_info)

	-- Optional: Also show a notification
	vim.notify("Copied: " .. location_info, vim.log.levels.INFO)
end, { desc = "Copy file location for AI context" })

-- Search and replace
keymap.set("n", "n", "nzzzv", { desc = "Next search result and center" })
keymap.set("n", "N", "Nzzzv", { desc = "Previous search result and center" })

-- Save and quit
keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })

-- Buffer navigation (bufferline.nvim)
keymap.set("n", "<S-l>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer", silent = true })
keymap.set("n", "<S-h>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer", silent = true })
keymap.set("n", "<S-x>", function()
	_G._smart_buf_close(false)
end, { desc = "Close current buffer (quit if last)" })

-- Quick buffer access with Command+Control+number
for i = 1, 9 do
	keymap.set(
		"n",
		"<D-C-" .. i .. ">",
		"<cmd>BufferLineGoToBuffer " .. i .. "<CR>",
		{ desc = "Go to buffer " .. i, silent = true }
	)
end
keymap.set("n", "<D-C-0>", "<cmd>BufferLineGoToBuffer -1<CR>", { desc = "Go to last buffer", silent = true })

-- Buffer reordering (move buffers left/right in tabline)
keymap.set("n", "<A-,>", "<cmd>BufferLineMovePrev<CR>", { desc = "Move buffer left", silent = true })
keymap.set("n", "<A-.>", "<cmd>BufferLineMoveNext<CR>", { desc = "Move buffer right", silent = true })

-- Buffer picking and management
keymap.set(
	"n",
	"<leader>bb",
	"<cmd>Telescope buffers sort_mru=true sort_lastused=true<CR>",
	{ desc = "Find open buffers", silent = true }
)
keymap.set(
	"n",
	"<leader>bv",
	"<cmd>BufferLinePick<CR>",
	{ desc = "Visual pick buffer (letter overlay)", silent = true }
)
keymap.set("n", "<leader>ba", "<cmd>b#<CR>", { desc = "Alternate (last) buffer", silent = true })
keymap.set("n", "<leader>bp", "<cmd>BufferLineTogglePin<CR>", { desc = "Pin/unpin buffer", silent = true })
keymap.set("n", "<leader>bo", "<cmd>BufferLineCloseOthers<CR>", { desc = "Close other buffers", silent = true })
keymap.set("n", "<leader>bl", "<cmd>BufferLineCloseRight<CR>", { desc = "Close buffers to right", silent = true })
keymap.set("n", "<leader>bh", "<cmd>BufferLineCloseLeft<CR>", { desc = "Close buffers to left", silent = true })

-- Terminal mode keybindings
keymap.set("t", "<C-[>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
keymap.set("t", "<C-n>", "<C-\\><C-n>", { desc = "Exit terminal mode (legacy alias)" })
keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Navigate to left window from terminal" })
keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Navigate to bottom window from terminal" })
keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Navigate to top window from terminal" })
keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Navigate to right window from terminal" })

-- Better line joining
keymap.set("n", "J", "mzJ`z", { desc = "Join lines without moving cursor" })

-- Keep cursor centered when jumping
keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })

-- Add undo break-points
keymap.set("i", ",", ",<c-g>u")
keymap.set("i", ".", ".<c-g>u")
keymap.set("i", ";", ";<c-g>u")

-- Better pasting
keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without yanking" })

-- Select all
keymap.set("n", "<C-a>", "ggVG", { desc = "Select all" })

-- System clipboard operations
keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
keymap.set({ "n", "v" }, "<leader>Y", '"+Y', { desc = "Yank line to system clipboard" })
keymap.set({ "n", "v" }, "<leader>P", '"+p', { desc = "Paste from system clipboard" })

-- Better window resizing (Alt/Option + hjkl)
keymap.set("n", "<M-h>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
keymap.set("n", "<M-l>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })
keymap.set("n", "<M-j>", "<cmd>resize +2<CR>", { desc = "Increase window height" })
keymap.set("n", "<M-k>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })

-- Health and diagnostics
keymap.set("n", "<leader>hc", "<cmd>lua require('config.health').check_health()<CR>", { desc = "Run health check" })
keymap.set(
	"n",
	"<leader>hC",
	"<cmd>lua require('config.health').check_config_consistency()<CR>",
	{ desc = "Check config consistency" }
)
keymap.set("n", "<leader>hN", "<cmd>checkhealth<CR>", { desc = "Run Neovim health check" })

-- Office/browser helpers
keymap.set("n", "<leader>ob", function()
	require("config.office").open_current_in_browser()
end, { desc = "Open Office file in browser" })
