-- =============================================================================
-- [ QUICKFIX ]
-- quicker.nvim  — editable quickfix buffer with context lines.
-- nvim-bqf      — floating preview and fzf-style filtering in quickfix.
-- =============================================================================

local M = {}

local mini = Config.safe_require("plugins.mini")

mini.later(function()
	-- -------------------------------------------------------------------------
	-- 1. [ QUICKER.NVIM ]
	-- Turns the quickfix list into an editable buffer.
	-- Edit entries in-place and save to write changes back to disk.
	-- -------------------------------------------------------------------------
	require("quicker").setup({
		opts = {
			buflisted = false,
			number = false,
			relativenumber = false,
			signcolumn = "auto",
			winfixheight = true,
			wrap = false,
		},
		use_default_opts = true,
		edit = {
			enabled = true,
			autosave = "unmodified",
		},
		constrain_cursor = true,
		highlight = {
			treesitter = true,
			lsp = true,
			load_buffers = false,
		},
		follow = { enabled = false },
		trim_leading_whitespace = "common",
		max_filename_width = function()
			return math.floor(math.min(95, vim.o.columns / 2))
		end,
		header_length = function(type, start_col)
			return vim.o.columns - start_col
		end,
		type_icons = {
			E = "󰅚 ",
			W = "󰀪 ",
			I = " ",
			N = " ",
			H = " ",
		},
		borders = {
			vert = "┃",
			strong_header = "━",
			strong_cross = "╋",
			strong_end = "┫",
			soft_header = "╌",
			soft_cross = "╂",
			soft_end = "┨",
		},
		keys = {
			{
				">",
				function()
					require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
				end,
				desc = "Quickfix: Expand context",
			},
			{
				"<",
				function()
					require("quicker").collapse()
				end,
				desc = "Quickfix: Collapse context",
			},
		},
	})

	-- -------------------------------------------------------------------------
	-- 2. [ NVIM-BQF ]
	-- Adds a floating preview window and fzf-based filtering to quickfix.
	-- Works automatically — just open the quickfix list and use <p> to preview.
	-- -------------------------------------------------------------------------
	require("bqf").setup({
		auto_enable = true,
		magic_window = true,
		auto_resize_height = true,
		preview = {
			auto_preview = true,
			border = "rounded",
			show_title = true,
			show_scroll_bar = false,
			delay_syntax = 50,
			win_height = 15,
			win_vheight = 15,
			winblend = 0,
			wrap = false,
			buf_label = true,
			should_preview_cb = nil,
		},
		func_map = {
			open = "<CR>",
			openc = "o",
			vsplit = "<C-v>",
			split = "<C-x>",
			tab = "t",
			tabb = "T",
			ptogglemode = "z,",
			pscrollup = "<C-u>",
			pscrolldown = "<C-d>",
		},
		filter = {
			fzf = {
				action_for = {
					["ctrl-x"] = "split",
					["ctrl-v"] = "vsplit",
					["ctrl-t"] = "tabedit",
					["ctrl-q"] = "signtoggle",
					["ctrl-c"] = "closeall",
				},
				extra_opts = { "--bind", "ctrl-o:toggle-all" },
			},
		},
	})
end)

return M
