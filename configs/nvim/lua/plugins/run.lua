-- run.nvim

vim.filetype.add({
	extension = {
		cir = "spice",
		sp = "spice",
		spice = "spice",
		net = "spice",
	},
})

local run = Config.safe_require("run")
if not run then
	return
end

run.setup({
	runners = {
		spice = function(ctx)
			return ("ngspice -b %s"):format(ctx.esc(ctx.file))
		end,
	},
})
