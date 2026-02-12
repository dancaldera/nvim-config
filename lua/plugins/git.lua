-- ============================================================================
-- Git Configuration (gitsigns + fugitive + AI commits)
-- ============================================================================

return {
	-- Gitsigns (hunks, blame, staging)
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("gitsigns").setup({
				signs = {
					add = { text = "│" },
					change = { text = "│" },
					delete = { text = "_" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
					untracked = { text = "┆" },
				},
				signcolumn = true,
				current_line_blame = false,
				current_line_blame_opts = {
					virt_text = true,
					virt_text_pos = "eol",
					delay = 1000,
				},
				on_attach = function(bufnr)
					local gs = package.loaded.gitsigns

					local function map(mode, l, r, opts)
						opts = opts or {}
						opts.buffer = bufnr
						vim.keymap.set(mode, l, r, opts)
					end

					-- Navigation
					map("n", "]c", function()
						if vim.wo.diff then
							return "]c"
						end
						vim.schedule(function()
							gs.next_hunk()
						end)
						return "<Ignore>"
					end, { expr = true, desc = "Next git hunk" })

					map("n", "[c", function()
						if vim.wo.diff then
							return "[c"
						end
						vim.schedule(function()
							gs.prev_hunk()
						end)
						return "<Ignore>"
					end, { expr = true, desc = "Previous git hunk" })

					-- Actions
					map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage hunk" })
					map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset hunk" })
					map("v", "<leader>hs", function()
						gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end, { desc = "Stage hunk" })
					map("v", "<leader>hr", function()
						gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end, { desc = "Reset hunk" })
					map("n", "<leader>hS", gs.stage_buffer, { desc = "Stage buffer" })
					map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "Undo stage hunk" })
					map("n", "<leader>hR", gs.reset_buffer, { desc = "Reset buffer" })
					map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })
					map("n", "<leader>hb", function()
						gs.blame_line({ full = true })
					end, { desc = "Blame line" })
					map("n", "<leader>gb", gs.toggle_current_line_blame, { desc = "Toggle line blame" })
					map("n", "<leader>hd", gs.diffthis, { desc = "Diff this" })
					map("n", "<leader>hD", function()
						gs.diffthis("~")
					end, { desc = "Diff this ~" })
					map("n", "<leader>gd", gs.toggle_deleted, { desc = "Toggle deleted" })

					-- Text object
					map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select git hunk" })
				end,
			})
		end,
	},

	-- Fugitive + AI-powered commit workflow
	{
		"tpope/vim-fugitive",
		cmd = "Git",
		keys = {
			{
				"<leader>gc",
				function()
					local openai = require("config.openai")
					local git_root = vim.trim(vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"))

					if git_root == "" then
						vim.notify("Not a git repository", vim.log.levels.ERROR)
						return
					end

					local staged = vim.trim(vim.fn.system("git diff --cached --name-only"))
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

					local fallback = string.format("[%s] Auto-commit", os.date("%Y-%m-%d %H:%M"))

					vim.notify("Generating commit message with AI...", vim.log.levels.INFO)
					local ai_message = openai.generate_commit_message(diff, fallback)

					vim.ui.input({ prompt = "Commit message: ", default = ai_message }, function(message)
						if not message or message == "" then
							vim.notify("Commit cancelled", vim.log.levels.INFO)
							return
						end
						local result = vim.fn.system(string.format("git commit -m %s", vim.fn.shellescape(message)))
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
				"<leader>gC",
				function()
					local openai = require("config.openai")
					vim.fn.system("git add -A")

					local status = vim.fn.system("git status --porcelain")
					if vim.trim(status) == "" then
						vim.notify("No changes to commit", vim.log.levels.INFO)
						return
					end

					local diff = vim.trim(vim.fn.system("git diff -U5 --unified=5 --cached | head -n 50"))
					if diff == "" then
						vim.notify("No staged changes", vim.log.levels.WARN)
						return
					end

					local fallback = string.format("[%s] Auto-commit", os.date("%Y-%m-%d %H:%M"))
					vim.notify("Generating commit message with AI...", vim.log.levels.INFO)
					local ai_message = openai.generate_commit_message(diff, fallback)

					vim.ui.input({ prompt = "Commit message: ", default = ai_message }, function(message)
						if not message or message == "" then
							vim.notify("Commit cancelled", vim.log.levels.INFO)
							return
						end
						local result = vim.fn.system(string.format("git commit -m %s", vim.fn.shellescape(message)))
						if vim.v.shell_error ~= 0 then
							vim.notify("Commit failed: " .. result, vim.log.levels.ERROR)
						else
							vim.notify("Committed: " .. message, vim.log.levels.INFO)
						end
					end)
				end,
				desc = "Git commit all with AI message",
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

					local diff = vim.trim(vim.fn.system("git diff -U5 --unified=5 --cached | head -n 50"))
					if diff == "" then
						vim.notify("No staged changes", vim.log.levels.WARN)
						return
					end

					local fallback = string.format("[%s] Auto-commit", os.date("%Y-%m-%d %H:%M"))
					vim.notify("Generating commit message with AI...", vim.log.levels.INFO)
					local ai_message = openai.generate_commit_message(diff, fallback)

					vim.ui.input({ prompt = "Commit message: ", default = ai_message }, function(message)
						if not message or message == "" then
							vim.notify("Commit cancelled", vim.log.levels.INFO)
							return
						end
						local commit_result =
							vim.fn.system(string.format("git commit -m %s", vim.fn.shellescape(message)))
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
				desc = "Git commit all & push",
			},
		},
	},
}
