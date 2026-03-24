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

local utils = require('core.utils')
local jit_group = vim.api.nvim_create_augroup("JIT_Notetaking", { clear = true })

-- [[ INTERNAL STATE: Atomic Loading ]]
-- Why: We use a local table instead of global vim.g variables to keep the 
-- global namespace clean and avoid accidental overrides.
local loaded = {
  obsidian = false,
}

--- Atomic Loader for Obsidian.
--- Uses pcall to ensure a missing config file doesn't crash the editor.
local function load_obsidian(args)
  if loaded.obsidian then return true end

  -- If triggered by opening a markdown file, only load if in an Obsidian vault.
  -- Why: We don't want the full Obsidian plugin features active when 
  -- editing a random README.md in a git repository.
  if type(args) == "table" and args.event == "FileType" then
    local vault_path = vim.fn.expand("~/Documents/Obsidian")
    local current_file = vim.api.nvim_buf_get_name(args.buf or 0)

    if current_file ~= "" and not current_file:find(vault_path, 1, true) then
      utils.soft_notify("Not in Obsidian vault. Skipping plugin load.", vim.log.levels.DEBUG)
      return false
    end
  end

  -- Load the actual plugin configuration file.
  local ok, plugin = pcall(require, "plugins.notetaking.obsidian")
  if ok and plugin.setup then
    -- ASYMMETRIC LEVERAGE: Only call setup once to avoid duplicate hooks.
    pcall(plugin.setup)
    loaded.obsidian = true
    return true
  else
    utils.soft_notify("Failed to JIT load Obsidian: " .. (plugin or "Unknown Error"), vim.log.levels.ERROR)
    return false
  end
end

-- [[ 1. AUTO-TRIGGER: FileType Interceptors ]]
-- These autocmds detect when you enter a specific domain (like Markdown) 
-- and transparently initialize the required plugin in the background.

vim.api.nvim_create_autocmd("FileType", {
  desc = "JIT Load Obsidian on Markdown entry",
  group = jit_group,
  pattern = "markdown",
  callback = load_obsidian,
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
map("n", "<leader>nq", obsidian_stub("Obsidian quick_switch"), { desc = "Notes: Quick Switch" })
map("n", "<leader>ns", obsidian_stub("Obsidian search"), { desc = "Notes: Search" })
map("n", "<leader>nn", obsidian_stub("Obsidian new"), { desc = "Notes: New Note" })

return M
