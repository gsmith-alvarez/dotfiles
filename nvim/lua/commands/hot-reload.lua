-- [[ SYSTEM COMMANDS ]]
-- Domain: Configuration Management
-- Location: lua/commands/hot-reload.lua
--
-- ARCHITECTURE: Orchestrator Node
-- Plugs directly into the Commands Orchestrator. Defines the Ex command
-- cleanly without taking up valuable keymap real estate.

local M = {}

M.commands = {
	Reload = {
		nargs = 0,
		desc = "Nuclear Hot-Reload of Entire Neovim Configuration",
		impl = function()
			-- 1. JIT ENGINE STATE RESET (CRITICAL)
			-- init.lua uses this global flag to prevent double-loading.
			-- We MUST clear it so the JIT engine is forced to re-evaluate
			-- the 'autocmd' and 'commands' directories.
			_G.JIT_AUTOMATION_LOADED = nil

			-- 2. THE CACHE SWEEPER
			-- Iterate through all loaded Lua modules. If it belongs to our
			-- architecture, we obliterate it from memory.
			for module_name, _ in pairs(package.loaded) do
				if module_name:match('^core')
				    or module_name:match('^autocmd')
				    or module_name:match('^commands')
				    or module_name:match('^plugins') then
					package.loaded[module_name] = nil
				end
			end

			-- 3. THE RE-BOOT
			-- Find your main init.lua file and execute it from scratch.
			-- dofile() bypasses the require() cache entirely.
			local init_path = vim.fn.stdpath('config') .. '/init.lua'
			local ok, err = pcall(dofile, init_path)

			-- 4. CONFIRMATION
			if ok then
				vim.notify("System Reloaded",
					vim.log.levels.INFO, { title = "System" })
			else
				vim.notify("System Crash during reload:\n" .. tostring(err), vim.log.levels.ERROR,
					{ title = "System" })
			end
		end,
	}
}

return M
