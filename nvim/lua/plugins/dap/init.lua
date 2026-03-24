-- [[ LSP/DAP DOMAIN ORCHESTRATOR ]]
-- Location: lua/plugins/dap/init.lua
-- Domain: Intelligence, Diagnostics, & Execution
--
-- PHILOSOPHY: The "Second Brain" Principle
-- The editor should not just show text; it should understand
-- intent and state. These modules provide the deep-tissue
-- inspection required for professional hardware/systems engineering.
--
-- MAINTENANCE TIPS:
-- 1. If debugging fails to start, check `debug.lua` for hardware 
--    server (OpenOCD) logic.
-- 2. Debugging keymaps are central to `core/plugin-keymaps.lua`.
-- 3. Use `:DapInfo` to see active debug sessions and adapters.

local M = {}
local utils = require 'core.utils'

-- [[ THE DOMAIN MODULES ]]
-- We list only the siblings in this specific directory.
-- Logic: We use the dot-notation path relative to the 'plugins' root.
local modules = {
  'dap.debug',                 -- Core DAP + PlatformIO Logic
  'dap.persistent-breakpoint', -- Session Persistence for Traps
}

for _, mod in ipairs(modules) do
  local module_path = 'plugins.' .. mod

  -- [[ THE CIRCUIT BREAKER ]]
  -- Wrapping each module in a pcall ensures that a failure in
  -- the Debugger doesn't crash your Text Editor.
  local ok, mod_or_err = pcall(require, module_path)
  if ok and type(mod_or_err) == 'table' and type(mod_or_err.setup) == 'function' then
    local setup_ok, setup_err = pcall(mod_or_err.setup)
    if not setup_ok then
      utils.soft_notify(string.format('DOMAIN SETUP FAILURE: [%s]\n%s', module_path, setup_err), vim.log.levels.ERROR)
    end
  elseif not ok then
    local err = mod_or_err
    -- ERROR CORRECTION: Log the specific failure to our diagnostic audit trail
    -- while notifying the UI so the user isn't left in the dark.
    utils.soft_notify(string.format('DAP DOMAIN FAILURE: [%s]\n%s', module_path, err), vim.log.levels.ERROR)
  end
end

-- THE CONTRACT: Return the module to satisfy the Global Plugins Orchestrator
return M
