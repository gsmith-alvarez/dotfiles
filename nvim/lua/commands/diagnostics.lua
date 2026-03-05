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

-- [[ Diagnostic Navigation ]]
-- Jump between diagnostics by severity. `float = true` shows the message inline on jump.
local function diag_jump(next, severity)
	return function()
		vim.diagnostic.jump({
			count    = (next and 1 or -1) * vim.v.count1,
			severity = severity and vim.diagnostic.severity[severity] or nil,
			float    = true,
		})
	end
end

-- [[ Diagnostic Navigation & Toggles ]]
-- Keymaps moved to lua/core/plugin-keymaps.lua under Diagnostics section.

-- [[ Diagnostic Hover ]]
-- Triggers a floating window containing the full error message when the cursor idles.
local diag_group = vim.api.nvim_create_augroup("DiagnosticHover", { clear = true })

vim.api.nvim_create_autocmd("CursorHold", {
  group = diag_group,
  callback = function()
    vim.diagnostic.open_float(nil, { focusable = false, scope = "cursor" })
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
