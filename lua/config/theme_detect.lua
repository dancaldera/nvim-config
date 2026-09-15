-- ============================================================================
-- Theme detection: follow the OS / terminal light-vs-dark setting
-- ============================================================================
-- Priority:
--   1. $NVIM_BACKGROUND / $VIM_BACKGROUND override ("light" or "dark")
--   2. macOS system appearance (defaults read -g AppleInterfaceStyle)
--   3. Linux desktop settings (gsettings / kreadconfig / GTK_THEME)
--   4. $COLORFGBG heuristic (terminals that export it)
--   5. Terminal background query (OSC 11) — best effort, fast timeout
--   6. Fallback: current &background, defaulting to "dark"
--
-- Live switching: start_watcher() polls the OS setting and re-checks on
-- FocusGained/VimResume, swapping background + tokyonight variant only when
-- the detected value actually changed.

local M = {}

---@return "light"|"dark"|nil
local function env_override()
	local v = vim.env.NVIM_BACKGROUND or vim.env.VIM_BACKGROUND
	if v == "light" or v == "dark" then
		return v
	end
	return nil
end

---@return "light"|"dark"|nil
local function macos_appearance()
	if vim.fn.has("mac") ~= 1 and vim.fn.has("macunix") ~= 1 then
		return nil
	end
	if vim.fn.executable("defaults") ~= 1 then
		return nil
	end
	-- "Dark" when dark mode is on; command fails (no key) when in light mode.
	local out = vim.fn.system("defaults read -g AppleInterfaceStyle 2>/dev/null")
	if out:match("Dark") then
		return "dark"
	end
	if vim.v.shell_error == 0 then
		return "dark"
	end
	-- No key means light mode on macOS.
	return "light"
end

---@return "light"|"dark"|nil
local function linux_desktop()
	if vim.fn.has("mac") == 1 or vim.fn.has("win32") == 1 then
		return nil
	end
	-- GNOME / freedesktop color-scheme: 'prefer-dark' | 'prefer-light' | 'default'
	if vim.fn.executable("gsettings") == 1 then
		local scheme = vim.fn.system("gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null")
		if scheme:match("prefer%-dark") then
			return "dark"
		elseif scheme:match("prefer%-light") then
			return "light"
		end
		local gtk = vim.fn.system("gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null"):lower()
		if gtk:match("dark") then
			return "dark"
		elseif gtk ~= "" and (gtk:match("light") or gtk:match("day")) then
			return "light"
		end
	end
	-- KDE Plasma 6 / 5
	for _, bin in ipairs({ "kreadconfig6", "kreadconfig5", "kreadconfig" }) do
		if vim.fn.executable(bin) == 1 then
			local out = vim.fn.system(bin .. " --group General --key ColorScheme 2>/dev/null"):lower()
			if out:match("dark") then
				return "dark"
			elseif out:match("light") then
				return "light"
			end
			break
		end
	end
	-- Plain env hints some setups export
	local gtk_theme = (vim.env.GTK_THEME or ""):lower()
	if gtk_theme:match("dark") then
		return "dark"
	elseif gtk_theme:match("light") then
		return "light"
	end
	return nil
end

---@return "light"|"dark"|nil
local function colorfgbg_heuristic()
	local v = vim.env.COLORFGBG
	if not v or v == "" then
		return nil
	end
	-- Format is "fg;bg" or "fg;default;bg". Low palette numbers (0-6, 8)
	-- are dark backgrounds, high ones (7, 15, ...) are light.
	local bg = v:match("([^;]+)%s*$")
	local n = bg and tonumber(bg)
	if not n then
		return nil
	end
	if n == 0 or n == 1 or n == 2 or n == 3 or n == 4 or n == 5 or n == 6 or n == 8 then
		return "dark"
	end
	return "light"
end

-- Query the terminal emulator itself for its background color via OSC 11.
-- Returns nil quickly when unsupported (most callers should treat nil as
-- "keep asking other sources"). Guarded to run at most once per process
-- unless forced, since it touches the tty with a short timeout.
local osc_cache = nil
local osc_queried = false

---@param r integer 0-65535
---@param g integer 0-65535
---@param b integer 0-65535
---@return "light"|"dark"
local function luminance_class(r, g, b)
	-- Relative luminance, 0-1. Threshold ~0.5 separates dark/light terms.
	local lum = (0.2126 * r + 0.7152 * g + 0.0722 * b) / 65535
	return lum > 0.5 and "light" or "dark"
end

---@param force? boolean
---@return "light"|"dark"|nil
local function terminal_osc11(force)
	if osc_queried and not force then
		return osc_cache
	end
	osc_queried = true
	-- Only try when attached to a real tty; skip in headless/embedded use.
	if vim.fn.has("ttyin") ~= 1 and vim.env.TERM == nil then
		return nil
	end
	local ok, result = pcall(function()
		-- Ask: OSC 11 ; ? ST. Read reply: OSC 11 ; rgb:RRRR/GGGG/BBBB ST.
		-- Wrapped in a tight timeout so unsupported terminals cost ~50ms once.
		local cmd =
			"stty -g < /dev/tty 2>/dev/null && printf '\\033]11;?\\033\\\\' > /dev/tty 2>/dev/null && timeout 0.05 head -c 64 < /dev/tty 2>/dev/null | od -An -tx1 | tr -d ' \\n'"
		local hex = vim.fn.system(cmd)
		if vim.v.shell_error ~= 0 or not hex or hex == "" then
			return nil
		end
		-- Response contains "rgb:" followed by hex triplets; find them in the
		-- raw hex dump (72 67 62 3a = "rgb:").
		local idx = hex:find("7267623a")
		if not idx then
			return nil
		end
		local tail = hex:sub(idx + 8):gsub("0a$", "")
		-- Split on 2f ("/"): r / g / b, each 2 or 4 hex digits.
		local parts = {}
		for part in (tail .. "2f"):gmatch("(.-)2f") do
			table.insert(parts, part)
		end
		if #parts < 3 then
			return nil
		end
		local function to16(s)
			s = s:gsub("%s+", "")
			if #s <= 2 then
				-- 8-bit component: scale up
				local v = tonumber(s, 16)
				return v and (v * 257) or nil
			end
			-- 16-bit component, possibly longer vendor forms: take leading 4
			return tonumber(s:sub(1, 4), 16)
		end
		local r, g, b = to16(parts[1]), to16(parts[2]), to16(parts[3])
		if not (r and g and b) then
			return nil
		end
		return luminance_class(r, g, b)
	end)
	if not ok then
		return nil
	end
	osc_cache = result
	return osc_cache
end

---Detect the desired background. Never returns nil.
---@return "light"|"dark"
function M.get()
	return env_override()
		or macos_appearance()
		or linux_desktop()
		or colorfgbg_heuristic()
		or terminal_osc11(false)
		or (vim.o.background == "light" and "light" or "dark")
end

---Map the detected background to this config's tokyonight variant.
---@param bg? "light"|"dark"
---@return string colorscheme name
function M.colorscheme(bg)
	bg = bg or M.get()
	return bg == "light" and "tokyonight-day" or "tokyonight-night"
end

---Map the detected background to tokyonight's `style` option.
---@param bg? "light"|"dark"
---@return string
function M.tokyonight_style(bg)
	bg = bg or M.get()
	return bg == "light" and "day" or "night"
end

-- Apply background + colorscheme. Safe to call before plugins load (sets
-- &background only) and after (also swaps the colorscheme when needed).
function M.apply()
	local bg = M.get()
	if vim.o.background ~= bg then
		vim.o.background = bg
	end
	local cs = M.colorscheme(bg)
	if vim.g.colors_name ~= cs then
		-- tokyonight isn't on the rtp until lazy.nvim loads it; pcall keeps
		-- early startup (options.lua) quiet and the watcher switches later.
		pcall(vim.cmd, "colorscheme " .. cs)
	end
	return bg
end

local watcher_started = false
local commands_created = false

-- Start live switching: re-detect on focus regain and poll the OS setting
-- every few seconds so Auto appearance flips follow without restarting.
---@param interval_ms? integer default 5000
function M.start_watcher(interval_ms)
	if watcher_started then
		return
	end
	watcher_started = true
	interval_ms = interval_ms or 5000

	local group = vim.api.nvim_create_augroup("ThemeAutoDetect", { clear = true })
	vim.api.nvim_create_autocmd({ "FocusGained", "VimResume" }, {
		group = group,
		callback = function()
			-- Re-query the terminal too on focus regain (cheap after first).
			osc_queried = false
			M.apply()
		end,
	})

	local ok, timer = pcall(vim.uv.new_timer)
	if not ok or not timer then
		return
	end
	timer:start(
		interval_ms,
		interval_ms,
		vim.schedule_wrap(function()
			if not watcher_started then
				pcall(function()
					timer:stop()
					timer:close()
				end)
				return
			end
			M.apply()
		end)
	)
end

-- Create :ThemeDetect / :ThemeToggle helpers.
local function create_commands()
	if commands_created then
		return
	end
	commands_created = true
	-- Re-detect now (clears any pinned override, follows the system again).
	vim.api.nvim_create_user_command("ThemeDetect", function()
		vim.env.NVIM_BACKGROUND = nil
		local bg = M.apply()
		vim.notify("Theme: " .. bg .. " (" .. (vim.g.colors_name or "?") .. ")", vim.log.levels.INFO)
	end, { desc = "Re-detect OS/terminal theme" })
	-- Force a side; pins $NVIM_BACKGROUND for this session so the watcher
	-- stops fighting you. Run :ThemeDetect to follow the system again.
	vim.api.nvim_create_user_command("ThemeToggle", function()
		local next_bg = vim.o.background == "dark" and "light" or "dark"
		vim.env.NVIM_BACKGROUND = next_bg
		M.apply()
		vim.notify("Theme pinned: " .. next_bg .. " (:ThemeDetect follows system again)", vim.log.levels.INFO)
	end, { desc = "Toggle light/dark theme (pins override until :ThemeDetect)" })
end

-- Entry point for init.lua: watcher + manual commands. Safe to call twice.
---@param interval_ms? integer default 5000
function M.setup(interval_ms)
	create_commands()
	M.start_watcher(interval_ms)
end

return M
