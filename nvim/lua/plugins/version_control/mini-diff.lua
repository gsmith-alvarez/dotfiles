-- [[ MINI.DIFF + MINI.BRACKETED: Git Hunk Navigation ]]
-- Domain: Git
-- ARCHITECTURE: Deferred via MiniDeps.later — runs strictly after initial render.
-- KEYMAPS: All git keymaps live in lua/core/plugin-keymaps.lua (<leader>g prefix).

local M = {}

M.setup = function()
	local MiniDeps = require('mini.deps')

	MiniDeps.later(function()
		-- 1. Bracketed Navigation (General)
		-- Provides native-feeling [b/]b (buffers), [d/]d (diagnostics), etc.
		require('mini.bracketed').setup()

		-- 2. Diff Management
		local git_icons = require('core.icons').git
		require('mini.diff').setup {
			view = {
				style = 'sign',
				signs = { add = git_icons.added, change = git_icons.modified, delete = git_icons.removed }
			},
			delay = { text_change = 200 },
		}
	end)
end

return M
