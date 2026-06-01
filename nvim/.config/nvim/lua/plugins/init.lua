return {
	"nvim-lua/plenary.nvim",
	"christoomey/vim-tmux-navigator",
	{
		"christopher-francisco/tmux-status.nvim",
		-- This ensures the plugin loads after your UI is ready
		event = "VeryLazy",
		config = function()
			require("tmux-status").setup({
				-- This plugin will now automatically sync your Matugen colors to tmux
			})
		end,
	},
}
