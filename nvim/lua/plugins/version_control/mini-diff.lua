-- [[ MINI.DIFF + MINI.BRACKETED: Git Hunk Navigation ]]
-- Domain: Git
-- ARCHITECTURE: Deferred via MiniDeps.later — runs strictly after initial render.
-- KEYMAPS: All git keymaps live in lua/core/plugin-keymaps.lua (<leader>g prefix).

local M = {}

M.setup = function()
	local MiniDeps = require('mini.deps')

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
end

return M
