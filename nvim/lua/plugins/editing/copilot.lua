-- [[ COPILOT: AI Pair Programmer ]]
-- Purpose: Provide context-aware AI code completion in the background.
-- Domain:  Editing / AI
-- Architecture: Deferred Background Worker (Phased Boot)
--
-- PHILOSOPHY: Non-Intrusive Assistance
-- Copilot is configured as an "Anti-Fragile" assistant: it uses ghost text 
-- (inline suggestions) rather than a disruptive popup. This respects the 
-- "Home-Row" navigation protocol and ensures that AI never blocks the 
-- primary UI thread.
--
-- MAINTENANCE TIPS:
-- 1. If Copilot stops working, run `:Copilot auth` to re-authenticate.
-- 2. Keybinds are mapped to <C-l> (accept) and <C-j>/<C-k> (cycle).
-- 3. You can toggle auto-trigger via `<leader>uc` (Utilities).

local M = {}
M.setup = function()
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
