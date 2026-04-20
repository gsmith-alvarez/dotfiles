-- [[ BUILDING & WATCHING DOMAIN ]]
-- =============================================================================

local M = {}

-- Use Snacks for notifications if available, fallback to native
local function notify(msg, level, opts)
	if pcall(require, "snacks") then
		require("snacks").notify(msg, vim.tbl_extend("force", { level = level }, opts or {}))
	else
		vim.notify(msg, level, opts)
	end
end

M.setup = {
	SmartRun = {
		options = { desc = "Run the current file based on filetype" },
		impl = function()
			local ft = vim.bo.filetype
			local file = vim.fn.expand "%:p"
			local cmd = ""

			if ft == "lua" then
				cmd = "source " .. file
				vim.cmd(cmd)
				return
			elseif ft == "python" then
				cmd = "python3 " .. file
			elseif ft == "cpp" or ft == "c" then
				if vim.fn.filereadable "Makefile" == 1 then
					cmd = "make"
				else
					local out = vim.fn.expand "%:r"
					cmd = "g++ -O3 " .. file .. " -o " .. out .. " && ./" .. out
				end
			end

			if cmd ~= "" then
				vim.cmd("term " .. cmd)
			else
				notify("No runner for " .. ft, vim.log.levels.WARN)
			end
		end,
	},
}

return M
