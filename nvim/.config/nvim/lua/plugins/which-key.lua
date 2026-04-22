-- =============================================================================
-- [ WHICH-KEY ]
-- Displays a popup with available keybindings for the current mode/prefix.
-- =============================================================================

local M = {}

local mini = Config.safe_require("plugins.mini")
local icons = Config.safe_require("mini.icons")
local wk = Config.safe_require("which-key")

mini.now(function()
	wk.setup({
		preset = "helix",
	})
	wk.add({
		-- Top level groups
		{ "<leader>c", group = "Code", icon = "" },
		{ "<leader>cg", group = "Code: Go to", icon = icons.get("lsp", "method") },
		{ "<leader>cw", group = "Code: Utils", icon = icons.get("lsp", "operator") },
		{ "<leader>cx", group = "Code: Execute", icon = icons.get("lsp", "event") },
		{ "<leader>d", group = "Debug", icon = icons.get("lsp", "event") },
		{ "<leader>dp", group = "Debug Profiler", icon = icons.get("lsp", "event") },
		{ "<leader>f", group = "Find", icon = icons.get("lsp", "reference") },
		{ "<leader>fe", group = "Find: Explorer", icon = icons.get("directory", "index") },
		{ "<leader>ff", group = "Find: Files", icon = icons.get("file", "file") },
		{ "<leader>fg", group = "Find: Grep/Text", icon = icons.get("lsp", "string") },
		{ "<leader>fh", group = "Find: History", icon = icons.get("lsp", "event") },
		{ "<leader>g", group = "Git", icon = icons.get("filetype", "git") },
		{ "<leader>gb", group = "Git Branch/Web", icon = icons.get("lsp", "reference") },
		{ "<leader>gc", group = "Git Commit", icon = icons.get("lsp", "struct") },
		{ "<leader>gd", group = "Git Diff", icon = icons.get("lsp", "operator") },
		{ "<leader>gh", group = "Git Hunk", icon = icons.get("lsp", "operator") },
		{ "<leader>gl", group = "Git Log", icon = icons.get("lsp", "event") },
		{ "<leader>go", desc = "Git: Show Object at Cursor" },
		{ "<leader>o", group = "Obsidian", icon = icons.get("filetype", "markdown") },
		{ "<leader>q", group = "Quit/Session", icon = icons.get("os", "exit") },
		{ "<leader>p", group = "Profiler", icon = icons.get("lsp", "event") },
		{ "<leader>s", group = "Search", icon = icons.get("lsp", "snippet") },
		{ "<leader>sc", group = "Search: Config", icon = icons.get("os", "windows") },
		{ "<leader>sd", group = "Search: Diagnostics", icon = icons.get("lsp", "event") },
		{ "<leader>si", group = "Search: Internal", icon = icons.get("lsp", "reference") },
		{ "<leader>ss", group = "Search: Symbols", icon = icons.get("lsp", "function") },
		{ "<leader>u", group = "UI/Toggles", icon = icons.get("lsp", "interface") },
		{ "<leader>m", group = "Mark", icon = "󱫀" },
		{ "<leader>t", group = "Terminal", icon = "" },
		{ "<leader>v", group = "Visits", icon = icons.get("lsp", "reference") },
		{ "<leader>vp", group = "Visits: Pick", icon = icons.get("lsp", "keyword") },
		{ "<leader>vl", group = "Visits: Label", icon = icons.get("lsp", "string") },

		-- Align (mini.align)
		{ "ga", desc = "Align", mode = { "n", "x" }, icon = icons.get("lsp", "operator") },
		{ "gA", desc = "Align (with preview)", mode = { "n", "x" }, icon = icons.get("lsp", "operator") },

		{ "gs", group = "surround", icon = icons.get("lsp", "operator") },
		{ "gsa", desc = "Add surrounding", mode = { "n", "x" } },
		{ "gsd", desc = "Delete surrounding" },
		{ "gsr", desc = "Replace surrounding" },
		{ "gsf", desc = "Find right surrounding" },
		{ "gsF", desc = "Find left surrounding" },
		{ "gsh", desc = "Highlight surrounding" },
		{ "gsn", desc = "Update n_lines" },

		-- Bracket Navigation (mini.bracketed)
		{ "[", group = "prev", icon = icons.get("lsp", "variable") },
		{ "]", group = "next", icon = icons.get("lsp", "variable") },
		{ "g", group = "goto", icon = icons.get("lsp", "method") },
		{ "z", group = "fold", icon = icons.get("lsp", "operator") },
		{ "[b", desc = "Buffer" },
		{ "]b", desc = "Buffer" },
		{ "[d", desc = "Diagnostic" },
		{ "]d", desc = "Diagnostic" },
		{ "[f", desc = "File" },
		{ "]f", desc = "File" },
		{ "[q", desc = "Quickfix" },
		{ "]q", desc = "Quickfix" },

		-- Expanders for built-in info
		{
			"<leader>b",
			group = "buffer",
			icon = icons.get("file", "file"),
			expand = function()
				return require("which-key.extras").expand.buf()
			end,
		},
		{
			"<leader>w",
			group = "window",
			icon = icons.get("os", "windows"),
			expand = function()
				return require("which-key.extras").expand.win()
			end,
		},

		-- Single Key Overrides
		{ "<leader>ct", desc = "Code: Trim Trailing Whitespace" },
		{ "<leader>fb", desc = "Find: Buffers" },
		{ "<leader>fff", desc = "Find: Files" },
		{ "<leader>ffg", desc = "Find: Git Files" },
		{ "<leader>ffp", desc = "Find: Projects" },
		{ "<leader>ffz", desc = "Find: Zoxide Path" },
		{ "<leader>ffv", desc = "Find: Recent Visits" },
		{ "<leader>fhs", desc = "Find: Search History" },
		{ "<leader>fhc", desc = "Find: Command History" },
		{ "<leader>fhr", desc = "Find: Resume Last Search" },
		{ "<leader><space>", desc = "Find: Smart Files", icon = icons.get("lsp", "constant") },
		{ "<leader>/", desc = "Search: Global Grep", icon = icons.get("lsp", "keyword") },
		{ "<leader>n", desc = "Notify: Show History", icon = icons.get("lsp", "event") },
		{ "<leader>.", desc = "Scratch: Toggle Buffer", icon = icons.get("lsp", "snippet") },
		{ "<leader>S", desc = "Scratch: Select Buffer", icon = icons.get("lsp", "snippet") },
		{ "gx", desc = "Open with system app", icon = icons.get("lsp", "keyword") },

		-- Global/Local help
		{
			"<leader>?",
			function()
				wk.show({ global = false })
			end,
			desc = "Buffer Local Keymaps",
			icon = icons.get("file", "info"),
		},

		-- Text Objects (mini.ai support)
		{
			mode = { "o", "x" },
			{ "a", group = "around", icon = icons.get("lsp", "class") },
			{ "i", group = "inside", icon = icons.get("lsp", "class") },
			{ "g", group = "goto", icon = icons.get("lsp", "method") },
			{ "gg", desc = "first line" },
			{ "ge", desc = "prev word end" },
			{ "gE", desc = "prev WORD end" },
			{ "g_", desc = "last char" },
			{ "g,", desc = "next change" },
			{ "g;", desc = "prev change" },
			{ "s", group = "surround", icon = icons.get("lsp", "operator") },
			{ "as", desc = "around surround" },
			{ "is", desc = "inside surround" },
			{ "[", group = "prev", icon = icons.get("lsp", "variable") },
			{ "[b", desc = "buffer" },
			{ "[d", desc = "diagnostic" },
			{ "[q", desc = "quickfix" },
			{ "]", group = "next", icon = icons.get("lsp", "variable") },
			{ "]b", desc = "buffer" },
			{ "]d", desc = "diagnostic" },
			{ "]q", desc = "quickfix" },
			{ "at", desc = "tag" },
			{ "it", desc = "tag" },
			{ "af", desc = "function" },
			{ "if", desc = "function" },
			{ "ao", desc = "block" },
			{ "io", desc = "block" },
			{ "aa", desc = "argument" },
			{ "ia", desc = "argument" },
		},
		-- Buffer sub-mappings (alongside expander)
		{ "<leader>ba", desc = "Buffer: Alternate" },
		{ "<leader>bs", desc = "Buffer: Scratch" },
		{ "<leader>bd", desc = "Buffer: Delete" },
		{ "<leader>bD", desc = "Buffer: Delete!" },
		{ "<leader>bw", desc = "Buffer: Wipeout" },
		{ "<leader>bW", desc = "Buffer: Wipeout!" },

		-- Find Group Sub-mappings
		{ "<leader>fee", desc = "Explore: Open Directory (CWD)" },
		{ "<leader>fef", desc = "Explore: Open File Directory" },
		{ "<leader>fep", desc = "Explore: Open Plugins Directory" },
		{ "<leader>fgg", desc = "Search: Multi Grep" },
		{ "<leader>fgw", desc = "Search: Word (CWD)" },
		{ "<leader>fgt", desc = "Search: Find TODO/FIXME/NOTE" },
		{ "<leader>fgc", desc = "Search: Clipboard" },

		-- Search Group Sub-mappings
		{ "<leader>sci", desc = "Config: Edit init.lua" },
		{ "<leader>scc", desc = "Config: Find File" },
		{ "<leader>sck", desc = "Config: Search Keymaps" },
		{ "<leader>scp", desc = "Config: Find Plugin Source" },
		{ "<leader>sco", desc = "Config: Edit Options" },
		{ "<leader>sss", desc = "Search: Find Document Symbols" },
		{ "<leader>ssS", desc = "Search: Find Workspace Symbols" },
		{ "<leader>sst", desc = "Search: Treesitter" },
		{ "<leader>ssb", desc = "Search: Pick Breadcrumb" },
		{ "<leader>sdw", desc = "Search: Find Workspace Diagnostics" },
		{ "<leader>sdb", desc = "Search: Find Buffer Diagnostics" },
		{ "<leader>sih", desc = "Search: Help Tags" },
		{ "<leader>siH", desc = "Search: Highlight Groups" },
		{ "<leader>siu", desc = "Search: Undo History" },
		{ "<leader>sin", desc = "Search: Notifications" },
		{ "<leader>sim", desc = "Search: Manuals" },
		{ "<leader>sii", desc = "Search: Icons" },
		{ "<leader>siq", desc = "Search: Quickfix List" },
		{ "<leader>sil", desc = "Search: Location List" },
		{ "<leader>siM", desc = "Search: Marks" },
		{ "<leader>sij", desc = "Search: Jumps" },

		-- UI / Toggles
		{ "<leader>uq", desc = "List: Toggle Quickfix" },
		{ "<leader>ul", desc = "List: Toggle Location" },
		{ "<leader>un", desc = "Notify: Show History" },

		-- Git: Sub-groups
		{ "<leader>gcc", desc = "Git: Commit" },
		{ "<leader>gca", desc = "Git: Commit Amend" },
		{ "<leader>gdd", desc = "Git: Diff (Workspace)" },
		{ "<leader>gdb", desc = "Git: Diff (Buffer)" },
		{ "<leader>gdo", desc = "Git: Toggle Diff Overlay" },
		{ "<leader>gll", desc = "Git: Lazygit Log" },
		{ "<leader>glf", desc = "Git: Lazygit Log (File)" },
		{ "<leader>glp", desc = "Git: Picker Log (All)" },
		{ "<leader>glb", desc = "Git: Picker Log (Buffer)" },
		{ "<leader>glh", desc = "Git: Show Range History", mode = { "n", "v" } },
		{ "<leader>gbb", desc = "Git: Show Branches" },
		{ "<leader>gbw", desc = "Git: Open Browser", mode = { "n", "v" } },

		-- Code / LSP (under existing <leader>c group)
		{ "<leader>ca", desc = "Code: Action", mode = { "n", "x" } },
		{ "<leader>cd", desc = "Code: Diagnostic Popup" },
		{ "<leader>cf", desc = "Code: Format", mode = { "n", "x" } },
		{ "<leader>ch", desc = "Code: Hover" },
		{ "<leader>cl", desc = "Code: CodeLens" },
		{ "<leader>cr", desc = "Code: Rename" },
		{ "<leader>cgd", desc = "LSP: Definition" },
		{ "<leader>cgi", desc = "LSP: Implementation" },
		{ "<leader>cgr", desc = "LSP: References" },
		{ "<leader>cgt", desc = "LSP: Type Definition" },
		{ "<leader>cww", desc = "Code: Trim Trailing Whitespace" },
		{ "<leader>cxx", desc = "Code: Smart Run" },
		{ "<leader>cxw", desc = "Code: Smart Run (watch)" },
	})

	vim.keymap.set("n", "<C-w><space>", function()
		wk.show({ keys = "<c-w>", loop = true })
	end, { desc = "Window Hydra Mode (which-key)" })
end)

return M
