-- [[ COMMANDS ORCHESTRATOR ]]
-- =============================================================================

local M = {}

--- Register a set of commands from a domain module.
--- @param domain string The module name under lua/commands/
M.register = function(domain)
	local payload = Config.safe_require("commands." .. domain)
	if not payload or not payload.setup then
		return
	end

	for name, cmd in pairs(payload.setup) do
		local options = cmd.options or {}
		vim.api.nvim_create_user_command(name, cmd.impl, options)
	end
end

return M
