#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "== Lua syntax =="
nvim --headless '+lua for _, f in ipairs(vim.fn.glob("lua/**/*.lua", false, true)) do local ok, err = loadfile(f); if not ok then error(f .. ": " .. err) end end; print("lua syntax ok")' '+qa'

echo "== Headless startup =="
nvim --headless '+qa'

echo "== Lazy-load core plugins =="
nvim --headless '+Lazy! load snacks.nvim nvim-lspconfig mason-lspconfig.nvim conform.nvim nvim-lint blink.cmp neo-tree.nvim' '+lua print("core plugins loaded ok")' '+qa'

echo "== Config health =="
nvim --headless '+checkhealth config' '+qa'

echo "validation ok"
