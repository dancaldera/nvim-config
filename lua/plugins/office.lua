-- ============================================================================
-- Office Document Viewing
-- ============================================================================

return {
	{
		"hat0uma/csvview.nvim",
		ft = { "csv", "tsv" },
		cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle", "CsvViewInfo" },
		---@module "csvview"
		---@type CsvView.Options
		opts = {
			parser = {
				comments = { "#" },
			},
			view = {
				display_mode = "border",
			},
		},
	},
}
