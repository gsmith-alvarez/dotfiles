-- =============================================================================
-- [ KEYMAPS ]
-- Fundamental Keyboard Interaction Layer.
-- Defines global keybindings that do not depend on external plugins.
-- =============================================================================

local M = {}
local u = Config.safe_require "core.utils"
if not u then
	return
end
local map = vim.keymap.set

-- 1. [ TERMINAL MODE ]
u.map("t", "<Esc><Esc>", [[<C-\><C-n>]], "Terminal: Exit Mode")

-- 2. [ WINDOW & SPLIT MANAGEMENT ]
u.nmap("<leader>wv", "<cmd>vsplit<CR>", "Window: Vertical Split")
u.nmap("<leader>ws", "<cmd>split<CR>", "Window: Horizontal Split")
u.nmap("<leader>wq", "<cmd>quit<CR>", "Window: Close Current")
u.nmap("<leader>wo", "<C-w>o", "Window: Close Others")
u.nmap("<leader>w=", "<C-w>=", "Window: Reset Sizes")
u.nmap("<leader>wx", "<C-w>x", "Window: Swap with Next")

map("n", "<leader>-", "<C-w>s", { desc = "Window: Split Horizontal", remap = true })
map("n", "<leader>|", "<C-w>v", { desc = "Window: Split Vertical", remap = true })

-- 3. [ NAVIGATION ]
u.nmap("<C-h>", "<C-w><C-h>", "Window: Focus Left")
u.nmap("<C-l>", "<C-w><C-l>", "Window: Focus Right")
u.nmap("<C-j>", "<C-w><C-j>", "Window: Focus Down")
u.nmap("<C-k>", "<C-w><C-k>", "Window: Focus Up")

-- 4. [ EDITING PRIMITIVES ]
u.map({ "n", "x" }, "s", "<Nop>", "Prefix: Surround")

map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- 5. [ SEARCH ENHANCEMENTS ]
u.nmap("<Esc>", "<cmd>nohlsearch<CR>", "Search: Clear Highlight")
map("n", "n", "'Nn'[v:searchforward] . 'zv'", { expr = true, desc = "Search: Next Result" })
map("n", "N", "'nN'[v:searchforward] . 'zv'", { expr = true, desc = "Search: Prev Result" })
map({ "x", "o" }, "n", "'Nn'[v:searchforward]", { expr = true, desc = "Search: Next Result" })
map({ "x", "o" }, "N", "'nN'[v:searchforward]", { expr = true, desc = "Search: Prev Result" })

-- 6. [ VISUAL MODE INDENTATION ]
u.map("x", "<", "<gv", "Edit: Indent Left (keep selected)")
u.map("x", ">", ">gv", "Edit: Indent Right (keep selected)")

-- 7. [ INSERT MODE UNDO BREAKPOINTS ]
u.imap(",", ",<C-g>u", nil)
u.imap(".", ".<C-g>u", nil)
u.imap(";", ";<C-g>u", nil)

-- 8. [ BUFFER NAVIGATION ]
u.nmap("H", "<cmd>bprevious<CR>", "Buffer: Prev")
u.nmap("L", "<cmd>bnext<CR>", "Buffer: Next")
u.nmap("[b", "<cmd>bprevious<CR>", "Buffer: Prev")
u.nmap("]b", "<cmd>bnext<CR>", "Buffer: Next")
u.nmap("<leader>bb", "<cmd>e #<CR>", "Buffer: Switch to Alternate")
u.nmap("<leader>`", "<cmd>e #<CR>", "Buffer: Switch to Alternate")
u.nmap("<leader>bD", "<cmd>bp | bd #<CR>", "Buffer: Delete + Close Window")

-- 9. [ QUICKFIX NAVIGATION ]
u.nmap("[q", vim.cmd.cprev, "Quickfix: Prev Item")
u.nmap("]q", vim.cmd.cnext, "Quickfix: Next Item")

-- 10. [ UTILITIES ]
u.map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", "File: Save")
u.nmap("<leader>bn", "<cmd>enew<CR>", "New Buffer")
u.nmap("<leader>qq", "<cmd>qa<CR>", "Session: Exit Neovim")
u.nmap("<leader>K", "<cmd>normal! K<CR>", "Keywordprg (man/help)")

u.nmap("<A-j>", ":m .+1<CR>==", "Move Line Down")
u.nmap("<A-k>", ":m .-2<CR>==", "Move Line Up")
u.imap("<A-j>", "<esc><cmd>m .+1<cr>==gi", "Edit: Move Line Down")
u.imap("<A-k>", "<esc><cmd>m .-2<cr>==gi", "Edit: Move Line Up")

u.nmap("<C-d>", "<C-d>zz", "Scroll down and center")
u.nmap("<C-u>", "<C-u>zz", "Scroll up and center")

-- 11. [ UI TOGGLES ]
u.nmap("<leader>uw", function()
	local wo = vim.wo
	wo.wrap = not wo.wrap
	wo.linebreak = wo.wrap
	wo.breakindent = wo.wrap
end, "UI: Toggle Soft-Wrap")

-- 12. [ INSPECT / DIAGNOSTICS ]
u.nmap("<leader>ui", vim.show_pos, "Inspect: Highlights")
u.nmap("<leader>uI", function()
	vim.treesitter.inspect_tree()
	vim.api.nvim_input "I"
end, "Inspect: Treesitter (full tree)")

u.nmap("<leader>cd", vim.diagnostic.open_float, "Open floating diagnostic message")

return M
