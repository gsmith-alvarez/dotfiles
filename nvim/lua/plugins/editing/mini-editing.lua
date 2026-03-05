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
	end)
end

return M
