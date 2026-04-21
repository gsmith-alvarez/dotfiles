-- =============================================================================
-- [ MENU.LUA ]
-- Right-click popup menu with safe, context-aware actions.
-- Inspired by TJ DeVries' Neovim popup menu setup.
-- =============================================================================
local M = {}

vim.opt.mousemodel = "popup"

-- Disable Neovim's default MenuPopup autocmd so it doesn't fight ours.
-- The default group is "nvim.popupmenu" (with a dot) in 0.11+.
pcall(vim.api.nvim_del_augroup_by_name, "nvim.popupmenu")

-- ---------- helpers ---------------------------------------------------------

local function has_lsp()
	return next(vim.lsp.get_clients({ bufnr = 0 })) ~= nil
end

local function notify(msg)
	vim.notify(msg, vim.log.levels.INFO, { title = "Popup Menu" })
end

local function open_url_under_cursor()
	local word = vim.fn.expand("<cfile>")
	if not word or word == "" or not word:match("^https?://") then
		notify("No URL under cursor")
		return
	end
	if vim.ui and vim.ui.open then
		vim.ui.open(word)
		return
	end
	local opener = vim.fn.has("mac") == 1 and "open" or "xdg-open"
	vim.fn.jobstart({ opener, word }, { detach = true })
end

---@param action fun()
---@param fallback_msg? string
local function with_lsp(action, fallback_msg)
	if not has_lsp() then
		notify(fallback_msg or "No LSP client attached")
		return
	end
	action()
end

local function current_file_path()
	local path = vim.api.nvim_buf_get_name(0)
	if path == "" then
		return nil
	end
	return vim.fn.fnamemodify(path, ":p")
end

local function copy_file_path()
	local path = current_file_path()
	if not path then
		notify("No file path to copy")
		return
	end
	vim.fn.setreg("+", path)
	notify("Copied file path")
end

-- All menu manipulation goes through this so a missing item never throws.
local function menu(cmd)
	vim.cmd("silent! " .. cmd)
end

-- ---------- menu definitions -----------------------------------------------

-- Wipe potentially-existing items before redefining (silent so first load is fine).
local items = {
	"Go\\ to\\ definition",
	"References",
	"Implementation",
	"Hover",
	"Code\\ Action",
	"Rename",
	"Copy\\ File\\ Path",
	"Open\\ in\\ web\\ browser",
	"Git\\ Browse",
}
for _, item in ipairs(items) do
	menu("aunmenu PopUp." .. item)
end

-- Define our items via the silent helper too — anoremenu doesn't error on redefine,
-- but staying consistent keeps load-order surprises out of the picture.
menu([[aunmenu   PopUp]])
menu([[anoremenu PopUp.Inspect <Cmd>Inspect<CR>]])
menu([[amenu     PopUp.-1- <Nop>]])
menu([[anoremenu PopUp.Go\ to\ definition <Cmd>lua require('plugins.menu').go_to_definition()<CR>]])
menu([[anoremenu PopUp.References         <Cmd>lua require('plugins.menu').references()<CR>]])
menu([[anoremenu PopUp.Implementation     <Cmd>lua require('plugins.menu').implementation()<CR>]])
menu([[anoremenu PopUp.Hover              <Cmd>lua require('plugins.menu').hover()<CR>]])
menu([[amenu     PopUp.-2- <Nop>]])
menu([[anoremenu PopUp.Code\ Action       <Cmd>lua require('plugins.menu').code_actions()<CR>]])
menu([[anoremenu PopUp.Rename             <Cmd>lua require('plugins.menu').rename()<CR>]])
menu([[amenu     PopUp.-3- <Nop>]])
menu([[nnoremenu PopUp.Back               <C-t>]])
menu([[anoremenu PopUp.Copy\ File\ Path   <Cmd>lua require('plugins.menu').copy_file_path()<CR>]])
menu([[anoremenu PopUp.Open\ in\ web\ browser <Cmd>lua require('plugins.menu').open_url()<CR>]])
menu([[amenu     PopUp.-4- <Nop>]])
menu([[anoremenu PopUp.Git\ Browse        <Cmd>lua require('plugins.menu').git_browse()<CR>]])

-- ---------- context-aware enable/disable -----------------------------------

local group = vim.api.nvim_create_augroup("user_popupmenu", { clear = true })

vim.api.nvim_create_autocmd("MenuPopup", {
	pattern = "*",
	group = group,
	desc = "Context-aware popup menu",
	callback = function()
		local toggleable = {
			"Go\\ to\\ definition",
			"References",
			"Implementation",
			"Hover",
			"Code\\ Action",
			"Rename",
			"Open\\ in\\ web\\ browser",
			"Copy\\ File\\ Path",
			"Git\\ Browse",
		}
		for _, item in ipairs(toggleable) do
			menu("amenu disable PopUp." .. item)
		end

		if has_lsp() then
			for _, item in ipairs({
				"Go\\ to\\ definition",
				"References",
				"Implementation",
				"Hover",
				"Code\\ Action",
				"Rename",
			}) do
				menu("amenu enable PopUp." .. item)
			end
		end
		if vim.fn.expand("<cfile>"):match("^https?://") then
			menu([[amenu enable PopUp.Open\ in\ web\ browser]])
		end
		if current_file_path() then
			menu([[amenu enable PopUp.Copy\ File\ Path]])
		end
		if vim.fs.root(0, ".git") then
			menu([[amenu enable PopUp.Git\ Browse]])
		end
	end,
})

-- ---------- exposed actions -------------------------------------------------
-- Lambdas keep LuaLS happy: vim.lsp.buf.* gets inferred as table in some
-- runtime meta combinations, which doesn't satisfy `fun()`.

function M.go_to_definition()
	with_lsp(function()
		vim.lsp.buf.definition()
	end, "No LSP definition available")
end

function M.references()
	with_lsp(function()
		vim.lsp.buf.references()
	end, "No LSP references available")
end

function M.implementation()
	with_lsp(function()
		vim.lsp.buf.implementation()
	end, "No LSP implementation available")
end

function M.code_actions()
	with_lsp(function()
		vim.lsp.buf.code_action()
	end, "No code actions available")
end

function M.hover()
	with_lsp(function()
		vim.lsp.buf.hover()
	end, "No hover available")
end

function M.rename()
	with_lsp(function()
		vim.lsp.buf.rename()
	end, "No rename action available")
end

function M.open_url()
	open_url_under_cursor()
end

function M.copy_file_path()
	copy_file_path()
end

function M.git_browse()
	local snacks = Config.safe_require("snacks")
	if snacks and snacks.gitbrowse then
		snacks.gitbrowse()
	else
		notify("Snacks gitbrowse is unavailable")
	end
end

return M
