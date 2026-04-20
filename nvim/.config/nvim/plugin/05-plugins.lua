local plugin_modules = {
	"plugins.mini",
	"plugins.snacks",
	"plugins.which-key",
	"plugins.languages",
	"plugins.blink",
	"plugins.luaSnips",
}
Config.safe_require(plugin_modules, "PLUGIN")
