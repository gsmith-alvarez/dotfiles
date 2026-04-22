-- =============================================================================
-- [ PLUGIN KEYMAPS ]
-- Keybindings that specifically target and require external plugins.
-- =============================================================================
local u = Config.safe_require("core.utils")
-- 1. [ MINI.FILES ]
u.nmap("-", function()
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
end, "Explore: Toggle File Tree")

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
-- 2. [ SNACKS: FIND (LEADER F) ]
-- History & Meta
u.nmap("<leader>f/", function()
	picker.search_history()
end, "Find: Search History")
u.nmap("<leader>f:", function()
	picker.command_history()
end, "Find: Search Command History")
u.nmap("<leader>fr", function()
	picker.resume()
end, "Find: Resume Last Search")

-- Buffers & Files
u.nmap("<leader>fb", function()
	picker.buffers()
end, "Find: Buffers")
u.nmap("<leader>fv", function()
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
	picker.zoxide()
end, "Find: Zoxide Path")

-- 3. [ SNACKS: SEARCH (LEADER S) ]
-- Code & Symbols
u.nmap("<leader>ss", function()
	picker.lsp_symbols()
end, "Search: Find Document Symbols")
u.nmap("<leader>sS", function()
	picker.lsp_workspace_symbols()
end, "Search: Find Workspace Symbols")
u.nmap("<leader>sg", function()
	multigrep()
end, "Search: Multi Grep")
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
u.nmap("<leader>sT", function()
	picker.grep({ search = "TODO|FIXME|NOTE|WIP|INFO" })
end, "Search: Find TODO/FIXME/NOTE")
u.nmap("<leader>st", function()
	picker.treesitter()
end, "Search: Treesitter")

-- Diagnostics
u.nmap("<leader>sd", function()
	picker.diagnostics()
end, "Search: Find Workspace Diagnostics")
u.nmap("<leader>sD", function()
	picker.diagnostics_buffer()
end, "Search: Find Buffer Diagnostics")

-- UI & Meta
u.nmap("<leader>sh", function()
	picker.help()
end, "Search: Help Tags")
u.nmap("<leader>sH", function()
	picker.highlights()
end, "Search: Highlight Groups")
u.nmap("<leader>su", function()
	picker.undo()
end, "Search: Undo History")
u.nmap("<leader>sk", function()
	picker.keymaps({ layout = { preset = "vscode" } })
end, "Search: Keymaps")
u.nmap("<leader>sj", function()
	picker.jumps()
end, "Search: Jumps")
u.nmap("<leader>sq", function()
	picker.qflist()
end, "Search: Quickfix List")
u.nmap("<leader>sl", function()
	picker.loclist()
end, "Search: Location List")
u.nmap("<leader>sm", function()
	picker.marks()
end, "Search: Marks")
u.nmap("<leader>si", function()
	picker.icons()
end, "Search: Icons")
u.nmap("<leader>sn", function()
	picker.notifications({ layout = { preset = "ivy_split" } })
end, "Search: Notifications")
u.nmap("<leader>sM", function()
	picker.man()
end, "Search: Manuals")
u.nmap("<leader>sc", function()
	picker.cliphist()
end, "Search: Clipboard")

-- 4. [ SNACKS: EXPLORE (LEADER E) ]
u.nmap("<leader>ed", function()
	snacks.explorer()
end, "Explore: Open Directory (CWD)")
u.nmap("<leader>ef", function()
	require("mini.files").open(vim.api.nvim_buf_get_name(0))
end, "Explore: Open File Directory")
u.nmap("<leader>ei", "<Cmd>edit $MYVIMRC<CR>", "Config: Edit init.lua")
u.nmap("<leader>ec", function()
	picker.files({ cwd = vim.fn.stdpath("config") })
end, "Config: Find File")
u.nmap("<leader>ep", function()
	require("mini.files").open(vim.fn.stdpath("data") .. "/site/pack/core/opt")
end, "Explore: Open Plugins Directory")

-- UI Lists
u.nmap("<leader>eq", function()
	vim.cmd(vim.fn.getqflist({ winid = true }).winid ~= 0 and "cclose" or "copen")
end, "List: Toggle Quickfix")
u.nmap("<leader>eQ", function()
	vim.cmd(vim.fn.getloclist(0, { winid = true }).winid ~= 0 and "lclose" or "lopen")
end, "List: Toggle Location")
u.nmap("<leader>sb", function()
	require("dropbar.api").pick()
end, "Search: Pick Breadcrumb")

-- 5. [ EXECUTE (LEADER X) ]
u.nmap("<leader>xx", "<Cmd>Run<CR>", "Execute: Smart Run")
u.nmap("<leader>xw", "<Cmd>RunWatch<CR>", "Execute: Smart Run (watch)")

-- 6. [ GIT (LEADER G) ]
u.nmap("<leader>gs", function()
	picker.git_status()
end, "Git: Show Status")
u.nmap("<leader>gb", function()
	picker.git_branches()
end, "Git: Show Branches")
u.nmap("<leader>gg", function()
	snacks.lazygit()
end, "Git: Open Lazygit")
u.map({ "n", "v" }, "<leader>gB", function()
	snacks.gitbrowse()
end, "Git: Open Browser")
-- Git Object / History
u.nmap("<leader>gO", function()
	require("mini.git").show_at_cursor()
end, "Git: Show Object at Cursor")
u.map({ "n", "v" }, "<leader>gH", function()
	require("mini.git").show_range_history()
end, "Git: Show Range History")
-- Git Log
u.nmap("<leader>gl", function()
	picker.git_log()
end, "Git: Show Log (All)")
u.nmap("<leader>gL", function()
	picker.git_log_file()
end, "Git: Show Log (Buffer)")
-- Git Hunks
u.nmap("<leader>gha", function()
	picker.git_diff({ staged = true })
end, "Git: Show Added Hunks (Staged)")
u.nmap("<leader>ghm", function()
	picker.git_diff()
end, "Git: Show Modified Hunks (Workspace)")
u.nmap("<leader>ghM", function()
	picker.git_diff({ path = "%" })
end, "Git: Show Modified Hunks (Buffer)")
u.nmap("<leader>ghd", function()
	picker.git_diff()
end, "Git: Show Diff Hunks")

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

u.nmap("<leader>TT", function()
	require("mini.trailspace").trim()
end, "Code: Trim Trailing Whitespace")

-- 8. [ NAVIGATION & LSP ]
-- gp* = Picker variants (mirrors gr* builtins)
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
u.nmap("<C-/>", function()
	snacks.terminal()
end, "Terminal: Toggle")

-- Reference Navigation
u.map({ "n", "t" }, "]]", function()
	snacks.words.jump(vim.v.count1)
end, "Reference: Jump to Next")
u.map({ "n", "t" }, "[[", function()
	snacks.words.jump(-vim.v.count1)
end, "Reference: Jump to Previous")

-- 9. [ MINI.SESSIONS ]
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

-- 11. [ EXPLORE: CONFIG FILE SHORTCUTS (LEADER E) ]
local cfg = vim.fn.stdpath("config")
u.nmap("<leader>ek", "<Cmd>edit " .. cfg .. "/plugin/04-plugin-keymaps.lua<CR>", "Config: Edit Keymaps")
u.nmap("<leader>em", "<Cmd>edit " .. cfg .. "/lua/plugins/mini.lua<CR>", "Config: Edit Mini")
u.nmap("<leader>en", function()
	snacks.notifier.show_history()
end, "Notify: Show History")
u.nmap("<leader>eo", "<Cmd>edit " .. cfg .. "/plugin/00-options.lua<CR>", "Config: Edit Options")

-- 12. [ GIT: DIFF & COMMIT (LEADER G) ]
u.nmap("<leader>gc", "<Cmd>Git commit<CR>", "Git: Commit")
u.nmap("<leader>gC", "<Cmd>Git commit --amend<CR>", "Git: Commit Amend")
u.nmap("<leader>gd", "<Cmd>Git diff<CR>", "Git: Diff (Workspace)")
u.nmap("<leader>gD", "<Cmd>Git diff -- %<CR>", "Git: Diff (Buffer)")
u.nmap("<leader>go", function()
	require("mini.diff").toggle_overlay()
end, "Git: Toggle Diff Overlay")

-- 13. [ CODE / LSP (LEADER C) ]
u.map({ "n", "x" }, "<leader>ca", function()
	vim.lsp.buf.code_action()
end, "Code: Action")
u.nmap("<leader>cd", function()
	vim.diagnostic.open_float()
end, "Code: Diagnostic Popup")
u.nmap("<leader>cf", function()
	vim.lsp.buf.format({ async = false })
end, "Code: Format")
u.map("x", "<leader>cf", function()
	vim.lsp.buf.format({ async = false })
end, "Code: Format Selection")
u.nmap("<leader>ch", function()
	vim.lsp.buf.hover()
end, "Code: Hover")
u.nmap("<leader>ci", function()
	vim.lsp.buf.implementation()
end, "Code: Implementation")
u.nmap("<leader>cl", function()
	vim.lsp.codelens.run()
end, "Code: CodeLens")
u.nmap("<leader>cr", function()
	vim.lsp.buf.rename()
end, "Code: Rename")
u.nmap("<leader>cR", function()
	vim.lsp.buf.references()
end, "Code: References")
u.nmap("<leader>cs", function()
	vim.lsp.buf.definition()
end, "Code: Definition")
u.nmap("<leader>ct", function()
	vim.lsp.buf.type_definition()
end, "Code: Type Definition")

-- 14. [ MAP (LEADER M) ]
u.nmap("<leader>mt", function()
	require("mini.map").toggle()
end, "Map: Toggle")
u.nmap("<leader>mf", function()
	require("mini.map").toggle_focus()
end, "Map: Focus Toggle")
u.nmap("<leader>ms", function()
	require("mini.map").toggle_side()
end, "Map: Side Toggle")
u.nmap("<leader>mr", function()
	require("mini.map").refresh()
end, "Map: Refresh")

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
u.nmap("<leader>vc", function()
	pick_visits_labeled("core", false)
end, "Visits: Core (All)")
u.nmap("<leader>vC", function()
	pick_visits_labeled("core", true)
end, "Visits: Core (CWD)")
u.nmap("<leader>vv", function()
	visits.add_label("core")
end, 'Visits: Add "core" Label')
u.nmap("<leader>vV", function()
	visits.remove_label("core")
end, 'Visits: Remove "core" Label')
u.nmap("<leader>vl", function()
	visits.add_label()
end, "Visits: Add Label")
u.nmap("<leader>vL", function()
	visits.remove_label()
end, "Visits: Remove Label")
