-- [[ PLUGIN DOMAIN ORCHESTRATOR: lua/plugins/init.lua ]]
-- =============================================================================
-- This is the "Engine Room" of your plugin ecosystem.
-- 
-- Architecture: "Asymmetric Event-Driven Loader"
-- -----------------------------------------------------------------------------
-- This config uses `mini.deps` to load plugins in three distinct waves:
-- 1. NOW: Critical UI elements (colors) and notifications.
-- 2. DASHBOARD: If you open Neovim with no file, we load the dashboard FIRST.
-- 3. LATER: Non-essential features (editing, LSP, workflow, etc.) are deferred
--    to the background "idle loop" to keep the editor responsive.
-- =============================================================================

local M = {}
local utils = require 'core.utils'

-- [[ THE SAFE LOAD WRAPPER ]]
local function safe_load(domain)
	local ok, mod_or_err = pcall(require, domain)
	if ok and type(mod_or_err) == 'table' and type(mod_or_err.setup) == 'function' then
		local setup_ok, setup_err = pcall(mod_or_err.setup)
		if not setup_ok then
			utils.soft_notify(string.format('DOMAIN SETUP FAILURE: [%s]\n%s', domain, setup_err),
				vim.log.levels.ERROR)
		end
	elseif not ok then
		utils.soft_notify(string.format('DOMAIN LOAD FAILURE: [%s]\n%s', domain, mod_or_err),
			vim.log.levels.ERROR)
	end
end

-- =============================================================================
-- PHASE 1: THE "HOT PATH" (Critical Foundation)
-- =============================================================================
local MiniDeps = require 'mini.deps'

-- Register custom treesitter rules for mise config files.
vim.treesitter.query.add_predicate('is-mise?', function(match, pattern, source)
	local bufname = vim.api.nvim_buf_get_name(source)
	return bufname:match('[/\\]mise%.toml$') ~= nil
	    or bufname:match('[/\\]%.mise%.toml$') ~= nil
end, { force = true })

-- HOT PATH: These are needed for EVERY session immediately.
MiniDeps.now(function()
	MiniDeps.add 'folke/snacks.nvim'
	safe_load 'plugins.core.snacks' -- Notifications and utilities.
	safe_load 'plugins.core.mini'   -- Basic UI framework (icons/tabline).
	
	-- We ONLY load colors synchronously to prevent the "Flash of Unstyled Content".
	local ok, ui = pcall(require, 'plugins.ui')
	if ok and ui.setup_foundation then
		ui.setup_foundation()
	end
end)

-- SCENARIO-BASED DEFERRAL
if vim.fn.argc() > 0 then
	-- You opened a file: Load the rest after a slight delay
	MiniDeps.later(function()
		safe_load 'plugins.ui'          -- Rest of the UI (statusline, etc).
		safe_load 'plugins.searching'   -- Fuzzy finders.
		safe_load 'plugins.lsp'         -- Language Servers.
		safe_load 'plugins.dap'         -- Debugger.
	end)
elseif #vim.api.nvim_list_uis() > 0 then
	-- You opened the dashboard: Load UI elements needed for starter
	MiniDeps.now(function()
		safe_load 'plugins.workflow.persistence' -- Session management.
		-- We load the rest of UI (which includes starter)
		safe_load 'plugins.ui'
	end)
	
	-- Defer heavy stuff even more
	MiniDeps.later(function()
		safe_load 'plugins.searching'
		safe_load 'plugins.lsp'
		safe_load 'plugins.dap'
		vim.api.nvim_exec_autocmds('FileType', { buffer = 0, modeline = false })
	end)
end

-- =============================================================================
-- PHASE 2: BACKGROUND DEFERRAL (The Idle Queue)
-- =============================================================================
if #vim.api.nvim_list_uis() > 0 then
	MiniDeps.later(function()
		-- Navigation tools
		safe_load 'plugins.navigation.history'
		safe_load 'plugins.navigation.smart-splits'
		safe_load 'plugins.navigation.mini-files'

		-- Git integration
		safe_load 'plugins.version_control'

		-- General editing and workflow enhancements
		local scheduled_domains = {
			'plugins.editing',
			'plugins.workflow',
		}
		for _, domain in ipairs(scheduled_domains) do
			safe_load(domain)
		end
	end)
end

return M
