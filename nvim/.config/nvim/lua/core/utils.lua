local M = {}

-- =============================================================================
-- [ FILESYSTEM & PROJECTS ]
-- Helpers for project discovery and filesystem navigation.
-- =============================================================================

--- Centralized Project Root Resolver
--- Why: Deterministic project discovery for LSP, File Explorer, and Grep.
--- Uses vim.fs.root (0.10+) which returns the *nearest* ancestor containing
--- any marker — correct for monorepos where a nested go.mod should win over
--- a parent .git.
--- @return string path The absolute path to the project root or CWD.
M.project_root = function()
	local markers = {
		'.git',
		'go.mod',
		'Cargo.toml',
		'package.json',
		'pom.xml',
		'pyproject.toml',
		'build.zig',
		'Makefile',
		'justfile',
	}
	return vim.fs.root(0, markers) or vim.fn.getcwd()
end

-- =============================================================================
-- [ AUTOCOMMANDS & EVENTS ]
-- Simplified API for Neovim's event system.
-- =============================================================================

-- Global augroup for custom configuration to allow easy clearing/re-loading.
local gr = vim.api.nvim_create_augroup('custom-config', { clear = true })

--- Create a custom autocommand within the 'custom-config' group.
--- @param event string|table Event name(s) to trigger on (e.g., 'BufWritePost').
--- @param pattern string|table File pattern(s) to match.
--- @param callback function|string The action to perform.
--- @param desc string Description of the autocommand for documentation.
M.new_autocmd = function(event, pattern, callback, desc)
	vim.api.nvim_create_autocmd(event, {
		group = gr,
		pattern = pattern,
		callback = callback,
		desc = desc,
	})
end

--- Custom hook for 'PackChanged' events (specific to the pack manager).
--- Allows executing logic when a specific plugin is added or updated.
M.on_packchanged = function(plugin_name, kinds, callback, desc)
	local f = function(ev)
		local spec = ev.data.spec
		local name = spec.name
			or (spec.src and vim.fn.fnamemodify(spec.src, ':t'))
			or (type(spec[1]) == 'string' and vim.fn.fnamemodify(spec[1], ':t'))
			or 'unknown'
		name = name:gsub('%.nvim$', '')

		local kind = ev.data.kind
		if not (name == plugin_name and vim.tbl_contains(kinds, kind)) then
			return
		end
		if not ev.data.active then
			vim.cmd.packadd(plugin_name)
		end
		callback(ev.data)
	end
	M.new_autocmd('PackChanged', '*', f, desc)
end

-- =============================================================================
-- [ KEYBINDINGS ]
-- Standardized mapping helpers to ensure descriptions are always present.
-- =============================================================================

local map = vim.keymap.set

--- Define a Normal mode mapping with a mandatory description.
M.nmap = function(keys, func, desc)
	map('n', keys, func, { desc = desc })
end

--- Define an Insert mode mapping with a mandatory description.
M.imap = function(keys, func, desc)
	map('i', keys, func, { desc = desc })
end

--- Define a mapping for any mode with a mandatory description.
--- @param mode string|table Mode short-name (e.g., 'n', 'v', 'i', or {'n', 'v'}).
M.map = function(mode, keys, func, desc)
	map(mode, keys, func, { desc = desc })
end

return M

