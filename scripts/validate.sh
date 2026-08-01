#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "== Lua syntax =="
nvim --headless '+lua for _, f in ipairs(vim.fn.glob("lua/**/*.lua", false, true)) do local ok, err = loadfile(f); if not ok then error(f .. ": " .. err) end end; print("lua syntax ok")' '+qa'
echo

echo "== Headless startup =="
nvim --headless '+qa'

echo "== Lazy-load core plugins =="
nvim --headless '+Lazy! load snacks.nvim mini.nvim nvim-lspconfig mason-lspconfig.nvim conform.nvim lualine.nvim bufferline.nvim which-key.nvim gitsigns.nvim' '+lua print("core plugins loaded ok")' '+qa'
echo

echo "== Explorer integration =="
nvim --headless init.lua '+lua local picker = Snacks.explorer.reveal({ file = vim.fn.fnamemodify("init.lua", ":p") }); assert(picker, "explorer did not open"); vim.wait(300, function() return #Snacks.picker.get({ source = "explorer" }) == 1 end); local active = Snacks.picker.get({ source = "explorer" })[1]; assert(active, "explorer is not active"); active:refresh(); active:close(); print("explorer ok")' '+qa'
echo

echo "== Lua LSP integration =="
nvim --headless init.lua '+lua local attached = vim.wait(8000, function() return #vim.lsp.get_clients({ bufnr = 0 }) > 0 end, 100); assert(attached, "lua_ls did not attach"); local names = {}; for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do names[#names + 1] = client.name end; table.sort(names); assert(vim.deep_equal(names, { "lua_ls" }), "unexpected Lua clients: " .. vim.inspect(names)); assert(vim.fn.exepath("stylua") ~= "", "Mason bin missing from PATH"); if vim.fn.executable("go") == 1 then assert(vim.fn.exepath("goimports") ~= "", "goimports is missing") end; print("LSP ok: " .. table.concat(names, ", "))' '+qa'
echo

echo "validation ok"
