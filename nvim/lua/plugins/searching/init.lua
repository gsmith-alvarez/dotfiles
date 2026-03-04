-- [[ SEARCHING DOMAIN ORCHESTRATOR ]]
-- Location: lua/plugins/searching/init.lua

local M = {}
local utils = require 'core.utils'

local modules = {
	'searching.aerial', -- Structural navigation
	'searching.snacks-picker', -- JIT Finding Engine
}

for _, mod in ipairs(modules) do
	local module_path = 'plugins.' .. mod
	local ok, err = pcall(require, module_path)
	if not ok then
		utils.soft_notify(string.format('NAV DOMAIN FAILURE: [%s]\n%s', module_path, err), vim.log.levels.ERROR)
	end
end

return M
