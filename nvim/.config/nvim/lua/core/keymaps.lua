vim.g.mapleader = " "

local keymap = vim.keymap

vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode with jk" })

vim.keymap.set("n", "<Esc>", "<Esc>:nohlsearch<CR>", { noremap = true, silent = true })

-- window mamagement
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Split window equal size" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to the next tab" })
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to the previous tab" })
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })

keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move block down" })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move block up" })

keymap.set("n", "<leader>rr", function()
	-- Save the file before running
	vim.cmd("silent! write")

	local filetype = vim.bo.filetype
	if filetype == "cpp" then
		-- Compiles using g++ and then runs the executable
		vim.cmd("split | term g++ % -o %:r && ./%:r")
	elseif filetype == "python" then
		-- Runs the current file with python3
		vim.cmd("split | term python3 %")
	else
		print("No runner configured for " .. filetype)
	end
end, { desc = "Run Code in Terminal" })
