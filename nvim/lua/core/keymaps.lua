-- [[ CORE KEYMAPS DOMAIN ]]
-- Domain: Global Navigation & Window Management
--
-- PHILOSOPHY: Home-Row Efficiency & Layout Control
-- Contains ONLY foundational editor mappings. Domain-specific mappings
-- (LSP, Formatting, Mux) are strictly encapsulated in their respective modules.

local M = {}

-- [[ 1. TERMINAL INTEROP ]]
vim.keymap.set('t', '<Esc><Esc>', [[<C-\><C-n>]], { desc = 'Terminal: Exit Mode' })

-- [[ 2. WINDOW & SPLIT MANAGEMENT ]]
vim.keymap.set('n', '<leader>wv', '<cmd>vsplit<CR>', { desc = 'Window: Vertical Split' })
vim.keymap.set('n', '<leader>ws', '<cmd>split<CR>',  { desc = 'Window: Split Horizontal' })
vim.keymap.set('n', '<leader>wq', '<cmd>quit<CR>',   { desc = 'Window: Quit Current' })
vim.keymap.set('n', '<leader>wo', '<C-w>o',          { desc = 'Window: Close Others' })
vim.keymap.set('n', '<leader>w=', '<C-w>=',          { desc = 'Window: Equalize Sizes' })
vim.keymap.set('n', '<leader>wx', '<C-w>x',          { desc = 'Window: Swap Next' })
-- Convenience aliases matching LazyVim muscle memory
vim.keymap.set('n', '<leader>-',  '<C-w>s', { desc = 'Window: Split Below', remap = true })
vim.keymap.set('n', '<leader>|',  '<C-w>v', { desc = 'Window: Split Right', remap = true })

-- [[ 3. NAVIGATION: Smart Multi-Pane Movement ]]
-- NOTE: overridden by smart-splits when loaded (Neovim ↔ Zellij)
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Window: Focus Left' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Window: Focus Right' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Window: Focus Down' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Window: Focus Up' })

-- [[ 4. TEXT EDITING: Soft-wrap-aware motion ]]
-- Applies to both normal and visual modes; falls back to line-count motion when a count is given.
vim.keymap.set({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ 5. SANER SEARCH: n/N always go forward/backward ]]
-- Regardless of whether the search was initiated with / or ?, n always moves
-- forward and N always moves backward. Also opens any closed folds (`zv`).
vim.keymap.set('n', 'n', "'Nn'[v:searchforward].'zv'", { expr = true, desc = 'Search: Next Result' })
vim.keymap.set('x', 'n', "'Nn'[v:searchforward]",      { expr = true, desc = 'Search: Next Result' })
vim.keymap.set('o', 'n', "'Nn'[v:searchforward]",      { expr = true, desc = 'Search: Next Result' })
vim.keymap.set('n', 'N', "'nN'[v:searchforward].'zv'", { expr = true, desc = 'Search: Prev Result' })
vim.keymap.set('x', 'N', "'nN'[v:searchforward]",      { expr = true, desc = 'Search: Prev Result' })
vim.keymap.set('o', 'N', "'nN'[v:searchforward]",      { expr = true, desc = 'Search: Prev Result' })

-- [[ 6. VISUAL MODE: Stay in visual after indenting ]]
vim.keymap.set('x', '<', '<gv', { desc = 'Edit: Indent Left' })
vim.keymap.set('x', '>', '>gv', { desc = 'Edit: Indent Right' })

-- [[ 7. INSERT MODE: Undo break-points at punctuation ]]
-- Inserts a `<C-g>u` undo checkpoint after common sentence-ending characters.
-- This means `u` in normal mode can undo one "thought" rather than wiping the whole insert session.
vim.keymap.set('i', ',', ',<C-g>u')
vim.keymap.set('i', '.', '.<C-g>u')
vim.keymap.set('i', ';', ';<C-g>u')

-- [[ 8. BUFFER NAVIGATION ]]
vim.keymap.set('n', 'H',           '<cmd>bprevious<CR>', { desc = 'Buffer: Prev' })
vim.keymap.set('n', 'L',           '<cmd>bnext<CR>',     { desc = 'Buffer: Next' })
vim.keymap.set('n', '<leader>bb',  '<cmd>e #<CR>',       { desc = 'Buffer: Switch to Alternate' })
vim.keymap.set('n', '<leader>`',   '<cmd>e #<CR>',       { desc = 'Buffer: Switch to Alternate' })
vim.keymap.set('n', '<leader>bD',  '<cmd>bd<CR>',        { desc = 'Buffer: Delete + Close Window' })

-- [[ 9. QUICKFIX NAVIGATION ]]
vim.keymap.set('n', '[q', vim.cmd.cprev, { desc = 'Quickfix: Prev Item' })
vim.keymap.set('n', ']q', vim.cmd.cnext, { desc = 'Quickfix: Next Item' })

-- [[ 10. MISC EDITOR UTILS ]]
vim.keymap.set({ 'i', 'x', 'n', 's' }, '<C-s>',      '<cmd>w<cr><esc>',    { desc = 'File: Save' })
vim.keymap.set('n',                     '<leader>fn',  '<cmd>enew<CR>',      { desc = 'File: New' })
vim.keymap.set('n',                     '<leader>qq',  '<cmd>qa<CR>',        { desc = 'Session: Quit All' })
vim.keymap.set('n',                     '<leader>K',   '<cmd>norm! K<CR>',   { desc = 'Code: Keywordprg' })

-- [[ 11. LINE MOVE: <A-j>/<A-k> in normal + insert ]]
-- Visual mode <M-j>/<M-k> is owned by mini.move (block move).
-- Normal/insert modes are free — wire them to :move like LazyVim.
vim.keymap.set('n', '<A-j>', '<cmd>m .+1<cr>==',        { desc = 'Edit: Move Line Down' })
vim.keymap.set('n', '<A-k>', '<cmd>m .-2<cr>==',        { desc = 'Edit: Move Line Up' })
vim.keymap.set('i', '<A-j>', '<esc><cmd>m .+1<cr>==gi', { desc = 'Edit: Move Line Down' })
vim.keymap.set('i', '<A-k>', '<esc><cmd>m .-2<cr>==gi', { desc = 'Edit: Move Line Up' })

-- [[ 12. INSPECT / DEBUG HELPERS ]]
vim.keymap.set('n', '<leader>ui', vim.show_pos, { desc = 'Inspect: Highlight under cursor' })
vim.keymap.set('n', '<leader>uI', function()
	vim.treesitter.inspect_tree()
	vim.api.nvim_input('I')
end, { desc = 'Inspect: Treesitter tree' })

return M
