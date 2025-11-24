-- ============================================================================
-- Code Formatting and Linting Configuration
-- ============================================================================

-- Detection functions for project-specific tools
local function root_has_file(patterns)
	local root = vim.fn.getcwd()
	for _, pattern in ipairs(patterns) do
		if vim.fn.glob(root .. "/" .. pattern) ~= "" then
			return true
		end
	end
	return false
end

local function has_biome()
	return root_has_file({ "biome.json", "biome.jsonc" })
end

local function has_deno()
	return root_has_file({ "deno.json", "deno.jsonc" })
end

local function has_prettier()
	return root_has_file({
		".prettierrc",
		".prettierrc.json",
		".prettierrc.yml",
		".prettierrc.yaml",
		".prettierrc.js",
		".prettierrc.cjs",
		".prettierrc.mjs",
		"prettier.config.js",
		"prettier.config.cjs",
		"prettier.config.mjs",
	})
end

local function has_eslint()
	return root_has_file({
		".eslintrc",
		".eslintrc.js",
		".eslintrc.cjs",
		".eslintrc.json",
		".eslintrc.yml",
		".eslintrc.yaml",
		"eslint.config.js",
		"eslint.config.cjs",
		"eslint.config.mjs",
	})
end

-- Dynamic formatter selection for JS/TS
local function js_formatter()
	if has_biome() then
		return { "biome" }
	elseif has_deno() then
		return { "deno_fmt" }
	else
		return { "prettier" } -- default fallback
	end
end

-- Dynamic linter selection for JS/TS
local function js_linter()
	if has_biome() then
		return { "biomejs" }
	elseif has_eslint() then
		return { "eslint_d" }
	else
		return {} -- no linting if no config found
	end
end

return {
	-- Formatter
	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local conform = require("conform")

			conform.setup({
				formatters_by_ft = {
					javascript = js_formatter,
					typescript = js_formatter,
					javascriptreact = js_formatter,
					typescriptreact = js_formatter,
					svelte = { "prettier" },
					css = { "prettier" },
					html = { "prettier" },
					json = { "prettier" },
					yaml = { "prettier" },
					markdown = { "prettier" },
					graphql = { "prettier" },
					liquid = { "prettier" },
					lua = { "stylua" },
					python = { "isort", "black" },
					rust = { "rustfmt", lsp_format = "fallback" },
					go = { "goimports", "gofmt" },
					sh = { "shfmt" },
					c = { "clang_format" },
					cpp = { "clang_format" },
				},
				-- Disable automatic formatting on save; users can trigger `<leader>mp` instead
				format_on_save = false,
				-- Notification for formatting
				notify_on_error = true,
				-- Format after changes
				format_after_save = nil,
			})

			vim.keymap.set({ "n", "v" }, "<leader>mp", function()
				conform.format({
					lsp_format = "fallback",
					async = false,
					timeout_ms = 1000,
				})
			end, { desc = "Format file or range (in visual mode)" })
		end,
	},

	-- Linter
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local lint = require("lint")

			lint.linters_by_ft = {
				python = { "ruff" },
				go = { "golangcilint" },
			}

			-- Lint on save and insert leave
			local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
			vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
				group = lint_augroup,
				callback = function()
					-- Dynamic linter selection for JS/TS
					local ft = vim.bo.filetype
					if
						ft == "javascript"
						or ft == "typescript"
						or ft == "javascriptreact"
						or ft == "typescriptreact"
					then
						lint.linters_by_ft[ft] = js_linter()
					end
					lint.try_lint()
				end,
			})

			vim.keymap.set("n", "<leader>ml", function()
				lint.try_lint()
			end, { desc = "Lint current file" })
		end,
	},
}
