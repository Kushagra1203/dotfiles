return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	config = function()
		require("catppuccin").setup({
			flavor = "mocha",
			transparent_background = true,
			term_colors = false,
			integrations = {
				-- Keep these FALSE so they use your Wallust theme
				telescope = { enabled = false },
				mason = false,
				alpha = false,
				which_key = false,
				bufferline = false,
				indent_blankline = { enabled = false },

				-- Keep these FALSE as you already had them
				cmp = false,
				gitsigns = false,
				nvimtree = false,
				notify = false,
				mini = { enabled = false },

				-- Leave this TRUE for the high-contrast code syntax you wanted
				treesitter = true,
			},
		})
	end,
}
