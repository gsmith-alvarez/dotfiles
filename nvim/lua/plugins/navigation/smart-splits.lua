-- [[ SMART-SPLITS: Multiplexer Integration ]]
-- Domain: Inter-Pane Movement (Neovim <-> Zellij)
-- Location: lua/plugins/navigation/smart-splits.lua
--
-- PHILOSOPHY: Anti-Fragile Proxy Execution
-- Bridges Neovim splits and Zellij panes with zero startup overhead.
-- It ensures that `<C-h/j/k/l>` moves seamlessly between Neovim windows
-- and terminal panes.
--
-- MAINTENANCE TIPS:
-- 1. If movement between Neovim and Zellij fails, check if `zellij` is 
--    in your system PATH (managed by Mise).
-- 2. Resize is mapped to `<M-h/j/k/l>`.
-- 3. This module uses a JIT bootstrap to replace the core keymaps only
--    when you first attempt to move windows.

local M = {}
local utils = require('core.utils')

local loaded = false

-- [[ The Hotswap Engine ]]
local function bootstrap_smart_splits()
  if loaded then return true end

  local ok, err = pcall(function()
    local MiniDeps = require('mini.deps')
    MiniDeps.add("mrjones2014/smart-splits.nvim")

    local zellij_path = vim.fn.executable('zellij') == 1 and 'zellij' or nil

    require("smart-splits").setup({
      -- 1. Multiplexer Core
      multiplexer_integration = zellij_path and "zellij" or nil,
      set_default_multiplexer = true,
      disable_multiplexer_nav_when_zoomed = true,
      zellij_move_focus_or_tab = false,

      -- 2. Movement & Behavior
      at_edge = 'wrap',
      move_cursor_same_row = false,
      cursor_follows_swapped_bufs = false,

      -- 3. Defaults & Limits
      default_amount = 3,
      float_win_behavior = 'stack',

      -- 4. Ignored Contexts (Satisfies strict type checking)
      ignored_buftypes = { 'nofile', 'prompt', 'popup' },
      ignored_filetypes = { 'NvimTree', 'snacks_picker_input', 'alpha' },
      ignored_events = { 'BufEnter', 'WinEnter' },

      -- Explicitly satisfying the 'setup' field if requested by LSP
      setup = nil,
    })
  end)

  if not ok then
    utils.soft_notify('Smart-splits failed to initialize: ' .. err, vim.log.levels.ERROR)
    return false
  end

  -- [[ THE PERMANENT OVERWRITE ]]
  local ss = require("smart-splits")
  local map = vim.keymap.set
  local dirs = { h = 'left', j = 'down', k = 'up', l = 'right' }

  for key, dir in pairs(dirs) do
    map({ "n", "t" }, "<C-" .. key .. ">", ss['move_cursor_' .. dir], { desc = "Move " .. dir })
    map({ "n", "t" }, "<M-" .. key .. ">", ss['resize_' .. dir], { desc = "Resize " .. dir })
  end

  loaded = true
  return true
end

-- [[ THE PROXY STUBS ]]
local proxy_dirs = { h = 'left', j = 'down', k = 'up', l = 'right' }

for key, dir in pairs(proxy_dirs) do
  vim.keymap.set({ "n", "t" }, "<C-" .. key .. ">", function()
    if bootstrap_smart_splits() then
      require('smart-splits')['move_cursor_' .. dir]()
    end
  end, { desc = "Smart Move " .. dir .. " (JIT)" })

  vim.keymap.set({ "n", "t" }, "<M-" .. key .. ">", function()
    if bootstrap_smart_splits() then
      require('smart-splits')['resize_' .. dir]()
    end
  end, { desc = "Smart Resize " .. dir .. " (JIT)" })
end

return M
