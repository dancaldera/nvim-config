-- ============================================================================
-- Remote Clipboard
--
-- - Local Wayland session: use wl-copy/wl-paste when available.
--   (Kept explicit because macOS-style pbcopy autodetection would not apply.)
-- - Remote (SSH) or tmux session: force Neovim's built-in OSC 52 provider.
--   It writes the escape sequence through the UI channel (no raw stdout
--   writes), so yanking never flickers the screen.
--
-- Requirements:
--   - tmux: `set -g set-clipboard on`
--   - terminal must support OSC 52 (kitty, alacritty, wezterm, ghostty, foot…)
--
-- See :h clipboard-osc52
-- ============================================================================

local M = {}

local function is_remote()
	return vim.env.SSH_TTY ~= nil or vim.env.TMUX ~= nil
end

function M.setup()
	-- Local Wayland session: prefer wl-copy/wl-paste if present.
	if not is_remote() then
		if vim.env.WAYLAND_DISPLAY and vim.fn.executable("wl-copy") == 1 then
			vim.g.clipboard = {
				name = "wayland",
				copy = {
					["+"] = "wl-copy",
					["*"] = "wl-copy",
				},
				paste = {
					["+"] = "wl-paste --no-newline",
					["*"] = "wl-paste --no-newline",
				},
				cache_enabled = 1,
			}
		end
		return
	end

	-- Remote/tmux session: use the bundled OSC 52 provider.
	vim.g.clipboard = "osc52"
end

M.setup()

return M
