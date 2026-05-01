-- ============================================================================
-- Completion Configuration (blink.cmp + copilot.vim)
-- ============================================================================

return {
	-- GitHub Copilot (official plugin - ghost text, independent of completion menu)
	{
		"github/copilot.vim",
		event = { "BufReadPre", "BufNewFile" },
		cmd = "Copilot",
		init = function()
			local node = vim.fn.exepath("node")
			if node ~= "" then
				vim.g.copilot_node_command = node
			end

			-- Prefer the bundled language server so auth/session behavior
			-- does not depend on npx resolving a different runtime per launch.
			vim.g.copilot_version = false
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

	-- Fast LSP/Snippet/Path/Buffer completion (replaces nvim-cmp + LuaSnip + lspkind)
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
