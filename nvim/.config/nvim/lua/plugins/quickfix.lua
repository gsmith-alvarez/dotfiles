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
		-- Show 2 lines of context above/below each quickfix entry.
		-- Set to 0 to disable.
		opts = {
			number = true,
			relativenumber = false,
			signcolumn = "auto",
		},
		-- Use rounded borders on the floating preview window.
		max_filename_width = function()
			return math.floor(math.min(95, vim.o.columns / 2))
		end,
		-- Trim leading whitespace from context lines.
		trim_leading_whitespace = "common",
		-- Keep the quickfix header (filename, line, col).
		header_length = 3,
		keys = {
			-- Toggle context lines with >  / <
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
		auto_resize_height = true,
		preview = {
			auto_preview = true,
			win_height = 15,
			win_vheight = 15,
			delay_syntax = 80,
			border = "rounded",
			show_title = true,
			show_scroll_bar = false,
		},
		func_map = {
			-- Keep navigation intuitive alongside your existing keymaps.
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
					-- Open in split when pressing <C-x> in fzf mode.
					["ctrl-x"] = "split",
					["ctrl-v"] = "vsplit",
					["ctrl-t"] = "tab drop",
				},
				extra_opts = { "--bind", "ctrl-o:toggle-all", "--prompt", "> " },
			},
		},
	})
end)

return M
