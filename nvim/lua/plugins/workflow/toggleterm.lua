-- [[ SNACKS TERMINAL: The Terminal Command Center ]]
-- Domain: Workflow & External TUI Integration
--
-- PHILOSOPHY: Action-Driven JIT Infrastructure
-- We treat the terminal not as a background process, but as a modular tool.
-- Every external binary (Lazygit, Spotify, Aider) is lazy-loaded and
-- validated against mise shims before execution.
--
-- REFACTOR: Dropped akinsho/toggleterm.nvim in favor of snacks.terminal.
-- Snacks provides a lighter, native Neovim 0.10+ floating terminal
-- without the need for complex persistent proxy classes.

local M = {}
local utils = require 'core.utils'

M.setup = function()
  -- [[ THE TERMINAL FACTORY ]]
  -- Centralized logic for creating floating TUI instances.
  -- Replaces toggleterm's persistent class instantiation.
  local function create_tui(bin_name, desc, cmd_override)
    return function()
      local path = utils.mise_shim(bin_name)
      if not path then
        utils.soft_notify(desc .. ' missing. Install via: mise install ' .. bin_name, vim.log.levels.WARN)
        return
      end

      -- Use Snacks native terminal toggle.
      -- We pass the resolved shim path or the override command.
      require('snacks').terminal.toggle(cmd_override or path)
    end
  end

  -- [[ KEYMAP DEFINITIONS ]]
  -- All keymaps moved to lua/core/plugin-keymaps.lua (Terminal, PIO, Git sections).
end

return M
