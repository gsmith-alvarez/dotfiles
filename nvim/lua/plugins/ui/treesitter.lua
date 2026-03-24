-- [[ TREESITTER: Advanced Syntax Parsing ]]
-- Purpose: Provide high-fidelity syntax highlighting and structural code awareness.
-- Domain:  UI & Core Mechanics
-- Architecture: Self-Healing Background Boot (Phased Boot)
--
-- PHILOSOPHY: The Incremental Highlighter
-- We use `later` to defer Treesitter loading. This prioritizes buffer 
-- visibility over highlighting. In an "Anti-Fragile" system, we fail 
-- gracefully: if parsers are missing, we use standard regex highlighting 
-- until the background `:TSUpdate` completes.
--
-- MAINTENANCE TIPS:
-- 1. If syntax highlighting is broken, run `:TSUpdate`.
-- 2. To add a new language, append it to the `ensure_installed` table.
-- 3. Use `:EditQuery` to debug custom treesitter queries or highlights.

local M = {}
local utils = require('core.utils')

M.setup = function()
  local ok, err = pcall(function()
    local MiniDeps = require('mini.deps')

    MiniDeps.later(function()
      MiniDeps.add({
        source = 'nvim-treesitter/nvim-treesitter',
        hooks = {
          post_checkout = function()
            vim.cmd('TSUpdate')
          end,
        },
      })

      MiniDeps.add({
        source = 'nvim-treesitter/nvim-treesitter-textobjects',
        depends = { 'nvim-treesitter/nvim-treesitter' }
      })

      MiniDeps.add({
        source = 'nvim-treesitter/nvim-treesitter-context',
        depends = { 'nvim-treesitter/nvim-treesitter' }
      })

      local status_ok, ts_configs = pcall(require, 'nvim-treesitter.configs')
      if not status_ok then
        return
      end

      ts_configs.setup({
        ensure_installed = {
          'bash', 'json', 'toml', 'yaml',
          'c', 'cpp', 'go', 'lua', 'python', 'rust', 'zig', 'sql',
          'html', 'javascript', 'typescript', 'markdown', 'markdown_inline',          'query', 'regex', 'vim', 'vimdoc', 'typst',
          -- Parsers for snacks.image
          'css', 'scss', 'tsx', 'svelte', 'vue', 'norg',
        },

        auto_install = true,

        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },

        indent = { enable = true },

        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ['aa'] = '@parameter.outer',
              ['ia'] = '@parameter.inner',
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
            },
          },
        },
      })

      -- [[ TREESITTER CONTEXT: Scope Pinning ]]
      -- Pins the current function/class/block header at the top of the viewport
      -- when you scroll past it. Essential for navigating long files.
      local ctx_ok, context = pcall(require, 'treesitter-context')
      if ctx_ok then
        context.setup {
          max_lines = 3,          -- Cap at 3 lines to avoid eating too much screen space
          min_window_height = 20, -- Don't activate in tiny splits
          trim_scope = 'outer',   -- When context is multi-line, trim outermost scope first
        }
      end
    end)
  end)

  if not ok then
    utils.soft_notify('Treesitter critical failure: ' .. err, vim.log.levels.ERROR)
  end
end

return M
