vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt

opt.relativenumber = true
opt.number= true

-- tabs & indentation
opt.tabstop = 2 -- 2 spaces for tabs (prettier defualt)
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- expnad tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

opt.wrap =false

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed cases in your search, assumes you want case-sensitive

opt.cursorline = true

opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

-- backspace
opt.backspace = "indent,eol,start"

--clipboard
opt.clipboard:append("unnamedplus")

--split windows
opt.splitright = true
opt.splitbelow = ture


