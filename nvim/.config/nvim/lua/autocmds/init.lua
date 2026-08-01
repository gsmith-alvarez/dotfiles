-- autocommand registrar

local M = {}
local utils = Config.safe_require("core.utils")
if not utils then
	return
end

--- Automatically register groups of autocommands defined in a module.
--- @param module_name string The name of the module inside lua/autocmds/
M.register = function(module_name)
	local module = Config.safe_require("autocmds." .. module_name)
	if not module or not module.setup then
		return
	end

	for _, def in ipairs(module.setup) do
		utils.autocmd(def.event, def.pattern, def.action, def.desc)
	end
end

return M
