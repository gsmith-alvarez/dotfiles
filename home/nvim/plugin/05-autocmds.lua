-- global autocommands
local u = Config.safe_require("core.utils")
if not u then
	return
end
-- 1. Treesitter attachment
--- @param args table Autocmd callback args.
local treesitter_attach = function(args)
	local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
	if lang then
		pcall(vim.treesitter.start, args.buf, lang)
	end
end
u.autocmd("FileType", "*", treesitter_attach, "Start Treesitter highlighting")
-- 2. UI polish
local highlight_yank = function()
	vim.hl.hl_op({ higroup = "Visual", timeout = 200 })
end
u.autocmd({ "TextYankPost", "TextPutPost" }, "*", highlight_yank, "Highlight yanked/put text")
-- 3. Cursor persistence
--- @param args table Autocmd callback args.
local cursor_persist = function(args)
	local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
	local line_count = vim.api.nvim_buf_line_count(args.buf)
	if mark[1] > 0 and mark[1] <= line_count then
		vim.api.nvim_win_set_cursor(0, mark)
		-- Defer centering slightly so it's applied after the buffer renders.
		vim.schedule(function()
			vim.cmd("normal! zz")
		end)
	end
end
u.autocmd("BufReadPost", "*", cursor_persist, "Restore cursor position on file open")
-- 4. Window behavior
u.autocmd("FileType", { "help", "man" }, function()
	vim.cmd("wincmd L")
end, "Open help/man in a vertical split")

u.autocmd("VimResized", "*", "wincmd =", "Equalize splits on window resize")
-- 5. Filetype overrides
u.autocmd({ "BufRead", "BufNewFile" }, { ".env", ".env.*" }, function()
	vim.bo.filetype = "dosini"
end, "Syntax highlighting for secret files")
-- 6. Whitespace management
-- Skip make/go/just and noexpandtab buffers.
local retab_skip = { make = true, go = true, just = true }
u.autocmd("BufWritePre", "*", function()
	if vim.bo.expandtab and not retab_skip[vim.bo.filetype] then
		vim.cmd("silent! %retab!")
	end
end, "Convert tabs to spaces on save")
u.autocmd("BufWritePre", "*", function()
	Config.safe_require("mini.trailspace").trim()
end, "Trims Trailing Whitesapce")
-- 7. Filesystem helpers
u.autocmd("BufWritePre", "*", function(event)
	local name = vim.api.nvim_buf_get_name(event.buf)
	if name == "" then
		return
	end
	local dir = vim.fn.fnamemodify(name, ":p:h")
	if vim.fn.isdirectory(dir) == 0 then
		vim.fn.mkdir(dir, "p")
	end
end, "Auto-create parent directories on save")

u.autocmd("User", "MiniFilesActionRename", function(event)
	require("snacks").rename.on_rename_file(event.data.from, event.data.to)
end, "Project-aware file renaming (mini.files + snacks.rename)")
u.autocmd("BufNewFile", "*", "silent! 0r " .. vim.fn.stdpath("config") .. "/templates/skeleton.%:e", "Use a template")

-- 8. Modular registration
local autocmds = Config.safe_require("autocmds")
if not autocmds then
	return
end
autocmds.register("lsp")
autocmds.register("format")
