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

-- Search and replace
keymap.set("n", "n", "nzzzv", { desc = "Next search result and center" })
keymap.set("n", "N", "Nzzzv", { desc = "Previous search result and center" })

-- Save and quit
keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })

-- Buffer navigation (bufferline.nvim)
keymap.set("n", "<S-l>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer", silent = true })
keymap.set("n", "<S-h>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer", silent = true })
keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Close current buffer" })

-- Buffer reordering
keymap.set("n", "<A-,>", "<cmd>BufferLineMovePrev<CR>", { desc = "Move buffer left", silent = true })
keymap.set("n", "<A-.>", "<cmd>BufferLineMoveNext<CR>", { desc = "Move buffer right", silent = true })

-- Buffer management
keymap.set("n", "<leader>bv", "<cmd>BufferLinePick<CR>", { desc = "Visual pick buffer", silent = true })
keymap.set("n", "<leader>ba", "<cmd>b#<CR>", { desc = "Alternate buffer", silent = true })
keymap.set("n", "<leader>bp", "<cmd>BufferLineTogglePin<CR>", { desc = "Pin/unpin buffer", silent = true })
keymap.set("n", "<leader>bo", "<cmd>BufferLineCloseOthers<CR>", { desc = "Close other buffers", silent = true })
keymap.set("n", "<leader>bl", "<cmd>BufferLineCloseRight<CR>", { desc = "Close buffers to right", silent = true })
keymap.set("n", "<leader>bh", "<cmd>BufferLineCloseLeft<CR>", { desc = "Close buffers to left", silent = true })

-- Terminal mode keybindings
-- (<C-\><C-n> stays free as the standard terminal escape; <C-[>/<Esc> stays
-- pass-through so nested apps like vim/less/REPLs receive it.)
keymap.set("t", "<C-n>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
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
keymap.set("i", ",", ",<c-g>u", { desc = "Undo breakpoint" })
keymap.set("i", ".", ".<c-g>u", { desc = "Undo breakpoint" })
keymap.set("i", ";", ";<c-g>u", { desc = "Undo breakpoint" })

-- Better pasting
keymap.set("x", "<leader>p", [[_dP]], { desc = "Paste without yanking" })

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
