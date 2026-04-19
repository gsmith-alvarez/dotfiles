-- ============================================================================= [ BLINK.CMP ]
-- Configuration for the high-performance completion engine.
-- =============================================================================

local M = {}

local mini = require('plugins.mini')

mini.later(function()
	require('blink.cmp').setup({
		keymap = {
			preset = 'super-tab',
			['<C-l>'] = { 'snippet_forward', 'accept', 'fallback' },
			['<C-h>'] = { 'snippet_backward', 'fallback' },
			['<C-j>'] = { 'select_next', 'fallback' },
			['<C-k>'] = { 'select_prev', 'fallback' },
		},
		completion = {
			documentation = { auto_show = false, auto_show_delay_ms = 200 },
			ghost_text = { enabled = false },
		},
	})
end)

-- Note: Automated build script (Cargo) is in plugin/02-pack.lua.

return M
