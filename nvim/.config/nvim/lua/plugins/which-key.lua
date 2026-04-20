-- =============================================================================
-- [ WHICH-KEY ]
-- Displays a popup with available keybindings for the current mode/prefix.
-- =============================================================================

local M = {}

local mini = Config.safe_require "plugins.mini"

mini.later(function()
	require("which-key").setup {
		preset = "helix",
		spec = {
			{
				"<leader>b",
				group = "Buffer",
				icon = "",
				expand = function()
					return require("which-key.extras").expand.buf()
				end,
			},
			{ "<leader>c", group = "Code", icon = "" },
			{ "<leader>f", group = "Finder", icon = "󰭎" },
			{ "<leader>g", group = "Git", icon = "" },
			{ "<leader>u", group = "UI", icon = "󰙵" },
			{ "<leader>e", group = "Execute", icon = "" },
			{
				"<leader>w",
				group = "Window",
				icon = "",
				expand = function()
					return require("which-key.extras").expand.win()
				end,
			},
			{
				"<leader>?",
				function()
					require("which-key").show { global = false }
				end,
				desc = "Buffer Local Keymaps",
			},
			{
				mode = { "o", "x" },
				{ "a", group = "around" },
				{ "i", group = "inside" },
				{ "af", desc = "function" },
				{ "if", desc = "function" },
				{ "ac", desc = "class" },
				{ "ic", desc = "class" },
				{ "ao", desc = "operation" },
				{ "io", desc = "operation" },
				{ "ag", desc = "buffer" },
				{ "ig", desc = "buffer" },
				{ "ad", desc = "digit" },
				{ "id", desc = "digit" },
			},
		},
	}
end)

return M
