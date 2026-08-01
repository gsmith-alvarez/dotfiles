-- markdown / obsidian keymaps

local u = Config.safe_require("core.utils")
if not u then
	return
end

local autolist = Config.safe_require("autolist")

local function is_list_indent_at_eol()
	local line = vim.api.nvim_get_current_line()
	local col = vim.fn.getpos(".")[3] - 1
	local marker = line:match("^%s*>?%s*(%S+)%s")

	return col >= #line - 1
		and marker ~= nil
		and (marker == "-" or marker == "+" or marker == "*" or marker:match("^%w+[.)]$") ~= nil)
end

local function autolist_tab()
	if is_list_indent_at_eol() then
		vim.schedule(autolist.recalculate)
		return "<C-t>"
	end

	return "<Tab>"
end

local function autolist_shift_tab()
	if is_list_indent_at_eol() then
		vim.schedule(autolist.recalculate)
		return "<C-d>"
	end

	return "<S-Tab>"
end

-- 1. Smart actions
u.nmap("<leader>oa", function()
	return require("obsidian.actions").smart_action()
end, "Obsidian: Smart Action", { buffer = true, expr = true })

-- 2. Navigation & links
u.nmap("<leader>of", "<cmd>Obsidian follow_link tab<CR>", "Obsidian: Follow Link (New Tab)", { buffer = true })
u.nmap("<leader>ov", "<cmd>Obsidian follow_link vsplit<CR>", "Obsidian: Follow Link (V-Split)", { buffer = true })
u.nmap("<leader>oh", "<cmd>Obsidian follow_link hsplit<CR>", "Obsidian: Follow Link (H-Split)", { buffer = true })
u.nmap("<leader>oc", "<cmd>Obsidian toc<CR>", "Obsidian: Contents (TOC)", { buffer = true })
u.nmap("<leader>oo", "<cmd>Obsidian open<CR>", "Obsidian: Open in GUI", { buffer = true })

-- 3. Search
u.nmap("<leader>os", "<cmd>Obsidian search<CR>", "Obsidian: Search Notes", { buffer = true })
u.nmap("<leader>oq", "<cmd>Obsidian quick_switch<CR>", "Obsidian: Quick Switch", { buffer = true })
u.nmap("<leader>ot", "<cmd>Obsidian tags<CR>", "Obsidian: Search Tags", { buffer = true })

-- 4. Note creation
u.nmap("<leader>on", "<cmd>Obsidian new<CR>", "Obsidian: New Note", { buffer = true })
u.nmap("<leader>ou", "<cmd>Obsidian unique_note<CR>", "Obsidian: Unique Note", { buffer = true })
u.nmap("<leader>oT", "<cmd>Obsidian template<CR>", "Obsidian: Insert Template", { buffer = true })

-- 5. Visual mode
u.map("v", "<leader>oe", "<cmd>Obsidian extract_note<CR>", "Obsidian: Extract Note", { buffer = true })
u.map("v", "<leader>ol", "<cmd>Obsidian link<CR>", "Obsidian: Link Selection", { buffer = true })
u.map("v", "<leader>oN", "<cmd>Obsidian link_new<CR>", "Obsidian: Link Selection to New", { buffer = true })

-- 6. Media
u.nmap("<leader>op", "<cmd>Obsidian paste_img<CR>", "Obsidian: Paste Image", { buffer = true })

-- 7. Overrides
u.imap("<Tab>", autolist_tab, "Autolist: Indent", { buffer = true, expr = true })
u.imap("<S-Tab>", autolist_shift_tab, "Autolist: Dedent", { buffer = true, expr = true })
u.imap("<CR>", "<CR><cmd>AutolistNewBullet<CR>", "Autolist: New Bullet", { buffer = true })
u.nmap("o", "o<cmd>AutolistNewBullet<CR>", "Autolist: New Bullet Below", { buffer = true })
u.nmap("O", "O<cmd>AutolistNewBulletBefore<CR>", "Autolist: New Bullet Above", { buffer = true })

u.nmap("<CR>", function()
	local line = vim.api.nvim_get_current_line()
	local obs_api = require("obsidian.api")

	if line:match("%[[ xX/%-!?]%]") then
		autolist.toggle_checkbox()
		return
	end
	if obs_api.cursor_link() then
		vim.cmd("Obsidian follow_link")
	elseif obs_api.cursor_heading() or obs_api.cursor_frontmatter() then
		vim.cmd("normal! za")
	else
		require("mini.jump2d").start(require("mini.jump2d").builtin_opts.word_start)
	end
end, "Obsidian: Toggle Checkbox, Jump, Follow Link, or Cycle Fold", { buffer = true })

-- 8. Notes helper
u.imap("<C-b>", "****<Left><Left>", "Markdown: Bolding")
u.imap("<C-i>", "__<Left>", "Markdown: italics")
