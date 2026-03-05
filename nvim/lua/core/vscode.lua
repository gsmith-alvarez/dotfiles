-- [[ VSCODE-NEOVIM INTEGRATION LAYER ]]
-- Location: lua/core/vscode.lua
--
-- PHILOSOPHY: Transparent Parity
-- This module is loaded ONLY when Neovim runs embedded inside VSCodium/VSCode
-- via vscode-neovim. It overrides the snacks.picker, mini.diff, aerial, DAP,
-- and other nvim-only leader maps with equivalent vscode.call() commands so
-- the muscle-memory keymap surface is identical in both environments.
--
-- GUARD: Returns a no-op module immediately when not in VSCode context.
-- This means including it in core/init.lua's module list has zero cost
-- in a normal Neovim session.

if not vim.g.vscode then
	return {}
end

local vs = require 'vscode'
local M = {}

--- Thin wrapper: creates a keymap that calls a VSCode command.
--- @param mode string|table
--- @param lhs string
--- @param cmd string  VSCode command ID
--- @param opts? table  Optional: { args = {...}, desc = "..." }
local function vcmd(mode, lhs, cmd, opts)
	opts = opts or {}
	local args = opts.args
	local desc = opts.desc
	vim.keymap.set(mode, lhs, function()
		vs.call(cmd, args and { args = args } or nil)
	end, { silent = true, desc = desc })
end

-- =============================================================================
-- SEARCH / FILE NAVIGATION  (replaces snacks.picker keymaps)
-- =============================================================================
vcmd('n', '<leader>ff', 'workbench.action.quickOpen',         { desc = 'Find: Files' })
vcmd('n', '<leader>sg', 'workbench.action.findInFiles',       { desc = 'Search: Grep Project' })
vcmd('n', '<leader>sd', 'workbench.actions.view.problems',    { desc = 'Search: Diagnostics' })
vcmd('n', '<leader>sh', 'workbench.action.showCommands',      { desc = 'Search: Help' })
vcmd('n', '<leader>sk', 'workbench.action.openGlobalKeybindings', { desc = 'Search: Keymaps' })
vcmd('n', '<leader>sr', 'workbench.action.openRecent',        { desc = 'Search: Resume' })
vcmd('n', '<leader><leader>', 'workbench.action.showAllEditors', { desc = 'Search: Active Buffers' })

-- Grep word under cursor
vim.keymap.set('n', '<leader>sw', function()
	vs.call('workbench.action.findInFiles', { args = { query = vim.fn.expand '<cword>' } })
end, { silent = true, desc = 'Search: Grep Word' })

-- Open nvim config dir in file picker
vim.keymap.set('n', '<leader>sn', function()
	vs.call('workbench.action.quickOpen', { args = { vim.fn.expand '~/.config/nvim/' } })
end, { silent = true, desc = 'Search: Neovim Config' })

-- =============================================================================
-- LSP  (replaces native-lsp.lua on-attach keymaps)
-- =============================================================================
vcmd('n', 'gd',           'editor.action.revealDefinition',      { desc = 'Code: Go to Definition' })
vcmd('n', 'gr',           'editor.action.goToReferences',        { desc = 'Code: References' })
vcmd('n', 'K',            'editor.action.showHover',             { desc = 'Code: Hover' })
vcmd('n', '<leader>ci',   'editor.action.goToImplementation',    { desc = 'Code: Implementations' })
vcmd('n', '<leader>ct',   'editor.action.goToTypeDefinition',    { desc = 'Code: Type Definition' })
vcmd('n', '<leader>co',   'workbench.action.gotoSymbol',         { desc = 'Code: Outline Symbols' })
vcmd('n', '<leader>cc',   'editor.action.revealDeclaration',     { desc = 'Code: Declaration' })
vcmd('n', '<leader>cn',   'editor.action.rename',                { desc = 'Code: Rename (native)' })
vcmd('n', '<leader>rn',   'editor.action.rename',                { desc = 'Refactor: Rename Symbol' })
vcmd({ 'n', 'x' }, '<leader>ca', 'editor.action.quickFix',      { desc = 'Code: Action' })
vcmd({ 'n', 'x' }, '<leader>cf', 'editor.action.formatDocument', { desc = 'Code: Format' })
vcmd('n', '<leader>ch',   'editor.action.inlayHints.toggle',     { desc = 'Code: Toggle Inlay Hints' })

-- =============================================================================
-- DIAGNOSTICS  (replaces trouble.nvim)
-- =============================================================================
vcmd('n', '<leader>xx', 'workbench.actions.view.problems', { desc = 'Trouble: Workspace Diagnostics' })
vcmd('n', '<leader>xd', 'workbench.actions.view.problems', { desc = 'Trouble: Document Diagnostics' })
vcmd('n', ']d', 'editor.action.marker.nextInFiles',        { desc = 'Diagnostics: Next' })
vcmd('n', '[d', 'editor.action.marker.prevInFiles',        { desc = 'Diagnostics: Prev' })

-- =============================================================================
-- GIT  (replaces mini.diff + lazygit snacks.terminal)
-- =============================================================================
-- Lazygit: open in integrated terminal
vim.keymap.set('n', '<leader>gg', function()
	vs.call 'workbench.action.terminal.newWithCwd'
	vim.defer_fn(function()
		vs.call('workbench.action.terminal.sendSequence', { args = { text = 'lazygit\n' } })
	end, 200)
end, { silent = true, desc = 'Git: Lazygit' })

vcmd('n', ']h',          'workbench.action.editor.nextChange',   { desc = 'Git: Next Hunk' })
vcmd('n', '[h',          'workbench.action.editor.previousChange', { desc = 'Git: Prev Hunk' })
vcmd('n', '<leader>hs',  'git.stageSelectedRanges',              { desc = 'Git: Stage Hunk' })
vcmd('n', '<leader>hr',  'git.revertSelectedRanges',             { desc = 'Git: Reset Hunk' })
vcmd('n', '<leader>hp',  'editor.action.dirtydiff.next',         { desc = 'Git: Preview Hunk' })

-- =============================================================================
-- VIEW / OUTLINE  (replaces aerial.nvim)
-- =============================================================================
vcmd('n', '<leader>va', 'outline.focus', { desc = 'View: Symbol Outline' })
vcmd('n', '<leader>vj', 'outline.focus', { desc = 'View: Jump to Symbol' })

-- =============================================================================
-- BUFFER & WINDOW MANAGEMENT
-- =============================================================================
vcmd('n', '<leader>bd', 'workbench.action.closeActiveEditor', { desc = 'Buffer: Delete' })
-- H / L: vscode-neovim translates :bprevious/:bnext natively — no override needed.

-- Window splits: use VSCode-native commands so splits are VSCode editor groups,
-- not Neovim window splits (which have no meaning in vscode-neovim).
vcmd('n', '<leader>wv', 'workbench.action.splitEditor',        { desc = 'Window: Vertical Split' })
vcmd('n', '<leader>ws', 'workbench.action.splitEditorDown',    { desc = 'Window: Split Horizontal' })
vcmd('n', '<leader>wq', 'workbench.action.closeActiveEditor',  { desc = 'Window: Quit Current' })
vcmd('n', '<leader>wo', 'workbench.action.closeOtherEditors',  { desc = 'Window: Close Others' })
vcmd('n', '<leader>w=', 'workbench.action.evenEditorWidths',   { desc = 'Window: Equalize Sizes' })

-- =============================================================================
-- TERMINAL / TUI  (replaces snacks.terminal factory)
-- =============================================================================
vcmd({ 'n', 't' }, '<C-\\>', 'workbench.action.terminal.toggleTerminal', { desc = 'Terminal: Toggle' })
vcmd('n', '<leader>ta', 'workbench.action.tasks.runTask', { args = { 'Aider AI' },             desc = 'Terminal: Aider AI' })
vcmd('n', '<leader>tp', 'workbench.action.tasks.runTask', { args = { 'Process Monitor (btm)' }, desc = 'Terminal: Process Monitor' })
vcmd('n', '<leader>ts', 'workbench.action.tasks.runTask', { args = { 'Spotify Player' },        desc = 'Terminal: Spotify' })

-- =============================================================================
-- DEBUG  (replaces nvim-dap)
-- =============================================================================
vcmd('n', '<leader>db', 'editor.debug.action.toggleBreakpoint', { desc = 'Debug: Toggle Breakpoint' })
vcmd('n', '<leader>dc', 'workbench.action.debug.continue',      { desc = 'Debug: Continue' })
vcmd('n', '<leader>du', 'workbench.view.debug',                  { desc = 'Debug: Toggle UI' })
vcmd('n', '<leader>dr', 'workbench.action.debug.toggleRepl',    { desc = 'Debug: Toggle REPL' })
vcmd('n', '<F5>',  'workbench.action.debug.start',    { desc = 'Debug: Start' })
vcmd('n', '<F10>', 'workbench.action.debug.stepOver',  { desc = 'Debug: Step Over' })
vcmd('n', '<F11>', 'workbench.action.debug.stepInto',  { desc = 'Debug: Step Into' })
vcmd('n', '<F12>', 'workbench.action.debug.stepOut',   { desc = 'Debug: Step Out' })

-- =============================================================================
-- PLATFORMIO  (replaces workflow/toggleterm.lua PIO terminal commands)
-- =============================================================================
vcmd('n', '<leader>pb', 'workbench.action.tasks.runTask', { args = { 'PIO: Build' },                   desc = 'PIO: Build' })
vcmd('n', '<leader>pu', 'workbench.action.tasks.runTask', { args = { 'PIO: Upload' },                  desc = 'PIO: Upload Firmware' })
vcmd('n', '<leader>pm', 'workbench.action.tasks.runTask', { args = { 'PIO: Monitor' },                 desc = 'PIO: Serial Monitor' })
vcmd('n', '<leader>pc', 'workbench.action.tasks.runTask', { args = { 'PIO: Generate Compilation DB' }, desc = 'PIO: Compile DB' })

-- =============================================================================
-- UTILITIES
-- =============================================================================
-- Yank path (replaces utilities.lua yank commands)
vcmd('n', '<leader>yp', 'workbench.action.files.copyFilePath', { desc = 'Yank: Absolute Path' })

-- Clear search highlights: leave to core/keymaps.lua (<leader><space> → :nohlsearch)
-- Session management: VSCode handles this natively via workspace restore

return M
