-- =============================================================================
-- [ TOOL & PATH MANAGEMENT ]
-- Centralized configuration for external binaries, versioning, and environment.
-- This module ensures Neovim can locate compilers, debuggers, and language servers.
-- =============================================================================

local M = {}

-- 1. [ ENVIRONMENT SETUP ]
-- Prioritize 'mise' shims in the system PATH. This ensures that when Neovim
-- calls an external command (like 'python' or 'clangd'), it uses the version
-- managed by mise rather than a system-wide default.
vim.env.PATH = vim.fn.expand "~/.local/share/mise/shims" .. ":" .. vim.env.PATH

-- 2. [ MISE INTEGRATION ]
-- Initialize mise to manage project-specific tool versions.
-- RATIONALE: Using mise provides a reproducible environment for LSPs,
-- formatters, and future debugger (DAP) configurations without relying on Mason.
local ok, mise = pcall(require, "mise")
if ok then
	mise.setup {}
end

return M
