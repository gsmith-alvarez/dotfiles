-- =============================================================================
-- [ MARKDOWN / OBSIDIAN KEYMAPS ]
-- Buffer-local mappings for Markdown files and Obsidian integration.
-- =============================================================================

local u = Config.safe_require("core.utils")
if not u then return end

local autolist = Config.safe_require("autolist")

-- Helper to ensure Obsidian is loaded and to set buffer-local maps
local map = function(mode, keys, func, desc)
	vim.keymap.set(mode, keys, func, { buffer = true, desc = "Obsidian: " .. desc })
end

-- 1. [ SMART ACTIONS ]
map("n", "<leader>oa", function()
	if require("obsidian.api").cursor_link() then
		return "<cmd>Obsidian follow_link<CR>"
	else
		return "<cmd>Obsidian toggle_checkbox<CR>"
	end
end, "Smart Action (expr)")
-- We need to re-set it with expr = true
vim.keymap.set("n", "<leader>oa", function()
	if require("obsidian.api").cursor_link() then
		return "<cmd>Obsidian follow_link<CR>"
	else
		return "<cmd>Obsidian toggle_checkbox<CR>"
	end
end, { buffer = true, expr = true, desc = "Obsidian: Smart Action" })

-- 2. [ NAVIGATION & LINKS ]
map("n", "<leader>of", "<cmd>Obsidian follow_link tab<CR>", "Follow Link (New Tab)")
map("n", "<leader>ov", "<cmd>Obsidian follow_link vsplit<CR>", "Follow Link (V-Split)")
map("n", "<leader>oh", "<cmd>Obsidian follow_link hsplit<CR>", "Follow Link (H-Split)")
map("n", "<leader>oc", "<cmd>Obsidian toc<CR>", "Contents (TOC)")
map("n", "<leader>oo", "<cmd>Obsidian open<CR>", "Open in GUI")

-- 3. [ SEARCH ]
map("n", "<leader>os", "<cmd>Obsidian search<CR>", "Search Notes")
map("n", "<leader>oq", "<cmd>Obsidian quick_switch<CR>", "Quick Switch")
map("n", "<leader>ot", "<cmd>Obsidian tags<CR>", "Search Tags")

-- 4. [ NOTE CREATION ]
map("n", "<leader>on", "<cmd>Obsidian new<CR>", "New Note")
map("n", "<leader>ou", "<cmd>Obsidian unique_note<CR>", "Unique Note")
map("n", "<leader>oT", "<cmd>Obsidian template<CR>", "Insert Template")

-- 5. [ VISUAL MODE ]
map("v", "<leader>oe", "<cmd>Obsidian extract_note<CR>", "Extract Note")
map("v", "<leader>ol", "<cmd>Obsidian link<CR>", "Link Selection")
map("v", "<leader>oN", "<cmd>Obsidian link_new<CR>", "Link Selection to New")

-- 6. [ MEDIA ]
map("n", "<leader>op", "<cmd>Obsidian paste_img<CR>", "Paste Image")

-- 7. [ OVERRIDES ]
vim.keymap.set("i", "<Tab>", "<cmd>AutolistTab<CR>", { buffer = true, desc = "Autolist: Indent" })
vim.keymap.set("i", "<S-Tab>", "<cmd>AutolistShiftTab<CR>", { buffer = true, desc = "Autolist: Dedent" })
vim.keymap.set("i", "<CR>", "<CR><cmd>AutolistNewBullet<CR>", { buffer = true, desc = "Autolist: New Bullet" })
vim.keymap.set("n", "o", "o<cmd>AutolistNewBullet<CR>", { buffer = true, desc = "Autolist: New Bullet Below" })
vim.keymap.set("n", "O", "O<cmd>AutolistNewBulletBefore<CR>", { buffer = true, desc = "Autolist: New Bullet Above" })

-- Give <CR> to checkbox toggle, link follow, or jump2d.
vim.keymap.set("n", "<CR>", function()
	local line = vim.api.nvim_get_current_line()
	if line:match("%[[ xX/%-!?]%]") then
		autolist.toggle_checkbox()
		return
	end
	if require("obsidian.api").cursor_link() then
		vim.cmd("Obsidian follow_link")
	else
		require("mini.jump2d").start(require("mini.jump2d").builtin_opts.word_start)
	end
end, { buffer = true, desc = "Toggle Checkbox, Jump, or Follow Link" })
