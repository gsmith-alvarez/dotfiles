-- ============================================================================= [ BLINK.CMP ]
-- Configuration for the high-performance completion engine.
-- =============================================================================

local M = {}

local mini = require('plugins.mini')

mini.later(function()
	 require('blink.cmp').setup()
end)

-- TODO: Add blink.cmp setup and options here.
-- Note: Automated build script (Cargo) is in plugin/02-pack.lua.

return M
