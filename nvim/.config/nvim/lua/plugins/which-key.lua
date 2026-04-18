-- =============================================================================
-- [ WHICH-KEY ]
-- Displays a popup with available keybindings for the current mode/prefix.
-- =============================================================================

local mini = require('plugins.mini')

mini.later(function()
	-- 1. [ INITIALIZATION ]
	-- Use the 'modern' preset for a clean, visually appealing UI.
	require('which-key').setup({
		preset = 'helix',
	})
end)
