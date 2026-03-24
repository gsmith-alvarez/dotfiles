-- [[ UI DOMAIN ORCHESTRATOR: lua/plugins/ui/init.lua ]]
-- =============================================================================
-- Purpose: Coordinate the visual "Skin" and "Telemetry" of the editor.
-- Domain:  Aesthetics & Information Design
-- Architecture: Phased Boot / Strict Rendering Hierarchy
-- =============================================================================

local M = {}
local utils = require 'core.utils'

--- PHASE 0: The Colorscheme
--- We load this separately and early to prevent the Flash of Unstyled Content.
M.setup_foundation = function()
	local ok, colors = pcall(require, 'plugins.ui.mini-colors')
	if ok and colors.setup then
		colors.setup()
	end
end

M.setup = function()
	-- [[ THE RENDERING PIPELINE ]]

	-- 1. DEFERRED UI (Scheduled for Next Tick)
	-- (Previously contained noice.nvim, now handled natively or via snacks)

	-- 2. EVENT-BASED PLUGINS (JIT / Autocmd Triggers)
	-- These are relatively cheap as they just register autocommands.
	local event_modules = {
		'ui.mini-starter',
		'ui.treesitter',
		'ui.trouble',
		'ui.render-markdown',
		'ui.mini-statusline',
		'ui.winbar',
		'ui.mini-clue',
	}

	for _, mod in ipairs(event_modules) do
		local module_path = 'plugins.' .. mod
		local ok, mod_or_err = pcall(require, module_path)
		if ok and type(mod_or_err) == 'table' and type(mod_or_err.setup) == 'function' then
			local setup_ok, setup_err = pcall(mod_or_err.setup)
			if not setup_ok then
				utils.soft_notify(string.format('DOMAIN SETUP FAILURE: [%s]\n%s', module_path, setup_err),
					vim.log.levels.ERROR)
			end
		elseif not ok then
			utils.soft_notify(string.format('UI-EVENT DOMAIN FAILURE: [%s]\n%s', module_path, mod_or_err),
				vim.log.levels.ERROR)
		end
	end
end

return M
