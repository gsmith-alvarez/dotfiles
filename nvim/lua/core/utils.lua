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

-- [[ CACHED PATHS ]]
-- PERFORMANCE: We cache the absolute path to the mise shims once at startup.
-- Why: This prevents the need to call vim.fn.expand() (which crosses the 
-- slow Vimscript bridge) every time a formatter, linter, or LSP 
-- asks for a binary.
local mise_shim_dir = vim.env.HOME .. '/.local/share/mise/shims/'

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

--- Checks if a binary is executable, prioritizing mise shims.
--- This is the core of our "Anti-Fragility" pillar.
--- @param binary string The name of the binary to find (e.g., 'rg', 'stylua').
--- @return string|nil path The absolute path to the binary if found, or nil if missing.
M.mise_shim = function(binary)
  -- 1. Direct string concatenation (Zero Vimscript overhead)
  local path = mise_shim_dir .. binary
  if vim.fn.executable(path) == 1 then
    return path
  end

  -- 2. Fall back to the standard system PATH.
  -- Why: If the user hasn't installed the tool via mise, we still want to 
  -- find it if it's available globally on the system.
  if vim.fn.executable(binary) == 1 then
    return binary
  end

  -- 3. If neither exist, return nil.
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
