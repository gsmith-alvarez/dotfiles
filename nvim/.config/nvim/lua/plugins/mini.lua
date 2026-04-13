-- =============================================================================
-- [ MINI.NVIM ]
-- Configuration for various modular plugins from the 'mini.nvim' collection.
-- =============================================================================

local M = {}

-- 1. [ COLORSCHEME (mini.base16) ]
-- Set up the base16 colorscheme with a custom Catppuccin-inspired palette.
require('mini.base16').setup({
  palette = {
    base00 = '#1e1e2e', -- mantle
    base01 = '#181825', -- crust
    base02 = '#313244', -- surface0
    base03 = '#45475a', -- surface1
    base04 = '#585b70', -- surface2
    base05 = '#cdd6f4', -- text
    base06 = '#f5e0dc', -- rosewater
    base07 = '#b4befe', -- lavender
    base08 = '#f38ba8', -- red
    base09 = '#fab387', -- peach
    base0A = '#f9e2af', -- yellow
    base0B = '#a6e3a1', -- green
    base0C = '#94e2d5', -- teal
    base0D = '#89b4fa', -- blue
    base0E = '#cba6f7', -- mauve
    base0F = '#f2cdcd', -- flamingo
  },
  use_cterm = nil,
  plugins = { default = true },
})

-- 2. [ ICONS (mini.icons) ]
-- Enable the icon provider and mock 'nvim-web-devicons' for compatibility with other plugins.
require('mini.icons').setup()
require('mini.icons').mock_nvim_web_devicons()

-- 3. [ UI COMPONENTS ]
-- Set up the tabline (list of buffers at the top).
require('mini.tabline').setup()

-- Set up the statusline (information bar at the bottom).
require('mini.statusline').setup()

-- 4. [ NAVIGATION & EDITING ]
-- 'mini.files' provides a powerful, buffer-like file explorer.
require('mini.files').setup()

-- 'mini.jump2d' allows for fast, multi-line movement using character jumping.
require('mini.jump2d').setup()

-- 'mini.jump' extends f/F/t/T movements to work across multiple lines.
require('mini.jump').setup()

-- 'mini.splitjoin' provides mappings to split and join arguments/lists.
require('mini.splitjoin').setup()

-- 'mini.ai' provides enhanced text objects (e.g. 'a' for argument, 'f' for function).
require('mini.ai').setup()

return M
