-- ============================================================================
-- Audio Playback Helpers
-- ============================================================================

local M = {}

local players = {
	{
		name = "mpv",
		cmd = "mpv",
		args = function(path)
			return { "--force-window=no", "--keep-open=no", path }
		end,
	},
	{
		name = "ffplay",
		cmd = "ffplay",
		args = function(path)
			return { "-nodisp", "-autoexit", path }
		end,
	},
	{
		name = "mpg123",
		cmd = "mpg123",
		args = function(path)
			return { path }
		end,
	},
}

M.state = {
	term_buf = nil,
	win_id = nil,
	job_id = nil,
	player = nil,
	path = nil,
}

function M.detect_player()
	for _, player in ipairs(players) do
		if vim.fn.executable(player.cmd) == 1 then
			return player
		end
	end

	return nil
end

function M.build_command(player, path)
	return vim.list_extend({ player.cmd }, player.args(path))
end

local function cleanup_terminal()
	local state = M.state
	local term_buf = state.term_buf
	local win_id = state.win_id

	if win_id and vim.api.nvim_win_is_valid(win_id) then
		vim.api.nvim_win_close(win_id, true)
	end

	if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
		pcall(vim.api.nvim_buf_delete, term_buf, { force = true })
	end

	state.win_id = nil
	state.term_buf = nil
	state.job_id = nil
end

function M.stop(opts)
	opts = opts or {}

	local state = M.state
	local had_playback = state.job_id ~= nil or state.term_buf ~= nil

	if state.job_id and state.job_id > 0 then
		pcall(vim.fn.jobstop, state.job_id)
	end

	cleanup_terminal()

	state.player = nil
	state.path = nil

	return had_playback
end

function M.toggle_pause()
	local job_id = M.state.job_id
	if not job_id or job_id <= 0 then
		vim.notify("No active audio playback", vim.log.levels.INFO)
		return false
	end

	vim.api.nvim_chan_send(job_id, " ")
	return true
end

local function floating_window_config()
	local columns = vim.o.columns
	local lines = vim.o.lines - vim.o.cmdheight
	local width = math.max(60, math.floor(columns * 0.8))
	local height = math.max(10, math.floor(lines * 0.7))

	return {
		relative = "editor",
		style = "minimal",
		border = "rounded",
		width = math.min(width, columns - 4),
		height = math.min(height, lines - 4),
		col = math.max(0, math.floor((columns - width) / 2)),
		row = math.max(0, math.floor((lines - height) / 2) - 1),
	}
end

function M.open(path)
	local normalized_path = vim.fn.fnamemodify(path, ":p")
	local player = M.detect_player()
	if not player then
		vim.notify("No supported audio player found (mpv, ffplay, mpg123)", vim.log.levels.ERROR)
		return false
	end

	M.stop()

	local current_buf = vim.api.nvim_get_current_buf()
	local current_path = vim.api.nvim_buf_get_name(current_buf)
	if current_path == normalized_path then
		vim.cmd("enew")
		if vim.api.nvim_buf_is_valid(current_buf) then
			pcall(vim.api.nvim_buf_delete, current_buf, { force = true })
		end
	end

	local term_buf = vim.api.nvim_create_buf(false, true)
	vim.bo[term_buf].bufhidden = "wipe"
	vim.bo[term_buf].swapfile = false
	vim.bo[term_buf].filetype = "audio-player"

	local win_id = vim.api.nvim_open_win(term_buf, true, floating_window_config())
	local cmd = M.build_command(player, normalized_path)
	local job_id = vim.fn.termopen(cmd, {
		on_exit = vim.schedule_wrap(function()
			local current_term_buf = M.state.term_buf
			local current_job_id = M.state.job_id
			if current_term_buf == term_buf or current_job_id == job_id then
				M.stop()
			end
		end),
	})

	if job_id <= 0 then
		vim.notify("Failed to start audio player", vim.log.levels.ERROR)
		if win_id and vim.api.nvim_win_is_valid(win_id) then
			vim.api.nvim_win_close(win_id, true)
		end
		pcall(vim.api.nvim_buf_delete, term_buf, { force = true })
		return false
	end

	M.state.win_id = win_id
	M.state.term_buf = term_buf
	M.state.job_id = job_id
	M.state.player = player.name
	M.state.path = normalized_path

	vim.cmd("startinsert")
	return true
end

function M.open_mp3_buffer(bufnr, path)
	M.open(path)
end

function M.setup()
	vim.api.nvim_create_user_command("AudioPause", function()
		M.toggle_pause()
	end, { desc = "Toggle pause for active audio playback" })

	vim.api.nvim_create_user_command("AudioStop", function()
		if not M.stop() then
			vim.notify("No active audio playback", vim.log.levels.INFO)
		end
	end, { desc = "Stop active audio playback" })

	vim.api.nvim_create_autocmd("BufReadCmd", {
		group = vim.api.nvim_create_augroup("AudioPlayback", { clear = true }),
		pattern = { "*.mp3", "*.MP3" },
		callback = function(args)
			M.open_mp3_buffer(args.buf, args.file)
		end,
	})
end

return M
