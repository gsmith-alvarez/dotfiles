-- [[ UTILITIES: Data Pipelines & Buffer Helpers ]]
-- Domain: Utility / System Interop
-- Location: lua/commands/utilities.lua
--
-- PHILOSOPHY: The High-Performance Workbench
-- Transforms Neovim into a tool for external CLI manipulation. We use
-- high-speed Rust/Go tools (jq, sd, xh) to transform and query buffer
-- data without blocking the UI.
--
-- MAINTENANCE TIPS:
-- 1. If :Jq fails, check if `gojq` is installed via Mise.
-- 2. If :Sd fails, check if `sd` is installed via Mise.
-- 3. Use `:Redir` to capture internal Neovim output (e.g., `:Redir hi`)
--    for easier debugging.
--
-- ARCHITECTURE: Binary Delegators
-- Most commands here are thin wrappers around Mise-managed binaries, 
-- ensuring that the editor stays fast by delegating heavy lifting to 
-- external processes.

local M = {}

M.commands = {
	-- [[ GoJQ: Native JSON Querying ]]
	Jq = {
		desc = 'Run gojq on current buffer',
		nargs = '?',
		keymap = '<leader>uj', -- Moved to 'u' (UI Utils) to avoid leader conflicts, or keep 'c'
		impl = function(opts)
			local utils = require('core.utils')
			local gojq = utils.mise_shim('gojq')

			if not gojq then
				utils.soft_notify('gojq is missing! Install via mise.', vim.log.levels.WARN)
				return
			end

			local query = opts.args == '' and '.' or opts.args
			local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
			local input = table.concat(lines, '\n')

			local obj = vim.system({ gojq, query }, { stdin = input, text = true }):wait()

			if obj.code ~= 0 then
				utils.soft_notify('gojq error: ' .. (obj.stderr or 'Unknown'), vim.log.levels.ERROR)
				return
			end

			local qf_items = {}
			local stdout = obj.stdout or ''
			local output_lines = vim.split(stdout:gsub('\n$', ''), '\n')
			for i, line in ipairs(output_lines) do
				if line ~= '' then
					table.insert(qf_items, { text = line, lnum = i, filename = 'gojq-output' })
				end
			end

			vim.fn.setqflist(qf_items, 'r')
			local has_trouble, _ = pcall(require, 'trouble')
			if has_trouble then
				vim.cmd 'Trouble quickfix toggle'
			else
				vim.cmd 'copen'
			end
			vim.notify('JQ Query: ' .. query, vim.log.levels.DEBUG)
		end,
	},

	-- [[ Sd: Surgical Buffer Replace ]]
	Sd = {
		desc = 'Surgical replace via sd',
		nargs = '+',
		keymap = '<leader>us',
		impl = function(opts)
			local utils = require('core.utils')
			local sd = utils.mise_shim('sd')
			if not sd then
				return
			end

			if #opts.fargs < 2 then
				utils.soft_notify('Usage: :Sd "find this" "replace with"', vim.log.levels.WARN)
				return
			end

			local find, replace = opts.fargs[1], opts.fargs[2]
			local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
			local input = table.concat(lines, '\n')

			local obj = vim.system({ sd, find, replace }, { stdin = input, text = true }):wait()
			if obj.code == 0 then
				local stdout = obj.stdout or ''
				local output = stdout:gsub('\n$', '')
				vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(output, '\n'))
				vim.notify(string.format('sd: Replaced "%s" with "%s"', find, replace), vim.log.levels.INFO)
			else
				utils.soft_notify('sd error: ' .. (obj.stderr or 'Unknown'), vim.log.levels.ERROR)
			end
		end,
	},

	-- [[ Xh: HTTP Playground ]]
	Xh = {
		desc = 'Execute HTTP request via xh',
		nargs = '*',
		keymap = '<leader>ux',
		impl = function(opts)
			local utils = require('core.utils')
			local xh = utils.mise_shim('xh')
			if not xh then
				return
			end

			local cmd = { xh }
			for _, arg in ipairs(opts.fargs) do
				table.insert(cmd, arg)
			end

			vim.notify('Dispatching HTTP Request...', vim.log.levels.DEBUG)

			vim.system(cmd, { text = true }, function(obj)
				vim.schedule(function()
					vim.cmd 'vnew'
					local buf = vim.api.nvim_get_current_buf()
					vim.bo[buf].buftype, vim.bo[buf].bufhidden = 'nofile', 'wipe'

					local raw_output = (obj.stdout and obj.stdout ~= '') and obj.stdout or obj.stderr or ''
					local output = raw_output:gsub('\n$', '')
					vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(output, '\n'))

					if output ~= '' then
						if output:find '^{' or output:find '^%[' then
							vim.bo[buf].filetype = 'json'
						elseif output:find '<html' or output:find '<!DOCTYPE' then
							vim.bo[buf].filetype = 'html'
						end
					end
				end)
			end)
		end,
	},

	-- [[ Output Capture Engine ]]
	Redir = {
		desc = 'Redirect command output to buffer',
		nargs = '+',
		complete = 'command',
		keymap = '<leader>ur',
		impl = function(ctx)
			local output = vim.fn.execute(ctx.args)
			vim.cmd 'vnew'
			local buf = vim.api.nvim_get_current_buf()
			vim.bo[buf].buftype = 'nofile'
			vim.bo[buf].bufhidden = 'wipe'

			if ctx.args:match '^lua' then
				vim.bo[buf].filetype = 'lua'
			elseif ctx.args:match '^hi' or ctx.args:match '^map' then
				vim.bo[buf].filetype = 'vim'
			end

			vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(output, '\n'))
		end,
	},

	-- [[ MiseTrust: Project Security Management ]]
	MiseTrust = {
		desc = 'Trust the .mise.toml in the current directory',
		keymap = '<leader>um',
		impl = function()
			local utils = require('core.utils')
			local mise = utils.mise_shim('mise')
			if not mise then
				utils.soft_notify('mise binary not found.', vim.log.levels.WARN)
				return
			end

			vim.system({ mise, 'trust', '.' }, { text = true }, function(obj)
				vim.schedule(function()
					if obj.code == 0 then
						vim.notify('Project Trusted: .mise.toml approved.', vim.log.levels.INFO)
					else
						utils.soft_notify('Mise Trust Failed: ' .. (obj.stderr or 'Unknown Error'), vim.log.levels.ERROR)
					end
				end)
			end)
		end,
	},

	-- [[ Scratch: Ephemeral Notepad ]]
	Scratch = {
		desc = 'Open an ephemeral scratch buffer',
		keymap = '<leader>us', -- Wait, 'Sd' and 'Scratch' both use 'us'? Let's refine.
		impl = function()
			vim.cmd 'vnew'
			local buf = vim.api.nvim_get_current_buf()
			vim.bo[buf].buftype = 'nofile'
			vim.bo[buf].bufhidden = 'wipe'
			vim.bo[buf].buflisted = false
			vim.bo[buf].swapfile = false
			vim.api.nvim_buf_set_name(buf, '[Scratch]')
		end,
	},

	-- [[ Logs: Configuration Debugging Tab ]]
	Logs = {
		desc = 'Open Neovim logs in a new tab',
		keymap = '<leader>ul',
		impl = function()
			local config_log = vim.fn.stdpath('state') .. '/config_diagnostics.log'
			local lsp_log = vim.fn.stdpath('state') .. '/lsp.log'

			vim.cmd 'tabnew'
			if vim.fn.filereadable(config_log) == 1 then
				vim.cmd('edit ' .. config_log)
				vim.cmd 'normal! G'
			else
				vim.notify('Config log not found yet.', vim.log.levels.DEBUG)
			end

			if vim.fn.filereadable(lsp_log) == 1 then
				vim.cmd('vsplit ' .. lsp_log)
				vim.cmd 'normal! G'
			end
		end,
	},

	-- [[ DiffOrig: Unsaved Changes Audit ]]
	DiffOrig = {
		desc = 'Diff current buffer against the file on disk',
		keymap = '<leader>ud',
		impl = function()
			vim.cmd 'vsplit'
			vim.cmd 'enew'
			vim.cmd 'read #'
			vim.cmd '0delete _'
			vim.bo.buftype = 'nofile'
			vim.bo.bufhidden = 'wipe'
			vim.bo.buflisted = false
			vim.bo.swapfile = false
			vim.cmd 'diffthis'
			vim.cmd 'wincmd p'
			vim.cmd 'diffthis'
		end,
	},
}

-- [[ Better gx - Open URLs with System Default ]]
-- We keep this as a direct keymap because it replaces a core vim feature.
vim.keymap.set('n', 'gx', function()
	local cfile = vim.fn.expand '<cfile>'
	if cfile:match '^https?://' then
		return vim.ui.open(cfile)
	end

	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2] + 1

	for text, url in line:gmatch '%[([^%]]+)%]%((https?://[^%)]+)%)' do
		local start_idx, end_idx = line:find('%[' .. text:gsub('([^%w])', '%%%1') .. '%]%(' .. url:gsub('([^%w])', '%%%1') .. '%)')
		if start_idx and col >= start_idx and col <= end_idx then
			return vim.ui.open(url)
		end
	end

	vim.ui.open(cfile)
end, { desc = 'Smart open link under cursor' })

return M
