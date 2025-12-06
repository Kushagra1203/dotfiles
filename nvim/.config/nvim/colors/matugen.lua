-- =====================================================
-- Matugen → Neovim Colorscheme
-- Generated from your Material You palette
-- =====================================================

local C = {
  bg        = "#0f1512",
  bg_dark   = "#3f4945",
  bg_light  = "#dbe5df",
  fg        = "#dee4e0",
  fg_dim    = "#bfc9c4",
  primary   = "#87d6bd",
  secondary = "#b2ccc2",
  tertiary  = "#a9cbe2",
  error     = "#ffb4ab",
}

vim.api.nvim_set_hl(0, "Normal",       { fg = C.fg, bg = C.bg })
vim.api.nvim_set_hl(0, "CursorLine",   { bg = C.bg_dark })
vim.api.nvim_set_hl(0, "NormalFloat",  { fg = C.fg, bg = "NONE" })
vim.api.nvim_set_hl(0, "FloatBorder",  { fg = C.fg_dim, bg = "NONE" })
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = C.primary })
vim.api.nvim_set_hl(0, "LineNr",       { fg = C.fg_dim })
vim.api.nvim_set_hl(0, "Visual",       { bg = C.secondary })

vim.api.nvim_set_hl(0, "StatusLine",   { fg = C.fg, bg = C.bg_dark })
vim.api.nvim_set_hl(0, "StatusLineNC", { fg = C.fg_dim, bg = C.bg_dark })

vim.api.nvim_set_hl(0, "Identifier", { fg = C.fg })
vim.api.nvim_set_hl(0, "Function",   { fg = C.primary })
vim.api.nvim_set_hl(0, "Keyword",    { fg = C.secondary })
vim.api.nvim_set_hl(0, "String",     { fg = C.tertiary })
vim.api.nvim_set_hl(0, "Comment",    { fg = C.fg_dim, italic = true })

vim.api.nvim_set_hl(0, "DiagnosticError", { fg = C.error })
vim.api.nvim_set_hl(0, "DiagnosticWarn",  { fg = C.tertiary })
vim.api.nvim_set_hl(0, "DiagnosticInfo",  { fg = C.primary })
vim.api.nvim_set_hl(0, "DiagnosticHint",  { fg = C.secondary })

vim.g.colors_name = "matugen"

