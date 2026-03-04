-- [[ GIT DOMAIN ORCHESTRATOR ]]
-- Location: lua/plugins/version_control/init.lua
-- Domain: Version Control & Diff Navigation

local M = {}
local utils = require 'core.utils'

local modules = {
	'version_control.mini-diff', -- Plants the hunk navigation keymaps
}

for _, mod in ipairs(modules) do
	local module_path = 'plugins.' .. mod

	local ok, mod_or_err = pcall(require, module_path)

	if ok and type(mod_or_err) == 'table' and type(mod_or_err.setup) == 'function' then
		local setup_ok, setup_err = pcall(mod_or_err.setup)
		if not setup_ok then
			utils.soft_notify(
				string.format('GIT DOMAIN SETUP FAILURE: [%s]\n%s', module_path, setup_err),
				vim.log.levels.ERROR)
		end
	elseif not ok then
		local err = mod_or_err
		utils.soft_notify(string.format('GIT DOMAIN FAILURE: [%s]\n%s', module_path, err),
			vim.log.levels.ERROR)
	end
end

-- THE CONTRACT: Return the module to satisfy the Global Plugins Orchestrator
return M
