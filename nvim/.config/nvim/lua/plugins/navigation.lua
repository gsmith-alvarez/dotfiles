local mini = Config.safe_require("plugins.mini")

mini.later(function()
	local s = Config.safe_require("sigils")
	s.setup()
end)
