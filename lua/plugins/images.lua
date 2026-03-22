-- ============================================================================
-- Image Viewing and Inline Rendering
-- ============================================================================

return {
	{
		"3rd/image.nvim",
		enabled = function()
			return vim.fn.executable("magick") == 1 or vim.fn.executable("convert") == 1
		end,
		event = "BufReadPre",
		build = false,
		init = function()
			if vim.fn.executable("magick") == 0 and vim.fn.executable("convert") == 0 then
				vim.schedule(function()
					vim.notify(
						"image.nvim disabled: install ImageMagick (`magick` or `convert`) to open images in Neovim.",
						vim.log.levels.WARN
					)
				end)
			end
		end,
		opts = {
			backend = "kitty",
			processor = "magick_cli",
			integrations = {
				markdown = {
					enabled = true,
					clear_in_insert_mode = false,
					download_remote_images = true,
					only_render_image_at_cursor = false,
					filetypes = { "markdown", "vimwiki", "Avante" },
				},
				html = {
					enabled = false,
				},
				css = {
					enabled = false,
				},
			},
			max_height_window_percentage = 50,
			window_overlap_clear_enabled = true,
			window_overlap_clear_ft_ignore = {
				"cmp_menu",
				"cmp_docs",
				"snacks_notif",
				"scrollview",
				"scrollview_sign",
			},
			editor_only_render_when_focused = false,
			tmux_show_only_in_active_window = false,
				hijack_file_patterns = {
					"*.png",
					"*.jpg",
					"*.jpeg",
					"*.gif",
					"*.webp",
					"*.avif",
					"*.bmp",
					"*.tiff",
					"*.tif",
					"*.heic",
					"*.heif",
					"*.ppm",
					"*.pgm",
					"*.pbm",
				},
			},
		},
	}
