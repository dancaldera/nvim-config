-- ============================================================================
-- File Explorer Configuration (nvim-tree.lua)
-- ============================================================================

local function current_file_is_readable()
	local path = vim.api.nvim_buf_get_name(0)
	return path ~= "" and vim.fn.filereadable(path) == 1
end

local function toggle_explorer()
	local api = require("nvim-tree.api")
	api.tree.toggle({
		focus = true,
		find_file = current_file_is_readable(),
		update_root = false,
	})
end

local function reveal_current_file()
	local api = require("nvim-tree.api")
	if current_file_is_readable() then
		api.tree.find_file({
			open = true,
			focus = true,
			update_root = false,
		})
	else
		api.tree.open({
			path = vim.fn.getcwd(),
			focus = true,
		})
	end
end

return {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	lazy = false,
	priority = 1100,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	keys = {
		{ "\\", toggle_explorer, desc = "Toggle file explorer" },
		{ "<leader>ee", toggle_explorer, desc = "Toggle file explorer" },
		{ "<leader>ef", reveal_current_file, desc = "Reveal current file in explorer" },
		{ "<leader>ec", "<cmd>NvimTreeClose<CR>", desc = "Close file explorer" },
		{ "<leader>er", "<cmd>NvimTreeRefresh<CR>", desc = "Refresh file explorer" },
		{ "<leader>eo", reveal_current_file, desc = "Focus file explorer" },
		{
			"<C-e>",
			function()
				if vim.bo.filetype == "NvimTree" then
					vim.cmd.wincmd("p")
				else
					reveal_current_file()
				end
			end,
			desc = "Toggle focus between explorer and buffer",
		},
	},
	config = function()
		require("nvim-web-devicons").setup({ default = true })

		require("nvim-tree").setup({
			disable_netrw = true,
			hijack_netrw = true,
			hijack_unnamed_buffer_when_opening = false,
			sync_root_with_cwd = true,
			respect_buf_cwd = true,
			reload_on_bufenter = true,
			select_prompts = true,
			hijack_directories = {
				enable = false,
				auto_open = false,
			},
			update_focused_file = {
				enable = true,
				update_root = {
					enable = false,
				},
			},
			view = {
				side = "left",
				width = 30,
				preserve_window_proportions = true,
				signcolumn = "yes",
			},
			renderer = {
				group_empty = true,
				root_folder_label = false,
				highlight_git = "name",
				icons = {
					web_devicons = {
						file = { enable = true, color = true },
						folder = { enable = true, color = true },
					},
					show = {
						file = true,
						folder = true,
						folder_arrow = true,
						git = true,
					},
				},
				indent_markers = {
					enable = true,
				},
			},
			git = {
				enable = true,
				ignore = false,
			},
			diagnostics = {
				enable = true,
				show_on_dirs = true,
			},
			modified = {
				enable = true,
			},
			actions = {
				open_file = {
					quit_on_open = false,
					resize_window = false,
					window_picker = {
						enable = false,
						exclude = {
							filetype = { "notify", "lazy", "qf", "diff", "NvimTree" },
							buftype = { "nofile", "terminal", "help" },
						},
					},
				},
			},
		})

		vim.api.nvim_create_autocmd("VimEnter", {
			group = vim.api.nvim_create_augroup("NvimTreeCleanStartup", { clear = true }),
			callback = function(data)
				local api = require("nvim-tree.api")
				local real_file = vim.fn.filereadable(data.file) == 1
				local directory = vim.fn.isdirectory(data.file) == 1
				local no_name = data.file == "" and vim.bo[data.buf].buftype == ""

				if directory then
					vim.cmd.enew()
					vim.bo.buflisted = false
					pcall(vim.api.nvim_buf_delete, data.buf, { force = true })
					vim.cmd.cd(vim.fn.fnameescape(data.file))
					api.tree.open({ current_window = false, focus = true })
					return
				end

				if no_name then
					vim.bo[data.buf].buflisted = false
					api.tree.open({ current_window = false, focus = true })
					return
				end

				if real_file then
					api.tree.open({ current_window = false, focus = false, find_file = true })
				end
			end,
		})
	end,
}
