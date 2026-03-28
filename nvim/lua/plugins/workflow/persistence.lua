-- [[ MINI.SESSIONS: Automatic Session Management ]]
-- Domain: Workflow & Context Switching
-- Location: lua/plugins/workflow/persistence.lua
--
-- PHILOSOPHY: Automatic State Recovery
-- Manually reopening files after a crash, restart, or branch switch
-- is a low-multiplier task. mini.sessions automates the "where was I?"
-- phase of development. Already bundled in mini.nvim — zero extra deps.
--
-- MAINTENANCE TIPS:
-- 1. Sessions are automatically saved to `stdpath('state') .. '/sessions'`.
-- 2. Use `<leader>qs` to restore the last session.
-- 3. Use `<leader>qw` to manually save or name a session.

local M = {}
local utils = require 'core.utils'

M.setup = function()
  local ok, err = pcall(function()
    require('mini.sessions').setup {
      autoread = false, -- manual restore via keymap
      autowrite = true, -- auto-save active session before quitting
      directory = vim.fn.stdpath 'state' .. '/sessions',
      verbose = { read = false, write = false, delete = false },
    }
    -- Session keymaps in lua/core/plugin-keymaps.lua (<leader>q section).
  end)

  if not ok then
    utils.soft_notify('mini.sessions failed to load: ' .. err, vim.log.levels.ERROR)
  end
end

return M
