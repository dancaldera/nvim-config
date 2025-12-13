-- ============================================================================
-- Colorscheme Configuration with Theme Switcher
-- ============================================================================

return {
	{
		name = "theme-switcher",
		dir = vim.fn.stdpath("config"),
		priority = 1000,
		config = function()
			-- Default to dark theme (gruvbox)
			local default_theme = vim.g.default_colorscheme or "gruvbox-custom"

			-- Load the default theme
			if default_theme == "gruvbox-custom" then
				dofile(vim.fn.stdpath("config") .. "/lua/colors/gruvbox-custom.lua")
			else
				dofile(vim.fn.stdpath("config") .. "/lua/colors/cursor-light.lua")
			end

			-- Global toggle function
			_G.toggle_colorscheme = function()
				if vim.g.colors_name == "gruvbox-custom" then
					dofile(vim.fn.stdpath("config") .. "/lua/colors/cursor-light.lua")
					vim.notify("Switched to Cursor Light theme", vim.log.levels.INFO)
				else
					dofile(vim.fn.stdpath("config") .. "/lua/colors/gruvbox-custom.lua")
					vim.notify("Switched to Gruvbox Material theme", vim.log.levels.INFO)
				end
			end
		end,
	},
}
