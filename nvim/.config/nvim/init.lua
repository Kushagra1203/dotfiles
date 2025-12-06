require("core")
require("lazy-bootstrap")
vim.cmd("colorscheme matugen")
vim.opt.fillchars = { eob = " " }

local uv = vim.loop

-- Files to watch
local theme_file = vim.fn.stdpath("config") .. "/colors/matugen.lua"
local lualine_file = vim.fn.stdpath("config") .. "/lua/plugins/lualine.lua"

-- Shared debounce timer
local timer = uv.new_timer()

-- One unified callback
local function on_change()
  timer:stop()
  timer:start(200, 0, vim.schedule_wrap(function()

    -- Reload Neovim colorscheme
    vim.cmd("colorscheme matugen")

    -- Reload just the lualine plugin
    vim.cmd("Lazy reload lualine.nvim")
  end))
end

-- Watchers
local theme_watcher = uv.new_fs_event()
local lualine_watcher = uv.new_fs_event()

theme_watcher:start(theme_file, {}, on_change)
lualine_watcher:start(lualine_file, {}, on_change)
