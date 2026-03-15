-- ============================================================================
-- Git Configuration (gitsigns + fugitive + AI commits)
-- ============================================================================

-- Shared AI commit function
local progress_timer = nil
local spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
local spinner_idx = 0

local function clear_progress()
	if progress_timer then
		progress_timer:stop()
		progress_timer:close()
		progress_timer = nil
	end
	-- Clear previous echomsg by echoing empty with redraw
	vim.api.nvim_echo({ { "", "None" } }, false, {})
	vim.cmd("redraw")
end

local function show_progress(message)
	clear_progress()
	spinner_idx = 0
	local timer = vim.uv.new_timer()
	progress_timer = timer
	timer:start(500, 500, vim.schedule_wrap(function()
		if progress_timer == timer then
			spinner_idx = (spinner_idx % #spinner_frames) + 1
			local spinner = spinner_frames[spinner_idx]
			vim.cmd("redraw")
			vim.api.nvim_echo({ { spinner .. " " .. message, "ModeMsg" } }, false, {})
		end
	end))
	-- Show initial message immediately
	vim.api.nvim_echo({ { spinner_frames[1] .. " " .. message, "ModeMsg" } }, false, {})
end

local function run_system_async(cmd, callback)
	if not vim.system then
		callback(vim.fn.system(cmd), vim.v.shell_error)
		return
	end

	vim.system({ "sh", "-c", cmd }, { text = true }, vim.schedule_wrap(function(result)
		callback(result.stdout or "", result.code)
	end))
end

local function truncate_diff(diff, max_lines, max_chars)
	-- First truncate by lines
	local lines = vim.split(diff, "\n")
	if #lines > max_lines then
		lines = vim.list_slice(lines, 1, max_lines)
		table.insert(lines, "...")
	end
	local truncated = table.concat(lines, "\n")
	-- Then truncate by characters (approximate tokens / 4)
	if #truncated > max_chars then
		truncated = truncated:sub(1, max_chars) .. "..."
	end
	return truncated
end

local function commit_with_ai(mode)
	show_progress("Preparing commit...")
	local openai = require("config.openai")
	local auto_staged_file = nil

	-- Get git root asynchronously
	run_system_async("git rev-parse --show-toplevel 2>/dev/null", function(git_root, code)
		if code ~= 0 or not git_root or vim.trim(git_root) == "" then
			clear_progress()
			vim.notify("Not a git repository", vim.log.levels.ERROR)
			return
		end

		local function generate_and_commit(diff)
			if not diff or vim.trim(diff) == "" then
				clear_progress()
				vim.notify("No changes to commit", vim.log.levels.WARN)
				return
			end

			-- Limit diff to ~30 lines, ~2000 chars (~500 tokens)
			local lean_diff = truncate_diff(diff, 30, 2000)

			show_progress("Generating commit message...")
			local fallback = string.format("[%s] Auto-commit", os.date("%Y-%m-%d %H:%M"))
			openai.generate_commit_message_async(lean_diff, fallback, function(ai_message)
				clear_progress()
				vim.ui.input({ prompt = "Commit message: ", default = ai_message }, function(message)
					if not message or message == "" then
						if auto_staged_file then
							run_system_async(
								string.format("git reset HEAD -- %s", vim.fn.shellescape(auto_staged_file)),
								function() end
							)
						end
						vim.notify("Commit cancelled", vim.log.levels.INFO)
						return
					end

					show_progress("Committing...")
					run_system_async(string.format("git commit -m %s", vim.fn.shellescape(message)), function(result, commit_code)
						if commit_code ~= 0 then
							clear_progress()
							vim.notify("Commit failed: " .. result, vim.log.levels.ERROR)
							return
						end

						if mode == "all_and_push" then
							show_progress("Pushing...")
							run_system_async("git push 2>&1", function(push_result, push_code)
								clear_progress()
								if push_code ~= 0 then
									vim.notify("Committed but push failed: " .. push_result, vim.log.levels.WARN)
								else
									vim.notify("Committed and pushed: " .. message, vim.log.levels.INFO)
								end
							end)
						else
							clear_progress()
							vim.notify("Committed: " .. message, vim.log.levels.INFO)
						end
					end)
				end)
			end)
		end

		if mode == "current_file" then
			-- Check if there are staged changes
			run_system_async("git diff --cached --name-only", function(staged, _)
				if staged and vim.trim(staged) ~= "" then
					-- Use existing staged changes
					run_system_async("git diff --cached -U3", function(diff, _) generate_and_commit(diff) end)
				else
					-- Stage current file
					local current_file = vim.fn.expand("%:p")
					if current_file ~= "" then
						run_system_async(
							string.format("git add %s", vim.fn.shellescape(current_file)),
							function(_, add_code)
								if add_code ~= 0 then
									clear_progress()
									vim.notify("Failed to stage current file", vim.log.levels.ERROR)
									return
								end
								auto_staged_file = current_file
								run_system_async("git diff --cached -U3", function(diff, _) generate_and_commit(diff) end)
							end
						)
					else
						clear_progress()
						vim.notify("No file open and no staged changes", vim.log.levels.WARN)
					end
				end
			end)
		else
			-- Stage all and commit
			run_system_async("git add -A", function(_, add_code)
				if add_code ~= 0 then
					clear_progress()
					vim.notify("Failed to stage changes", vim.log.levels.ERROR)
					return
				end

				-- Check if there's anything to commit
				run_system_async("git diff --cached --quiet", function(_, quiet_code)
					if quiet_code == 0 then
						clear_progress()
						vim.notify("No changes to commit", vim.log.levels.INFO)
						return
					end

					run_system_async("git diff --cached -U3", function(diff, _) generate_and_commit(diff) end)
				end)
			end)
		end
	end)
end

-- Push function
local function push_to_remote()
	show_progress("Pushing changes...")
	run_system_async("git push 2>&1", function(result, code)
		clear_progress()
		if code ~= 0 then
			vim.notify("Push failed: " .. result, vim.log.levels.ERROR)
		else
			vim.notify("Pushed successfully", vim.log.levels.INFO)
		end
	end)
end

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
				current_line_blame = true,
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
					commit_with_ai("current_file")
				end,
				desc = "Git commit with AI message",
			},
			{
				"<leader>gP",
				function()
					push_to_remote()
				end,
				desc = "Git push",
			},
			{
				"<leader>gC",
				function()
					commit_with_ai("all")
				end,
				desc = "Git commit all with AI message",
			},
			{
				"<leader>gA",
				function()
					commit_with_ai("all_and_push")
				end,
				desc = "Git commit all & push",
			},
			{
				"<leader>gt",
				function()
					require("config.openai").test_commit_message()
				end,
				desc = "Test AI commit message generation",
			},
		},
	},
}
