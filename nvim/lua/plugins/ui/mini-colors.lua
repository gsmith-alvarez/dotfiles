-- [[ MINI.BASE16: Catppuccin Mocha ]]
-- Domain: UI & Aesthetics
--
-- Uses mini.base16 (already in mini.nvim) instead of the catppuccin/nvim plugin.
-- No external dependency, no compile step, no cache management.
-- Palette sourced from the official Catppuccin Mocha spec.

local M = {}
local utils = require 'core.utils'

local ok, err = pcall(function()
  require('mini.base16').setup({
    palette = {
      base00 = '#1e1e2e', -- base        (background)
      base01 = '#181825', -- mantle      (lighter background)
      base02 = '#313244', -- surface0    (selection background)
      base03 = '#585b70', -- surface2    (comments)
      base04 = '#a6adc8', -- subtext0    (dark foreground)
      base05 = '#cdd6f4', -- text        (foreground)
      base06 = '#f5e0dc', -- rosewater   (light foreground)
      base07 = '#b4befe', -- lavender    (brightest foreground)
      base08 = '#f38ba8', -- red         (variables, xml tags)
      base09 = '#fab387', -- peach       (integers, booleans)
      base0A = '#f9e2af', -- yellow      (classes, search)
      base0B = '#a6e3a1', -- green       (strings)
      base0C = '#94e2d5', -- teal        (support, regex)
      base0D = '#89b4fa', -- blue        (functions)
      base0E = '#cba6f7', -- mauve       (keywords)
      base0F = '#f2cdcd', -- flamingo    (deprecated, embedded)
    },
    use_cterm = false,
  })
end)

if not ok then
  vim.cmd.colorscheme 'habamax'
  utils.soft_notify('mini.base16 failed to load. Falling back to native theme. Error: ' .. err, vim.log.levels.ERROR)
end

return M
