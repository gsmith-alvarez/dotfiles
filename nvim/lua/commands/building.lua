-- [[ BUILDING & EXECUTION DOMAIN ]]
-- Domain: Task Automation & External Execution
-- Location: lua/commands/building.lua
--
-- PHILOSOPHY: Process Offloading
-- Modularized logic for offloading heavy compilation and execution tasks 
-- to Zellij (or a background terminal). 
-- PRINCIPLE: Neovim handles the text; Zellij handles the process. 
-- By keeping long-running builds or tests in a separate Zellij pane, 
-- we ensure Neovim's UI thread is never blocked, and we can see live 
-- output while we continue to code.
--
-- MAINTENANCE TIPS:
-- 1. To add support for a new language, update the `execute_smart_build` function.
-- 2. If `Watch` fails, verify `watchexec` is installed via `mise`.
-- 3. These commands are auto-registered by `commands/init.lua`.

local M = {}

--- Helper: Find the project root based on common markers.
--- Why: This allows us to run commands like `go run .` or `cargo run` from 
--- anywhere in the project tree.
local function get_project_root()
	local markers = { 'Cargo.toml', 'go.mod', 'build.zig', 'Makefile', 'pyproject.toml', '.git' }
	local root = vim.fs.find(markers, { upward = true, stop = vim.env.HOME })[1]
	if root then
		return vim.fs.dirname(root)
	end
	return nil
end

-- [[ The Anti-Fragile Smart Runner ]]
-- Why: Instead of manually typing `python file.py` or `go run .`, this 
-- function detects your filetype and project structure to run the 
-- most appropriate command in a side pane.
local function execute_smart_build(is_continuous)
	local ft = vim.bo.filetype
	local file = vim.fn.expand '%:p'
	local root = get_project_root()
	local cmd = ''

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
		else
			-- We use Zig as a high-performance C/C++ compiler.
			local link_flags = (ft == 'cpp') and '-lc -lc++' or '-lc'
			local std_flag = (ft == 'cpp') and '-std=c++23' or '-std=std=c23'
			cmd = string.format('zig run -cflags %s -Wall -Wextra -O2 -Werror -- %s %s', std_flag, vim.fn.shellescape(file), link_flags)
		end
	elseif ft == 'lua' then
		-- Run the current Lua file using Neovim's internal interpreter.
		cmd = string.format('nvim -l %s', vim.fn.shellescape(file))
	elseif ft == 'rust' then
		local has_cargo = root and vim.fn.filereadable(root .. '/Cargo.toml') == 1
		if has_cargo then
			cmd = 'cargo run -q'
		else
			local tmp_bin = '/tmp/' .. vim.fn.expand '%:t:r' .. '_rust_run'
			cmd = string.format([[bash -c "rustc %s -o %s && %s"]], vim.fn.shellescape(file), tmp_bin, tmp_bin)
		end
	else
		vim.notify('No smart runner for filetype: ' .. ft, vim.log.levels.WARN)
		return
	end

	if is_continuous then
		-- Use our :Watch command to run this in a loop.
		vim.cmd('Watch ' .. cmd)
	else
		-- Launch in a new Zellij pane to the right.
		local zellij_cmd = string.format('zellij action new-pane -d right -- %s', cmd)
		vim.fn.jobstart(zellij_cmd)
		vim.notify('Executing: ' .. cmd, vim.log.levels.DEBUG)
	end
end

M.commands = {
	-- [[ Watchexec Continuous Daemon: :Watch ]]
	-- Why: This turns any command into a "watch" command. When you save a file 
	-- in the project, the command is instantly re-run in a side pane.
	Watch = {
		desc = 'Run command continuously in Zellij via watchexec',
		nargs = '+',
		impl = function(opts)
			local utils = require 'core.utils'
			local watchexec = utils.mise_shim 'watchexec'
			if not watchexec then
				utils.soft_notify('watchexec not found. Install via: mise install watchexec', vim.log.levels.ERROR)
				return
			end

			local cmd_args = opts.args
			-- % expansion for current file path (matches Vim's standard behavior).
			if cmd_args:match '%%' then
				local current_file = vim.fn.expand '%:p'
				if current_file == '' then
					utils.soft_notify('No file open to expand %', vim.log.levels.WARN)
					return
				end
				cmd_args = cmd_args:gsub('%%', vim.fn.shellescape(current_file))
			end

			local root = get_project_root() or vim.fn.expand '%:p:h'
			-- Launch watchexec in a Zellij pane.
			-- -r: restart process if it's already running.
			-- -c: clear screen before each run.
			local zellij_cmd = string.format('zellij action new-pane -d right -- %s -r -c -w %s -- %s', watchexec, vim.fn.shellescape(root), cmd_args)
			vim.fn.jobstart(zellij_cmd)
			vim.notify('Watcher Active: ' .. cmd_args, vim.log.levels.DEBUG)
		end,
	},

	-- [[ Smart Run Entry Points ]]
	Run = {
		desc = 'Execute current file smartly in Zellij side-pane',
		keymap = '<leader>er',
		impl = function()
			execute_smart_build(false)
		end,
	},

	RunWatch = {
		desc = 'Execute current file continuously via watchexec',
		keymap = '<leader>ew',
		impl = function()
			execute_smart_build(true)
		end,
	},
}

-- Maintain legacy exports for any direct Lua calls.
M.run = function()
	execute_smart_build(false)
end
M.run_continuous = function()
	execute_smart_build(true)
end

return M
