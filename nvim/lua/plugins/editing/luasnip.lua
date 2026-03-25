-- [[ LUASNIP: Snippet Engine ]]
-- Purpose: Provide a powerful, Lua-native snippet engine with custom snippet support.
-- Domain:  Editing / Text Manipulation
-- Architecture: Deferred Bootstrapper (Phased Boot)
--
-- PHILOSOPHY: Own Your Snippets
-- While friendly-snippets (VSCode format) gives you a solid baseline,
-- LuaSnip lets you write snippets in Lua with full programmatic control:
-- dynamic nodes, lambdas, choice nodes, and regex triggers.
-- Custom snippets live in lua/snippets/ and are hot-reloadable.
--
-- KEYMAPS:
--   <C-l>  Jump to the NEXT node       (insert + select mode)
--   <C-h>  Jump to the PREVIOUS node   (insert + select mode)
--   <C-e>  Cycle choice / exit snippet  (insert + select mode)
--   These intentionally share keys with blink.cmp's accept/backward bindings;
--   LuaSnip only activates them when INSIDE an active snippet.
--
-- MAINTENANCE TIPS:
-- 1. Add custom snippets in lua/snippets/<filetype>.lua (or all.lua for global).
-- 2. Run :LuaSnipListAvailable to see which snippets are loaded.
-- 3. history=true lets you jump back into previously exited snippets.

local M = {}
local utils = require 'core.utils'

M.setup = function()
	local ok, err = pcall(function()
		local MiniDeps = require 'mini.deps'

		-- 1. Install LuaSnip
		MiniDeps.add 'L3MON4D3/LuaSnip'

		local luasnip = require 'luasnip'

		-- 2. Configure the engine
		luasnip.config.set_config {
			-- Allow jumping back into a snippet after you've exited it
			history = true,
			-- Update dynamic nodes as you type (e.g. mirrored placeholder nodes)
			updateevents = 'TextChanged,TextChangedI',
			-- Enable autosnippets (trigger without completion menu)
			enable_autosnippets = true,
		}

		-- 3. Load snippet sources
		-- VSCode-format snippets from friendly-snippets (managed by blink.cmp's add call)
		require('luasnip.loaders.from_vscode').lazy_load()

		-- Lua-format snippets from our custom directory
		require('luasnip.loaders.from_lua').lazy_load {
			paths = vim.fn.stdpath('config') .. '/lua/snippets',
		}

		-- 4. Keymaps: node navigation (only active inside a snippet)
		vim.keymap.set({ 'i', 's' }, '<C-l>', function()
			if luasnip.locally_jumpable(1) then
				luasnip.jump(1)
			end
		end, { silent = true, desc = 'LuaSnip: jump to next node' })

		vim.keymap.set({ 'i', 's' }, '<C-h>', function()
			if luasnip.locally_jumpable(-1) then
				luasnip.jump(-1)
			end
		end, { silent = true, desc = 'LuaSnip: jump to previous node' })

		-- Cycle through choice nodes, or exit the current snippet
		vim.keymap.set({ 'i', 's' }, '<C-e>', function()
			if luasnip.choice_active() then
				luasnip.change_choice(1)
			else
				luasnip.unlink_current()
			end
		end, { silent = true, desc = 'LuaSnip: cycle choice / exit snippet' })
	end)

	if not ok then
		utils.soft_notify('LuaSnip failed to initialize: ' .. err, vim.log.levels.ERROR)
	end
end

return M
