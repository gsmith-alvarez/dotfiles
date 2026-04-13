-- =============================================================================
-- [ INIT.LUA ]
-- Entry point for Neovim configuration.
-- =============================================================================

-- 1. [ PERFORMANCE OPTIMIZATION ]
-- Enable the experimental Lua loader to speed up startup by caching byte-code.
if vim.loader then
	vim.loader.enable()
end

-- 2. [ EXPERIMENTAL FEATURES ]
-- Enable "Experimental 0.12 features" for enhanced UI capabilities.
-- This uses pcall to safely check if the module exists before requiring.
if pcall(require, 'vim._core.ui2') then
	require('vim._core.ui2').enable {}
end

-- 3. [ BUILT-IN PLUGIN ACTIVATION ]
-- Enable built-in plugins that are useful but not enabled by default.
local builtins = {
  'nvim.difftool', -- Enhanced side-by-side directory and file comparison
  'cfilter',       -- Allows filtering the quickfix and location list (:Cfilter)
  'nvim.undotree', -- Native interactive undo history visualization
  'justify',       -- Provides the :Justify command for text alignment
  'nohlsearch',    -- Automatically disables search highlighting after moving
}

for _, plugin in ipairs(builtins) do
	vim.cmd.packadd(plugin)
end

-- 4. [ BUILT-IN PLUGIN DEACTIVATION ]
-- Disable certain built-in features that we replace with more powerful plugins
-- or simply don't use to reduce bloat and improve startup speed.
local disabled_builtins = {
  "netrw",              -- Replaced by mini.files
  "netrwPlugin",
  "netrwSettings",
  "netrwFileHandlers",
  "gzip",               -- Compression support (unnecessary for most)
  "zip",
  "zipPlugin",
  "tar",
  "tarPlugin",
  "getscript",          -- Legacy Vim script distribution tools
  "getscriptPlugin",
  "vimball",
  "vimballPlugin",
  "2html_plugin",       -- Convert buffer to HTML
  "logipat",            -- Logical patterns
  "rrhelper",
  "matchit",            -- Enhanced % matching (handled by treesitter/mini.ai)
}

for _, plugin in ipairs(disabled_builtins) do
	vim.g['loaded_' .. plugin] = 1
end

-- 5. [ RUNTIME PATH CLEANUP ]
-- Remove legacy Arch Linux Vim paths from the runtimepath to avoid conflicts
-- and ensure a clean environment.
local unwanted_paths = { '/usr/share/vim/vimfiles', '/usr/share/vim/vimfiles/after' }
vim.opt.runtimepath:remove(unwanted_paths)

-- 6. [ MODULE LOADING ARCHITECTURE ]
-- Define a helper function to safely load configuration modules.
-- If a module fails to load, it will notify the user via a non-blocking notification
-- instead of crashing the entire startup process.
local function safe_require(module)
	local ok, err = pcall(require, module)
	if not ok then
		-- Use vim.schedule to ensure notifications don't interfere with startup UI
		vim.schedule(function()
			vim.notify(
				string.format('[BOOT SEQUENCE FAILURE]\nModule: %s\nError: %s', module, err),
				vim.log.levels.ERROR,
				{ title = 'Init.lua Fault Tolerance' }
			)
		end)
	end
	return ok
end

-- 7. [ CORE & PLUGINS INITIALIZATION ]
-- Load the main configuration components.
safe_require 'core'    -- Essential settings, paths, and keymaps
safe_require 'plugins' -- Plugin specifications and configurations
