-- =============================================================================
-- [[ PHASE 0: MICROCODE & FOUNDATION ]]
-- =============================================================================
if vim.loader then
	vim.loader.enable()
end

-- [[ PHASE 0.5: LEGACY PURGE ]]
-- Disable 1990s-era Vim plugins. We use modern, asynchronous Lua alternatives.
local disabled_built_ins = {
	'netrw',
	'netrwPlugin',
	'netrwSettings',
	'netrwFileHandlers',
	'gzip',
	'zip',
	'zipPlugin',
	'tar',
	'tarPlugin',
	'getscript',
	'getscriptPlugin',
	'vimball',
	'vimballPlugin',
	'2html_plugin',
	'logipat',
	'rrhelper',
	'spellfile_plugin',
	'matchit',
	'fzf',
}

for _, plugin in pairs(disabled_built_ins) do
	vim.g['loaded_' .. plugin] = 1
end

-- =============================================================================
-- [[ NEOVIM BOOTSTRAP OS ]]
-- Architecture: Iterative Fault-Tolerant Loader
-- =============================================================================

-- [[ THE ANTI-FRAGILE ENGINE ]]
-- Captures stack traces and schedules notifications for the UI-attach phase.
local function safe_require(module)
	local ok, err = pcall(require, module)
	if not ok then
		vim.schedule(function()
			vim.notify(string.format('[BOOT SEQUENCE FAILURE]\nModule: %s\nError: %s', module, err),
				vim.log.levels.ERROR, { title = 'Init.lua Fault Tolerance' })
		end)
	end
	return ok
end

-- =============================================================================
-- PHASE 1: CORE FOUNDATION
-- =============================================================================
-- We load the reporter, installer, and core logic in a strict dependency order.

-- 1. Reporter: Must load first to log errors from subsequent modules.
require 'core.utils'

-- 2. Core Orchestrator: Loads deps.lua, libs.lua, options, and keymaps
safe_require 'core'

-- 3. Automation Layers: Custom user commands and autocommands
safe_require 'autocmd'
safe_require 'commands'

safe_require 'plugins'
