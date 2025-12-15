# GitHub Copilot AI Completion - Quick Start Guide

## 🚀 First-Time Setup

### Step 1: Authentication (Required on First Use)

When you first use GitHub Copilot, you need to authenticate:

```vim
:Copilot auth
```

**What happens:**
1. This command will open your browser
2. You'll be asked to sign in with GitHub
3. Enter the one-time code displayed in Neovim
4. Authorize GitHub Copilot
5. Done! Copilot is now active 🎉

**Note:** GitHub Copilot requires a subscription (free for students, educators, and open source maintainers).

### Step 2: Verify It's Working

1. Open a file (any programming language)
2. Start typing some code
3. You should see **gray inline text** appear - that's Copilot!

## ⌨️ How to Use AI Suggestions

### Accept Suggestions

When you see gray inline text (AI suggestion):

| Key | Action |
|-----|--------|
| **`<Ctrl-g>`** | **Accept the entire suggestion** |
| `<Ctrl-;>` | See next alternative suggestion |
| `<Ctrl-,>` | See previous alternative suggestion |
| `<Ctrl-x>` | Dismiss/clear the suggestion |
| `<M-CR>` | Open Copilot panel with alternatives |

### Example Usage

```javascript
// 1. Start typing:
function calculateT

// 2. Copilot shows (in gray):
function calculateTotal(items) {
  return items.reduce((sum, item) => sum + item.price, 0)
}

// 3. Press Ctrl-g to accept!
```

## 🎯 Quick Tips

### ✅ DO:
- **Press `<Ctrl-g>` to accept** - This is the main keybinding!
- Let it suggest entire functions - it's smart!
- Use `<Ctrl-;>` to see alternatives
- Use `<M-CR>` to open the panel for more options
- Keep typing if the suggestion isn't perfect

### ❌ DON'T:
- Don't press `Tab` for AI (that's for LSP completion)
- Don't press `Enter` to accept AI (use `<Ctrl-g>`)
- Don't confuse AI inline text with LSP popup menu

## 🆚 AI vs LSP Completion

### AI Completion (Copilot) - Gray Inline Text
```
You type: function add
AI shows: function addNumbers(a, b) { return a + b; }
Press: <Ctrl-g> to accept
```

### LSP Completion (nvim-cmp) - Popup Menu
```
You type: console.l
Menu shows: log, error, warn, etc.
Press: <Enter> or <Tab> to accept
```

**They work together!** Use AI for new code, LSP for existing names.

## 🔧 Common Commands

| Command | Description |
|---------|-------------|
| `:Copilot auth` | Authenticate Copilot (first time only) |
| `:Copilot setup` | Setup Copilot |
| `:Copilot status` | Check Copilot status |
| `:Copilot panel` | Open Copilot panel |
| `:Copilot disable` | Disable Copilot temporarily |
| `:Copilot enable` | Enable Copilot |

## 🐛 Troubleshooting

### No suggestions appearing?

**Check authentication:**
```vim
:Copilot auth
```

**Check status:**
```vim
:Copilot status
```

### Wrong suggestions?

**Cycle through alternatives:**
- Press `<Ctrl-;>` for next suggestion
- Press `<Ctrl-,>` for previous suggestion
- Press `<M-CR>` to open panel with multiple options
- Press `<Ctrl-x>` to dismiss

### Suggestions appearing too slow?

This is normal! AI takes a moment to:
1. Analyze your code context
2. Send request to GitHub API
3. Return the suggestion

Just keep typing, suggestions will appear when ready.

## 📝 Keybindings Summary

### AI Completion (Insert Mode Only)
```
<Ctrl-g>  = Accept AI suggestion       👈 MOST IMPORTANT!
<Ctrl-;>  = Next AI suggestion
<Ctrl-,>  = Previous AI suggestion
<Ctrl-x>  = Dismiss AI suggestion
<M-CR>    = Open Copilot panel (Alt/Option + Enter)
```

### Copilot Panel (when open)
```
]]        = Jump to next suggestion
[[        = Jump to previous suggestion
<CR>      = Accept suggestion
gr        = Refresh suggestions
```

### LSP Completion (Insert Mode)
```
<Ctrl-Space> = Trigger LSP menu
<Tab>        = Next item / expand snippet
<Shift-Tab>  = Previous item
<Enter>      = Accept LSP completion
<Ctrl-e>     = Close menu
```

## 🎓 Learning Path

### Day 1: Basic Usage
1. Run `:Copilot auth` to authenticate
2. Start coding normally
3. When you see gray text, press `<Ctrl-g>` to accept
4. That's it! You're using AI 🎉

### Day 2: Exploring Alternatives
1. Notice the AI suggestion
2. Press `<Ctrl-;>` to see other options
3. Press `<M-CR>` to open the panel for even more alternatives
4. Cycle through until you find the best one
5. Press `<Ctrl-g>` to accept

### Day 3: Combining with LSP
1. Use AI (`<Ctrl-g>`) for boilerplate code
2. Use LSP (`<Enter>`) for precise names
3. Get the best of both worlds!

## 💡 Pro Tips

### 1. Write Comments First
```javascript
// Calculate the total price of all items including tax
// AI will suggest the entire function based on your comment!
```

### 2. Start Function Signatures
```javascript
function validateEmail
// Just start typing, AI will complete the whole thing
```

### 3. Use in Different Languages
Works great with:
- JavaScript/TypeScript ✅
- Python ✅
- Go ✅
- Rust ✅
- C/C++ ✅
- Java ✅
- And many more!

### 4. Let It Write Tests
```javascript
// Write a test for the addNumbers function
// AI will suggest the entire test!
```

### 5. Use the Panel for Complex Code
When you need to see multiple options at once, press `<M-CR>` to open the Copilot panel. This is especially useful for:
- Complex functions
- Multiple implementation approaches
- When cycling with `<Ctrl-;>` isn't enough

## 🔐 Privacy & Security

- **Requires GitHub subscription** - Free for students, educators, open source maintainers
- **Your code context is sent to GitHub** - For generating suggestions
- **Not used for training by default** - Opt-in for sharing (check GitHub settings)
- **Secure connection** - All API calls are encrypted
- **Respects .gitignore** - Won't suggest from ignored files

## 📚 Additional Resources

- **Full keybindings**: See `AI_COMPLETION_GUIDE.md`
- **Configuration**: See `lua/plugins/autocompletion.lua`
- **GitHub Copilot Docs**: https://docs.github.com/en/copilot

## 🎉 You're Ready!

Remember:
1. **`:Copilot auth`** - Authenticate first time
2. **`<Ctrl-g>`** - Accept AI suggestions
3. **`<M-CR>`** - Open panel for more options
4. **Start coding!** - AI will help you

Happy coding with GitHub Copilot! 🚀
