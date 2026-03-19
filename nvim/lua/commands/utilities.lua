-- [[ UTILITIES & DATA PIPELINES ]]
-- Modularized logic for buffer manipulation, system interop, and data processing.
-- PRINCIPLE: Transform Neovim into a high-performance workbench for external CLI tools.
-- KEYMAPS: All keymaps live in lua/core/plugin-keymaps.lua.

local M = {}

-- External tool commands (invoked via keymaps in plugin-keymaps.lua)

-- [[ GoJQ: Native JSON Querying ]]
-- Pipeline: Current Buffer -> String -> GoJQ -> Quickfix List.
vim.api.nvim_create_user_command('Jq', function(opts)
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
  -- BUG FIX: Strip trailing newline from stdout before splitting. Added nil safety.
  local stdout = obj.stdout or ""
  local output_lines = vim.split(stdout:gsub('\n$', ''), '\n')
  for i, line in ipairs(output_lines) do
    if line ~= "" then
      table.insert(qf_items, { text = line, lnum = i, filename = 'gojq-output' })
    end
  end

  vim.fn.setqflist(qf_items, 'r')
  local has_trouble, _ = pcall(require, 'trouble')
  if has_trouble then
    vim.cmd('Trouble quickfix toggle')
  else
    vim.cmd('copen')
  end
  vim.notify('JQ Query: ' .. query, vim.log.levels.DEBUG)
end, { nargs = '?', desc = 'Run gojq on current buffer' })

-- [[ Sd: Surgical Buffer Replace ]]
-- Uses 'sd' (modern sed) to perform regex transformations directly in the buffer.
vim.api.nvim_create_user_command('Sd', function(opts)
  local utils = require('core.utils')
  local sd = utils.mise_shim('sd')
  if not sd then return end

  if #opts.fargs < 2 then
    utils.soft_notify('Usage: :Sd "find this" "replace with"', vim.log.levels.WARN)
    return
  end

  local find, replace = opts.fargs[1], opts.fargs[2]
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local input = table.concat(lines, '\n')

  local obj = vim.system({ sd, find, replace }, { stdin = input, text = true }):wait()
  if obj.code == 0 then
    -- BUG FIX: Strip trailing newline to prevent buffer expansion. Added nil safety.
    local stdout = obj.stdout or ""
    local output = stdout:gsub('\n$', '')
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(output, '\n'))
    vim.notify(string.format('sd: Replaced "%s" with "%s"', find, replace), vim.log.levels.INFO)
  else
    utils.soft_notify('sd error: ' .. (obj.stderr or 'Unknown'), vim.log.levels.ERROR)
  end
end, { nargs = '+', desc = 'Surgical replace via sd' })

-- [[ Xh: HTTP Playground ]]
-- Executes requests and uses a heuristic filetype detector to enable highlighting.
vim.api.nvim_create_user_command('Xh', function(opts)
  local utils = require('core.utils')
  local xh = utils.mise_shim('xh')
  if not xh then return end

  local cmd = { xh }
  for _, arg in ipairs(opts.fargs) do
    table.insert(cmd, arg)
  end

  vim.notify('Dispatching HTTP Request...', vim.log.levels.DEBUG)

  -- ASYNC HANDOFF: Pass a callback function instead of using :wait()
  vim.system(cmd, { text = true }, function(obj)
    -- Must schedule UI mutations back to the main Neovim thread
    vim.schedule(function()
      vim.cmd('vnew')
      local buf = vim.api.nvim_get_current_buf()
      vim.bo[buf].buftype, vim.bo[buf].bufhidden = 'nofile', 'wipe'

      -- BUG FIX: Trim trailing newline from async stdout
      local raw_output = (obj.stdout and obj.stdout ~= "") and obj.stdout or obj.stderr or ""
      local output = raw_output:gsub('\n$', '')
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(output, '\n'))

      -- AUTOMATED SYNTAX ACTIVATION
      if output ~= "" then
        if output:find('^{') or output:find('^%[') then
          vim.bo[buf].filetype = 'json'
        elseif output:find('<html') or output:find('<!DOCTYPE') then
          vim.bo[buf].filetype = 'html'
        end
      end
    end)
  end)
end, { nargs = '*', desc = 'Execute HTTP request via xh' })

-- [[ BUFFER MANAGEMENT ]]
-- Buffer deletion keymaps live in lua/core/plugin-keymaps.lua (<leader>b prefix).

-- [[ Output Capture Engine ]]
-- Intercepts the output of any internal Neovim ex-command and dumps it into a buffer.
vim.api.nvim_create_user_command('Redir', function(ctx)
	local output = vim.fn.execute(ctx.args)
	vim.cmd('vnew')
	local buf = vim.api.nvim_get_current_buf()
	vim.bo[buf].buftype = 'nofile'
	vim.bo[buf].bufhidden = 'wipe'

	-- SMART HIGHLIGHTING: Detect if we are redirecting Lua or Vimscript output.
	if ctx.args:match('^lua') then
		vim.bo[buf].filetype = 'lua'
	elseif ctx.args:match('^hi') or ctx.args:match('^map') then
		vim.bo[buf].filetype = 'vim'
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(output, '\n'))
end, { nargs = '+', complete = 'command', desc = 'Redirect command output to buffer' })

-- [[ Better gx - Open URLs with System Default ]]
-- Replaces the default 'gx' behavior with a more robust implementation.
vim.keymap.set("n", "gx", function()
	-- 1. Use native Neovim 0.10 URL handling for standard strings
	local cfile = vim.fn.expand("<cfile>")
	if cfile:match("^https?://") then
		return vim.ui.open(cfile)
	end

	-- 2. Markdown Link Parsing Logic
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2] + 1

	for text, url in line:gmatch("%[([^%]]+)%]%((https?://[^%)]+)%)") do
		local start_idx, end_idx = line:find("%[" .. text:gsub("([^%w])", "%%%1") .. "%]%(" .. url:gsub("([^%w])", "%%%1") .. "%)")
		if start_idx and col >= start_idx and col <= end_idx then
			return vim.ui.open(url)
		end
	end

	-- 3. Fallback to native UI open
	vim.ui.open(cfile)
end, { desc = "Smart open link under cursor" })

	-- [[ MiseTrust: Project Security Management ]]
	-- Asynchronously trusts the .mise.toml in the current directory.
	-- This prevents mise from blocking LSPs in untrusted directories.
	vim.api.nvim_create_user_command('MiseTrust', function()
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
	end, { desc = 'Trust the .mise.toml in the current directory' })

	-- [[ Scratch: Ephemeral Notepad ]]
	-- Quickly opens a temporary, unlisted buffer for snippets or notes.
	vim.api.nvim_create_user_command('Scratch', function()
	vim.cmd('vnew')
	local buf = vim.api.nvim_get_current_buf()
	vim.bo[buf].buftype = 'nofile'
	vim.bo[buf].bufhidden = 'wipe'
	vim.bo[buf].buflisted = false
	vim.bo[buf].swapfile = false
	vim.api.nvim_buf_set_name(buf, '[Scratch]')
	end, { desc = 'Open an ephemeral scratch buffer' })

	-- [[ Logs: Configuration Debugging Tab ]]
	-- Opens a tab showing both the configuration audit log and the LSP log.
	vim.api.nvim_create_user_command('Logs', function()
	local config_log = vim.fn.stdpath('state') .. '/config_diagnostics.log'
	local lsp_log = vim.fn.stdpath('state') .. '/lsp.log'

	vim.cmd('tabnew')
	if vim.fn.filereadable(config_log) == 1 then
		vim.cmd('edit ' .. config_log)
		vim.cmd('normal! G') -- Jump to end
	else
		vim.notify('Config log not found yet.', vim.log.levels.DEBUG)
	end

	if vim.fn.filereadable(lsp_log) == 1 then
		vim.cmd('vsplit ' .. lsp_log)
		vim.cmd('normal! G') -- Jump to end
	end
	end, { desc = 'Open Neovim logs in a new tab' })

	-- [[ DiffOrig: Unsaved Changes Audit ]]
	-- Compares the current unsaved buffer against the version saved on disk.
	vim.api.nvim_create_user_command('DiffOrig', function()
	-- Create a vertical split
	vim.cmd('vsplit')
	-- Open the original file from disk in the new split
	vim.cmd('enew')
	vim.cmd('read #')
	vim.cmd('0delete _')
	-- Set it to a temporary, read-only buffer
	vim.bo.buftype = 'nofile'
	vim.bo.bufhidden = 'wipe'
	vim.bo.buflisted = false
	vim.bo.swapfile = false
	-- Start diff mode on both windows
	vim.cmd('diffthis')
	vim.cmd('wincmd p')
	vim.cmd('diffthis')
	end, { desc = 'Diff current buffer against the file on disk' })

	return M
