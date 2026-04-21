-- =============================================================================
-- [ CORE UTILS ]
-- Shared helper functions used across commands, autocmds, and keymaps.
-- =============================================================================

local M = {}

-- =============================================================================
-- [ FILESYSTEM & PROJECTS ]
-- Helpers for project discovery and filesystem navigation.
-- =============================================================================

--- Centralized Project Root Resolver
--- Why: Deterministic project discovery for LSP, File Explorer, and Grep.
--- Uses vim.fs.root which returns the *nearest* ancestor containing
--- any marker — correct for monorepos where a nested go.mod should win over
--- a parent .git.
--- @return string path The absolute path to the project root or CWD.
M.project_root = function()
	local markers = {
		".git",
		"go.mod",
		"Cargo.toml",
		"package.json",
		"pom.xml",
		"pyproject.toml",
		"build.zig",
		"Makefile",
		"justfile",
	}
	return vim.fs.root(0, markers) or vim.fn.getcwd()
end

-- =============================================================================
-- [ AUTOCOMMANDS & EVENTS ]
-- Simplified API for Neovim's event system.
-- =============================================================================

-- Global augroup for custom configuration to allow easy clearing/re-loading.
-- This ensures that when the config is sourced again, old autocommands are wiped.
local augroup = vim.api.nvim_create_augroup("custom-config", { clear = true })

--- Create a custom autocommand within the 'custom-config' group.
--- Why: Centralizes event handling and prevents duplicate registration on reload.
--- @param event string|table Event name(s) to trigger on (e.g., 'BufWritePost').
--- @param pattern string|table File pattern(s) to match.
--- @param action function|string The action to perform (Lua function or Vim command string).
--- @param desc string Description of the autocommand for documentation.
M.autocmd = function(event, pattern, action, desc)
	local opts = {
		group = augroup,
		pattern = pattern,
		desc = desc,
	}

	-- Automatically route to 'command' or 'callback' based on type.
	if type(action) == "string" then
		opts.command = action
	else
		opts.callback = action
	end

	vim.api.nvim_create_autocmd(event, opts)
end

--- Custom hook for 'PackChanged' events (specific to the pack manager).
--- Allows executing logic when a specific plugin is added or updated.
M.on_packchanged = function(plugin_name, kinds, callback, desc)
	local f = function(ev)
		local spec = ev.data.spec
		local name = spec.name
			or (spec.src and vim.fn.fnamemodify(spec.src, ":t"))
			or (type(spec[1]) == "string" and vim.fn.fnamemodify(spec[1], ":t"))
			or "unknown"
		name = name:gsub("%.nvim$", "")

		local kind = ev.data.kind
		if not (name == plugin_name and vim.tbl_contains(kinds, kind)) then
			return
		end
		if not ev.data.active then
			vim.cmd.packadd(plugin_name)
		end
		callback(ev.data)
	end
	M.autocmd("PackChanged", "*", f, desc)
end

-- =============================================================================
-- [ KEYBINDINGS ]
-- Standardized mapping helpers for consistent keymap declarations.
-- =============================================================================

local map = vim.keymap.set

--- Merge a description and optional keymap options into one opts table.
--- @param desc string|table|nil Keymap description, or opts table when used as shorthand.
--- @param opts table|nil Optional keymap options.
--- @return table merged Keymap options suitable for vim.keymap.set.
local function merge_map_opts(desc, opts)
	if type(desc) == "table" and opts == nil then
		opts = desc
		desc = opts.desc
	end

	local merged = vim.tbl_extend("force", {}, opts or {})
	if desc ~= nil then
		merged.desc = desc
	end

	return merged
end

--- Define a Normal mode mapping.
--- @param keys string Left-hand side mapping.
--- @param func string|function Right-hand side mapping target.
--- @param desc string|nil Human-readable keymap description.
--- @param opts table|nil Optional vim.keymap.set options.
M.nmap = function(keys, func, desc, opts)
	map("n", keys, func, merge_map_opts(desc, opts))
end

--- Define an Insert mode mapping.
--- @param keys string Left-hand side mapping.
--- @param func string|function Right-hand side mapping target.
--- @param desc string|nil Human-readable keymap description.
--- @param opts table|nil Optional vim.keymap.set options.
M.imap = function(keys, func, desc, opts)
	map("i", keys, func, merge_map_opts(desc, opts))
end

--- Define a mapping for any mode.
--- @param mode string|table Mode short-name (e.g., 'n', 'v', 'i', or {'n', 'v'}).
--- @param keys string Left-hand side mapping.
--- @param func string|function Right-hand side mapping target.
--- @param desc string|nil Human-readable keymap description.
--- @param opts table|nil Optional vim.keymap.set options.
M.map = function(mode, keys, func, desc, opts)
	map(mode, keys, func, merge_map_opts(desc, opts))
end

return M
