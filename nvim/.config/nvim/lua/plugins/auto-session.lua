return {
	"rmagatti/auto-session",
	config = function()
		local auto_session = require("auto-session")

		-- FIX 1: Set the recommended session options globally
		-- This ensures highlighting and local settings work after restore
		vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

		auto_session.setup({
			-- FIX 2: Use the new 2025 configuration names
			auto_restore = false,
			suppressed_dirs = { "~/", "~/Dev/", "~/Downloads", "~/Documents", "~/Desktop/" },

			-- Keep legacy_cmds off to avoid the "nag" warning we fixed earlier
			legacy_cmds = false,
			log_level = "error",
		})

		local keymap = vim.keymap
		-- Modern 2025 commands
		keymap.set("n", "<leader>wr", "<cmd>AutoSession restore<CR>", { desc = "Restore session for cwd" })
		keymap.set("n", "<leader>ws", "<cmd>AutoSession save<CR>", { desc = "Save session for current directory" })
	end,
}
