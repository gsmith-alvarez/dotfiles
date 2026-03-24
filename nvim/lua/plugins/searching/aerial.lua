-- [[ AERIAL: Structural Code Navigation ]]
-- Domain: Search, Discovery, and Navigation
-- Location: lua/plugins/searching/aerial.lua
--
-- PHILOSOPHY: Spatial Awareness
-- Provides a persistent, hierarchical view of code symbols. It allows you 
-- to "see" the functions, classes, and variables in a file at a glance.
--
-- MAINTENANCE TIPS:
-- 1. Use `<leader>va` to toggle the symbol outline sidebar.
-- 2. Use `<leader>vj` to open the jump menu (fuzzy find symbols in file).
-- 3. If symbols are missing, check if Treesitter is installed for the filetype.

local M = {}
local utils = require('core.utils')

local loaded = false

-- [[ THE JIT PROXY ]]
local function bootstrap_aerial()
	if loaded then return true end

	local ok, err = pcall(function()
		require('mini.deps').add('stevearc/aerial.nvim')

		require('aerial').setup({
			-- Backends prioritized for speed
			backends = { "treesitter", "lsp", "markdown", "man" },

			layout = {
				max_width = { 40, 0.2 },
				min_width = 30,
				default_direction = "right",
				placement = "window",
			},

			-- Visual Feedback
			show_guides = true,
			highlight_on_hover = true,

			-- INTEGRATION: mini.icons mapping
			-- We don't call .get() directly; we let aerial use the
			-- global NerdFont icons or we'd have to map them individually.
			-- If mini.icons is mocked as web-devicons, this works automatically.
			nerd_font = true,

			-- Navigation Sync
			manage_folds = false,
			link_cursor_to_symbol = true,

			-- Close aerial when it's the last window open
			close_on_select = false,
		})
	end)

	if not ok then
		utils.soft_notify('Aerial failed to initialize: ' .. err, vim.log.levels.ERROR)
		return false
	end

	loaded = true
	return true
end

-- Keymaps moved to lua/core/plugin-keymaps.lua under View (<leader>v) section.

M.bootstrap = bootstrap_aerial

return M
