-- =============================================================================
-- [ PLUGIN KEYMAPS ]
-- Keybindings that specifically target and require external plugins.
-- =============================================================================
local u = Config.safe_require("core.utils")
-- 1. [ MINI.FILES ]
local toggle_file_tree = function()
	local mf = Config.safe_require("mini.files")
	if not mf.close() then
		local path = vim.api.nvim_buf_get_name(0)
		if path == "" or path:match("^minifiles://") then
			path = vim.fn.getcwd()
		elseif vim.fn.filereadable(path) == 0 and vim.fn.isdirectory(path) == 0 then
			path = vim.fn.fnamemodify(path, ":p:h")
			if vim.fn.isdirectory(path) == 0 then
				path = vim.fn.getcwd()
			end
		end
		mf.open(path)
	end
end
u.nmap("-", toggle_file_tree, "Explore: Toggle File Tree")
u.nmap("<A-e>", toggle_file_tree, "Explore: Toggle File Tree")

-- Snacks Helper
local snacks = Config.safe_require("snacks")
local picker = snacks.picker

local function multigrep(opts)
	opts = opts or {}
	local cwd = opts.cwd and vim.fn.expand(opts.cwd) or vim.uv.cwd()
	local shortcuts = opts.shortcuts
		or {
			l = "*.lua",
			v = "*.vim",
			n = "*.{vim,lua}",
			c = "*.c",
			r = "*.rs",
			g = "*.go",
			m = "*.md",
			p = "*.py",
		}
	local pattern = opts.pattern or "%s"

	picker.pick({
		title = "Live Grep (with shortcuts)",
		live = true,
		debounce = 100,
		format = "file",
		sort = false,
		cwd = cwd,
		finder = function(finder_opts, ctx)
			local prompt = ctx.filter.search
			if not prompt or prompt == "" then
				return {}
			end

			local parts = vim.split(prompt, "  ", { plain = true })
			local grep_pat = vim.trim(parts[1] or "")
			if grep_pat == "" then
				return {}
			end
			local glob = vim.trim(parts[2] or "")

			local grep_opts = {
				cwd = cwd,
				hidden = opts.hidden ~= false,
				ignored = finder_opts.ignored,
				follow = finder_opts.follow,
				exclude = finder_opts.exclude,
				debug = finder_opts.debug or {},
				regex = true,
				ft = opts.ft,
				args = opts.args,
			}

			if glob ~= "" then
				local resolved = shortcuts[glob] or glob
				grep_opts.glob = string.format(pattern, resolved)
			else
				grep_opts.glob = nil
			end

			local proxy_ctx = setmetatable({ filter = vim.deepcopy(ctx.filter) }, { __index = ctx })
			proxy_ctx.filter.search = grep_pat

			return require("snacks.picker.source.grep").grep(grep_opts, proxy_ctx)
		end,
	})
end

-- 2. [ FIND (LEADER F) - Files & Buffers ]
-- Everything here results in opening a file or switching buffers.
-- Fast access
u.nmap("<leader>fb", function()
	picker.buffers()
end, "Find: Buffers")

-- Find Group
u.nmap("<leader>ff", function()
	picker.files()
end, "Find: Files")
u.nmap("<leader>fg", function()
	picker.git_files()
end, "Find: Git Files")
u.nmap("<leader>fp", function()
	picker.projects()
end, "Find: Projects")
u.nmap("<leader>fz", function()
	picker.zoxide({
		confirm = function(p, item)
			p:close()
			picker.files({ cwd = item.file })
		end,
	})
end, "Find: Zoxide Path")
u.nmap("<leader>fr", function()
	local visits = Config.safe_require("mini.visits")
	local paths = visits.list_paths()
	if #paths == 0 then
		vim.notify("No visits recorded", vim.log.levels.INFO)
		return
	end
	picker.pick({
		title = "Visits",
		items = vim.tbl_map(function(p)
			return { text = p, file = p }
		end, paths),
		format = "file",
	})
end, "Find: Recent Visits")

-- 3. [ SEARCH (LEADER S) - Content & Internals ]
-- Everything here searches text, metadata, symbols, or history.
u.nmap("<leader>sg", function()
	multigrep()
end, "Search: Live Grep")
u.nmap("<leader>sw", function()
	local word = vim.fn.expand("<cword>")
	if word == nil or word == "" then
		return
	end
	picker.grep({
		search = word,
		regex = false,
		args = { "--word-regexp" },
		dirs = { vim.fn.expand("%:p:h") },
	})
end, "Search: Word (CWD)")
u.nmap("<leader>st", function()
	picker.grep({ search = "TODO|FIXME|NOTE|WIP|INFO" })
end, "Search: Find TODO/FIXME/NOTE")
u.nmap("<leader>sc", function()
	picker.cliphist()
end, "Search: Clipboard")

-- History & Resume
u.nmap("<leader>s/", function()
	picker.search_history()
end, "Search: Search History")
u.nmap("<leader>s:", function()
	picker.command_history()
end, "Search: Command History")
u.nmap("<leader>sr", function()
	picker.resume()
end, "Search: Resume Last Search")

-- Config Group
u.nmap("<leader>fi", "<Cmd>edit $MYVIMRC<CR>", "Config: Edit init.lua")
u.nmap("<leader>fc", function()
	picker.files({ cwd = vim.fn.stdpath("config") })
end, "Config: Find File")
u.nmap("<leader>sk", function()
	picker.keymaps({ layout = { preset = "vscode" } })
end, "Search: Search Keymaps")
u.nmap("<leader>fP", function()
	picker.files({
		title = "Plugin Source",
		cwd = vim.fn.stdpath("data") .. "/site/pack/core/opt",
	})
end, "Config: Find Plugin Source")
local cfg = vim.fn.stdpath("config")
u.nmap("<leader>fo", "<Cmd>edit " .. cfg .. "/plugin/00-options.lua<CR>", "Config: Edit Options")

-- Symbols
u.nmap("<leader>ss", function()
	picker.lsp_symbols()
end, "Search: Find Document Symbols")
u.nmap("<leader>sS", function()
	picker.lsp_workspace_symbols()
end, "Search: Find Workspace Symbols")
u.nmap("<leader>sT", function()
	picker.treesitter()
end, "Search: Treesitter")
u.nmap("<leader>sb", function()
	require("dropbar.api").pick()
end, "Search: Pick Breadcrumb")

-- Diagnostics
u.nmap("<leader>sd", function()
	picker.diagnostics()
end, "Search: Find Workspace Diagnostics")
u.nmap("<leader>sD", function()
	picker.diagnostics_buffer()
end, "Search: Find Buffer Diagnostics")

-- Internal/System
u.nmap("<leader>sh", function()
	picker.help()
end, "Search: Help Tags")
u.nmap("<leader>sH", function()
	picker.highlights()
end, "Search: Highlight Groups")
u.nmap("<leader>su", function()
	picker.undo()
end, "Search: Undo History")
u.nmap("<leader>sn", function()
	picker.notifications({ layout = { preset = "ivy_split" } })
end, "Search: Notifications")
u.nmap("<leader>sm", function()
	picker.man()
end, "Search: Manuals")
u.nmap("<leader>si", function()
	picker.icons()
end, "Search: Icons")
u.nmap("<leader>sq", function()
	picker.qflist()
end, "Search: Quickfix List")
u.nmap("<leader>sl", function()
	picker.loclist()
end, "Search: Location List")
u.nmap("<leader>sM", function()
	picker.marks()
end, "Search: Marks")
u.nmap("<leader>sj", function()
	picker.jumps()
end, "Search: Jumps")

-- 4. [ UI & TOGGLES (LEADER U) ]
local toggle_qf = function()
	vim.cmd(vim.fn.getqflist({ winid = true }).winid ~= 0 and "cclose" or "copen")
end
u.nmap("<leader>uq", toggle_qf, "List: Toggle Quickfix")
u.nmap("<A-q>", toggle_qf, "List: Toggle Quickfix")

local toggle_loc = function()
	vim.cmd(vim.fn.getloclist(0, { winid = true }).winid ~= 0 and "lclose" or "lopen")
end
u.nmap("<leader>ul", toggle_loc, "List: Toggle Location")
u.nmap("<A-x>", toggle_loc, "List: Toggle Location")
u.nmap("<leader>un", function()
	snacks.notifier.show_history()
end, "Notify: Show History")

-- 6. [ GIT (LEADER G) ]
-- Top-level
u.nmap("<leader>gg", function()
	snacks.lazygit()
end, "Git: Open Lazygit")
u.nmap("<leader>gs", function()
	picker.git_status()
end, "Git: Show Status")
u.nmap("<leader>go", function()
	require("mini.git").show_at_cursor()
end, "Git: Show Object at Cursor")

-- Git Log
u.nmap("<leader>gl", function()
	snacks.lazygit.log()
end, "Git: Lazygit Log")
u.nmap("<leader>gL", function()
	snacks.lazygit.log_file()
end, "Git: Lazygit Log (File)")
u.nmap("<leader>gP", function()
	picker.git_log()
end, "Git: Picker Log (All)")
u.nmap("<leader>gp", function()
	picker.git_log_file()
end, "Git: Picker Log (Buffer)")
u.map({ "n", "v" }, "<leader>gh", function()
	require("mini.git").show_range_history()
end, "Git: Show Range History")

-- Git Diff & Hunks
u.nmap("<leader>gd", function()
	picker.git_diff()
end, "Git: Show Diff Hunks")
u.nmap("<leader>gS", function()
	picker.git_diff({ staged = true })
end, "Git: Show Added Hunks (Staged)")
u.nmap("<leader>gw", function()
	picker.git_diff()
end, "Git: Show Modified Hunks (Workspace)")
u.nmap("<leader>gB", function()
	picker.git_diff({ path = "%" })
end, "Git: Show Modified Hunks (Buffer)")

-- Branches & Web
u.nmap("<leader>gb", function()
	picker.git_branches()
end, "Git: Show Branches")
u.map({ "n", "v" }, "<leader>gy", function()
	snacks.gitbrowse()
end, "Git: Open Browser")

-- Commit
u.nmap("<leader>gc", "<Cmd>Git commit<CR>", "Git: Commit")
u.nmap("<leader>gC", "<Cmd>Git commit --amend<CR>", "Git: Commit Amend")

-- Diff Overlay
u.nmap("<leader>gx", function()
	local bufnr = vim.api.nvim_get_current_buf()
	require("mini.diff").toggle_overlay(bufnr)
end, "Git: Toggle Diff Overlay")

-- 7. [ TOP-LEVEL UTILS ]
u.nmap("<leader><space>", function()
	picker.smart()
end, "Find: Smart Files")
u.nmap("<leader>/", function()
	picker.grep()
end, "Search: Global Grep")
u.nmap("<leader>n", function()
	snacks.notifier.show_history()
end, "Notify: Show History")
u.nmap("<leader>.", function()
	snacks.scratch()
end, "Scratch: Toggle Buffer")
u.nmap("<leader>S", function()
	snacks.scratch.select()
end, "Scratch: Select Buffer")
u.nmap("<leader>ps", function()
	snacks.profiler.scratch()
end, "Profiler: Open Scratch Buffer")

-- 13. [ CODE / LSP (LEADER C) ]
u.map({ "n", "x" }, "<leader>ca", function()
	vim.lsp.buf.code_action()
end, "Code: Action")
u.nmap("<leader>cd", function()
	vim.diagnostic.open_float()
end, "Code: Diagnostic Popup")
local cycle_list_history = function(direction)
	local winid = vim.fn.win_getid()
	local wininfo = vim.fn.getwininfo(winid)[1]
	local is_loclist = false
	if wininfo.quickfix == 1 then
		is_loclist = wininfo.loclist == 1
	else
		is_loclist = #vim.fn.getloclist(0) > 0
	end

	local cmd = is_loclist and (direction == "older" and "lolder" or "lnewer")
		or (direction == "older" and "colder" or "cnewer")
	local ok, err = pcall(vim.cmd, cmd)
	if not ok then
		local clean_err = err:match("E%d+:.*") or err
		vim.notify(clean_err, vim.log.levels.WARNING)
	end
end

u.nmap("<leader>xx", function()
	vim.diagnostic.setloclist()
end, "List: Diagnostics to Location List")
u.nmap("<leader>xq", function()
	vim.diagnostic.setqflist()
end, "List: Project Diagnostics to Quickfix List")
u.nmap("<leader>x[", function()
	cycle_list_history("older")
end, "List: Older History List")
u.nmap("<leader>x]", function()
	cycle_list_history("newer")
end, "List: Newer History List")
u.nmap("<leader>xc", function()
	vim.fn.setloclist(0, {})
	vim.cmd("lclose")
	vim.notify("Location list cleared", vim.log.levels.INFO)
end, "List: Clear Current Location List")
u.nmap("<leader>xC", function()
	vim.fn.setqflist({})
	vim.cmd("cclose")
	vim.notify("Quickfix list cleared", vim.log.levels.INFO)
end, "List: Clear Global Quickfix List")
u.nmap("<leader>cf", function()
	vim.lsp.buf.format({ async = false })
end, "Code: Format")
u.map("x", "<leader>cf", function()
	vim.lsp.buf.format({ async = false })
end, "Code: Format Selection")
u.nmap("<leader>ch", function()
	vim.lsp.buf.hover()
end, "Code: Hover")
u.nmap("<leader>cr", function()
	vim.lsp.buf.rename()
end, "Code: Rename")
u.nmap("<leader>cl", function()
	vim.lsp.codelens.run()
end, "Code: CodeLens")
u.nmap("<leader>cg", function()
	picker.lsp_definitions()
end, "Code: Goto Definition")

-- Execute Group (<leader>cx)
u.nmap("<leader>cx", "<Cmd>Run<CR>", "Code: Smart Run")
u.nmap("<leader>cX", "<Cmd>RunWatch<CR>", "Code: Smart Run (watch)")

-- 7. [ PICKER VARIANTS (GP*) ]
u.nmap("gpd", function()
	picker.lsp_definitions()
end, "LSP: Find Definitions (Picker)")
u.nmap("gpr", function()
	picker.lsp_references()
end, "LSP: Find References (Picker)")
u.nmap("gpt", function()
	picker.lsp_type_definitions()
end, "LSP: Find Type Definitions (Picker)")
u.nmap("gpi", function()
	picker.lsp_implementations()
end, "LSP: Find Implementations (Picker)")
u.nmap("gpO", function()
	picker.lsp_symbols()
end, "LSP: Find Document Symbols (Picker)")

-- 8. [ NAVIGATION UTILS ]
u.nmap("<A-t>", function()
	snacks.terminal()
end, "Terminal: Toggle")
u.map({ "n", "t" }, "]]", function()
	snacks.words.jump(vim.v.count1)
end, "Reference: Jump to Next")
u.map({ "n", "t" }, "[[", function()
	snacks.words.jump(-vim.v.count1)
end, "Reference: Jump to Previous")

-- 9. [ MINI.SESSIONS (LEADER Q) ]
local sessions = Config.safe_require("mini.sessions")
u.nmap("<leader>qs", function()
	sessions.select()
end, "Session: Select")
u.nmap("<leader>qr", function()
	local name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
	sessions.read(name)
end, "Session: Read (CWD)")
u.nmap("<leader>qw", function()
	local name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
	sessions.write(name)
end, "Session: Write (CWD)")
u.nmap("<leader>qR", "<Cmd>lua MiniSessions.restart()<CR>", "Session: Restart")

-- 10. [ BUFFER (LEADER B) ]
local new_scratch_buffer = function()
	vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(true, true))
end
u.nmap("<leader>ba", "<Cmd>b#<CR>", "Buffer: Alternate")
u.nmap("<leader>bs", new_scratch_buffer, "Buffer: Scratch")
u.nmap("<leader>bd", function()
	require("mini.bufremove").delete()
end, "Buffer: Delete")
u.nmap("<leader>bD", function()
	require("mini.bufremove").delete(0, true)
end, "Buffer: Delete!")
u.nmap("<leader>bw", function()
	require("mini.bufremove").wipeout()
end, "Buffer: Wipeout")
u.nmap("<leader>bW", function()
	require("mini.bufremove").wipeout(0, true)
end, "Buffer: Wipeout!")

-- 15. [ TERMINAL (LEADER T) ]
u.nmap("<leader>tt", "<Cmd>vertical term<CR>", "Terminal: Vertical Split")
u.nmap("<leader>tT", "<Cmd>horizontal term<CR>", "Terminal: Horizontal Split")

-- 15. [ VISITS (LEADER V) ]
local visits = Config.safe_require("mini.visits")
local function pick_visits_labeled(label, cwd_filter)
	local sort = visits.gen_sort.default({ recency_weight = 1 })
	local cwd = cwd_filter and vim.uv.cwd() or ""
	local paths = visits.list_paths(cwd, { filter = label, sort = sort })
	if #paths == 0 then
		vim.notify("No visits" .. (label and (' with label "' .. label .. '"') or ""), vim.log.levels.INFO)
		return
	end
	picker.pick({
		title = "Visits" .. (label and (': "' .. label .. '"') or "") .. (cwd_filter and " (cwd)" or " (all)"),
		items = vim.tbl_map(function(p)
			return { text = p, file = p }
		end, paths),
		format = "file",
	})
end

-- Pick
u.nmap("<leader>vP", function()
	pick_visits_labeled("core", false)
end, "Visits: Core (All)")
u.nmap("<leader>vp", function()
	pick_visits_labeled("core", true)
end, "Visits: Core (CWD)")

-- Label
u.nmap("<leader>va", function()
	visits.add_label("core")
end, 'Visits: Add "core" Label')
u.nmap("<leader>vr", function()
	visits.remove_label("core")
end, 'Visits: Remove "core" Label')
u.nmap("<leader>vA", function()
	visits.add_label()
end, "Visits: Add Custom Label")
u.nmap("<leader>vR", function()
	visits.remove_label()
end, "Visits: Remove Custom Label")
