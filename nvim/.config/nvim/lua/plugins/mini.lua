-- =============================================================================
-- [ MINI.NVIM ]
-- Configuration for various modular plugins from the 'mini.nvim' collection.
-- =============================================================================

local M = {}

-- [ 1. MINI.MISC & PACER SETUP ]
-- 'mini.misc' provides the `safely` function used for deferred loading.
local misc = Config.safe_require("mini.misc")

local function pacer_logic(mode, f)
	if package.loaded["mini.misc"] then
		misc.safely(mode, f)
	else
		f()
	end
end

--- Run a callback immediately through mini.misc.safely when available.
--- @param f function Callback to execute.
M.now = function(f)
	pacer_logic("now", f)
end
--- Run a callback later through mini.misc.safely when available.
--- @param f function Callback to execute.
M.later = function(f)
	pacer_logic("later", f)
end
M.now_if_args = vim.fn.argc(-1) > 0 and M.now or M.later
--- Run a callback on an editor event using mini.misc pacing.
--- @param ev string Neovim event name.
--- @param f function Callback to execute.
M.on_event = function(ev, f)
	pacer_logic("event:" .. ev, f)
end
--- Run a callback on a filetype using mini.misc pacing.
--- @param ft string Filetype name.
--- @param f function Callback to execute.
M.on_filetype = function(ft, f)
	pacer_logic("filetype:" .. ft, f)
end

-- Deferred to avoid conflicts with :restart process handover
vim.schedule(function()
	if package.loaded["mini.misc"] then
		misc.setup_auto_root()
	end
end)

-- [ 2. IMMEDIATE SETUP (M.now) ]
-- Critical UI components and theme that should be loaded during startup.
M.now(function()
	-- A. COLORSCHEME (mini.base16)
	Config.safe_require("mini.base16").setup({
		palette = {
			base00 = "#1e1e2e", -- mantle
			base01 = "#181825", -- crust
			base02 = "#313244", -- surface0
			base03 = "#45475a", -- surface1
			base04 = "#585b70", -- surface2
			base05 = "#cdd6f4", -- text
			base06 = "#f5e0dc", -- rosewater
			base07 = "#b4befe", -- lavender
			base08 = "#f38ba8", -- red
			base09 = "#fab387", -- peach
			base0A = "#f9e2af", -- yellow
			base0B = "#a6e3a1", -- green
			base0C = "#94e2d5", -- teal
			base0D = "#89b4fa", -- blue
			base0E = "#cba6f7", -- mauve
			base0F = "#f2cdcd", -- flamingo
		},
		use_cterm = nil,
		plugins = { default = true },
	})

	-- B. ICONS (mini.icons)
	local icons = Config.safe_require("mini.icons")
	icons.setup()
	icons.mock_nvim_web_devicons()

	-- C. UI COMPONENTS
	Config.safe_require("mini.tabline").setup()
	Config.safe_require("mini.statusline").setup()
end)

-- [ 3. DEFERRED SETUP (M.later) ]
-- Non-critical tools and editing enhancements loaded after startup.
M.later(function()
	-- A. NAVIGATION & EDITING
	Config.safe_require("mini.files").setup()
	Config.safe_require("mini.jump2d").setup()
	Config.safe_require("mini.jump").setup()
	Config.safe_require("mini.splitjoin").setup()
	Config.safe_require("mini.comment").setup()
	Config.safe_require("mini.operators").setup()
	Config.safe_require("mini.pairs").setup()
	Config.safe_require("mini.align").setup()
	Config.safe_require("mini.git").setup()
	Config.safe_require("mini.trailspace").setup()
	Config.safe_require("mini.visits").setup()
	Config.safe_require("mini.surround").setup({
		mappings = {
			add = "gsa", -- Add surrounding in Normal and Visual modes
			delete = "gsd", -- Delete surrounding
			find = "gsf", -- Find surrounding (to the right)
			find_left = "gsF", -- Find surrounding (to the left)
			highlight = "gsh", -- Highlight surrounding
			replace = "gsr", -- Replace surrounding
			update_n_lines = "gsn", -- Update `n_lines`

			suffix_last = "l", -- Suffix to search with "prev" method
			suffix_next = "n", -- Suffix to search with "next" method
		},
		highlight_duration = 500,
	})
	Config.safe_require("mini.bufremove").setup()
	Config.safe_require("mini.map").setup()
	Config.safe_require("mini.diff").setup()
	Config.safe_require("mini.move").setup()
	Config.safe_require("mini.bracketed").setup()
	Config.safe_require("mini.extra").setup()
	Config.safe_require("mini.sessions").setup({
		autoread = true,
		autowrite = true,
		directory = vim.fn.stdpath("data") .. "/sessions",
	})

	-- C. HIGHLIGHTING (mini.hipatterns)
	local hipatterns = Config.safe_require("mini.hipatterns")
	local hi_extra = require("mini.extra").gen_highlighter
	hipatterns.setup({
		highlighters = {
			-- Highlight standalone 'FIXME', 'TODO', 'NOTE'
			fixme = hi_extra.words({ "FIXME", "WIP" }, "MiniHypatternsFixme"),
			todo = hi_extra.words({ "TODO" }, "MiniHypatternsTodo"),
			note = hi_extra.words({ "NOTE", "INFO" }, "MiniHypatternsNote"),

			-- Highlight hex colors
			hex_color = hipatterns.gen_highlighter.hex_color(),
		},
	})

	-- B. ENHANCED TEXT OBJECTS (mini.ai)
	local ai = Config.safe_require("mini.ai")
	local ai_extra = require("mini.extra").gen_ai_spec
	ai.setup({
		n_lines = 500,
		custom_textobjects = {
			f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
			c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
			o = ai.gen_spec.treesitter({
				a = { "@conditional.outer", "@loop.outer" },
				i = { "@conditional.inner", "@loop.inner" },
			}),
			-- From mini.extra
			i = ai_extra.indent(),
			b = ai_extra.buffer(),
			d = ai_extra.diagnostic(),
			n = ai_extra.number(),
		},
	})
end)

return M
