-- [[ EDITING DOMAIN ORCHESTRATOR ]]
-- Location: lua/plugins/editing/init.lua
-- Domain: Text Manipulation, Formatting, & Refactoring
--
-- ARCHITECTURE: Eager Proxy Registration
-- This orchestrator runs at startup. It does NOT load the heavy plugins.
-- It only executes the root-level keymaps and autocommands inside these
-- files, planting the JIT traps for later execution.

local M = {}
local utils = require 'core.utils'

-- [[ THE DOMAIN MODULES ]]
-- All three of our text manipulation modules are "Proxy Traps".
-- They must be registered immediately at startup so Neovim knows
-- what to do when you press the keybinds or open a file.
local modules = {
	'editing.refactoring', -- Plants the AST keymap traps
	'editing.indent', -- Plants the BufReadPre autocommand trap
	'editing.inc-rename', -- Plants the LSP keymap trap
	'editing.mini-editing', -- Deferred: ai, move, surround, indentscope, pairs, hipatterns
	'editing.todo-comments', -- Highlighted TODO/FIXME/HACK annotations + Trouble integration
}

for _, mod in ipairs(modules) do
	local module_path = 'plugins.' .. mod

	-- [[ THE CIRCUIT BREAKER ]]
	local ok, mod_or_err = pcall(require, module_path)

	if ok and type(mod_or_err) == 'table' and type(mod_or_err.setup) == 'function' then
		local setup_ok, setup_err = pcall(mod_or_err.setup)
		if not setup_ok then
			utils.soft_notify(
				string.format('EDITING DOMAIN SETUP FAILURE: [%s]\n%s', module_path, setup_err),
				vim.log.levels.ERROR)
		end
	elseif not ok then
		local err = mod_or_err
		utils.soft_notify(string.format('EDITING DOMAIN FAILURE: [%s]\n%s', module_path, err),
			vim.log.levels.ERROR)
	end
end

-- THE CONTRACT: Return the module to satisfy the Global Plugins Orchestrator
return M
