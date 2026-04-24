-- =============================================================================
-- [ MARKDOWN ]
-- render-markdown.nvim — in-buffer markdown rendering.
-- obsidian.nvim        — Obsidian vault integration.
-- Note: obsidian's built-in UI is disabled in favour of render-markdown.
-- =============================================================================

local M = {}

local mini = Config.safe_require("plugins.mini")

-- -----------------------------------------------------------------------------
-- 1. [ RENDER-MARKDOWN ]
-- Must be set up before obsidian to ensure its rendering hooks are in place.
-- -----------------------------------------------------------------------------
mini.later(function()
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
		picker = {
			name = "snacks",
		},
		completion = { blink = true },
		attachments = {
			---@param path obsidian.Path
			img_text_func = function(path)
				local name = vim.fs.basename(tostring(path))
				local encoded_name = require("obsidian.util").urlencode(name)
				return string.format("![%s](%s)", name, encoded_name)
			end,
		},
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
end)

return M
