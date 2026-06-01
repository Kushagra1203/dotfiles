require("core")
require("lazy-bootstrap")
require("lsp")

local function apply_theme()
	-- 1. Load Catppuccin first to get the high-contrast syntax logic
	vim.cmd("colorscheme catppuccin-mocha")

	local ok, matugen = pcall(require, "matugen")
	if not ok then
		-- Fallback if the module hasn't been created by Wallust yet
		vim.cmd("colorscheme matugen")
	end
end

-- Run it on startup
vim.schedule(function()
	apply_theme()
end)

vim.opt.fillchars = { eob = " " }

local uv = vim.loop
local timer = uv.new_timer()
local theme_file = vim.fn.stdpath("config") .. "/colors/matugen.lua"
local lualine_file = vim.fn.stdpath("config") .. "/lua/plugins/lualine.lua"

local function on_change()
	timer:stop()
	timer:start(
		200,
		0,
		vim.schedule_wrap(function()
			apply_theme()
			vim.cmd("Lazy reload lualine.nvim")

			vim.defer_fn(function()
				apply_theme()
				vim.cmd("Lazy reload lualine.nvim")
			end, 1000)
		end)
	)
end

local theme_watcher = uv.new_fs_event()
local lualine_watcher = uv.new_fs_event()
theme_watcher:start(theme_file, {}, on_change)
lualine_watcher:start(lualine_file, {}, on_change)
