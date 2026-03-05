-- [[ PLUGIN KEYMAPS ]]
-- Single source of truth for all global plugin-owned keymaps.
-- Mirrors lua/core/keymaps.lua which owns editor-fundamental bindings.
--
-- RULES:
--   • All descs follow "Category: Action" format — no brackets, no parentheticals
--   • Keymaps use JIT closures: require() inside function body, never at top-level
--   • Buffer-local keymaps (LspAttach, FileType autocmds) stay in their plugin files
--   • One prefix = one domain (see plan.md for the full prefix map)
--   • This file is loaded immediately from core/init.lua at startup

local M = {}

-- ─────────────────────────────────────────────────────────────────────────────
-- Local Helpers
-- ─────────────────────────────────────────────────────────────────────────────

local utils = require('core.utils')

--- TUI factory: validates the mise shim then opens a snacks floating terminal.
local function tui(bin, label, cmd_override)
	return function()
		local path = utils.mise_shim(bin)
		if not path then
			utils.soft_notify(label .. ' missing. Install via: mise install ' .. bin, vim.log.levels.WARN)
			return
		end
		require('snacks').terminal.toggle(cmd_override or path)
	end
end

--- Wrapper for PIO commands: runs in terminal, waits for Enter before closing.
local function pio(cmd)
	return function()
		require('snacks').terminal.toggle(cmd .. "; read -p 'Press Enter to close...'")
	end
end

--- Jump helper for vim.diagnostic.jump — forward or backward, optional severity.
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

vim.keymap.set({ 'n', 't' }, [[<C-\>]], function()
	require('snacks').terminal.toggle()
end, { desc = 'Terminal: Toggle' })

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

vim.keymap.set('n', '<leader>gg', tui('lazygit', 'lazygit'), { desc = 'Git: Lazygit' })

vim.keymap.set('n', '<leader>gl', function()
	require('snacks').picker.git_log()
end, { desc = 'Git: Log' })
vim.keymap.set('n', '<leader>gf', function()
	require('snacks').picker.git_log_file()
end, { desc = 'Git: File History' })
vim.keymap.set('n', '<leader>gS', function()
	require('snacks').picker.git_status()
end, { desc = 'Git: Status' })
vim.keymap.set('n', '<leader>gb', function()
	require('snacks').picker.git_branches()
end, { desc = 'Git: Branches' })
vim.keymap.set({ 'n', 'x' }, '<leader>gB', function()
	require('snacks').gitbrowse()
end, { desc = 'Git: Browse (open)' })
vim.keymap.set({ 'n', 'x' }, '<leader>gY', function()
	require('snacks').gitbrowse({
		open = function(url) vim.fn.setreg('+', url) end,
		notify = false,
	})
end, { desc = 'Git: Browse (copy URL)' })

-- mini.diff hunk operations — guarded with pcall since mini.diff loads deferred
vim.keymap.set('n', ']c', function()
	local ok, diff = pcall(require, 'mini.diff')
	if ok then diff.goto_hunk('next') end
end, { desc = 'Git: Next Hunk' })
vim.keymap.set('n', '[c', function()
	local ok, diff = pcall(require, 'mini.diff')
	if ok then diff.goto_hunk('prev') end
end, { desc = 'Git: Prev Hunk' })
vim.keymap.set('n', '<leader>gs', function()
	require('mini.diff').apply_hunk()
end, { desc = 'Git: Stage Hunk' })
vim.keymap.set('n', '<leader>gu', function()
	require('mini.diff').reset_hunk()
end, { desc = 'Git: Undo Hunk' })
vim.keymap.set('n', '<leader>gD', function()
	require('mini.diff').toggle_overlay(0)
end, { desc = 'Git: Toggle Diff Overlay' })
vim.keymap.set('n', '<leader>gq', function()
	require('mini.diff').export_to_qf('current')
end, { desc = 'Git: Export Hunks to Quickfix' })

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ CODE / LSP (non-buffer-local): <leader>c ]]
-- Buffer-local keymaps (gd, gr, <leader>ca, etc.) live in native-lsp.lua
-- ─────────────────────────────────────────────────────────────────────────────

vim.keymap.set({ 'n', 'v' }, '<leader>cf', function()
	require('core.format').autoformat()
end, { desc = 'Code: Format Buffer' })

vim.keymap.set('n', 'gco', 'o<Esc>Vcx<Esc><cmd>normal gcc<CR>fxa<BS>', { desc = 'Code: Comment Below' })
vim.keymap.set('n', 'gcO', 'O<Esc>Vcx<Esc><cmd>normal gcc<CR>fxa<BS>', { desc = 'Code: Comment Above' })

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ EXECUTE: <leader>e ]] (build / run / watch — moved from <leader>c)
-- ─────────────────────────────────────────────────────────────────────────────

vim.keymap.set('n', '<leader>er', function()
	require('commands.building').run()
end, { desc = 'Execute: Run' })
vim.keymap.set('n', '<leader>ec', function()
	require('commands.building').run_continuous()
end, { desc = 'Execute: Continuous (watch)' })
vim.keymap.set('n', '<leader>ew', '<cmd>Watch ', { desc = 'Execute: Watch (manual)' })

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

vim.keymap.set('n', '<leader>ff', function() require('snacks').picker.files() end, { desc = 'Find: Files' })
vim.keymap.set('n', '<leader>fd', function() require('snacks').picker.zoxide() end, { desc = 'Find: Directory (Zoxide)' })
vim.keymap.set('n', '<leader>fr', function() require('snacks').picker.recent() end, { desc = 'Find: Recent Files' })
vim.keymap.set('n', '<leader>fc', function() require('snacks').picker.recent({ filter = { cwd = true } }) end,
	{ desc = 'Find: Recent (CWD)' })
vim.keymap.set('n', '<leader>fs', function() require('mini.starter').open() end, { desc = 'Find: Starter' })

vim.keymap.set('n', '<leader>fe', function()
	require('mini.files').open(project_root())
end, { desc = 'File: Explorer (Root)' })
vim.keymap.set('n', '-', function()
	require('mini.files').open(vim.api.nvim_buf_get_name(0))
end, { desc = 'File: Explorer (Current Dir)' })

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ SEARCH: <leader>s ]]
-- ─────────────────────────────────────────────────────────────────────────────

vim.keymap.set('n', '<leader>sg', function() require('snacks').picker.grep() end, { desc = 'Search: Grep Project' })
vim.keymap.set('n', '<leader>sw', function() require('snacks').picker.grep_word() end, { desc = 'Search: Grep Word' })
vim.keymap.set('n', '<leader>sd', function() require('snacks').picker.diagnostics() end, { desc = 'Search: Diagnostics' })
vim.keymap.set('n', '<leader>sr', function() require('snacks').picker.resume() end, { desc = 'Search: Resume' })
vim.keymap.set('n', '<leader>sh', function() require('snacks').picker.help() end, { desc = 'Search: Help' })
vim.keymap.set('n', '<leader>sk', function() require('snacks').picker.keymaps() end, { desc = 'Search: Keymaps' })
vim.keymap.set('n', '<leader>su', function() require('snacks').picker.undo() end, { desc = 'Search: Undo History' })
vim.keymap.set('n', '<leader>sN', function() require('snacks').picker.notifications() end,
	{ desc = 'Search: Notifications' })
vim.keymap.set('n', '<leader>sn', function()
	require('snacks').picker.files({ cwd = vim.fn.stdpath('config') })
end, { desc = 'Search: Neovim Config' })
vim.keymap.set('n', '<leader>sR', '<cmd>Sd<CR>', { desc = 'Search: Find & Replace (sd)' })

vim.keymap.set('n', '<leader><leader>', function()
	require('snacks').picker.buffers()
end, { desc = 'Search: Active Buffers' })

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

vim.keymap.set('n', '<leader>vq', '<cmd>Jq<CR>', { desc = 'View: jq Scratchpad' })
vim.keymap.set('n', '<leader>vx', '<cmd>Xh<CR>', { desc = 'View: HTTP Client (xh)' })
vim.keymap.set('n', '<leader>vJ', '<cmd>Jless<CR>', { desc = 'View: JSON Viewer (jless)' })

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ TROUBLE: <leader>x ]]
-- ─────────────────────────────────────────────────────────────────────────────

local function trouble(action)
	return function()
		local ok, t = pcall(require, 'trouble')
		if ok then t.toggle(action) end
	end
end

vim.keymap.set('n', '<leader>xx', trouble('diagnostics toggle'), { desc = 'Trouble: Workspace Diagnostics' })
vim.keymap.set('n', '<leader>xd', trouble('diagnostics toggle filter.buf=0'), { desc = 'Trouble: Document Diagnostics' })
vim.keymap.set('n', '<leader>xq', trouble('qflist toggle'), { desc = 'Trouble: Quickfix' })
vim.keymap.set('n', '<leader>xl', trouble('loclist toggle'), { desc = 'Trouble: Location List' })

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
	local ok = pcall(function() require('trouble').toggle('qflist') end)
	if not ok then vim.cmd('copen') end
end, { desc = 'Diagnostics: Quickfix List' })

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ UTILITIES: <leader>u, <leader>y, <Esc> ]]
-- These were previously scattered in diagnostics.lua, auditing.lua, utilities.lua
-- ─────────────────────────────────────────────────────────────────────────────

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR><Esc>', { desc = 'Utilities: Clear Highlights' })

vim.keymap.set('n', '<leader>ur', '<cmd>LspRestart<CR>', { desc = 'Utilities: Restart LSP' })
vim.keymap.set('n', '<leader>ut', '<cmd>ToolCheck<CR>', { desc = 'Utilities: Tool Check' })
vim.keymap.set('n', '<leader>uT', '<cmd>Typos<CR>', { desc = 'Utilities: Typos Check' })

vim.keymap.set('n', '<leader>ul', function()
	local cfg = vim.diagnostic.config()
	vim.diagnostic.config({ virtual_text = not cfg.virtual_text })
end, { desc = 'Utilities: Toggle Virtual Text' })
vim.keymap.set('n', '<leader>uu', function()
	local cfg = vim.diagnostic.config()
	vim.diagnostic.config({ underline = not cfg.underline })
end, { desc = 'Utilities: Toggle Underlines' })

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ YANK: <leader>y ]]
-- ─────────────────────────────────────────────────────────────────────────────

vim.keymap.set('n', '<leader>yp', function()
	local path = vim.fn.expand('%:p')
	vim.fn.setreg('+', path)
	vim.notify('Copied: ' .. path, vim.log.levels.INFO)
end, { desc = 'Yank: Absolute Path' })
vim.keymap.set('n', '<leader>yr', function()
	local path = vim.fn.expand('%:~:.')
	vim.fn.setreg('+', path)
	vim.notify('Copied: ' .. path, vim.log.levels.INFO)
end, { desc = 'Yank: Relative Path' })

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ BUFFER: <leader>b ]]
-- ─────────────────────────────────────────────────────────────────────────────

vim.keymap.set('n', '<leader>bd', function()
	local ok, snacks = pcall(require, 'snacks')
	if ok then snacks.bufdelete() else vim.cmd('bdelete') end
end, { desc = 'Buffer: Delete' })
vim.keymap.set('n', '<leader>bo', function()
	local ok, snacks = pcall(require, 'snacks')
	if ok then snacks.bufdelete.other() else vim.cmd('%bd|e#|bd#') end
end, { desc = 'Buffer: Delete Others' })

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
	require('mini.sessions').write(nil, { verbose = true })
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
	vim.cmd('Trouble todo toggle')
end, { desc = 'Trouble: TODO List' })
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
