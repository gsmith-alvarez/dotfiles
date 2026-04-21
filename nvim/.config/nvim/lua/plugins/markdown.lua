-- =============================================================================
-- [ MARKDOWN ]
-- render-markdown.nvim — in-buffer markdown rendering.
-- obsidian.nvim        — Obsidian vault integration.
-- Note: obsidian's built-in UI is disabled in favour of render-markdown.
-- =============================================================================

local M = {}

-- -----------------------------------------------------------------------------
-- 1. [ RENDER-MARKDOWN ]
-- Must be set up before obsidian to ensure its rendering hooks are in place.
-- -----------------------------------------------------------------------------
Config.safe_require("render-markdown").setup({
	completions = { lsp = { enabled = true } },
	latex = { enabled = false },
	headings = {
		sign = false,
		icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
	},
})

-- -----------------------------------------------------------------------------
-- 2. [ OBSIDIAN.NVIM ]
-- -----------------------------------------------------------------------------
Config.safe_require("obsidian").setup({
	workspaces = {
		{
			name = "vault",
			path = "~/Documents/Obsidian",
		},
	},
	-- Disabled in favour of render-markdown.nvim
	ui = { enabled = false },
	legacy_commands = false,
})

Config.safe_require("autolist").setup({
	lists = {
		markdown = {
			">%s*[-+*]",
			">%s*%d+[.)]",
			">%s*%a[.)]",
			">%s*%u+[.)]",
			">",
			"[-+*]",
			"%d+[.)]",
			"%a[.)]",
			"%u+[.)]",
		},
	},
})

return M
