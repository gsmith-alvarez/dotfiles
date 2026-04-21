-- =============================================================================
-- [ INIT.LUA ]
-- Entry point for Neovim configuration.
-- =============================================================================

-- Define config table to be able to pass data between scripts
-- It is a global variable which can be use both as `_G.Config` and `Config`
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

-- Assign the anonymous function directly to the table key.
Config.safe_require = function(module_or_list, desc)
	-- Use the call stack to find the executing script, fallback to SYSTEM
	desc = desc or (debug.getinfo(2, "S") and debug.getinfo(2, "S").source:match("@?(.*/)") or "SYSTEM")

	-- Handle table of modules recursively
	if type(module_or_list) == "table" then
		local loaded_modules = {}
		for _, m in ipairs(module_or_list) do
			-- Recursively call and store the payload by module name
			loaded_modules[m] = Config.safe_require(m, desc)
		end
		-- Return the dictionary of loaded modules
		return loaded_modules
	end

	-- Base case: handle single string module
	local ok, result = pcall(require, module_or_list)

	-- Check if nil patterns
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

-- 1. [ PERFORMANCE OPTIMIZATION ]
-- Enable the experimental Lua loader to speed up startup by caching byte-code.
if vim.loader then
	vim.loader.enable()
end

-- 2. [ EXPERIMENTAL FEATURES ]
Config.safe_require("vim._core.ui2").enable({})

-- 3. [ BUILT-IN PLUGIN ACTIVATION ]
-- Enable built-in plugins that are useful but not enabled by default.
local builtins = {
	"nvim.difftool",
	"cfilter",
	"nvim.undotree",
	"justify",
	"nohlsearch",
}

for _, plugin in ipairs(builtins) do
	vim.cmd.packadd(plugin)
end

-- 4. [ BUILT-IN PLUGIN DEACTIVATION ]
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

-- 5. [ RUNTIME PATH CLEANUP ]
local unwanted_paths = { "/usr/share/vim/vimfiles", "/usr/share/vim/vimfiles/after" }
vim.opt.runtimepath:remove(unwanted_paths)

-- 6. [ BOOTSTRAP ]
-- The 'plugin/' directory is auto-loaded by Neovim's engine.
