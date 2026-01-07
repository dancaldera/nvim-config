-- ============================================================================
-- Colorscheme Configuration
-- ============================================================================

return {
	{
		name = "custom-themes",
		dir = vim.fn.stdpath("config"),
		priority = 1000,
		config = function()
			-- Load theme manager
			local theme_manager = require("config.theme-manager")

			-- Load user's preferred theme or default to gruvbox-custom
			local preferred_theme = theme_manager.load_preference()
			theme_manager.load_theme(preferred_theme)
		end,
	},
}
