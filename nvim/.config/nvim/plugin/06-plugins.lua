-- plugin module registry

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
	"plugins.run",
}
Config.safe_require(plugin_modules, "PLUGIN")
