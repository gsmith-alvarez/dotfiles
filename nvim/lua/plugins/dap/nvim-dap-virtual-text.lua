-- [[ DAP-VIRTUAL-TEXT: Inline State Inspection ]]
-- Domain: Debugging & UI
-- Location: lua/plugins/dap/nvim-dap-virtual-text.lua
--
-- PHILOSOPHY: Zero-Latency State Mapping
-- State is rendered directly in the buffer's virtual space.
-- ARCHITECTURE: Completely dormant until explicitly invoked by the DAP JIT engine.
--
-- MAINTENANCE TIPS:
-- 1. This module is automatically initialized by `debug.lua` during 
--    the DAP bootstrap.
-- 2. If virtual text is too noisy, adjust the `filter` function.
-- 3. Variable values are displayed at the end of the line (EOL).

local M = {}
local utils = require('core.utils')

-- THE CONTRACT: This function is completely isolated. It will not execute
-- until explicitly called by the main debug orchestrator.
M.setup = function()
  local ok, err = pcall(function()
    local MiniDeps = require('mini.deps')

    -- 1. Dependency Management
    MiniDeps.add('theHamsta/nvim-dap-virtual-text')

    -- 2. Configuration
    require('nvim-dap-virtual-text').setup({
      enabled = true,
      enabled_commands = true,
      highlight_changed_variables = true,
      highlight_new_as_changed = false,
      show_stop_reason = true,
      commented = false,

      -- Filter out "noise" variables that aren't helpful in embedded
      filter = function(variable, buf)
        return true -- Hardware requires absolute visibility
      end,

      -- Display Options
      virt_text_pos = 'eol',
      all_frames = false,
    })
  end)

  if not ok then
    utils.soft_notify('DAP Virtual Text failed to initialize: ' .. err, vim.log.levels.ERROR)
  end
end

return M

