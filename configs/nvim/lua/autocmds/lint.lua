-- lint

local M = {}

local severity = vim.diagnostic.severity

--- Linters run on the saved file and print JSON; `parse` maps that report to
--- vim.diagnostic items. A clean run prints nothing, which clears diagnostics.
local linters = {
	statix = {
		cmd = function(file)
			return { "statix", "check", "-o", "json", file }
		end,
		parse = function(report)
			local items = {}
			for _, lint in ipairs(report.report) do
				for _, d in ipairs(lint.diagnostics) do
					table.insert(items, {
						lnum = d.at.from.line - 1,
						col = d.at.from.column - 1,
						end_lnum = d.at.to.line - 1,
						end_col = d.at.to.column - 1,
						severity = lint.severity == "Error" and severity.ERROR or severity.WARN,
						message = lint.note .. ": " .. d.message,
					})
				end
			end
			return items
		end,
	},
	deadnix = {
		cmd = function(file)
			return { "deadnix", "-o", "json", file }
		end,
		parse = function(report)
			return vim.tbl_map(function(r)
				return {
					lnum = r.line - 1,
					col = r.column - 1,
					end_col = r.endColumn - 1,
					severity = severity.WARN,
					message = r.message,
				}
			end, report.results)
		end,
	},
}

for name, linter in pairs(linters) do
	linter.namespace = vim.api.nvim_create_namespace(name)
end

local function lint(buf)
	local file = vim.api.nvim_buf_get_name(buf)
	for name, linter in pairs(linters) do
		local cmd = linter.cmd(file)
		if vim.fn.executable(cmd[1]) == 1 then
			vim.system(
				cmd,
				{ text = true },
				vim.schedule_wrap(function(result)
					if not vim.api.nvim_buf_is_valid(buf) then
						return
					end
					local ok, items = pcall(function()
						return linter.parse(vim.json.decode(result.stdout))
					end)
					items = ok and items or {}
					for _, item in ipairs(items) do
						item.source = name
					end
					vim.diagnostic.set(linter.namespace, buf, items)
				end)
			)
		end
	end
end

M.setup = {
	{
		event = { "BufReadPost", "BufWritePost" },
		pattern = "*.nix",
		action = function(ev)
			lint(ev.buf)
		end,
		desc = "Lint Nix with statix and deadnix",
	},
}

return M
