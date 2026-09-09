-- tool & path management

local M = {}

-- 1. Environment setup
local path = vim.env.PATH

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

return M
