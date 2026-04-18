-- =============================================================================
-- [ PLUGIN MANAGEMENT ]
-- Uses Neovim's native 'vim.pack' system to manage and download plugins.
-- =============================================================================

local M = {}
local u = require('core.utils')

-- 1. [ HELPER FUNCTIONS ]
-- Generates a full GitHub URL for a given repository.
local function host(domain)
	return function(repo)
		return 'https://' .. domain .. '/' .. repo
	end
end

local gh = host('github.com')

local function get_lib_extension()
	local os = jit.os:lower()
	if os == 'mac' or os == 'osx' then
		return '.dylib'
	end
	if os == 'windows' then
		return '.dll'
	end
	return '.so'
end

local function notify_build_failed(name, obj)
	vim.schedule(function()
		vim.notify(
			string.format('%s build failed (code=%d)', name, obj.code),
			vim.log.levels.ERROR,
			{ title = 'plugin/02-pack.lua' }
		)
	end)
end

local function build_blink(path)
	if vim.fn.executable('cargo') ~= 1 then
		vim.notify('cargo not found; skipping blink.cmp build', vim.log.levels.WARN)
		return
	end

	vim.notify('Building blink.cmp in the background...', vim.log.levels.INFO)
	vim.system({ 'cargo', 'build', '--release' }, { cwd = path }, function(obj)
		if obj.code == 0 then
			vim.schedule(function()
				vim.notify('blink.cmp build complete.', vim.log.levels.INFO)
			end)
			return
		end
		notify_build_failed('blink.cmp', obj)
	end)
end

local function build_luasnip(path)
	if vim.fn.executable('make') ~= 1 then
		vim.notify('make not found; skipping LuaSnip build', vim.log.levels.WARN)
		return
	end

	vim.notify('Building LuaSnip (jsregexp) in the background...', vim.log.levels.INFO)
	vim.system({ 'make', 'install_jsregexp' }, { cwd = path }, function(obj)
		local ext = get_lib_extension()
		local lib_dest = path .. '/deps/luasnip-jsregexp' .. ext
		if obj.code == 0 and vim.fn.filereadable(lib_dest) == 1 then
			vim.schedule(function()
				vim.notify('LuaSnip build complete.', vim.log.levels.INFO)
			end)
			return
		end
		notify_build_failed('LuaSnip', obj)
	end)
end

-- 2. [ AUTOMATIC POST-INSTALL/UPDATE HOOKS ]
-- Register hooks before vim.pack.add so install/update events are not missed.
local build_kinds = { 'install', 'update' }

u.on_packchanged('blink.cmp', build_kinds, function(data)
	build_blink(data.path)
end, 'Build blink.cmp')

u.on_packchanged('LuaSnip', build_kinds, function(data)
	build_luasnip(data.path)
end, 'Build LuaSnip')

-- 3. [ PLUGIN SPECIFICATIONS ]
-- Register plugins with the native package manager.
vim.pack.add({
	-- CORE UTILITIES
	gh('echasnovski/mini.nvim'), -- Collection of modular Lua plugins
	gh('echasnovski/mini.icons'), -- Icon provider
	gh('folke/snacks.nvim'), -- Collection of small, high-quality plugins
	gh('folke/which-key.nvim'), -- Keybinding popup and discovery
	gh('romus204/tree-sitter-manager.nvim'), -- Manager for Treesitter parsers
	'https://plugins.ejri.dev/mise.nvim', -- mise (tool manager) integration

	-- SNIPPETS
	gh('L3MON4D3/LuaSnip'), -- Snippet engine
	gh('rafamadriz/friendly-snippets'), -- Predefined snippet collection
	gh('saghen/blink.cmp'), -- High-performance completion engine
})

-- 4. [ SELF-HEALING STARTUP CHECK ]
-- If plugins already exist but binaries are missing, trigger builds once.
local data_site = vim.fn.stdpath('data') .. '/site/pack/core/opt'

local blink_path = data_site .. '/blink.cmp'
local blink_ext = get_lib_extension()
local blink_lib_a = blink_path .. '/target/release/libblink_cmp_fuzzy' .. blink_ext
local blink_lib_b = blink_path .. '/target/release/blink_cmp_fuzzy' .. blink_ext
if vim.fn.isdirectory(blink_path) == 1 and vim.fn.filereadable(blink_lib_a) == 0 and vim.fn.filereadable(blink_lib_b) == 0 then
	build_blink(blink_path)
end

local luasnip_path = data_site .. '/LuaSnip'
local luasnip_lib = luasnip_path .. '/deps/luasnip-jsregexp' .. get_lib_extension()
if vim.fn.isdirectory(luasnip_path) == 1 and vim.fn.filereadable(luasnip_lib) == 0 then
	build_luasnip(luasnip_path)
end

return M
