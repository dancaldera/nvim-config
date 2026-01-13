# Advanced Troubleshooting

Comprehensive troubleshooting guide for Neovim configuration issues beyond basic README fixes.

---

## Table of Contents

1. [Startup Issues](#startup-issues)
2. [LSP Problems](#lsp-problems)
3. [Formatter Not Working](#formatter-not-working)
4. [Completion Issues](#completion-issues)
5. [Git Integration Problems](#git-integration-problems)
6. [Plugin Loading Failures](#plugin-loading-failures)
7. [Performance Problems](#performance-problems)
8. [Treesitter Issues](#treesitter-issues)
9. [Terminal Integration](#terminal-integration)
10. [Copilot Problems](#copilot-problems)
11. [Keybinding Conflicts](#keybinding-conflicts)
12. [Session/Persistence Issues](#sessionpersistence-issues)
13. [Nuclear Options](#nuclear-options)

---

## Startup Issues

### Symptom: Neovim Crashes on Startup

**Diagnosis:**
```bash
nvim --startuptime startup.log
cat startup.log | tail -50
```

Look for the last line before crash.

**Common Causes:**

1. **Plugin syntax error**
```vim
:messages  " Check for Lua errors
```

**Fix:** Identify plugin from error message, temporarily disable in `lua/plugins/`:
```lua
return {}  -- Comment out plugin config
```

2. **Incompatible Neovim version**
```bash
nvim --version  # Must be 0.10+, recommend 0.11+
```

**Fix:** Upgrade Neovim:
```bash
# macOS
brew upgrade neovim

# Or download from https://github.com/neovim/neovim/releases
```

3. **Corrupted plugin cache**
```bash
rm -rf ~/.local/share/nvim/lazy
nvim  # Reinstalls all plugins
```

### Symptom: Slow Startup (>200ms)

**Diagnosis:**
```vim
:Lazy profile
```

Identify slow-loading plugins.

**Fixes:**
1. **Lazy load plugin:**
```lua
-- Add event trigger
event = "VeryLazy"  -- or BufReadPre, InsertEnter
```

2. **Remove unused plugin:**
```lua
-- Comment out or delete plugin spec
```

3. **Check external deps:**
```bash
# Some plugins need external tools
:checkhealth
```

### Symptom: "Lazy.nvim not found" Error

**Fix: Re-bootstrap lazy.nvim**
```bash
rm -rf ~/.local/share/nvim/lazy/lazy.nvim
nvim  # Will auto-install lazy.nvim
```

---

## LSP Problems

### LSP Not Attaching

**Diagnosis:**
```vim
:LspInfo
```

Should show attached clients. If empty:

**Check 1: Server installed?**
```vim
:Mason
```
Look for checkmark next to server. If missing, press `i` to install.

**Check 2: File type detected?**
```vim
:set filetype?
```
Should show correct type (e.g., `filetype=python`).

**Check 3: Server configured?**
```bash
# Check if server is in lsp-servers.lua
cat lua/plugins/lsp-servers.lua | grep "server_name"
```

**Fix: Manual server start**
```vim
:lua vim.lsp.start({ name = 'server_name' })
```

### LSP Started But No Features

**Symptom:** LSP shows in `:LspInfo` but no completion/diagnostics

**Check: Capabilities**
```vim
:lua print(vim.inspect(vim.lsp.get_active_clients()[1].server_capabilities))
```

Should show various capabilities = true.

**Fixes:**

1. **Restart LSP:**
```vim
:LspRestart
```

2. **Check LSP logs:**
```vim
:LspLog
```
Look for errors related to workspace/file.

3. **Verify project setup:**
```bash
# TypeScript: needs tsconfig.json or jsconfig.json
# Python: needs __init__.py or pyproject.toml
# Go: needs go.mod
```

### LSP Extremely Slow

**Symptoms:**
- Completion takes >2 seconds
- High CPU usage
- Neovim freezes

**Diagnosis:**
```bash
# Check CPU usage
top -o cpu | grep nvim

# Check LSP workspace size
:lua print(#vim.lsp.get_active_clients()[1].workspace_folders)
```

**Fixes:**

1. **Exclude large directories:**
```json
// TypeScript: tsconfig.json
{
  "exclude": ["node_modules", "dist", "build", ".next"]
}
```

2. **Reduce Rust Analyzer scope:**
```toml
# Cargo.toml
[package.metadata.rust-analyzer]
check.workspace = false
checkOnSave.enable = false
```

3. **Disable LSP for large files:**
```lua
-- In lua/config/autocmds.lua
vim.api.nvim_create_autocmd("BufRead", {
  callback = function()
    if vim.api.nvim_buf_line_count(0) > 5000 then
      vim.cmd("LspStop")
    end
  end,
})
```

### "Multiple LSP Clients Attached" Warning

**Symptom:** Multiple servers of same type attached

**Diagnosis:**
```vim
:LspInfo
```

Shows duplicate servers.

**Fix:**
```vim
:LspStop <client_id>  " Stop duplicate
:LspRestart  " Restart cleanly
```

**Prevention:** Check for duplicate configs in `lsp-servers.lua`.

---

## Formatter Not Working

### Auto-Format on Save Not Running

**Check 1: Format enabled?**
```vim
:lua print(vim.g.disable_autoformat, vim.b.disable_autoformat)
```
Should be `nil nil`. If `true`, formatting is disabled.

**Fix:**
```vim
:let g:disable_autoformat = 0
:let b:disable_autoformat = 0
```

**Check 2: Formatter installed?**
```bash
which prettier  # or black, stylua, etc.
```

**Fix:**
```vim
:Mason
# Navigate to formatter, press 'i'
```

**Check 3: conform.nvim loaded?**
```vim
:lua print(package.loaded['conform'])
```
Should show table, not `nil`.

### Formatter Runs But No Changes

**Diagnosis:**
```vim
:lua print(vim.inspect(require('conform').list_formatters(0)))
```

Check for:
- `available = false` → formatter not found
- `available = true, exit_code = 1` → formatter error

**Check formatter directly:**
```bash
# Test formatter manually
prettier --write test.js
black test.py
```

**Common Issues:**

1. **Wrong config syntax:**
```json
// .prettierrc (JSON requires trailing commas, etc.)
{
  "semi": false,  // ❌ Trailing comma in JSON
}
```

2. **Formatter not in PATH:**
```bash
# Add to ~/.zshrc or ~/.bashrc
export PATH=$PATH:/usr/local/bin:~/.local/bin
```

3. **Virtual env not activated (Python):**
```vim
<leader>pe  " Switch to correct venv
:LspRestart
```

---

## Completion Issues

### No Completion Menu Appearing

**Diagnosis:**
```vim
# Try in insert mode - type a few characters
# Menu should appear automatically

# Check if nvim-cmp loaded
:lua print(require('cmp'))
```

**Fixes:**

1. **Restart in insert mode:**
```vim
:CmpEnable
```

2. **Check sources:**
```vim
:lua print(vim.inspect(require('cmp').get_config().sources))
```
Should show LSP, buffer, path, etc.

3. **Manually trigger completion:**
```vim
" In insert mode
<C-Space>
```

### Copilot Suggestions Not Showing

**Diagnosis:**
```vim
:Copilot status
```

Should show "Ready".

**Common States:**

- **"Disabled":** Run `:Copilot enable`
- **"Error: Not authenticated":** Run `:Copilot auth`
- **"Offline":** Check internet connection
- **"Rate limited":** Wait 1-2 minutes

**Fixes:**

1. **Authenticate:**
```vim
:Copilot auth
```
Follow browser prompt.

2. **Check Copilot subscription:**
Go to https://github.com/settings/copilot
Ensure subscription is active.

3. **Restart Copilot:**
```vim
:Copilot disable
:Copilot enable
```

### Completion Too Slow

**Symptom:** 2+ second delay before completion appears

**Diagnosis:** Check if LSP is slow (see LSP section above).

**Fixes:**

1. **Increase debounce:**
```lua
-- In lua/plugins/autocompletion.lua
completion = {
  keyword_length = 2,  -- Require more characters
},
performance = {
  debounce = 150,  -- Increase from 100ms
}
```

2. **Disable buffer source for large files:**
```lua
-- In autocmd for large files
vim.b.cmp_source_buffer_enabled = false
```

---

## Git Integration Problems

### Gitsigns Not Showing

**Symptom:** No git signs in sign column

**Check 1: In git repo?**
```bash
git status
```

**Check 2: Gitsigns loaded?**
```vim
:lua print(require('gitsigns'))
```

**Fix:**
```vim
:Gitsigns refresh
:e  " Reload file
```

### Git Blame Not Appearing

**Keybinding:** `<leader>gb` (toggle blame)

**Check:**
```vim
:Gitsigns toggle_current_line_blame
```

### Neogit Not Opening

**Symptom:** `:Neogit` command not found

**Check:**
```vim
:lua print(package.loaded['neogit'])
```

If `nil`, plugin not loaded.

**Fix:**
```vim
:Lazy sync
:Neogit
```

---

## Plugin Loading Failures

### "module 'plugin' not found"

**Diagnosis:**
```vim
:Lazy
```

Check plugin status:
- Green checkmark = loaded
- Red X = failed
- Gray = not loaded yet (lazy)

**Fixes:**

1. **Sync plugins:**
```vim
:Lazy sync
```

2. **Check lazy-lock.json:**
```bash
cat lazy-lock.json | grep plugin-name
```

If missing, plugin not installed.

3. **Reinstall specific plugin:**
```vim
:Lazy clean
:Lazy install
```

### Plugin Installed But Not Working

**Check plugin config:**
```bash
# Find plugin config file
find lua/plugins -name "*.lua" -exec grep -l "plugin-name" {} \;
```

**Common issues:**

1. **Missing setup() call:**
```lua
-- ❌ Wrong
return { "author/plugin" }

-- ✅ Correct
return {
  "author/plugin",
  config = function()
    require("plugin").setup({})
  end,
}
```

2. **Wrong event trigger:**
```lua
-- Plugin needs to load earlier
event = "BufReadPre"  -- Instead of VeryLazy
```

---

## Performance Problems

### High Memory Usage (>500MB)

**Diagnosis:**
```vim
:lua print(collectgarbage("count"))  " Memory in KB
```

**Fixes:**

1. **Close unused buffers:**
```vim
:bufdo bwipeout  " Close all except current
```

2. **Disable Treesitter for large files:**
```vim
:TSBufDisable highlight
```

3. **Limit LSP workspace:**
See LSP slow section above.

### Slow Scrolling / Typing

**Diagnosis:**
```vim
:set lazyredraw?  " Should be set
:set ttyfast?     " Should be set
```

**Fixes:**

1. **Disable smooth scroll:**
```lua
-- Comment out in lua/plugins/utilities.lua
-- neoscroll.nvim config
```

2. **Reduce Treesitter highlighting:**
```lua
-- In treesitter.lua
highlight = {
  enable = true,
  disable = { "html", "css" },  -- Disable for slow languages
}
```

3. **Disable inline git blame:**
```vim
<leader>gb  " Toggle off
```

---

## Treesitter Issues

### Treesitter Parsing Errors

**Symptom:** "TSUpdate failed" or incorrect syntax highlighting

**Diagnosis:**
```vim
:TSModuleInfo
```

Shows which modules are enabled/disabled.

**Fixes:**

1. **Update parsers:**
```vim
:TSUpdate
```

2. **Reinstall specific parser:**
```vim
:TSUninstall javascript
:TSInstall javascript
```

3. **Check parser compatibility:**
```vim
:checkhealth nvim-treesitter
```

### Folding Not Working

**Symptom:** `za` doesn't fold code

**Check:**
```vim
:set foldmethod?
```
Should be `expr` (Treesitter folding).

**Fix:**
```vim
:lua require('ufo').setup()
:e  " Reload file
```

---

## Terminal Integration

### Terminal Not Opening

**Keybinding:** `<C-\>` or `<leader>tt`

**Check:**
```vim
:lua print(package.loaded['snacks'])
```

**Fix:**
```vim
:Lazy reload snacks.nvim
```

### Terminal Exit Not Working

**Issue:** Can't exit terminal mode

**Fix:**
```vim
" In terminal mode
<C-\><C-n>  " Exit to normal mode
```

Then close with `:q` or `<leader>bd`.

---

## Copilot Problems

### Copilot Authentication Failed

**Symptom:** "GitHub account not found"

**Fix:**
1. Ensure GitHub account has Copilot access
2. Re-authenticate:
```vim
:Copilot auth
```
3. If browser doesn't open, manually go to:
```
https://github.com/login/device
```
Enter code from Neovim.

### Copilot Suggestions Incorrect Language

**Issue:** Getting Python suggestions in JavaScript file

**Check filetype:**
```vim
:set filetype?
```

**Fix:**
```vim
:set filetype=javascript
:Copilot enable
```

---

## Keybinding Conflicts

### Keybinding Not Working

**Diagnosis:**
```vim
:verbose map <leader>ca
```

Shows where keybinding is defined. If multiple definitions, last one wins.

**Check for conflicts:**
```vim
:map <leader>ca  " Shows all mappings
```

**Fix:** Remove conflicting mapping or change keybinding in config.

---

## Session/Persistence Issues

### Session Not Restoring

**Symptom:** `:lua require('persistence').load()` does nothing

**Check:**
```bash
ls ~/.local/state/nvim/sessions/
```

Should show session files.

**Fixes:**

1. **Create new session:**
```vim
<leader>qs  " Save session
```

2. **Check if session saving disabled:**
```vim
<leader>qd  " This disables session saving - run again to re-enable
```

---

## Nuclear Options

### When All Else Fails

**Level 1: Sync Plugins**
```vim
:Lazy sync
:Mason
:TSUpdate
```

**Level 2: Clear Caches**
```bash
rm -rf ~/.local/share/nvim/lazy
rm -rf ~/.cache/nvim
nvim  # Reinstalls plugins
```

**Level 3: Reset Everything**
```bash
# Backup your config first!
cp -r ~/.config/nvim ~/.config/nvim.backup

# Remove data/cache/state
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim

# Start fresh
nvim
# Plugins will auto-install
```

**Level 4: Debug with minimal config**
```bash
# Create minimal init.lua
mkdir -p /tmp/nvim-test
cat > /tmp/nvim-test/init.lua <<EOF
-- Minimal config for testing
require('config.lazy')  -- Just load lazy.nvim
EOF

# Test with clean environment
NVIM_APPNAME=nvim-test nvim
```

---

## Getting Help

### Health Check First
```vim
:checkhealth
```

Reviews all subsystems and flags issues.

### Collect Debug Info

When asking for help, include:

1. **Neovim version:**
```bash
nvim --version
```

2. **LSP status:**
```vim
:LspInfo
```

3. **Plugin status:**
```vim
:Lazy
```

4. **Error messages:**
```vim
:messages
```

5. **Health check:**
```vim
:checkhealth
```

6. **Minimal reproduction:**
```lua
-- Create minimal config that reproduces issue
-- Test with: NVIM_APPNAME=nvim-test nvim
```

### Reporting Bugs

**For this config:**
- GitHub Issues (if you forked from a repo)
- Include all debug info above

**For plugins:**
- Check plugin's GitHub Issues
- Provide minimal reproduction

**For Neovim itself:**
- https://github.com/neovim/neovim/issues

---

## Quick Troubleshooting Checklist

```
□ Run :checkhealth
□ Check Neovim version (0.10+ required, 0.11+ recommended)
□ Run :Lazy sync
□ Run :Mason to check tool installation
□ Run :LspInfo to check LSP status
□ Check :messages for errors
□ Try :LspRestart
□ Clear caches (rm -rf ~/.cache/nvim)
□ Reinstall plugins (rm -rf ~/.local/share/nvim/lazy && nvim)
```

---

**See also:**
- `LSP_GUIDE.md` - Language-specific LSP troubleshooting
- `PLUGINS_REFERENCE.md` - Plugin documentation
- `PERFORMANCE.md` - Performance optimization
- `README.md` - Basic troubleshooting
