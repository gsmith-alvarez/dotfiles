-- [[ JIT NOTETAKING ]]
-- Domain: Deferred Plugin Initialization
-- Location: lua/autocmd/jit.lua
--
-- PHILOSOPHY: Asymmetric Resource Allocation
-- Why load a 10,000-line Markdown plugin when you're editing a C++ file?
-- This module implements "Stubs" and "Proxy Autocmds" to defer plugin
-- loading until the exact moment the functionality is required. This is
-- the core of the "Phased Boot" strategy, keeping the initial startup time
-- extremely low (usually <20ms).
--
-- MAINTENANCE TIPS:
-- 1. If Obsidian keymaps aren't working, check if you're in a Markdown file
--    inside your vault (`~/Documents/Obsidian`).
-- 2. New JIT plugins should follow the "Proxy" pattern: check for loading,
--    load if needed, then execute the command.
-- 3. Use `pcall(require, ...)` to ensure a missing plugin doesn't break
--    the entire JIT engine.

local M = {}
local utils = require 'core.utils'

-- [[ INTERNAL STATE: Atomic Loading ]]
-- Why: We use a local table instead of global vim.g variables to keep the
-- global namespace clean and avoid accidental overrides.
local loaded = {
  obsidian = false,
  wrapping = false,
}

--- Atomic Loader for Wrapping.nvim
local function load_wrapping()
  if loaded.wrapping then
    return true
  end

  local ok, plugin = pcall(require, 'plugins.notetaking.wrapping')
  if ok and plugin.setup then
    pcall(plugin.setup)
    loaded.wrapping = true
    
    -- JIT Fix: Trigger wrapping immediately on the file that initiated the load
    local wrap_plugin = package.loaded['wrapping']
    if wrap_plugin and wrap_plugin.set_mode_heuristically then
      pcall(wrap_plugin.set_mode_heuristically)
    end
    
    return true
  else
    utils.soft_notify('Failed to JIT load Wrapping: ' .. (plugin or 'Unknown Error'), vim.log.levels.ERROR)
    return false
  end
end

--- Atomic Loader for Obsidian.
--- Uses pcall to ensure a missing config file doesn't crash the editor.
local function load_obsidian(args)
  if loaded.obsidian then
    return true
  end

  -- If triggered by opening a markdown file, only load if in an Obsidian vault.
  -- Why: We don't want the full Obsidian plugin features active when
  -- editing a random README.md in a git repository.
  local buf = args and args.buf or 0
  if type(args) == 'table' and args.event == 'FileType' then
    local vault_path = vim.fn.expand '~/Documents/Obsidian'
    local current_file = vim.api.nvim_buf_get_name(buf)

    if current_file ~= '' and not current_file:find(vault_path, 1, true) then
      utils.soft_notify('Not in Obsidian vault. Skipping plugin load.', vim.log.levels.DEBUG)
      return false
    end
  end

  -- Load the actual plugin configuration file.
  local ok, plugin = pcall(require, 'plugins.notetaking.obsidian')
  if ok and plugin.setup then
    -- ASYMMETRIC LEVERAGE: Only call setup once to avoid duplicate hooks.
    pcall(plugin.setup)
    loaded.obsidian = true

    -- CRITICAL FIX: The plugin registers its FileType autocmd during setup(),
    -- but if we're loading JIT (triggered BY FileType), that event already fired.
    -- We must manually re-trigger the FileType event for the current buffer
    -- to ensure obsidian's autocmds run and keymaps get registered.
    if type(args) == 'table' and args.event == 'FileType' and vim.bo[buf].filetype == 'markdown' then
      -- Re-trigger FileType to let obsidian's autocmds register their BufEnter hooks
      vim.api.nvim_exec_autocmds('FileType', {
        buffer = buf,
        group = 'obsidian_setup',
        modeline = false,
      })
      -- Then trigger BufEnter to actually set up the buffer
      vim.api.nvim_exec_autocmds('BufEnter', {
        buffer = buf,
        group = 'obsidian_setup',
        modeline = false,
      })
    end

    return true
  else
    utils.soft_notify('Failed to JIT load Obsidian: ' .. (plugin or 'Unknown Error'), vim.log.levels.ERROR)
    return false
  end
end

-- ARCHITECTURE SHIFT: We receive the Master Switch from the loader (init.lua)
M.setup = function(injected_group)
  -- ========================================================================
  -- OBSIDIAN BUFFER-LOCAL KEYMAPS
  -- ========================================================================
  -- Register this BEFORE the FileType autocmd so it's ready when ObsidianNoteEnter fires.
  vim.api.nvim_create_autocmd('User', {
    desc = 'Setup Obsidian buffer-local keymaps',
    pattern = 'ObsidianNoteEnter',
    -- Note: We intentionally use the injected_group here instead of creating a new one
    -- to ensure hot-reloading works perfectly.
    group = injected_group,
    callback = function(ev)
      -- Ensure obsidian is loaded before requiring actions
      if not loaded.obsidian then
        return
      end

      local ok, actions = pcall(require, 'obsidian.actions')
      if not ok then
        return
      end

      -- Smart action (follow link, tag picker, toggle checkbox, fold cycle)
      -- Provide standard behavior without relying on internal `actions` object
      vim.keymap.set('n', '<leader>na', function()
        if require('obsidian.api').cursor_link() then
          return '<cmd>Obsidian follow_link<CR>'
        else
          return '<cmd>Obsidian toggle_checkbox<CR>'
        end
      end, { buffer = 0, expr = true, desc = 'Obsidian: Smart Action' })

      -- Follow link variants
      vim.keymap.set('n', '<leader>nf', '<cmd>Obsidian follow_link tab<CR>', { buffer = 0, desc = 'Obsidian: Follow Link (New Tab)' })
      vim.keymap.set('n', '<leader>nv', '<cmd>Obsidian follow_link vsplit<CR>', { buffer = 0, desc = 'Obsidian: Follow Link (V-Split)' })
      vim.keymap.set('n', '<leader>nh', '<cmd>Obsidian follow_link hsplit<CR>', { buffer = 0, desc = 'Obsidian: Follow Link (H-Split)' })

      -- Remove obsidian's default <CR> (smart_action) and give it to mini.jump2d
      pcall(vim.keymap.del, 'n', '<CR>', { buffer = 0 })
      vim.keymap.set('n', '<CR>', function()
        require('mini.jump2d').start(require('mini.jump2d').builtin_opts.word_start)
      end, { buffer = 0, desc = 'Jump2d: jump to word' })

      vim.keymap.set('n', '<leader>nT', '<cmd>Obsidian tags<CR>', { buffer = 0, desc = 'Obsidian: Search [T]ags' })
      vim.keymap.set('n', '<leader>no', '<cmd>Obsidian open<CR>', { buffer = 0, desc = 'Obsidian: [O]pen in GUI' })
      vim.keymap.set('n', '<leader>nc', '<cmd>Obsidian toc<CR>', { buffer = 0, desc = 'Obsidian: [C]ontents (TOC)' })

      -- Note Creation & Templates
      vim.keymap.set('n', '<leader>nt', '<cmd>Obsidian template<CR>', { buffer = 0, desc = 'Obsidian: Insert [T]emplate' })

      -- Visual mode commands - these only work in visual mode
      vim.keymap.set('v', '<leader>ne', '<cmd>Obsidian extract_note<CR>', { buffer = 0, desc = 'Obsidian: Extract Selection to New Note' })
      vim.keymap.set('v', '<leader>nl', '<cmd>Obsidian link<CR>', { buffer = 0, desc = 'Obsidian: Link Selection to Existing Note' })
      vim.keymap.set('v', '<leader>nN', '<cmd>Obsidian link_new<CR>', { buffer = 0, desc = 'Obsidian: Link Selection to New Note' })

      -- Media & Attachments
      vim.keymap.set('n', '<leader>np', '<cmd>Obsidian paste_img<CR>', { buffer = 0, desc = 'Obsidian: [P]aste Image' })
    end,
  })

  -- [[ 1. AUTO-TRIGGER: FileType Interceptors ]]
  -- These autocmds detect when you enter a specific domain (like Markdown)
  -- and transparently initialize the required plugin in the background.

  vim.api.nvim_create_autocmd('FileType', {
    desc = 'JIT Load Obsidian on Markdown entry',
    group = injected_group, -- <-- Bound to the Master Switch
    pattern = 'markdown',
    callback = load_obsidian,
  })

  vim.api.nvim_create_autocmd('FileType', {
    desc = 'JIT Load Wrapping.nvim for Prose',
    group = injected_group,
    pattern = { 'asciidoc', 'gitcommit', 'latex', 'mail', 'markdown', 'norg', 'rst', 'tex', 'text', 'typst' },
    callback = load_wrapping,
  })

  -- [[ 2. PROXY COMMANDS: Global Stub Entry Points ]]
  -- Why: These keymaps act as "Proxies." When pressed, they first verify
  -- the plugin is loaded, and then pass the intended command through to
  -- the newly initialized plugin. This allows you to have a global
  -- "Search Notes" keymap that works even if the plugin hasn't loaded yet.

  --- Higher-order function to create Obsidian command stubs.
  --- @param cmd string The Obsidian command to run after loading.
  local function obsidian_stub(cmd)
    return function()
      if load_obsidian() then
        vim.cmd(cmd)
      end
    end
  end

  local map = vim.keymap.set
  map('n', '<leader>nq', obsidian_stub 'Obsidian quick_switch', { desc = 'Notes: Quick Switch' })
  map('n', '<leader>ns', obsidian_stub 'Obsidian search', { desc = 'Notes: Search' })
  map('n', '<leader>nn', obsidian_stub 'Obsidian new', { desc = 'Notes: New Note' })
end

return M
