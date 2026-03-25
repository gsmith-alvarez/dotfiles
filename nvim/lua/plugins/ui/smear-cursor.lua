-- [[ SMEAR-CURSOR.NVIM: Smooth Cursor Animations ]]
-- Purpose: Draw a smooth trail behind the cursor when moving for visual polish.
-- Domain:  Aesthetics & UI
-- Architecture: Deferred Event Loader

local M = {}
local utils = require 'core.utils'

M.setup = function()
	local ok, err = pcall(function()
		require('mini.deps').add('sphamba/smear-cursor.nvim')
		require('smear_cursor').setup({
			-- Safe defaults for high performance
			stiffness = 0.8,
			trailing_stiffness = 0.5,
			distance_stop_animating = 0.5,
			hide_target_hack = false,
		})
	end)

	if not ok then
		utils.soft_notify('Smear-cursor initialization failed: ' .. err, vim.log.levels.ERROR)
	end
end

return M
