-- mini.nvim

local M = {}

-- 1. Mini.misc & pacer setup
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

vim.schedule(function()
	if package.loaded["mini.misc"] then
		misc.setup_auto_root()
	end
end)

-- 2. Immediate setup (M.now)
M.now(function()
	-- A. COLORSCHEME (catppuccin)
	local catppuccin = Config.safe_require("catppuccin")
	if catppuccin then
		catppuccin.setup({
			color_overrides = {
				mocha = {
					base = "#230817",
				},
			},
		})
		vim.cmd.colorscheme("catppuccin")
	end

	-- Custom highlight overrides for MiniDiff
	vim.api.nvim_set_hl(0, "MiniDiffOverAdd", { link = "DiffAdd" })
	vim.api.nvim_set_hl(0, "MiniDiffOverDelete", { link = "DiffDelete" })
	vim.api.nvim_set_hl(0, "MiniDiffOverChange", { link = "DiffChange" })
	vim.api.nvim_set_hl(0, "MiniDiffOverContext", { link = "DiffText" })

	-- B. ICONS (mini.icons)
	local icons = Config.safe_require("mini.icons")
	icons.setup()
	icons.mock_nvim_web_devicons()

	-- C. UI COMPONENTS
	Config.safe_require("mini.tabline").setup()
	Config.safe_require("mini.statusline").setup()
end)

-- 3. Deferred setup (M.later)
M.later(function()
	-- A. NAVIGATION & EDITING
	Config.safe_require("mini.files").setup()
	Config.safe_require("mini.input").setup()
	Config.safe_require("mini.jump2d").setup({
		mappings = {
			start_jumping = "<S-CR>",
		},
	})
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
	hipatterns.setup({
		highlighters = {
			fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
			hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
			wip = { pattern = "%f[%w]()WIP()%f[%W]", group = "MiniHipatternsHack" },
			todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
			note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
			info = { pattern = "%f[%w]()INFO()%f[%W]", group = "MiniHipatternsNote" },

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
			i = ai_extra.indent(),
			b = ai_extra.buffer(),
			d = ai_extra.diagnostic(),
			n = ai_extra.number(),
		},
	})
end)

return M
