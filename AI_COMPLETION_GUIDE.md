# AI Completion Guide (Codeium/Windsurf)

Your Neovim configuration now includes **dual completion system**:
- 🤖 **AI Completion** (Codeium) - Ghost text suggestions powered by AI
- 💻 **LSP Completion** (nvim-cmp) - Traditional LSP, snippets, and buffer completions

## How It Works

### AI Completion (Ghost Text)
When you type, Codeium will show AI-powered suggestions as **gray ghost text** after your cursor. These are context-aware, intelligent suggestions based on your code.

### LSP Completion (Popup Menu)
Press `<C-Space>` or start typing to see traditional completions in a popup menu with LSP suggestions, snippets, and buffer text.

**They work together without conflicts!** 🎉

## Keybindings

### AI Completion (Codeium)
| Key | Action | Description |
|-----|--------|-------------|
| `<C-g>` | Accept AI suggestion | Accept the entire AI ghost text suggestion |
| `<C-;>` | Next suggestion | Cycle to next AI suggestion |
| `<C-,>` | Previous suggestion | Cycle to previous AI suggestion |
| `<C-x>` | Clear suggestion | Dismiss current AI suggestion |

### LSP Completion (nvim-cmp)
| Key | Action | Description |
|-----|--------|-------------|
| `<C-Space>` | Trigger completion | Manually trigger completion menu |
| `<C-k>` | Previous item | Select previous completion item |
| `<C-j>` | Next item | Select next completion item |
| `<Tab>` | Next/Expand | Next item or expand snippet |
| `<S-Tab>` | Previous | Previous item or jump back in snippet |
| `<CR>` | Confirm | Accept selected completion |
| `<C-e>` | Abort | Close completion menu |
| `<C-b>` | Scroll docs up | Scroll documentation window up |
| `<C-f>` | Scroll docs down | Scroll documentation window down |

## Usage Examples

### Example 1: Using AI Suggestions
```
You type: function calculateT
AI shows: function calculateTotal(items) {
            return items.reduce((sum, item) => sum + item.price, 0)
          }
```
- Press `<C-g>` to accept the entire suggestion
- Press `<C-;>` to see alternative suggestions
- Press `<C-x>` to dismiss if not needed

### Example 2: Using LSP Completion
```
You type: import { use
Menu shows:
  - useState (React)
  - useEffect (React)
  - useRef (React)
```
- Use `<C-j>`/`<C-k>` or `<Tab>`/`<S-Tab>` to navigate
- Press `<CR>` or `<Tab>` to select

### Example 3: Both Together
```
You type: const [count, setC
LSP menu shows: setCount, setCounter, etc.
AI ghost text: setCount] = useState(0)
```
- You can select from LSP menu with `<CR>`
- Or accept AI suggestion with `<C-g>`
- Best of both worlds!

## Configuration Details

### AI Completion Features
- **Context-aware**: Understands your entire codebase
- **Multi-line suggestions**: Can suggest entire functions
- **Language support**: Works with all programming languages
- **Ghost text**: Non-intrusive gray text display
- **No account required**: Codeium is free for individual use

### LSP Completion Features
- **Accurate**: Based on actual code analysis
- **Type information**: Shows parameter types and docs
- **Snippets**: Pre-built code templates
- **Fast**: Local processing, no API calls
- **Buffer words**: Suggests from current file

## Tips & Best Practices

### When to Use AI (Codeium)
✅ Writing new functions or logic
✅ Boilerplate code
✅ Complex algorithms
✅ Repetitive patterns
✅ Comments and documentation

### When to Use LSP
✅ Exact method/variable names
✅ API exploration
✅ Type-specific completions
✅ Language-specific syntax
✅ Snippets expansion

### Pro Tips
1. **Start typing naturally** - AI will suggest contextually
2. **Use `<C-;>` often** - See multiple AI suggestions
3. **Combine both** - Accept AI structure, refine with LSP
4. **Clear distractions** - Use `<C-x>` to dismiss unwanted AI suggestions
5. **Trigger manually** - Use `<C-Space>` when LSP menu doesn't appear

## Troubleshooting

### AI suggestions not appearing?
1. Make sure you're in Insert mode
2. Check internet connection (Codeium needs API access)
3. Wait a moment - AI takes slightly longer than LSP
4. Try typing more context for better suggestions

### LSP completion not working?
1. Ensure LSP is attached: `:LspInfo`
2. Trigger manually with `<C-Space>`
3. Check if server is running: `:LspRestart`

### Both showing at once?
This is normal! They complement each other:
- LSP shows in **popup menu**
- AI shows as **ghost text**
- Choose whichever is more appropriate

## First-Time Setup

### Codeium Authentication (First Launch)
1. When you first use Codeium, it will prompt for authentication
2. It will open a browser to authenticate
3. Follow the on-screen instructions
4. It's completely free for individual use!

### Alternative: If you prefer Windsurf
Replace `codeium.vim` with `windsurf.vim` in the config:
```lua
-- In lua/plugins/autocompletion.lua
{
  "Exafunction/windsurf.vim",  -- instead of codeium.vim
  -- ... rest of config
}
```

## Summary

You now have **the best of both worlds**:

🤖 **AI (Codeium)** - Smart, context-aware, multi-line suggestions
💻 **LSP (nvim-cmp)** - Precise, fast, local completions

Press `<C-g>` for AI magic ✨
Press `<CR>` for LSP precision 🎯

Happy coding! 🚀
