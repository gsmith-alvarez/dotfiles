-- [[ TREESITTER: Advanced Syntax Parsing ]]
-- Domain: UI & Core Mechanics
--
-- PHILOSOPHY: Self-Healing Background Boot
-- We use 'later' to defer loading. Crucially, we account for the
-- async nature of package managers: if the plugin is currently
-- downloading on a fresh install, we fail gracefully and silently
-- rather than throwing a red stack trace.

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
          'c', 'cpp', 'go', 'lua', 'python', 'rust', 'zig',
          'html', 'javascript', 'typescript', 'markdown', 'markdown_inline',
          'query', 'regex', 'vim', 'vimdoc', 'typst',
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
