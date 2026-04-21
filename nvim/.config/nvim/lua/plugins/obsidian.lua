-- =============================================================================
-- [ OBSIDIAN.NVIM ]
-- Configuration for Obsidian note-taking integration.
-- =============================================================================

local M = {}

Config.safe_require("obsidian").setup({
	workspaces = {
		{
			name = "vault",
			path = "~/Documents/Obsidian",
		},
	},
	-- Doesn't work with render-markdown for render-markdown
	ui = { enabled = false },
	-- Disable legacy commands warning
	legacy_commands = false,
})

return M
