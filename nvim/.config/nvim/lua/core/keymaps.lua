-- =============================================================================
-- [ KEYMAPS ]
-- Fundamental Keyboard Interaction Layer.
-- Defines global keybindings that do not depend on external plugins.
-- =============================================================================

local M = {}

-- 1. [ TERMINAL MODE ]
-- Exit terminal mode with a quick double-press of Esc, making it more intuitive
-- than the default <C-\><C-n>.
vim.keymap.set('t', '<Esc><Esc>', [[<C-\><C-n>]], { desc = 'Terminal: Exit Mode' })

-- 2. [ WINDOW & SPLIT MANAGEMENT ]
-- Use <leader>w as a prefix for ergonomic window controls.
vim.keymap.set('n', '<leader>wv', '<cmd>vsplit<CR>', { desc = 'Window: Vertical Split' })
vim.keymap.set('n', '<leader>ws', '<cmd>split<CR>', { desc = 'Window: Horizontal Split' })
vim.keymap.set('n', '<leader>wq', '<cmd>quit<CR>', { desc = 'Window: Close Current' })
vim.keymap.set('n', '<leader>wo', '<C-w>o', { desc = 'Window: Close Others' })
vim.keymap.set('n', '<leader>w=', '<C-w>=', { desc = 'Window: Reset Sizes' })
vim.keymap.set('n', '<leader>wx', '<C-w>x', { desc = 'Window: Swap with Next' })

-- Mnemonic aliases for fast splitting.
vim.keymap.set('n', '<leader>-', '<C-w>s', { desc = 'Window: Split Horizontal', remap = true })
vim.keymap.set('n', '<leader>|', '<C-w>v', { desc = 'Window: Split Vertical', remap = true })

-- 3. [ NAVIGATION ]
-- Move between windows using Ctrl + hjkl, bypassing the need for <C-w>.
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Window: Focus Left' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Window: Focus Right' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Window: Focus Down' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Window: Focus Up' })

-- 4. [ EDITING PRIMITIVES ]
-- Disable 's' (native substitute) to use it as a prefix for other operations (like surround).
vim.keymap.set({ 'n', 'x' }, 's', '<Nop>', { desc = 'Prefix: Surround' })

-- Remap j/k to move visually when lines wrap, unless a count is provided (e.g. 10j).
vim.keymap.set({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- 5. [ SEARCH ENHANCEMENTS ]
-- Ensure 'n' always moves forward and 'N' always moves backward, regardless
-- of whether the search was initiated with / or ?. Includes 'zv' to open folds.
vim.keymap.set('n', 'n', "'Nn'[v:searchforward] . 'zv'", { expr = true, desc = 'Search: Next Result' })
vim.keymap.set('n', 'N', "'nN'[v:searchforward] . 'zv'", { expr = true, desc = 'Search: Prev Result' })
vim.keymap.set({ 'x', 'o' }, 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Search: Next Result' })
vim.keymap.set({ 'x', 'o' }, 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Search: Prev Result' })

-- 6. [ VISUAL MODE INDENTATION ]
-- Re-select the visual area after indenting to allow for multiple indentations
-- without having to press 'v' again.
vim.keymap.set('x', '<', '<gv', { desc = 'Edit: Indent Left (keep selected)' })
vim.keymap.set('x', '>', '>gv', { desc = 'Edit: Indent Right (keep selected)' })

-- 7. [ INSERT MODE UNDO BREAKPOINTS ]
-- Create undo breakpoints when typing punctuation, so 'u' only reverts small chunks.
vim.keymap.set('i', ',', ',<C-g>u')
vim.keymap.set('i', '.', '.<C-g>u')
vim.keymap.set('i', ';', ';<C-g>u')

-- 8. [ BUFFER NAVIGATION ]
-- High-speed navigation between open buffers.
vim.keymap.set('n', 'H', '<cmd>bprevious<CR>', { desc = 'Buffer: Prev' })
vim.keymap.set('n', 'L', '<cmd>bnext<CR>', { desc = 'Buffer: Next' })
vim.keymap.set('n', '[b', '<cmd>bprevious<CR>', { desc = 'Buffer: Prev' })
vim.keymap.set('n', ']b', '<cmd>bnext<CR>', { desc = 'Buffer: Next' })
vim.keymap.set('n', '<leader>bb', '<cmd>e #<CR>', { desc = 'Buffer: Switch to Alternate' })
vim.keymap.set('n', '<leader>`', '<cmd>e #<CR>', { desc = 'Buffer: Switch to Alternate' })
vim.keymap.set('n', '<leader>bD', '<cmd>bp | bd #<CR>', { desc = 'Buffer: Delete + Close Window' })

-- 9. [ QUICKFIX NAVIGATION ]
-- Easily traverse the quickfix list.
vim.keymap.set('n', '[q', vim.cmd.cprev, { desc = 'Quickfix: Prev Item' })
vim.keymap.set('n', ']q', vim.cmd.cnext, { desc = 'Quickfix: Next Item' })

-- 10. [ UTILITIES ]
-- Save the file from any mode with Ctrl + S.
vim.keymap.set({ 'i', 'x', 'n', 's' }, '<C-s>', '<cmd>w<cr><esc>', { desc = 'File: Save' })
vim.keymap.set('n', '<leader>fn', '<cmd>enew<CR>', { desc = 'File: New Buffer' })
vim.keymap.set('n', '<leader>qq', '<cmd>qa<CR>', { desc = 'Session: Exit Neovim' })
vim.keymap.set('n', '<leader>K', '<cmd>normal! K<CR>', { desc = 'Keywordprg (man/help)' })

-- Move lines up or down with Alt + j/k.
vim.keymap.set('n', '<A-j>', ':m .+1<CR>==', { desc = 'Move Line Down' })
vim.keymap.set('n', '<A-k>', ':m .-2<CR>==', { desc = 'Move Line Up' })
vim.keymap.set('i', '<A-j>', '<esc><cmd>m .+1<cr>==gi', { desc = 'Edit: Move Line Down' })
vim.keymap.set('i', '<A-k>', '<esc><cmd>m .-2<cr>==gi', { desc = 'Edit: Move Line Up' })

-- Center the screen while scrolling half-pages.
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down and center' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up and center' })

-- 11. [ UI TOGGLES ]
-- Toggle soft line wrapping.
vim.keymap.set('n', '<leader>uw', function()
  local wo = vim.wo
  wo.wrap = not wo.wrap
  wo.linebreak = wo.wrap
  wo.breakindent = wo.wrap
end, { desc = 'UI: Toggle Soft-Wrap' })

-- 12. [ INSPECT / DIAGNOSTICS ]
-- Inspect highlights or Treesitter nodes under the cursor.
vim.keymap.set('n', '<leader>ui', vim.show_pos, { desc = 'Inspect: Highlights' })
vim.keymap.set('n', '<leader>uI', function()
  vim.treesitter.inspect_tree()
  vim.api.nvim_input 'I'
end, { desc = 'Inspect: Treesitter (full tree)' })

-- Open floating diagnostic window for the current line.
vim.keymap.set('n', '<leader>cd', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })

return M

