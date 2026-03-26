-- [[ PLUGIN KEYMAPS REGISTRY ]]
-- Purpose: Centralized Global Plugin Integration
-- Domain: Plugin Mapping Surface
-- Architecture: Deferred/Lazy-First (Phased Boot)
-- Location: lua/core/plugin-keymaps.lua

local M = {}

-- ─────────────────────────────────────────────────────────────────────────────
-- Local Helpers
-- ─────────────────────────────────────────────────────────────────────────────

local utils = require('core.utils')

--- JIT Snacks wrapper: ensures Snacks is configured before calling its API.
local function snacks_call(func_name, ...)
	local args = { ... }
	return function()
		require('plugins.core.snacks').bootstrap()
		local parts = vim.split(func_name, '.', { plain = true })
		local target = require('snacks')
		for i = 1, #parts do
			target = target[parts[i]]
		end
		target(unpack(args))
	end
end

--- TUI factory: validates the mise shim then opens a snacks floating terminal.
local function tui(bin, label, cmd_override)
	return function()
		local path = vim.fn.executable(bin) == 1 and bin or nil
		if not path then
			utils.soft_notify(label .. ' missing. Install via: mise install ' .. bin, vim.log.levels.WARN)
			return
		end
		require('plugins.core.snacks').bootstrap()
		require('snacks').terminal.toggle(cmd_override or path)
	end
end

--- Wrapper for PIO commands: runs in terminal, waits for Enter before closing.
local function pio(cmd)
	return function()
		require('plugins.core.snacks').bootstrap()
		require('snacks').terminal.toggle(cmd .. "; read -p 'Press Enter to close...'")
	end
end

--- Jump helper for vim.diagnostic.jump
local function diag_jump(next, severity)
	return function()
		vim.diagnostic.jump({
			count    = (next and 1 or -1) * vim.v.count1,
			severity = severity and vim.diagnostic.severity[severity] or nil,
			float    = true,
		})
	end
end

--- Walk up from cwd to find the project root by marker files.
local function project_root()
	local markers = { '.git', 'go.mod', 'Cargo.toml', 'package.json', 'pom.xml', 'pyproject.toml', 'build.zig' }
	for _, marker in ipairs(markers) do
		local found = vim.fs.find(marker, { upward = true, stop = vim.env.HOME })
		if found[1] then
			return vim.fs.dirname(found[1])
		end
	end
	return vim.fn.getcwd()
end

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ TERMINAL / TUI: <C-\>, <leader>t ]]
-- ─────────────────────────────────────────────────────────────────────────────

vim.keymap.set({ 'n', 't' }, [[<C-\>]], snacks_call('terminal.toggle'), { desc = 'Terminal: Toggle' })

vim.keymap.set('n', '<leader>tp', tui('btm', 'btm'), { desc = 'Terminal: Process Monitor' })
vim.keymap.set('n', '<leader>ts', tui('spotify_player', 'spotify_player'), { desc = 'Terminal: Spotify' })
vim.keymap.set('n', '<leader>ti', tui('podman-tui', 'podman-tui'), { desc = 'Terminal: Containers' })
vim.keymap.set('n', '<leader>ta', function()
	local file = vim.fn.expand('%:p')
	local cmd  = 'aider ' .. (file ~= '' and vim.fn.shellescape(file) or '')
	tui('aider', 'Aider AI', cmd)()
end, { desc = 'Terminal: Aider AI' })

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ PLATFORMIO: <leader>p ]]
-- ─────────────────────────────────────────────────────────────────────────────

vim.keymap.set('n', '<leader>pb', pio('pio run'), { desc = 'PIO: Build' })
vim.keymap.set('n', '<leader>pu', pio('pio run -t upload'), { desc = 'PIO: Upload Firmware' })
vim.keymap.set('n', '<leader>pm', pio('pio device monitor'), { desc = 'PIO: Serial Monitor' })
vim.keymap.set('n', '<leader>pc', pio('pio project init --ide=vscode'), { desc = 'PIO: Compile DB' })

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ GIT: <leader>g ]]
-- ─────────────────────────────────────────────────────────────────────────────

vim.keymap.set('n', '<leader>gg', function()
	if vim.fn.executable('lazygit') == 0 then
		utils.soft_notify('lazygit missing. Install via: mise install lazygit', vim.log.levels.WARN)
		return
	end
	require('plugins.core.snacks').bootstrap()
	require('snacks').lazygit.open()
end, { desc = 'Git: Lazygit' })

vim.keymap.set('n', '<leader>gl', snacks_call('picker.git_log'), { desc = 'Git: Log' })
vim.keymap.set('n', '<leader>gf', snacks_call('picker.git_log_file'), { desc = 'Git: File History' })
vim.keymap.set('n', '<leader>gS', snacks_call('picker.git_status'), { desc = 'Git: Status' })
vim.keymap.set('n', '<leader>gb', snacks_call('picker.git_branches'), { desc = 'Git: Branches' })
vim.keymap.set({ 'n', 'x' }, '<leader>gB', snacks_call('gitbrowse'), { desc = 'Git: Browse (open)' })
vim.keymap.set({ 'n', 'x' }, '<leader>gY', snacks_call('gitbrowse', {
	open = function(url) vim.fn.setreg('+', url) end,
	notify = false,
}), { desc = 'Git: Browse (copy URL)' })

-- mini.diff hunk operations
vim.keymap.set('n', ']c', function()
	local ok, diff = pcall(require, 'mini.diff')
	if ok then diff.goto_hunk('next') end
end, { desc = 'Git: Next Hunk' })
vim.keymap.set('n', '[c', function()
	local ok, diff = pcall(require, 'mini.diff')
	if ok then diff.goto_hunk('prev') end
end, { desc = 'Git: Prev Hunk' })
vim.keymap.set('n', '<leader>gs', function()
	local ok, diff = pcall(require, 'mini.diff')
	if ok then diff.do_hunks(0, 'apply') end
end, { desc = 'Git: Stage Hunk' })
vim.keymap.set('n', '<leader>gu', function()
	local ok, diff = pcall(require, 'mini.diff')
	if ok then diff.do_hunks(0, 'reset') end
end, { desc = 'Git: Undo Hunk' })
vim.keymap.set('n', '<leader>gD', function()
	local ok, diff = pcall(require, 'mini.diff')
	if ok then diff.toggle_overlay(0) end
end, { desc = 'Git: Toggle Diff Overlay' })
vim.keymap.set('n', '<leader>gq', function()
	local ok, diff = pcall(require, 'mini.diff')
	if ok then diff.export('qf', { scope = 'current' }) end
end, { desc = 'Git: Export Hunks to Quickfix' })

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ CODE / LSP (non-buffer-local): <leader>c ]]
-- ─────────────────────────────────────────────────────────────────────────────

vim.keymap.set({ 'n', 'v' }, '<leader>cf', function()
	require('core.format').autoformat()
end, { desc = 'Code: Format Buffer' })

vim.keymap.set('n', 'gco', 'o<Esc>Vcx<Esc><cmd>normal gcc<CR>fxa<BS>', { desc = 'Code: Comment Below' })
vim.keymap.set('n', 'gcO', 'O<Esc>Vcx<Esc><cmd>normal gcc<CR>fxa<BS>', { desc = 'Code: Comment Above' })

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ EXECUTE: <leader>e ]] (build / run / watch)
-- ─────────────────────────────────────────────────────────────────────────────

vim.keymap.set('n', '<leader>er', function() require('commands.building').run() end, { desc = 'Execute: Run' })
vim.keymap.set('n', '<leader>ew', function() require('commands.building').run_continuous() end, { desc = 'Execute: Watch' })
vim.keymap.set('n', '<leader>ec', '<cmd>Watch ', { desc = 'Execute: Watch (manual command)' })

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ DEBUG: <leader>d, <F5> ]]
-- ─────────────────────────────────────────────────────────────────────────────

vim.keymap.set('n', '<F5>', function()
	require('plugins.dap.debug').bootstrap()
	require('dap').continue()
end, { desc = 'Debug: Continue' })
vim.keymap.set('n', '<leader>dc', function()
	require('plugins.dap.debug').bootstrap()
	require('dap').continue()
end, { desc = 'Debug: Continue' })
vim.keymap.set('n', '<leader>db', function()
	require('plugins.dap.debug').bootstrap()
	require('persistent-breakpoints.api').toggle_breakpoint()
end, { desc = 'Debug: Toggle Breakpoint' })
vim.keymap.set('n', '<leader>dB', function()
	require('plugins.dap.debug').bootstrap()
	require('persistent-breakpoints.api').clear_all_breakpoints()
end, { desc = 'Debug: Clear All Breakpoints' })
vim.keymap.set('n', '<leader>do', function()
	require('plugins.dap.debug').bootstrap()
	require('dap').step_over()
end, { desc = 'Debug: Step Over' })
vim.keymap.set('n', '<leader>di', function()
	require('plugins.dap.debug').bootstrap()
	require('dap').step_into()
end, { desc = 'Debug: Step Into' })
vim.keymap.set('n', '<leader>dr', function()
	require('plugins.dap.debug').bootstrap()
	require('dap').repl.toggle()
end, { desc = 'Debug: Toggle REPL' })
vim.keymap.set('n', '<leader>du', function()
	require('plugins.dap.debug').bootstrap()
	require('dapui').toggle()
end, { desc = 'Debug: Toggle UI' })

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ REFACTOR: <leader>r ]]
-- ─────────────────────────────────────────────────────────────────────────────

vim.keymap.set('n', '<leader>rn', function()
	return require('plugins.editing.inc-rename').rename()
end, { expr = true, desc = 'Refactor: Rename Symbol' })

vim.keymap.set({ 'n', 'x' }, '<leader>rr', function()
	require('plugins.editing.refactoring').bootstrap()
	require('refactoring').select_refactor()
end, { desc = 'Refactor: Select' })
vim.keymap.set('x', '<leader>re', function()
	require('plugins.editing.refactoring').bootstrap()
	return require('refactoring').refactor('Extract Variable')
end, { expr = true, desc = 'Refactor: Extract Variable' })
vim.keymap.set('x', '<leader>rf', function()
	require('plugins.editing.refactoring').bootstrap()
	return require('refactoring').refactor('Extract Function')
end, { expr = true, desc = 'Refactor: Extract Function' })
vim.keymap.set('x', '<leader>rF', function()
	require('plugins.editing.refactoring').bootstrap()
	return require('refactoring').refactor('Extract Function To File')
end, { expr = true, desc = 'Refactor: Extract Function to File' })
vim.keymap.set({ 'n', 'x' }, '<leader>ri', function()
	require('plugins.editing.refactoring').bootstrap()
	return require('refactoring').refactor('Inline Variable')
end, { expr = true, desc = 'Refactor: Inline Variable' })

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ FIND: <leader>f ]]
-- ─────────────────────────────────────────────────────────────────────────────

vim.keymap.set('n', '<leader>ff', snacks_call('picker.files'), { desc = 'Find: Files' })
vim.keymap.set('n', '<leader>fd', snacks_call('picker.zoxide'), { desc = 'Find: Directory (Zoxide)' })
vim.keymap.set('n', '<leader>fr', snacks_call('picker.recent'), { desc = 'Find: Recent Files' })
vim.keymap.set('n', '<leader>fc', snacks_call('picker.recent', { filter = { cwd = true } }),
	{ desc = 'Find: Recent (CWD)' })
vim.keymap.set('n', '<leader>fs', function() require('mini.starter').open() end, { desc = 'Find: Starter' })

vim.keymap.set('n', '<leader>fe', function()
	require('mini.files').open(project_root())
end, { desc = 'File: Explorer (Root)' })
vim.keymap.set('n', '-', function()
	local mf = require('mini.files')
	if not mf.close() then
		local path = vim.api.nvim_buf_get_name(0)
		if path == '' or path:match('^minifiles://') then
			path = vim.fn.getcwd()
		end
		mf.open(path)
	end
end, { desc = 'File: Explorer (toggle)' })

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ SEARCH: <leader>s ]]
-- ─────────────────────────────────────────────────────────────────────────────

vim.keymap.set('n', '<leader>sg', snacks_call('picker.grep'), { desc = 'Search: Grep Project' })
vim.keymap.set('n', '<leader>sw', snacks_call('picker.grep_word'), { desc = 'Search: Grep Word' })
vim.keymap.set('n', '<leader>sd', snacks_call('picker.diagnostics'), { desc = 'Search: Diagnostics' })
vim.keymap.set('n', '<leader>sr', snacks_call('picker.resume'), { desc = 'Search: Resume' })
vim.keymap.set('n', '<leader>sh', snacks_call('picker.help'), { desc = 'Search: Help' })
vim.keymap.set('n', '<leader>sk', snacks_call('picker.keymaps'), { desc = 'Search: Keymaps' })
vim.keymap.set('n', '<leader>su', snacks_call('picker.undo'), { desc = 'Search: Undo History' })
vim.keymap.set('n', '<leader>sN', snacks_call('picker.notifications'), { desc = 'Search: Notifications' })
vim.keymap.set('n', '<leader>sn', snacks_call('picker.files', { cwd = vim.fn.stdpath('config') }),
	{ desc = 'Search: Neovim Config' })

vim.keymap.set('n', '<leader><leader>', snacks_call('picker.buffers'), { desc = 'Search: Active Buffers' })

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ VIEW: <leader>v ]]
-- ─────────────────────────────────────────────────────────────────────────────

vim.keymap.set('n', '<leader>va', function()
	require('plugins.searching.aerial').bootstrap()
	vim.cmd('AerialToggle!')
end, { desc = 'View: Symbol Outline' })
vim.keymap.set('n', '<leader>vj', function()
	require('plugins.searching.aerial').bootstrap()
	vim.cmd('AerialNavToggle')
end, { desc = 'View: Jump to Symbol' })

vim.keymap.set('n', '<leader>vJ', '<cmd>Jless<CR>', { desc = 'View: JSON Viewer (jless)' })

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ TROUBLE: <leader>x ]]
-- ─────────────────────────────────────────────────────────────────────────────

local function trouble(mode, extra_opts)
	return function()
		local ok, err = pcall(function()
			require('mini.deps').add('folke/trouble.nvim')
			local t = require('trouble')
			if not t.is_open() then
				local opts = { mode = mode, focus = true }
				if extra_opts then opts = vim.tbl_extend('force', opts, extra_opts) end
				t.open(opts)
			else
				t.close()
			end
		end)
		if not ok then
			vim.notify('Trouble: ' .. tostring(err), vim.log.levels.ERROR)
		end
	end
end

vim.keymap.set('n', '<leader>xx', trouble('diagnostics'), { desc = 'Trouble: Workspace Diagnostics' })
vim.keymap.set('n', '<leader>xd', trouble('diagnostics', { filter = { buf = 0 } }), { desc = 'Trouble: Document Diagnostics' })
vim.keymap.set('n', '<leader>xq', trouble('qflist'), { desc = 'Trouble: Quickfix' })
vim.keymap.set('n', '<leader>xl', trouble('loclist'), { desc = 'Trouble: Location List' })

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ DIAGNOSTICS: ]d/[d/]e/[e/]w/[w, <leader>cd ]]
-- ─────────────────────────────────────────────────────────────────────────────

vim.keymap.set('n', '<leader>cd', vim.diagnostic.open_float, { desc = 'Diagnostics: Line Float' })
vim.keymap.set('n', ']d', diag_jump(true), { desc = 'Diagnostics: Next' })
vim.keymap.set('n', '[d', diag_jump(false), { desc = 'Diagnostics: Prev' })
vim.keymap.set('n', ']e', diag_jump(true, 'ERROR'), { desc = 'Diagnostics: Next Error' })
vim.keymap.set('n', '[e', diag_jump(false, 'ERROR'), { desc = 'Diagnostics: Prev Error' })
vim.keymap.set('n', ']w', diag_jump(true, 'WARN'), { desc = 'Diagnostics: Next Warning' })
vim.keymap.set('n', '[w', diag_jump(false, 'WARN'), { desc = 'Diagnostics: Prev Warning' })

vim.keymap.set('n', '<leader>q', function()
	local ok, _ = pcall(require, 'trouble')
	if ok then vim.cmd('Trouble qflist toggle') else vim.cmd('copen') end
end, { desc = 'Diagnostics: Quickfix List' })

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ UTILITIES: <leader>u, <leader>y, <Esc> ]]
-- ─────────────────────────────────────────────────────────────────────────────

vim.keymap.set({ 'n', 'x', 'o' }, '<Esc>', function()
	local ok, jump = pcall(require, 'mini.jump')
	if ok and jump.state and jump.state.jumping then
		jump.stop_jumping()
	end
	vim.cmd.nohlsearch()
	return '<Esc>'
end, { expr = true, silent = true, desc = 'Utilities: Clear Highlights / Stop Jump' })

vim.keymap.set('n', '<leader>ur', '<cmd>LspRestart<CR>', { desc = 'Utilities: Restart LSP' })

vim.keymap.set('n', '<leader>ul', function()
	local cfg = vim.diagnostic.config()
	vim.diagnostic.config({ virtual_text = not cfg.virtual_text })
end, { desc = 'Utilities: Toggle Virtual Text' })
vim.keymap.set('n', '<leader>uu', function()
	local cfg = vim.diagnostic.config()
	vim.diagnostic.config({ underline = not cfg.underline })
end, { desc = 'Utilities: Toggle Underlines' })
vim.keymap.set('n', '<leader>uc', function()
	require('copilot.suggestion').toggle_auto_trigger()
	vim.cmd('redrawstatus')
end, { desc = 'Utilities: Toggle Copilot' })

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ YANK: <leader>y ]]
-- ─────────────────────────────────────────────────────────────────────────────

vim.keymap.set('n', '<leader>yp', function()
	local path = vim.fn.expand('%:p')
	vim.fn.setreg('+', path)
	vim.fn.setreg('"', path)
	vim.notify('Copied: ' .. path, vim.log.levels.INFO)
end, { desc = 'Yank: Absolute Path' })
vim.keymap.set('n', '<leader>yr', function()
	local path = vim.fn.expand('%:~:.')
	vim.fn.setreg('+', path)
	vim.fn.setreg('"', path)
	vim.notify('Copied: ' .. path, vim.log.levels.INFO)
end, { desc = 'Yank: Relative Path' })

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ BUFFER: <leader>b ]]
-- ─────────────────────────────────────────────────────────────────────────────

vim.keymap.set('n', '<leader>bd', snacks_call('bufdelete'), { desc = 'Buffer: Delete' })
vim.keymap.set('n', '<leader>bo', snacks_call('bufdelete.other'), { desc = 'Buffer: Delete Others' })

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ SESSION: <leader>q ]]
-- ─────────────────────────────────────────────────────────────────────────────

vim.keymap.set('n', '<leader>qs', function()
	require('mini.sessions').read()
end, { desc = 'Session: Restore' })
vim.keymap.set('n', '<leader>ql', function()
	require('mini.sessions').select('read')
end, { desc = 'Session: Select & Restore' })
vim.keymap.set('n', '<leader>qw', function()
	local ms = require('mini.sessions')
	if vim.v.this_session ~= '' then
		ms.write(nil, { verbose = true })
	else
		local default = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
		local name = vim.fn.input('Session name: ', default)
		if name ~= '' then ms.write(name, { verbose = true }) end
	end
end, { desc = 'Session: Save' })
vim.keymap.set('n', '<leader>qd', function()
	require('mini.sessions').config.autowrite = false
	vim.notify('Session autosave disabled', vim.log.levels.DEBUG)
end, { desc = 'Session: Disable Autosave' })

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ OVERSEER: <leader>o ]]
-- ─────────────────────────────────────────────────────────────────────────────

local function overseer(cmd)
	return function()
		require('plugins.workflow.overseer').bootstrap()
		vim.cmd(cmd)
	end
end

vim.keymap.set('n', '<leader>ot', overseer('OverseerToggle'), { desc = 'Overseer: Toggle' })
vim.keymap.set('n', '<leader>or', overseer('OverseerRun'), { desc = 'Overseer: Run Template' })
vim.keymap.set('n', '<leader>oi', overseer('OverseerInfo'), { desc = 'Overseer: Info' })
vim.keymap.set('n', '<leader>oa', overseer('OverseerTaskAction'), { desc = 'Overseer: Action Menu' })

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ TEST: <leader>T ]]
-- ─────────────────────────────────────────────────────────────────────────────

vim.keymap.set('n', '<leader>Tr', function()
	require('plugins.workflow.test-runner').run_all()
end, { desc = 'Test: Run All (Project)' })
vim.keymap.set('n', '<leader>Tf', function()
	require('plugins.workflow.test-runner').run_file()
end, { desc = 'Test: Run File' })
vim.keymap.set('n', '<leader>Tn', function()
	require('plugins.workflow.test-runner').run_nearest()
end, { desc = 'Test: Run Nearest' })

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ TODO: ]t / [t / <leader>xt / <leader>xT ]]
-- ─────────────────────────────────────────────────────────────────────────────

vim.keymap.set('n', ']t', function()
	require('todo-comments').jump_next()
end, { desc = 'TODO: Next' })
vim.keymap.set('n', '[t', function()
	require('todo-comments').jump_prev()
end, { desc = 'TODO: Prev' })
vim.keymap.set('n', '<leader>xt', function()
	require('mini.deps').add('folke/trouble.nvim')
	vim.cmd('TodoTrouble cwd=' .. vim.fn.fnameescape(project_root()))
end, { desc = 'Trouble: TODO List (Project)' })
vim.keymap.set('n', '<leader>xT', function()
	vim.cmd('TodoQuickFix')
end, { desc = 'TODO: Quickfix' })

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ ZELLIJ: <leader>z ]]
-- ─────────────────────────────────────────────────────────────────────────────

vim.keymap.set('n', '<leader>zv', function()
	vim.fn.jobstart('zellij action new-pane -d right')
end, { desc = 'Zellij: Split Vertical' })
vim.keymap.set('n', '<leader>zs', function()
	vim.fn.jobstart('zellij action new-pane -d down')
end, { desc = 'Zellij: Split Horizontal' })
vim.keymap.set('n', '<leader>zf', function()
	vim.fn.jobstart('zellij action new-pane -f')
end, { desc = 'Zellij: Floating Pane' })
vim.keymap.set('n', '<leader>zq', function()
	vim.fn.jobstart('zellij action close-pane')
end, { desc = 'Zellij: Close Pane' })

return M
