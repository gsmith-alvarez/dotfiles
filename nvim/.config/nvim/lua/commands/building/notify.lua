-- =============================================================================
-- [ BUILD NOTIFICATIONS ]
-- Shared notification backend for building commands.
-- =============================================================================

local M = {}

local snacks = Config.safe_require("snacks")
local backend = snacks and snacks.notify or nil

--- Notify via Snacks when available, fallback to vim.notify.
--- @param msg string Notification message.
--- @param level integer Log level (vim.log.levels.*).
--- @param opts table|nil Optional notification options.
function M.notify(msg, level, opts)
	if backend then
		backend(msg, vim.tbl_extend("force", { level = level }, opts or {}))
	else
		vim.notify(msg, level, opts)
	end
end

return M
