-- [[ MINI.STATUSLINE: Telemetry Bar ]]
-- Domain: UI
-- Deferred via MiniDeps.later — runs after the initial render.

local M = {}

M.setup = function()
	require('mini.deps').later(function()
		local statusline = require 'mini.statusline'

		local ft_to_tool = {
			python = 'python', javascript = 'node', typescript = 'node',
			javascriptreact = 'node', typescriptreact = 'node',
			go = 'go', rust = 'rust', zig = 'zig', ruby = 'ruby',
			php = 'php', java = 'java', lua = 'lua', c = 'clang', cpp = 'clang',
		}

		local telemetry_group = vim.api.nvim_create_augroup('MiniStatuslineTelemetry', { clear = true })
		if vim.fn.executable 'mise' == 1 then
			vim.api.nvim_create_autocmd({ 'FileType', 'BufEnter', 'DirChanged' }, {
				group = telemetry_group,
				callback = function(event)
					local buf = event.buf
					if not vim.api.nvim_buf_is_valid(buf) or vim.b[buf]._mise_polling then return end
					local ft = vim.bo[buf].filetype
					local target_tool = ft_to_tool[ft]
					if not target_tool then
						vim.b[buf].mise_status = ''
						vim.cmd 'redrawstatus'
						return
					end
					vim.b[buf]._mise_polling = true
					vim.system({ 'mise', 'current', target_tool }, { text = true }, function(out)
						local status = ''
						if out.code == 0 and out.stdout and out.stdout ~= '' then
							local version = out.stdout:gsub('\n', ''):gsub('%s+$', '')
							version = version:match '([^@%s]+)$' or version
							status = '🛠 ' .. version
						end
						vim.schedule(function()
							if vim.api.nvim_buf_is_valid(buf) then
								vim.b[buf].mise_status = status
								vim.b[buf]._mise_polling = false
								vim.cmd 'redrawstatus'
							end
						end)
					end)
				end,
				desc = 'Targeted Mise Version Poller',
			})
		end

		local function render_telemetry()
			local mode, mode_hl = statusline.section_mode { trunc_width = 120 }
			local git = statusline.section_git { trunc_width = 40 }
			local diagnostics = statusline.section_diagnostics { trunc_width = 75 }
			local filename = statusline.section_filename { trunc_width = 140 }
			local location = statusline.section_location { trunc_width = 75 }
			local showcmd = '%10S'
			local lsp_status = ''
			local active_clients = vim.lsp.get_clients { bufnr = 0 }
			if #active_clients > 0 then
				lsp_status = '⚡ ' .. active_clients[1].name
			end
			local mise_status = vim.b.mise_status or ''

			return statusline.combine_groups {
				{ hl = mode_hl,                  strings = { mode } },
				{ hl = 'MiniStatuslineDevinfo',  strings = { git, diagnostics } },
				'%<',
				{ hl = 'MiniStatuslineFilename', strings = { filename } },
				'%=',
				{ hl = 'MiniStatuslineFilename', strings = { showcmd } },
				{ hl = 'MiniStatuslineDevinfo',  strings = { lsp_status, mise_status } },
				{ hl = mode_hl,                  strings = { location } },
			}
		end

		statusline.setup {
			content = { active = render_telemetry },
			use_icons = true,
			set_vim_settings = false,
		}
		vim.opt.showcmdloc = 'statusline'
	end)
end

return M
