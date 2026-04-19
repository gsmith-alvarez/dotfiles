-- =============================================================================
-- [ WHICH-KEY ]
-- Displays a popup with available keybindings for the current mode/prefix.
-- =============================================================================

local M = {}

local mini = Config.safe_require("plugins.mini")

mini.later(function()
	require("which-key").setup({
		preset = "modern",
		spec = {
			{ "<leader>c", group = "Code", icon = "" },
			{ "<leader>f", group = "File", icon = "" },
			{ "<leader>g", group = "Git", icon = "" },
			{ "<leader>u", group = "UI", icon = "󰙵" },
			{ "<leader>w", group = "Window", icon = "" },
		},
	})
end)

return M
