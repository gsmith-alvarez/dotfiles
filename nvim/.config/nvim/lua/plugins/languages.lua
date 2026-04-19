-- =============================================================================
-- Comprehensive configuration for Language Servers and Treesitter.
-- This file acts as the source of truth for language-specific intelligence.
-- =============================================================================

local M = {}

local mini = require('plugins.mini')

-- 1. [ TREESITTER: SYNTAX & PARSING ]
-- Manage Treesitter parsers and enable automatic installation for core languages.
mini.later(function()
  require('tree-sitter-manager').setup({
    ensure_installed = { 'python', 'cpp', 'bash', 'fish', 'lua', 'markdown', 'markdown_inline' },
    auto_install = true,
  })
end)

-- 2. [ LSP: LANGUAGE SERVER OVERRIDES ]
-- Use vim.lsp.config() to merge project-specific overrides with the
-- default configurations provided by nvim-lspconfig. This avoids
-- redefining entire server setups and ensures we only track our changes.

-- [ LUA (lua_ls) ]
vim.lsp.config('lua_ls', {
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if
          path ~= vim.fn.stdpath('config')
          and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
      then
        return
      end
    end

    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
      runtime = {
        -- Tell the language server which version of Lua you're using (most
        -- likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
        -- Tell the language server how to find Lua modules same way as Neovim
        -- (see `:h lua-module-load`)
        path = {
          'lua/?.lua',
          'lua/?/init.lua',
        },
      },
      -- Make the server aware of Neovim runtime files
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
        },
      },
      -- Enable inlay hints
      hint = {
        enable = true,
        setType = true,
      },
    })
  end,
  settings = {
    Lua = {},
  },
})

-- [ C/C++ (clangd) ]
vim.lsp.config('clangd', {
  filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'h', 'hpp' },
  settings = {
    clangd = {
      InlayHints = {
        Designators = true,
        Enabled = true,
        ParameterNames = true,
        DeducedTypes = true,
      },
    },
  },
})

-- [ JSON (jsonls) ]
-- Enable snippet support for jsonls (often required for schema completions)
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
vim.lsp.config('jsonls', {
  capabilities = capabilities,
})

-- 3. [ ACTIVATION ]
-- Enable the configured servers for the current session.
vim.lsp.enable({
  'ty',         -- Python (Astral)
  'ruff',       -- Python (Formatting/Linting)
  'lua_ls',     -- Lua
  'bashls',     -- Bash
  'clangd',     -- C/C++
  'jsonls',     -- JSON
  'yamlls',     -- YAML
  'dockerls',   -- Docker
  'taplo',      -- TOML
})

return M
