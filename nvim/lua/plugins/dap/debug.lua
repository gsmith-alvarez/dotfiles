-- [[ DAP: Debug Adapter Protocol + PlatformIO ]]
-- Domain: Hardware Debugging & Execution Control

local M = {}
local utils = require('core.utils')

local bootstrap_dap_core = function()
	local ok, _ = pcall(require, 'dap')
	if ok then return true end

	local MiniDeps = require('mini.deps')
	MiniDeps.add('mfussenegger/nvim-dap')
	vim.cmd('packadd nvim-dap')

	return pcall(require, 'dap')
end

-- Exported as M.setup for the DAP domain orchestrator (plugins/dap/init.lua).
M.bootstrap = bootstrap_dap_core

local loaded = false

-- [[ OPENOCD LIFECYCLE MANAGEMENT ]]
local openocd_job_id = nil

local function start_openocd()
	if openocd_job_id then return true end -- Already running

	-- Guard: openocd is EE-specific; skip silently if not installed
	if not utils.mise_shim('openocd') then
		utils.soft_notify('openocd not found — install it via mise.local.toml to enable hardware debugging.', vim.log.levels.WARN)
		return false
	end

	-- Enforce project-level configuration.
	-- You must have an openocd.cfg in your project root.
	if vim.fn.filereadable('openocd.cfg') == 0 then
		utils.soft_notify('Fatal: openocd.cfg missing from project root.', vim.log.levels.ERROR)
		return false
	end

	openocd_job_id = vim.fn.jobstart({ 'openocd', '-f', 'openocd.cfg' }, {
		detach = false, -- If Neovim crashes, the OS kills OpenOCD. No orphaned processes.
		on_stderr = function(_, data)
			-- OpenOCD spits out a lot of noise. We only care if it completely panics.
			-- You can expand this to parse for "Error:" strings if you want strict validation.
		end,
	})

	if openocd_job_id <= 0 then
		utils.soft_notify('Failed to spawn OpenOCD process.', vim.log.levels.ERROR)
		openocd_job_id = nil
		return false
	end

	-- Yield the thread for 500ms to give OpenOCD time to bind to port 3333
	-- and interface with the USB hardware before LLDB tries to connect.
	vim.cmd('sleep 500m')
	return true
end

local function kill_openocd()
	if openocd_job_id then
		vim.fn.jobstop(openocd_job_id)
		openocd_job_id = nil
	end
end


local function bootstrap_full_dap()
	if loaded then return true end

	if not bootstrap_dap_core() then
		utils.soft_notify('Failed to bootstrap core DAP library.', vim.log.levels.ERROR)
		return false
	end

	local ok, err = pcall(function()
		local MiniDeps = require('mini.deps')
		MiniDeps.add('rcarriga/nvim-dap-ui')
		MiniDeps.add('nvim-neotest/nvim-nio')

		local dap = require('dap')
		local dapui = require('dapui')

		-- UI Automation
		dapui.setup()

		-- JIT Load Virtual Text
		-- The file path must match wherever you saved the virtual text module.
		require('plugins.dap.nvim-dap-virtual-text').setup()

		dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end

		-- Teardown Hooks (UI and Hardware Server)
		dap.listeners.before.event_terminated["teardown"] = function()
			dapui.close()
			kill_openocd()
		end
		dap.listeners.before.event_exited["teardown"] = function()
			dapui.close()
			kill_openocd()
		end
		dap.listeners.before.disconnect["teardown"] = function()
			kill_openocd()
		end

		-- Hardware Adapter Configuration (LLDB)
		dap.adapters.lldb = {
			type = 'executable',
			command = utils.mise_shim('lldb-dap') or 'lldb-dap',
			name = 'lldb',
		}

		-- PlatformIO Specific Targets
		dap.configurations.cpp = {
			{
				name = "PlatformIO: Hardware Debug (LLDB/OpenOCD)",
				type = "lldb",
				request = "launch",
				-- Use coroutine to allow async UI selection without blocking DAP
				program = function()
					return coroutine.create(function(dap_run_co)
						-- 1. Boot the hardware server FIRST
						if not start_openocd() then
							-- If the server fails to boot, we abort the entire debug session.
							return
						end

						-- 2. Proceed with ELF resolution
						local pio_path = vim.fn.getcwd() .. '/.pio/build/'
						local executables = vim.fn.glob(pio_path .. '*/firmware.elf', false, true)

						if #executables == 0 then
							local path = vim.fn.input('Path to .elf: ', pio_path, 'file')
							coroutine.resume(dap_run_co, path)
						elseif #executables == 1 then
							coroutine.resume(dap_run_co, executables[1])
						else
							vim.ui.select(executables,
								{ prompt = 'Select Target Environment:' },
								function(choice)
									coroutine.resume(dap_run_co, choice)
								end)
						end
					end)
				end,
				initCommands = { "gdb-remote localhost:3333" },
				postRunCommands = {
					"process plugin packet monitor reset halt",
					"target modules load --all"
				},
			},
		}
		dap.configurations.c = dap.configurations.cpp
	end)

	if not ok then
		utils.soft_notify('DAP Infrastructure failure: ' .. err, vim.log.levels.ERROR)
		return false
	end

	loaded = true
	return true
end

-- Keymaps moved to lua/core/plugin-keymaps.lua under Debug (<leader>d / <F5>) section.

M.bootstrap = bootstrap_full_dap

return M