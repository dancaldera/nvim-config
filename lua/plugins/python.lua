-- ============================================================================
-- Python Environment Configuration
-- ============================================================================

return {
	{
		"AckslD/swenv.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		event = { "BufReadPre *.py", "BufNewFile *.py" },
		keys = {
			{
				"<leader>pv",
				function()
					require("swenv.api").pick_venv()
				end,
				desc = "Pick Python venv",
			},
		},
		config = function()
			require("swenv").setup({
				-- Get venvs from these locations
				venvs_path = vim.fn.expand("~/.virtualenvs"),
				-- Search both global and project-local venvs
				get_venvs = function(venvs_path)
					local venvs = require("swenv.api").get_venvs(venvs_path)
					-- Add project-local venvs with error handling
					local ok, cwd = pcall(vim.fn.getcwd)
					if not ok then
						return venvs
					end

					-- Base virtualenv detection
					local local_venv_names = { ".venv", "venv", ".env", "env" }
					for _, name in ipairs(local_venv_names) do
						local path = cwd .. "/" .. name
						local dir_ok, is_dir = pcall(vim.fn.isdirectory, path)
						if dir_ok and is_dir == 1 then
							table.insert(venvs, 1, { name = name .. " (local)", path = path })
						end
					end

					-- Poetry detection (standard paths only)
					local poetry_venvs = {
						cwd .. "/.venv",
						cwd .. "/venv",
						vim.fn.expand("~/.local/share/pypoetry/virtualenvs"),
					}
					for _, path in ipairs(poetry_venvs) do
						if vim.fn.isdirectory(path) == 1 then
							-- Try to get Poetry venv name
							local venv_name = nil
							local ok, result = pcall(function()
								return vim.fn.system("poetry env info --name 2>/dev/null"):gsub("\n", "")
							end)
							if ok and result and result ~= "" then
								venv_name = "poetry:" .. result
							else
								venv_name = "poetry:default"
							end
							table.insert(venvs, 1, { name = venv_name, path = path })
							break
						end
					end

					-- UV detection (check both .python-version and uv.lock)
					local has_python_version = vim.fn.filereadable(cwd .. "/.python-version") == 1
					local has_uv_lock = vim.fn.filereadable(cwd .. "/uv.lock") == 1

					if has_python_version or has_uv_lock then
						local uv_venv_paths = {
							cwd .. "/.venv",
							cwd .. "/.uvvenv",
							vim.fn.expand("~/.cache/uv"),
						}
						for _, path in ipairs(uv_venv_paths) do
							if vim.fn.isdirectory(path) == 1 then
								local venv_name = "uv:local"
								-- Try to get UV venv name
								local ok, result = pcall(function()
									return vim.fn.system("uv python info 2>/dev/null"):match("Name: ([^\n]+)")
								end)
								if ok and result then
									venv_name = "uv:" .. result
								end
								table.insert(venvs, 1, { name = venv_name, path = path })
								break
							end
						end
					end

					-- Pipenv detection
					local pipfile_path = cwd .. "/Pipfile"
					if vim.fn.filereadable(pipfile_path) == 1 then
						local ok, result = pcall(function()
							return vim.fn.system("pipenv --venv 2>/dev/null"):gsub("\n", "")
						end)
						if ok and result and result ~= "" then
							table.insert(venvs, 1, { name = "pipenv:project", path = result })
						end
					end

					return venvs
				end,
				-- Notify LSP when venv changes
				post_set_venv = function()
					vim.cmd("LspRestart")
				end,
			})

			-- Auto-select venv function
			local function auto_select_venv()
				local ok, swenv_api = pcall(require, "swenv.api")
				if not ok then
					return nil
				end

				-- Don't override existing selection
				if swenv_api.get_current_venv() then
					return nil
				end

				local venvs = swenv_api.get_venvs()
				if not venvs or #venvs == 0 then
					return nil
				end

				-- Select first local/project venv only
				local venv = venvs[1]
				if
					venv.name:match("%(local%)")
					or venv.name:match("^poetry:")
					or venv.name:match("^uv:")
					or venv.name:match("^pipenv:")
				then
					swenv_api.set_venv(venv.name)
					return venv
				end
				return nil
			end

			-- Auto-detect venv on Python file open
			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = "*.py",
				group = vim.api.nvim_create_augroup("PythonAutoVenv", { clear = true }),
				callback = function()
					local cwd = vim.fn.getcwd()
					if vim.g._python_venv_cwd == cwd then
						return
					end
					vim.g._python_venv_cwd = cwd

					vim.defer_fn(function()
						auto_select_venv()
					end, 50)
				end,
			})

			-- Reset on directory change
			vim.api.nvim_create_autocmd("DirChanged", {
				group = vim.api.nvim_create_augroup("PythonAutoVenvDir", { clear = true }),
				callback = function()
					vim.g._python_venv_cwd = nil
				end,
			})
		end,
	},
}
