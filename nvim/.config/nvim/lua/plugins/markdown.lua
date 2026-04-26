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
		-- blink sources declared manually in plugins/completion.lua
		completion = { blink = false },
		attachments = {
			---@param path obsidian.Path
			img_text_func = function(path)
				local name = vim.fs.basename(tostring(path))
				local encoded_name = require("obsidian.util").urlencode(name)
				return string.format("![%s](%s)", name, encoded_name)
			end,
		},
	})

	-- mini.later() runs after VimEnter, so BufEnter has already fired for any
	-- files opened at startup. Manually start the obsidian LSP for those buffers
	-- so they don't miss the BufEnter autocmd obsidian just registered.
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_is_valid(buf) then
			local ft = vim.bo[buf].filetype
			if ft == "markdown" or ft == "quarto" then
				require("obsidian.lsp").start(buf)
			end
		end
	end

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
