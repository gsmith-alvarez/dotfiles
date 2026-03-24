-- [[ MINI.BASE16: Catppuccin Mocha ]]
-- Purpose: Provide a consistent, high-contrast theme across the entire UI.
-- Domain:  UI & Aesthetics
-- Architecture: Synchronous Foundation Layer
--
-- PHILOSOPHY: Zero-Dependency Theming
-- This is a core "Anti-Fragile" pillar. By using `mini.base16` (part of the
-- existing `mini.nvim` core) instead of a standalone theme plugin, we 
-- eliminate an external dependency, avoid complex compile/cache steps, 
-- and ensure the theme is available even in "safe mode."
--
-- MAINTENANCE TIPS:
-- 1. If colors look "off," verify your terminal supports 24-bit (TrueColor).
-- 2. To change the theme, update the HEX codes in the `palette` table.
-- 3. If this fails, the system falls back to `habamax` as an Anti-Fragile safety net.

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
