-- =============================================================================
-- [ AUTOCOMMAND REGISTRAR ]
-- Orchestrates the discovery and activation of modular autocommands.
-- =============================================================================

local M = {}
local utils = Config.safe_require "core.utils"
if not utils then
	return
end

--- Automatically register groups of autocommands defined in a module.
--- Why: Allows grouping complex events (like LSP) into their own files.
--- @param module_name string The name of the module inside lua/autocmds/
M.register = function(module_name)
	-- Use the global safe_require defined in init.lua for error handling.
	local module = Config.safe_require("autocmds." .. module_name)
	if not module or not module.setup then
		return
	end

	for _, def in ipairs(module.setup) do
		-- Use the existing utility to ensure they are added to the 'custom-config' group.
		-- This guarantees they are cleared properly on configuration reload.
		utils.autocmd(def.event, def.pattern, def.action, def.desc)
	end
end

return M
