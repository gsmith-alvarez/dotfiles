-- [[ EDITING DOMAIN ORCHESTRATOR ]]
-- Purpose: Coordinate text manipulation, formatting, and structural refactoring.
-- Domain:  Editing & Productivity
-- Architecture: Eager Proxy Registration (Phased Boot)
--
-- PHILOSOPHY: The "Trap" Architecture
-- This orchestrator runs at startup but DOES NOT load heavy plugins. 
-- Instead, it plants "JIT Traps" (keymaps and autocommands) that only 
-- trigger the full plugin load when the user actually attempts an edit.
-- This is a core "Anti-Fragile" strategy: Neovim stays fast, while the 
-- editing features remain globally available.
--
-- MAINTENANCE TIPS:
-- 1. If an editing feature (refactor, rename) fails, check the specific 
--    module in this directory.
-- 2. New editing-related plugins should be added to the `modules` table.
-- 3. JIT (Just-In-Time) loading is used extensively here to keep startup 
--    under 50ms.

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
	'editing.copilot', -- Copilot integration
	'editing.luasnip', -- Snippet engine: custom Lua + VSCode snippets with node navigation
	'editing.autolist', -- Automatic list continuation and formatting
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
