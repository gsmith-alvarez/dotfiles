-- markdown

local M = {}

local mini = Config.safe_require("plugins.mini")

-- 1. Render-markdown
mini.now(function()
	Config.safe_require("render-markdown").setup({
		completions = { lsp = { enabled = true } },
		latex = { enabled = false },
		headings = {
			sign = false,
			icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
		},
	})

-- 2. Obsidian.nvim
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
		note_id_func = function(title)
			if title ~= nil then
				return title:gsub("[^%w%s%-]", "")
			else
				return tostring(os.time())
			end
		end,
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
			folder = "500-Resources/Templates",
			date_format = "%Y-%m-%d",
			time_format = "%H:%M",
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
