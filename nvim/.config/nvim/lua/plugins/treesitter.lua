-- =============================================================================
-- [ TREESITTER ]
-- Configuration for Treesitter editing and navigation.
-- =============================================================================

local M = {}

local mini = Config.safe_require "plugins.mini"

mini.later(function()
	require("nvim-treesitter.configs").setup {
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
		},
		auto_install = true,
		highlight = {
			enable = true,
			additional_vim_regex_highlighting = false,
		},
		textobjects = {
			select = {
				enable = true,
				lookahead = true,
				keymaps = {
					-- We primarily use mini.ai for these, but nvim-treesitter-textobjects
					-- needs to be enabled for the queries to be loaded correctly.
				},
			},
		},
	}
end)

return M
