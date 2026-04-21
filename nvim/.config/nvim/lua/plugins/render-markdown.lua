-- =============================================================================
-- [ RENDER-MARKDOWN ]
-- Configuration for enhanced Markdown rendering in the buffer.
-- =============================================================================

local M = {}

Config.safe_require("render-markdown").setup({
	completions = { lsp = { enabled = true } },
	latex = { enabled = false },
	headings = {
		sign = false,
		icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
	},
})

return M
