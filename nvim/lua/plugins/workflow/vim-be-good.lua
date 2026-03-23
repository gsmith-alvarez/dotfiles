-- [[ VIM-BE-GOOD: Motion Training ]]
-- Domain: Workflow
--
-- PHILOSOPHY: Gamified Muscle Memory
-- This plugin provides a set of games to help you practice your Vim motions.
-- We use a fork that has been updated for better performance and modern Neovim APIs.

local M = {}
local utils = require('core.utils')

M.setup = function()
  local ok, err = pcall(function()
    require('mini.deps').add({
      source = 'gsmith-alvarez/vim-be-good',
    })
  end)

  if not ok then
    utils.soft_notify('Vim-be-good failed to load: ' .. err, vim.log.levels.ERROR)
  end
end

return M
