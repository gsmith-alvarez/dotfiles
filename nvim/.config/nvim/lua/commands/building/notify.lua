local M = {}

local ok, snacks = pcall(require, "snacks")
local backend = ok and snacks.notify or nil

function M.notify(msg, level, opts)
	if backend then
		backend(msg, vim.tbl_extend("force", { level = level }, opts or {}))
	else
		vim.notify(msg, level, opts)
	end
end

return M
