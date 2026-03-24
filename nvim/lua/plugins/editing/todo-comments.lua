-- [[ TODO-COMMENTS: Highlighted Annotations ]]
-- Purpose: Highlight and aggregate annotations like TODO, FIXME, and HACK.
-- Domain:  Editing / Visibility
-- Architecture: Passive JIT Highlight
--
-- PHILOSOPHY: Explicit Metadata
-- This plugin provides an "Anti-Fragile" audit trail of technical debt. 
-- Highlighting is "Passive" (low overhead), so we bootstrap it immediately 
-- to ensure annotations are visible from the first frame. It integrates 
-- with the Trouble domain for project-wide auditing.
--
-- MAINTENANCE TIPS:
-- 1. Use `]t` and `[t` to jump between annotations.
-- 2. Project-wide view is available via `<leader>xt`.
-- 3. If highlights are missing, ensure the filetype is supported by Treesitter.

local M = {}
local utils = require 'core.utils'

local loaded = false

local function bootstrap()
	if loaded then return true end

	local ok, err = pcall(function()
		require('mini.deps').add('folke/todo-comments.nvim')
		require('todo-comments').setup { signs = true }
	end)

	if not ok then
		utils.soft_notify('todo-comments failed to initialize: ' .. err, vim.log.levels.ERROR)
		return false
	end

	loaded = true
	return true
end

-- Bootstrap immediately (highlighting is passive and cheap)
bootstrap()

-- Keymaps moved to lua/core/plugin-keymaps.lua under TODO and Trouble sections.

return M
