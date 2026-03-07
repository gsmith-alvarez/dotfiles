-- [[ MINI.CLUE: Key Hint Popup ]]
-- Domain: UI
-- Loaded on VimEnter to stay out of the startup hot path.

local M = {}

M.setup = function()
	local clue_group = vim.api.nvim_create_augroup('UI_MiniClue', { clear = true })
	vim.api.nvim_create_autocmd('VimEnter', {
		group = clue_group,
		pattern = '*',
		callback = function()
			local miniclue = require 'mini.clue'
			miniclue.setup {
				triggers = {
					{ mode = 'n', keys = '<Leader>' },
					{ mode = 'x', keys = '<Leader>' },
					{ mode = 'i', keys = '<C-x>' },
					{ mode = 'n', keys = 'g' },
					{ mode = 'x', keys = 'g' },
					{ mode = 'n', keys = "'" },
					{ mode = 'n', keys = '`' },
					{ mode = 'x', keys = "'" },
					{ mode = 'x', keys = '`' },
					{ mode = 'n', keys = '"' },
					{ mode = 'x', keys = '"' },
					{ mode = 'i', keys = '<C-r>' },
					{ mode = 'c', keys = '<C-r>' },
					{ mode = 'n', keys = '<C-w>' },
					{ mode = 'n', keys = 'z' },
					{ mode = 'x', keys = 'z' },
					{ mode = 'n', keys = '[' },
					{ mode = 'n', keys = ']' },
				},
				clues = {
					miniclue.gen_clues.builtin_completion(),
					miniclue.gen_clues.g(),
					miniclue.gen_clues.marks(),
					miniclue.gen_clues.registers(),
					miniclue.gen_clues.windows(),
					miniclue.gen_clues.z(),
					{ mode = 'n', keys = '<Leader>c', desc = '💻 Code' },
					{ mode = 'n', keys = '<Leader>d', desc = '🐞 Debug' },
					{ mode = 'n', keys = '<Leader>e', desc = '⚡ Execute' },
					{ mode = 'n', keys = '<Leader>g', desc = '📦 Git' },
					{ mode = 'n', keys = '<Leader>n', desc = '📝 Notes' },
					{ mode = 'n', keys = '<Leader>o', desc = '🏃 Overseer' },
					{ mode = 'n', keys = '<Leader>p', desc = '🚀 PlatformIO' },
					{ mode = 'n', keys = '<Leader>q', desc = '💾 Session' },
					{ mode = 'n', keys = '<Leader>r', desc = '🛠️ Refactor' },
					{ mode = 'n', keys = '<Leader>s', desc = '🔍 Search' },
					{ mode = 'n', keys = '<Leader>t', desc = '🖥️ Terminal/TUI' },
					{ mode = 'n', keys = '<Leader>T', desc = '🧪 Test' },
					{ mode = 'n', keys = '<Leader>u', desc = '🎨 UI Utils' },
					{ mode = 'n', keys = '<Leader>v', desc = '👁️ View' },
					{ mode = 'n', keys = '<Leader>w', desc = '🪟 Window' },
					{ mode = 'n', keys = '<Leader>z', desc = '🧱 Zellij' },
					{ mode = 'n', keys = '<Leader>b', desc = '󰓩 Buffers' },
					{ mode = 'n', keys = '<Leader>f', desc = '🔭 Find' },
					{ mode = 'n', keys = '<Leader>x', desc = ' Trouble' },
					{ mode = 'n', keys = '<Leader>y', desc = '📋 Yank' },
				},
				window = { delay = 300, config = { width = 'auto', border = 'single' } },
			}
			vim.api.nvim_clear_autocmds { group = 'UI_MiniClue' }
		end,
	})
end

return M
