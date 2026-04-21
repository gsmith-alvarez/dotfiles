-- =============================================================================
-- [ KEYMAPS ]
-- Fundamental Keyboard Interaction Layer.
-- Defines global keybindings that do not depend on external plugins.
-- =============================================================================

local M = {}
local u = Config.safe_require("core.utils")
if not u then
	return
end

-- 1. [ TERMINAL MODE ]
u.map("t", "<Esc><Esc>", [[<C-\><C-n>]], "Terminal: Exit Mode")

-- 2. [ WINDOW & SPLIT MANAGEMENT ]
u.nmap("<leader>wv", "<cmd>vsplit<CR>", "Window: Split Vertically")
u.nmap("<leader>ws", "<cmd>split<CR>", "Window: Split Horizontally")
u.nmap("<leader>wq", "<cmd>quit<CR>", "Window: Close Current Window")
u.nmap("<leader>wo", "<C-w>o", "Window: Close Other Windows")
u.nmap("<leader>w=", "<C-w>=", "Window: Equalize Sizes")
u.nmap("<leader>wx", "<C-w>x", "Window: Swap with Next Window")

u.nmap("<C-Up>", "<cmd>resize +2<cr>", "Window: Resize Up")
u.nmap("<C-Down>", "<cmd>resize -2<cr>", "Window: Resize Down")
u.nmap("<C-Left>", "<cmd>vertical resize -2<cr>", "Window: Resize Left")
u.nmap("<C-Right>", "<cmd>vertical resize +2<cr>", "Window: Resize Right")

u.nmap("<leader>-", "<C-w>s", "Window: Split Horizontally", { remap = true })
u.nmap("<leader>|", "<C-w>v", "Window: Split Vertically", { remap = true })

-- 3. [ NAVIGATION ]
u.nmap("<C-h>", "<C-w><C-h>", "Window: Focus Left")
u.nmap("<C-l>", "<C-w><C-l>", "Window: Focus Right")
u.nmap("<C-j>", "<C-w><C-j>", "Window: Focus Down")
u.nmap("<C-k>", "<C-w><C-k>", "Window: Focus Up")

-- 4. [ EDITING PRIMITIVES ]
u.map({ "n", "x" }, "s", "<Nop>", "Prefix: Disable Surround")

u.map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", "Move: Visual Up", { expr = true, silent = true })
u.map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", "Move: Visual Down", { expr = true, silent = true })

-- 5. [ SEARCH ENHANCEMENTS ]
u.nmap("<Esc>", "<cmd>nohlsearch<CR>", "Search: Clear Highlight")
u.map("n", "n", "'Nn'[v:searchforward] . 'zv'", "Search: Next Result", { expr = true })
u.map("n", "N", "'nN'[v:searchforward] . 'zv'", "Search: Prev Result", { expr = true })
u.map({ "x", "o" }, "n", "'Nn'[v:searchforward]", "Search: Next Result", { expr = true })
u.map({ "x", "o" }, "N", "'nN'[v:searchforward]", "Search: Prev Result", { expr = true })

-- 6. [ VISUAL MODE INDENTATION ]
u.map("x", "<", "<gv", "Edit: Indent Left (keep selected)")
u.map("x", ">", ">gv", "Edit: Indent Right (keep selected)")

-- 7. [ INSERT MODE UNDO BREAKPOINTS ]
u.imap(",", ",<C-g>u", nil)
u.imap(".", ".<C-g>u", nil)
u.imap(";", ";<C-g>u", nil)

-- 8. [ BUFFER NAVIGATION ]
u.nmap("H", "<cmd>bprevious<CR>", "Buffer: Go to Previous")
u.nmap("L", "<cmd>bnext<CR>", "Buffer: Go to Next")
u.nmap("[b", "<cmd>bprevious<CR>", "Buffer: Go to Previous")
u.nmap("]b", "<cmd>bnext<CR>", "Buffer: Go to Next")
u.nmap("<leader>bb", "<cmd>e #<CR>", "Buffer: Switch to Alternate")
u.nmap("<leader>`", "<cmd>e #<CR>", "Buffer: Switch to Alternate")
u.nmap("<leader>bd", function()
	require("snacks").bufdelete()
end, "Buffer: Delete")
u.nmap("<leader>bD", "<cmd>bp | bd #<CR>", "Buffer: Delete + Close Window")

-- 9. [ QUICKFIX NAVIGATION ]
u.nmap("[q", vim.cmd.cprev, "Quickfix: Go to Previous Item")
u.nmap("]q", vim.cmd.cnext, "Quickfix: Go to Next Item")

-- 10. [ UTILITIES ]
u.map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", "File: Save")
u.nmap("<leader>bn", "<cmd>enew<CR>", "Buffer: Create New")
u.nmap("<leader>qq", "<cmd>qa<CR>", "Session: Exit Neovim")
u.nmap("U", "<cmd>Undotree<CR>", "Tool: Open Undotree")

u.imap("<A-j>", "<esc><cmd>m .+1<cr>==gi", "Edit: Move Line Down")
u.imap("<A-k>", "<esc><cmd>m .-2<cr>==gi", "Edit: Move Line Up")

u.nmap("<C-d>", "<C-d>zz", "Scroll: Down and Center")
u.nmap("<C-u>", "<C-u>zz", "Scroll: Up and Center")

-- 11. [ INSPECT / DIAGNOSTICS ]
u.nmap("<leader>ui", vim.show_pos, "Inspect: Show Highlights")
u.nmap("<leader>uI", function()
	vim.treesitter.inspect_tree()
	vim.api.nvim_input("I")
end, "Inspect: Show Treesitter Tree (Full)")

u.nmap("<leader>cd", vim.diagnostic.open_float, "Diagnostic: Open Floating Message")

return M
