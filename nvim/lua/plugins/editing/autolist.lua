local M = {}
local utils = require 'core.utils'

local loaded = false

local function bootstrap_for_buffer(buf)
  local ok, err = pcall(function()
    require('mini.deps').add 'gaoDean/autolist.nvim'
    if not loaded then
      require('autolist').setup {
        lists = {
          markdown = {
            '[-+*]',
            '%d+[.)]',
            '%a[.)]',
            '%u*[.)]',
            '>+', -- Matches blockquotes like > and >>
          },
          text = {
            '[-+*]',
            '%d+[.)]',
            '%a[.)]',
            '%u*[.)]',
            '>+', -- Matches blockquotes like > and >>
          },
        },
      }
      loaded = true
    end

    local function map(mode, lhs, rhs, opts)
      local options = vim.tbl_extend('force', { buffer = buf }, opts or {})
      vim.keymap.set(mode, lhs, rhs, options)
    end

    map('i', '<tab>', '<cmd>AutolistTab<cr>')
    map('i', '<s-tab>', '<cmd>AutolistShiftTab<cr>')
    map('i', '<CR>', '<CR><cmd>AutolistNewBullet<cr>')
    map('n', 'o', 'o<cmd>AutolistNewBullet<cr>')
    map('n', 'O', 'O<cmd>AutolistNewBulletBefore<cr>')
    map('n', '<CR>', '<cmd>AutolistToggleCheckbox<cr><CR>')
    map('n', '<C-r>', '<cmd>AutolistRecalculate<cr>')

    map('n', '<leader>cn', require('autolist').cycle_next_dr, { expr = true })
    map('n', '<leader>cp', require('autolist').cycle_prev_dr, { expr = true })

    map('n', '>>', '>><cmd>AutolistRecalculate<cr>')
    map('n', '<<', '<<<cmd>AutolistRecalculate<cr>')
    map('n', 'dd', 'dd<cmd>AutolistRecalculate<cr>')
    map('v', 'd', 'd<cmd>AutolistRecalculate<cr>')
  end)

  if not ok then
    utils.soft_notify('autolist failed to initialize: ' .. err, vim.log.levels.ERROR)
  end
end

M.setup = function()
  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'markdown', 'text', 'tex', 'plaintex', 'norg' },
    callback = function(args)
      bootstrap_for_buffer(args.buf)
    end,
  })
end

return M
