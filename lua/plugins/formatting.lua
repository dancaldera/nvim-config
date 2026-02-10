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
	return root_has_file({ "biome.json", "biome.jsonc", ".biomerc.json", "biome.yaml" })
end

local function has_deno()
	return root_has_file({ "deno.json", "deno.jsonc" })
end

local function has_prettier()
	return root_has_file({
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

local function has_pyproject_toml()
	return root_has_file({ "pyproject.toml" })
end

local function has_ruff_config()
	if not has_pyproject_toml() then
		return false
	end
	local root = vim.fn.getcwd()
	-- Check for ruff config file
	if vim.fn.glob(root .. "/ruff.toml") ~= "" then
		return true
	end
	-- Check for pyproject.toml with [tool.ruff] section
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

-- Dynamic formatter selection for Python
local function python_formatter()
	-- Only use Ruff if project explicitly configures it
	if has_ruff_config() then
		return { "ruff_format" }
	end
	-- Otherwise, fallback to black+isort if project has [tool.black] config
	if has_black_config() then
		return { "isort", "black" }
	end
	-- No formatter configured - that's OK! (allows other tools like Biome to work)
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
				-- Format on save disabled by default
				-- To enable: uncomment and configure format_on_save below
				-- To format manually: use <leader>cf or <leader>jf
				-- format_on_save = { timeout_ms = 500, lsp_fallback = true },
				-- Notification for formatting
				notify_on_error = true,
			})

			vim.keymap.set({ "n", "v" }, "<leader>cf", function()
				conform.format({
					lsp_format = "fallback",
					async = false,
					timeout_ms = 1000,
				})
			end, { desc = "Format file or range (in visual mode)" })

			-- Alias for formatting
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

			-- Lint on save and insert leave
			local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

			-- Global state for auto-linting
			vim.g.auto_lint_enabled = true

			-- Helper to update linters based on filetype
			local function update_linters()
				local ft = vim.bo.filetype
				if ft == "javascript" or ft == "typescript" or ft == "javascriptreact" or ft == "typescriptreact" then
					lint.linters_by_ft[ft] = js_linter()
				end
			end

			vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
				group = lint_augroup,
				callback = function()
					-- Check if auto-linting is enabled
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

			-- Toggle Auto-Linting
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
					-- Clear diagnostics for the current buffer when disabling
					vim.diagnostic.reset(nil, 0)
				end
			end, { desc = "Toggle Auto-Linting" })
		end,
	},
}
