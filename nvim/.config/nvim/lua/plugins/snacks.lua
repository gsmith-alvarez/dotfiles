-- =============================================================================
-- [ SNACKS.NVIM ]
-- Configuration for the snacks.nvim utility collection.
-- =============================================================================

local M = {}

-- 1. [ INITIALIZATION ]
-- Load snacks immediately to ensure global helpers and 'get' functions
-- are available for early-attach events (LSP, BufRead).
local snacks = Config.safe_require("snacks")

-- [[ GLOBAL DEBUG HELPERS ]]
_G.dd = function(...)
	snacks.debug.inspect(...)
end
_G.bt = function()
	snacks.debug.backtrace()
end

---@diagnostic disable-next-line: duplicate-set-field
vim._print = function(...)
	_G.dd(...)
end

-- 2. [ CONSOLIDATED SETUP ]
-- Snacks is highly modular and lazy-loads its tools by default.
-- We call setup once here to initialize the core config table.
snacks.setup {
	-- A. UI & VISUALS (Logic runs on buffer events)
	bigfile = { enabled = true },
	indent = {
		enabled = true,
		char = "│",
		scope = {
			enabled = true,
			char = "│",
			edge = true,
		},
		chunk = {
			enabled = true,
		},
	},
	scroll = { enabled = true },
	statuscolumn = { enabled = true },
	notifier = {
		enabled = true,
		timeout = 3000,
	},
	words = { enabled = true },
	quickfile = { enabled = true },

	-- B. TOOLS & UTILITIES (Lazy-loaded on demand)
	animate = { enabled = true },
	bufdelete = { enabled = true },
	dashboard = { enabled = false },
	debug = { enabled = true },
	dim = { enabled = true },
	gh = { enabled = true },
	git = { enabled = true },
	image = { enabled = true },
	lazygit = { enabled = true },
	picker = {
		enabled = true,
		layout = "custom",
		layouts = {
			custom = {
				layout = {
					box = "vertical",
					backdrop = false,
					row = -1,
					width = 0,
					height = 0.4,
					border = "none",
					title = " {title} {live} {flags}",
					title_pos = "left",
					{
						box = "horizontal",
						{ win = "list", border = "rounded" },
						{ win = "preview", title = "{preview}", width = 0.6, border = "rounded" },
					},
					{ win = "input", height = 1, border = "none" },
				},
			},
		},
	},
	scope = { enabled = true },
	terminal = {
		win = {
			border = "rounded",
			winblend = 3,
			keys = { q = "hide" },
			style = {
				statusline = " %{fnamemodify(getcwd(), ':~')} ",
			},
		},
	},
	scratch = { enabled = true },
	toggle = { enabled = true },
	zen = { enabled = true },
}

-- 3. [ TOGGLES ]
-- We define these here using the Snacks Toggle API.
-- These will automatically appear in Which-Key with proper descriptions.
local mini = Config.safe_require "plugins.mini"
mini.later(function()
	Snacks.toggle.option("spell", { name = "Spelling" }):map "<leader>us"
	Snacks.toggle.option("wrap", { name = "Wrap" }):map "<leader>uw"
	Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map "<leader>uL"
	Snacks.toggle.diagnostics():map "<leader>ud"
	Snacks.toggle.line_number():map "<leader>ul"
	Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map "<leader>uc"
	Snacks.toggle.treesitter():map "<leader>uT"
	Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map "<leader>ub"
	Snacks.toggle.inlay_hints():map "<leader>uh"
	Snacks.toggle.indent():map "<leader>ug"
	Snacks.toggle.dim():map "<leader>uD"
	Snacks.toggle.zen():map "<leader>uz"
	Snacks.toggle.zoom():map "<leader>uZ"
end)

return M
