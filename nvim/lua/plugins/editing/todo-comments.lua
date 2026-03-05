-- [[ TODO-COMMENTS: Highlighted Annotations ]]
-- Domain: Editing
-- JIT-loaded on first use; highlights are registered immediately via autocmd.

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
