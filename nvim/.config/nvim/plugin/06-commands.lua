-- =============================================================================
-- [ USER COMMANDS ]
-- Entry point for custom command modules.
-- =============================================================================
local commands = Config.safe_require "commands"
if not commands then
	return
end
-- [ Building & Execution ]
-- Includes :Run, :RunWatch, and :Watch commands.
commands.register "building"
-- [ Plugin Management ]
-- High-level commands for the 'vim.pack' system.
commands.register "pack"
