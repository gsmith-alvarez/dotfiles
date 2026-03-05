-- [[ NATIVE FORMATTING BRIDGE ]]
-- Domain: Buffer Transformation & Standardization
--
-- PHILOSOPHY: Direct-to-Metal Execution
-- This module implements a zero-dependency formatting architecture. By
-- bypassing intermediate abstraction layers (conform, null-ls), we reduce
-- latency and eliminate "plugin-creep." It leverages the Neovim 0.10+
-- vim.system API for high-performance, synchronous CLI filtering.

local utils = require 'core.utils'

local M = {}

--- [[ TOOLCHAIN REGISTRY & CUSTOMIZATION GUIDE ]]
--- To add a new formatter, it MUST satisfy these requirements:
--- 1. It must read from `stdin` (the current state of your Neovim buffer).
--- 2. It must write to `stdout` (the formatted text).
--- 3. `is_filter` MUST be true. Tools that format files "in-place" on your SSD
---    will corrupt data if run during a Neovim `BufWritePre` hook.
---
--- @type table<string, {bin: string, args: table, is_filter: boolean}>
local formatters = {
	lua = {
		bin = 'stylua',
		-- $FILENAME is dynamically replaced. This allows stylua to locate your
		-- .stylua.toml file in the directory tree while still formatting stdin.
		args = { '-', '--search-parent-directories', '--stdin-filepath', '$FILENAME' },
		is_filter = true,
	},
	javascript = {
		bin = 'oxfmt',
		args = { '-', '--stdin-filename', '$FILENAME' },
		is_filter = true,
	},
	typescript = {
		bin = 'oxfmt',
		args = { '-', '--stdin-filename', '$FILENAME' },
		is_filter = true,
	},
	python = {
		bin = 'ruff',
		args = { 'format', '-', '--stdin-filename', '$FILENAME' },
		is_filter = true,
	},
	fish = {
		bin = 'fish_indent',
		args = {},
		is_filter = true,
	},
	-- ⚠️ ARCHITECTURAL TRAP AVOIDED:
	-- markdownlint-cli2 does not support stdin filtering easily.
	-- Running in-place formatters during BufWritePre overwrites disk data right
	-- before Neovim writes buffer memory, destroying the file.
	-- This belongs in a separate linting pipeline, not the synchronous save hook.
	-- markdown = { ... }
}

--- Captures the current window state (cursor, scroll, folds).
--- This is used to maintain visual continuity across destructive buffer edits.
local function get_view_state()
	return vim.fn.winsaveview()
end

--- Restores the window state with type-safety checks.
--- @param view table|nil The view dictionary returned by winsaveview.
local function restore_view_state(view)
	if view and type(view) == 'table' then
		vim.fn.winrestview(view)
	end
end

--- Internal execution engine for CLI-based formatting.
--- @param ft string The filetype for configuration lookup.
local function format_with_cli(ft)
	local config = formatters[ft]
	if not config then
		return
	end

	-- TEMPORAL GUARDRAIL: We cannot format files on-disk during a pre-save hook.
	if not config.is_filter then
		utils.soft_notify(
		string.format("Format Error: '%s' is an in-place editor. BufWritePre formatters must be stdin filters.",
			config.bin), vim.log.levels.ERROR)
		return
	end

	local bin_path = utils.mise_shim(config.bin)
	if not bin_path then
		-- Graceful degradation: Log but don't disrupt the save loop.
		return
	end

	local filename = vim.api.nvim_buf_get_name(0)
	local args = {}
	for _, arg in ipairs(config.args) do
		table.insert(args, (arg:gsub('$FILENAME', filename)))
	end

	-- Pull the raw memory buffer to send to the CLI tool
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local input = table.concat(lines, '\n')

	-- Execute synchronously to ensure the write happens AFTER the format.
	local result = vim.system({ bin_path, unpack(args) }, { stdin = input, text = true }):wait()

	if result.code == 0 then
		-- DATA LOSS FIX: Strip only the terminal newline left by the CLI tool.
		-- Using `plain = true` prevents vim.split from destroying intentional
		-- internal blank lines in your source code.
		local safe_stdout = result.stdout:gsub('\n$', '')
		local output_lines = vim.split(safe_stdout, '\n', { plain = true })

		local view = get_view_state()
		vim.api.nvim_buf_set_lines(0, 0, -1, false, output_lines)
		restore_view_state(view)
	else
		utils.soft_notify('Format Failure (' .. config.bin .. '): ' .. (result.stderr or 'Error'),
			vim.log.levels.WARN)
	end
end

--- Main entry point for formatting orchestration.
--- Prioritizes LSP capabilities with a CLI fallback mechanism.
function M.autoformat()
	local ft = vim.bo.filetype
	local view = get_view_state()

	-- 1. LSP Formatting (Highest Priority)
	-- If a language server (like gopls or rust-analyzer) provides formatting, we use it natively.
	local lsp_clients = vim.lsp.get_clients { bufnr = 0, method = 'textDocument/formatting' }
	if #lsp_clients > 0 then
		vim.lsp.buf.format { async = false, timeout_ms = 1000 }
	else
		-- 2. CLI Formatting (Mise Fallback)
		-- If no LSP handles formatting (e.g., Lua or Python if Ruff isn't attached as an LSP), route to our CLI engine.
		format_with_cli(ft)
	end

	-- 3. Global Hygiene: Trim trailing whitespace
	-- Excluded for formatting-sensitive types where trailing spaces dictate syntax (like Markdown line breaks).
	local excluded_hygiene = { 'markdown', 'markdown.mdx', 'diff', 'mail' }
	if not vim.tbl_contains(excluded_hygiene, ft) then
		local cursor_view = get_view_state()
		vim.cmd [[keepjumps keeppatterns silent! %s/\s\+$//e]]
		restore_view_state(cursor_view)
	end

	-- Final visual anchor restoration
	restore_view_state(view)
end

-- [[ AUTOMATED ORCHESTRATION ]]

local group = vim.api.nvim_create_augroup('NativeFormatGroup', { clear = true })

-- Attaches to the save event directly.
vim.api.nvim_create_autocmd('BufWritePre', {
	group = group,
	pattern = '*',
	callback = function()
		M.autoformat()
	end,
	desc = 'Synchronous buffer transformation prior to disk write',
})

-- Format keymap moved to lua/core/plugin-keymaps.lua (<leader>cf under Code section).

return M
