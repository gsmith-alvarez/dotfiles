-- nix

local u = Config.safe_require("core.utils")
if not u then
	return
end

local api = vim.api

vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2

local function termcodes(keys)
	return api.nvim_replace_termcodes(keys, true, false, true)
end

-- <C-g>U keeps undo and dot-repeat intact across the cursor movement.
local LEFT = termcodes("<C-g>U<Left>")
local RIGHT = termcodes("<C-g>U<Right>")
local DEL = termcodes("<Del>")
local BS = termcodes("<BS>")

local function char_at_cursor()
	local col = vim.fn.col(".")
	return api.nvim_get_current_line():sub(col, col)
end

-- Bracket pairs ending in `;`

local STRING_OR_COMMENT = {
	comment = true,
	string_fragment = true,
	string_expression = true,
	indented_string_expression = true,
}

--- Tree-sitter check, needed for multi-line `''` strings that the line-local
--- scan below cannot see. Reparses the cursor row: the highlighter's tree can lag behind typing.
local function in_string_or_comment()
	local parser = vim.treesitter.get_parser(0, "nix", { error = false })
	if not parser then
		return false
	end
	local row, col = unpack(api.nvim_win_get_cursor(0))
	parser:parse({ row - 1, row })
	local node = parser:named_node_for_range({ row - 1, col, row - 1, col }, { ignore_injections = true })
	return node ~= nil and STRING_OR_COMMENT[node:type()] == true
end

--- Text before the cursor. On an otherwise blank line, the previous non-blank
--- line is prepended so that `name =\n  {` still reads as a binding.
local function text_before_cursor()
	local row, col = unpack(api.nvim_win_get_cursor(0))
	local before = api.nvim_get_current_line():sub(1, col)
	local prev = vim.fn.prevnonblank(row - 1)
	if before:find("^%s*$") and prev > 0 then
		before = vim.fn.getline(prev) .. " " .. before
	end
	return before
end

--- Whether a bracket typed here starts the value of a binding (`name = {`),
--- the one place Nix wants a terminating `;`. List elements, function
--- arguments and top-level expressions are left alone.
local function starts_binding_value()
	local before = text_before_cursor()
		:gsub("\\.", "") -- escaped characters
		:gsub('%b""', "") -- closed strings
		:gsub("''.-''", "")
	if before:find('["#]') or before:find("''") or in_string_or_comment() then
		return false
	end

	-- Everything after the last binding `=` (not `==`, `!=`, `<=`, `>=`).
	local value = before:match("[^=!<>]=([^=]*)$")
	if not value then
		return false
	end

	-- The bracket opens the value itself only if nothing before it in the value
	-- is still open or already terminated.
	value = value
		:gsub("with%s+[%w_.]+%s*;", "") -- `with pkgs; [`
		:gsub("%b{}", "")
		:gsub("%b[]", "")
		:gsub("%b()", "")
	return not value:find("[{%[(;]")
end

local function open_pair(pair)
	return function()
		local rest = api.nvim_get_current_line():sub(vim.fn.col("."))
		if starts_binding_value() and not rest:find("^%s*;") then
			return pair .. ";" .. LEFT .. LEFT
		end
		return _G.MiniPairs and MiniPairs.open(pair, "^[^\\]") or pair .. LEFT
	end
end

--- Step over a `;` that was inserted with the pair instead of doubling it.
local function semicolon()
	return char_at_cursor() == ";" and RIGHT or ";"
end

--- Delete an empty `{};` / `[];` as one unit; everything else goes to mini.pairs.
local function backspace()
	local col = vim.fn.col(".")
	local around = api.nvim_get_current_line():sub(col - 1, col + 1)
	local bs = _G.MiniPairs and MiniPairs.bs() or BS
	return (around == "{};" or around == "[];") and bs .. DEL or bs
end

-- Navigation & evaluation

--- `gf` that resolves Nix imports: `./dir` → `./dir/default.nix`, `./foo` → `./foo.nix`.
local function goto_file()
	local path = vim.fn.expand("<cfile>")
	if not path:find("^[/~]") then
		path = vim.fs.joinpath(vim.fn.expand("%:p:h"), path)
	end
	path = vim.fs.normalize(path)

	for _, candidate in ipairs({ path .. "/default.nix", path .. ".nix" }) do
		if vim.uv.fs_stat(candidate) then
			return vim.cmd.edit(candidate)
		end
	end
	vim.cmd("normal! gf")
end

--- Run `nix eval` on the visual selection, or the word under the cursor.
local function eval()
	local mode = vim.fn.mode()
	local expr = mode:find("^[vV\22]")
			and table.concat(vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = mode }), "\n")
		or vim.fn.expand("<cword>")

	vim.system(
		{ "nix", "eval", "--expr", expr },
		{ text = true },
		vim.schedule_wrap(function(result)
			local ok = result.code == 0
			local level = ok and vim.log.levels.INFO or vim.log.levels.ERROR
			vim.notify(vim.trim(ok and result.stdout or result.stderr), level, { title = "nix eval" })
		end)
	)
end

-- Keymaps

local expr = { buffer = true, expr = true, replace_keycodes = false }
u.imap("{", open_pair("{}"), "Nix: Pair {} (with ; for bindings)", expr)
u.imap("[", open_pair("[]"), "Nix: Pair [] (with ; for bindings)", expr)
u.imap(";", semicolon, "Nix: Step over ;", expr)
u.imap("<BS>", backspace, "Nix: Delete empty pair", expr)

u.nmap("gf", goto_file, "Nix: Go to file", { buffer = true })
u.map({ "n", "x" }, "<leader>ce", eval, "Nix: Evaluate expression", { buffer = true })
