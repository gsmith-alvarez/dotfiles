-- [[ HISTORY & OMNISEARCH ]]
-- Domain: Temporal Navigation & Contextual Discovery
-- Location: lua/plugins/navigation/history.lua
--
-- PHILOSOPHY: Recency-First Discovery
-- We prioritize historical context (recent files, previous searches) as the
-- fastest way to resume work. This module ensures the infrastructure for
-- project-wide discovery is available.
--
-- MAINTENANCE TIPS:
-- 1. Picker config and keymaps live in `plugins/core/snacks.lua`.
-- 2. Use `<leader>fr` to find recent files across the entire system.
-- 3. Use `<leader>fc` to find recent files restricted to the current CWD.

local M = {}

M.setup = function()
  require('mini.deps').add 'folke/snacks.nvim'
end

return M
