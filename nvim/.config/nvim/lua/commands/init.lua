-- =============================================================================
-- [ COMMAND REGISTRAR ]
-- Orchestrates the discovery and activation of modular user commands.
-- =============================================================================

local M = {}
local utils = require("core.utils")

--- Automatically register commands and keymaps defined in a command module.
--- Why: Decouples command logic from registration and provides fault tolerance.
--- @param module_name string The name of the module inside lua/commands/
M.register = function(module_name)
	-- Use the global safe_require defined in init.lua for error handling.
	local module = Config.safe_require("commands." .. module_name)
	if not module or not module.setup then
		return
	end

	for name, def in pairs(module.setup) do
		-- 1. Create the User Command
		-- Maps the command name to its implementation function.
		vim.api.nvim_create_user_command(name, def.impl, def.options or {})

		-- 2. Automatically create the keymap if defined
		-- Uses the global nmap utility to ensure consistent behavior and descriptions.
		if def.keymap then
			utils.nmap(def.keymap, def.impl, def.options.desc or name)
		end
	end
end

return M
