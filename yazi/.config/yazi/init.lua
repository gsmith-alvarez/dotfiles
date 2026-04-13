require("git"):setup({
	-- Order of status signs showing in the linemode
	order = 1500,
})

require("full-border"):setup({
	type = ui.Border.ROUNDED,
})

-- Add a clock component to the status bar
Status:children_add(function()
	return ui.Span(os.date("%H:%M ")):fg("blue")
end, 500, Status.RIGHT)

require("starship"):setup()
