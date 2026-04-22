-- =============================================================================
-- [ PLUGIN MODULE REGISTRY ]
-- Central list of plugin configuration modules to load.
-- =============================================================================

local plugin_modules = {
	"plugins.mini",
	"plugins.snacks",
	"plugins.languages",
	"plugins.completion",
	"plugins.markdown",
	"plugins.which-key",
	"plugins.menu",
	"plugins.quickfix",
	"plugins.navigation",
}
Config.safe_require(plugin_modules, "PLUGIN")
