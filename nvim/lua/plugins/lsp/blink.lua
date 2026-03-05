-- [[ BLINK.CMP: High-Performance Autocompletion ]]
-- Domain: LSP & Intelligence
--
-- PHILOSOPHY: Pre-Emptive Capability Injection
-- Autocompletion is not a standalone UI; it is an integrated client of the LSP.
-- It must load exactly when a file is read so its capabilities can be broadcast
-- to the Language Servers the millisecond they attach.

local M = {}
local utils = require 'core.utils'

M.setup = function()
  -- [[ DEFERRED BOOTSTRAPPER ]]
  local ok, err = pcall(function()
    local MiniDeps = require 'mini.deps'

    -- 1. Snippets & Neovim API intelligence
    MiniDeps.add 'rafamadriz/friendly-snippets'
    MiniDeps.add 'folke/lazydev.nvim'

    -- Configure LazyDev immediately so it is ready for Blink's source list
    require('lazydev').setup {
      library = { { path = '${3rd}/luv/library', words = { 'vim%.uv' } } },
    }

    -- 2. Add and Compile Blink
    -- Pinned to a tag so prebuilt binaries always match the exact version.
    -- On machines without cargo, blink downloads the prebuilt automatically.
    MiniDeps.add {
      source = 'saghen/blink.cmp',
      checkout = 'v1.9.1',
      hooks = {
        post_install = function(args)
          if utils.mise_shim('cargo') then
            vim.system({ 'cargo', 'build', '--release' }, { cwd = args.path }):wait()
          end
        end,
        post_checkout = function(args)
          if utils.mise_shim('cargo') then
            vim.system({ 'cargo', 'build', '--release' }, { cwd = args.path }):wait()
          end
        end,
      },
    }

    -- 3. Configure the Engine
    require('blink.cmp').setup {
      fuzzy = {
        -- Download a prebuilt binary if the native build is missing (new machine safety net)
        prebuilt_binaries = { download = true },
      },
      keymap = {
        -- Zero interference with native Neovim keys
        preset = 'none',

        ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-e>'] = { 'hide' },

        -- The Home-Row Navigation Protocol
        ['<C-j>'] = { 'select_next', 'fallback' },
        ['<C-k>'] = { 'select_prev', 'fallback' },
        ['<C-l>'] = { 'accept', 'fallback' },
        ['<C-h>'] = { 'hide', 'fallback' },

        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
      },
      appearance = {
        nerd_font_variant = 'mono',
        kind_icons = require('core.icons').kinds,
      },
      completion = {
        trigger = {
          -- Show completions immediately after typing a trigger character
          show_on_trigger_character = true,
          show_on_insert_on_trigger_character = true,
        },
        list = {
          selection = {
            preselect = true,    -- Auto-targets the first item for instant <C-l> acceptance
            auto_insert = false, -- Prevents ghost text from mutating your buffer while scrolling
          },
        },
        documentation = {
          auto_show = true,         -- Show docs panel automatically when navigating items
          auto_show_delay_ms = 200, -- Snappy feel — matches VS Code behaviour
          window = { border = 'rounded' },
        },
        ghost_text = {
          enabled = true, -- Inline suggestion à la VS Code / Copilot
        },
        menu = {
          border = 'rounded',
          draw = {
            treesitter = { 'lsp' }, -- Syntax-highlight the label inside the menu
            columns = { { 'label', 'label_description', gap = 1 }, { 'kind_icon', 'kind' } },
          },
        },
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'lazydev' },
        providers = {
          lazydev = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            score_offset = 100,
          },
        },
      },
      signature = {
        enabled = true,
        window = { border = 'rounded' },
      },
    }
  end)

  if not ok then
    utils.soft_notify('Blink.cmp failed to initialize: ' .. err, vim.log.levels.ERROR)
  end
end

-- THE CONTRACT: Return the module to satisfy the LSP Orchestrator
return M
