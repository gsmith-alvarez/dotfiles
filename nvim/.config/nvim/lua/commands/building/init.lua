-- =============================================================================
-- [ BUILDING COMMANDS ]
-- Implements :Run, :RunWatch, and :Watch command behaviors.
-- =============================================================================

local notify = require("commands.building.notify").notify
local runners = require("commands.building.runners")
local exec = require("commands.building.executors")

local M = {}

local ROOT_MARKERS = {
	".git",
	"go.mod",
	"Cargo.toml",
	"build.zig",
	"Makefile",
	"CMakeLists.txt",
	"pyproject.toml",
}

--- Resolve project root for build execution.
--- @return string|nil root Project root directory when found.
local function project_root()
	return vim.fs.root(0, ROOT_MARKERS)
end

--- Append a keypress prompt so spawned commands stay visible.
--- @param cmd string Command to wrap.
--- @return string wrapped Command with pause prompt.
local function hold_open(cmd)
	return cmd .. [[; echo ""; echo "Press any key to close..."; read -n 1 -s]]
end

--- Smart file runner that dispatches by filetype and runtime context.
--- @param continuous boolean When true, runs in watch mode.
local function smart_run(continuous)
	local buf = vim.api.nvim_get_current_buf()
	local ft = vim.bo[buf].filetype
	local file = vim.api.nvim_buf_get_name(buf)

	if file == "" then
		notify("Buffer has no file", vim.log.levels.WARN)
		return
	end

	if vim.bo[buf].modified then
		vim.cmd("silent! update")
	end

	local cmd, err = runners.build(ft, { file = file, root = project_root() })
	if not cmd then
		notify(err or "No runner", vim.log.levels.WARN)
		return
	end

	if continuous then
		vim.cmd("Watch " .. cmd)
		return
	end

	local payload = hold_open(cmd)
	if exec.in_zellij() then
		exec.zellij_pane(payload)
	else
		exec.snacks_terminal(payload)
	end

	notify("Executing: " .. cmd, vim.log.levels.DEBUG)
end

--- Implementation for :Watch command.
--- @param opts table Command options passed by nvim_create_user_command.
local function watch_impl(opts)
	if vim.fn.executable("watchexec") ~= 1 then
		notify("watchexec not found. Install via: mise install watchexec", vim.log.levels.ERROR)
		return
	end

	local cmd_args = opts.args
	if cmd_args:match("%%") then
		local current_file = vim.api.nvim_buf_get_name(0)
		if current_file == "" then
			notify("No file open to expand %", vim.log.levels.WARN)
			return
		end
		cmd_args = cmd_args:gsub("%%", vim.fn.shellescape(current_file))
	end

	local root = project_root() or vim.uv.cwd()
	exec.watch("watchexec", root, cmd_args)
	notify("Watcher active: " .. cmd_args, vim.log.levels.DEBUG)
end

M.setup = {
	Watch = {
		options = {
			desc = "Run command continuously in Zellij via watchexec",
			nargs = "+",
		},
		impl = watch_impl,
	},
	Run = {
		options = { desc = "Run the current file smartly" },
		impl = function()
			smart_run(false)
		end,
	},
	RunWatch = {
		options = { desc = "Run the current file with watchexec" },
		impl = function()
			smart_run(true)
		end,
	},
	SmartRun = {
		options = { desc = "Run the current file based on filetype (legacy name)" },
		impl = function()
			smart_run(false)
		end,
	},
}

return M
