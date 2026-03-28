-- [[ MINI.NVIM: Core Foundation ]]
-- Domain: Core
-- TIER 0 only: icons (deferred setup) and tabline (synchronous).
-- All other mini.nvim modules live in their respective domains.

local M = {}
local utils = require 'core.utils'

M.setup = function()
  local ok, err = pcall(function()
    require('mini.deps').add 'echasnovski/mini.nvim'

    -- ICONS: Added to rtp immediately; setup deferred out of the hot path
    require('mini.deps').add 'echasnovski/mini.icons'
    vim.schedule(function()
      require('mini.icons').setup {}
      require('mini.icons').mock_nvim_web_devicons()
    end)

    -- TABLINE: Visible immediately on boot
    require('mini.tabline').setup {
      show_icons = true,
      set_vim_settings = true,
      format = nil,
    }
  end)

  if not ok then
    utils.soft_notify('Mini foundation failed: ' .. err, vim.log.levels.ERROR)
  end
end

return M
