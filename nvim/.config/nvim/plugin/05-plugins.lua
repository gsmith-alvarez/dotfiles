local plugin_modules = {
	"plugins.mini",
	"plugins.snacks",
	"plugins.treesitter",
	"plugins.languages",
	"plugins.luaSnips",
	"plugins.blink",
	"plugins.obsidian",
	"plugins.render-markdown",
	"plugins.which-key",
	"plugins.dropbar",
	"plugins.menu",
}
Config.safe_require(plugin_modules, "PLUGIN")
