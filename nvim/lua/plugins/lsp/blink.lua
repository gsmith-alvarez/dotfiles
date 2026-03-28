-- [[ BLINK.CMP: High-Performance Autocompletion ]]
-- Purpose: Provide a lightning-fast, fuzzy completion engine written in Rust.
-- Domain:  LSP & Intelligence
-- Architecture: Pre-emptive Capability Injection (Phased Boot)
--
-- PHILOSOPHY: The Pre-Emptive Strike
-- Autocompletion is not a standalone UI; it is an integrated client of the LSP.
-- In our "Phased Boot" strategy, Blink must load exactly when a file is read
-- so its capabilities can be broadcast to the Language Servers the millisecond
-- they attach. This prevents the "no completions on first attach" bug.
--
-- MAINTENANCE TIPS:
-- 1. If the completion menu is slow or broken, check if a new version requires
--    a `cargo build` (handled automatically by MiniDeps hooks).
-- 2. Keybinds for completion are isolated here to avoid global conflicts.
-- 3. Symbols/Icons are pulled from `lua/core/icons.lua`.
-- 4. If the binary is missing on a new machine, `prebuilt_binaries.download = true`
--    acts as an Anti-Fragile safety net.

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
          if vim.fn.executable 'cargo' == 1 then
            vim.system({ 'cargo', '+nightly', 'build', '--release' }, { cwd = args.path }):wait()
          end
        end,
        post_checkout = function(args)
          if vim.fn.executable 'cargo' == 1 then
            vim.system({ 'cargo', '+nightly', 'build', '--release' }, { cwd = args.path }):wait()
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
      -- Use LuaSnip as the snippet engine.
      -- preset='luasnip' makes blink query LuaSnip's registry for completions
      -- (so custom Lua snippets appear in the menu) AND routes expansion through
      -- LuaSnip (full node-jumping support). Official blink.cmp integration.
      snippets = { preset = 'luasnip' },
      keymap = {
        -- Zero interference with native Neovim keys
        preset = 'none',

        ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-e>'] = { 'hide', 'fallback' },

        -- The Home-Row Navigation Protocol
        ['<C-j>'] = { 'select_next', 'fallback' },
        ['<C-k>'] = { 'select_prev', 'fallback' },
        -- C-l/C-h: accept/hide from menu, then fallback to luasnip.lua's locally_jumpable keymaps
        ['<C-l>'] = { 'accept', 'fallback' },
        ['<C-h>'] = { 'hide', 'fallback' },

        -- Tab: accept selected item, fallback to luasnip node jump or TabOut
        ['<Tab>'] = { 'accept', 'fallback' },

        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },

        -- Custom split view for documentation
        ['<C-w>d'] = {
          function(cmp)
            local item = cmp.get_selected_item()
            if not item then
              return false
            end

            -- Close menu and open in split
            cmp.hide()
            vim.schedule(function()
              vim.cmd 'vsplit'
              vim.lsp.buf.hover()
            end)

            return true
          end,
          'fallback',
        },
      },
      appearance = {
        nerd_font_variant = 'mono',
        kind_icons = require('core.icons').kinds,
      },
      completion = {
        trigger = {
          -- Completely disable automatic menu popping
          show_on_keyword = false,
          show_on_trigger_character = false,
          show_on_insert_on_trigger_character = false,
        },
        list = {
          selection = {
            preselect = true, -- Auto-targets the first item for instant <C-l> acceptance
            auto_insert = false, -- Prevents ghost text from mutating your buffer while scrolling
          },
        },
        documentation = {
          auto_show = true, -- Show docs panel automatically when navigating items
          auto_show_delay_ms = 200, -- Snappy feel — matches VS Code behaviour
          window = { border = 'rounded' },
        },
        ghost_text = {
          enabled = true, -- Inline suggestion à la VS Code
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
