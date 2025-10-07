# Codeium AI Completion - Quick Start Guide

## 🚀 First-Time Setup

### Step 1: Authentication (Required on First Use)

When you first use Codeium, you need to authenticate:

```vim
:Codeium Auth
```

**What happens:**
1. This command will open your browser
2. You'll be asked to sign in (it's **completely free** for individual use!)
3. Copy the authentication token from the browser
4. Paste it back in Neovim when prompted
5. Done! Codeium is now active 🎉

### Step 2: Verify It's Working

1. Open a file (any programming language)
2. Start typing some code
3. You should see **gray ghost text** appear - that's Codeium!

## ⌨️ How to Use AI Suggestions

### Accept Suggestions

When you see gray ghost text (AI suggestion):

| Key | Action |
|-----|--------|
| **`<Ctrl-g>`** | **Accept the entire suggestion** |
| `<Ctrl-;>` | See next alternative suggestion |
| `<Ctrl-,>` | See previous alternative suggestion |
| `<Ctrl-x>` | Dismiss/clear the suggestion |

### Example Usage

```javascript
// 1. Start typing:
function calculateT

// 2. Codeium shows (in gray):
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
- Keep typing if the suggestion isn't perfect

### ❌ DON'T:
- Don't press `Tab` for AI (that's for LSP completion)
- Don't press `Enter` to accept AI (use `<Ctrl-g>`)
- Don't confuse AI ghost text with LSP popup menu

## 🆚 AI vs LSP Completion

### AI Completion (Codeium) - Gray Ghost Text
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
| `:Codeium Auth` | Authenticate Codeium (first time only) |
| `:Codeium Enable` | Enable Codeium |
| `:Codeium Disable` | Disable Codeium temporarily |
| `:Codeium Toggle` | Toggle Codeium on/off |

## 🐛 Troubleshooting

### No suggestions appearing?

**Check authentication:**
```vim
:Codeium Auth
```

**Check if enabled:**
```vim
:Codeium Enable
```

### Wrong suggestions?

**Cycle through alternatives:**
- Press `<Ctrl-;>` for next suggestion
- Press `<Ctrl-,>` for previous suggestion
- Press `<Ctrl-x>` to dismiss

### Suggestions appearing too slow?

This is normal! AI takes a moment to:
1. Analyze your code context
2. Send request to Codeium API
3. Return the suggestion

Just keep typing, suggestions will appear when ready.

## 📝 Keybindings Summary

### AI Completion (Insert Mode Only)
```
<Ctrl-g>  = Accept AI suggestion       👈 MOST IMPORTANT!
<Ctrl-;>  = Next AI suggestion
<Ctrl-,>  = Previous AI suggestion
<Ctrl-x>  = Clear AI suggestion
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
1. Run `:Codeium Auth` to authenticate
2. Start coding normally
3. When you see gray text, press `<Ctrl-g>` to accept
4. That's it! You're using AI 🎉

### Day 2: Exploring Alternatives
1. Notice the AI suggestion
2. Press `<Ctrl-;>` to see other options
3. Cycle through until you find the best one
4. Press `<Ctrl-g>` to accept

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

## 🔐 Privacy & Security

- **Free for individuals** - No credit card needed
- **Your code stays private** - Only sends context for suggestions
- **No training on your code** - Your code is NOT used to train models
- **Secure connection** - All API calls are encrypted

## 📚 Additional Resources

- **Full keybindings**: See `AI_COMPLETION_GUIDE.md`
- **Configuration**: See `lua/plugins/autocompletion.lua`
- **Help in Neovim**: `:help codeium`

## 🎉 You're Ready!

Remember:
1. **`:Codeium Auth`** - Authenticate first time
2. **`<Ctrl-g>`** - Accept AI suggestions
3. **Start coding!** - AI will help you

Happy coding with AI superpowers! 🚀
