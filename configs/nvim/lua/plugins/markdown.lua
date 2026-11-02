-- markdown

local M = {}

local mini = Config.safe_require("plugins.mini")

-- 1. Render-markdown
mini.on_filetype("markdown", function()
	Config.safe_require("render-markdown").setup({
		completions = { lsp = { enabled = true } },
		latex = { enabled = false },
		headings = {
			sign = false,
			icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
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
