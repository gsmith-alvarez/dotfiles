-- [[ DIAGNOSTIC SUBSYSTEM ]]
-- Manages how Neovim communicates code intelligence errors to the user.

local M = {}
local icons = require('core.icons').diagnostics

-- [[ Diagnostic Signs + Virtual Text ]]
vim.diagnostic.config {
	underline      = true,
	update_in_insert = false,
	severity_sort  = true,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = icons.Error,
			[vim.diagnostic.severity.WARN]  = icons.Warn,
			[vim.diagnostic.severity.HINT]  = icons.Hint,
			[vim.diagnostic.severity.INFO]  = icons.Info,
		},
	},
	virtual_text = {
		spacing = 4,
		source  = 'if_many',
		prefix  = function(diagnostic)
			local map = {
				[vim.diagnostic.severity.ERROR] = icons.Error,
				[vim.diagnostic.severity.WARN]  = icons.Warn,
				[vim.diagnostic.severity.HINT]  = icons.Hint,
				[vim.diagnostic.severity.INFO]  = icons.Info,
			}
			return (map[diagnostic.severity] or '●'):gsub('%s+$', '')
		end,
	},
	float = { border = 'rounded', source = 'if_many' },
}

-- [[ Diagnostic Hover ]]
-- Triggers a floating window containing the full error message when the cursor idles.
local diag_group = vim.api.nvim_create_augroup("DiagnosticHover", { clear = true })

vim.api.nvim_create_autocmd("CursorHold", {
	group = diag_group,
	callback = function()
		-- 1. Performance Guard: Only attempt if no other floating windows are active
		-- This prevents the diagnostic float from overwriting LSP hover or signature help.
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			local config = vim.api.nvim_win_get_config(win)
			if config.relative ~= "" then return end
		end

		-- 2. Scope Guard: Only open if the line actually has diagnostics
		local line = vim.api.nvim_win_get_cursor(0)[1] - 1
		local bufnr = vim.api.nvim_get_current_buf()
		local diagnostics = vim.diagnostic.get(bufnr, { lnum = line })
		if #diagnostics > 0 then
			vim.diagnostic.open_float(nil, { focusable = false, scope = "cursor" })
		end
	end,
})

-- CRITICAL PERFORMANCE TUNING: `updatetime`
-- This controls the delay (in milliseconds) before the `CursorHold` event fires.
-- The Neovim default is an agonizing 4000ms. Lowering it to 500ms makes error
-- discovery feel instantaneous. (Note: This also controls how often Neovim
-- writes to the swap file, but 500ms is a highly stable modern standard).
vim.opt.updatetime = 500

-- [[ Diagnostic Discovery Toggles ]]
-- Diagnostics can create intense visual noise. These toggles allow you to
-- surgically mute the LSP when you are in the flow state, then turn it back
-- on for the error-correction phase.

return M
