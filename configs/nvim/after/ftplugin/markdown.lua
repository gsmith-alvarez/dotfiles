-- markdown keymaps

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

-- List editing
u.imap("<Tab>", autolist_tab, "Autolist: Indent", { buffer = true, expr = true })
u.imap("<S-Tab>", autolist_shift_tab, "Autolist: Dedent", { buffer = true, expr = true })
u.imap("<CR>", "<CR><cmd>AutolistNewBullet<CR>", "Autolist: New Bullet", { buffer = true })
u.nmap("o", "o<cmd>AutolistNewBullet<CR>", "Autolist: New Bullet Below", { buffer = true })
u.nmap("O", "O<cmd>AutolistNewBulletBefore<CR>", "Autolist: New Bullet Above", { buffer = true })

u.nmap("<CR>", function()
	local line = vim.api.nvim_get_current_line()

	if line:match("%[[ xX/%-!?]%]") then
		autolist.toggle_checkbox()
		return
	end

	require("mini.jump2d").start(require("mini.jump2d").builtin_opts.word_start)
end, "Markdown: Toggle Checkbox or Jump", { buffer = true })

-- Markdown text helpers
u.imap("<C-b>", "****<Left><Left>", "Markdown: Bolding")
u.imap("<C-i>", "__<Left>", "Markdown: italics")

-- Prose wrapping: hard-wrap at 120 and show the wrap-point marker.
vim.opt_local.colorcolumn = "+1"
vim.opt_local.formatoptions:append({ "t" }) -- wrap at textwidth while typing
