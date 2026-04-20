-- =============================================================================
-- [ TREESITTER ]
-- Configuration for Treesitter editing and navigation.
-- =============================================================================

local M = {}

local mini = Config.safe_require "plugins.mini"

-- We use 'now' instead of 'later' to ensure parsers are checked and
-- installed immediately and that queries are available for pickers.
mini.now(function()
	local configs = require("nvim-treesitter.configs")
	configs.setup {
		-- Ensure parsers are installed
		ensure_installed = {
			"lua",
			"vim",
			"vimdoc",
			"markdown",
			"markdown_inline",
			"python",
			"cpp",
			"bash",
			"fish",
			"latex",
			"regex",
		},
		auto_install = true,
		highlight = {
			enable = true,
			additional_vim_regex_highlighting = false,
		},
		incremental_selection = {
			enable = true,
		},
		textobjects = {
			select = {
				enable = true,
				lookahead = true,
			},
			move = {
				enable = true,
				set_jumps = true,
			},
		},
	}
end)

return M
