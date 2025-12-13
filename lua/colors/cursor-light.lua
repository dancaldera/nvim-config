-- ============================================================================
-- Cursor Light Custom Colorscheme
-- Based on Cursor Light theme v0.0.2
-- Modern light theme with clean aesthetics
-- ============================================================================

-- Color Palette from Cursor Light theme v0.0.2
local colors = {
	-- Base colors
	bg0 = "#FCFCFC", -- Main background (near-white)
	bg1 = "#F3F3F3", -- Sidebar/statusline background
	bg2 = "#EDEDED", -- Line highlight background
	fg = "#141414", -- Main foreground (near-black)
	grey = "#6F6F6F", -- Comments

	-- Syntax colors
	red = "#B31B3F", -- Keywords
	green = "#1F8A65", -- Git added, decorators, strings (alternate)
	yellow = "#C08532", -- Modified files, warnings
	blue = "#206595", -- Types, constants
	purple = "#9E94D5", -- Strings (primary)
	orange = "#DB704B", -- Functions, warnings, parameters
	aqua = "#6049B3", -- Properties
	cyan = "#4C7F8C", -- Cyan elements
	teal = "#6F9BA6", -- Built-in functions, booleans
	magenta = "#B8448B", -- Numbers, special keywords

	-- UI accents
	visual = "#F0F0F0", -- Visual selection
	search = "#B8CDD4", -- Search highlight
	error = "#CF2D56", -- Errors
	warning = "#DB704B", -- Warnings
	info = "#206595", -- Info
	hint = "#6F9BA6", -- Hints
}

-- Helper function for setting highlights
local function hl(group, settings)
	vim.api.nvim_set_hl(0, group, settings)
end

-- Clear existing highlights
vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") then
	vim.cmd("syntax reset")
end

vim.g.colors_name = "cursor-light"

-- ============================================================================
-- Editor UI
-- ============================================================================
hl("Normal", { fg = colors.fg, bg = colors.bg0 })
hl("NormalFloat", { fg = colors.fg, bg = colors.bg1 })
hl("Cursor", { fg = colors.bg0, bg = colors.fg })
hl("CursorLine", { bg = colors.bg2 })
hl("CursorLineNr", { fg = colors.fg, bold = true })
hl("LineNr", { fg = "#999999" })
hl("SignColumn", { bg = colors.bg0 })
hl("ColorColumn", { bg = colors.bg2 })
hl("VertSplit", { fg = "#DDDDDD" })
hl("Visual", { bg = colors.visual })
hl("VisualNOS", { bg = colors.visual })
hl("Search", { fg = colors.fg, bg = colors.search })
hl("IncSearch", { fg = colors.bg0, bg = colors.orange })
hl("Pmenu", { fg = colors.fg, bg = colors.bg1 })
hl("PmenuSel", { fg = colors.bg0, bg = colors.blue })
hl("PmenuSbar", { bg = colors.bg2 })
hl("PmenuThumb", { fg = "#999999" })
hl("StatusLine", { fg = colors.fg, bg = colors.bg1 })
hl("StatusLineNC", { fg = colors.grey, bg = colors.bg1 })
hl("TabLine", { fg = colors.grey, bg = colors.bg1 })
hl("TabLineFill", { bg = colors.bg1 })
hl("TabLineSel", { fg = colors.fg, bg = colors.bg0 })
hl("Folded", { fg = colors.grey, bg = colors.bg1 })
hl("FoldColumn", { fg = colors.grey, bg = colors.bg0 })

-- ============================================================================
-- Syntax Highlighting (Minimal - Treesitter handles details)
-- ============================================================================
hl("Comment", { fg = colors.grey, italic = true })
hl("Constant", { fg = colors.blue })
hl("String", { fg = colors.purple })
hl("Character", { fg = colors.purple })
hl("Number", { fg = colors.magenta })
hl("Boolean", { fg = colors.teal })
hl("Float", { fg = colors.magenta })
hl("Identifier", { fg = colors.fg })
hl("Function", { fg = colors.orange })
hl("Statement", { fg = colors.red })
hl("Keyword", { fg = colors.red })
hl("Conditional", { fg = colors.red })
hl("Repeat", { fg = colors.red })
hl("Label", { fg = colors.red })
hl("Operator", { fg = colors.fg })
hl("Exception", { fg = colors.red })
hl("PreProc", { fg = colors.green })
hl("Include", { fg = colors.green })
hl("Define", { fg = colors.green })
hl("Macro", { fg = colors.green })
hl("Type", { fg = colors.blue })
hl("StorageClass", { fg = colors.red })
hl("Structure", { fg = colors.blue })
hl("Typedef", { fg = colors.blue })
hl("Special", { fg = colors.magenta })
hl("SpecialChar", { fg = colors.magenta })
hl("Delimiter", { fg = colors.fg })
hl("Error", { fg = colors.error, bold = true })
hl("Todo", { fg = colors.yellow, bold = true })

-- ============================================================================
-- Treesitter Highlights (Minimal - key scopes only)
-- ============================================================================
hl("@comment", { link = "Comment" })
hl("@keyword", { link = "Keyword" })
hl("@string", { link = "String" })
hl("@function", { link = "Function" })
hl("@function.builtin", { fg = colors.teal, italic = true })
hl("@variable", { link = "Identifier" })
hl("@variable.builtin", { fg = colors.magenta })
hl("@type", { link = "Type" })
hl("@type.builtin", { link = "Type" })
hl("@constant", { link = "Constant" })
hl("@constant.builtin", { link = "Constant" })
hl("@number", { link = "Number" })
hl("@boolean", { link = "Boolean" })
hl("@operator", { link = "Operator" })
hl("@property", { fg = colors.aqua })
hl("@parameter", { fg = colors.orange, italic = true })

-- ============================================================================
-- LSP Semantic Tokens
-- ============================================================================
hl("@lsp.type.function", { link = "Function" })
hl("@lsp.type.method", { link = "Function" })
hl("@lsp.type.variable", { link = "Identifier" })
hl("@lsp.type.parameter", { link = "@parameter" })
hl("@lsp.type.property", { link = "@property" })
hl("@lsp.type.type", { link = "Type" })
hl("@lsp.type.class", { link = "Type" })
hl("@lsp.type.keyword", { link = "Keyword" })

-- ============================================================================
-- Diagnostics
-- ============================================================================
hl("DiagnosticError", { fg = colors.error })
hl("DiagnosticWarn", { fg = colors.warning })
hl("DiagnosticInfo", { fg = colors.info })
hl("DiagnosticHint", { fg = colors.hint })
hl("DiagnosticUnderlineError", { sp = colors.error, undercurl = true })
hl("DiagnosticUnderlineWarn", { sp = colors.warning, undercurl = true })
hl("DiagnosticUnderlineInfo", { sp = colors.info, undercurl = true })
hl("DiagnosticUnderlineHint", { sp = colors.hint, undercurl = true })

-- ============================================================================
-- Git Signs
-- ============================================================================
hl("GitSignsAdd", { fg = colors.green })
hl("GitSignsChange", { fg = colors.yellow })
hl("GitSignsDelete", { fg = colors.error })

-- ============================================================================
-- Plugin-Specific Highlights (Minimal - let plugins inherit)
-- ============================================================================
-- Telescope
hl("TelescopeBorder", { fg = colors.grey })
hl("TelescopePromptBorder", { fg = colors.blue })
hl("TelescopeSelection", { fg = colors.fg, bg = colors.bg2 })

-- NvimTree
hl("NvimTreeFolderIcon", { fg = "#055180" }) -- Darker, richer blue for better contrast on light bg
hl("NvimTreeFolderName", { fg = "#055180" }) -- Closed folder names
hl("NvimTreeOpenedFolderName", { fg = colors.yellow }) -- Brighter yellow for opened folders
hl("NvimTreeEmptyFolderName", { fg = "#7A8B99" }) -- Muted grey for empty folders
hl("NvimTreeRootFolder", { fg = "#055180", bold = true }) -- Bold blue for root folder
hl("NvimTreeSymlink", { fg = colors.cyan }) -- Symbolic links
hl("NvimTreeExecFile", { fg = colors.green }) -- Executable files

-- Which-Key
hl("WhichKey", { fg = colors.orange })
hl("WhichKeyGroup", { fg = colors.blue })
hl("WhichKeySeparator", { fg = colors.grey })

-- Flash (motion plugin)
hl("FlashLabel", { fg = colors.bg0, bg = colors.orange, bold = true })
hl("FlashMatch", { fg = colors.blue })
