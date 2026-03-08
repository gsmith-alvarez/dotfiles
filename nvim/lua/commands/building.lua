-- [[ BUILDING & EXECUTION DOMAIN ]]
-- Modularized logic for offloading heavy compilation and execution tasks to Zellij.
-- PRINCIPLE: Neovim handles the text; Zellij handles the process.
-- KEYMAPS: All keymaps live in lua/core/plugin-keymaps.lua (<leader>e prefix).

local M = {}

--- Helper: Find the project root based on common markers.
--- This allows the runner to determine if it should use 'go run main.go' or 'go run .'.
--- @return string|nil The absolute path to the project root or nil.
local function get_project_root()
	local markers = { 'Cargo.toml', 'go.mod', 'build.zig', 'Makefile', 'pyproject.toml', '.git' }
	local root = vim.fs.find(markers, { upward = true, stop = vim.env.HOME })[1]
	if root then
		return vim.fs.dirname(root)
	end
	return nil
end

-- [[ Watchexec Continuous Daemon ]]
-- Pipes commands to a side-pane in Zellij and re-runs them on file save.
vim.api.nvim_create_user_command('Watch', function(opts)
	local utils = require('core.utils')
	local watchexec = utils.mise_shim('watchexec')
	if not watchexec then
		utils.soft_notify("watchexec not found. Install via mise.", vim.log.levels.ERROR)
		return
	end

	if opts.args == '' then
		utils.soft_notify('Usage: :Watch <command>', vim.log.levels.WARN)
		return
	end

	-- SYMBOL EXPANSION: Convert '%' into the absolute path of the current file.
	local cmd_args = opts.args
	if cmd_args:match("%%") then
		local current_file = vim.fn.expand('%:p')
		if current_file == "" then
			utils.soft_notify('No file open to expand %', vim.log.levels.WARN)
			return
		end
		cmd_args = cmd_args:gsub("%%", vim.fn.shellescape(current_file))
	end

	-- Determine watch root: project root or current file's directory
	local root = get_project_root() or vim.fn.expand('%:p:h')

	-- ASYNCHRONOUS HANDOFF:
	-- -r: restart the process on change (kills old run, starts fresh)
	-- -c: clear screen on each re-run for readability
	-- -w: watch the project root directory
	-- --postpone (-p): don't run at startup, wait for first file change
	-- We do NOT pass --postpone so it runs immediately on pane open.
	local zellij_cmd = string.format(
		"zellij action new-pane -d right -- %s -r -c -w %s -- %s",
		watchexec, vim.fn.shellescape(root), cmd_args)

	vim.fn.jobstart(zellij_cmd)
	vim.notify("Watcher Active: " .. cmd_args, vim.log.levels.DEBUG)
end, { nargs = '+', desc = 'Run command continuously in Zellij via watchexec' })

-- [[ The Anti-Fragile Smart Runner ]]
-- A shared logic engine for both 'Watch' (continuous) and 'Run' (single execution).
-- @param is_continuous boolean Whether to wrap the command in watchexec.
local function execute_smart_build(is_continuous)
	local ft = vim.bo.filetype
	local file = vim.fn.expand('%:p')
	local root = get_project_root()
	local cmd = ""

	-- 1. PYTHON: Modern 'uv' integration.
	if ft == "python" then
		cmd = string.format("uv run %s", vim.fn.shellescape(file))

		-- 2. GO: Workspace awareness.
	elseif ft == "go" then
		-- If we found a go.mod, run the entire module; otherwise run the file.
		local has_mod = root and vim.fn.filereadable(root .. "/go.mod") == 1
		cmd = has_mod and "go run ." or string.format("go run %s", vim.fn.shellescape(file))

		-- 3. ZIG: Build-system awareness.
	elseif ft == "zig" then
		-- Prefer 'zig build run' if a build file exists.
		local has_build = root and vim.fn.filereadable(root .. "/build.zig") == 1
		cmd = has_build and "zig build run" or string.format("zig run %s", vim.fn.shellescape(file))

		-- 4. C / C++: Native Zig runner.
	elseif ft == "c" or ft == "cpp" then
		if root and vim.fn.filereadable(root .. "/Makefile") == 1 then
			cmd = "make"
		else
			-- 'zig run' handles the temporary binary generation and execution cleanly.
			-- '-lc' links the C standard library. C++ also requires '-lc++'.
			local link_flags = (ft == "cpp") and "-lc -lc++" or "-lc"
			cmd = string.format("zig run %s %s", vim.fn.shellescape(file), link_flags)
		end
		-- 5. LUA: Native Neovim runner.
	elseif ft == "lua" then
		cmd = string.format("nvim -l %s", vim.fn.shellescape(file))

		-- 6. RUST: Cargo awareness and artifact-free single files.
	elseif ft == "rust" then
		local has_cargo = root and vim.fn.filereadable(root .. "/Cargo.toml") == 1
		if has_cargo then
			-- Standard Cargo execution (-q keeps the Zellij pane quiet from build spam)
			cmd = "cargo run -q"
		else
			-- Single file execution: Compile to /tmp/ to avoid artifact pollution
			local tmp_bin = "/tmp/" .. vim.fn.expand('%:t:r') .. "_rust_run"
			cmd = string.format([[bash -c "rustc %s -o %s && %s"]], vim.fn.shellescape(file), tmp_bin,
				tmp_bin)
		end
	else
		vim.notify("No smart runner for filetype: " .. ft, vim.log.levels.WARN)
		return
	end

	-- FINAL DISPATCH
	if is_continuous then
		vim.cmd("Watch " .. cmd)
	else
		local zellij_cmd = string.format("zellij action new-pane -d right -- %s", cmd)
		vim.fn.jobstart(zellij_cmd) -- Non-blocking async handoff
		vim.notify("Executing: " .. cmd, vim.log.levels.DEBUG)
	end
end

-- [[ Keymaps: Entry Points ]]
-- Moved to lua/core/plugin-keymaps.lua under the Execute (<leader>e) section.

M.run            = function() execute_smart_build(false) end
M.run_continuous = function() execute_smart_build(true) end

return M
