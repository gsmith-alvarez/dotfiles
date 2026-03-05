-- [[ REFACTORING.NVIM: Codebase Transformation ]]
-- Domain: Text Manipulation & Refactoring
--
-- PHILOSOPHY: Action-Driven JIT Execution
-- Refactoring is a heavy, AST-dependent operation.
-- The engine only spins up the exact moment you attempt a refactor.

local M = {}
local utils = require('core.utils')

local loaded = false

-- [[ The JIT Engine ]]
local function bootstrap_refactoring()
  if loaded then return true end

  -- 1. True AST Validation
  -- We must verify if the engine can actually read the current buffer's filetype.
  local ok_ts, parsers = pcall(require, 'nvim-treesitter.parsers')
  if not ok_ts or not parsers.has_parser() then
    utils.soft_notify('AST Error: No active Treesitter parser for this file.', vim.log.levels.WARN)
    return false
  end

  local ok, err = pcall(function()
    require('mini.deps').add({
      source = 'ThePrimeagen/refactoring.nvim',
      depends = { 'nvim-treesitter/nvim-treesitter' }
    })

    require('refactoring').setup({})
  end)

  if not ok then
    utils.soft_notify('Refactoring engine failed to initialize: ' .. err, vim.log.levels.ERROR)
    return false
  end

  loaded = true
  return true
end

-- Keymaps moved to lua/core/plugin-keymaps.lua under Refactor (<leader>r) section.

M.bootstrap = bootstrap_refactoring

return M
