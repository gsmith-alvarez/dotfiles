-- which-key

local M = {}

local mini = Config.safe_require("plugins.mini")
local icons = Config.safe_require("mini.icons")
local wk = Config.safe_require("which-key")

mini.now(function()
	wk.setup({
		preset = "helix",
		triggers = {
			{ "<auto>", mode = "nixsotc" },
			{ "s", mode = { "n", "x" } },
			{ "g", mode = { "n", "x" } },
		},
	})
	wk.add({
		-- Top level groups
		{ "<leader>c", group = "Code", icon = "" },
		{ "<leader>cg", desc = "Goto Definition", icon = icons.get("lsp", "keyword") },
		{ "<leader>d", group = "Debug", icon = icons.get("lsp", "event") },
		{ "<leader>f", group = "Find (Files/Buffers)", icon = icons.get("lsp", "reference") },
		{ "<leader>g", group = "Git", icon = icons.get("filetype", "git") },
		{ "<leader>q", group = "Quit/Session", icon = icons.get("os", "exit") },
		{ "<leader>p", group = "Profiler", icon = icons.get("lsp", "event") },
		{ "<leader>s", group = "Search (Content/System)", icon = icons.get("lsp", "snippet") },
		{ "<leader>u", group = "UI/Toggles", icon = icons.get("lsp", "interface") },
		{ "<leader>m", group = "Mark", icon = "󱫀" },
		{ "<leader>t", group = "Terminal", icon = "" },
		{ "<leader>v", group = "Visits", icon = icons.get("lsp", "reference") },
		{ "<leader>o", group = "options", icon = icons.get("lsp", "symbols") },
		{ "<leader>x", group = "Diagnostics / Lists", icon = icons.get("lsp", "event") },
		{ "g", group = "Go / LSP / Navigation", icon = icons.get("lsp", "keyword") },
		{ "gp", group = "LSP: Picker", icon = icons.get("lsp", "keyword") },
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

mini.later(function()
	wk.add({
		{ "gs", desc = "Sort", icon = "󱄽", mode = { "n", "x" } },
		{ "s", group = "Surround", icon = icons.get("lsp", "operator"), mode = { "n", "x" } },
	})
end)

return M
