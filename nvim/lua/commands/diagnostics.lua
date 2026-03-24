-- [[ DIAGNOSTIC SUBSYSTEM ]]
-- Domain: UI / Code Intelligence
-- Location: lua/commands/diagnostics.lua
--
-- PHILOSOPHY: Non-Intrusive Guidance
-- This module manages how Neovim communicates code intelligence errors 
-- (from LSP or linters) to the user. It prioritizes clarity over clutter 
-- by using custom icons, sorting by severity, and using a smart hover 
-- mechanism that only shows errors when your cursor is idle.
--
-- MAINTENANCE TIPS:
-- 1. To change diagnostic icons, see `lua/core/icons.lua`.
-- 2. If diagnostics are too noisy, increase `vim.opt.updatetime` below.
-- 3. Use `:LspRestart` if diagnostics seem "stale" or out of sync.

local M = {}
local icons = require('core.icons').diagnostics

-- [[ Diagnostic Signs + Virtual Text ]]
-- Why: We configure the native diagnostic API to be more descriptive.
-- `update_in_insert = false` ensures your screen doesn't flicker while typing.
-- `severity_sort = true` ensures that Errors always appear above Warnings.
vim.diagnostic.config {
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = icons.Error,
			[vim.diagnostic.severity.WARN] = icons.Warn,
			[vim.diagnostic.severity.HINT] = icons.Hint,
			[vim.diagnostic.severity.INFO] = icons.Info,
		},
	},
	virtual_text = {
		spacing = 4,
		source = 'if_many',
		prefix = function(diagnostic)
			local map = {
				[vim.diagnostic.severity.ERROR] = icons.Error,
				[vim.diagnostic.severity.WARN] = icons.Warn,
				[vim.diagnostic.severity.HINT] = icons.Hint,
				[vim.diagnostic.severity.INFO] = icons.Info,
			}
			-- Remove trailing whitespace from icons for a cleaner look.
			return (map[diagnostic.severity] or '●'):gsub('%s+$', '')
		end,
	},
	float = { border = 'rounded', source = 'if_many' },
}

-- [[ Diagnostic Hover ]]
-- Why: Instead of manually pressing a key to see an error message, this 
-- autocmd automatically opens a floating window with the error description 
-- whenever you pause your cursor on a line with a diagnostic.
local diag_group = vim.api.nvim_create_augroup('DiagnosticHover', { clear = true })
vim.api.nvim_create_autocmd('CursorHold', {
	group = diag_group,
	callback = function()
		-- Avoid opening the hover if there's already a floating window 
		-- (like a completion menu) open.
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			local config = vim.api.nvim_win_get_config(win)
			if config.relative ~= '' then
				return
			end
		end

		local line = vim.api.nvim_win_get_cursor(0)[1] - 1
		local bufnr = vim.api.nvim_get_current_buf()
		local diagnostics = vim.diagnostic.get(bufnr, { lnum = line })
		if #diagnostics > 0 then
			vim.diagnostic.open_float(nil, { focusable = false, scope = 'cursor' })
		end
	end,
})

-- Why: updatetime (in ms) controls how long Neovim waits after you stop 
-- typing before it triggers the 'CursorHold' event above.
vim.opt.updatetime = 500

M.commands = {
	-- Placeholders for future diagnostic-related commands.
}

return M
