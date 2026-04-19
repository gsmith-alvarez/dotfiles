-- =============================================================================
-- [ USER COMMANDS ]
-- Entry point for custom command modules.
-- =============================================================================

local commands = require('commands')

-- [ Building & Execution ]
-- Includes :Run, :RunWatch, and :Watch commands.
commands.register('building')

-- [ Plugin Management ]
-- High-level commands for the 'vim.pack' system.
commands.register('pack')
