-- [[ MINI.FILES: File Explorer ]]
-- Domain: Navigation
-- Deferred via MiniDeps.later — runs after the initial render.

local M = {}

M.setup = function()
	require('mini.deps').later(function()
		require('mini.files').setup {
			windows = { preview = true, width_focus = 30 },
		}

		local show_dotfiles = true
		local filter_show = function(_) return true end
		local filter_hide = function(fs_entry) return not vim.startswith(fs_entry.name, '.') end

		local toggle_dotfiles = function()
			show_dotfiles = not show_dotfiles
			local new_filter = show_dotfiles and filter_show or filter_hide
			require('mini.files').refresh({ content = { filter = new_filter } })
		end

		local map_split = function(buf_id, lhs, direction)
			local rhs = function()
				local mf = require('mini.files')
				local cur_target = mf.get_explorer_state().target_window
				local new_target = vim.api.nvim_win_call(cur_target, function()
					vim.cmd(direction .. ' split')
					return vim.api.nvim_get_current_win()
				end)
				mf.set_target_window(new_target)
				mf.go_in({ close_on_file = true })
			end
			vim.keymap.set('n', lhs, rhs, { buffer = buf_id, desc = 'Split ' .. direction })
		end

		vim.api.nvim_create_autocmd('User', {
			pattern = 'MiniFilesBufferCreate',
			callback = function(args)
				local buf_id = args.data.buf_id
				map_split(buf_id, '<C-s>', 'belowright horizontal')
				map_split(buf_id, '<C-v>', 'belowright vertical')
				vim.keymap.set('n', 'g.', toggle_dotfiles, { buffer = buf_id, desc = 'Toggle Hidden Files' })
			end,
		})

		local root_markers = { '.git', 'go.mod', 'Cargo.toml', 'package.json', 'pom.xml', 'pyproject.toml', 'build.zig' }

		local function get_project_root()
			local path = vim.api.nvim_buf_get_name(0)
			path = path ~= '' and vim.fn.fnamemodify(path, ':p:h') or vim.fn.getcwd()
			for dir in vim.fs.parents(path) do
				for _, marker in ipairs(root_markers) do
					if vim.uv.fs_stat(dir .. '/' .. marker) then
						return dir
					end
				end
			end
			return vim.fn.getcwd()
		end

		-- <leader>fe and - keymaps moved to lua/core/plugin-keymaps.lua (File section).
		-- project_root() logic is inlined there as a local helper.
	end)
end

return M
