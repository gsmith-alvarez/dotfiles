-- [[ INC-RENAME: Incremental LSP Renaming ]]
-- Purpose: Provide live, real-time feedback during LSP symbol renaming.
-- Domain:  Text Manipulation & Refactoring
-- Architecture: Precision JIT Loading (LSP-Guarded)
--
-- PHILOSOPHY: The "Just-in-Time" Specialist
-- We abandon global loading for a highly targeted "Anti-Fragile" approach. 
-- The plugin only wakes up when `<leader>rn` is pressed, AND it first 
-- verifies that an LSP is attached that actually supports renaming. This 
-- prevents useless plugin overhead in plain text or unsupported files.
--
-- MAINTENANCE TIPS:
-- 1. If renaming doesn't start, verify that an LSP is attached and 
--    supports the `renameProvider` capability.
-- 2. This module uses a "bootstrap" pattern to avoid loading until 
--    `<leader>rn` is pressed.

local M = {}
local utils = require('core.utils')

local loaded = false

-- [[ The JIT Engine ]]
local function bootstrap_increname()
	if loaded then return true end

	-- 1. LSP Capability Guard
	-- Do not wake the plugin or download dependencies if the current buffer
	-- has no LSP attached, or if the attached server cannot perform renames.
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	local can_rename = false
	for _, client in ipairs(clients) do
		if client.server_capabilities.renameProvider then
			can_rename = true
			break
		end
	end

	if not can_rename then
		utils.soft_notify('LSP Error: No active language server supports renaming in this buffer.',
			vim.log.levels.WARN)
		return false
	end

	local ok, err = pcall(function()
		require('mini.deps').add('smjonas/inc-rename.nvim')
		require('inc_rename').setup({})
	end)

	if not ok then
		utils.soft_notify('Inc-Rename failed to initialize: ' .. err, vim.log.levels.ERROR)
		return false
	end

	loaded = true
	return true
end

-- Keymap moved to lua/core/plugin-keymaps.lua under Refactor (<leader>rn).

M.rename = function()
	if bootstrap_increname() then
		return ':IncRename ' .. vim.fn.expand('<cword>')
	end
	return ''
end

-- THE CONTRACT: Return the module to satisfy the Editing Orchestrator.
return M
