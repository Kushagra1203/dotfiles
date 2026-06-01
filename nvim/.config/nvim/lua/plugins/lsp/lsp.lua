return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/lazydev.nvim", opts = {} },
	},
	config = function()
		local lspconfig = require("lspconfig")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")
		local capabilities = cmp_nvim_lsp.default_capabilities()

		-- 1. Set global defaults (New API)
		vim.lsp.config("*", {
			capabilities = capabilities,
		})

		-- 2. Setup Python (Pyright)
		vim.lsp.enable("pyright")

		-- We add 'root_dir' so it works even for single-file competitive programming
		-- 3. Force System Clangd for C++
		vim.lsp.config("clangd", {
			cmd = {
				"clangd",
				"--background-index",
				"--clang-tidy",
				"--fallback-style=llvm",
			},
			capabilities = {
				offsetEncoding = { "utf-16" },
			},
			-- FORCE Neovim to treat the current folder as the project root
			-- This fixes the "No workspace folders found" error in your log
			root_dir = vim.fn.getcwd(),
		})
		vim.lsp.enable("clangd") -- 4. Register and Enable other servers
		local servers = { "html", "cssls", "tailwindcss", "svelte", "ts_ls" }
		for _, lsp in ipairs(servers) do
			vim.lsp.enable(lsp)
		end
	end,
}
