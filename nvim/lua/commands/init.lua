-- [[ COMMANDS ORCHESTRATOR ]]
-- =============================================================================
-- Purpose: Central Dispatcher for Custom User Commands
-- Domain:  Automation / Ex-Commands
-- Architecture: Fault-Tolerant Auto-Registration
--
-- PHILOSOPHY: Action-Driven Extendability
-- This file allows you to add complex logic (Zellij integration, auditing,
-- etc.) without cluttering your init.lua. It automatically scans the
-- modules in this directory and registers both the Ex command AND the
-- corresponding keymap if defined.
-- =============================================================================

local M = {}
local utils = require('core.utils')

-- [[ THE COMMAND MODULES ]]
-- List of files in lua/commands/ to be scanned.
local modules = {
	'commands.auditing', -- ToolCheck, Redir, Typos
	'commands.building', -- Zellij & Watchexec smart runners
	'commands.diagnostics', -- Quickfix and LSP hover routing
	'commands.utilities', -- Jq, Sd, Xh, and buffer helpers
	'commands.mux',  -- Zellij pane management
	'commands.hot-reload', -- Hot Reloading for my config
}

-- [[ THE AUTO-REGISTRATION ENGINE ]]
-- Why: Instead of manually calling nvim_create_user_command for 50+ tools,
-- we loop through structured tables. This ensures consistency.
for _, module in ipairs(modules) do
	local ok, mod = pcall(require, module)

	if not ok then
		-- Route failures to the audit trail (~/.local/state/nvim/config_diagnostics.log)
		utils.soft_notify(string.format('CRITICAL: Failed to load %s\nError: %s', module, mod),
			vim.log.levels.ERROR)
	elseif type(mod) == 'table' and mod.commands then
		for cmd_name, cmd_def in pairs(mod.commands) do
			-- 1. Register the Ex Command (e.g., :Jq)
			vim.api.nvim_create_user_command(cmd_name, cmd_def.impl, {
				nargs = cmd_def.nargs,
				desc = cmd_def.desc,
				complete = cmd_def.complete,
			})

			-- 2. Register the Keymap (e.g., <leader>uj)
			-- These are automatically discovered by mini.clue thanks to the 'desc' field.
			if cmd_def.keymap then
				vim.keymap.set('n', cmd_def.keymap, '<cmd>' .. cmd_name .. '<CR>', {
					desc = cmd_name .. ': ' .. cmd_def.desc,
				})
			end
		end
	end
end

return M
