-- [[ VERSION CONTROL DOMAIN: lua/plugins/version_control/init.lua ]]
-- =============================================================================
-- Purpose: Orchestrator for all Git and VCS-related integrations.
-- Domain:  Version Control
-- Architecture: Deferred Loading (Phase 2)
--
-- PHILOSOPHY: Lean Version Control
-- -----------------------------------------------------------------------------
-- We use `mini.diff` for fast, native hunk tracking and `snacks.lazygit`
-- for heavy-duty repository management. These are loaded in the background
-- (Phase 2) to ensure the editor stays fast.
-- =============================================================================

local M = {}
local utils = require 'core.utils'

M.setup = function()
  -- [[ THE DOMAIN MODULES ]]
  local modules = {
    'plugins.version_control.mini-diff', -- Inline git signs and hunks.
  }

  for _, module in ipairs(modules) do
    local ok, mod = pcall(require, module)
    if ok and type(mod) == 'table' and type(mod.setup) == 'function' then
      local setup_ok, setup_err = pcall(mod.setup)
      if not setup_ok then
        utils.soft_notify(string.format('VCS SETUP FAILURE: [%s]\n%s', module, setup_err), vim.log.levels.ERROR)
      end
    elseif not ok then
      utils.soft_notify(string.format('VCS LOAD FAILURE: [%s]\n%s', module, mod), vim.log.levels.ERROR)
    end
  end
end

return M
