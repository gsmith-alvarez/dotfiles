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

-- 2. [ FIND (LEADER F) - Files & Patterns ]
-- Fast access
u.nmap("<leader>fb", function()
	picker.buffers()
end, "Find: Buffers")

-- Files Group (<leader>ff)
u.nmap("<leader>fff", function()
	picker.files()
end, "Find: Files")
u.nmap("<leader>ffg", function()
	picker.git_files()
end, "Find: Git Files")
u.nmap("<leader>ffp", function()
	picker.projects()
end, "Find: Projects")
u.nmap("<leader>ffz", function()
	picker.zoxide({
		confirm = function(p, item)
			p:close()
			picker.files({ cwd = item.file })
		end,
	})
end, "Find: Zoxide Path")
u.nmap("<leader>ffv", function()
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

-- Grep Group (<leader>fg)
u.nmap("<leader>fgg", function()
	multigrep()
end, "Search: Multi Grep")
u.nmap("<leader>fgw", function()
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
u.nmap("<leader>fgt", function()
	picker.grep({ search = "TODO|FIXME|NOTE|WIP|INFO" })
end, "Search: Find TODO/FIXME/NOTE")
u.nmap("<leader>fgc", function()
	picker.cliphist()
end, "Search: Clipboard")

-- History Group (<leader>fh)
u.nmap("<leader>fhs", function()
	picker.search_history()
end, "Find: Search History")
u.nmap("<leader>fhc", function()
	picker.command_history()
end, "Find: Command History")
u.nmap("<leader>fhr", function()
	picker.resume()
end, "Find: Resume Last Search")

-- 3. [ SEARCH (LEADER S) - Metadata & Config ]
-- Config Group (<leader>sc)
u.nmap("<leader>sci", "<Cmd>edit $MYVIMRC<CR>", "Config: Edit init.lua")
u.nmap("<leader>scc", function()
	picker.files({ cwd = vim.fn.stdpath("config") })
end, "Config: Find File")
u.nmap("<leader>sck", function()
	picker.keymaps({ layout = { preset = "vscode" } })
end, "Config: Search Keymaps")
u.nmap("<leader>scp", function()
	picker.files({
		title = "Plugin Source",
		cwd = vim.fn.stdpath("data") .. "/site/pack/core/opt",
	})
end, "Config: Find Plugin Source")
local cfg = vim.fn.stdpath("config")
u.nmap("<leader>sco", "<Cmd>edit " .. cfg .. "/plugin/00-options.lua<CR>", "Config: Edit Options")

-- Symbols Group (<leader>ss)
u.nmap("<leader>sss", function()
	picker.lsp_symbols()
end, "Search: Find Document Symbols")
u.nmap("<leader>ssS", function()
	picker.lsp_workspace_symbols()
end, "Search: Find Workspace Symbols")
u.nmap("<leader>sst", function()
	picker.treesitter()
end, "Search: Treesitter")
u.nmap("<leader>ssb", function()
	require("dropbar.api").pick()
end, "Search: Pick Breadcrumb")

-- Diagnostics Group (<leader>sd)
u.nmap("<leader>sdw", function()
	picker.diagnostics()
end, "Search: Find Workspace Diagnostics")
u.nmap("<leader>sdb", function()
	picker.diagnostics_buffer()
end, "Search: Find Buffer Diagnostics")

-- Internal/System Group (<leader>si)
u.nmap("<leader>sih", function()
	picker.help()
end, "Search: Help Tags")
u.nmap("<leader>siH", function()
	picker.highlights()
end, "Search: Highlight Groups")
u.nmap("<leader>siu", function()
	picker.undo()
end, "Search: Undo History")
u.nmap("<leader>sin", function()
	picker.notifications({ layout = { preset = "ivy_split" } })
end, "Search: Notifications")
u.nmap("<leader>sim", function()
	picker.man()
end, "Search: Manuals")
u.nmap("<leader>sii", function()
	picker.icons()
end, "Search: Icons")
u.nmap("<leader>siq", function()
	picker.qflist()
end, "Search: Quickfix List")
u.nmap("<leader>sil", function()
	picker.loclist()
end, "Search: Location List")
u.nmap("<leader>siM", function()
	picker.marks()
end, "Search: Marks")
u.nmap("<leader>sij", function()
	picker.jumps()
end, "Search: Jumps")

-- 4. [ UI & TOGGLES (LEADER U) ]
u.nmap("<leader>uq", function()
	vim.cmd(vim.fn.getqflist({ winid = true }).winid ~= 0 and "cclose" or "copen")
end, "List: Toggle Quickfix")
u.nmap("<leader>ul", function()
	vim.cmd(vim.fn.getloclist(0, { winid = true }).winid ~= 0 and "lclose" or "lopen")
end, "List: Toggle Location")
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

-- Log Group (<leader>gl)
u.nmap("<leader>gll", function()
	snacks.lazygit.log()
end, "Git: Lazygit Log")
u.nmap("<leader>glf", function()
	snacks.lazygit.log_file()
end, "Git: Lazygit Log (File)")
u.nmap("<leader>glp", function()
	picker.git_log()
end, "Git: Picker Log (All)")
u.nmap("<leader>glb", function()
	picker.git_log_file()
end, "Git: Picker Log (Buffer)")
u.map({ "n", "v" }, "<leader>glh", function()
	require("mini.git").show_range_history()
end, "Git: Show Range History")

-- Hunk Group (<leader>gh)
u.nmap("<leader>gha", function()
	picker.git_diff({ staged = true })
end, "Git: Show Added Hunks (Staged)")
u.nmap("<leader>ghw", function()
	picker.git_diff()
end, "Git: Show Modified Hunks (Workspace)")
u.nmap("<leader>ghb", function()
	picker.git_diff({ path = "%" })
end, "Git: Show Modified Hunks (Buffer)")
u.nmap("<leader>ghd", function()
	picker.git_diff()
end, "Git: Show Diff Hunks")

-- Branch & Web Group (<leader>gb)
u.nmap("<leader>gbb", function()
	picker.git_branches()
end, "Git: Show Branches")
u.map({ "n", "v" }, "<leader>gbw", function()
	snacks.gitbrowse()
end, "Git: Open Browser")

-- Commit Group (<leader>gc)
u.nmap("<leader>gcc", "<Cmd>Git commit<CR>", "Git: Commit")
u.nmap("<leader>gca", "<Cmd>Git commit --amend<CR>", "Git: Commit Amend")

-- Diff Group (<leader>gd)
u.nmap("<leader>gdd", "<Cmd>Git diff<CR>", "Git: Diff (Workspace)")
u.nmap("<leader>gdb", "<Cmd>Git diff -- %<CR>", "Git: Diff (Buffer)")
u.nmap("<leader>gdo", function()
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

-- Navigation Group (<leader>cg)
u.nmap("<leader>cgd", function()
	vim.lsp.buf.definition()
end, "LSP: Definition")
u.nmap("<leader>cgi", function()
	vim.lsp.buf.implementation()
end, "LSP: Implementation")
u.nmap("<leader>cgr", function()
	vim.lsp.buf.references()
end, "LSP: References")
u.nmap("<leader>cgt", function()
	vim.lsp.buf.type_definition()
end, "LSP: Type Definition")

-- Utils Group (<leader>cw)
u.nmap("<leader>cww", function()
	require("mini.trailspace").trim()
end, "Code: Trim Trailing Whitespace")

-- Execute Group (<leader>cx)
u.nmap("<leader>cxx", "<Cmd>Run<CR>", "Code: Smart Run")
u.nmap("<leader>cxw", "<Cmd>RunWatch<CR>", "Code: Smart Run (watch)")

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
u.nmap("<C-/>", function()
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

-- Pick Group (<leader>vp)
u.nmap("<leader>vpa", function()
	pick_visits_labeled("core", false)
end, "Visits: Core (All)")
u.nmap("<leader>vpc", function()
	pick_visits_labeled("core", true)
end, "Visits: Core (CWD)")

-- Label Group (<leader>vl)
u.nmap("<leader>vla", function()
	visits.add_label("core")
end, 'Visits: Add "core" Label')
u.nmap("<leader>vlr", function()
	visits.remove_label("core")
end, 'Visits: Remove "core" Label')
u.nmap("<leader>vlA", function()
	visits.add_label()
end, "Visits: Add Custom Label")
u.nmap("<leader>vlR", function()
	visits.remove_label()
end, "Visits: Remove Custom Label")
