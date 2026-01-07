-- ============================================================================
-- Nord Dark Colorscheme
-- Official Nord palette by Arctic Ice Studio
-- Arctic, north-bluish color palette with clean, flat design
-- ============================================================================

-- Color Palette - Nord (Official Specification)
-- 16 carefully selected, dimmed pastel colors
-- Source: https://www.nordtheme.com/docs/colors-and-palettes/
local colors = {
	-- Base colors (Polar Night + Snow Storm)
	bg0 = "#2e3440", -- nord0 (main background)
	bg1 = "#3b4252", -- nord1 (UI elements, CursorLine)
	bg2 = "#434c5e", -- nord2 (borders, selection)
	fg = "#d8dee9", -- nord4 (primary text)
	grey = "#88c0d0", -- nord8 Frost cyan (improved comment readability)

	-- Syntax colors (Frost + Aurora)
	red = "#bf616a", -- nord11 (Keywords)
	green = "#a3be8c", -- nord14 (Strings)
	yellow = "#ebcb8b", -- nord13 (Functions)
	blue = "#81a1c1", -- nord9 (Types)
	purple = "#b48ead", -- nord15 (Special)
	orange = "#d08770", -- nord12 (Numbers)
	aqua = "#8fbcbb", -- nord7 (Properties)

	-- UI accents
	visual = "#434c5e", -- nord2 (selection)
	search = "#ebcb8b", -- nord13 (search highlight)
	error = "#bf616a", -- nord11
	warning = "#ebcb8b", -- nord13
	info = "#81a1c1", -- nord9
	hint = "#8fbcbb", -- nord7
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

vim.g.colors_name = "nord-dark"

-- ============================================================================
-- Editor UI
-- ============================================================================
hl("Normal", { fg = colors.fg, bg = colors.bg0 })
hl("NormalFloat", { fg = colors.fg, bg = colors.bg1 })
hl("Cursor", { fg = colors.bg0, bg = colors.fg })
hl("CursorLine", { bg = colors.bg1 })
hl("CursorLineNr", { fg = colors.fg, bold = true })
hl("LineNr", { fg = colors.grey })
hl("SignColumn", { bg = colors.bg0 })
hl("ColorColumn", { bg = colors.bg1 })
hl("VertSplit", { fg = colors.bg2 })
hl("Visual", { bg = colors.visual })
hl("VisualNOS", { bg = colors.visual })
hl("Search", { fg = colors.bg0, bg = colors.search })
hl("IncSearch", { fg = colors.bg0, bg = colors.orange })
hl("Pmenu", { fg = colors.fg, bg = colors.bg1 })
hl("PmenuSel", { fg = colors.bg0, bg = colors.blue })
hl("PmenuSbar", { bg = colors.bg2 })
hl("PmenuThumb", { bg = colors.grey })
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
hl("Constant", { fg = colors.orange })
hl("String", { fg = colors.green })
hl("Character", { fg = colors.green })
hl("Number", { fg = colors.orange })
hl("Boolean", { fg = colors.orange })
hl("Float", { fg = colors.orange })
hl("Identifier", { fg = colors.fg })
hl("Function", { fg = colors.yellow })
hl("Statement", { fg = colors.red })
hl("Keyword", { fg = colors.red })
hl("Conditional", { fg = colors.red })
hl("Repeat", { fg = colors.red })
hl("Label", { fg = colors.red })
hl("Operator", { fg = colors.fg })
hl("Exception", { fg = colors.red })
hl("PreProc", { fg = colors.aqua })
hl("Include", { fg = colors.aqua })
hl("Define", { fg = colors.aqua })
hl("Macro", { fg = colors.aqua })
hl("Type", { fg = colors.blue })
hl("StorageClass", { fg = colors.red })
hl("Structure", { fg = colors.blue })
hl("Typedef", { fg = colors.blue })
hl("Special", { fg = colors.purple })
hl("SpecialChar", { fg = colors.purple })
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
hl("@function.builtin", { fg = colors.yellow, italic = true })
hl("@variable", { link = "Identifier" })
hl("@variable.builtin", { fg = colors.purple })
hl("@type", { link = "Type" })
hl("@type.builtin", { link = "Type" })
hl("@constant", { link = "Constant" })
hl("@constant.builtin", { link = "Constant" })
hl("@number", { link = "Number" })
hl("@boolean", { link = "Boolean" })
hl("@operator", { link = "Operator" })
hl("@property", { fg = colors.aqua })
hl("@parameter", { fg = colors.fg, italic = true })

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
hl("GitSignsChange", { fg = colors.blue })
hl("GitSignsDelete", { fg = colors.red })

-- ============================================================================
-- Plugin-Specific Highlights (Minimal - let plugins inherit)
-- ============================================================================
-- Telescope
hl("TelescopeBorder", { fg = colors.grey })
hl("TelescopePromptBorder", { fg = colors.blue })
hl("TelescopeSelection", { fg = colors.fg, bg = colors.bg2 })

-- NvimTree
hl("NvimTreeFolderIcon", { fg = colors.blue })
hl("NvimTreeOpenedFolderName", { fg = colors.yellow })

-- Which-Key
hl("WhichKey", { fg = colors.yellow })
hl("WhichKeyGroup", { fg = colors.blue })
hl("WhichKeySeparator", { fg = colors.grey })

-- Flash (motion plugin)
hl("FlashLabel", { fg = colors.bg0, bg = colors.orange, bold = true })
hl("FlashMatch", { fg = colors.search })
