-- [[ AUTOCOMMANDS: lua/autocmd/init.lua ]]
-- =============================================================================
-- This is the "Automation Hub" of your configuration.
-- 
-- Architecture: Fault-Tolerant Event Dispatcher
-- -----------------------------------------------------------------------------
-- Neovim uses "Autocommands" to trigger logic when certain events happen
-- (e.g. saving a file, changing a buffer, or entering Neovim).
-- This file orchestrates all your custom automation layers.
-- =============================================================================

local M = {}
local utils = require('core.utils')

-- [[ THE AUTOMATION MODULES ]]
local modules = {
	'autocmd.basic',    -- General UI and buffer cleanup.
	'autocmd.external', -- Integration with system tools (Terminals, Mise).
	'autocmd.jit',      -- Performance tuning and JIT optimization.
}

-- [[ THE PROTECTED LOADER ]]
-- We load these modules inside a pcall to ensure a mistake in one automation 
-- script doesn't break the entire editor.
for _, module in ipairs(modules) do
	local ok, err = pcall(require, module)
	if not ok then
		utils.soft_notify(string.format("AUTOCMD FAILURE: Failed to load %s\nError: %s", module, err),
			vim.log.levels.ERROR)
	end
end

return M
