-- tool & path management

local M = {}

-- 1. Environment setup
local path = vim.env.PATH

local mise_shim = vim.fn.expand("~/.local/share/mise/shims")
path = mise_shim .. ":" .. path

-- 2. Virtual env detection & sourcing
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

-- 3. Mise integration
local ok, mise = pcall(require, "mise")
if ok then
	mise.setup({})
end

return M
