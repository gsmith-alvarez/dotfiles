--- [[ CORE UTILITY FUNCTIONS ]]
--- Purpose: Shared Config Foundation & Auditing
--- Domain: Core Infrastructure / Helper Library
--- Architecture: Stateless / Performance-Optimized
--- Location: lua/core/utils.lua
---
--- PHILOSOPHY: The Anti-Fragile Foundation
--- This module provides the bedrock for reliable tool discovery. By caching
--- paths and prioritizing mise shims, we ensure that formatters, linters, 
--- and LSP servers are discovered with zero overhead and near-zero failure 
--- rates. This is the cornerstone of the configuration's stability.
---
--- MAINTENANCE TIPS:
--- 1. If tools are not being found, check `mise_shim_dir` below.
--- 2. Use `soft_notify` instead of `vim.notify` to ensure messages are 
---    logged to the persistent audit trail.

local M = {}

-- [[ 1. THE AUDIT TRAIL ]]
-- We use Neovim's 'state' directory (~/.local/state/nvim/ on Unix).
-- This complies with the XDG Base Directory specification.
-- Why: This log survives across Neovim sessions, making it invaluable 
-- for debugging intermittent boot or plugin issues.
local log_path = vim.fn.stdpath('state') .. '/config_diagnostics.log'

-- [[ THE AUDIT TRAIL ]]

--- Resolves Neovim log levels to human-readable strings for the log file.
local log_level_to_string = {
  [vim.log.levels.TRACE] = "TRACE",
  [vim.log.levels.DEBUG] = "DEBUG",
  [vim.log.levels.INFO]  = "INFO",
  [vim.log.levels.WARN]  = "WARN",
  [vim.log.levels.ERROR] = "ERROR",
  [vim.log.levels.OFF]   = "OFF",
}

--- Appends a message to the dedicated configuration log file.
--- @param msg string The message to log.
--- @param level integer The log level.
local function log_to_file(msg, level)
  -- Open the file in "a" (append) mode.
  local file = io.open(log_path, "a")
  if file then
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local level_str = log_level_to_string[level] or "UNKNOWN"

    -- Format: [2026-02-28 03:27:53] [WARN] LSP missing: clangd
    file:write(string.format("[%s] [%s] %s\n", timestamp, level_str, msg))
    file:close()
  end
end



local tsdk_cache = nil

--- Retrieves the TSDK (TypeScript SDK) path from mise.
--- Why: typescript-language-server (ts_ls) requires a valid 'typescript' 
--- installation to function. This allows us to find it dynamically.
--- @return string|nil path The absolute path to the typescript/lib directory.
M.get_tsdk_path = function()
  if tsdk_cache then return tsdk_cache end

  -- Use mise to find the installation root for npm:typescript
  local handle = io.popen("mise where npm:typescript 2>/dev/null")
  if not handle then return nil end

  local result = handle:read("*a")
  handle:close()

  if result and result ~= "" then
    -- Clean any whitespace/newlines and append the standard TSDK path
    tsdk_cache = result:gsub("%s+", "") .. "/lib/node_modules/typescript/lib"
    return tsdk_cache
  end

  return nil
end

--- A wrapper for vim.notify that defaults to DEBUG level if not specified.
--- It immediately routes the message to both the UI and the persistent log file.
--- @param msg string The message to display.
--- @param level integer|nil The log level (e.g., vim.log.levels.WARN).
M.soft_notify = function(msg, level)
  local safe_level = level or vim.log.levels.DEBUG

  -- Route to the persistent audit trail.
  log_to_file(msg, safe_level)

  -- Route to the UI (intercepted by snacks.notifier).
  vim.notify(msg, safe_level)
end

return M
