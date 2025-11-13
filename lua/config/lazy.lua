-- ============================================================================
-- Lazy.nvim Plugin Manager Setup
-- ============================================================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
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

require("lazy").setup({
	{ import = "plugins" },
}, {
	checker = {
		enabled = true,
		notify = false,
		frequency = 3600, -- Check every hour
	},
	change_detection = {
		enabled = true,
		notify = false,
	},
	install = {
		colorscheme = { "catppuccin", "habamax" },
	},
	ui = {
		border = "rounded",
		backdrop = 60,
	},
	rocks = {
		enabled = false, -- Disable luarocks support (not needed for current plugins)
	},
	performance = {
		cache = {
			enabled = true,
		},
		reset_packpath = true, -- Improves performance
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
				"rplugin",
				"builtins",
				"compiler",
				"optwin",
				-- Additional disabled plugins for performance
				"spellfile",
				"shada_plugin",
			},
		},
	},
	-- Enable profiling for performance monitoring
	profiling = {
		enabled = false, -- Set to true to debug performance
	},
})
