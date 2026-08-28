-- init.lua

_G.Config = {}

if vim.env.PROF then
	local snacks_path = vim.fn.stdpath("data") .. "/site/pack/core/opt/snacks.nvim"
	if vim.fn.isdirectory(snacks_path) == 1 then
		vim.opt.rtp:append(snacks_path)
		local ok_profiler, profiler = pcall(require, "snacks.profiler")
		if ok_profiler then
			profiler.startup({
				startup = {
					event = "VimEnter",
				},
			})
		end
	end
end

Config.safe_require = function(module_or_list, desc)
	desc = desc or (debug.getinfo(2, "S") and debug.getinfo(2, "S").source:match("@?(.*/)") or "SYSTEM")

	if type(module_or_list) == "table" then
		local loaded_modules = {}
		for _, m in ipairs(module_or_list) do
			loaded_modules[m] = Config.safe_require(m, desc)
		end
		return loaded_modules
	end

	local ok, result = pcall(require, module_or_list)

	if not ok then
		vim.schedule(function()
			local snacks = pcall(require, "snacks") and require("snacks")
			if snacks then
				snacks.notify(
					string.format("[%s SEQUENCE FAILURE]\nModule: %s\nError: %s", desc, module_or_list, result),
					{ title = "Init.lua Fault Tolerance", level = vim.log.levels.ERROR }
				)
			else
				vim.notify(
					string.format("[%s SEQUENCE FAILURE]\nModule: %s\nError: %s", desc, module_or_list, result),
					vim.log.levels.ERROR,
					{ title = "Init.lua Fault Tolerance" }
				)
			end
		end)
		return setmetatable({}, {
			__index = function()
				return function() end
			end,
		})
	end

	return result
end

-- 1. Performance optimization
if vim.loader then
	vim.loader.enable()
end

-- 2. Experimental features
Config.safe_require("vim._core.ui2").enable({})

-- 3. Built-in plugin activation
local builtins = {
	"nvim.difftool",
	"cfilter",
	"nvim.undotree",
	"nohlsearch",
}

for _, plugin in ipairs(builtins) do
	vim.cmd.packadd(plugin)
end

-- 4. Built-in plugin deactivation
local disabled_builtins = {
	"netrw",
	"netrwPlugin",
	"netrwSettings",
	"netrwFileHandlers",
	"gzip",
	"zip",
	"zipPlugin",
	"tar",
	"tarPlugin",
	"getscript",
	"getscriptPlugin",
	"vimball",
	"vimballPlugin",
	"2html_plugin",
	"logipat",
	"rrhelper",
	"matchit",
}

for _, plugin in ipairs(disabled_builtins) do
	vim.g["loaded_" .. plugin] = 1
end

-- 5. Runtime path cleanup
local unwanted_paths = { "/usr/share/vim/vimfiles", "/usr/share/vim/vimfiles/after" }
vim.opt.runtimepath:remove(unwanted_paths)

-- 6. Bootstrap
