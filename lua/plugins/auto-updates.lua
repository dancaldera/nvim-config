-- ============================================================================
-- Automatic Updates Configuration
-- ============================================================================

return {
	-- Auto-update plugin
	{
		"folke/lazy.nvim",
		opts = function(_, opts)
			-- Configure auto-update schedule
			opts.checker = opts.checker or {}
			opts.checker.enabled = true
			opts.checker.frequency = 3600 -- Check every hour

			-- Schedule automatic updates (weekly)
			local function schedule_auto_update()
				local current_time = os.date("*t")
				local day_of_week = current_time.wday
				local hour = current_time.hour

				-- Run updates on Sunday at 2 AM
				if day_of_week == 1 and hour >= 2 and hour < 3 then
					vim.defer_fn(function()
						vim.notify("Running scheduled plugin updates...", vim.log.levels.INFO)

						-- Update plugins
						require("lazy").sync({
							wait = true,
							show = false,
						})

						-- Update LSP servers
						vim.defer_fn(function()
							vim.cmd("MasonUpdate")
							vim.notify("Scheduled updates completed!", vim.log.levels.INFO)
						end, 5000)
					end, 10000) -- Wait 10 seconds after startup
				end
			end

			-- Check schedule on startup
			vim.defer_fn(schedule_auto_update, 5000)

			-- Also check schedule periodically
			local timer = vim.loop.new_timer()
			timer:start(3600000, 3600000, vim.schedule_wrap(schedule_auto_update)) -- Check every hour

			return opts
		end,
	},

	-- Auto-update LSP servers and tools
	{
		"williamboman/mason.nvim",
		opts = function(_, opts)
			-- Add auto-update notification for Mason
			local mason = require("mason")

			-- Schedule weekly Mason updates
			local function schedule_mason_update()
				local current_time = os.date("*t")
				local day_of_week = current_time.wday
				local hour = current_time.hour

				-- Run updates on Sunday at 3 AM (after plugins)
				if day_of_week == 1 and hour >= 3 and hour < 4 then
					vim.defer_fn(function()
						vim.notify("Updating LSP servers and tools...", vim.log.levels.INFO)
						vim.cmd("MasonUpdate")
					end, 15000) -- Wait 15 seconds after startup
				end
			end

			vim.defer_fn(schedule_mason_update, 7000)

			return opts
		end,
	},

	-- Auto-update Treesitter parsers
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			-- Schedule weekly Treesitter updates
			local function schedule_treesitter_update()
				local current_time = os.date("*t")
				local day_of_week = current_time.wday
				local hour = current_time.hour

				-- Run updates on Sunday at 3:30 AM
				if day_of_week == 1 and hour >= 3 and hour < 4 then
					vim.defer_fn(function()
						vim.notify("Updating Treesitter parsers...", vim.log.levels.INFO)
						vim.cmd("TSUpdate")
					end, 20000) -- Wait 20 seconds after startup
				end
			end

			vim.defer_fn(schedule_treesitter_update, 8000)

			return opts
		end,
	},
}
