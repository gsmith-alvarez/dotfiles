-- =============================================================================
-- [ PLUGIN MANAGEMENT ]
-- Uses Neovim's native 'vim.pack' system to manage and download plugins.
-- =============================================================================

local M = {}

-- 1. [ HELPER FUNCTIONS ]
-- Generates a full GitHub URL for a given repository.
local function host(domain)
    return function(repo)
        return 'https://' .. domain .. '/' .. repo
    end
end

local gh = host 'github.com'

-- 2. [ PLUGIN SPECIFICATIONS ]
-- Register plugins with the native package manager.
vim.pack.add({
  -- CORE UTILITIES
  gh 'echasnovski/mini.nvim',        -- Collection of modular Lua plugins
  gh 'echasnovski/mini.icons',       -- Icon provider
  gh 'folke/snacks.nvim',            -- Collection of small, high-quality plugins
  gh 'folke/which-key.nvim',         -- Keybinding popup and discovery
  gh 'saghen/blink.cmp',             -- High-performance completion engine
  gh 'romus204/tree-sitter-manager.nvim', -- Manager for Treesitter parsers
  'https://plugins.ejri.dev/mise.nvim',   -- mise (tool manager) integration

  -- SNIPPETS
  gh 'L3MON4D3/LuaSnip',             -- Snippet engine
  gh 'rafamadriz/friendly-snippets', -- Predefined snippet collection
})

-- 3. [ AUTOMATIC POST-INSTALL/UPDATE HOOKS ]
-- Create an autocommand to handle building plugins after they are installed or updated.
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local spec = ev.data.spec
    local kind = ev.data.kind
    local path = ev.data.path

    -- Robust name resolution from various specification formats.
    local name = spec.name
      or (spec.src and vim.fn.fnamemodify(spec.src, ':t'))
      or (type(spec[1]) == 'string' and vim.fn.fnamemodify(spec[1], ':t'))
      or 'unknown'
    name = name:gsub('%.nvim$', '')

    -- Only proceed for installations or updates.
    if kind ~= 'install' and kind ~= 'update' then
      return
    end

    -- [ BLINK.CMP BUILD HOOK ]
    -- Compile the Rust backend for blink.cmp.
    if name == 'blink.cmp' then
      if vim.fn.executable 'cargo' == 1 then
        vim.notify('Building blink.cmp in the background...', vim.log.levels.INFO)
        vim.system({ 'cargo', '+nightly', 'build', '--release' }, { cwd = path }, function(obj)
          if obj.code == 0 then
            vim.schedule(function()
              vim.notify('blink.cmp build complete.', vim.log.levels.INFO)
            end)
          end
        end)
      end

    -- [ LUASNIP BUILD HOOK ]
    -- Compile jsregexp for LuaSnip to support advanced snippet transformations.
    elseif name == 'LuaSnip' then
      if vim.fn.executable 'make' == 1 then
        vim.notify('Building LuaSnip (jsregexp) in the background...', vim.log.levels.INFO)
        vim.system({ 'make', 'install_jsregexp' }, { cwd = path }, function(obj)
          -- Robustness fallback: ensure the compiled library is correctly placed
          -- if the Makefile didn't handle it as expected.
          local lua_dir = path .. '/lua'
          local jsregexp_dir = lua_dir .. '/jsregexp'
          if vim.fn.isdirectory(jsregexp_dir) == 0 then
            vim.fn.mkdir(jsregexp_dir, 'p')
          end

          local lib_src = path .. '/deps/jsregexp006/jsregexp.so'
          local lib_dest = jsregexp_dir .. '/core.so'
          local lua_src = path .. '/deps/jsregexp006/jsregexp.lua'
          local lua_dest = lua_dir .. '/luasnip-jsregexp.lua'

          if vim.fn.filereadable(lib_src) == 1 then
            vim.fn.setfperm(lib_src, 'rwxr-xr-x')
            vim.fn.system { 'cp', lib_src, lib_dest }
          end
          if vim.fn.filereadable(lua_src) == 1 then
            vim.fn.system { 'cp', lua_src, lua_dest }
          end

          if obj.code == 0 or vim.fn.filereadable(lib_dest) == 1 then
            vim.schedule(function()
              vim.notify('LuaSnip build complete.', vim.log.levels.INFO)
            end)
          end
        end)
      end
    end
  end,
})

return M
