-- Entry point. LazyVim itself loads config.options, config.keymaps and
-- config.autocmds (see lua/config/*.lua).
require("config.lazy")

-- Remote clipboard (OSC 52) so yanks work across tmux/SSH sessions.
-- Must run early so the clipboard provider is in place before use.
require("config.remote_clipboard")

-- Follow the OS / terminal light-vs-dark setting, switching live without
-- restarting. Runs here (not autocmds.lua) because LazyVim defers autocmds
-- to VeryLazy when opening without file arguments.
require("config.theme_detect").setup()
