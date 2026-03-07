-- [[ PLUGIN DOMAIN ORCHESTRATOR ]]
-- Location: lua/plugins/init.lua
-- Architecture: Asymmetric Event-Driven Loader
--
-- STRATEGY: Domain-Isolated Execution with Non-Blocking Deferral

local M = {}
local utils = require 'core.utils'

-- Helper to safely load and route errors
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
-- PHASE 1: CONTEXT-AWARE BOOT
-- =============================================================================
local MiniDeps = require 'mini.deps'

if vim.fn.argc() > 0 then
	MiniDeps.now(function()
		-- Ensure snacks is available for early notifications
		MiniDeps.add 'folke/snacks.nvim'
		safe_load 'plugins.core.snacks'

		-- Load core UI/mini modules synchronously to prevent FOUC
		safe_load 'plugins.core.mini'
		safe_load 'plugins.ui'

		-- Sub-Domain Bypass: Searching
		safe_load 'plugins.searching'

		-- Sub-Domain Bypass: LSP (Strict Order: Blink -> Native)
		safe_load 'plugins.lsp'

		safe_load 'plugins.dap'
	end)
elseif #vim.api.nvim_list_uis() > 0 then
	-- Dashboard: load UI immediately, defer LSP
	MiniDeps.now(function()
		MiniDeps.add 'folke/snacks.nvim'
		safe_load 'plugins.core.snacks'
		safe_load 'plugins.core.mini'
		-- Sessions must be set up before starter renders
		safe_load 'plugins.workflow.persistence'
		safe_load 'plugins.ui'

		-- Sub-Domain: Searching
		safe_load 'plugins.searching'
	end)
	MiniDeps.later(function()
		-- Sub-Domain Bypass: LSP (Strict Order: Blink -> Native)
		safe_load 'plugins.lsp'

		safe_load 'plugins.dap'
		-- Re-trigger FileType to ensure LSP and Treesitter attach retroactively
		vim.api.nvim_exec_autocmds('FileType', { buffer = 0, modeline = false })
	end)
else
	-- Headless (e.g., nvim --headless +q)
	MiniDeps.now(function()
		MiniDeps.add 'neovim/nvim-lspconfig'
	end)
end

-- =============================================================================
-- PHASE 2: BACKGROUND DEFERRAL (The Idle Queue)
-- =============================================================================
-- Pushed to the background event loop. These evaluate immediately AFTER Neovim
-- finishes its startup sequence and draws the UI.
if #vim.api.nvim_list_uis() > 0 then
	MiniDeps.later(function()
		-- Sub-Domain Bypass: Navigation
		safe_load 'plugins.navigation.history'
		safe_load 'plugins.navigation.smart-splits'
		safe_load 'plugins.navigation.mini-files'

		-- Sub-Domain Bypass: version_control
		safe_load 'plugins.version_control'

		local scheduled_domains = {
			'plugins.editing',    -- Text Manipulation (Surround, pairs, etc.)
			'plugins.workflow',   -- External TUI / Snacks
			'plugins.notetaking.obsidian', -- Obsidian vault integration (JIT)
		}
		for _, domain in ipairs(scheduled_domains) do
			safe_load(domain)
		end
	end)
end

return M
