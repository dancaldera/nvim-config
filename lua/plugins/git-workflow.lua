return {
	{
		"tpope/vim-fugitive",
		cmd = "Git",
		keys = {
			{
				"<leader>gc",
				function()
					local openai = require("config.openai")
					local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null")
					git_root = vim.trim(git_root)

					if git_root == "" then
						vim.notify("Not a git repository", vim.log.levels.ERROR)
						return
					end

					local staged = vim.fn.system("git diff --cached --name-only")
					staged = vim.trim(staged)

					local diff
					if staged ~= "" then
						diff = vim.fn.system("git diff --cached -U5 --unified=5 | head -n 50")
					else
						local current_file = vim.fn.expand("%:p")
						if current_file ~= "" then
							vim.fn.system(string.format("git add %s", vim.fn.shellescape(current_file)))
							diff = vim.fn.system("git diff --cached -U5 --unified=5 | head -n 50")
						else
							vim.notify("No file open and no staged changes", vim.log.levels.WARN)
							return
						end
					end

					diff = vim.trim(diff)
					if diff == "" then
						vim.notify("No changes to commit", vim.log.levels.WARN)
						return
					end

					local timestamp = os.date("%Y-%m-%d %H:%M")
					local fallback = string.format("[%s] Auto-commit", timestamp)

					vim.notify("Generating commit message with AI...", vim.log.levels.INFO)
					local ai_message = openai.generate_commit_message(diff, fallback)

					vim.ui.input({
						prompt = "Commit message (edit AI suggestion): ",
						default = ai_message,
					}, function(message)
						if not message or message == "" then
							vim.notify("Commit cancelled", vim.log.levels.INFO)
							return
						end

						local result = vim.fn.system(string.format('git commit -m %s', vim.fn.shellescape(message)))
						if vim.v.shell_error ~= 0 then
							vim.notify("Commit failed: " .. result, vim.log.levels.ERROR)
						else
							vim.notify("Committed: " .. message, vim.log.levels.INFO)
						end
					end)
				end,
				desc = "Git commit with AI message",
			},

			{
				"<leader>gP",
				function()
					local result = vim.fn.system("git push 2>&1")
					if vim.v.shell_error ~= 0 then
						vim.notify("Push failed: " .. result, vim.log.levels.ERROR)
					else
						vim.notify("Pushed successfully", vim.log.levels.INFO)
					end
				end,
				desc = "Git push",
			},

			{
				"<leader>gA",
				function()
					local openai = require("config.openai")

					vim.fn.system("git add -A")

					local status = vim.fn.system("git status --porcelain")
					if vim.trim(status) == "" then
						vim.notify("No changes to commit", vim.log.levels.INFO)
						return
					end

					local diff = vim.fn.system("git diff -U5 --unified=5 --cached | head -n 50")
					diff = vim.trim(diff)

					if diff == "" then
						vim.notify("No staged changes", vim.log.levels.WARN)
						return
					end

					local timestamp = os.date("%Y-%m-%d %H:%M")
					local fallback = string.format("[%s] Auto-commit", timestamp)

					vim.notify("Generating commit message with AI...", vim.log.levels.INFO)
					local ai_message = openai.generate_commit_message(diff, fallback)

					vim.ui.input({
						prompt = "Commit message (edit AI suggestion): ",
						default = ai_message,
					}, function(message)
						if not message or message == "" then
							vim.notify("Commit cancelled", vim.log.levels.INFO)
							return
						end

						local commit_result = vim.fn.system(string.format('git commit -m %s', vim.fn.shellescape(message)))
						if vim.v.shell_error ~= 0 then
							vim.notify("Commit failed: " .. commit_result, vim.log.levels.ERROR)
							return
						end

						local push_result = vim.fn.system("git push 2>&1")
						if vim.v.shell_error ~= 0 then
							vim.notify("Committed but push failed: " .. push_result, vim.log.levels.WARN)
						else
							vim.notify("Committed and pushed: " .. message, vim.log.levels.INFO)
						end
					end)
				end,
				desc = "Git auto-commit & push",
			},
		},
	},
}
