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
		{ "gp", group = "LSP: Picker", icon = icons.get("lsp", "keyword") },
		{ "gs", group = "Sort/Surrond", icon = "󱄽" },
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
	})

	vim.keymap.set("n", "<C-w><space>", function()
		wk.show({ keys = "<c-w>", loop = true })
	end, { desc = "Window Hydra Mode (which-key)" })
end)

return M
