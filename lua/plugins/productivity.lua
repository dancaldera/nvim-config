-- ============================================================================
-- Productivity Tools
-- Project management, code navigation, markdown tools, and sessions
-- ============================================================================

return {
	-- Project management
	{
		"ahmedkhalf/project.nvim",
		event = "VeryLazy",
		opts = {
			detection_methods = { "pattern" },
			patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json", "go.mod" },
			silent_chdir = true,
			scope_chdir = "global",
		},
		config = function(_, opts)
			require("project_nvim").setup(opts)
			require("telescope").load_extension("projects")
		end,
		keys = {
			{ "<leader>fp", "<cmd>Telescope projects<cr>", desc = "Find projects" },
		},
	},

	-- Better code navigation breadcrumbs
	{
		"SmiteshP/nvim-navic",
		dependencies = "neovim/nvim-lspconfig",
		event = "LspAttach",
		opts = {
			icons = {
				File = "📄",
				Module = "📦",
				Namespace = "📁",
				Package = "📦",
				Class = "🧱",
				Method = "ƒ",
				Property = "⚙",
				Field = "▸",
				Constructor = "◯",
				Enum = "≣",
				Interface = "🔱",
				Function = "λ",
				Variable = "𝑥",
				Constant = "π",
				String = "⌛",
				Number = "#",
				Boolean = "⊨",
				Array = "[]",
				Object = "{}",
				Key = "⌘",
				Null = "∅",
				EnumMember = "≣",
				Struct = "🧱",
				Event = "⚡",
				Operator = "◦",
				TypeParameter = "𝑇",
			},
			lsp = {
				auto_attach = true,
				preference = nil,
			},
			highlight = true,
			separator = " > ",
			depth_limit = 0,
			depth_limit_indicator = "..",
			safe_output = true,
			lazy_update_context = false,
			click = false,
		},
	},

	-- Markdown preview
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = function()
			vim.fn["mkdp#util#install"]()
		end,
		keys = {
			{ "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview", ft = "markdown" },
		},
	},

	-- Render markdown with visual effects (togglable)
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown" },
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("render-markdown").setup({
				enabled = false, -- start disabled (raw chars visible)
			})
		end,
		keys = {
			{ "<leader>jm", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle markdown render" },
		},
	},

	-- Session management
	{
		"folke/persistence.nvim",
		event = "VimEnter",
		opts = {
			dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"),
			options = { "buffers", "curdir", "tabpages", "winsize" },
			pre_save = nil,
		},
		keys = {
			{
				"<leader>qs",
				function()
					require("persistence").load()
				end,
				desc = "Restore session",
			},
			{
				"<leader>ql",
				function()
					require("persistence").load({ last = true })
				end,
				desc = "Restore last session",
			},
			{
				"<leader>qd",
				function()
					require("persistence").stop()
				end,
				desc = "Don't save current session",
			},
		},
	},
}
