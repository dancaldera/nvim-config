# Neovim bottom command-line research

## Findings

- Neovim's native `cmdheight=0` hides the idle command line; it appears only while being used and covers the last screen line. The option is currently marked experimental. [Neovim options](https://neovim.io/doc/user/options.html#'cmdheight')
- `showcmd=false` hides partially entered commands and Visual selection-size information. [Neovim options](https://neovim.io/doc/user/options.html#'showcmd')
- `showmode=false` hides the native mode message; this configuration already displays mode through `mini.statusline`. [Neovim options](https://neovim.io/doc/user/options.html#'showmode')
- `shortmess` flag `W` suppresses `written`/`[w]` messages after saving. [Neovim options](https://neovim.io/doc/user/options.html#'shortmess')
- Noice is not present in this config's lockfile. It can replace Neovim's command-line and message UI, but is unnecessary for removing the idle line. [Noice](https://github.com/folke/noice.nvim)

## Decision

Use Neovim's built-in options instead of adding a plugin. The settings are in `lua/config/options.lua`.
