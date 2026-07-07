-- =============================================================================
-- [ RUN.NVIM ]
-- Smart code runner and watcher configuration.
-- =============================================================================

local run = Config.safe_require("run")
if not run then
	return
end

run.setup({
	-- You can place custom configuration overrides here.
	-- Default options (e.g. root_markers, zellij auto-detect, watchexec, default runners)
	-- are already defined in the plugin.
})
