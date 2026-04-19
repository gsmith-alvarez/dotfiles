-- =============================================================================
-- [ KEYMAPS ]
-- Fundamental Keyboard Interaction Layer.
-- Defines global keybindings that do not depend on external plugins.
-- =============================================================================

local M = {}
local u = require('core.utils')
local map = vim.keymap.set

-- 1. [ TERMINAL MODE ]
-- Exit terminal mode with a quick double-press of Esc.
u.map('t', '<Esc><Esc>', [[<C-\><C-n>]], 'Terminal: Exit Mode')

-- 2. [ WINDOW & SPLIT MANAGEMENT ]
-- Use <leader>w as a prefix for ergonomic window controls.
u.nmap('<leader>wv', '<cmd>vsplit<CR>', 'Window: Vertical Split')
u.nmap('<leader>ws', '<cmd>split<CR>', 'Window: Horizontal Split')
u.nmap('<leader>wq', '<cmd>quit<CR>', 'Window: Close Current')
u.nmap('<leader>wo', '<C-w>o', 'Window: Close Others')
u.nmap('<leader>w=', '<C-w>=', 'Window: Reset Sizes')
u.nmap('<leader>wx', '<C-w>x', 'Window: Swap with Next')

-- Mnemonic aliases for fast splitting.
-- Keep explicit for 'remap' capability.
map('n', '<leader>-', '<C-w>s', { desc = 'Window: Split Horizontal', remap = true })
map('n', '<leader>|', '<C-w>v', { desc = 'Window: Split Vertical', remap = true })

-- 3. [ NAVIGATION ]
-- Move between windows using Ctrl + hjkl.
u.nmap('<C-h>', '<C-w><C-h>', 'Window: Focus Left')
u.nmap('<C-l>', '<C-w><C-l>', 'Window: Focus Right')
u.nmap('<C-j>', '<C-w><C-j>', 'Window: Focus Down')
u.nmap('<C-k>', '<C-w><C-k>', 'Window: Focus Up')

-- 4. [ EDITING PRIMITIVES ]
-- Disable 's' (native substitute) to use it as a prefix for other operations.
u.map({ 'n', 'x' }, 's', '<Nop>', 'Prefix: Surround')

-- Remap j/k to move visually when lines wrap.
-- Keep explicit for 'expr' and 'silent' capabilities.
map({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- 5. [ SEARCH ENHANCEMENTS ]
-- Keep explicit for 'expr' capability.
map('n', 'n', "'Nn'[v:searchforward] . 'zv'", { expr = true, desc = 'Search: Next Result' })
map('n', 'N', "'nN'[v:searchforward] . 'zv'", { expr = true, desc = 'Search: Prev Result' })
map({ 'x', 'o' }, 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Search: Next Result' })
map({ 'x', 'o' }, 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Search: Prev Result' })

-- 6. [ VISUAL MODE INDENTATION ]
u.map('x', '<', '<gv', 'Edit: Indent Left (keep selected)')
u.map('x', '>', '>gv', 'Edit: Indent Right (keep selected)')

-- 7. [ INSERT MODE UNDO BREAKPOINTS ]
-- Note: These do not have descriptions to avoid popup clutter.
u.imap(',', ',<C-g>u', nil)
u.imap('.', '.<C-g>u', nil)
u.imap(';', ';<C-g>u', nil)

-- 8. [ BUFFER NAVIGATION ]
u.nmap('H', '<cmd>bprevious<CR>', 'Buffer: Prev')
u.nmap('L', '<cmd>bnext<CR>', 'Buffer: Next')
u.nmap('[b', '<cmd>bprevious<CR>', 'Buffer: Prev')
u.nmap(']b', '<cmd>bnext<CR>', 'Buffer: Next')
u.nmap('<leader>bb', '<cmd>e #<CR>', 'Buffer: Switch to Alternate')
u.nmap('<leader>`', '<cmd>e #<CR>', 'Buffer: Switch to Alternate')
u.nmap('<leader>bD', '<cmd>bp | bd #<CR>', 'Buffer: Delete + Close Window')

-- 9. [ QUICKFIX NAVIGATION ]
u.nmap('[q', vim.cmd.cprev, 'Quickfix: Prev Item')
u.nmap(']q', vim.cmd.cnext, 'Quickfix: Next Item')

-- 10. [ UTILITIES ]
u.map({ 'i', 'x', 'n', 's' }, '<C-s>', '<cmd>w<cr><esc>', 'File: Save')
u.nmap('<leader>fn', '<cmd>enew<CR>', 'File: New Buffer')
u.nmap('<leader>qq', '<cmd>qa<CR>', 'Session: Exit Neovim')
u.nmap('<leader>K', '<cmd>normal! K<CR>', 'Keywordprg (man/help)')

-- Move lines up or down with Alt + j/k.
u.nmap('<A-j>', ':m .+1<CR>==', 'Move Line Down')
u.nmap('<A-k>', ':m .-2<CR>==', 'Move Line Up')
u.imap('<A-j>', '<esc><cmd>m .+1<cr>==gi', 'Edit: Move Line Down')
u.imap('<A-k>', '<esc><cmd>m .-2<cr>==gi', 'Edit: Move Line Up')

-- Center the screen while scrolling half-pages.
u.nmap('<C-d>', '<C-d>zz', 'Scroll down and center')
u.nmap('<C-u>', '<C-u>zz', 'Scroll up and center')

-- 11. [ UI TOGGLES ]
u.nmap('<leader>uw', function()
  local wo = vim.wo
  wo.wrap = not wo.wrap
  wo.linebreak = wo.wrap
  wo.breakindent = wo.wrap
end, 'UI: Toggle Soft-Wrap')

-- 12. [ INSPECT / DIAGNOSTICS ]
-- Note: Native LSP defaults are active (grn: Rename, gra: Code Action,
-- grr: References, gri: Implementation, gO: Symbols, K: Hover).
-- Advanced overrides are managed in lua/autocmds/lsp.lua.
u.nmap('<leader>ui', vim.show_pos, 'Inspect: Highlights')
u.nmap('<leader>uI', function()
  vim.treesitter.inspect_tree()
  vim.api.nvim_input('I')
end, 'Inspect: Treesitter (full tree)')

u.nmap('<leader>cd', vim.diagnostic.open_float, 'Open floating diagnostic message')

return M
