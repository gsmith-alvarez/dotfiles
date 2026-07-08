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
mini.now(function()
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
		completion = {
			min_chars = 1,
		},
		-- Use note titles as filenames instead of Zettelkasten random numbers
		note_id_func = function(title)
			if title ~= nil then
				-- Remove characters that are illegal in filenames but keep casing and spaces
				return title:gsub("[^%w%s%-]", "")
			else
				-- Fall back to Zettelkasten ID if no title
				return tostring(os.time())
			end
		end,
		-- Disabled in favour of render-markdown.nvim
		ui = { enabled = false },
		legacy_commands = false,
		picker = {
			name = "snacks.picker",
		},
		attachments = {
			---@param path obsidian.Path
			img_text_func = function(path)
				local name = vim.fs.basename(tostring(path))
				local encoded_name = require("obsidian.util").urlencode(name)
				return string.format("![%s](%s)", name, encoded_name)
			end,
		},
		templates = {
			-- Path is relative to the workspace path defined above
			folder = "500-Resources/Templates",
			date_format = "%Y-%m-%d",
			time_format = "%H:%M",
			-- Allow overriding existing variables in the note
			substitutions = {
				today = function()
					return os.date("%Y-%m-%d")
				end,
				yesterday = function()
					return os.date("%Y-%m-%d", os.time() - 86400)
				end,
				tomorrow = function()
					return os.date("%Y-%m-%d", os.time() + 86400)
				end,
			},
		},
	})

	Config.safe_require("autolist").setup({
		lists = {
			markdown = {
				"> >%s*[-+*]",
				"> >%s*%d+[.)]",
				"> >%s*%a[.)]",
				"> >%s*%u+[.)]",
				"> >",
				"[-+*]",
				">%s*[-+*]",
				">%s*%d+[.)]",
				">%s*%a[.)]",
				">%s*%u+[.)]",
				">",
				"%d+[.)]",
				"%a[.)]",
				"%u+[.)]",
			},
		},
	})
end)

return M
