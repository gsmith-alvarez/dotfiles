local notify = require("commands.building.notify").notify

local M = {}

function M.in_zellij()
	return vim.env.ZELLIJ ~= nil
end

function M.zellij_pane(bash_cmd)
	vim.system(
		{ "zellij", "run", "-d", "right", "-c", "--", "bash", "-c", bash_cmd },
		{ text = true },
		function(obj)
			if obj.code ~= 0 then
				vim.schedule(function()
					notify(("zellij run failed (exit %d): %s"):format(obj.code, obj.stderr or ""), vim.log.levels.ERROR)
				end)
			end
		end
	)
end

function M.snacks_terminal(bash_cmd)
	require("snacks").terminal.toggle({ "bash", "-c", bash_cmd })
end

function M.watch(watchexec, root, bash_cmd)
	local argv = { watchexec, "-r", "-c", "-w", root, "--", "bash", "-c", bash_cmd }
	if M.in_zellij() then
		local full = { "zellij", "run", "-d", "right", "-c", "--" }
		vim.list_extend(full, argv)
		vim.system(full, { text = true }, function(obj)
			if obj.code ~= 0 then
				vim.schedule(function()
					notify(("zellij run failed (exit %d): %s"):format(obj.code, obj.stderr or ""), vim.log.levels.ERROR)
				end)
			end
		end)
	else
		require("snacks").terminal.toggle(argv)
	end
end

return M
