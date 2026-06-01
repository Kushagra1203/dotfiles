return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },

  config = function()
    local lualine = require("lualine")
    local lazy_status = require("lazy.status")

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

    local my_lualine_theme = {
      normal = {
        a = { bg = C.primary, fg = C.bg, gui = "bold" },
        b = { bg = C.bg_dark, fg = C.fg },
        c = { bg = C.bg, fg = C.fg_dim },
      },
      insert = {
        a = { bg = C.secondary, fg = C.bg, gui = "bold" },
        b = { bg = C.bg_dark, fg = C.fg },
        c = { bg = C.bg, fg = C.fg_dim },
      },
      visual = {
        a = { bg = C.tertiary, fg = C.bg, gui = "bold" },
        b = { bg = C.bg_dark, fg = C.fg },
        c = { bg = C.bg, fg = C.fg_dim },
      },
      replace = {
        a = { bg = C.fg_dim, fg = C.bg, gui = "bold" },
        b = { bg = C.bg_dark, fg = C.fg },
        c = { bg = C.bg, fg = C.fg_dim },
      },
      command = {
        a = { bg = C.error, fg = C.bg, gui = "bold" },
        b = { bg = C.bg_dark, fg = C.fg },
        c = { bg = C.bg, fg = C.fg_dim },
      },
      inactive = {
        a = { bg = C.bg_dark, fg = C.fg_dim },
        b = { bg = C.bg_dark, fg = C.fg_dim },
        c = { bg = C.bg_dark, fg = C.fg_dim },
      },
    }

    lualine.setup({
      options = {
        theme = my_lualine_theme,
      },
      sections = {
        lualine_x = {
          {
            lazy_status.updates,
            cond = lazy_status.has_updates,
            color = { fg = C.tertiary },
          },
          "encoding",
          "fileformat",
          "filetype",
        },
      },
    })
  end,
}

