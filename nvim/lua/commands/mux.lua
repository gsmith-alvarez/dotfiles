-- [[ MUX INTEROP: Zellij Pane Management ]]
-- Domain: Terminal Multiplexer Orchestration
-- Location: lua/commands/mux.lua
--
-- PHILOSOPHY: The Seamless Workbench
-- Neovim handles the text; Zellij handles the session. This module provides
-- the bridge for opening new panes, sending commands, and managing the
-- layout from within the editor.
--
-- WHY: We use Zellij for long-running builds and tests to keep Neovim's
-- UI thread unblocked and responsive.
--
-- MAINTENANCE TIPS:
-- 1. Zellij pane keymaps live in `lua/core/plugin-keymaps.lua` (<leader>z).
-- 2. Pane navigation (<C-h/j/k/l>) is in `plugins/navigation/smart-splits.lua`.
-- 3. If pane creation fails, check if the `zellij` binary is in your PATH.

local M = {}

M.commands = {
  -- Future Zellij-specific commands go here.
}

return M
