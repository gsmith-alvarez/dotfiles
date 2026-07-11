-- =============================================================================
-- [ TOOL & PATH MANAGEMENT ]
-- Centralized configuration for external binaries, versioning, and environment.
-- This module ensures Neovim can locate compilers, debuggers, and language servers.
-- =============================================================================

local M = {}

-- 1. [ ENVIRONMENT SETUP ]
-- Prioritize virtual environment if active, followed by 'mise' shims, and finally
-- the rest of the system PATH. This ensures that when Neovim calls an external
-- command (like 'python' or 'clangd'), it resolves tool versions correctly.
local path = vim.env.PATH

-- Prepend mise shims to prioritize mise-managed global/project tools
local mise_shim = vim.fn.expand("~/.local/share/mise/shims")
path = mise_shim .. ":" .. path

-- 2. [ VIRTUAL ENV DETECTION & SOURCING ]
-- If a virtual environment is active in the parent shell or exists in the
-- current working directory, prioritize its binaries over global/mise tools.
local venv = vim.env.VIRTUAL_ENV
if not venv then
	local cwd = vim.fn.getcwd()
	if vim.fn.isdirectory(cwd .. "/.venv") == 1 then
		venv = cwd .. "/.venv"
	elseif vim.fn.isdirectory(cwd .. "/venv") == 1 then
		venv = cwd .. "/venv"
	end
end

if venv then
	vim.env.VIRTUAL_ENV = venv
	path = venv .. "/bin:" .. path
end

vim.env.PATH = path

-- 3. [ MISE INTEGRATION ]
-- Initialize mise to manage project-specific tool versions.
-- RATIONALE: Using mise provides a reproducible environment for LSPs,
-- formatters, and future debugger (DAP) configurations without relying on Mason.
local ok, mise = pcall(require, "mise")
if ok then
	mise.setup({})
end

return M
