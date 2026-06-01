return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui", -- The UI (Variables sidebar, Console)
			"nvim-neotest/nvim-nio", -- Requirement for UI
			"mfussenegger/nvim-dap-python", -- Helper for Python
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			dapui.setup()

			-- Python: This plugin finds the Mason version of debugpy automatically
			require("dap-python").setup("python3")

			-- C++: We tell nvim-dap to use the 'codelldb' you just installed in Mason
			dap.adapters.codelldb = {
				type = "server",
				port = "${port}",
				executable = {
					command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
					args = { "--port", "${port}" },
				},
			}

			dap.configurations.cpp = {
				{
					name = "Launch file",
					type = "codelldb",
					request = "launch",
					program = function()
						-- This asks you which file to run (usually your compiled .out file)
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
				},
			}

			-- Automatically open UI when debugging starts
			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
		end,
	},
}
