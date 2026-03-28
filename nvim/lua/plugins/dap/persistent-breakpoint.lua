-- [[ PERSISTENT-BREAKPOINTS: Debug State Serialization ]]
-- Domain: Debugging & Project Continuity
-- Location: lua/plugins/dap/persistent-breakpoint.lua
--
-- PHILOSOPHY: State Preservation
-- Breakpoints should survive between Neovim sessions. This module
-- serializes breakpoint state to disk so you don't have to re-set
-- traps every time you restart the editor.
--
-- MAINTENANCE TIPS:
-- 1. Breakpoints are saved in `stdpath("state") .. "/breakpoints/"`.
-- 2. This module triggers a lightweight DAP bootstrap to ensure
--    signs (gutter icons) are rendered on buffer load.
-- 3. Keymap `<leader>db` toggles breakpoints.

local M = {}
local utils = require 'core.utils'

M.setup = function()
  local ok, err = pcall(function()
    -- 1. THE BRIDGE: We MUST add the core DAP library to the runtime path
    -- before this plugin attempts to read breakpoints on BufReadPost.
    -- This invokes the lightweight bootstrap, NOT the heavy hardware adapters.
    require('plugins.dap.debug').bootstrap()

    local MiniDeps = require 'mini.deps'
    MiniDeps.add 'Weissle/persistent-breakpoints.nvim'

    require('persistent-breakpoints').setup {
      -- Native event handling to load signs
      load_breakpoints_event = { 'BufReadPost' },

      -- XDG Compliance
      save_dir = vim.fn.stdpath 'state' .. '/breakpoints/',
    }
  end)

  if not ok then
    utils.soft_notify('Persistent Breakpoints failed: ' .. err, vim.log.levels.ERROR)
  end
end

return M
