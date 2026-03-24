-- [[ SEARCHING DOMAIN ORCHESTRATOR ]]
-- Location: lua/plugins/searching/init.lua
-- Domain: Search, Discovery, and Structural Navigation
--
-- PHILOSOPHY: Contextual Retrieval
-- Searching is not just about finding strings; it's about navigating the 
-- codebase's structure. This orchestrator manages the high-speed finding 
-- engines and symbol browsers.
--
-- MAINTENANCE TIPS:
-- 1. Global search/find keymaps live in `core/plugin-keymaps.lua`.
-- 2. Symbol-based navigation is handled by `aerial.lua`.
-- 3. JIT (Just-In-Time) loading ensures search engines don't slow down boot.

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
