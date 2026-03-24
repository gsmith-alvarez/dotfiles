-- [[ MINI.DIFF: Git Hunks & Signs ]]
-- Purpose: Visual feedback for git changes directly in the buffer.
-- Domain:  Version Control
-- Architecture: Performance-Oriented Native Diffing
--
-- PHILOSOPHY: Near-Instant Visual Feedback
-- -----------------------------------------------------------------------------
-- We use `mini.diff` to show added (+), modified (~), and deleted (-) 
-- signs in the gutter. It is much faster and more reliable than the 
-- older `gitsigns.nvim`. 
--
-- MAINTENANCE TIPS:
-- 1. Signs are shown in the gutter (left column).
-- 2. Use `]c` and `[c` to jump between changes (hunks).
-- 3. Use `<leader>gD` to see a full diff overlay.
-- 4. If signs don't show up, verify that you are in a Git repository.
-- =============================================================================

local M = {}
local utils = require 'core.utils'

M.setup = function()
	local ok, err = pcall(function()
		local MiniDeps = require 'mini.deps'

		-- 1. Bracketed Navigation (General)
		-- Provides native-feeling [b/]b (buffers), [d/]d (diagnostics), etc.
		MiniDeps.later(function() require('mini.bracketed').setup() end)

		-- 2. Git Integration (branch + status for statusline via vim.b.minigit_summary)
		MiniDeps.later(function() require('mini.git').setup() end)

		-- 3. Diff Management — sign column hunks (+/~/-)
		MiniDeps.later(function()
			require('mini.diff').setup {
				view = {
					style = 'sign',
					signs = { add = '', change = '󰋖', delete = '' }
				},
				delay = { text_change = 200 },
			}
			-- Attach to buffer already open when later() fires
			vim.schedule(function()
				local buf = vim.api.nvim_get_current_buf()
				if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == '' then
					require('mini.diff').enable(buf)
				end
			end)

			-- Color the signs: green add, yellow change, red delete
			vim.api.nvim_set_hl(0, 'MiniDiffSignAdd', { fg = '#89b4fa' })
			vim.api.nvim_set_hl(0, 'MiniDiffSignChange', { fg = '#f9e2af' })
			vim.api.nvim_set_hl(0, 'MiniDiffSignDelete', { fg = '#f38ba8' })
		end)
	end)

	if not ok then
		utils.soft_notify('Mini.diff failed to load: ' .. err, vim.log.levels.ERROR)
	end
end

return M
