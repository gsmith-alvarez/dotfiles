-- [[ TROUBLE: Diagnostic & Quickfix Aggregation ]]
-- Domain: UI & Code Auditing
--
-- PHILOSOPHY: Action-Driven JIT Execution
-- Trouble is a heavy diagnostic aggregator. It should never load when a buffer 
-- opens. It should only consume memory the exact millisecond you ask to view 
-- your workspace errors.

local M = {}
local utils = require('core.utils')

local loaded = false

-- [[ The JIT Engine ]]
local function bootstrap_trouble()
  if loaded then return true end

  local ok, err = pcall(function()
    require('mini.deps').add('folke/trouble.nvim')
    
    require('trouble').setup({
      -- We enforce modern UI aesthetics that match our color theme
      auto_close = true,       -- Auto close when an item is selected
      auto_preview = false,    -- Disable auto-preview to save CPU cycles
      focus = true,            -- Jump straight into the Trouble window
    })
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
