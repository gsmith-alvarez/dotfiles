-- [[ SYSTEM DEPENDENCY BOOTSTRAPPER ]]
-- Location: lua/core/deps.lua
--
-- STRATEGY: Imperative Package Management
-- 
-- PHILOSOPHY: The Zero-Lag Installer
-- Unlike declarative managers (like Lazy.nvim), mini.deps uses an imperative
-- approach. This gives us full control over the load order and ensures that
-- no expensive "scanning" happens during the critical startup path.
--
-- MAINTENANCE TIPS:
-- 1. If `mini.deps` is missing, this script will automatically `git clone` it.
-- 2. To update plugins, run `:DepsUpdate`.
-- 3. To clean unused plugins, run `:DepsClean`.
-- =============================================================================

local M = {}
local utils = require 'core.utils'

-- 1. Path Definition
-- We store plugins in the standard Neovim data directory.
local deps_path = vim.fn.stdpath 'data' .. '/mini.deps'

-- 2. Automated Installation (The Bootstrap)
-- If the manager itself is missing, we fetch it immediately.
if not vim.uv.fs_stat(deps_path) then
	vim.notify('Installing mini.deps...', vim.log.levels.INFO)
	vim.fn.system { 'git', 'clone', '--filter=blob:none', 'https://github.com/echasnovski/mini.deps', deps_path }
end

-- 3. Runtime Integration
vim.opt.rtp:prepend(deps_path)

-- [[ PROFILER INJECTION (Conditional) ]]
-- Only runs if the Neovim command is prefixed with PROFILE=1
-- Example: `PROFILE=1 nvim`
if vim.env.PROFILE then
	local snacks_path = deps_path .. '/pack/deps/opt/snacks.nvim'
	if vim.uv.fs_stat(snacks_path) then
		vim.opt.rtp:prepend(snacks_path)
		local ok_snacks, snacks_profiler = pcall(require, 'snacks.profiler')
		if ok_snacks then
			snacks_profiler.startup()
		end
	end
end

-- 4. Manager Initialization
local ok, mini_deps = pcall(require, 'mini.deps')
if ok then
	mini_deps.setup { path = { package = deps_path } }
	-- We expose MiniDeps globally so other modules can use it.
	_G.MiniDeps = mini_deps
else
	utils.soft_notify('Failed to load mini.deps!', vim.log.levels.ERROR)
end

return M
