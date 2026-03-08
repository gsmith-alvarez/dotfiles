local M = {}
local MiniDeps = require('mini.deps')

function M.setup()
	MiniDeps.add({
		source = 'zbirenbaum/copilot.lua',
		-- Note: We do not need standard lazy-loading keys like `event = "InsertEnter"`
		-- here because your orchestrator's `MiniDeps.later` block is already
		-- handling the non-blocking background deferral.
	})

	require('copilot').setup({
		suggestion = {
			enabled = true,
			auto_trigger = true,
			keymap = {
				-- Map this to whatever key you prefer for accepting ghost text
				accept = "<C-l>",
				accept_word = false,
				accept_line = false,
				next = "<C-j>",
				prev = "<C-k>",
				dismiss = "<C-h>",
			},
		},
		-- The panel is usually redundant if you just want inline ghost text
		panel = { enabled = false },
	})
end

return M
