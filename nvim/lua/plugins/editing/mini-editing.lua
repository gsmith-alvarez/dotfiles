-- [[ MINI.NVIM: Editing Enhancements ]]
-- Domain: Editing
-- Deferred via MiniDeps.later — runs after the initial render.

local M = {}

M.setup = function()
	require('mini.deps').later(function()
		require('mini.ai').setup { n_lines = 500 }
		require('mini.move').setup {
			mappings = {
				left = '<M-h>', right = '<M-l>', down = '<M-j>', up = '<M-k>',
				line_left = '', line_right = '', line_down = '', line_up = '',
			},
			options = { reindent_linewise = true },
		}
		require('mini.surround').setup {
			mappings = {
				add = 'gza', delete = 'gzd', find = 'gzf', find_left = 'gzF',
				highlight = 'gzh', replace = 'gzr', update_n_lines = 'gzn',
				suffix_last = '', suffix_next = '',
			},
			n_lines = 50,
			search_method = 'cover_or_next',
		}
		require('mini.comment').setup {
			mappings = {
				comment = 'gc',
				comment_line = 'gcc',
				comment_visual = 'gc',
				textobject = 'gc',
			},
		}
		-- gco / gcO keymaps moved to lua/core/plugin-keymaps.lua (Code section)
		require('mini.indentscope').setup { symbol = '│' }
		require('mini.pairs').setup {
			modes = { insert = true, command = false, terminal = false },
			mappings = {},
		}
		require('mini.jump').setup()
		require('mini.splitjoin').setup()
		require('mini.align').setup()



		-- TabOut: press <Tab> to jump past the next closing bracket/quote
		local tabout_chars = { ')', ']', '}', "'", '"', '`', '>', ';', ',' }
		vim.keymap.set('i', '<Tab>', function()
			local line = vim.api.nvim_get_current_line()
			local col  = vim.api.nvim_win_get_cursor(0)[2] -- 0-indexed
			local after = line:sub(col + 1)                -- char directly under cursor
			for _, ch in ipairs(tabout_chars) do
				if after:sub(1, 1) == ch then
					return '<Right>'
				end
			end
			return '<Tab>'
		end, { expr = true, silent = true, desc = 'TabOut: jump past closing char or insert tab' })

		local hipatterns = require 'mini.hipatterns'
		hipatterns.setup {
			highlighters = {
				fixme    = { pattern = '%f[%w]()FIXME()%f[%W]',  group = 'MiniHipatternsFixme' },
				hack     = { pattern = '%f[%w]()HACK()%f[%W]',   group = 'MiniHipatternsHack' },
				todo     = { pattern = '%f[%w]()TODO()%f[%W]',   group = 'MiniHipatternsTodo' },
				note     = { pattern = '%f[%w]()NOTE()%f[%W]',   group = 'MiniHipatternsNote' },
				hex_color = hipatterns.gen_highlighter.hex_color(),
			},
		}

		-- [[ MINI.JUMP2D: Two-keystroke anywhere-on-screen jumping ]]
		-- `<CR>` → label all word starts → press label to jump
		-- Works in operator-pending mode: `d<CR>{label}` deletes to that word
		require('mini.jump2d').setup {
			spotter = require('mini.jump2d').gen_spotter.pattern('%S+'),
			labels = 'asdfjklghweryuiopzxcvbnmqt',
			view = { dim = true, n_steps_ahead = 2 },
			mappings = { start_jumping = '' }, -- managed manually below
			allowed_lines = { blank = false, fold = false },
		}
		-- <CR> jumps in normal/visual/op-pending; quickfix buffers keep default <CR>
		vim.keymap.set({ 'n', 'x', 'o' }, '<CR>', function()
			if vim.bo.filetype == 'qf' or vim.bo.buftype == 'quickfix' then
				vim.api.nvim_feedkeys(vim.keycode('<CR>'), 'n', false)
				return
			end
			require('mini.jump2d').start(require('mini.jump2d').builtin_opts.word_start)
		end, { desc = 'Jump2d: jump to word' })

		-- [[ RAINBOW DELIMITERS ]]
		-- Treesitter-based: each nesting level gets its own color, always visible.
		require('mini.deps').add 'HiPhish/rainbow-delimiters.nvim'
		local rainbow = require 'rainbow-delimiters'
		require('rainbow-delimiters.setup').setup {
			strategy = { [''] = rainbow.strategy['global'] },
			query    = { [''] = 'rainbow-delimiters' },
			priority = { [''] = 110 },
			highlight = {
				'RainbowDelimiterRed',
				'RainbowDelimiterYellow',
				'RainbowDelimiterBlue',
				'RainbowDelimiterOrange',
				'RainbowDelimiterGreen',
				'RainbowDelimiterViolet',
				'RainbowDelimiterCyan',
			},
		}
		-- Catppuccin Mocha palette
		vim.api.nvim_set_hl(0, 'RainbowDelimiterRed',    { fg = '#f38ba8' })
		vim.api.nvim_set_hl(0, 'RainbowDelimiterYellow', { fg = '#f9e2af' })
		vim.api.nvim_set_hl(0, 'RainbowDelimiterBlue',   { fg = '#89b4fa' })
		vim.api.nvim_set_hl(0, 'RainbowDelimiterOrange', { fg = '#fab387' })
		vim.api.nvim_set_hl(0, 'RainbowDelimiterGreen',  { fg = '#a6e3a1' })
		vim.api.nvim_set_hl(0, 'RainbowDelimiterViolet', { fg = '#cba6f7' })
		vim.api.nvim_set_hl(0, 'RainbowDelimiterCyan',   { fg = '#89dceb' })
	end)
end

return M
