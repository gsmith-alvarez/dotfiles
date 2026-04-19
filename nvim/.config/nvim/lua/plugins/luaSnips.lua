-- =============================================================================
-- [ LUASNIPS ]
-- Configuration for the snippet engine.
-- =============================================================================

local M = {}

local mini = Config.safe_require("plugins.mini")

mini.later(function()
	-- TODO: Add LuaSnip setup and custom snippet loading here.
	-- Note: Automated build script (jsregexp) is in plugin/02-pack.lua.
end)

return M
