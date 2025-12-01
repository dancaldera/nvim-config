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
		end,
	},
}
