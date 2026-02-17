-- ============================================================================
-- Code Formatting and Linting Configuration
-- ============================================================================

-- Generic config file detector
local function root_has_file(patterns)
	local root = vim.fn.getcwd()
	for _, pattern in ipairs(patterns) do
		if vim.fn.glob(root .. "/" .. pattern) ~= "" then
			return true
		end
	end
	return false
end

-- JavaScript/TypeScript formatters
local js_formatter_patterns = {
	"biome.json",
	"biome.jsonc",
	".biomerc.json",
	"biome.yaml",
	"deno.json",
	"deno.jsonc",
	".prettierrc",
	".prettierrc.json",
	".prettierrc.js",
	".prettierrc.cjs",
	".prettierrc.mjs",
	".prettierrc.yml",
	".prettierrc.yaml",
	"prettier.config.js",
	"prettier.config.cjs",
	"prettier.config.mjs",
	".prettierignore",
}

local function js_formatter()
	if root_has_file({ "biome.json", "biome.jsonc", ".biomerc.json", "biome.yaml" }) then
		return { "biome" }
	elseif root_has_file({ "deno.json", "deno.jsonc" }) then
		return { "deno_fmt" }
	else
		return { "prettier" }
	end
end

local function js_linter()
	if root_has_file({ "biome.json", "biome.jsonc", ".biomerc.json", "biome.yaml" }) then
		return { "biomejs" }
	elseif
		root_has_file({
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
	then
		return { "eslint_d" }
	else
		return {}
	end
end

-- Python formatter detection
local function has_pyproject_toml()
	return root_has_file({ "pyproject.toml" })
end

local function has_ruff_config()
	if not has_pyproject_toml() then
		return false
	end
	local root = vim.fn.getcwd()
	if vim.fn.glob(root .. "/ruff.toml") ~= "" then
		return true
	end
	local pyproject = root .. "/pyproject.toml"
	if vim.fn.filereadable(pyproject) == 1 then
		local content = vim.fn.readfile(pyproject)
		for _, line in ipairs(content) do
			if string.match(line, "%[tool%.ruff%]") then
				return true
			end
		end
	end
	return false
end

local function has_black_config()
	if not has_pyproject_toml() then
		return false
	end
	local pyproject = vim.fn.getcwd() .. "/pyproject.toml"
	if vim.fn.filereadable(pyproject) == 1 then
		local content = vim.fn.readfile(pyproject)
		for _, line in ipairs(content) do
			if string.match(line, "%[tool%.black%]") then
				return true
			end
		end
	end
	return false
end

local function python_formatter()
	if has_ruff_config() then
		return { "ruff_format" }
	end
	if has_black_config() then
		return { "isort", "black" }
	end
	return {}
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
					python = python_formatter,
					rust = { "rustfmt", lsp_format = "fallback" },
					go = { "goimports", "gofmt" },
					sh = { "shfmt" },
					c = { "clang_format" },
					cpp = { "clang_format" },
				},
				notify_on_error = true,
			})

			vim.keymap.set({ "n", "v" }, "<leader>cf", function()
				conform.format({
					lsp_format = "fallback",
					async = false,
					timeout_ms = 1000,
				})
			end, { desc = "Format file or range (in visual mode)" })

			vim.keymap.set({ "n", "v" }, "<leader>jf", function()
				conform.format({
					lsp_format = "fallback",
					async = false,
					timeout_ms = 1000,
				})
			end, { desc = "Format file (alias for <leader>cf)" })
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

			local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

			vim.g.auto_lint_enabled = true

			local function update_linters()
				local ft = vim.bo.filetype
				if ft == "javascript" or ft == "typescript" or ft == "javascriptreact" or ft == "typescriptreact" then
					lint.linters_by_ft[ft] = js_linter()
				end
			end

			vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
				group = lint_augroup,
				callback = function()
					if not vim.g.auto_lint_enabled then
						return
					end

					update_linters()
					lint.try_lint()
				end,
			})

			vim.keymap.set("n", "<leader>ml", function()
				update_linters()
				lint.try_lint()
				local linters = lint.linters_by_ft[vim.bo.filetype] or {}
				if #linters > 0 then
					vim.notify("Linting with: " .. table.concat(linters, ", "), vim.log.levels.INFO)
				else
					vim.notify("No linter configured for this filetype", vim.log.levels.WARN)
				end
			end, { desc = "Lint current file (Manual)" })

			vim.keymap.set("n", "<leader>jl", function()
				vim.g.auto_lint_enabled = not vim.g.auto_lint_enabled
				if vim.g.auto_lint_enabled then
					update_linters()
					local linters = lint.linters_by_ft[vim.bo.filetype] or {}
					local linter_msg = #linters > 0 and (" (" .. table.concat(linters, ", ") .. ")") or ""
					vim.notify("Auto-linting ENABLED" .. linter_msg, vim.log.levels.INFO)
					lint.try_lint()
				else
					vim.notify("Auto-linting DISABLED", vim.log.levels.INFO)
					vim.diagnostic.reset(nil, 0)
				end
			end, { desc = "Toggle Auto-Linting" })
		end,
	},
}
