-- [[ THE ENTRY POINT: init.lua ]]
-- =============================================================================
-- Welcome to your Neovim Configuration.
--
-- If you are a newcomer to Neovim:
-- 1. This file is the "Main Menu" of your editor. It's the first thing Neovim runs.
-- 2. It follows a "Phased Boot Sequence" (0 to 2) to ensure the fastest startup.
-- 3. It uses an "Anti-Fragile" loader: if one part of your config breaks, the rest
--    of the editor will still work, and you'll see a notification with the error.
-- =============================================================================

-- [[ PHASE 0: MICROCODE & FOUNDATION ]]
-- Enables Neovim's built-in byte-code cache for faster startup.
if vim.loader then
  vim.loader.enable()
end

-- [[ PHASE 0.5: LEGACY PURGE ]]
-- Disable 1990s-era Vim plugins. We use modern, asynchronous Lua alternatives.
local disabled_built_ins = {
  'netrw',
  'netrwPlugin',
  'netrwSettings',
  'netrwFileHandlers',
  'gzip',
  'zip',
  'zipPlugin',
  'tar',
  'tarPlugin',
  'getscript',
  'getscriptPlugin',
  'vimball',
  'vimballPlugin',
  '2html_plugin',
  'logipat',
  'rrhelper',
  'spellfile_plugin',
  'matchit',
  'fzf',
}

for _, plugin in pairs(disabled_built_ins) do
  vim.g['loaded_' .. plugin] = 1
end

-- =============================================================================
-- [[ NEOVIM BOOTSTRAP OS ]]
-- Architecture: Iterative Fault-Tolerant Loader
-- =============================================================================

-- [[ THE ANTI-FRAGILE ENGINE ]]
-- This function is your safety net. If you make a mistake in a Lua file,
-- this engine catches it so Neovim doesn't crash on startup.
local function safe_require(module)
  local ok, err = pcall(require, module)
  if not ok then
    -- We schedule the notification so it appears AFTER the UI has loaded.
    vim.schedule(function()
      vim.notify(string.format('[BOOT SEQUENCE FAILURE]\nModule: %s\nError: %s', module, err), vim.log.levels.ERROR, { title = 'Init.lua Fault Tolerance' })
    end)
  end
  return ok
end

-- =============================================================================
-- PHASE 1: CORE FOUNDATION
-- =============================================================================
-- 1. Reporter: Must load first to log errors from subsequent modules.
require 'core.utils'

-- 2. Core Orchestrator: Loads deps.lua, options, and keymaps.
--    Located in: lua/core/init.lua
safe_require 'core'
vim.opt.expandtab = true --Coverting tabs to spaces
vim.opt.shiftwidth = 4 -- size of indent
vim.opt.tabstop = 4 -- Number of spaces tabs count for
vim.opt.softtabstop = 4 -- Number of spaces a tab counts for while editing

-- =============================================================================
-- PHASE 2: PLUGIN ORCHESTRATION
-- =============================================================================
-- We load this synchronously because lua/plugins/init.lua is its own
-- high-performance orchestrator that handles Scenario-based deferral.
safe_require 'plugins'

-- =============================================================================
-- [[ THE JIT ENGINE: AUTOMATION DEFERRAL ]]
-- -----------------------------------------------------------------------------
-- PHILOSOPHY: Ultimate Speed Optimization
-- We defer the heavy automation and custom commands until they are needed.
-- This keeps the "Hot Path" extremely thin (10-15ms).
-- =============================================================================

local function load_jit_automation()
  if _G.JIT_AUTOMATION_LOADED then
    return
  end
  _G.JIT_AUTOMATION_LOADED = true
  -- 3. Automation Layers: Custom user commands and autocommands
  safe_require 'autocmd'
  safe_require 'commands'
end

-- TRIGGER A: User tries to run a custom command
vim.api.nvim_create_autocmd('CmdUndefined', {
  group = vim.api.nvim_create_augroup('JIT_Automation', { clear = true }),
  callback = function()
    load_jit_automation()
    vim.api.nvim_clear_autocmds { group = 'JIT_Automation' }
  end,
})

-- TRIGGER B: After UI is interactive (deferred to idle loop)
vim.api.nvim_create_autocmd('VimEnter', {
  group = 'JIT_Automation',
  callback = function()
    vim.defer_fn(load_jit_automation, 1)
  end,
})

-- Fallback for extremely fast interactions
vim.defer_fn(function()
  if vim.v.vim_did_enter == 1 then
    load_jit_automation()
  end
end, 0)

-- =============================================================================
-- MAINTENANCE CHEATSHEET FOR NEWBIES:
-- -----------------------------------------------------------------------------
-- 1. "I want to change a setting (like line numbers)": Edit lua/core/options.lua
-- 2. "I want to add a keybinding": Edit lua/core/keymaps.lua
-- 3. "I want to add a plugin": Add it to lua/plugins/init.lua (or a subfolder)
-- 4. "Something is broken": Check the logs! Run the :Logs command or check
--    ~/.local/state/nvim/config_diagnostics.log
-- =============================================================================
