-- ============================================================================
-- Completion Configuration (blink.cmp + copilot.vim)
-- ============================================================================

return {
	-- GitHub Copilot (official plugin - ghost text, independent of completion menu)
	{
		"github/copilot.vim",
		event = "InsertEnter",
		cmd = "Copilot",
		init = function()
			local node = vim.fn.exepath("node")
			if node ~= "" then
				vim.g.copilot_node_command = node
			end

			vim.g.copilot_no_tab_map = true
		end,
		config = function()
			-- Simplified Copilot keybindings: only accept and dismiss
			vim.keymap.set("i", "<C-g>", 'copilot#Accept("\\<CR>")', {
				expr = true,
				replace_keycodes = false,
				desc = "Accept Copilot suggestion",
			})
			vim.keymap.set("i", "<C-x>", "<Plug>(copilot-dismiss)", { desc = "Dismiss Copilot" })
		end,
	},

	-- Fast LSP/Snippet/Path/Buffer completion
	{
		"saghen/blink.cmp",
		version = "1.*",
		event = "InsertEnter",
		dependencies = {
			"rafamadriz/friendly-snippets",
		},
		opts = {
			keymap = {
				preset = "default",
				["<C-Space>"] = { "show", "show_documentation" },
				["<C-k>"] = { "select_prev", "fallback" },
				["<C-j>"] = { "select_next", "fallback" },
				["<CR>"] = { "accept", "fallback" },
				["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
				["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
			},
			appearance = {
				nerd_font_variant = "mono",
			},
			completion = {
				documentation = { auto_show = true },
				menu = { auto_show = true },
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},
			snippets = { preset = "default" },
		},
	},
}
