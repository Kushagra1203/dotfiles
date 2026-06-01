-- ~/.config/wallust/templates/nvim/colors.lua.template
local C = {
  bg        = "#060300",
  bg_dark   = "#090501",
  bg_light  = "#9A7594",
  fg        = "#EFC4E7",
  fg_dim    = "#E1B7D9",
  primary   = "#A16D5D",
  secondary = "#637996",
  tertiary  = "#8F7289",
  error     = "#585C64",
}

vim.api.nvim_set_hl(0, "Normal",       { fg = C.fg, bg = C.bg })
vim.api.nvim_set_hl(0, "CursorLine",   { bg = C.bg_dark })
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = C.primary })
vim.api.nvim_set_hl(0, "LineNr",       { fg = C.fg_dim })
vim.api.nvim_set_hl(0, "Visual",       { bg = C.bg_light })

--vim.api.nvim_set_hl(0, "Identifier", { fg = C.fg })
--vim.api.nvim_set_hl(0, "Function",   { fg = C.primary })
--vim.api.nvim_set_hl(0, "Keyword",    { fg = C.secondary })
--vim.api.nvim_set_hl(0, "String",     { fg = C.tertiary })
--vim.api.nvim_set_hl(0, "Comment",    { fg = C.fg_dim, italic = true })

vim.api.nvim_set_hl(0, "NormalFloat",  { fg = C.fg, bg = C.bg })
vim.api.nvim_set_hl(0, "FloatBorder",  { fg = C.primary, bg = C.bg })
vim.api.nvim_set_hl(0, "Pmenu",        { fg = C.fg, bg = C.bg_dark })
vim.api.nvim_set_hl(0, "PmenuSel",     { fg = C.bg, bg = C.primary })

vim.api.nvim_set_hl(0, "AlphaHeader",   { fg = C.primary, bold = true })
vim.api.nvim_set_hl(0, "AlphaShortcut", { fg = C.secondary })

vim.api.nvim_set_hl(0, "DiagnosticError", { fg = C.error })
vim.api.nvim_set_hl(0, "DiagnosticWarn",  { fg = "#6A798D" })
vim.api.nvim_set_hl(0, "DiagnosticInfo",  { fg = C.primary })
vim.api.nvim_set_hl(0, "DiagnosticHint",  { fg = C.secondary })

vim.g.colors_name = "matugen"
return C
