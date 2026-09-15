-- ============================================================================
-- Lazy.nvim bootstrap + LazyVim distribution setup
-- ============================================================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
---@diagnostic disable-next-line: undefined-field
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Leader keys must be set before lazy.nvim boots.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("lazy").setup({
	spec = {
		-- LazyVim distribution (core plugins, defaults, utilities)
		{ "LazyVim/LazyVim", import = "lazyvim.plugins", opts = { news = { lazyvim = false } } },
		-- Your plugin specs (auto-imported from lua/plugins/)
		{ import = "plugins" },
	},
	defaults = {
		lazy = true,
		version = false,
	},
	install = { colorscheme = { "habamax" } },
	checker = {
		enabled = true,
		notify = false,
	},
	change_detection = {
		enabled = true,
		notify = false,
	},
	rocks = {
		enabled = false,
	},
	ui = {
		border = "rounded",
		backdrop = 60,
	},
	performance = {
		reset_packpath = true,
		rtp = {
			disabled_plugins = {
				"gzip",
				"matchit",
				"matchparen",
				"netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})
