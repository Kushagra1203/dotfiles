return {
	"goolord/alpha-nvim",
	event = "VimEnter",
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		dashboard.section.header.val = {
			"                                                     ",
			"  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
			"  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
			"  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
			"  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
			"  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
			"  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
			"                                                     ",
		}

		-- This map tells Alpha WHERE to put the colors.
		-- Matugen/Wallust will then decide WHAT those colors are.
		dashboard.section.header.opts.hl = {
			{ "AlphaHeader", 0, -1 },
			{ "AlphaHeader", 0, -1 },
			{ "AlphaHeader", 0, -1 },
			{ "AlphaHeader", 0, -1 },
			{ "AlphaHeader", 0, -1 },
			{ "AlphaHeader", 0, -1 },
			{ "AlphaHeader", 0, -1 },
			{ "AlphaHeader", 0, -1 },
		}

		dashboard.section.buttons.val = {
			dashboard.button("e", "  > New File", "<cmd>ene<CR>"),
			dashboard.button("SPC ee", "  > Toggle file explorer", "<cmd>NvimTreeToggle<CR>"),
			dashboard.button("SPC ff", "󰱼 > Find File", "<cmd>Telescope find_files<CR>"),
			dashboard.button("SPC fs", "  > Find Word", "<cmd>Telescope live_grep<CR>"),
			dashboard.button("SPC wr", "󰁯  > Restore Session For Current Directory", "<cmd>AutoSession restore<CR>"),
			dashboard.button("q", " > Quit NVIM", "<cmd>qa<CR>"),
		}

		for _, button in ipairs(dashboard.section.buttons.val) do
			button.opts.hl = "AlphaButton"
			button.opts.hl_shortcut = "AlphaShortcut"
		end

		alpha.setup(dashboard.opts)
	end,
}
