# 🎉 First Launch Guide - Neovim with AI

Welcome to your optimized Neovim configuration! Follow these simple steps to get started.

## ✅ Step 1: First Launch

When you first open Neovim:

```bash
nvim
```

**What will happen:**
1. ✨ Lazy.nvim will install all plugins automatically
2. 📦 Mason will install LSP servers in the background
3. 🎨 Dashboard will show (press `q` to close or select an option)
4. ⏳ Wait ~30 seconds for everything to install

## ✅ Step 2: Setup AI Completion (REQUIRED!)

**This is the most important step!**

In Neovim, run:
```vim
:Codeium Auth
```

**What will happen:**
1. 🌐 Your browser will open
2. 🔐 Sign in to Codeium (it's FREE!)
3. 📋 Copy the authentication token
4. 📥 Paste it in Neovim when prompted
5. ✅ Press Enter

**Done! AI completion is now active!** 🎉

## ✅ Step 3: Test AI Completion

1. Create a new file:
   ```vim
   :e test.js
   ```

2. Enter INSERT mode:
   ```
   Press: i
   ```

3. Start typing:
   ```javascript
   function add
   ```

4. **Look for gray ghost text** - that's the AI suggestion!

5. **Press `<Ctrl-g>` to accept it!** 🚀

## ✅ Step 4: Verify Everything Works

Run health checks:
```vim
:checkhealth
```

Check LSP servers:
```vim
:Mason
```

Check plugins:
```vim
:Lazy
```

## 🎯 Essential Keybindings to Remember

### AI Completion (Most Important!)
```
<Ctrl-g>  = Accept AI suggestion     👈 YOU MUST REMEMBER THIS!
<Ctrl-;>  = Next AI suggestion
<Ctrl-x>  = Clear AI suggestion
```

### File Navigation
```
<leader>ff = Find files              (Space + f + f)
<leader>fs = Search in files         (Space + f + s)
<leader>ee = Toggle file explorer    (Space + e + e)
```

### LSP Features
```
gd         = Go to definition
K          = Show documentation
<leader>ca = Code actions            (Space + c + a)
```

### Git
```
<leader>gg = Open Git UI             (Space + g + g)
<leader>hp = Preview git hunk        (Space + h + p)
```

## 📚 Learn More

### Must-Read Documentation
1. **CODEIUM_SETUP.md** ⭐ - Complete AI setup guide
2. **AI_COMPLETION_GUIDE.md** - Advanced AI usage
3. **README.md** - Full features and installation

### Quick References
- `:help` - Neovim help
- `:help codeium` - Codeium help
- `:WhichKey <leader>` - See all leader keybindings

## 🐛 Troubleshooting

### AI suggestions not appearing?
```vim
:Codeium Auth          " Re-authenticate
:Codeium Enable        " Make sure it's enabled
```

### LSP not working?
```vim
:LspInfo              " Check LSP status
:LspRestart           " Restart LSP servers
:Mason                " Check server installation
```

### Plugins not loading?
```vim
:Lazy sync            " Sync all plugins
:Lazy clean           " Remove unused plugins
:Lazy update          " Update all plugins
```

## 💡 Pro Tips

### 1. Use Which-Key
Don't remember a keybinding? Press `<Space>` and wait - Which-Key will show you all options!

### 2. AI + Comments
Write a comment describing what you want, and let AI write the code:
```javascript
// Function to validate email format and check domain
// AI will suggest the entire function!
```

### 3. Explore with Telescope
- `<leader>ff` - Find any file instantly
- `<leader>fs` - Search any text in your project
- `<leader>ft` - Find all TODOs

### 4. Git Integration
- `<leader>gg` - Opens beautiful Git UI
- `]c` / `[c` - Jump between git changes
- `<leader>hp` - Preview changes before staging

## 🎓 Learning Path

### Day 1 (Today!)
- [x] `:Codeium Auth` - Setup AI
- [x] Learn `<Ctrl-g>` - Accept AI suggestions
- [x] Try `<leader>ff` - Find files
- [x] Use `<leader>ee` - Open file explorer

### Day 2
- [ ] Read `CODEIUM_SETUP.md`
- [ ] Try `<Ctrl-;>` for alternative AI suggestions
- [ ] Explore `<leader>fs` for text search
- [ ] Use `gd` to jump to definitions

### Day 3
- [ ] Read `AI_COMPLETION_GUIDE.md`
- [ ] Try Git features (`<leader>gg`)
- [ ] Use `<leader>ca` for code actions
- [ ] Explore TODO comments (`]t` / `[t`)

### Week 1
- [ ] Read full `README.md`
- [ ] Customize colorscheme if desired
- [ ] Add your own keybindings
- [ ] Install additional LSP servers

## 🚀 You're Ready!

**Remember the golden rule:**
> When you see gray ghost text, press `<Ctrl-g>` to accept it!

Everything else will come naturally as you use Neovim.

---

**Happy coding!** 🎉

*Got questions? Check the documentation files or run `:help` in Neovim.*
