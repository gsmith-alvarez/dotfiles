local M = {}

local snacks = Config.safe_require("snacks")
local backend = snacks and snacks.notify or nil

function M.notify(msg, level, opts)
	if backend then
		backend(msg, vim.tbl_extend("force", { level = level }, opts or {}))
	else
		vim.notify(msg, level, opts)
	end
end

return M
