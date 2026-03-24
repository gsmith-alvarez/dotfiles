-- [[ SHARED CORE LIBRARIES ]]
-- Purpose: Global Dependency Injection
-- Domain: Core Infrastructure
-- Architecture: Pre-emptive Injection (Phased Boot)
-- Location: lua/core/libs.lua
--
-- PHILOSOPHY: Stability Through Pre-emption
-- To prevent "Module not found" errors during the phased boot process, 
-- we inject critical libraries (like Plenary) early. This ensures that 
-- regardless of plugin load order, the foundational APIs are always 
-- available when needed, preventing race conditions.
--
-- MAINTENANCE TIPS:
-- 1. If a plugin complains about missing `plenary`, verify it is listed here.
-- 2. This file is loaded early in `core/init.lua`. Do not add heavy logic here.

local M = {}
local utils = require('core.utils')

-- We use a protected block to ensure a git failure doesn't halt the boot.
-- Why: If GitHub is down, we want Neovim to still open, even if plugins fail.
local ok, err = pcall(function()
  -- 1. nvim-lua/plenary.nvim: The Neovim Standard Library
  -- MiniDeps.add handles the runtimepath injection automatically.
  MiniDeps.add('nvim-lua/plenary.nvim')

  -- 2. mini.icons (Optional Library)
  -- If you eventually need global devicons, inject echasnovski/mini.icons here.
end)

if not ok then
  utils.soft_notify("CORE LIB FAILURE: Plenary failed to inject.\n" .. err, vim.log.levels.ERROR)
end

return M
