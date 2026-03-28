-- [[ TROUBLE: Diagnostic & Quickfix Aggregation ]]
-- Purpose: Aggregate errors, warnings, and hints into a navigable list.
-- Domain:  UI & Code Auditing
-- Architecture: Action-Driven JIT Execution (Lazy Load)
--
-- PHILOSOPHY: Memory-on-Demand
-- Trouble is a heavy diagnostic aggregator. In our "Phased Boot" model,
-- it should never load when a buffer opens. It is "Anti-Fragile" by
-- only consuming memory the exact millisecond you ask to view workspace
-- errors, keeping the editor lean during normal typing.
--
-- MAINTENANCE TIPS:
-- 1. If Trouble is missing features, check if `folke/trouble.nvim` is correctly
--    added via MiniDeps.
-- 2. Keymaps are proxied via `core/plugin-keymaps.lua` to maintain lazy loading.
-- 3. Use `:Trouble help` to see all available modes.

local M = {}
local utils = require 'core.utils'

local loaded = false

-- [[ The JIT Engine ]]
local function bootstrap_trouble()
  if loaded then
    return true
  end

  local ok, err = pcall(function()
    require('mini.deps').add 'folke/trouble.nvim'

    require('trouble').setup {
      -- We enforce modern UI aesthetics that match our color theme
      auto_close = true, -- Auto close when an item is selected
      auto_preview = false, -- Disable auto-preview to save CPU cycles
      focus = true, -- Jump straight into the Trouble window
    }
  end)

  if not ok then
    utils.soft_notify('Trouble failed to initialize: ' .. err, vim.log.levels.ERROR)
    return false
  end

  loaded = true
  return true
end

-- [[ THE PROXY KEYMAPS ]]
-- Moved to lua/core/plugin-keymaps.lua under Trouble (<leader>x) section.
-- bootstrap_trouble() is called via pcall(require, 'trouble') in the closures.

-- THE CONTRACT: Return the module to satisfy the UI Orchestrator
return M
