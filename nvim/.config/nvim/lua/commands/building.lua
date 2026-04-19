-- [[ BUILDING & EXECUTION DOMAIN: lua/commands/building.lua ]]
-- =============================================================================
-- Purpose: Task Automation & External Code Execution.
-- Domain:  Advanced Productivity / Build System
--
-- Architecture: Process Offloading. Modularized logic for offloading heavy
--               compilation and execution tasks to Zellij (or a background
--               terminal). By keeping long-running builds in a separate
--               pane, we ensure the UI thread is never blocked.
--
-- Philosophy:   "Neovim handles the text; Zellij handles the process."
-- =============================================================================

local M = {}
local utils = require('core.utils')

--- Check if the current session is running inside Zellij.
--- @return boolean
local function is_zellij()
	return os.getenv('ZELLIJ') ~= nil
end

--- Core logic for determining how to build and run the current file.
--- @param is_continuous boolean If true, runs via 'Watch' (watchexec).
local function execute_smart_build(is_continuous)
	local ft = vim.bo.filetype
	local file = vim.fn.expand('%:p')

	-- Ensure the buffer is saved before execution so the file on disk is current.
	if file ~= '' and vim.bo.modified then
		vim.cmd('silent! update')
	end

	local root = utils.project_root()
	local cmd = ''

	-- [ Language-specific Build/Run Definitions ]
	if ft == 'python' then
		cmd = string.format('uv run %s', vim.fn.shellescape(file))
	elseif ft == 'go' then
		local has_mod = root and vim.fn.filereadable(root .. '/go.mod') == 1
		cmd = has_mod and 'go run .' or string.format('go run %s', vim.fn.shellescape(file))
	elseif ft == 'zig' then
		local has_build = root and vim.fn.filereadable(root .. '/build.zig') == 1
		cmd = has_build and 'zig build run' or string.format('zig run %s', vim.fn.shellescape(file))
	elseif ft == 'c' or ft == 'cpp' then
		if root and vim.fn.filereadable(root .. '/Makefile') == 1 then
			cmd = 'make'
		elseif root and vim.fn.filereadable(root .. '/CMakeLists.txt') == 1 then
			cmd = 'cmake --build build'
		else
			if vim.fn.filereadable(file) == 0 then
				vim.notify('C/C++ file not readable: ' .. file, vim.log.levels.ERROR)
				return
			end
			local link_flags = (ft == 'cpp') and '-lc -lc++' or '-lc'
			local std_flag = (ft == 'cpp') and '-std=c++23' or '-std=c23'
			cmd = string.format(
				'zig run -cflags %s -Wall -Wextra -O2 -Werror -- %s %s',
				std_flag,
				vim.fn.shellescape(file),
				link_flags
			)
		end
	elseif ft == 'lua' then
		cmd = string.format('nvim -l %s 2>&1', vim.fn.shellescape(file))
	elseif ft == 'sh' or ft == 'bash' then
		cmd = string.format('bash %s', vim.fn.shellescape(file))
	elseif ft == 'rust' then
		local has_cargo = root and vim.fn.filereadable(root .. '/Cargo.toml') == 1
		if has_cargo then
			cmd = 'cargo run -q'
		else
			local tmp_bin = '/tmp/' .. vim.fn.expand('%:t:r') .. '_rust_run'
			cmd = string.format([[bash -c "rustc %s -o %s && %s"]], vim.fn.shellescape(file), tmp_bin, tmp_bin)
		end
	else
		vim.notify('No smart runner for filetype: ' .. ft, vim.log.levels.WARN)
		return
	end

	if is_continuous then
		-- Route to the watchexec daemon.
		vim.cmd('Watch ' .. cmd)
	else
		-- Wrap command to hold the pane open after execution.
		local hold_open_cmd = string.format('%s; echo ""; echo "Press any key to close..."; read -n 1 -s', cmd)

		if is_zellij() then
			-- Execute in a new Zellij pane.
			vim.system({ 'zellij', 'run', '-d', 'right', '-c', '--', 'bash', '-c', hold_open_cmd })
		else
			-- Fallback to Snacks terminal.
			local snacks = Config.safe_require('snacks')
			if snacks then
				snacks.terminal.toggle({ 'bash', '-c', hold_open_cmd })
			end
		end
		vim.notify('Executing: ' .. cmd, vim.log.levels.DEBUG)
	end
end

-- [[ Command Registry ]]
-- These are picked up by commands/init.lua and registered automatically.
M.setup = {
	Watch = {
		options = { desc = 'Run command continuously in Zellij via watchexec', nargs = '+' },
		impl = function(opts)
			local watchexec = vim.fn.executable('watchexec') == 1 and 'watchexec' or nil
			if not watchexec then
				vim.notify('watchexec not found. Install via: mise install watchexec', vim.log.levels.ERROR)
				return
			end

			local cmd_args = opts.args
			if cmd_args:match('%%') then
				local current_file = vim.fn.expand('%:p')
				if current_file == '' then
					vim.notify('No file open to expand %', vim.log.levels.WARN)
					return
				end
				cmd_args = cmd_args:gsub('%%', vim.fn.shellescape(current_file))
			end

			local root = utils.project_root()

			if is_zellij() then
				vim.system({
					'zellij',
					'run',
					'-d',
					'right',
					'-c',
					'--',
					watchexec,
					'-r',
					'-c',
					'-w',
					root,
					'--',
					'bash',
					'-c',
					cmd_args,
				})
			else
				local snacks = Config.safe_require('snacks')
				if snacks then
					snacks.terminal.toggle({
						watchexec,
						'-r',
						'-c',
						'-w',
						root,
						'--',
						'bash',
						'-c',
						cmd_args,
					})
				end
			end
			vim.notify('Watcher Active: ' .. cmd_args, vim.log.levels.DEBUG)
		end,
	},

	Run = {
		keymap = '<leader>er',
		options = { desc = 'Smart Run current file' },
		impl = function()
			execute_smart_build(false)
		end,
	},

	RunWatch = {
		keymap = '<leader>ew',
		options = { desc = 'Smart Run current file (Continuous)' },
		impl = function()
			execute_smart_build(true)
		end,
	},
}

return M
