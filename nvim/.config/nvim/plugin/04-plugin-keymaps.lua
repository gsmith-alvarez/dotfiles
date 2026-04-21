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
end, "Explore: File Tree (toggle)")

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
end, "Search History")
u.nmap("<leader>f:", function()
	picker.command_history()
end, "Command History")
u.nmap("<leader>fr", function()
	picker.resume()
end, "Resume Last Search")

-- Buffers & Files
u.nmap("<leader>fb", function()
	picker.buffers()
end, "Find Buffers")
u.nmap("<leader>ff", function()
	picker.files()
end, "Find Files")
u.nmap("<leader>fg", function()
	picker.git_files()
end, "Find Git Files")
u.nmap("<leader>fp", function()
	picker.projects()
end, "Find Projects")
u.nmap("<leader>fz", function()
	picker.zoxide()
end, "Find Zoxide Path")

-- 3. [ SNACKS: SEARCH (LEADER S) ]
-- Code & Symbols
u.nmap("<leader>ss", function()
	picker.lsp_symbols()
end, "Search Symbols (document)")
u.nmap("<leader>sS", function()
	picker.lsp_workspace_symbols()
end, "Search Symbols (workspace)")
u.nmap("<leader>sg", function()
	multigrep()
end, "Search Multi Grep")
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
end, "Search Word (CWD)")
u.nmap("<leader>sT", function()
	picker.grep({ search = "TODO|FIXME|NOTE|WIP|INFO" })
end, "Search: TODO/FIXME/NOTE")
u.nmap("<leader>st", function()
	picker.treesitter()
end, "Search Treesitter")

-- Diagnostics
u.nmap("<leader>sd", function()
	picker.diagnostics()
end, "Search Diagnostics (workspace)")
u.nmap("<leader>sD", function()
	picker.diagnostics_buffer()
end, "Search Diagnostics (buffer)")

-- UI & Meta
u.nmap("<leader>sh", function()
	picker.help()
end, "Search Help Tags")
u.nmap("<leader>sH", function()
	picker.highlights()
end, "Search Highlight Groups")
u.nmap("<leader>su", function()
	picker.undo()
end, "Search Undo History")
u.nmap("<leader>sk", function()
	picker.keymaps({ layout = { preset = "vscode" } })
end, "Search Keymaps")
u.nmap("<leader>sj", function()
	picker.jumps()
end, "Search Jumps")
u.nmap("<leader>sq", function()
	picker.qflist()
end, "Search Quickfix List")
u.nmap("<leader>sl", function()
	picker.loclist()
end, "Search Location List")
u.nmap("<leader>sm", function()
	picker.marks()
end, "Search Marks")
u.nmap("<leader>si", function()
	picker.icons()
end, "Search Icons")
u.nmap("<leader>sn", function()
	picker.notifications({ layout = { preset = "ivy_split" } })
end, "Search Notifications")
u.nmap("<leader>sM", function()
	picker.man()
end, "Search Manuals")
u.nmap("<leader>sc", function()
	picker.cliphist()
end, "Search Clipboard")

-- 4. [ SNACKS: EXPLORE (LEADER E) ]
u.nmap("<leader>ed", function()
	snacks.explorer()
end, "Directory (CWD)")
u.nmap("<leader>ef", function()
	require("mini.files").open(vim.api.nvim_buf_get_name(0))
end, "File directory")
u.nmap("<leader>ei", "<Cmd>edit $MYVIMRC<CR>", "Edit init.lua")
u.nmap("<leader>ec", function()
	picker.files({ cwd = vim.fn.stdpath("config") })
end, "Find Config File")
u.nmap("<leader>ep", function()
	require("mini.files").open(vim.fn.stdpath("data") .. "/site/pack/core/opt")
end, "Explore Plugins")

-- UI Lists
u.nmap("<leader>eq", function()
	vim.cmd(vim.fn.getqflist({ winid = true }).winid ~= 0 and "cclose" or "copen")
end, "Quickfix List (toggle)")
u.nmap("<leader>eQ", function()
	vim.cmd(vim.fn.getloclist(0, { winid = true }).winid ~= 0 and "lclose" or "lopen")
end, "Location List (toggle)")
u.nmap("<leader>sb", function()
	require("dropbar.api").pick()
end, "Search: Pick Breadcrumb")

-- 5. [ EXECUTE (LEADER X) ]
u.nmap("<leader>xx", "<Cmd>Run<CR>", "Execute: Smart Run")
u.nmap("<leader>xw", "<Cmd>RunWatch<CR>", "Execute: Smart Run (watch)")

-- 6. [ GIT (LEADER G) ]
u.nmap("<leader>gs", function()
	picker.git_status()
end, "Git Status")
u.nmap("<leader>gb", function()
	picker.git_branches()
end, "Git Branches")
u.nmap("<leader>gg", function()
	snacks.lazygit()
end, "Lazygit")
u.map({ "n", "v" }, "<leader>gB", function()
	snacks.gitbrowse()
end, "Git Browse")
-- Git Log
u.nmap("<leader>gl", function()
	picker.git_log()
end, "Git Log (all)")
u.nmap("<leader>gL", function()
	picker.git_log_file()
end, "Git Log (buffer)")
-- Git Hunks
u.nmap("<leader>gha", function()
	picker.git_diff({ staged = true })
end, "Added Hunks (staged)")
u.nmap("<leader>ghm", function()
	picker.git_diff()
end, "Modified Hunks (workspace)")
u.nmap("<leader>ghM", function()
	picker.git_diff({ path = "%" })
end, "Modified Hunks (buffer)")
u.nmap("<leader>ghd", function()
	picker.git_diff()
end, "Git Diff (Hunks)")

-- 7. [ TOP-LEVEL UTILS ]
u.nmap("<leader><space>", function()
	picker.smart()
end, "Smart Find Files")
u.nmap("<leader>/", function()
	picker.grep()
end, "Global Grep")
u.nmap("<leader>n", function()
	snacks.notifier.show_history()
end, "Notification History")
u.nmap("<leader>.", function()
	snacks.scratch()
end, "Toggle Scratch Buffer")
u.nmap("<leader>S", function()
	snacks.scratch.select()
end, "Select Scratch Buffer")

-- 8. [ NAVIGATION & LSP ]
-- gp* = Picker variants (mirrors gr* builtins)
u.nmap("gpd", function()
	picker.lsp_definitions()
end, "LSP: Definitions (Picker)")
u.nmap("gpr", function()
	picker.lsp_references()
end, "LSP: References (Picker)")
u.nmap("gpt", function()
	picker.lsp_type_definitions()
end, "LSP: Type Definitions (Picker)")
u.nmap("gpi", function()
	picker.lsp_implementations()
end, "LSP: Implementations (Picker)")
u.nmap("gpO", function()
	picker.lsp_symbols()
end, "LSP: Document Symbols (Picker)")
u.nmap("<C-/>", function()
	snacks.terminal()
end, "Toggle Terminal")

-- Reference Navigation
u.map({ "n", "t" }, "]]", function()
	snacks.words.jump(vim.v.count1)
end, "Next Reference")
u.map({ "n", "t" }, "[[", function()
	snacks.words.jump(-vim.v.count1)
end, "Prev Reference")

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
