-- =============================================================================
-- [ SNACKS.NVIM ]
-- Configuration for the snacks.nvim utility collection.
-- =============================================================================

local M = {}

local mini = Config.safe_require("plugins.mini")
if not mini then
	return
end

mini.later(function()
	-- TODO: Configure specific snacks modules (e.g. notifier, dash, picker) here.
end)

return M
