-- [[ SNACKS.NVIM: The Centralized Pillar ]]
-- Domain: Workflow, UI, Navigation, and Profiling
--
-- PHILOSOPHY: Single Source of Truth & Zero-Overhead Boot
-- We call setup exactly once. Snacks handles its own lazy-loading internally.
-- We only enable the profiler if the PROFILE=1 environment variable is set.

local M = {}
local utils = require 'core.utils'

M.setup = function()
  -- [[ THE BOOTSTRAPPER ]]
  -- Deferred to keep snacks.picker out of the startup hot path.
  -- Keymaps are registered immediately as closures; setup runs after first render.
  vim.schedule(function()
    local ok, err = pcall(function()
      require('snacks').setup {
      -- 1. UI: Immediate Message Interception (Lean)
      notifier = {
        enabled = true,
        timeout = 3000,
        top_down = false,
        level = vim.log.levels.INFO, -- DEBUG notifications go to history only, no popup
      },

      -- 2. PROFILING: Conditional overhead
      profiler = { enabled = vim.env.PROFILE ~= nil },

      -- 3. WORKFLOW: Definitions (Lazy-loaded on first call)
      terminal = {
        win = { border = 'rounded', winblend = 3, keys = { q = 'hide' } },
      },

      -- 4. NAVIGATION: Definitions (Lazy-loaded on first call)
      picker = {
        enabled = true,
        ui_select = true,
        sources = {
          files = {
            hidden = true,
            ignored = true,
            exclude = { ".git", ".pio", "node_modules", "build" },
          },
        },
        win = {
          input = {
            keys = {
              ["<C-j>"] = { "list_down", mode = { "i", "n" } },
              ["<C-k>"] = { "list_up",   mode = { "i", "n" } },
            },
          },
        },
      },

      -- 5. LSP PROGRESS: Spinner shown while language servers index/load (replaces fidget.nvim)
      progress = { enabled = true },

      -- 6. EXPLICIT OPT-OUT: Save cycles by disabling unused modules
      dashboard = { enabled = false },
      indent = { enabled = false },
      input = { enabled = false },
      scope = { enabled = false },
      scroll = { enabled = false },
      words = { enabled = false },
      statuscolumn = { enabled = false },
      lazygit = { enabled = false },
    }
  end)

  if not ok then
    utils.soft_notify('Snacks.nvim failed: ' .. err, vim.log.levels.ERROR)
  end
  end)

  -- [[ ON-DEMAND KEYMAPS ]]
  -- All keymaps moved to lua/core/plugin-keymaps.lua.
  -- Profiler keys removed (dev-only, polluted <leader>z Zellij prefix).
end

return M
