-- ============================================================================
-- DAP Debugging (nvim-dap + dap-ui + language adapters)
-- ============================================================================

return {
	-- Core DAP
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			-- DAP UI
			"rcarriga/nvim-dap-ui",
			-- Required by dap-ui
			"nvim-neotest/nvim-nio",
			-- Virtual text for variable values
			"theHamsta/nvim-dap-virtual-text",
			-- Mason integration
			"jay-babu/mason-nvim-dap.nvim",
			-- Language adapters
			"mfussenegger/nvim-dap-python",
			"leoluz/nvim-dap-go",
		},
		keys = {
			{ "<F5>", function() require("dap").continue() end, desc = "Debug: Continue" },
			{ "<F10>", function() require("dap").step_over() end, desc = "Debug: Step Over" },
			{ "<F11>", function() require("dap").step_into() end, desc = "Debug: Step Into" },
			{ "<F12>", function() require("dap").step_out() end, desc = "Debug: Step Out" },
			{ "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle Breakpoint" },
			{
				"<leader>dB",
				function()
					require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
				end,
				desc = "Debug: Conditional Breakpoint",
			},
			{ "<leader>dl", function() require("dap").run_last() end, desc = "Debug: Run Last" },
			{ "<leader>dr", function() require("dap").repl.open() end, desc = "Debug: Open REPL" },
			{ "<leader>dq", function() require("dap").terminate() end, desc = "Debug: Terminate" },
			{ "<leader>du", function() require("dapui").toggle() end, desc = "Debug: Toggle UI" },
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			-- Mason DAP installer
			require("mason-nvim-dap").setup({
				ensure_installed = { "python", "delve" },
				automatic_installation = true,
				handlers = {},
			})

			-- DAP UI setup
			dapui.setup({
				icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
				controls = {
					icons = {
						pause = "⏸",
						play = "▶",
						step_into = "⏎",
						step_over = "⏭",
						step_out = "⏮",
						step_back = "b",
						run_last = "▶▶",
						terminate = "⏹",
						disconnect = "⏏",
					},
				},
			})

			-- Auto-open/close UI on debug session
			dap.listeners.after.event_initialized["dapui_config"] = dapui.open
			dap.listeners.before.event_terminated["dapui_config"] = dapui.close
			dap.listeners.before.event_exited["dapui_config"] = dapui.close

			-- Virtual text
			require("nvim-dap-virtual-text").setup({
				display_callback = function(variable, _, _, _, options)
					if options.virt_text_pos == "inline" then
						return " = " .. variable.value
					else
						return variable.name .. " = " .. variable.value
					end
				end,
			})

			-- Python adapter
			local ok_python, dap_python = pcall(require, "dap-python")
			if ok_python then
				-- Use the debugpy installed by Mason
				local mason_registry = require("mason-registry")
				local debugpy_path = mason_registry.is_installed("debugpy")
						and mason_registry.get_package("debugpy"):get_install_path()
						.. "/venv/bin/python"
					or vim.fn.exepath("python3")
				dap_python.setup(debugpy_path)
				dap_python.test_runner = "pytest"
			end

			-- Go adapter
			local ok_go, dap_go = pcall(require, "dap-go")
			if ok_go then
				dap_go.setup({
					dap_configurations = {
						{
							type = "go",
							name = "Attach remote",
							mode = "remote",
							request = "attach",
						},
					},
				})
			end
		end,
	},
}
