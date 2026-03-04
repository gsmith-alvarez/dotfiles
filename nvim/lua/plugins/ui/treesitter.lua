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
      -- tree-sitter build uses CC from the environment. The global mise config
      -- sets CC="zig cc" for Rust/C/Zig projects, but tree-sitter needs a
      -- plain C compiler. Override for this process only.
      vim.env.CC = "gcc"

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
    end)
  end)

  if not ok then
    utils.soft_notify('Treesitter critical failure: ' .. err, vim.log.levels.ERROR)
  end
end

return M

