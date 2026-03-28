-- [[ CORE SYSTEM ORCHESTRATOR ]]
-- =============================================================================
-- This file acts as the "Traffic Controller" for the core of your editor.
--
-- Architecture: "Vital Organs" loading.
-- The core of your Neovim config is split into domain-specific files
-- (options, keymaps, etc.). This orchestrator loads them one by one.
-- =============================================================================

local M = {}
local utils = require 'core.utils'

-- [[ THE SYNC BLOCK: Critical Vital Organs ]]
-- These MUST load immediately for leader keys and options to work.
local sync_modules = {
  -- 1. Infrastructure: Must load first to manage all external plugins.
  'core.deps',

  -- 2. Standard Editor Behavior: Global Neovim settings (no plugins).
  'core.options',

  -- 3. Interaction Layer: Base keybindings (no plugins).
  'core.keymaps',

  -- 4. Plugin Keymaps: The "Control Room" for all your plugin-related bindings.
  'core.plugin-keymaps',
}

for _, module in ipairs(sync_modules) do
  local ok, err = pcall(require, module)
  if not ok then
    -- Logs failure to your persistent log (~/.local/state/nvim/config_diagnostics.log)
    utils.soft_notify(string.format('CORE SYNC FAILURE: Failed to load %s\nError: %s', module, err), vim.log.levels.ERROR)
  end
end

-- [[ THE JIT BLOCK: Deferrable Foundation ]]
-- These load after the UI is ready to save precious milliseconds.
local function load_jit_core()
  local jit_modules = {
    -- 5. Shared Libraries: Injects Plenary.nvim (async/path helper).
    'core.libs',

    -- 6. Formatting & Linting logic.
    'core.format',
    'core.lint',
  }
  for _, module in ipairs(jit_modules) do
    local ok, err = pcall(require, module)
    if not ok then
      utils.soft_notify(string.format('CORE JIT FAILURE: Failed to load %s\nError: %s', module, err), vim.log.levels.ERROR)
    end
  end
end

-- Defer loading non-critical core logic to the first available idle cycle.
vim.defer_fn(load_jit_core, 0)

-- =============================================================================
-- [[ SELF-CORRECTING HOT RELOAD ]]
-- -----------------------------------------------------------------------------
-- This is a superpower for developers.
-- When you save any file in lua/core/ (like keymaps.lua), this configuration
-- automatically re-loads it. No need to restart Neovim!
-- =============================================================================
vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = '*/lua/core/*.lua',
  desc = 'Auto-reload core system modules on save',
  callback = function(event)
    -- Skip init.lua to avoid loops
    if event.file:match 'init%.lua$' then
      return
    end

    local target_path = event.file or event.match
    local match = target_path:match 'lua/(core/.*)%.lua$'
    if not match then
      return
    end

    local module_name = match:gsub('/', '.')

    -- Purge Lua's internal cache and re-run the file.
    package.loaded[module_name] = nil
    local ok, err = pcall(require, module_name)
    if ok then
      vim.notify('⚙️ Core Reloaded: ' .. module_name, vim.log.levels.DEBUG)
    else
      local utils = require 'core.utils'
      utils.soft_notify('Core Reload Failed: ' .. err, vim.log.levels.ERROR)
    end
  end,
})

return M
